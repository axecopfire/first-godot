extends CharacterBody2D

signal inventory_changed

const SPEED = 100.0

var inventory: Array[String] = []
var sprite: Sprite2D
var last_direction := Vector2.DOWN
var anim_timer := 0.0
var anim_frame := 0
var player_texture: Texture2D

func _ready() -> void:
	sprite = $Sprite2D
	add_to_group("player")
	_ensure_movement_bindings()
	_load_player_texture()

func _ensure_movement_bindings() -> void:
	_ensure_action_binding("move_left", [KEY_A, KEY_LEFT])
	_ensure_action_binding("move_right", [KEY_D, KEY_RIGHT])
	_ensure_action_binding("move_up", [KEY_W, KEY_UP])
	_ensure_action_binding("move_down", [KEY_S, KEY_DOWN])

func _ensure_action_binding(action: StringName, keys: Array[Key]) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)

	var existing_events := InputMap.action_get_events(action)
	for key in keys:
		var has_logical := false
		var has_physical := false
		for event in existing_events:
			if not (event is InputEventKey):
				continue
			var key_event := event as InputEventKey
			if key_event.keycode == key:
				has_logical = true
			if key_event.physical_keycode == key:
				has_physical = true

		if not has_logical:
			var logical_event := InputEventKey.new()
			logical_event.keycode = key
			InputMap.action_add_event(action, logical_event)
			existing_events.append(logical_event)

		if not has_physical:
			var physical_event := InputEventKey.new()
			physical_event.physical_keycode = key
			InputMap.action_add_event(action, physical_event)
			existing_events.append(physical_event)

func _load_player_texture() -> void:
	player_texture = TextureCache.player
	if player_texture:
		_update_sprite_frame()

func _physics_process(delta: float) -> void:
	var direction := _get_move_direction()

	if direction.length() > 0:
		direction = direction.normalized()
		last_direction = direction
		velocity = direction * SPEED

		# Animate walking
		anim_timer += delta
		if anim_timer > 0.15:
			anim_timer = 0.0
			anim_frame = (anim_frame + 1) % 4
			_update_sprite_frame()
	else:
		velocity = Vector2.ZERO
		if anim_frame != 0:
			anim_frame = 0
			_update_sprite_frame()

	move_and_slide()

func _get_move_direction() -> Vector2:
	# Prefer InputMap actions, but fall back to direct key polling for web exports
	# where serialized InputEventKey mappings can be inconsistent across browsers.
	var x := Input.get_axis("move_left", "move_right")
	var y := Input.get_axis("move_up", "move_down")

	if is_zero_approx(x):
		x = _get_fallback_axis(KEY_A, KEY_D, KEY_LEFT, KEY_RIGHT)
	if is_zero_approx(y):
		y = _get_fallback_axis(KEY_W, KEY_S, KEY_UP, KEY_DOWN)

	return Vector2(x, y)

func _get_fallback_axis(neg_key: Key, pos_key: Key, neg_arrow: Key, pos_arrow: Key) -> float:
	var negative := _is_key_down(neg_key) or _is_key_down(neg_arrow)
	var positive := _is_key_down(pos_key) or _is_key_down(pos_arrow)

	if negative == positive:
		return 0.0
	return -1.0 if negative else 1.0

func _is_key_down(keycode: Key) -> bool:
	# Check both logical and physical keys so non-US layouts and web keyboard events
	# still resolve movement controls correctly.
	return Input.is_key_pressed(keycode) or Input.is_physical_key_pressed(keycode)

func _update_sprite_frame() -> void:
	if player_texture == null or sprite == null:
		return

	# Determine row: 0=down, 1=up, 2=right
	var row := 0
	if abs(last_direction.x) > abs(last_direction.y):
		row = 2
		sprite.flip_h = last_direction.x < 0
	else:
		if last_direction.y < 0:
			row = 1
		else:
			row = 0
		sprite.flip_h = false

	var atlas = AtlasTexture.new()
	atlas.atlas = player_texture
	atlas.region = Rect2(anim_frame * 16, row * 16, 16, 16)
	sprite.texture = atlas

func add_item(item_name: String) -> void:
	inventory.append(item_name)
	inventory_changed.emit()

func remove_item(item_name: String) -> bool:
	var idx = inventory.find(item_name)
	if idx >= 0:
		inventory.remove_at(idx)
		inventory_changed.emit()
		return true
	return false

func has_item(item_name: String) -> bool:
	return item_name in inventory

func get_inventory() -> Array[String]:
	return inventory
