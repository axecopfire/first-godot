extends Node

## Global texture cache for procedurally generated textures.
## Stores ImageTexture objects in memory for use throughout the game.

var tiles: ImageTexture
var player: ImageTexture
var market_stall: ImageTexture
var barrel: ImageTexture
var crate: ImageTexture
var well: ImageTexture
var fountain: ImageTexture

var npcs: Dictionary = {
	"merchant": null,
	"baker": null,
	"blacksmith": null,
	"herbalist": null,
}

## Cache for loaded/generated textures
var texture_cache: Dictionary = {}

func _ready() -> void:
	_generate_all()

## Load or get a cached texture. Priority: cache > generated > file > placeholder
func get_texture(path: String) -> Texture2D:
	# Check if already cached
	if texture_cache.has(path):
		return texture_cache[path]
	
	# Try to load from file
	if ResourceLoader.exists(path):
		var tex = load(path)
		if tex:
			texture_cache[path] = tex
			return tex
	
	# Try common procedurally generated textures by name
	var filename = path.get_file().trim_suffix(".png")
	if filename == "tiles":
		return tiles
	elif filename == "player":
		return player
	elif filename == "market_stall":
		return market_stall
	elif filename == "barrel":
		return barrel
	elif filename == "crate":
		return crate
	elif filename == "well":
		return well
	elif filename == "fountain":
		return fountain
	elif filename.begins_with("npc_"):
		var npc_name = filename.trim_prefix("npc_")
		if npcs.has(npc_name) and npcs[npc_name]:
			return npcs[npc_name]
	
	# Return a placeholder texture
	var placeholder = _create_placeholder_texture(16, 16)
	texture_cache[path] = placeholder
	return placeholder

## Create a simple placeholder texture
func _create_placeholder_texture(width: int, height: int) -> ImageTexture:
	var img = Image.create(width, height, false, Image.FORMAT_RGBA8)
	img.fill(Color(0.5, 0.5, 0.5, 0.8))
	# Draw a cross pattern
	for i in range(width):
		img.set_pixel(i, i, Color(1, 1, 1, 1))
		if i < height:
			img.set_pixel(i, height - 1 - i, Color(1, 1, 1, 1))
	return ImageTexture.create_from_image(img)

func _generate_all() -> void:
	_create_player()
	_create_npcs()
	_create_tiles()
	_create_stall()
	_create_barrel()
	_create_crate()
	_create_well()
	_create_fountain()
	print("All textures generated and cached in memory!")

func _create_player() -> void:
	var img = Image.create(64, 48, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	var skin = Color(0.87, 0.72, 0.53)
	var tunic = Color(0.2, 0.4, 0.15)
	var pants = Color(0.35, 0.25, 0.15)
	var hair = Color(0.4, 0.25, 0.1)
	var boots = Color(0.25, 0.15, 0.08)

	for frame in range(4):
		var ox = frame * 16
		# Down row
		_draw_head(img, ox, 0, hair, skin)
		img.set_pixel(ox + 6, 5, Color.BLACK)
		img.set_pixel(ox + 9, 5, Color.BLACK)
		_draw_tunic(img, ox, 0, tunic)
		var aoff = 1 if (frame % 2 == 0) else 0
		img.set_pixel(ox + 3, 7 + aoff, skin)
		img.set_pixel(ox + 12, 8 - aoff, skin)
		_draw_legs(img, ox, 0, pants, boots, frame)

		# Up row
		for x in range(5, 11):
			for y in range(1, 7):
				img.set_pixel(ox + x, 16 + y, hair)
		_draw_tunic(img, ox, 16, tunic)
		img.set_pixel(ox + 3, 16 + 7 + aoff, skin)
		img.set_pixel(ox + 12, 16 + 8 - aoff, skin)
		_draw_legs(img, ox, 16, pants, boots, frame)

		# Right row
		_draw_head(img, ox, 32, hair, skin)
		img.set_pixel(ox + 10, 32 + 5, Color.BLACK)
		for x in range(5, 12):
			for y in range(7, 11):
				img.set_pixel(ox + x, 32 + y, tunic)
		img.set_pixel(ox + 11, 32 + 8 + aoff, skin)
		_draw_legs(img, ox, 32, pants, boots, frame)

	player = ImageTexture.create_from_image(img)

func _draw_head(img: Image, ox: int, oy: int, hair: Color, skin: Color) -> void:
	for x in range(5, 11):
		for y in range(1, 4):
			img.set_pixel(ox + x, oy + y, hair)
	for x in range(5, 11):
		for y in range(4, 7):
			img.set_pixel(ox + x, oy + y, skin)

func _draw_tunic(img: Image, ox: int, oy: int, tunic: Color) -> void:
	for x in range(4, 12):
		for y in range(7, 11):
			img.set_pixel(ox + x, oy + y, tunic)

func _draw_legs(img: Image, ox: int, oy: int, pants: Color, boots: Color, frame: int) -> void:
	for x in range(5, 11):
		for y in range(11, 13):
			img.set_pixel(ox + x, oy + y, pants)
	var boff = 1 if (frame == 1 or frame == 3) else 0
	for x in range(5, 8):
		if oy + 13 + boff < 48:
			img.set_pixel(ox + x, oy + 13 + boff, boots)
	for x in range(8, 11):
		img.set_pixel(ox + x, oy + 13 - boff, boots)

func _create_npcs() -> void:
	var configs = [
		{"name": "merchant", "tunic": Color(0.6, 0.15, 0.15), "hair": Color(0.2, 0.15, 0.1)},
		{"name": "baker", "tunic": Color(0.85, 0.8, 0.7), "hair": Color(0.7, 0.5, 0.1)},
		{"name": "blacksmith", "tunic": Color(0.3, 0.3, 0.35), "hair": Color(0.15, 0.1, 0.08)},
		{"name": "herbalist", "tunic": Color(0.3, 0.55, 0.3), "hair": Color(0.6, 0.3, 0.1)},
	]
	for cfg in configs:
		var img = Image.create(16, 16, false, Image.FORMAT_RGBA8)
		img.fill(Color(0, 0, 0, 0))
		var skin = Color(0.87, 0.72, 0.53)
		for x in range(5, 11):
			for y in range(1, 4):
				img.set_pixel(x, y, cfg["hair"])
		for x in range(5, 11):
			for y in range(4, 7):
				img.set_pixel(x, y, skin)
		img.set_pixel(6, 5, Color.BLACK)
		img.set_pixel(9, 5, Color.BLACK)
		for x in range(4, 12):
			for y in range(7, 11):
				img.set_pixel(x, y, cfg["tunic"])
		for x in range(5, 11):
			for y in range(11, 13):
				img.set_pixel(x, y, Color(0.35, 0.25, 0.15))
		for x in range(5, 11):
			img.set_pixel(x, 13, Color(0.25, 0.15, 0.08))
		npcs[cfg["name"]] = ImageTexture.create_from_image(img)

func _create_tiles() -> void:
	var img = Image.create(96, 16, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))

	# Grass
	for x in range(0, 16):
		for y in range(0, 16):
			img.set_pixel(x, y, Color(0.15, randf_range(0.35, 0.45), 0.1))
	# Dirt
	for x in range(16, 32):
		for y in range(0, 16):
			var v = randf_range(0.38, 0.45)
			img.set_pixel(x, y, Color(v + 0.1, v, v - 0.1))
	# Cobblestone
	for x in range(32, 48):
		for y in range(0, 16):
			img.set_pixel(x, y, Color(0.5, 0.48, 0.46))
	for x in range(32, 48):
		img.set_pixel(x, 0, Color(0.3, 0.3, 0.3))
		img.set_pixel(x, 8, Color(0.3, 0.3, 0.3))
	for y in range(0, 16):
		img.set_pixel(32, y, Color(0.3, 0.3, 0.3))
		img.set_pixel(40, y, Color(0.3, 0.3, 0.3))
	# Wood
	for x in range(48, 64):
		for y in range(0, 16):
			img.set_pixel(x, y, Color(0.55, 0.4, 0.2))
	for x in range(48, 64):
		for yl in [3, 7, 11]:
			img.set_pixel(x, yl, Color(0.4, 0.3, 0.15))
	# Stone wall
	for x in range(64, 80):
		for y in range(0, 16):
			img.set_pixel(x, y, Color(0.4, 0.4, 0.42))
	for x in range(64, 80):
		for yl in [4, 8, 12]:
			img.set_pixel(x, yl, Color(0.55, 0.5, 0.45))
	# Water (acequia)
	for x in range(80, 96):
		for y in range(0, 16):
			var b = randf_range(0.55, 0.7)
			img.set_pixel(x, y, Color(0.2, 0.4, b))
	for x in range(80, 96):
		for yl in [3, 9, 13]:
			img.set_pixel(x, yl, Color(0.45, 0.65, 0.85))

	tiles = ImageTexture.create_from_image(img)

func _create_stall() -> void:
	var img = Image.create(48, 32, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	var cloth1 = Color(0.7, 0.15, 0.1)
	var cloth2 = Color(0.8, 0.75, 0.6)
	var wood = Color(0.5, 0.35, 0.15)
	var wood_d = Color(0.35, 0.22, 0.1)

	for x in range(0, 48):
		for y in range(0, 10):
			img.set_pixel(x, y, cloth1 if (x / 6) % 2 == 0 else cloth2)
	for x in range(0, 48):
		img.set_pixel(x, 10, Color(0.3, 0.2, 0.1, 0.5))
	for x in range(2, 46):
		for y in range(11, 18):
			img.set_pixel(x, y, wood)
	for x in range(2, 46):
		img.set_pixel(x, 11, Color(0.6, 0.45, 0.2))
	for y in range(18, 30):
		for px in [4, 5, 22, 23, 42, 43]:
			img.set_pixel(px, y, wood_d)
	var wares = [Color(0.8, 0.2, 0.1), Color(0.2, 0.6, 0.2), Color(0.8, 0.7, 0.1), Color(0.5, 0.2, 0.6)]
	for i in range(4):
		var wx = 8 + i * 9
		for x in range(wx, wx + 5):
			for y in range(8, 11):
				img.set_pixel(x, y, wares[i])
	market_stall = ImageTexture.create_from_image(img)

func _create_barrel() -> void:
	var img = Image.create(12, 14, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	for x in range(2, 10):
		for y in range(1, 13):
			img.set_pixel(x, y, Color(0.45, 0.3, 0.12))
	for x in range(1, 11):
		img.set_pixel(x, 3, Color(0.35, 0.35, 0.4))
		img.set_pixel(x, 10, Color(0.35, 0.35, 0.4))
	barrel = ImageTexture.create_from_image(img)

func _create_crate() -> void:
	var img = Image.create(14, 14, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	var cw = Color(0.55, 0.4, 0.18)
	var ce = Color(0.4, 0.28, 0.1)
	for x in range(1, 13):
		for y in range(1, 13):
			img.set_pixel(x, y, cw)
	for i in range(14):
		img.set_pixel(i, 0, ce)
		img.set_pixel(i, 13, ce)
		img.set_pixel(0, i, ce)
		img.set_pixel(13, i, ce)
	for i in range(1, 13):
		img.set_pixel(i, 7, ce)
		img.set_pixel(7, i, ce)
	crate = ImageTexture.create_from_image(img)

func _create_well() -> void:
	var img = Image.create(24, 24, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	for x in range(4, 20):
		for y in range(6, 22):
			var cx = x - 12
			var cy = y - 14
			var d = cx * cx + cy * cy
			if d <= 64:
				img.set_pixel(x, y, Color(0.5, 0.48, 0.45))
			if d <= 36 and d > 20:
				img.set_pixel(x, y, Color(0.35, 0.33, 0.3))
			if d <= 20:
				img.set_pixel(x, y, Color(0.15, 0.25, 0.5))
	for y in range(0, 14):
		img.set_pixel(6, y, Color(0.4, 0.25, 0.1))
		img.set_pixel(17, y, Color(0.4, 0.25, 0.1))
	for x in range(4, 20):
		img.set_pixel(x, 0, Color(0.5, 0.3, 0.1))
		img.set_pixel(x, 1, Color(0.45, 0.28, 0.1))
	well = ImageTexture.create_from_image(img)

func _create_fountain() -> void:
	var img = Image.create(32, 32, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	for x in range(32):
		for y in range(32):
			var cx = x - 16
			var cy = y - 16
			var d = cx * cx + cy * cy
			if d <= 225 and d > 144:
				img.set_pixel(x, y, Color(0.55, 0.52, 0.48))
			elif d <= 144:
				img.set_pixel(x, y, Color(0.2, 0.35, 0.6))
	for x in range(14, 18):
		for y in range(8, 20):
			img.set_pixel(x, y, Color(0.55, 0.52, 0.48))
	for x in range(12, 20):
		img.set_pixel(x, 8, Color(0.55, 0.52, 0.48))
		img.set_pixel(x, 9, Color(0.55, 0.52, 0.48))
	fountain = ImageTexture.create_from_image(img)
