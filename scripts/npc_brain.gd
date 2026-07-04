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
var _last_goal_score := 0.0
var _last_challenger_score := 0.0
var _last_hysteresis_retained := false

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
		"goal_score": _last_goal_score,
		"challenger_score": _last_challenger_score,
		"hysteresis_decision": _last_hysteresis_retained,
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

	var hard_reevaluation := bool(facts.get("bell_pending", false)) and bool(facts.get("player_nearby", false))
	var goal := _select_goal(facts, hard_reevaluation)
	_goap_current_goal = goal.get("name", "")
	var world_key := _world_signature(facts)

	if _goap_cached_world_key != world_key or _goap_cached_goal != _goap_current_goal or _goap_current_plan.is_empty():
		_goap_current_plan = _plan_for_goal(facts, goal, _GOAP_MAX_DEPTH)
		_goap_cached_world_key = world_key
		_goap_cached_goal = _goap_current_goal

	if _goap_current_plan.is_empty() and _goal_is_satisfied(facts, goal.get("desired", {})):
		_current_action = _goal_to_runtime_action(goal.get("name", ""))
		_current_target = _target_for_goal(goal.get("name", ""), current_position, home_position, work_position, social_hub)
		_current_reason = "goap h%02d goal=%s satisfied" % [hour, _goap_current_goal]
		_decision_cooldown = _rng.randf_range(4.5, 8.5)
		_decision_made_this_tick = true
		_last_trigger = "hard_reevaluation" if hard_reevaluation else "cooldown_expired"
		return

	if _goap_current_plan.is_empty():
		# Safety fallback inside GOAP-only mode: default to home if no plan is found.
		_current_action = ACTION_HOME
		_current_target = home_position
		_current_reason = "goap h%02d goal=%s fallback=GoHome" % [hour, _goap_current_goal]
		_decision_cooldown = _rng.randf_range(4.5, 8.5)
		_decision_made_this_tick = true
		_last_trigger = "hard_reevaluation" if hard_reevaluation else "cooldown_expired"
		return

	var step_name := _goap_current_plan[0]
	var mapped_action := _goap_step_to_runtime_action(step_name)
	_current_action = mapped_action
	_current_target = _target_for_step(step_name, current_position, home_position, work_position, social_hub)
	_current_reason = "goap h%02d goal=%s step=%s" % [hour, _goap_current_goal, step_name]
	_decision_cooldown = _rng.randf_range(4.5, 8.5)
	_decision_made_this_tick = true
	_last_trigger = "hard_reevaluation" if hard_reevaluation else "cooldown_expired"

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

func _select_goal(facts: Dictionary, hard_reevaluation: bool = false) -> Dictionary:
	var goals := _build_goap_goal_catalog(facts)
	if goals.is_empty():
		_last_goal_score = 0.0
		_last_challenger_score = 0.0
		_last_hysteresis_retained = false
		return {}

	var scored_goals: Array[Dictionary] = []
	for goal in goals:
		var raw_score := _score_goal(goal)
		var effective_score := raw_score
		if not hard_reevaluation and _goap_current_goal != "" and str(goal.get("name", "")) != _goap_current_goal:
			effective_score -= float(goal.get("switch_penalty", 0.0))

		var scored_goal: Dictionary = goal.duplicate(true)
		scored_goal["score"] = raw_score
		scored_goal["effective_score"] = effective_score
		scored_goals.append(scored_goal)

	_sort_scored_goals(scored_goals)

	var current_goal := _find_goal_by_name(scored_goals, _goap_current_goal)
	var challenger_goal := _best_alternative_goal(scored_goals, _goap_current_goal)

	if hard_reevaluation or current_goal.is_empty():
		var selected_goal: Dictionary = scored_goals[0]
		_last_goal_score = float(selected_goal.get("effective_score", 0.0))
		_last_challenger_score = float(challenger_goal.get("effective_score", 0.0))
		_last_hysteresis_retained = false
		return selected_goal

	var current_score := float(current_goal.get("effective_score", 0.0))
	var challenger_score := float(challenger_goal.get("effective_score", -INF))
	var hysteresis_margin := float(current_goal.get("hysteresis", 0.0))

	if challenger_goal.is_empty() or challenger_score <= current_score + hysteresis_margin:
		_last_goal_score = current_score
		_last_challenger_score = 0.0 if challenger_goal.is_empty() else challenger_score
		_last_hysteresis_retained = not challenger_goal.is_empty() and challenger_score > current_score
		return current_goal

	_last_goal_score = challenger_score
	_last_challenger_score = current_score
	_last_hysteresis_retained = false
	return challenger_goal

func _build_goap_goal_catalog(facts: Dictionary) -> Array[Dictionary]:
	var goals: Array[Dictionary] = []
	var in_work_window := bool(facts.get("in_work_window", false))
	var at_work := bool(facts.get("at_work", false))
	var at_home := bool(facts.get("at_home", false))
	var bell_pending := bool(facts.get("bell_pending", false))
	var player_nearby := bool(facts.get("player_nearby", false))
	var has_friendly_tie := bool(facts.get("has_friendly_tie", false))
	var recently_socialized := bool(facts.get("recently_socialized", false))

	if in_work_window:
		goals.append({
			"name": "maintain_role_routine",
			"desired": {"at_work": true},
			"base": 3.0,
			"urgency": 2.0 if not at_work else 1.0,
			"social": 0.0,
			"economic": 1.4,
			"cooldown": 0.0,
			"switch_penalty": 0.5,
			"hysteresis": 0.6,
		})
	else:
		goals.append({
			"name": "maintain_rest_routine",
			"desired": {"at_home": true},
			"base": 3.0,
			"urgency": 2.0 if not at_home else 1.0,
			"social": 0.0,
			"economic": 0.1,
			"cooldown": 0.0,
			"switch_penalty": 0.4,
			"hysteresis": 0.5,
		})

	goals.append({
		"name": "maintain_social_assimilation",
		"desired": {"recently_socialized": true},
		"base": 3.2,
		"urgency": 1.8 if not recently_socialized else 0.4,
		"social": 2.0 if has_friendly_tie and player_nearby else (1.2 if has_friendly_tie else (0.8 if player_nearby else 0.0)),
		"economic": 0.2 if not in_work_window else 0.0,
		"cooldown": 2.0 if recently_socialized else 0.0,
		"switch_penalty": 0.4,
		"hysteresis": 0.4,
	})

	goals.append({
		"name": "avoid_attention_spike",
		"desired": {"at_home": true} if bell_pending and player_nearby else {"at_social_hub": false},
		"base": 2.5,
		"urgency": 4.0 if bell_pending and player_nearby else (1.2 if bell_pending else 0.2),
		"social": 2.2 if bell_pending and player_nearby else (0.8 if player_nearby else 0.0),
		"economic": -0.5 if in_work_window else 0.0,
		"cooldown": 0.0,
		"switch_penalty": 0.2,
		"hysteresis": 0.2,
	})

	return goals

func _score_goal(goal: Dictionary) -> float:
	return float(goal.get("base", 0.0)) + float(goal.get("urgency", 0.0)) + float(goal.get("social", 0.0)) + float(goal.get("economic", 0.0)) - float(goal.get("cooldown", 0.0))

func _sort_scored_goals(goals: Array[Dictionary]) -> void:
	goals.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		var ea := float(a.get("effective_score", -INF))
		var eb := float(b.get("effective_score", -INF))
		if ea == eb:
			var sa := float(a.get("score", -INF))
			var sb := float(b.get("score", -INF))
			if sa == sb:
				return str(a.get("name", "")) < str(b.get("name", ""))
			return sa > sb
		return ea > eb
	)

func _find_goal_by_name(goals: Array[Dictionary], goal_name: String) -> Dictionary:
	for goal in goals:
		if str(goal.get("name", "")) == goal_name:
			return goal
	return {}

func _best_alternative_goal(goals: Array[Dictionary], goal_name: String) -> Dictionary:
	for goal in goals:
		if str(goal.get("name", "")) != goal_name:
			return goal
	return {}

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
				best_plan = _packed_steps_to_array(node_steps)
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

func _packed_steps_to_array(steps: PackedStringArray) -> Array[String]:
	var materialized: Array[String] = []
	for step in steps:
		materialized.append(step)
	return materialized

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

func _goal_to_runtime_action(goal_name: String) -> String:
	match goal_name:
		"maintain_role_routine":
			return ACTION_WORK
		"maintain_rest_routine", "avoid_attention_spike":
			return ACTION_HOME
		"maintain_social_assimilation":
			return ACTION_SOCIALIZE
		_:
			return ACTION_HOME

func _target_for_goal(
	goal_name: String,
	current_position: Vector2,
	home_position: Vector2,
	work_position: Vector2,
	social_hub: Vector2
) -> Vector2:
	match goal_name:
		"maintain_role_routine":
			return work_position
		"maintain_rest_routine", "avoid_attention_spike":
			return home_position
		"maintain_social_assimilation":
			return social_hub
		_:
			return current_position

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
