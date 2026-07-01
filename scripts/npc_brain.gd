class_name NpcBrain
extends RefCounted

const ACTION_HOME := "home"
const ACTION_WORK := "work"
const ACTION_SOCIALIZE := "socialize"
const ACTION_WANDER := "wander"

var _rng := RandomNumberGenerator.new()
var _decision_cooldown := 0.0
var _current_action := ACTION_HOME
var _current_target := Vector2.ZERO
var _current_reason := ""

func _init(seed_value: int = 0) -> void:
	if seed_value == 0:
		seed_value = int(Time.get_unix_time_from_system())
	_rng.seed = seed_value

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
	_decision_cooldown = maxf(_decision_cooldown - delta, 0.0)
	if _decision_cooldown <= 0.0:
		_reconsider_action(
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

	return {
		"action": _current_action,
		"target": _current_target,
		"reason": _current_reason,
	}

func _reconsider_action(
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
	var bell_pending_tolls: int = int(world_state.get("bell_pending_tolls", 0))
	var in_work_window := hour >= morning_depart_hour and hour < evening_return_hour
	var near_dusk_or_dawn := hour <= 8 or hour >= 17

	var scores := {
		ACTION_HOME: 0.0,
		ACTION_WORK: 0.0,
		ACTION_SOCIALIZE: 0.0,
		ACTION_WANDER: 0.0,
	}

	scores[ACTION_HOME] += 1.2 if not in_work_window else -0.6
	scores[ACTION_WORK] += 2.4 if in_work_window else -1.1
	scores[ACTION_SOCIALIZE] += 0.7 if near_dusk_or_dawn else 0.1
	scores[ACTION_WANDER] += 0.2

	if bell_pending_tolls > 0:
		scores[ACTION_HOME] += 0.8
		scores[ACTION_SOCIALIZE] -= 0.4

	if is_player_nearby:
		scores[ACTION_SOCIALIZE] += 0.4

	if has_friendly_tie:
		scores[ACTION_SOCIALIZE] += 0.3

	# Keep some inertia so NPCs do not switch actions every tick.
	scores[_current_action] += 1.1

	for action in scores.keys():
		scores[action] += _rng.randf_range(-0.2, 0.2)

	var best_action := ACTION_HOME
	var best_score := -INF
	for action in scores.keys():
		var candidate_score: float = scores[action]
		if candidate_score > best_score:
			best_score = candidate_score
			best_action = action

	_current_action = best_action
	_current_target = _target_for_action(best_action, current_position, home_position, work_position, social_hub)
	_current_reason = "h%02d score=%.2f" % [hour, best_score]
	_decision_cooldown = _rng.randf_range(4.0, 8.0)

func _target_for_action(
	action: String,
	current_position: Vector2,
	home_position: Vector2,
	work_position: Vector2,
	social_hub: Vector2
) -> Vector2:
	match action:
		ACTION_WORK:
			return work_position
		ACTION_SOCIALIZE:
			return social_hub
		ACTION_WANDER:
			return current_position + Vector2(_rng.randf_range(-64.0, 64.0), _rng.randf_range(-64.0, 64.0))
		_:
			return home_position
