class_name RulesGenerator
extends RefCounted
## Cadence bands, per-generator cap 6, per-floor cap 28 (G6 §2 core/).

var id: int = 0
var pos_x: float = 0.0
var pos_y: float = 0.0
var tile_x: int = 0
var tile_y: int = 0
var hp: int = 60
var max_hp: int = 60
var enemy_type: int = 0
var spawn_cadence_ticks: int = 180
var spawn_counter: int = 0
var max_alive_per_generator: int = 6
var alive: bool = true

func setup(gd: GeneratorDef, gid: int, tx: int, ty: int, tile_size: int) -> void:
	id = gid
	tile_x = tx
	tile_y = ty
	pos_x = float(tx * tile_size + tile_size / 2)
	pos_y = float(ty * tile_size + tile_size / 2)
	hp = gd.hp
	max_hp = gd.hp
	enemy_type = gd.enemy_type
	spawn_cadence_ticks = gd.spawn_cadence_ticks
	max_alive_per_generator = gd.max_alive_per_generator
	spawn_counter = spawn_cadence_ticks  # why: first spawn after one cadence

func take_damage(amount: int) -> void:
	hp -= amount
	if hp <= 0:
		hp = 0
		alive = false

func is_dead() -> bool:
	return not alive

func ready_to_spawn(children_alive: int, floor_alive: int, floor_cap: int) -> bool:
	if not alive:
		return false
	if spawn_counter > 0:
		return false
	if children_alive >= max_alive_per_generator:
		return false
	if floor_alive >= floor_cap:
		return false
	return true

func tick() -> void:
	if spawn_counter > 0:
		spawn_counter -= 1

func reset_spawn_counter() -> void:
	spawn_counter = spawn_cadence_ticks

func to_dict() -> Dictionary:
	return {
		"id": id, "hp": hp, "pos_x": pos_x, "pos_y": pos_y,
		"alive": alive, "enemy_type": enemy_type
	}
