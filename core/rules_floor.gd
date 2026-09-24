class_name RulesFloor
extends RefCounted
## Tile grid, baked entity spawns, seeded PRNG, exit overlap (G6 §2 core/).
## Pure data + deterministic floor logic. No Node, no rendering.

var tiles: PackedStringArray = PackedStringArray()
var grid_w: int = 20
var grid_h: int = 14
var spawn: Vector2i = Vector2i(2, 2)
var exit_pos: Vector2i = Vector2i(17, 2)
var doors: Array = []          # Array[Vector2i]
var foods: Array = []          # Array[Vector2i]
var keys: Array = []           # Array[Vector2i]
var potions: Array = []        # Array[Vector2i]
var chests: Array = []         # Array[{x,y,value}]
var generators: Array = []     # Array[{x,y,enemy_type}]
var initial_enemies: Array = [] # Array[{x,y,type}]
var hazards: Array = []        # Array[{type,tiles,phase}]
var floor_number: int = 1
var drain_hp_per_sec: float = 2.0
var target_seconds: int = 135
var chest_total: int = 0
var generator_hp: int = 60
var generator_cadence_ticks: int = 180

func setup_from_floor_data(fd: FloorData) -> void:
	tiles = fd.tiles.duplicate()
	grid_w = 20
	grid_h = 14
	spawn = fd.spawn
	exit_pos = fd.exit_pos
	floor_number = fd.floor_number
	drain_hp_per_sec = fd.drain_hp_per_sec
	target_seconds = fd.target_seconds
	chest_total = fd.chest_total
	generator_hp = fd.generator_hp
	generator_cadence_ticks = fd.generator_cadence_ticks
	doors = _unpack_vec_array(fd.doors)
	foods = _unpack_vec_array(fd.foods)
	keys = _unpack_vec_array(fd.keys)
	potions = _unpack_vec_array(fd.potions)
	chests = fd.chests.duplicate(true)
	generators = fd.generators.duplicate(true)
	initial_enemies = fd.initial_enemies.duplicate(true)
	hazards = fd.hazards.duplicate(true)

func _unpack_vec_array(packed: PackedVector2Array) -> Array:
	var out: Array = []
	for v in packed:
		out.append(v)
	return out

func tile_at(x: int, y: int) -> int:
	# why: returns StateEnums.Tile code; out-of-bounds = WALL
	if x < 0 or x >= grid_w or y < 0 or y >= grid_h:
		return StateEnums.Tile.WALL
	if y >= tiles.size():
		return StateEnums.Tile.WALL
	var row: String = tiles[y]
	if x >= row.length():
		return StateEnums.Tile.WALL
	var c: String = row[x]
	match c:
		"#": return StateEnums.Tile.WALL
		".": return StateEnums.Tile.FLOOR
		"D": return StateEnums.Tile.DOOR
		"X": return StateEnums.Tile.EXIT
		"V": return StateEnums.Tile.VOID
		_: return StateEnums.Tile.WALL

func is_walkable(x: int, y: int, door_open: bool) -> bool:
	var t: int = tile_at(x, y)
	if t == StateEnums.Tile.FLOOR or t == StateEnums.Tile.EXIT:
		return true
	if t == StateEnums.Tile.DOOR and door_open:
		return true
	return false

func is_wall(x: int, y: int) -> bool:
	return tile_at(x, y) == StateEnums.Tile.WALL

func has_line_of_sight(x0: int, y0: int, x1: int, y1: int) -> bool:
	# why: Bresenham line; walls block LOS. Used by Sorcerer blink + Lobber.
	var dx: int = abs(x1 - x0)
	var dy: int = abs(y1 - y0)
	var sx: int = 1 if x0 < x1 else -1
	var sy: int = 1 if y0 < y1 else -1
	var err: int = dx - dy
	var cx: int = x0
	var cy: int = y0
	while true:
		if cx == x1 and cy == y1:
			return true
		if not (cx == x0 and cy == y0) and is_wall(cx, cy):
			return false
		var e2: int = 2 * err
		if e2 > -dy:
			err -= dy
			cx += sx
		if e2 < dx:
			err += dx
			cy += sy
	return true

func find_nearest_walkable(x: int, y: int) -> Vector2i:
	# why: collapsing-void bounce — teleport to nearest valid tile if none adjacent.
	if is_walkable(x, y, true):
		return Vector2i(x, y)
	for radius in range(1, max(grid_w, grid_h)):
		for dy in range(-radius, radius + 1):
			for dx in range(-radius, radius + 1):
				if abs(dx) != radius and abs(dy) != radius:
					continue
				var nx: int = x + dx
				var ny: int = y + dy
				if is_walkable(nx, ny, true):
					return Vector2i(nx, ny)
	return spawn

func pixel_to_tile(px: float, py: float, tile_size: int) -> Vector2i:
	return Vector2i(int(px) / tile_size, int(py) / tile_size)

func tile_to_pixel(tx: int, ty: int, tile_size: int) -> Vector2:
	return Vector2(tx * tile_size + tile_size / 2, ty * tile_size + tile_size / 2)
