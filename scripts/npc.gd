extends CharacterBody2D

@export var wander_speed := 40.0
@export var wander_range := 80.0
@export var npc_name := "Villager"
@export var dialogue_lines: PackedStringArray = ["Welcome to the market!", "Fine goods for sale!"]

var sprite: Sprite2D
var label: Label
var interaction_area: Area2D

var item_reactions: Dictionary = {}
var greeting_items: String = ""
var greeting_all: String = ""
var npc_closing: String = ""
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
	_pick_new_wander_target()

	sprite = get_node_or_null("Sprite2D")
	label = get_node_or_null("Label")
	interaction_area = get_node_or_null("InteractionArea")

	if label:
		label.visible = false

	if interaction_area:
		interaction_area.body_entered.connect(_on_interaction_area_body_entered)
		interaction_area.body_exited.connect(_on_interaction_area_body_exited)

func _physics_process(delta: float) -> void:
	if showing_dialogue:
		velocity = Vector2.ZERO
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

	# Add closing
	if npc_closing != "":
		lines.append(npc_closing)

	if lines.is_empty():
		return dialogue_lines

	return PackedStringArray(lines)

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
