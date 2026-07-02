class_name WorldStateManager
extends Node

## Owns all world-time and bell state so the main orchestrator reads a single
## source of truth.  Main delegates `tick()` each frame; everything else is
## read-only from the outside.

const DAY_DURATION_SECONDS := 300.0

const _BELL_SCHEDULE: Dictionary = ScheduleConfig.BELL_SCHEDULE
const _TOLL_INTERVAL := 1.1  # seconds between strikes

var day_number: int = 1
var day_timer: float = 0.0

var _last_bell_hour: int = -1
var _pending_tolls: int = 0
var _toll_cooldown: float = 0.0
var _bell_player: AudioStreamPlayer

# ---------------------------------------------------------------------------
# Derived read-only helpers
# ---------------------------------------------------------------------------

func get_cycle_progress() -> float:
	return day_timer / DAY_DURATION_SECONDS

func get_current_hour() -> int:
	return int(get_cycle_progress() * 24.0) % 24

func get_pending_tolls() -> int:
	return _pending_tolls

func format_clock_time() -> String:
	var cycle_progress := get_cycle_progress()
	var total_minutes: int = int(floor(cycle_progress * 24.0 * 60.0))
	var hours: int = int(total_minutes / 60) % 24
	var minutes: int = total_minutes % 60
	return "%02d:%02d" % [hours, minutes]

## Returns the canonical world-state dict consumed by NPC brains.
func get_world_state(social_hub_position: Vector2) -> Dictionary:
	return {
		"hour": get_current_hour(),
		"day": day_number,
		"bell_pending_tolls": _pending_tolls,
		"social_hub_position": social_hub_position,
	}

# ---------------------------------------------------------------------------
# Mutation
# ---------------------------------------------------------------------------

## Advance time by `delta` seconds and process bell strikes.  Call once per
## `_process` frame from the main scene.
func tick(delta: float) -> void:
	day_timer += delta
	while day_timer >= DAY_DURATION_SECONDS:
		day_timer -= DAY_DURATION_SECONDS
		day_number += 1

	_tick_bell(delta)

## Jump the clock to the start of `hour` (0-23).
func set_time_to_hour(hour: int) -> void:
	day_timer = (float(hour) / 24.0) * DAY_DURATION_SECONDS

## Attach the bell AudioStreamPlayer as a child and configure it.
func setup_bell_audio() -> void:
	_bell_player = AudioStreamPlayer.new()
	_bell_player.name = "BellPlayer"
	_bell_player.bus = "Master"
	_bell_player.volume_db = 0.0
	var stream := load("res://audio/bell_toll.wav") as AudioStream
	if stream == null:
		push_warning("bell_toll.wav not found — bell audio disabled")
		return
	_bell_player.stream = stream
	add_child(_bell_player)

# ---------------------------------------------------------------------------
# Internal
# ---------------------------------------------------------------------------

func _tick_bell(delta: float) -> void:
	var current_hour := get_current_hour()
	if current_hour != _last_bell_hour:
		_last_bell_hour = current_hour
		if _BELL_SCHEDULE.has(current_hour):
			_pending_tolls += _BELL_SCHEDULE[current_hour]
			_toll_cooldown = 0.0

	if _pending_tolls > 0:
		_toll_cooldown -= delta
		if _toll_cooldown <= 0.0:
			if _bell_player != null:
				_bell_player.play()
			_pending_tolls -= 1
			_toll_cooldown = _TOLL_INTERVAL
