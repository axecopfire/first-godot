extends Node2D

## Main scene — composes the village from `MapGenerator` and spawns the player,
## NPCs, items, and HUD on top.

const TILE_SIZE := MapGenerator.TILE_SIZE
var ENABLE_SCHEDULE_DEBUG_UI := OS.is_debug_build()

var world_state: WorldStateManager
var map_generator: MapGenerator
var player: CharacterBody2D
var camera: Camera2D
var inventory_label: Label
var drop_hint_label: Label
var time_label: Label
var schedule_debug_label: Label
var zone_labels: Dictionary = {}
var dev_time_dropdown: OptionButton
var day_night_overlay: ColorRect

func _ready() -> void:
	world_state = WorldStateManager.new()
	world_state.name = "WorldState"
	add_child(world_state)
	world_state.setup_bell_audio()
	map_generator = MapGenerator.new()
	map_generator.build(self)
	_setup_web_keyboard_focus()
	_create_zone_labels()
	_create_player()
	_place_pickup_items()
	_spawn_npcs()
	_setup_npc_dialogues()
	_create_day_night_overlay()
	_create_ui()
	_update_day_night(0.0)
	_update_npc_schedules(0.0, true)

func _setup_web_keyboard_focus() -> void:
	if not OS.has_feature("web"):
		return

	# Keep keyboard focus on the canvas in web exports so movement keys are
	# captured even after clicking around the page UI.
	JavaScriptBridge.eval("""
		(function () {
			if (window.__mm_input_focus_setup) {
				return;
			}
			window.__mm_input_focus_setup = true;

			var canvas = document.getElementById('canvas') || document.querySelector('canvas');
			if (!canvas) {
				return;
			}

			if (canvas.tabIndex < 0) {
				canvas.tabIndex = 0;
			}

			var focusCanvas = function () {
				try {
					canvas.focus({ preventScroll: true });
				} catch (e) {
					canvas.focus();
				}
			};

			window.addEventListener('pointerdown', focusCanvas, { passive: true });
			window.addEventListener('keydown', focusCanvas, { passive: true });
			focusCanvas();
		})();
	""")

func _process(delta: float) -> void:
	world_state.tick(delta)
	var progress := world_state.get_cycle_progress()
	_update_day_night(progress)
	_update_npc_schedules(progress)
	if ENABLE_SCHEDULE_DEBUG_UI:
		_update_schedule_debug_ui(progress)

const _DEV_TIME_PRESETS = ScheduleConfig.DEV_TIME_PRESETS

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
	player.add_child(camera)
	camera.make_current.call_deferred()
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
			"morning_hour": 8,
			"evening_hour": 18,
		},
		{
			"name": "Amina",
			"profession": "Baker",
			"texture": "res://textures/npc_baker.png",
			"pos": Vector2(57, 24),
			"lines": ["Fresh bread! Still warm\nfrom the oven!", "Try my honey cakes,\nbest in the kingdom!", "The secret is in the yeast..."],
			"range": 25.0,
			"morning_hour": 5,
			"evening_hour": 18,
		},
		{
			"name": "Samira",
			"profession": "Herbalist",
			"texture": "res://textures/npc_herbalist.png",
			"pos": Vector2(57, 32),
			"lines": ["Herbs and potions,\ncures for what ails ye!", "This tincture will ward\noff the plague... probably.", "Lavender for luck,\nthyme for truth!"],
			"range": 20.0,
			"morning_hour": 7,
			"evening_hour": 18,
		},
		{
			"name": "Old Hamid",
			"profession": "Herdsman",
			"texture": "res://textures/npc_merchant.png",
			"pos": Vector2(43, 32),
			"lines": ["The goats know me,\nand I know them.", "A donkey will outwork\nany horse, mark my words.", "Mind the smell, friend."],
			"range": 0.0,
			"morning_hour": 6,
			"evening_hour": 18,
		},
		# --- Blacksmith ---
		{
			"name": "Ibrahim",
			"profession": "Blacksmith",
			"texture": "res://textures/npc_blacksmith.png",
			"pos": Vector2(39, 39),
			"lines": ["Need a blade sharpened?", "This steel was forged in\ndragonfire! ...Well, regular fire.", "Watch your fingers\naround the anvil!"],
			"range": 18.0,
			"morning_hour": 7,
			"evening_hour": 18,
		},
		{
			"name": "Tarik",
			"profession": "Apprentice",
			"texture": "res://textures/npc_blacksmith.png",
			"pos": Vector2(41, 35),
			"lines": ["Ibrahim wants me to\nrun another errand.", "The bellows never rest.", "One day I'll forge my own\nblade. One day."],
			"range": 60.0,
			"morning_hour": 7,
			"evening_hour": 18,
		},
		# --- Mill ---
		{
			"name": "Abbas",
			"profession": "Miller",
			"texture": "res://textures/npc_baker.png",
			"pos": Vector2(56, 39),
			"lines": ["The wheel turns,\nthe flour falls.", "Mind the dust — it gets\neverywhere.", "I sing to the stones.\nThey listen better than people."],
			"range": 0.0,
			"morning_hour": 5,
			"evening_hour": 18,
		},
		# --- Warehouse ---
		{
			"name": "Rafiq",
			"profession": "Storekeeper",
			"texture": "res://textures/npc_blacksmith.png",
			"pos": Vector2(72, 25),
			"lines": ["Don't touch the sacks.", "Every grain is counted.", "I see everything in here.\nRemember that."],
			"range": 30.0,
			"morning_hour": 8,
			"evening_hour": 18,
		},
		{
			"name": "Salim",
			"profession": "Porter",
			"texture": "res://textures/npc_merchant.png",
			"pos": Vector2(70, 26),
			"lines": ["Hauling, hauling,\nalways hauling.", "Rafiq counts twice. Then\nhe counts again.", "My back will give out\nbefore the harvest does."],
			"range": 40.0,
			"morning_hour": 7,
			"evening_hour": 18,
		},
		{
			"name": "Nura",
			"profession": "Clerk",
			"texture": "res://textures/npc_merchant.png",
			"pos": Vector2(74, 27),
			"lines": ["The patrol schedule is\non the barracks wall.", "I've memorized every\nguard rotation, you know.", "Don't ask how I know\nwhen they switch."],
			"range": 40.0,
			"morning_hour": 8,
			"evening_hour": 18,
		},
		# --- Barracks ---
		{
			"name": "Capitan Rodrigo",
			"profession": "Captain",
			"texture": "res://textures/npc_blacksmith.png",
			"pos": Vector2(71, 35),
			"lines": ["State your business.", "I keep this village safe.\nDon't get in my way.", "If you fall foul of the law,\nyou'll meet me again."],
			"range": 25.0,
			"morning_hour": 6,
			"evening_hour": 18,
		},
		# --- Church ---
		{
			"name": "Father Domingo",
			"profession": "Priest",
			"texture": "res://textures/npc_baker.png",
			"pos": Vector2(30, 9),
			"lines": ["Peace be upon you,\ntraveler.", "All are welcome at this altar,\nwhatever their tongue.", "Light a candle, rest your feet."],
			"range": 0.0,
			"morning_hour": 6,
			"evening_hour": 18,
		},
		# --- Workshop ---
		{
			"name": "Zahra",
			"profession": "Artisan",
			"texture": "res://textures/npc_herbalist.png",
			"pos": Vector2(40, 8),
			"lines": ["Mind the kiln —\nshe bites.", "Geometry is the language\nof beauty.", "I have books, if you want\nto see worlds beyond this one."],
			"range": 12.0,
			"morning_hour": 8,
			"evening_hour": 18,
		},
		# --- School ---
		{
			"name": "Maestro al-Rashid",
			"profession": "Teacher",
			"texture": "res://textures/npc_merchant.png",
			"pos": Vector2(59, 8),
			"lines": ["The chalkboard remembers\nwhat children forget.", "Every script tells a story.\nWhich is yours?", "Sit. Learn. There is time."],
			"range": 0.0,
			"morning_hour": 7,
			"evening_hour": 18,
		},
		# --- Tailor ---
		{
			"name": "Maryam",
			"profession": "Tailor",
			"texture": "res://textures/npc_herbalist.png",
			"pos": Vector2(43, 16),
			"lines": ["Mind the pins on the floor.", "I work best by lamplight.", "Take this scrap, if it suits.\nWinter is coming."],
			"range": 0.0,
			"morning_hour": 8,
			"evening_hour": 18,
		},
		# --- Fields ---
		{
			"name": "Qadir",
			"profession": "Fieldmaster",
			"texture": "res://textures/npc_blacksmith.png",
			"pos": Vector2(26, 36),
			"lines": ["Idle hands aren't welcome\nin my fields.", "Pick up a sickle or move on.", "The acequia waits for no one."],
			"range": 60.0,
			"morning_hour": 6,
			"evening_hour": 18,
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
		sprite.texture = TextureCache.get_texture(cfg["texture"])
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
		var work_hours := ScheduleConfig.get_npc_work_hours(display_name)
		npc.set_schedule(int(work_hours["morning_hour"]), int(work_hours["evening_hour"]))
		npc.set_home_position(_resolve_npc_home_position(display_name, cfg["pos"]))
		if cfg.has("work_pos"):
			npc.set_work_position(cfg["work_pos"])

		npcs_node.add_child(npc)

func _update_npc_schedules(cycle_progress: float, snap_to_schedule := false) -> void:
	var npcs_node := get_node_or_null("NPCs")
	if npcs_node == null:
		return
	var market_zone: Rect2i = MapGenerator.ZONES.get("market", Rect2i(0, 0, 1, 1))
	var social_hub_position := Vector2(
		(market_zone.position.x + market_zone.size.x * 0.5) * TILE_SIZE,
		(market_zone.position.y + market_zone.size.y * 0.5) * TILE_SIZE
	)
	var world_state_dict := world_state.get_world_state(social_hub_position)

	for npc in npcs_node.get_children():
		if npc.has_method("set_day_cycle_progress"):
			npc.set_day_cycle_progress(cycle_progress, snap_to_schedule, world_state_dict)

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

	if ENABLE_SCHEDULE_DEBUG_UI:
		schedule_debug_label = Label.new()
		schedule_debug_label.name = "ScheduleDebugLabel"
		schedule_debug_label.position = Vector2(10, 78)
		schedule_debug_label.add_theme_font_size_override("font_size", 11)
		schedule_debug_label.add_theme_color_override("font_color", Color(0.85, 1.0, 0.85, 0.95))
		schedule_debug_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
		schedule_debug_label.add_theme_constant_override("shadow_offset_x", 1)
		schedule_debug_label.add_theme_constant_override("shadow_offset_y", 1)
		canvas.add_child(schedule_debug_label)

	dev_time_dropdown = OptionButton.new()
	dev_time_dropdown.name = "DevTimeDropdown"
	dev_time_dropdown.position = Vector2(10, 56)
	dev_time_dropdown.custom_minimum_size = Vector2(210, 0)
	dev_time_dropdown.focus_mode = Control.FOCUS_NONE
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
		time_label.text = "Day %d | %s" % [world_state.day_number, world_state.format_clock_time()]

func _on_dev_time_selected(index: int) -> void:
	if index < 0 or index >= _DEV_TIME_PRESETS.size():
		return

	var preset = _DEV_TIME_PRESETS[index]
	var hour: int = int(preset["hour"])
	_set_time_to_hour(hour)

func _set_time_to_hour(hour: int) -> void:
	world_state.set_time_to_hour(hour)

	var progress := world_state.get_cycle_progress()
	_update_day_night(progress)
	var should_snap_to_home := hour >= 21 or hour < 6
	_update_npc_schedules(progress, should_snap_to_home)
	if ENABLE_SCHEDULE_DEBUG_UI:
		_update_schedule_debug_ui(progress)

func _update_schedule_debug_ui(cycle_progress: float) -> void:
	if not ENABLE_SCHEDULE_DEBUG_UI:
		return

	if schedule_debug_label == null:
		return

	var npcs_node := get_node_or_null("NPCs")
	if npcs_node == null:
		schedule_debug_label.text = "Schedule Debug: NPC node missing"
		return

	var hour: int = int(cycle_progress * 24.0) % 24
	var lines := PackedStringArray(["Schedule Debug (%02d:00)" % [hour]])
	for npc in npcs_node.get_children():
		if npc.has_method("get_schedule_debug_status"):
			lines.append(npc.get_schedule_debug_status(hour))

	schedule_debug_label.text = "\n".join(lines)

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
	if event is InputEventKey:
		var key_event := event as InputEventKey
		if key_event.pressed and not key_event.echo:
			var preset_index := -1
			match key_event.keycode:
				KEY_1:
					preset_index = 0
				KEY_2:
					preset_index = 1
				KEY_3:
					preset_index = 2
				KEY_4:
					preset_index = 3
				KEY_5:
					preset_index = 4
				KEY_6:
					preset_index = 5
				KEY_7:
					preset_index = 6
			if preset_index >= 0 and preset_index < _DEV_TIME_PRESETS.size():
				if dev_time_dropdown != null:
					dev_time_dropdown.select(preset_index)
				var preset = _DEV_TIME_PRESETS[preset_index]
				_set_time_to_hour(int(preset["hour"]))
				get_viewport().set_input_as_handled()
				return

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
