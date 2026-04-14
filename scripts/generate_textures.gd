@tool
extends EditorScript

## Run this script from the Godot Editor: Script > Run (Ctrl+Shift+X)
## It generates all the pixel-art textures needed for the medieval market game.

func _run() -> void:
	_create_player_sprites()
	_create_npc_sprites()
	_create_tile_textures()
	_create_stall_texture()
	_create_object_textures()
	print("All textures generated!")

func _create_player_sprites() -> void:
	# Player sprite sheet: 4 frames x 3 directions (down, up, right) at 16x16 each
	var img = Image.create(64, 48, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))

	# Colors
	var skin = Color(0.87, 0.72, 0.53)
	var tunic = Color(0.2, 0.4, 0.15)  # green tunic
	var pants = Color(0.35, 0.25, 0.15)
	var hair = Color(0.4, 0.25, 0.1)
	var boots = Color(0.25, 0.15, 0.08)

	# --- Walk Down (row 0) ---
	for frame in range(4):
		var ox = frame * 16
		var oy = 0
		# Hair
		for x in range(5, 11):
			for y in range(1, 4):
				img.set_pixel(ox + x, oy + y, hair)
		# Face
		for x in range(5, 11):
			for y in range(4, 7):
				img.set_pixel(ox + x, oy + y, skin)
		# Eyes
		img.set_pixel(ox + 6, oy + 5, Color.BLACK)
		img.set_pixel(ox + 9, oy + 5, Color.BLACK)
		# Tunic
		for x in range(4, 12):
			for y in range(7, 11):
				img.set_pixel(ox + x, oy + y, tunic)
		# Arms (animate)
		var arm_off = 1 if (frame % 2 == 0) else 0
		img.set_pixel(ox + 3, oy + 7 + arm_off, skin)
		img.set_pixel(ox + 12, oy + 8 - arm_off, skin)
		# Pants
		for x in range(5, 11):
			for y in range(11, 13):
				img.set_pixel(ox + x, oy + y, pants)
		# Boots
		var boot_off = 1 if (frame == 1 or frame == 3) else 0
		for x in range(5, 8):
			img.set_pixel(ox + x, oy + 13 + boot_off, boots)
		for x in range(8, 11):
			img.set_pixel(ox + x, oy + 13 - boot_off, boots)

	# --- Walk Up (row 1) ---
	for frame in range(4):
		var ox = frame * 16
		var oy = 16
		# Hair (covers whole head from back)
		for x in range(5, 11):
			for y in range(1, 7):
				img.set_pixel(ox + x, oy + y, hair)
		# Tunic
		for x in range(4, 12):
			for y in range(7, 11):
				img.set_pixel(ox + x, oy + y, tunic)
		var arm_off = 1 if (frame % 2 == 0) else 0
		img.set_pixel(ox + 3, oy + 7 + arm_off, skin)
		img.set_pixel(ox + 12, oy + 8 - arm_off, skin)
		# Pants
		for x in range(5, 11):
			for y in range(11, 13):
				img.set_pixel(ox + x, oy + y, pants)
		var boot_off = 1 if (frame == 1 or frame == 3) else 0
		for x in range(5, 8):
			img.set_pixel(ox + x, oy + 13 + boot_off, boots)
		for x in range(8, 11):
			img.set_pixel(ox + x, oy + 13 - boot_off, boots)

	# --- Walk Right (row 2) ---
	for frame in range(4):
		var ox = frame * 16
		var oy = 32
		# Hair
		for x in range(5, 11):
			for y in range(1, 4):
				img.set_pixel(ox + x, oy + y, hair)
		# Face (profile)
		for x in range(7, 12):
			for y in range(4, 7):
				img.set_pixel(ox + x, oy + y, skin)
		# Eye
		img.set_pixel(ox + 10, oy + 5, Color.BLACK)
		# Tunic
		for x in range(5, 12):
			for y in range(7, 11):
				img.set_pixel(ox + x, oy + y, tunic)
		var arm_off = 1 if (frame % 2 == 0) else 0
		img.set_pixel(ox + 11, oy + 8 + arm_off, skin)
		# Pants
		for x in range(6, 11):
			for y in range(11, 13):
				img.set_pixel(ox + x, oy + y, pants)
		var boot_off = 1 if (frame == 1 or frame == 3) else 0
		for x in range(6, 9):
			img.set_pixel(ox + x, oy + 13 + boot_off, boots)
		for x in range(9, 11):
			img.set_pixel(ox + x, oy + 13 - boot_off, boots)

	img.save_png("res://textures/player.png")
	print("Player sprite saved.")

func _create_npc_sprites() -> void:
	# Simple NPC sprite - 16x16 single frame for now
	var colors_list = [
		{"name": "merchant", "tunic": Color(0.6, 0.15, 0.15), "hair": Color(0.2, 0.15, 0.1)},
		{"name": "baker", "tunic": Color(0.85, 0.8, 0.7), "hair": Color(0.7, 0.5, 0.1)},
		{"name": "blacksmith", "tunic": Color(0.3, 0.3, 0.35), "hair": Color(0.15, 0.1, 0.08)},
		{"name": "herbalist", "tunic": Color(0.3, 0.55, 0.3), "hair": Color(0.6, 0.3, 0.1)},
	]

	for npc_data in colors_list:
		var img = Image.create(16, 16, false, Image.FORMAT_RGBA8)
		img.fill(Color(0, 0, 0, 0))
		var skin = Color(0.87, 0.72, 0.53)
		var tunic_c: Color = npc_data["tunic"]
		var hair_c: Color = npc_data["hair"]
		var pants = Color(0.35, 0.25, 0.15)
		var boots = Color(0.25, 0.15, 0.08)

		for x in range(5, 11):
			for y in range(1, 4):
				img.set_pixel(x, y, hair_c)
		for x in range(5, 11):
			for y in range(4, 7):
				img.set_pixel(x, y, skin)
		img.set_pixel(6, 5, Color.BLACK)
		img.set_pixel(9, 5, Color.BLACK)
		for x in range(4, 12):
			for y in range(7, 11):
				img.set_pixel(x, y, tunic_c)
		for x in range(5, 11):
			for y in range(11, 13):
				img.set_pixel(x, y, pants)
		for x in range(5, 11):
			img.set_pixel(x, 13, boots)

		img.save_png("res://textures/npc_" + npc_data["name"] + ".png")
	print("NPC sprites saved.")

func _create_tile_textures() -> void:
	# Create a tileset image: 5 tiles in a row, each 16x16
	# 0: grass, 1: dirt path, 2: cobblestone, 3: wood floor, 4: stone wall
	var img = Image.create(80, 16, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))

	# Tile 0: Grass
	for x in range(0, 16):
		for y in range(0, 16):
			var g = randf_range(0.3, 0.5)
			img.set_pixel(x, y, Color(0.15, g, 0.1))
	# Grass detail
	for i in range(5):
		var gx = randi_range(1, 14)
		var gy = randi_range(1, 14)
		img.set_pixel(gx, gy, Color(0.2, 0.6, 0.15))

	# Tile 1: Dirt path
	for x in range(16, 32):
		for y in range(0, 16):
			var v = randf_range(0.35, 0.45)
			img.set_pixel(x, y, Color(v + 0.1, v, v - 0.1))
	# Pebbles
	for i in range(3):
		var px = randi_range(17, 30)
		var py = randi_range(1, 14)
		img.set_pixel(px, py, Color(0.5, 0.45, 0.35))

	# Tile 2: Cobblestone
	for x in range(32, 48):
		for y in range(0, 16):
			var v = randf_range(0.4, 0.55)
			img.set_pixel(x, y, Color(v, v, v))
	# Stone borders
	for x in range(32, 48):
		img.set_pixel(x, 0, Color(0.3, 0.3, 0.3))
		img.set_pixel(x, 8, Color(0.3, 0.3, 0.3))
	for y in range(0, 16):
		img.set_pixel(32, y, Color(0.3, 0.3, 0.3))
		img.set_pixel(40, y, Color(0.3, 0.3, 0.3))

	# Tile 3: Wood floor
	for x in range(48, 64):
		for y in range(0, 16):
			var v = randf_range(0.4, 0.5)
			img.set_pixel(x, y, Color(v + 0.15, v + 0.05, v - 0.1))
	# Wood grain
	for y_line in [3, 7, 11]:
		for x in range(48, 64):
			img.set_pixel(x, y_line, Color(0.4, 0.3, 0.15))

	# Tile 4: Stone wall
	for x in range(64, 80):
		for y in range(0, 16):
			var v = randf_range(0.35, 0.45)
			img.set_pixel(x, y, Color(v, v, v + 0.05))
	# Mortar lines
	for x in range(64, 80):
		img.set_pixel(x, 4, Color(0.55, 0.5, 0.45))
		img.set_pixel(x, 8, Color(0.55, 0.5, 0.45))
		img.set_pixel(x, 12, Color(0.55, 0.5, 0.45))
	for y in range(0, 4):
		img.set_pixel(72, y, Color(0.55, 0.5, 0.45))
	for y in range(4, 8):
		img.set_pixel(68, y, Color(0.55, 0.5, 0.45))
		img.set_pixel(76, y, Color(0.55, 0.5, 0.45))
	for y in range(8, 12):
		img.set_pixel(72, y, Color(0.55, 0.5, 0.45))
	for y in range(12, 16):
		img.set_pixel(68, y, Color(0.55, 0.5, 0.45))
		img.set_pixel(76, y, Color(0.55, 0.5, 0.45))

	img.save_png("res://textures/tiles.png")
	print("Tile textures saved.")

func _create_stall_texture() -> void:
	# Market stall: 48x32 pixels
	var img = Image.create(48, 32, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))

	var wood = Color(0.5, 0.35, 0.15)
	var wood_dark = Color(0.35, 0.22, 0.1)
	var cloth = Color(0.7, 0.15, 0.1)  # red awning
	var cloth_stripe = Color(0.8, 0.75, 0.6)

	# Awning (top portion)
	for x in range(0, 48):
		for y in range(0, 10):
			if (x / 6) % 2 == 0:
				img.set_pixel(x, y, cloth)
			else:
				img.set_pixel(x, y, cloth_stripe)
	# Awning shadow
	for x in range(0, 48):
		img.set_pixel(x, 10, Color(0.3, 0.2, 0.1, 0.5))

	# Counter / table
	for x in range(2, 46):
		for y in range(11, 18):
			img.set_pixel(x, y, wood)
	# Counter top highlight
	for x in range(2, 46):
		img.set_pixel(x, 11, Color(0.6, 0.45, 0.2))

	# Legs
	for y in range(18, 30):
		for x in [4, 5, 22, 23, 42, 43]:
			img.set_pixel(x, y, wood_dark)

	# Some wares on counter (colored squares)
	var ware_colors = [Color(0.8, 0.2, 0.1), Color(0.2, 0.6, 0.2), Color(0.8, 0.7, 0.1), Color(0.5, 0.2, 0.6)]
	for i in range(4):
		var wx = 8 + i * 9
		for x in range(wx, wx + 5):
			for y in range(8, 11):
				img.set_pixel(x, y, ware_colors[i])

	img.save_png("res://textures/market_stall.png")
	print("Market stall texture saved.")

func _create_object_textures() -> void:
	# Barrel: 12x14
	var barrel = Image.create(12, 14, false, Image.FORMAT_RGBA8)
	barrel.fill(Color(0, 0, 0, 0))
	var bwood = Color(0.45, 0.3, 0.12)
	var band = Color(0.35, 0.35, 0.4)
	for x in range(2, 10):
		for y in range(1, 13):
			barrel.set_pixel(x, y, bwood)
	# Bands
	for x in range(1, 11):
		barrel.set_pixel(x, 3, band)
		barrel.set_pixel(x, 10, band)
	# Top rim
	for x in range(3, 9):
		barrel.set_pixel(x, 0, Color(0.5, 0.35, 0.15))
		barrel.set_pixel(x, 1, Color(0.55, 0.4, 0.2))
	barrel.save_png("res://textures/barrel.png")

	# Crate: 14x14
	var crate = Image.create(14, 14, false, Image.FORMAT_RGBA8)
	crate.fill(Color(0, 0, 0, 0))
	var cwood = Color(0.55, 0.4, 0.18)
	var cedge = Color(0.4, 0.28, 0.1)
	for x in range(1, 13):
		for y in range(1, 13):
			crate.set_pixel(x, y, cwood)
	# Edges
	for i in range(0, 14):
		crate.set_pixel(i, 0, cedge)
		crate.set_pixel(i, 13, cedge)
		crate.set_pixel(0, i, cedge)
		crate.set_pixel(13, i, cedge)
	# Cross planks
	for i in range(1, 13):
		crate.set_pixel(i, 7, cedge)
		crate.set_pixel(7, i, cedge)
	crate.save_png("res://textures/crate.png")

	# Well: 24x24
	var well = Image.create(24, 24, false, Image.FORMAT_RGBA8)
	well.fill(Color(0, 0, 0, 0))
	var stone = Color(0.5, 0.48, 0.45)
	var stone_dark = Color(0.35, 0.33, 0.3)
	var water = Color(0.15, 0.25, 0.5)
	# Circular stone base
	for x in range(4, 20):
		for y in range(6, 22):
			var cx = x - 12
			var cy = y - 14
			if cx * cx + cy * cy <= 64:
				well.set_pixel(x, y, stone)
			if cx * cx + cy * cy <= 36 and cx * cx + cy * cy > 20:
				well.set_pixel(x, y, stone_dark)
			if cx * cx + cy * cy <= 20:
				well.set_pixel(x, y, water)
	# Roof posts
	for y in range(0, 14):
		well.set_pixel(6, y, Color(0.4, 0.25, 0.1))
		well.set_pixel(17, y, Color(0.4, 0.25, 0.1))
	# Roof
	for x in range(4, 20):
		well.set_pixel(x, 0, Color(0.5, 0.3, 0.1))
		well.set_pixel(x, 1, Color(0.45, 0.28, 0.1))
	well.save_png("res://textures/well.png")

	# Fountain: 32x32
	var fountain = Image.create(32, 32, false, Image.FORMAT_RGBA8)
	fountain.fill(Color(0, 0, 0, 0))
	var fstone = Color(0.55, 0.52, 0.48)
	var fwater = Color(0.2, 0.35, 0.6)
	# Outer ring
	for x in range(32):
		for y in range(32):
			var cx = x - 16
			var cy = y - 16
			var dist = cx * cx + cy * cy
			if dist <= 225 and dist > 144:
				fountain.set_pixel(x, y, fstone)
			elif dist <= 144:
				fountain.set_pixel(x, y, fwater)
	# Center pillar
	for x in range(14, 18):
		for y in range(8, 20):
			fountain.set_pixel(x, y, fstone)
	# Top basin
	for x in range(12, 20):
		fountain.set_pixel(x, 8, fstone)
		fountain.set_pixel(x, 9, fstone)
	fountain.save_png("res://textures/fountain.png")

	print("Object textures saved.")
