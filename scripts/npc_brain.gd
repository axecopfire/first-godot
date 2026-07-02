class_name NpcBrain
extends RefCounted

const ACTION_HOME := "home"
const ACTION_WORK := "work"
const ACTION_SOCIALIZE := "socialize"
const ACTION_WANDER := "wander"

const GOAP_ACTION_GO_TO_WORK := "GoToWork"
const GOAP_ACTION_GO_HOME := "GoHome"
const GOAP_ACTION_SOCIALIZE_AT_HUB := "SocializeAtHub"
const GOAP_ACTION_WANDER_LOCAL := "WanderLocal"

const _GOAP_MAX_DEPTH := 3

var _rng := RandomNumberGenerator.new()
var _decision_cooldown := 0.0
var _current_action := ACTION_HOME
var _current_target := Vector2.ZERO
var _current_reason := ""

var _goap_actions: Array[Dictionary] = []
var _goap_current_plan: Array[String] = []
var _goap_current_goal := ""
var _goap_cached_world_key := ""
var _goap_cached_goal := ""
var _last_socialized_hour := -99

## Telemetry: set true for one tick whenever _reconsider_action_goap runs.
var _decision_made_this_tick := false
var _last_trigger := ""

func _init(seed_value: int = 0) -> void:
	if seed_value == 0:
		seed_value = int(Time.get_unix_time_from_system())
	_rng.seed = seed_value
	_init_goap_actions()

func tick(
	delta: float,
	cycle_progress: float,
	current_position: Vector2,
	home_position: Vector2,
	work_position: Vector2,
	morning_depart_hour: int,
	evening_return_hour: int,
	world_state: Dictionary,
	is_player_nearby: bool,
	has_friendly_tie: bool
) -> Dictionary:
	_decision_made_this_tick = false
	_decision_cooldown = maxf(_decision_cooldown - delta, 0.0)
	if _decision_cooldown <= 0.0:
		_reconsider_action_goap(
			cycle_progress,
			current_position,
			home_position,
			work_position,
			morning_depart_hour,
			evening_return_hour,
			world_state,
			is_player_nearby,
			has_friendly_tie
		)

	if _current_action == ACTION_SOCIALIZE:
		_last_socialized_hour = int(cycle_progress * 24.0) % 24

	return {
		"action": _current_action,
		"target": _current_target,
		"reason": _current_reason,
		"goal": _goap_current_goal,
		"plan_step": _goap_current_plan[0] if _goap_current_plan.size() > 0 else "",
		"new_decision": _decision_made_this_tick,
		"trigger": _last_trigger,
	}

func _reconsider_action_goap(
	cycle_progress: float,
	current_position: Vector2,
	home_position: Vector2,
	work_position: Vector2,
	morning_depart_hour: int,
	evening_return_hour: int,
	world_state: Dictionary,
	is_player_nearby: bool,
	has_friendly_tie: bool
) -> void:
	var hour: int = int(cycle_progress * 24.0) % 24
	var social_hub: Vector2 = world_state.get("social_hub_position", (home_position + work_position) * 0.5)
	var facts := _build_world_facts(
		hour,
		current_position,
		home_position,
		work_position,
		social_hub,
		morning_depart_hour,
		evening_return_hour,
		world_state,
		is_player_nearby,
		has_friendly_tie
	)

	var goal := _select_goal(facts)
	_goap_current_goal = goal.get("name", "")
	var world_key := _world_signature(facts)

	if _goap_cached_world_key != world_key or _goap_cached_goal != _goap_current_goal or _goap_current_plan.is_empty():
		_goap_current_plan = _plan_for_goal(facts, goal, _GOAP_MAX_DEPTH)
		_goap_cached_world_key = world_key
		_goap_cached_goal = _goap_current_goal

	if _goap_current_plan.is_empty():
		# Safety fallback inside GOAP-only mode: default to home if no plan is found.
		_current_action = ACTION_HOME
		_current_target = home_position
		_current_reason = "goap h%02d goal=%s fallback=GoHome" % [hour, _goap_current_goal]
		_decision_cooldown = _rng.randf_range(4.5, 8.5)
		_decision_made_this_tick = true
		_last_trigger = "cooldown_expired"
		return

	var step_name := _goap_current_plan[0]
	var mapped_action := _goap_step_to_runtime_action(step_name)
	_current_action = mapped_action
	_current_target = _target_for_step(step_name, current_position, home_position, work_position, social_hub)
	_current_reason = "goap h%02d goal=%s step=%s" % [hour, _goap_current_goal, step_name]
	_decision_cooldown = _rng.randf_range(4.5, 8.5)
	_decision_made_this_tick = true
	_last_trigger = "cooldown_expired"

func _init_goap_actions() -> void:
	_goap_actions = [
		{
			"name": GOAP_ACTION_GO_TO_WORK,
			"cost": 1.0,
			"pre": {},
			"effects": {
				"at_work": true,
				"at_home": false,
				"at_social_hub": false,
			},
		},
		{
			"name": GOAP_ACTION_GO_HOME,
			"cost": 1.0,
			"pre": {},
			"effects": {
				"at_home": true,
				"at_work": false,
				"at_social_hub": false,
			},
		},
		{
			"name": GOAP_ACTION_SOCIALIZE_AT_HUB,
			"cost": 1.4,
			"pre": {
				"bell_pending": false,
			},
			"effects": {
				"at_social_hub": true,
				"at_home": false,
				"at_work": false,
				"recently_socialized": true,
			},
		},
		{
			"name": GOAP_ACTION_WANDER_LOCAL,
			"cost": 1.8,
			"pre": {},
			"effects": {
				"recently_socialized": false,
			},
		},
	]

func _build_world_facts(
	hour: int,
	current_position: Vector2,
	home_position: Vector2,
	work_position: Vector2,
	social_hub: Vector2,
	morning_depart_hour: int,
	evening_return_hour: int,
	world_state: Dictionary,
	is_player_nearby: bool,
	has_friendly_tie: bool
) -> Dictionary:
	var in_work_window := hour >= morning_depart_hour and hour < evening_return_hour
	var bell_pending := int(world_state.get("bell_pending_tolls", 0)) > 0
	var at_home := current_position.distance_to(home_position) <= 8.0
	var at_work := current_position.distance_to(work_position) <= 8.0
	var at_social_hub := current_position.distance_to(social_hub) <= 8.0
	var recently_socialized: bool = abs(hour - _last_socialized_hour) <= 2

	return {
		"in_work_window": in_work_window,
		"bell_pending": bell_pending,
		"player_nearby": is_player_nearby,
		"has_friendly_tie": has_friendly_tie,
		"at_home": at_home,
		"at_work": at_work,
		"at_social_hub": at_social_hub,
		"recently_socialized": recently_socialized,
	}

func _select_goal(facts: Dictionary) -> Dictionary:
	var goals: Array[Dictionary] = []
	if bool(facts.get("in_work_window", false)):
		goals.append({
			"name": "maintain_role_routine",
			"priority": 4,
			"desired": {"at_work": true},
		})
	else:
		goals.append({
			"name": "maintain_rest_routine",
			"priority": 4,
			"desired": {"at_home": true},
		})

	goals.append({
		"name": "maintain_social_assimilation",
		"priority": 3,
		"desired": {"recently_socialized": true},
	})

	if bool(facts.get("bell_pending", false)) and bool(facts.get("player_nearby", false)):
		goals.append({
			"name": "avoid_attention_spike",
			"priority": 5,
			"desired": {"at_home": true},
		})
	else:
		goals.append({
			"name": "avoid_attention_spike",
			"priority": 2,
			"desired": {"at_social_hub": false},
		})

	goals.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		var pa := int(a.get("priority", 0))
		var pb := int(b.get("priority", 0))
		if pa == pb:
			return str(a.get("name", "")) < str(b.get("name", ""))
		return pa > pb
	)

	return goals[0]

func _plan_for_goal(initial_facts: Dictionary, goal: Dictionary, max_depth: int) -> Array[String]:
	var desired: Dictionary = goal.get("desired", {})
	if _goal_is_satisfied(initial_facts, desired):
		return []

	var open_list: Array[Dictionary] = [{
		"facts": initial_facts,
		"cost": 0.0,
		"steps": PackedStringArray(),
	}]
	var visited: Dictionary = {}
	var best_plan: Array[String] = []
	var best_cost := INF

	while not open_list.is_empty():
		_open_list_sort(open_list)
		var node: Dictionary = open_list.pop_front()
		var node_facts: Dictionary = node.get("facts", {})
		var node_cost: float = float(node.get("cost", INF))
		var node_steps: PackedStringArray = node.get("steps", PackedStringArray())

		if node_steps.size() > max_depth:
			continue

		if _goal_is_satisfied(node_facts, desired):
			if node_cost < best_cost:
				best_cost = node_cost
				best_plan = Array(node_steps)
			continue

		if node_cost >= best_cost:
			continue

		for action in _goap_actions:
			if not _matches_conditions(node_facts, action.get("pre", {})):
				continue

			var next_facts := _apply_effects(node_facts, action.get("effects", {}))
			var next_steps := node_steps.duplicate()
			next_steps.append(str(action.get("name", "")))
			var next_cost := node_cost + float(action.get("cost", 1.0))
			var signature := _world_signature(next_facts) + "|" + ",".join(next_steps)

			if visited.has(signature) and float(visited[signature]) <= next_cost:
				continue

			visited[signature] = next_cost
			open_list.append({
				"facts": next_facts,
				"cost": next_cost,
				"steps": next_steps,
			})

	return best_plan

func _open_list_sort(open_list: Array[Dictionary]) -> void:
	open_list.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		var ca := float(a.get("cost", INF))
		var cb := float(b.get("cost", INF))
		if ca == cb:
			var sa: PackedStringArray = a.get("steps", PackedStringArray())
			var sb: PackedStringArray = b.get("steps", PackedStringArray())
			if sa.size() == sb.size():
				return ",".join(sa) < ",".join(sb)
			return sa.size() < sb.size()
		return ca < cb
	)

func _goal_is_satisfied(facts: Dictionary, desired: Dictionary) -> bool:
	return _matches_conditions(facts, desired)

func _matches_conditions(facts: Dictionary, conditions: Dictionary) -> bool:
	for key in conditions.keys():
		if facts.get(key, null) != conditions[key]:
			return false
	return true

func _apply_effects(facts: Dictionary, effects: Dictionary) -> Dictionary:
	var merged := facts.duplicate()
	for key in effects.keys():
		merged[key] = effects[key]
	return merged

func _world_signature(facts: Dictionary) -> String:
	var keys := facts.keys()
	keys.sort()
	var parts := PackedStringArray()
	for key in keys:
		parts.append("%s=%s" % [str(key), str(facts[key])])
	return "|".join(parts)

func _goap_step_to_runtime_action(step_name: String) -> String:
	match step_name:
		GOAP_ACTION_GO_TO_WORK:
			return ACTION_WORK
		GOAP_ACTION_GO_HOME:
			return ACTION_HOME
		GOAP_ACTION_SOCIALIZE_AT_HUB:
			return ACTION_SOCIALIZE
		GOAP_ACTION_WANDER_LOCAL:
			return ACTION_WANDER
		_:
			return ACTION_HOME

func _target_for_step(
	step_name: String,
	current_position: Vector2,
	home_position: Vector2,
	work_position: Vector2,
	social_hub: Vector2
) -> Vector2:
	match step_name:
		GOAP_ACTION_GO_TO_WORK:
			return work_position
		GOAP_ACTION_GO_HOME:
			return home_position
		GOAP_ACTION_SOCIALIZE_AT_HUB:
			return social_hub
		GOAP_ACTION_WANDER_LOCAL:
			return current_position + Vector2(_rng.randf_range(-64.0, 64.0), _rng.randf_range(-64.0, 64.0))
		_:
			return home_position
