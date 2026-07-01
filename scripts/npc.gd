extends CharacterBody2D

@export var wander_speed := 40.0
@export var wander_range := 80.0
@export var entity_name := "Villager"
@export var npc_display_name := "Villager"
@export var npc_profession := "Villager"
@export var dialogue_lines: PackedStringArray = ["Welcome to the market!", "Fine goods for sale!"]
@export var night_return_speed_multiplier := 1.25
@export var night_hours_start := 21
@export var night_hours_end := 6

var home_position := Vector2.ZERO
var has_home_position := false
var is_night_schedule_active := false

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
var wander_target := Vector2.ZERO
var wander_timer := 0.0
var is_player_nearby := false
var showing_dialogue := false
var current_line := 0

func _ready() -> void:
	start_position = global_position
	home_position = start_position
	_pick_new_wander_target()

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

func _physics_process(delta: float) -> void:
	if showing_dialogue:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	if is_night_schedule_active and has_home_position:
		var home_dir := home_position - global_position
		if home_dir.length() < 5.0:
			velocity = Vector2.ZERO
		else:
			velocity = home_dir.normalized() * wander_speed * night_return_speed_multiplier
			if sprite:
				sprite.flip_h = velocity.x < 0

		move_and_slide()
		return

	wander_timer -= delta
	if wander_timer <= 0:
		_pick_new_wander_target()

	var dir = (wander_target - global_position)
	if dir.length() < 5:
		velocity = Vector2.ZERO
		_pick_new_wander_target()
	else:
		velocity = dir.normalized() * wander_speed
		if sprite:
			sprite.flip_h = velocity.x < 0

	move_and_slide()

func set_home_position(pos: Vector2) -> void:
	home_position = pos
	has_home_position = true

func set_day_cycle_progress(cycle_progress: float) -> void:
	var hour: int = int(cycle_progress * 24.0) % 24
	var should_be_night := hour >= night_hours_start or hour < night_hours_end
	if should_be_night == is_night_schedule_active:
		return

	is_night_schedule_active = should_be_night
	if not is_night_schedule_active:
		# Reset wander timing so NPCs immediately resume daytime roaming.
		wander_timer = 0.0
		_pick_new_wander_target()

func _pick_new_wander_target() -> void:
	wander_target = start_position + Vector2(
		randf_range(-wander_range, wander_range),
		randf_range(-wander_range, wander_range)
	)
	wander_timer = randf_range(2.0, 5.0)

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
