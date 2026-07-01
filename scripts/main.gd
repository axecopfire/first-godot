extends Node2D

## Main scene — composes the village from `MapGenerator` and spawns the player,
## NPCs, items, and HUD on top.

const TILE_SIZE := MapGenerator.TILE_SIZE
const DAY_DURATION_SECONDS := 300.0

var map_generator: MapGenerator
var player: CharacterBody2D
var camera: Camera2D
var inventory_label: Label
var drop_hint_label: Label
var time_label: Label
var zone_labels: Dictionary = {}
var dev_time_dropdown: OptionButton
var day_night_overlay: ColorRect
var day_number: int = 1
var day_timer: float = 0.0

## Bell-toll state
var bell_player: AudioStreamPlayer
var _last_bell_hour: int = -1
var _pending_tolls: int = 0
var _toll_cooldown: float = 0.0
const _TOLL_INTERVAL := 1.1  # seconds between strikes

func _ready() -> void:
	map_generator = MapGenerator.new()
	map_generator.build(self)
	_create_zone_labels()
	_create_player()
	_place_pickup_items()
	_spawn_npcs()
	_setup_npc_dialogues()
	_create_day_night_overlay()
	_create_ui()
	_setup_bell_audio()
	_update_day_night(0.0)

func _process(delta: float) -> void:
	day_timer += delta
	while day_timer >= DAY_DURATION_SECONDS:
		day_timer -= DAY_DURATION_SECONDS
		day_number += 1
	var progress := day_timer / DAY_DURATION_SECONDS
	_update_day_night(progress)
	_tick_bell(progress, delta)
	_update_npc_schedules(progress)

## Hours that trigger the bell and how many times it strikes.
## 1 = dawn, 2 = noon, 3 = evening, 4 = night — player can count to place themselves in the day.
const _BELL_SCHEDULE: Dictionary = { 6: 1, 12: 2, 18: 3, 21: 4 }
const _DEV_TIME_PRESETS := [
	{"label": "Set Time: Dawn (06:00)", "hour": 6},
	{"label": "Set Time: Morning (09:00)", "hour": 9},
	{"label": "Set Time: Noon (12:00)", "hour": 12},
	{"label": "Set Time: Afternoon (15:00)", "hour": 15},
	{"label": "Set Time: Evening (18:00)", "hour": 18},
	{"label": "Set Time: Night (21:00)", "hour": 21},
	{"label": "Set Time: Midnight (00:00)", "hour": 0},
]

func _tick_bell(progress: float, delta: float) -> void:
	var current_hour: int = int(progress * 24.0) % 24
	if current_hour != _last_bell_hour:
		_last_bell_hour = current_hour
		if _BELL_SCHEDULE.has(current_hour):
			_pending_tolls += _BELL_SCHEDULE[current_hour]
			_toll_cooldown = 0.0

	if _pending_tolls > 0:
		_toll_cooldown -= delta
		if _toll_cooldown <= 0.0:
			bell_player.play()
			_pending_tolls -= 1
			_toll_cooldown = _TOLL_INTERVAL

func _setup_bell_audio() -> void:
	bell_player = AudioStreamPlayer.new()
	bell_player.name = "BellPlayer"
	bell_player.bus = "Master"
	bell_player.volume_db = 0.0
	var stream = AudioStreamWAV.new()
	var file = FileAccess.open("res://audio/bell_toll.wav", FileAccess.READ)
	if file == null:
		push_warning("bell_toll.wav not found — bell audio disabled")
		return
	# Skip 44-byte PCM WAV header, read raw 16-bit mono samples
	file.seek(44)
	var raw: PackedByteArray = file.get_buffer(file.get_length() - 44)
	file.close()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.stereo = false
	stream.mix_rate = 44100
	stream.data = raw
	bell_player.stream = stream
	add_child(bell_player)

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
	# Profession-specific dialogue comes from `npc_dialogues.gd`.
	var npc_script = load("res://scripts/npc.gd")
	var npc_configs = [
		# --- Market square ---
		{
			"name": "Yusuf",
			"profession": "Merchant",
			"texture": "res://textures/npc_merchant.png",
			"pos": Vector2(43, 24),
			"lines": ["Welcome, traveler!\nThe finest silks from the East!", "Perhaps a jeweled dagger\ncatches your eye?", "Come back anytime!"],
			"range": 25.0,
		},
		{
			"name": "Amina",
			"profession": "Baker",
			"texture": "res://textures/npc_baker.png",
			"pos": Vector2(57, 24),
			"lines": ["Fresh bread! Still warm\nfrom the oven!", "Try my honey cakes,\nbest in the kingdom!", "The secret is in the yeast..."],
			"range": 25.0,
		},
		{
			"name": "Samira",
			"profession": "Herbalist",
			"texture": "res://textures/npc_herbalist.png",
			"pos": Vector2(57, 32),
			"lines": ["Herbs and potions,\ncures for what ails ye!", "This tincture will ward\noff the plague... probably.", "Lavender for luck,\nthyme for truth!"],
			"range": 20.0,
		},
		{
			"name": "Old Hamid",
			"profession": "Herdsman",
			"texture": "res://textures/npc_merchant.png",
			"pos": Vector2(43, 32),
			"lines": ["The goats know me,\nand I know them.", "A donkey will outwork\nany horse, mark my words.", "Mind the smell, friend."],
			"range": 0.0,
		},
		# --- Blacksmith ---
		{
			"name": "Ibrahim",
			"profession": "Blacksmith",
			"texture": "res://textures/npc_blacksmith.png",
			"pos": Vector2(39, 39),
			"lines": ["Need a blade sharpened?", "This steel was forged in\ndragonfire! ...Well, regular fire.", "Watch your fingers\naround the anvil!"],
			"range": 18.0,
		},
		{
			"name": "Tarik",
			"profession": "Apprentice",
			"texture": "res://textures/npc_blacksmith.png",
			"pos": Vector2(41, 35),
			"lines": ["Ibrahim wants me to\nrun another errand.", "The bellows never rest.", "One day I'll forge my own\nblade. One day."],
			"range": 60.0,
		},
		# --- Mill ---
		{
			"name": "Abbas",
			"profession": "Miller",
			"texture": "res://textures/npc_baker.png",
			"pos": Vector2(56, 39),
			"lines": ["The wheel turns,\nthe flour falls.", "Mind the dust — it gets\neverywhere.", "I sing to the stones.\nThey listen better than people."],
			"range": 0.0,
		},
		# --- Warehouse ---
		{
			"name": "Rafiq",
			"profession": "Storekeeper",
			"texture": "res://textures/npc_blacksmith.png",
			"pos": Vector2(72, 25),
			"lines": ["Don't touch the sacks.", "Every grain is counted.", "I see everything in here.\nRemember that."],
			"range": 30.0,
		},
		{
			"name": "Salim",
			"profession": "Porter",
			"texture": "res://textures/npc_merchant.png",
			"pos": Vector2(70, 26),
			"lines": ["Hauling, hauling,\nalways hauling.", "Rafiq counts twice. Then\nhe counts again.", "My back will give out\nbefore the harvest does."],
			"range": 40.0,
		},
		{
			"name": "Nura",
			"profession": "Clerk",
			"texture": "res://textures/npc_merchant.png",
			"pos": Vector2(74, 27),
			"lines": ["The patrol schedule is\non the barracks wall.", "I've memorized every\nguard rotation, you know.", "Don't ask how I know\nwhen they switch."],
			"range": 40.0,
		},
		# --- Barracks ---
		{
			"name": "Capitan Rodrigo",
			"profession": "Captain",
			"texture": "res://textures/npc_blacksmith.png",
			"pos": Vector2(71, 35),
			"lines": ["State your business.", "I keep this village safe.\nDon't get in my way.", "If you fall foul of the law,\nyou'll meet me again."],
			"range": 25.0,
		},
		# --- Church ---
		{
			"name": "Father Domingo",
			"profession": "Priest",
			"texture": "res://textures/npc_baker.png",
			"pos": Vector2(30, 9),
			"lines": ["Peace be upon you,\ntraveler.", "All are welcome at this altar,\nwhatever their tongue.", "Light a candle, rest your feet."],
			"range": 0.0,
		},
		# --- Workshop ---
		{
			"name": "Zahra",
			"profession": "Artisan",
			"texture": "res://textures/npc_herbalist.png",
			"pos": Vector2(40, 8),
			"lines": ["Mind the kiln —\nshe bites.", "Geometry is the language\nof beauty.", "I have books, if you want\nto see worlds beyond this one."],
			"range": 12.0,
		},
		# --- School ---
		{
			"name": "Maestro al-Rashid",
			"profession": "Teacher",
			"texture": "res://textures/npc_merchant.png",
			"pos": Vector2(59, 8),
			"lines": ["The chalkboard remembers\nwhat children forget.", "Every script tells a story.\nWhich is yours?", "Sit. Learn. There is time."],
			"range": 0.0,
		},
		# --- Tailor ---
		{
			"name": "Maryam",
			"profession": "Tailor",
			"texture": "res://textures/npc_herbalist.png",
			"pos": Vector2(43, 16),
			"lines": ["Mind the pins on the floor.", "I work best by lamplight.", "Take this scrap, if it suits.\nWinter is coming."],
			"range": 0.0,
		},
		# --- Fields ---
		{
			"name": "Qadir",
			"profession": "Fieldmaster",
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
		var display_name := str(cfg.get("name", "")).strip_edges()
		var profession := str(cfg.get("profession", "")).strip_edges()
		if display_name == "" or profession == "":
			push_warning("Skipping NPC config with missing name/profession: %s" % [str(cfg)])
			continue

		var npc = CharacterBody2D.new()
		npc.name = display_name
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

		var name_label = Label.new()
		name_label.name = "NameLabel"
		name_label.text = "%s (%s)" % [display_name, profession]
		name_label.position = Vector2(-30, -25)
		name_label.add_theme_font_size_override("font_size", 10)
		name_label.add_theme_color_override("font_color", Color.YELLOW)
		name_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
		name_label.add_theme_constant_override("shadow_offset_x", 1)
		name_label.add_theme_constant_override("shadow_offset_y", 1)
		npc.add_child(name_label)

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

		npc.entity_name = display_name
		npc.npc_display_name = display_name
		npc.npc_profession = profession
		var base_lines := PackedStringArray(cfg["lines"])
		var relationship_lines := NpcRelationships.build_dialogue_lines(display_name)
		for line in relationship_lines:
			base_lines.append(line)
		npc.dialogue_lines = base_lines
		npc.set_meta("relationship_profile", NpcRelationships.get_profile(display_name))
		npc.set_meta("dwelling_profile", NpcRelationships.get_dwelling_for_npc(display_name))
		npc.wander_range = cfg["range"]
		npc.set_home_position(_resolve_npc_home_position(display_name, cfg["pos"]))

		npcs_node.add_child(npc)

func _update_npc_schedules(cycle_progress: float) -> void:
	var npcs_node := get_node_or_null("NPCs")
	if npcs_node == null:
		return

	for npc in npcs_node.get_children():
		if npc.has_method("set_day_cycle_progress"):
			npc.set_day_cycle_progress(cycle_progress)

func _create_zone_labels() -> void:
	## Creates location name labels positioned at the center of each zone.
	## Labels are world-space objects so they appear on the map and move with camera.
	var labels_layer = Node2D.new()
	labels_layer.name = "ZoneLabels"
	add_child(labels_layer)

	for zone_name in MapGenerator.ZONES:
		var zone: Rect2i = MapGenerator.ZONES[zone_name]
		var center_x = (zone.position.x + zone.size.x / 2.0) * TILE_SIZE
		var center_y = (zone.position.y + zone.size.y / 2.0) * TILE_SIZE

		var label = Label.new()
		label.name = zone_name + "_label"
		label.text = zone_name.to_upper()
		label.position = Vector2(center_x - 60, center_y - 10)
		label.add_theme_font_size_override("font_size", 12)
		label.add_theme_color_override("font_color", Color(0.4, 0.9, 0.6, 0.9))
		label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.95))
		label.add_theme_constant_override("shadow_offset_x", 2)
		label.add_theme_constant_override("shadow_offset_y", 2)

		labels_layer.add_child(label)
		zone_labels[zone_name] = label

func _resolve_npc_home_position(entity_name: String, fallback_tile: Vector2) -> Vector2:
	var dwelling := NpcRelationships.get_dwelling_for_npc(entity_name)
	if dwelling.is_empty():
		return fallback_tile * TILE_SIZE

	var zone_name := str(dwelling.get("zone", ""))
	if zone_name == "" or not MapGenerator.ZONES.has(zone_name):
		return fallback_tile * TILE_SIZE

	var zone: Rect2i = MapGenerator.ZONES[zone_name]
	var interior_width: int = max(zone.size.x - 2, 1)
	var interior_height: int = max(zone.size.y - 2, 1)
	var seed: int = abs(hash(entity_name))
	var offset_x: int = int(seed % interior_width)
	var offset_y: int = int((seed / max(interior_width, 1)) % interior_height)
	var tile_x: int = zone.position.x + 1 + offset_x
	var tile_y: int = zone.position.y + 1 + offset_y
	return Vector2(tile_x + 0.5, tile_y + 0.5) * TILE_SIZE

func _setup_npc_dialogues() -> void:
	var npcs_node = get_node("NPCs")
	for npc in npcs_node.get_children():
		NpcDialogues.configure(npc)

func _create_ui() -> void:
	var canvas = CanvasLayer.new()
	canvas.name = "UI"
	canvas.layer = 10
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

	time_label = Label.new()
	time_label.name = "TimeLabel"
	time_label.position = Vector2(10, 34)
	time_label.add_theme_font_size_override("font_size", 12)
	time_label.add_theme_color_override("font_color", Color(0.8, 0.9, 1.0, 0.95))
	time_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
	time_label.add_theme_constant_override("shadow_offset_x", 1)
	time_label.add_theme_constant_override("shadow_offset_y", 1)
	canvas.add_child(time_label)

	dev_time_dropdown = OptionButton.new()
	dev_time_dropdown.name = "DevTimeDropdown"
	dev_time_dropdown.position = Vector2(10, 56)
	dev_time_dropdown.custom_minimum_size = Vector2(210, 0)
	for i in range(_DEV_TIME_PRESETS.size()):
		var preset = _DEV_TIME_PRESETS[i]
		dev_time_dropdown.add_item(preset["label"], i)
	dev_time_dropdown.item_selected.connect(_on_dev_time_selected)
	canvas.add_child(dev_time_dropdown)

func _create_day_night_overlay() -> void:
	var cycle_layer: CanvasLayer = CanvasLayer.new()
	cycle_layer.name = "DayNightLayer"
	cycle_layer.layer = 5
	add_child(cycle_layer)

	day_night_overlay = ColorRect.new()
	day_night_overlay.name = "DayNightOverlay"
	day_night_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	day_night_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	day_night_overlay.grow_horizontal = Control.GROW_DIRECTION_BOTH
	day_night_overlay.grow_vertical = Control.GROW_DIRECTION_BOTH
	cycle_layer.add_child(day_night_overlay)

func _update_day_night(cycle_progress: float) -> void:
	if day_night_overlay != null:
		# Daylight peaks at midday and fades to a dark blue tint through the night.
		var daylight: float = clampf(cos((cycle_progress - 0.5) * TAU), 0.0, 1.0)
		var night_alpha: float = lerpf(0.55, 0.0, daylight)
		day_night_overlay.color = Color(0.08, 0.12, 0.25, night_alpha)

	if time_label != null:
		time_label.text = "Day %d | %s" % [day_number, _format_clock_time(cycle_progress)]

func _format_clock_time(cycle_progress: float) -> String:
	var total_minutes: int = int(floor(cycle_progress * 24.0 * 60.0))
	var hours: int = int(total_minutes / 60) % 24
	var minutes: int = total_minutes % 60
	return "%02d:%02d" % [hours, minutes]

func _on_dev_time_selected(index: int) -> void:
	if index < 0 or index >= _DEV_TIME_PRESETS.size():
		return

	var preset = _DEV_TIME_PRESETS[index]
	var hour: int = int(preset["hour"])
	day_timer = (float(hour) / 24.0) * DAY_DURATION_SECONDS

	var progress := day_timer / DAY_DURATION_SECONDS
	_update_day_night(progress)
	_update_npc_schedules(progress)

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
