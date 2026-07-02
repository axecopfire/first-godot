extends CharacterBody2D

@export var wander_speed := 40.0
@export var entity_name := "Villager"
@export var npc_display_name := "Villager"
@export var npc_profession := "Villager"
@export var dialogue_lines: PackedStringArray = ["Welcome to the market!", "Fine goods for sale!"]
@export var night_return_speed_multiplier := 1.25
@export var morning_depart_hour := 7
@export var evening_return_hour := 18
@export var work_position := Vector2.ZERO

var home_position := Vector2.ZERO
var has_home_position := false
var has_work_position := false
var daily_schedule: Array[Vector2] = []
var brain: NpcBrain

var sprite: Sprite2D
var label: Label
var name_label: Label
var interaction_area: Area2D

var item_reactions: Dictionary = {}
var greeting_items: String = ""
var greeting_all: String = ""
var npc_closing: String = ""
var combo_reactions: Array = []  # Array of {"items": [...], "line": "..."}
var nearby_player: Node2D = null
var active_dialogue: PackedStringArray = []

var start_position := Vector2.ZERO
var is_player_nearby := false
var showing_dialogue := false
var current_line := 0
var _cycle_progress := 0.0
var _world_state: Dictionary = {}
var _last_action := ""
var _last_action_reason := ""
var _last_goal := ""
var _last_plan_step := ""

func _ready() -> void:
	start_position = global_position
	if not has_home_position:
		home_position = start_position
		has_home_position = true
	if work_position != Vector2.ZERO:
		has_work_position = true

	sprite = get_node_or_null("Sprite2D")
	label = get_node_or_null("Label")
	name_label = get_node_or_null("NameLabel")
	interaction_area = get_node_or_null("InteractionArea")

	if label:
		label.visible = false

	if name_label:
		if npc_display_name.strip_edges() == "":
			npc_display_name = entity_name
		if npc_profession.strip_edges() == "":
			npc_profession = "Villager"
		name_label.text = "%s (%s)" % [npc_display_name, npc_profession]

	if interaction_area:
		interaction_area.body_entered.connect(_on_interaction_area_body_entered)
		interaction_area.body_exited.connect(_on_interaction_area_body_exited)

	_generate_daily_schedule()
	if daily_schedule.size() > 0:
		_current_scheduled_position = daily_schedule[0]

	brain = NpcBrain.new(abs(hash(entity_name)))

func _physics_process(delta: float) -> void:
	if showing_dialogue:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	# Move towards the scheduled position for the current hour
	if brain != null:
		var decision := brain.tick(
			delta,
			_cycle_progress,
			global_position,
			home_position,
			_get_work_location(),
			morning_depart_hour,
			evening_return_hour,
			_world_state,
			is_player_nearby,
			_has_friendly_tie()
		)
		_current_scheduled_position = decision.get("target", _current_scheduled_position)
		_last_action = str(decision.get("action", ""))
		_last_action_reason = str(decision.get("reason", ""))
		_last_goal = str(decision.get("goal", ""))
		_last_plan_step = str(decision.get("plan_step", ""))

		if decision.get("new_decision", false):
			NpcTelemetry.log_decision({
				"npc_id": entity_name,
				"profession": npc_profession,
				"day": int(_world_state.get("day", 1)),
				"hour": int(_cycle_progress * 24.0) % 24,
				"active_goal": _last_goal,
				"routine": _last_action,
				"trigger": str(decision.get("trigger", "cooldown_expired")),
				"rationale": _last_action_reason,
			})

	var scheduled_position = _get_scheduled_position()
	var dir = (scheduled_position - global_position)

	if dir.length() < 5.0:
		velocity = Vector2.ZERO
	else:
		velocity = dir.normalized() * wander_speed
		if sprite:
			sprite.flip_h = velocity.x < 0

	move_and_slide()

func set_home_position(pos: Vector2) -> void:
	home_position = pos
	has_home_position = true
	_generate_daily_schedule()

func set_schedule(morning_hour: int, evening_hour: int) -> void:
	morning_depart_hour = clampi(morning_hour, 0, 23)
	evening_return_hour = clampi(evening_hour, 0, 23)
	_generate_daily_schedule()

func set_work_position(pos: Vector2) -> void:
	work_position = pos
	has_work_position = true
	_generate_daily_schedule()

func _generate_daily_schedule() -> void:
	daily_schedule.clear()
	var work_location := _get_work_location()
	
	for hour in range(24):
		if hour >= morning_depart_hour and hour < evening_return_hour:
			# Day hours: go to work location
			daily_schedule.append(work_location)
		else:
			# Night hours: at home
			daily_schedule.append(home_position)

func _get_work_location() -> Vector2:
	if has_work_position:
		return work_position
	return start_position

func _get_scheduled_position() -> Vector2:
	return _current_scheduled_position

var _current_scheduled_position := Vector2.ZERO

func set_day_cycle_progress(cycle_progress: float, snap_to_schedule := false, world_state: Dictionary = {}) -> void:
	_cycle_progress = cycle_progress
	_world_state = world_state

	if brain == null:
		var hour: int = int(cycle_progress * 24.0) % 24
		if hour < daily_schedule.size():
			_current_scheduled_position = daily_schedule[hour]
		else:
			_current_scheduled_position = start_position

	if snap_to_schedule:
		global_position = _current_scheduled_position
		velocity = Vector2.ZERO

func get_schedule_debug_status(hour: int) -> String:
	var work_location := _get_work_location()
	var in_work_window := hour >= morning_depart_hour and hour < evening_return_hour
	var planned_state := "WORK" if in_work_window else "HOME"

	var target_state := "HOME"
	if _current_scheduled_position.distance_to(work_location) < 1.0:
		target_state = "WORK"
	elif _current_scheduled_position.distance_to(home_position) >= 1.0:
		target_state = "TRANSIT"

	var same_work_and_home := work_location.distance_to(home_position) < 1.0
	var display_hour := clampi(hour, 0, 23)
	var merged_flag := " [work=home]" if same_work_and_home else ""
	var action_fragment := ""
	if _last_action != "":
		action_fragment = " action=%s" % [_last_action]
	if _last_action_reason != "":
		action_fragment += " %s" % [_last_action_reason]
	if _last_goal != "":
		action_fragment += " goal=%s" % [_last_goal]
	if _last_plan_step != "":
		action_fragment += " step=%s" % [_last_plan_step]
	return "%02d %s (%s): plan=%s target=%s [m%02d-e%02d]%s%s" % [display_hour, npc_display_name, npc_profession, planned_state, target_state, morning_depart_hour, evening_return_hour, merged_flag, action_fragment]

func _has_friendly_tie() -> bool:
	if not has_meta("relationship_profile"):
		return false
	var profile = get_meta("relationship_profile")
	if typeof(profile) != TYPE_DICTIONARY:
		return false
	var friendly: Dictionary = profile.get("friendly", {})
	return friendly.has("npc")

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and is_player_nearby:
		if not showing_dialogue:
			showing_dialogue = true
			active_dialogue = _build_dialogue()
			current_line = 0
			_show_line()
		else:
			current_line += 1
			if current_line >= active_dialogue.size():
				_hide_dialogue()
			else:
				_show_line()
		get_viewport().set_input_as_handled()

func _build_dialogue() -> PackedStringArray:
	if nearby_player == null or not nearby_player.has_method("get_inventory"):
		return dialogue_lines

	var inv: Array = nearby_player.get_inventory()
	if inv.is_empty():
		return dialogue_lines

	var lines: Array[String] = []

	# Choose greeting based on item count
	if inv.size() >= 4 and greeting_all != "":
		lines.append(greeting_all)
	elif greeting_items != "":
		lines.append(greeting_items)

	# Add per-item reactions in sorted order for determinism
	var sorted_inv = inv.duplicate()
	sorted_inv.sort()
	for item_name in sorted_inv:
		if item_name in item_reactions:
			lines.append(item_reactions[item_name])

	# Add combo reactions — special lines when specific item groups are all present
	for combo in combo_reactions:
		var all_present := true
		for required_item in combo["items"]:
			if required_item not in inv:
				all_present = false
				break
		if all_present:
			lines.append(combo["line"])

	# Add closing
	if npc_closing != "":
		lines.append(npc_closing)

	# Add relationship-aware lines when a profile is present.
	_append_relationship_lines(lines)

	if lines.is_empty():
		return dialogue_lines

	return PackedStringArray(lines)

func _append_relationship_lines(lines: Array[String]) -> void:
	if not has_meta("relationship_profile"):
		return

	var profile = get_meta("relationship_profile")
	if typeof(profile) != TYPE_DICTIONARY:
		return

	var familial: Dictionary = profile.get("familial", {})
	var friendly: Dictionary = profile.get("friendly", {})
	var backstory := str(profile.get("backstory", ""))
	var dwelling_label := ""
	if has_meta("dwelling_profile"):
		var dwelling = get_meta("dwelling_profile")
		if typeof(dwelling) == TYPE_DICTIONARY:
			dwelling_label = str(dwelling.get("label", ""))

	if dwelling_label != "":
		lines.append("Home: %s." % [dwelling_label])

	if familial.has("npc"):
		lines.append("Family: %s is my %s." % [familial["npc"], str(familial.get("subkind", "kin"))])
	if friendly.has("npc"):
		lines.append("Friend: I trust %s." % [friendly["npc"]])
	if backstory != "":
		lines.append("Story: %s" % [backstory])

func _show_line() -> void:
	if label and current_line < active_dialogue.size():
		label.text = active_dialogue[current_line]
		label.visible = true

func _hide_dialogue() -> void:
	showing_dialogue = false
	if label:
		label.visible = false

func _on_interaction_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		is_player_nearby = true
		nearby_player = body

func _on_interaction_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		is_player_nearby = false
		nearby_player = null
		_hide_dialogue()
