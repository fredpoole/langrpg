class_name World
extends Node2D
## Builds the overworld from the text maps in ROOMS. Each room is one screen,
## like a classic top-down adventure. Edit the maps to change the world.
##
## Map legend:
##   .  grass        ,  flowers      =  path
##   T  tree*        ~  water*       #  rock*        H  house roof*
##   P  player start (on grass)
##   A-E  NPCs from the NPCS table (on grass)
##   * = solid
## Neighbouring rooms must leave matching gaps in their edges so the player can walk between them.

const TILE: int = 16
const ROOM_W: int = 16
const ROOM_H: int = 11
const ROOM_SIZE: Vector2 = Vector2(ROOM_W * TILE, ROOM_H * TILE)

const TILE_CHARS: String = ".,=T~#H"
const SOLID_CHARS: String = "T~#H"

const NPC_SCENE: PackedScene = preload("res://scenes/npc.tscn")

const ROOM_NAMES: Dictionary = {
	Vector2i(0, 0): "Meadow",
	Vector2i(1, 0): "Village",
	Vector2i(2, 0): "Lake",
	Vector2i(0, 1): "Rocky Hills",
	Vector2i(1, 1): "Crossroads",
	Vector2i(2, 1): "Flower Field",
}

const ROOMS: Dictionary = {
	Vector2i(0, 0): [
		"TTTTTTTTTTTTTTTT",
		"T..,.....T.....T",
		"T....TT.....,..T",
		"T....TT........T",
		"T.......P.......",
		"T..,......======",
		"T...............",
		"T..T......,....T",
		"T.......=......T",
		"T.......=....T.T",
		"TTTTTTT..TTTTTTT",
	],
	Vector2i(1, 0): [
		"TTTTTTTTTTTTTTTT",
		"T.HHH....HHH...T",
		"T.HHH....HHH...T",
		"T...A..........T",
		"................",
		"================",
		"................",
		"T.....B........T",
		"T..,....=...,..T",
		"T.......=......T",
		"TTTTTTT..TTTTTTT",
	],
	Vector2i(2, 0): [
		"TTTTTTTTTTTTTTTT",
		"T..............T",
		"T...~~~~~~~....T",
		"T..~~~~~~~~~...T",
		"...~~~~~~~~~~..T",
		"====~~~~~~~~~..T",
		"....~~~~~~~...CT",
		"T....~~~~~.....T",
		"T..............T",
		"T.......=......T",
		"TTTTTTT..TTTTTTT",
	],
	Vector2i(0, 1): [
		"TTTTTTT..TTTTTTT",
		"T.......=......T",
		"T.##....=...##.T",
		"T.#.....=....#.T",
		"T.......=.......",
		"T.......========",
		"T..#............",
		"T........##....T",
		"T.##.....#.....T",
		"T..............T",
		"TTTTTTTTTTTTTTTT",
	],
	Vector2i(1, 1): [
		"TTTTTTT..TTTTTTT",
		"T.......=......T",
		"T..,....=....,.T",
		"T.......=......T",
		"........=.......",
		"================",
		"......D.........",
		"T.....,........T",
		"T...T......T...T",
		"T..............T",
		"TTTTTTTTTTTTTTTT",
	],
	Vector2i(2, 1): [
		"TTTTTTT..TTTTTTT",
		"T,.,.,..=.,.,.,T",
		"T.,.,.,.=,.,.,.T",
		"T,.,.,..=.,.,.,T",
		"........=..,.,.T",
		"=========...E..T",
		".,.,.,.,.,.,.,.T",
		"T.,.,.,.,.,.,.,T",
		"T,.,.,.,.,.,.,.T",
		"T.,.,.,.,.,.,.,T",
		"TTTTTTTTTTTTTTTT",
	],
}

## Placeholder dialogue: each line is followed by its English meaning.
const NPCS: Dictionary = {
	"A": {
		"name": "Ana",
		"color": Color(0.8, 0.3, 0.5),
		"lines": ["¡Hola! Me llamo Ana.", "(Hello! My name is Ana.)", "Bienvenido al pueblo.", "(Welcome to the village.)"],
	},
	"B": {
		"name": "Beto",
		"color": Color(0.3, 0.45, 0.85),
		"lines": ["Buenos días. ¿Cómo estás?", "(Good morning. How are you?)"],
	},
	"C": {
		"name": "Carmen",
		"color": Color(0.9, 0.55, 0.2),
		"lines": ["El lago es muy bonito.", "(The lake is very pretty.)"],
	},
	"D": {
		"name": "Diego",
		"color": Color(0.55, 0.35, 0.75),
		"lines": ["Norte, sur, este, oeste.", "(North, south, east, west.)", "El pueblo está al norte.", "(The village is to the north.)"],
	},
	"E": {
		"name": "Elena",
		"color": Color(0.85, 0.8, 0.3),
		"lines": ["Me gustan las flores.", "(I like flowers.)"],
	},
}

var player_spawn: Vector2 = Vector2.ZERO
var _ground: TileMapLayer


func _ready() -> void:
	_ground = TileMapLayer.new()
	_ground.name = "Ground"
	_ground.tile_set = _build_tileset()
	add_child(_ground)
	for room: Vector2i in ROOMS:
		_build_room(room, ROOMS[room])


func room_at(world_position: Vector2) -> Vector2i:
	return Vector2i(floori(world_position.x / ROOM_SIZE.x), floori(world_position.y / ROOM_SIZE.y))


func room_origin(room: Vector2i) -> Vector2:
	return Vector2(room) * ROOM_SIZE


func room_name(room: Vector2i) -> String:
	return ROOM_NAMES.get(room, "???")


func _build_room(room: Vector2i, rows: Array) -> void:
	assert(rows.size() == ROOM_H, "Room %s needs %d rows" % [room, ROOM_H])
	for y in ROOM_H:
		var row: String = rows[y]
		assert(row.length() == ROOM_W, "Room %s row %d needs %d characters" % [room, y, ROOM_W])
		for x in ROOM_W:
			var cell := Vector2i(room.x * ROOM_W + x, room.y * ROOM_H + y)
			var ch: String = row[x]
			var tile_index: int = TILE_CHARS.find(ch)
			if tile_index == -1:
				# Player and NPC markers stand on grass.
				tile_index = 0
				_place_marker(ch, cell)
			_ground.set_cell(cell, 0, Vector2i(tile_index, 0))


func _place_marker(ch: String, cell: Vector2i) -> void:
	var pos: Vector2 = Vector2(cell * TILE) + Vector2(TILE, TILE) / 2.0
	if ch == "P":
		player_spawn = pos
	elif NPCS.has(ch):
		var def: Dictionary = NPCS[ch]
		var npc := NPC_SCENE.instantiate() as NPC
		npc.position = pos
		npc.display_name = def["name"]
		npc.color = def["color"]
		npc.lines.assign(def["lines"])
		add_child(npc)
	else:
		push_warning("Unknown map character '%s' at %s" % [ch, cell])


func _build_tileset() -> TileSet:
	var tile_set := TileSet.new()
	tile_set.tile_size = Vector2i(TILE, TILE)
	tile_set.add_physics_layer()

	var image := Image.create_empty(TILE * TILE_CHARS.length(), TILE, false, Image.FORMAT_RGBA8)
	for i in TILE_CHARS.length():
		_paint_tile(image, Vector2i(i * TILE, 0), TILE_CHARS[i])

	var source := TileSetAtlasSource.new()
	source.texture = ImageTexture.create_from_image(image)
	source.texture_region_size = Vector2i(TILE, TILE)
	tile_set.add_source(source, 0)

	var half: float = TILE / 2.0
	var square := PackedVector2Array([
		Vector2(-half, -half), Vector2(half, -half), Vector2(half, half), Vector2(-half, half),
	])
	for i in TILE_CHARS.length():
		var coords := Vector2i(i, 0)
		source.create_tile(coords)
		if SOLID_CHARS.contains(TILE_CHARS[i]):
			var data: TileData = source.get_tile_data(coords, 0)
			data.add_collision_polygon(0)
			data.set_collision_polygon_points(0, 0, square)
	return tile_set


# Placeholder art: each tile is painted with simple shapes until real sprites go in assets/.
func _paint_tile(image: Image, origin: Vector2i, ch: String) -> void:
	var full := Rect2i(origin, Vector2i(TILE, TILE))
	match ch:
		".":
			_paint_grass(image, origin)
		",":
			_paint_grass(image, origin)
			for p: Vector2i in [Vector2i(3, 4), Vector2i(11, 3), Vector2i(7, 11), Vector2i(13, 12)]:
				image.set_pixelv(origin + p, Color(1, 1, 1))
				image.set_pixelv(origin + p + Vector2i(1, 0), Color(1, 0.85, 0.2))
		"=":
			image.fill_rect(full, Color(0.85, 0.72, 0.47))
			_speckle(image, origin, Color(0.74, 0.6, 0.38))
		"T":
			_paint_grass(image, origin)
			image.fill_rect(Rect2i(origin + Vector2i(6, 11), Vector2i(4, 5)), Color(0.42, 0.26, 0.13))
			_disc(image, origin, Vector2(8, 6.5), 6.5, Color(0.12, 0.42, 0.18))
			_disc(image, origin, Vector2(6, 4.5), 2.5, Color(0.2, 0.55, 0.25))
		"~":
			image.fill_rect(full, Color(0.23, 0.44, 0.85))
			for p: Vector2i in [Vector2i(2, 3), Vector2i(9, 7), Vector2i(4, 12)]:
				image.fill_rect(Rect2i(origin + p, Vector2i(4, 1)), Color(0.55, 0.72, 0.98))
		"#":
			_paint_grass(image, origin)
			_disc(image, origin, Vector2(8, 9), 6.5, Color(0.45, 0.45, 0.48))
			_disc(image, origin, Vector2(7, 7), 3.5, Color(0.62, 0.62, 0.65))
		"H":
			image.fill_rect(full, Color(0.71, 0.28, 0.23))
			for y in range(3, TILE, 4):
				image.fill_rect(Rect2i(origin + Vector2i(0, y), Vector2i(TILE, 1)), Color(0.5, 0.18, 0.15))


func _paint_grass(image: Image, origin: Vector2i) -> void:
	image.fill_rect(Rect2i(origin, Vector2i(TILE, TILE)), Color(0.29, 0.61, 0.25))
	_speckle(image, origin, Color(0.22, 0.5, 0.2))


func _speckle(image: Image, origin: Vector2i, color: Color) -> void:
	for p: Vector2i in [Vector2i(3, 2), Vector2i(12, 5), Vector2i(6, 9), Vector2i(14, 13), Vector2i(1, 14), Vector2i(9, 1)]:
		image.set_pixelv(origin + p, color)


func _disc(image: Image, origin: Vector2i, center: Vector2, radius: float, color: Color) -> void:
	for y in TILE:
		for x in TILE:
			if Vector2(x + 0.5, y + 0.5).distance_to(center) <= radius:
				image.set_pixel(origin.x + x, origin.y + y, color)
