extends Node2D

## Main scene — builds the entire medieval market procedurally at runtime.

const TILE_SIZE := 16
const MAP_W := 40
const MAP_H := 30

enum Tile { GRASS, DIRT, COBBLE, WOOD, WALL }

var tile_textures: Array[Texture2D] = []
var map_data: Array = []
var player: CharacterBody2D
var camera: Camera2D
var inventory_label: Label
var drop_hint_label: Label

func _ready() -> void:
	_load_textures()
	_generate_map()
	_draw_map()
	_place_market_stalls()
	_place_decorations()
	_place_pickup_items()
	_create_player()
	_spawn_npcs()
	_setup_npc_dialogues()
	_build_walls()
	_create_ui()

func _load_textures() -> void:
	var tiles_img = Image.load_from_file("res://textures/tiles.png")
	for i in range(5):
		var tile_img = Image.create(TILE_SIZE, TILE_SIZE, false, Image.FORMAT_RGBA8)
		tile_img.blit_rect(tiles_img, Rect2i(i * TILE_SIZE, 0, TILE_SIZE, TILE_SIZE), Vector2i.ZERO)
		tile_textures.append(ImageTexture.create_from_image(tile_img))

func _generate_map() -> void:
	map_data.resize(MAP_H)
	for y in range(MAP_H):
		map_data[y] = []
		map_data[y].resize(MAP_W)
		for x in range(MAP_W):
			map_data[y][x] = Tile.GRASS

	# Central cobblestone plaza
	for y in range(8, 22):
		for x in range(8, 32):
			map_data[y][x] = Tile.COBBLE

	# Paths leading in from each direction
	for y in range(0, 8):
		for x in range(18, 22):
			map_data[y][x] = Tile.DIRT
	for y in range(22, MAP_H):
		for x in range(18, 22):
			map_data[y][x] = Tile.DIRT
	for y in range(13, 17):
		for x in range(0, 8):
			map_data[y][x] = Tile.DIRT
	for y in range(13, 17):
		for x in range(32, MAP_W):
			map_data[y][x] = Tile.DIRT

	# Wood floors under stall areas
	for rect in [
		[9, 12, 10, 16], [9, 12, 24, 30],
		[18, 21, 10, 16], [18, 21, 24, 30]
	]:
		for y in range(rect[0], rect[1]):
			for x in range(rect[2], rect[3]):
				map_data[y][x] = Tile.WOOD

func _draw_map() -> void:
	var map_node = Node2D.new()
	map_node.name = "Map"
	add_child(map_node)

	for y in range(MAP_H):
		for x in range(MAP_W):
			var sprite = Sprite2D.new()
			sprite.texture = tile_textures[map_data[y][x]]
			sprite.position = Vector2(x * TILE_SIZE, y * TILE_SIZE)
			sprite.centered = false
			sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			map_node.add_child(sprite)

func _create_player() -> void:
	player = CharacterBody2D.new()
	player.name = "Player"
	player.position = Vector2(20 * TILE_SIZE, 15 * TILE_SIZE)
	player.collision_layer = 1
	player.collision_mask = 14  # walls + objects + npcs
	player.set_script(load("res://scripts/player.gd"))

	var sprite = Sprite2D.new()
	sprite.name = "Sprite2D"
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	player.add_child(sprite)

	var col = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(10, 12)
	col.shape = shape
	player.add_child(col)

	add_child(player)

	# Camera
	camera = Camera2D.new()
	camera.name = "PlayerCamera"
	camera.zoom = Vector2(3, 3)
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = 8.0
	camera.make_current()
	player.add_child(camera)
	player.inventory_changed.connect(_on_inventory_changed)

func _place_market_stalls() -> void:
	var stall_tex = ImageTexture.create_from_image(Image.load_from_file("res://textures/market_stall.png"))
	var stall_positions = [
		Vector2(10, 9), Vector2(24, 9),
		Vector2(10, 18), Vector2(24, 18),
	]

	var stalls = Node2D.new()
	stalls.name = "Stalls"
	add_child(stalls)

	for pos in stall_positions:
		var spr = Sprite2D.new()
		spr.texture = stall_tex
		spr.position = Vector2(pos.x * TILE_SIZE, pos.y * TILE_SIZE)
		spr.centered = false
		spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		stalls.add_child(spr)

		var body = StaticBody2D.new()
		body.position = Vector2(pos.x * TILE_SIZE + 24, pos.y * TILE_SIZE + 14)
		body.collision_layer = 4
		body.collision_mask = 0
		var shape = CollisionShape2D.new()
		var rect = RectangleShape2D.new()
		rect.size = Vector2(44, 8)
		shape.shape = rect
		body.add_child(shape)
		stalls.add_child(body)

func _place_decorations() -> void:
	var barrel_tex = ImageTexture.create_from_image(Image.load_from_file("res://textures/barrel.png"))
	var crate_tex = ImageTexture.create_from_image(Image.load_from_file("res://textures/crate.png"))
	var well_tex = ImageTexture.create_from_image(Image.load_from_file("res://textures/well.png"))
	var fountain_tex = ImageTexture.create_from_image(Image.load_from_file("res://textures/fountain.png"))

	var decor = Node2D.new()
	decor.name = "Decorations"
	add_child(decor)

	# Fountain in center
	_add_decor(decor, fountain_tex, Vector2(19 * TILE_SIZE, 14 * TILE_SIZE))
	var fb = StaticBody2D.new()
	fb.position = Vector2(19 * TILE_SIZE, 14 * TILE_SIZE)
	fb.collision_layer = 4
	fb.collision_mask = 0
	var fs = CollisionShape2D.new()
	var fc = CircleShape2D.new()
	fc.radius = 14
	fs.shape = fc
	fb.add_child(fs)
	decor.add_child(fb)

	# Barrels
	for bpos in [
		Vector2(9, 11), Vector2(16, 10), Vector2(23, 11),
		Vector2(30, 10), Vector2(9, 20), Vector2(16, 19), Vector2(30, 19)
	]:
		var p = bpos * TILE_SIZE
		_add_decor_col(decor, barrel_tex, p, Vector2(10, 12))

	# Crates
	for cpos in [Vector2(8, 9), Vector2(31, 9), Vector2(8, 20), Vector2(31, 20)]:
		var p = cpos * TILE_SIZE
		_add_decor_col(decor, crate_tex, p, Vector2(12, 12))

	# Well
	_add_decor(decor, well_tex, Vector2(35 * TILE_SIZE, 15 * TILE_SIZE))
	var wb = StaticBody2D.new()
	wb.position = Vector2(35 * TILE_SIZE, 15 * TILE_SIZE)
	wb.collision_layer = 4
	wb.collision_mask = 0
	var ws = CollisionShape2D.new()
	var wc = CircleShape2D.new()
	wc.radius = 10
	ws.shape = wc
	wb.add_child(ws)
	decor.add_child(wb)

func _add_decor(parent: Node2D, tex: Texture2D, pos: Vector2) -> void:
	var spr = Sprite2D.new()
	spr.texture = tex
	spr.position = pos
	spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	parent.add_child(spr)

func _add_decor_col(parent: Node2D, tex: Texture2D, pos: Vector2, col_size: Vector2) -> void:
	_add_decor(parent, tex, pos)
	var body = StaticBody2D.new()
	body.position = pos
	body.collision_layer = 4
	body.collision_mask = 0
	var shape = CollisionShape2D.new()
	var rect = RectangleShape2D.new()
	rect.size = col_size
	shape.shape = rect
	body.add_child(shape)
	parent.add_child(body)

func _spawn_npcs() -> void:
	var npc_script = load("res://scripts/npc.gd")
	var npc_configs = [
		{
			"name": "Merchant",
			"texture": "res://textures/npc_merchant.png",
			"pos": Vector2(13, 12),
			"lines": ["Welcome, traveler!\nThe finest silks from the East!", "Perhaps a jeweled dagger\ncatches your eye?", "Come back anytime!"],
			"range": 30.0,
		},
		{
			"name": "Baker",
			"texture": "res://textures/npc_baker.png",
			"pos": Vector2(27, 12),
			"lines": ["Fresh bread! Still warm\nfrom the oven!", "Try my honey cakes,\nbest in the kingdom!", "The secret is in the yeast..."],
			"range": 25.0,
		},
		{
			"name": "Blacksmith",
			"texture": "res://textures/npc_blacksmith.png",
			"pos": Vector2(13, 21),
			"lines": ["Need a blade sharpened?", "This steel was forged in\ndragonfire! ...Well, regular fire.", "Watch your fingers\naround the anvil!"],
			"range": 35.0,
		},
		{
			"name": "Herbalist",
			"texture": "res://textures/npc_herbalist.png",
			"pos": Vector2(27, 21),
			"lines": ["Herbs and potions,\ncures for what ails ye!", "This tincture will ward\noff the plague... probably.", "Lavender for luck,\nthyme for truth!"],
			"range": 20.0,
		},
	]

	var npcs_node = Node2D.new()
	npcs_node.name = "NPCs"
	add_child(npcs_node)

	for cfg in npc_configs:
		var npc = CharacterBody2D.new()
		npc.name = cfg["name"]
		npc.set_script(npc_script)
		npc.position = cfg["pos"] * TILE_SIZE

		var sprite = Sprite2D.new()
		sprite.name = "Sprite2D"
		sprite.texture = ImageTexture.create_from_image(Image.load_from_file(cfg["texture"]))
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		npc.add_child(sprite)

		var col = CollisionShape2D.new()
		var col_shape = RectangleShape2D.new()
		col_shape.size = Vector2(10, 12)
		col.shape = col_shape
		npc.add_child(col)
		npc.collision_layer = 8
		npc.collision_mask = 6

		var label = Label.new()
		label.name = "Label"
		label.position = Vector2(-60, -40)
		label.add_theme_font_size_override("font_size", 8)
		label.add_theme_color_override("font_color", Color.WHITE)
		label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
		label.add_theme_constant_override("shadow_offset_x", 1)
		label.add_theme_constant_override("shadow_offset_y", 1)
		npc.add_child(label)

		var area = Area2D.new()
		area.name = "InteractionArea"
		area.collision_layer = 0
		area.collision_mask = 1
		var area_shape = CollisionShape2D.new()
		var area_circle = CircleShape2D.new()
		area_circle.radius = 30
		area_shape.shape = area_circle
		area.add_child(area_shape)
		npc.add_child(area)

		npc.npc_name = cfg["name"]
		npc.dialogue_lines = PackedStringArray(cfg["lines"])
		npc.wander_range = cfg["range"]

		npcs_node.add_child(npc)

func _build_walls() -> void:
	var walls = Node2D.new()
	walls.name = "Walls"
	add_child(walls)

	var map_px_w = MAP_W * TILE_SIZE
	var map_px_h = MAP_H * TILE_SIZE
	_add_wall(walls, Vector2(map_px_w / 2, -4), Vector2(map_px_w, 8))
	_add_wall(walls, Vector2(map_px_w / 2, map_px_h + 4), Vector2(map_px_w, 8))
	_add_wall(walls, Vector2(-4, map_px_h / 2), Vector2(8, map_px_h))
	_add_wall(walls, Vector2(map_px_w + 4, map_px_h / 2), Vector2(8, map_px_h))

func _add_wall(parent: Node2D, pos: Vector2, size: Vector2) -> void:
	var body = StaticBody2D.new()
	body.position = pos
	body.collision_layer = 2
	body.collision_mask = 0
	var shape = CollisionShape2D.new()
	var rect = RectangleShape2D.new()
	rect.size = size
	shape.shape = rect
	body.add_child(shape)
	parent.add_child(body)

func _create_ui() -> void:
	var canvas = CanvasLayer.new()
	canvas.name = "UI"
	add_child(canvas)

	var hint = Label.new()
	hint.text = "WASD to move | E to interact | Q to drop item"
	hint.position = Vector2(10, 10)
	hint.add_theme_font_size_override("font_size", 14)
	hint.add_theme_color_override("font_color", Color(1, 1, 1, 0.6))
	canvas.add_child(hint)

	# Fade out hint after 5 seconds
	var tween = create_tween()
	tween.tween_interval(5.0)
	tween.tween_property(hint, "modulate:a", 0.0, 2.0)

	# Inventory HUD (top-right corner)
	var inv_panel = PanelContainer.new()
	inv_panel.name = "InventoryPanel"
	inv_panel.position = Vector2(900, 10)
	inv_panel.add_theme_stylebox_override("panel", _create_inv_panel_style())

	var vbox = VBoxContainer.new()
	inv_panel.add_child(vbox)

	var inv_title = Label.new()
	inv_title.text = "Inventory"
	inv_title.add_theme_font_size_override("font_size", 12)
	inv_title.add_theme_color_override("font_color", Color(1, 0.85, 0.4))
	vbox.add_child(inv_title)

	inventory_label = Label.new()
	inventory_label.name = "InventoryLabel"
	inventory_label.text = "(empty)"
	inventory_label.add_theme_font_size_override("font_size", 10)
	inventory_label.add_theme_color_override("font_color", Color.WHITE)
	vbox.add_child(inventory_label)

	drop_hint_label = Label.new()
	drop_hint_label.name = "DropHint"
	drop_hint_label.text = ""
	drop_hint_label.add_theme_font_size_override("font_size", 8)
	drop_hint_label.add_theme_color_override("font_color", Color(1, 1, 1, 0.5))
	vbox.add_child(drop_hint_label)

	canvas.add_child(inv_panel)

func _create_inv_panel_style() -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0, 0, 0, 0.6)
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_left = 4
	style.corner_radius_bottom_right = 4
	style.content_margin_left = 8
	style.content_margin_right = 8
	style.content_margin_top = 4
	style.content_margin_bottom = 4
	return style

func _place_pickup_items() -> void:
	var item_script = load("res://scripts/pickup_item.gd")
	var items_config = [
		{"name": "Bread", "pos": Vector2(29, 13) * TILE_SIZE, "color": Color(0.82, 0.65, 0.35)},
		{"name": "Sword", "pos": Vector2(11, 19) * TILE_SIZE, "color": Color(0.7, 0.7, 0.75)},
		{"name": "Herb", "pos": Vector2(29, 22) * TILE_SIZE, "color": Color(0.2, 0.7, 0.3)},
		{"name": "Gold Coin", "pos": Vector2(18, 8) * TILE_SIZE, "color": Color(1.0, 0.85, 0.2)},
	]

	var items_node = Node2D.new()
	items_node.name = "Items"
	add_child(items_node)

	for cfg in items_config:
		var item_name: String = cfg["name"]
		var item = Area2D.new()
		item.name = item_name.replace(" ", "")
		item.set_script(item_script)
		item.item_name = item_name
		item.position = cfg["pos"]
		item.collision_layer = 0
		item.collision_mask = 1

		var sprite = Sprite2D.new()
		sprite.name = "Sprite2D"
		var img = Image.create(12, 12, false, Image.FORMAT_RGBA8)
		img.fill(cfg["color"])
		sprite.texture = ImageTexture.create_from_image(img)
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		item.add_child(sprite)

		var lbl = Label.new()
		lbl.name = "ItemLabel"
		lbl.text = item_name
		lbl.position = Vector2(-20, -18)
		lbl.add_theme_font_size_override("font_size", 6)
		lbl.add_theme_color_override("font_color", Color.WHITE)
		lbl.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
		lbl.add_theme_constant_override("shadow_offset_x", 1)
		lbl.add_theme_constant_override("shadow_offset_y", 1)
		item.add_child(lbl)

		var col = CollisionShape2D.new()
		var shape = CircleShape2D.new()
		shape.radius = 14
		col.shape = shape
		item.add_child(col)

		items_node.add_child(item)

func _setup_npc_dialogues() -> void:
	var npcs_node = get_node("NPCs")
	for npc in npcs_node.get_children():
		NpcDialogues.configure(npc)

func _on_inventory_changed() -> void:
	if inventory_label == null:
		return
	var inv = player.get_inventory()
	if inv.is_empty():
		inventory_label.text = "(empty)"
		drop_hint_label.text = ""
	else:
		var lines = PackedStringArray()
		for i in range(inv.size()):
			lines.append(str(i + 1) + ". " + inv[i])
		inventory_label.text = "\n".join(lines)
		drop_hint_label.text = "Q to drop last item"

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("drop_item") and player != null:
		var inv = player.get_inventory()
		if inv.size() > 0:
			var dropped_item_name = inv[inv.size() - 1]
			player.remove_item(dropped_item_name)
			_spawn_dropped_item(dropped_item_name, player.global_position + Vector2(0, 20))

func _spawn_dropped_item(item_name: String, pos: Vector2) -> void:
	var item_colors = {
		"Bread": Color(0.82, 0.65, 0.35),
		"Sword": Color(0.7, 0.7, 0.75),
		"Herb": Color(0.2, 0.7, 0.3),
		"Gold Coin": Color(1.0, 0.85, 0.2),
	}
	var color = item_colors.get(item_name, Color.WHITE)

	var item_script = load("res://scripts/pickup_item.gd")
	var item = Area2D.new()
	item.name = item_name.replace(" ", "") + "_dropped"
	item.set_script(item_script)
	item.item_name = item_name
	item.position = pos
	item.collision_layer = 0
	item.collision_mask = 1

	var sprite = Sprite2D.new()
	sprite.name = "Sprite2D"
	var img = Image.create(12, 12, false, Image.FORMAT_RGBA8)
	img.fill(color)
	sprite.texture = ImageTexture.create_from_image(img)
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	item.add_child(sprite)

	var lbl = Label.new()
	lbl.name = "ItemLabel"
	lbl.text = item_name
	lbl.position = Vector2(-20, -18)
	lbl.add_theme_font_size_override("font_size", 6)
	lbl.add_theme_color_override("font_color", Color.WHITE)
	lbl.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
	lbl.add_theme_constant_override("shadow_offset_x", 1)
	lbl.add_theme_constant_override("shadow_offset_y", 1)
	item.add_child(lbl)

	var col = CollisionShape2D.new()
	var shape = CircleShape2D.new()
	shape.radius = 14
	col.shape = shape
	item.add_child(col)

	var items_node = get_node_or_null("Items")
	if items_node:
		items_node.add_child(item)
	else:
		add_child(item)
