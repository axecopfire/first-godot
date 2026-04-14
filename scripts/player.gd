extends CharacterBody2D

const SPEED = 200.0

var sprite: Sprite2D
var last_direction := Vector2.DOWN
var anim_timer := 0.0
var anim_frame := 0
var player_texture: Texture2D

func _ready() -> void:
	sprite = $Sprite2D
	add_to_group("player")
	_load_player_texture()

func _load_player_texture() -> void:
	if FileAccess.file_exists("res://textures/player.png"):
		var img = Image.load_from_file("res://textures/player.png")
		player_texture = ImageTexture.create_from_image(img)
		_update_sprite_frame()

func _physics_process(delta: float) -> void:
	var direction := Vector2.ZERO
	direction.x = Input.get_axis("move_left", "move_right")
	direction.y = Input.get_axis("move_up", "move_down")

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
