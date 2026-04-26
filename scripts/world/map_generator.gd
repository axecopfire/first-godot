class_name MapGenerator
extends RefCounted

## Builds the village map procedurally. Extracted from main.gd so map composition
## stays in one place and main.gd remains a scene compositor.
##
## See docs/general/MAP_PLAN.md for the layout plan and docs/places/village.md
## for the narrative description.

const TILE_SIZE := 16
const MAP_W := 90
const MAP_H := 50

enum Tile { GRASS, DIRT, COBBLE, WOOD, WALL, WATER }

const TILE_COUNT := 6

# Building / zone rectangles in tile coordinates (Rect2i x,y,w,h).
# Used for suspicion modifiers (Step 10) and NPC placement.
const ZONES := {
	"market": Rect2i(38, 20, 25, 14),       # plaza cobble
	"alley": Rect2i(48, 4, 5, 16),          # north alley (start)
	"church": Rect2i(26, 4, 9, 9),
	"workshop": Rect2i(36, 5, 8, 7),
	"school": Rect2i(55, 5, 9, 7),
	"tailor": Rect2i(41, 14, 6, 5),
	"blacksmith": Rect2i(36, 36, 8, 7),
	"mill": Rect2i(53, 36, 8, 7),
	"warehouse": Rect2i(67, 21, 11, 9),
	"barracks": Rect2i(67, 31, 9, 9),
	"manor_courtyard": Rect2i(4, 22, 12, 11),
	"manor_house": Rect2i(7, 24, 6, 6),
	"fields": Rect2i(16, 30, 22, 16),
}

# Suspicion rate per zone (per second). Negative reduces suspicion.
# Wired to the suspicion system in a later step (DEV_PLAN Step 3).
const ZONE_SUSPICION := {
	"market": 1.5,
	"alley": 0.0,
	"church": -0.5,
	"workshop": 0.0,
	"school": 0.0,
	"tailor": 0.0,
	"blacksmith": 0.0,
	"mill": 0.0,
	"warehouse": 1.0,
	"barracks": 2.0,
	"manor_courtyard": 1.0,
	"manor_house": 1.0,
	"fields": 0.3,
}

var tile_textures: Array[Texture2D] = []
var map_data: Array = []
var player_spawn: Vector2 = Vector2.ZERO
var manor_gate_tile: Vector2i = Vector2i(15, 27)

func build(parent: Node2D) -> void:
	_load_textures()
	_generate_map()
	_draw_map(parent)
	_place_market_stalls(parent)
	_place_decorations(parent)
	_build_walls(parent)
	_build_water_collisions(parent)
	_build_manor_gate(parent)

func get_zone_at(world_pos: Vector2) -> String:
	var tx := int(world_pos.x / TILE_SIZE)
	var ty := int(world_pos.y / TILE_SIZE)
	var pt := Vector2i(tx, ty)
	for zone_name in ZONES:
		if ZONES[zone_name].has_point(pt):
			return zone_name
	return ""

func _load_textures() -> void:
	var tiles_img := Image.load_from_file("res://textures/tiles.png")
	for i in range(TILE_COUNT):
		var tile_img := Image.create(TILE_SIZE, TILE_SIZE, false, Image.FORMAT_RGBA8)
		tile_img.blit_rect(tiles_img, Rect2i(i * TILE_SIZE, 0, TILE_SIZE, TILE_SIZE), Vector2i.ZERO)
		tile_textures.append(ImageTexture.create_from_image(tile_img))

func _generate_map() -> void:
	# Initialize all tiles as grass.
	map_data.resize(MAP_H)
	for y in range(MAP_H):
		map_data[y] = []
		map_data[y].resize(MAP_W)
		for x in range(MAP_W):
			map_data[y][x] = Tile.GRASS

	# Market square (cobble plaza).
	_fill_rect(ZONES["market"], Tile.COBBLE)

	# Wood floors under stall areas inside the plaza.
	for r in [
		Rect2i(40, 22, 4, 3),
		Rect2i(54, 22, 4, 3),
		Rect2i(40, 30, 4, 3),
		Rect2i(54, 30, 4, 3),
	]:
		_fill_rect(r, Tile.WOOD)

	# Starting alley (cobble corridor with stone walls on either side).
	_fill_rect(Rect2i(49, 4, 3, 16), Tile.COBBLE)
	for y in range(4, 18):
		map_data[y][48] = Tile.WALL
		map_data[y][52] = Tile.WALL

	# Paths radiating from the plaza.
	_fill_rect(Rect2i(49, 33, 3, 5), Tile.DIRT)         # south path toward smithy/mill
	_fill_rect(Rect2i(63, 24, 5, 4), Tile.DIRT)         # warehouse lane (east)
	_fill_rect(Rect2i(15, 26, 23, 3), Tile.DIRT)        # west road across fields
	_fill_rect(Rect2i(67, 29, 11, 2), Tile.DIRT)        # alley behind warehouse/barracks

	# Building shells.
	_place_building(ZONES["church"], Vector2i(30, 12), Tile.WOOD)
	_place_building(ZONES["workshop"], Vector2i(39, 11), Tile.WOOD)
	_place_building(ZONES["school"], Vector2i(59, 11), Tile.WOOD)
	_place_building(ZONES["tailor"], Vector2i(46, 16), Tile.WOOD)
	# Tailor back door (north) into church garden.
	map_data[14][43] = Tile.DIRT
	_place_building(ZONES["blacksmith"], Vector2i(39, 36), Tile.WOOD)
	_place_building(ZONES["mill"], Vector2i(56, 36), Tile.WOOD)
	_place_building(ZONES["warehouse"], Vector2i(67, 25), Tile.WOOD)
	# Warehouse back exit east into the alley.
	map_data[28][77] = Tile.WOOD
	_place_building(ZONES["barracks"], Vector2i(67, 35), Tile.WOOD)

	# Church herb garden behind the church (small grass patch).
	_fill_rect(Rect2i(28, 1, 5, 3), Tile.GRASS)

	# Manor compound: outer wall with a gate (initially closed).
	_place_building(ZONES["manor_courtyard"], manor_gate_tile, Tile.COBBLE)
	# Manor house inside the courtyard.
	_place_building(ZONES["manor_house"], Vector2i(9, 29), Tile.WOOD)

	# Fields: scatter dirt-path dividers between crop plots and a low pasture wall.
	for x in range(16, 38):
		map_data[37][x] = Tile.DIRT  # pasture divider path
	for x in range(20, 36):
		map_data[42][x] = Tile.WALL  # low stone wall separating pasture

	# Acequia (water channel): from north edge, into church garden, around the
	# plaza, then south-east to power the mill waterwheel.
	for y in range(0, 14):
		map_data[y][45] = Tile.WATER
	for x in range(45, 50):
		map_data[14][x] = Tile.WATER
	# Bridge over the alley (wood plank) so the player can cross.
	map_data[14][49] = Tile.WOOD
	# Plaza fountain feed enters at the north of the plaza.
	map_data[19][49] = Tile.WATER
	# Outflow from south plaza toward the mill.
	for y in range(33, 38):
		map_data[y][53] = Tile.WATER
	for x in range(53, 60):
		map_data[37][x] = Tile.WATER
	# Bridge across the south path so the player can still reach the smithy/mill.
	map_data[35][53] = Tile.DIRT
	# Acequia branches feeding the fields.
	for x in range(16, 38):
		map_data[24][x] = Tile.WATER
	# Bridge across the west road where it meets the field acequia.
	map_data[26][24] = Tile.DIRT

	# Player spawn: top of the alley facing south.
	player_spawn = Vector2((50 + 0.5) * TILE_SIZE, (5 + 0.5) * TILE_SIZE)

func _fill_rect(r: Rect2i, t: int) -> void:
	for y in range(r.position.y, r.position.y + r.size.y):
		if y < 0 or y >= MAP_H:
			continue
		for x in range(r.position.x, r.position.x + r.size.x):
			if x < 0 or x >= MAP_W:
				continue
			map_data[y][x] = t

func _place_building(r: Rect2i, door: Vector2i, floor_tile: int) -> void:
	# Walls on the perimeter, floor inside, then carve the door.
	var x1 := r.position.x
	var y1 := r.position.y
	var x2 := r.position.x + r.size.x - 1
	var y2 := r.position.y + r.size.y - 1
	for x in range(x1, x2 + 1):
		map_data[y1][x] = Tile.WALL
		map_data[y2][x] = Tile.WALL
	for y in range(y1, y2 + 1):
		map_data[y][x1] = Tile.WALL
		map_data[y][x2] = Tile.WALL
	for y in range(y1 + 1, y2):
		for x in range(x1 + 1, x2):
			map_data[y][x] = floor_tile
	# Carve doorway tile (becomes floor so the player can walk through).
	if door.y >= 0 and door.y < MAP_H and door.x >= 0 and door.x < MAP_W:
		map_data[door.y][door.x] = floor_tile

func _draw_map(parent: Node2D) -> void:
	var map_node := Node2D.new()
	map_node.name = "Map"
	parent.add_child(map_node)

	for y in range(MAP_H):
		for x in range(MAP_W):
			var sprite := Sprite2D.new()
			sprite.texture = tile_textures[map_data[y][x]]
			sprite.position = Vector2(x * TILE_SIZE, y * TILE_SIZE)
			sprite.centered = false
			sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			map_node.add_child(sprite)

func _place_market_stalls(parent: Node2D) -> void:
	var stall_tex := ImageTexture.create_from_image(Image.load_from_file("res://textures/market_stall.png"))
	var stall_positions := [
		Vector2(40, 22), Vector2(54, 22),
		Vector2(40, 30), Vector2(54, 30),
	]

	var stalls := Node2D.new()
	stalls.name = "Stalls"
	parent.add_child(stalls)

	for pos in stall_positions:
		var spr := Sprite2D.new()
		spr.texture = stall_tex
		spr.position = Vector2(pos.x * TILE_SIZE, pos.y * TILE_SIZE)
		spr.centered = false
		spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		stalls.add_child(spr)

		var body := StaticBody2D.new()
		body.position = Vector2(pos.x * TILE_SIZE + 24, pos.y * TILE_SIZE + 14)
		body.collision_layer = 4
		body.collision_mask = 0
		var shape := CollisionShape2D.new()
		var rect := RectangleShape2D.new()
		rect.size = Vector2(44, 8)
		shape.shape = rect
		body.add_child(shape)
		stalls.add_child(body)

func _place_decorations(parent: Node2D) -> void:
	var barrel_tex := ImageTexture.create_from_image(Image.load_from_file("res://textures/barrel.png"))
	var crate_tex := ImageTexture.create_from_image(Image.load_from_file("res://textures/crate.png"))
	var well_tex := ImageTexture.create_from_image(Image.load_from_file("res://textures/well.png"))
	var fountain_tex := ImageTexture.create_from_image(Image.load_from_file("res://textures/fountain.png"))

	var decor := Node2D.new()
	decor.name = "Decorations"
	parent.add_child(decor)

	# Plaza fountain.
	_add_decor(decor, fountain_tex, Vector2(49 * TILE_SIZE, 26 * TILE_SIZE))
	var fb := StaticBody2D.new()
	fb.position = Vector2(49 * TILE_SIZE, 26 * TILE_SIZE)
	fb.collision_layer = 4
	fb.collision_mask = 0
	var fs := CollisionShape2D.new()
	var fc := CircleShape2D.new()
	fc.radius = 14
	fs.shape = fc
	fb.add_child(fs)
	decor.add_child(fb)

	# Barrels around the plaza and warehouse.
	for bpos in [
		Vector2(39, 23), Vector2(46, 22), Vector2(53, 23),
		Vector2(60, 22), Vector2(39, 32), Vector2(46, 31), Vector2(60, 31),
		Vector2(70, 23), Vector2(75, 23), Vector2(70, 27), Vector2(75, 27),
	]:
		var p: Vector2 = bpos * TILE_SIZE
		_add_decor_col(decor, barrel_tex, p, Vector2(10, 12))

	# Crates at plaza corners and warehouse interior.
	for cpos in [
		Vector2(38, 21), Vector2(61, 21), Vector2(38, 32), Vector2(61, 32),
		Vector2(72, 25), Vector2(74, 25),
	]:
		var p: Vector2 = cpos * TILE_SIZE
		_add_decor_col(decor, crate_tex, p, Vector2(12, 12))

	# Manor courtyard well.
	_add_decor(decor, well_tex, Vector2(10 * TILE_SIZE, 26 * TILE_SIZE))
	var wb := StaticBody2D.new()
	wb.position = Vector2(10 * TILE_SIZE, 26 * TILE_SIZE)
	wb.collision_layer = 4
	wb.collision_mask = 0
	var ws := CollisionShape2D.new()
	var wc := CircleShape2D.new()
	wc.radius = 10
	ws.shape = wc
	wb.add_child(ws)
	decor.add_child(wb)

func _add_decor(parent: Node2D, tex: Texture2D, pos: Vector2) -> void:
	var spr := Sprite2D.new()
	spr.texture = tex
	spr.position = pos
	spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	parent.add_child(spr)

func _add_decor_col(parent: Node2D, tex: Texture2D, pos: Vector2, col_size: Vector2) -> void:
	_add_decor(parent, tex, pos)
	var body := StaticBody2D.new()
	body.position = pos
	body.collision_layer = 4
	body.collision_mask = 0
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = col_size
	shape.shape = rect
	body.add_child(shape)
	parent.add_child(body)

func _build_walls(parent: Node2D) -> void:
	var walls := Node2D.new()
	walls.name = "Walls"
	parent.add_child(walls)

	# Outer map boundary.
	var map_px_w := MAP_W * TILE_SIZE
	var map_px_h := MAP_H * TILE_SIZE
	_add_wall(walls, Vector2(map_px_w / 2.0, -4), Vector2(map_px_w, 8))
	_add_wall(walls, Vector2(map_px_w / 2.0, map_px_h + 4), Vector2(map_px_w, 8))
	_add_wall(walls, Vector2(-4, map_px_h / 2.0), Vector2(8, map_px_h))
	_add_wall(walls, Vector2(map_px_w + 4, map_px_h / 2.0), Vector2(8, map_px_h))

	# Per-tile walls for every WALL tile on the map.
	for y in range(MAP_H):
		for x in range(MAP_W):
			if map_data[y][x] == Tile.WALL:
				_add_wall(walls,
					Vector2(x * TILE_SIZE + TILE_SIZE / 2.0, y * TILE_SIZE + TILE_SIZE / 2.0),
					Vector2(TILE_SIZE, TILE_SIZE))

func _build_water_collisions(parent: Node2D) -> void:
	# Water tiles block movement unless a bridge tile (WOOD/DIRT) is placed.
	var water := Node2D.new()
	water.name = "Water"
	parent.add_child(water)
	for y in range(MAP_H):
		for x in range(MAP_W):
			if map_data[y][x] == Tile.WATER:
				_add_wall(water,
					Vector2(x * TILE_SIZE + TILE_SIZE / 2.0, y * TILE_SIZE + TILE_SIZE / 2.0),
					Vector2(TILE_SIZE, TILE_SIZE))

func _build_manor_gate(parent: Node2D) -> void:
	# The manor gate is closed at start; unlocking it is a future gameplay mechanic.
	var gate := StaticBody2D.new()
	gate.name = "ManorGate"
	gate.position = Vector2(
		manor_gate_tile.x * TILE_SIZE + TILE_SIZE / 2.0,
		manor_gate_tile.y * TILE_SIZE + TILE_SIZE / 2.0)
	gate.collision_layer = 2
	gate.collision_mask = 0
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(TILE_SIZE, TILE_SIZE)
	shape.shape = rect
	gate.add_child(shape)
	parent.add_child(gate)

func _add_wall(parent: Node2D, pos: Vector2, size: Vector2) -> void:
	var body := StaticBody2D.new()
	body.position = pos
	body.collision_layer = 2
	body.collision_mask = 0
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = size
	shape.shape = rect
	body.add_child(shape)
	parent.add_child(body)
