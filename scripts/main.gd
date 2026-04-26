extends Node2D

## Main scene — composes the village from `MapGenerator` and spawns the player,
## NPCs, items, and HUD on top.

const TILE_SIZE := MapGenerator.TILE_SIZE

var map_generator: MapGenerator
var player: CharacterBody2D
var camera: Camera2D
var inventory_label: Label
var drop_hint_label: Label

func _ready() -> void:
	map_generator = MapGenerator.new()
	map_generator.build(self)
	_create_player()
	_place_pickup_items()
	_spawn_npcs()
	_setup_npc_dialogues()
	_create_ui()

func _create_player() -> void:
	player = CharacterBody2D.new()
	player.name = "Player"
	player.position = map_generator.player_spawn
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

	camera = Camera2D.new()
	camera.name = "PlayerCamera"
	camera.zoom = Vector2(3, 3)
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = 8.0
	camera.make_current()
	player.add_child(camera)
	player.inventory_changed.connect(_on_inventory_changed)

func _spawn_npcs() -> void:
	# Roster reconciled with docs/places/village.md. Original four textures
	# (merchant, baker, blacksmith, herbalist) are reused for the wider cast.
	# The four legacy names keep their inventory-aware dialogue from
	# `npc_dialogues.gd`; the rest use generic dialogue lines.
	var npc_script = load("res://scripts/npc.gd")
	var npc_configs = [
		# --- Market square ---
		{
			"name": "Merchant",
			"texture": "res://textures/npc_merchant.png",
			"pos": Vector2(43, 24),
			"lines": ["Welcome, traveler!\nThe finest silks from the East!", "Perhaps a jeweled dagger\ncatches your eye?", "Come back anytime!"],
			"range": 25.0,
		},
		{
			"name": "Baker",
			"texture": "res://textures/npc_baker.png",
			"pos": Vector2(57, 24),
			"lines": ["Fresh bread! Still warm\nfrom the oven!", "Try my honey cakes,\nbest in the kingdom!", "The secret is in the yeast..."],
			"range": 25.0,
		},
		{
			"name": "Herbalist",
			"texture": "res://textures/npc_herbalist.png",
			"pos": Vector2(57, 32),
			"lines": ["Herbs and potions,\ncures for what ails ye!", "This tincture will ward\noff the plague... probably.", "Lavender for luck,\nthyme for truth!"],
			"range": 20.0,
		},
		{
			"name": "Old Hamid",
			"texture": "res://textures/npc_merchant.png",
			"pos": Vector2(43, 32),
			"lines": ["The goats know me,\nand I know them.", "A donkey will outwork\nany horse, mark my words.", "Mind the smell, friend."],
			"range": 0.0,
		},
		# --- Blacksmith ---
		{
			"name": "Blacksmith",
			"texture": "res://textures/npc_blacksmith.png",
			"pos": Vector2(39, 39),
			"lines": ["Need a blade sharpened?", "This steel was forged in\ndragonfire! ...Well, regular fire.", "Watch your fingers\naround the anvil!"],
			"range": 18.0,
		},
		{
			"name": "Tarik",
			"texture": "res://textures/npc_blacksmith.png",
			"pos": Vector2(41, 35),
			"lines": ["Ibrahim wants me to\nrun another errand.", "The bellows never rest.", "One day I'll forge my own\nblade. One day."],
			"range": 60.0,
		},
		# --- Mill ---
		{
			"name": "Abbas",
			"texture": "res://textures/npc_baker.png",
			"pos": Vector2(56, 39),
			"lines": ["The wheel turns,\nthe flour falls.", "Mind the dust — it gets\neverywhere.", "I sing to the stones.\nThey listen better than people."],
			"range": 0.0,
		},
		# --- Warehouse ---
		{
			"name": "Rafiq",
			"texture": "res://textures/npc_blacksmith.png",
			"pos": Vector2(72, 25),
			"lines": ["Don't touch the sacks.", "Every grain is counted.", "I see everything in here.\nRemember that."],
			"range": 30.0,
		},
		{
			"name": "Salim",
			"texture": "res://textures/npc_merchant.png",
			"pos": Vector2(70, 26),
			"lines": ["Hauling, hauling,\nalways hauling.", "Rafiq counts twice. Then\nhe counts again.", "My back will give out\nbefore the harvest does."],
			"range": 40.0,
		},
		{
			"name": "Nura",
			"texture": "res://textures/npc_merchant.png",
			"pos": Vector2(74, 27),
			"lines": ["The patrol schedule is\non the barracks wall.", "I've memorized every\nguard rotation, you know.", "Don't ask how I know\nwhen they switch."],
			"range": 40.0,
		},
		# --- Barracks ---
		{
			"name": "Capitan Rodrigo",
			"texture": "res://textures/npc_blacksmith.png",
			"pos": Vector2(71, 35),
			"lines": ["State your business.", "I keep this village safe.\nDon't get in my way.", "If you fall foul of the law,\nyou'll meet me again."],
			"range": 25.0,
		},
		# --- Church ---
		{
			"name": "Father Domingo",
			"texture": "res://textures/npc_baker.png",
			"pos": Vector2(30, 9),
			"lines": ["Peace be upon you,\ntraveler.", "All are welcome at this altar,\nwhatever their tongue.", "Light a candle, rest your feet."],
			"range": 0.0,
		},
		# --- Workshop ---
		{
			"name": "Zahra",
			"texture": "res://textures/npc_herbalist.png",
			"pos": Vector2(40, 8),
			"lines": ["Mind the kiln —\nshe bites.", "Geometry is the language\nof beauty.", "I have books, if you want\nto see worlds beyond this one."],
			"range": 12.0,
		},
		# --- School ---
		{
			"name": "Maestro al-Rashid",
			"texture": "res://textures/npc_merchant.png",
			"pos": Vector2(59, 8),
			"lines": ["The chalkboard remembers\nwhat children forget.", "Every script tells a story.\nWhich is yours?", "Sit. Learn. There is time."],
			"range": 0.0,
		},
		# --- Tailor ---
		{
			"name": "Maryam",
			"texture": "res://textures/npc_herbalist.png",
			"pos": Vector2(43, 16),
			"lines": ["Mind the pins on the floor.", "I work best by lamplight.", "Take this scrap, if it suits.\nWinter is coming."],
			"range": 0.0,
		},
		# --- Fields ---
		{
			"name": "Qadir",
			"texture": "res://textures/npc_blacksmith.png",
			"pos": Vector2(26, 36),
			"lines": ["Idle hands aren't welcome\nin my fields.", "Pick up a sickle or move on.", "The acequia waits for no one."],
			"range": 60.0,
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

func _setup_npc_dialogues() -> void:
	var npcs_node = get_node("NPCs")
	for npc in npcs_node.get_children():
		NpcDialogues.configure(npc)

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

	var tween = create_tween()
	tween.tween_interval(5.0)
	tween.tween_property(hint, "modulate:a", 0.0, 2.0)

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
		{"name": "Bread", "pos": Vector2(58, 26) * TILE_SIZE, "color": Color(0.82, 0.65, 0.35)},
		{"name": "Sword", "pos": Vector2(40, 40) * TILE_SIZE, "color": Color(0.7, 0.7, 0.75)},
		{"name": "Herb", "pos": Vector2(31, 2) * TILE_SIZE, "color": Color(0.2, 0.7, 0.3)},
		{"name": "Gold Coin", "pos": Vector2(50, 8) * TILE_SIZE, "color": Color(1.0, 0.85, 0.2)},
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
