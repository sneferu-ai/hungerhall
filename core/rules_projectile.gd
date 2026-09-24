class_name RulesProjectile
extends RefCounted
## Movement, collision, pierce/splash, faction mask (G6 §2 core/).

var id: int = 0
var faction: int = 0  # 0 = player, 1 = enemy
var pos_x: float = 0.0
var pos_y: float = 0.0
var vel_x: float = 0.0
var vel_y: float = 0.0
var dmg: int = 0
var range_px: float = 0.0
var traveled_px: float = 0.0
var pierces: bool = false
var splash_dmg: int = 0
var splash_radius_tiles: int = 0
var kind: String = "axe"
var alive: bool = true
var ignores_walls: bool = false
var hit_entities: Array = []  # entity ids already hit (for pierce)

func setup(fid: int, x: float, y: float, dx: float, dy: float, p_speed: float, p_dmg: int, p_range_tiles: int, tile_size: int, p_kind: String) -> void:
	id = fid
	faction = 0
	pos_x = x
	pos_y = y
	var norm: Vector2 = Vector2(dx, dy)
	if norm.length() > 0:
		norm = norm.normalized()
	vel_x = norm.x * p_speed
	vel_y = norm.y * p_speed
	dmg = p_dmg
	range_px = float(p_range_tiles * tile_size)
	kind = p_kind
	pierces = (p_kind == "axe")
	ignores_walls = false

func setup_enemy(fid: int, x: float, y: float, dx: float, dy: float, p_speed: float, p_dmg: int, p_kind: String, p_ignores_walls: bool) -> void:
	id = fid
	faction = 1
	pos_x = x
	pos_y = y
	var norm: Vector2 = Vector2(dx, dy)
	if norm.length() > 0:
		norm = norm.normalized()
	vel_x = norm.x * p_speed
	vel_y = norm.y * p_speed
	dmg = p_dmg
	range_px = 999999.0  # why: enemy projectiles despawn on hit/wall, not range
	kind = p_kind
	pierces = false
	ignores_walls = p_ignores_walls

func tick(tile_size: int, floor: RulesFloor) -> Dictionary:
	# why: returns {"wall_hit": bool, "new_pos": [x,y]} — caller handles collision
	var prev_x: float = pos_x
	var prev_y: float = pos_y
	pos_x += vel_x / 60.0
	pos_y += vel_y / 60.0
	traveled_px += Vector2(vel_x, vel_y).length() / 60.0
	if traveled_px >= range_px:
		alive = false
		return {"wall_hit": false, "new_pos": [pos_x, pos_y]}
	if not ignores_walls:
		var tile: Vector2i = floor.pixel_to_tile(pos_x, pos_y, tile_size)
		if floor.is_wall(tile.x, tile.y):
			alive = false
			return {"wall_hit": true, "new_pos": [prev_x, prev_y]}
	return {"wall_hit": false, "new_pos": [pos_x, pos_y]}

func is_dead() -> bool:
	return not alive

func to_dict() -> Dictionary:
	return {
		"id": id, "faction": faction, "pos_x": pos_x, "pos_y": pos_y,
		"kind": kind, "alive": alive
	}
