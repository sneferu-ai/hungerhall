class_name RulesPlayer
extends RefCounted
## HP drain, 8-way movement, facing, throw, potion, class kits (G6 §2 core/).
## Pure deterministic state. No Node, no Input.

var hp: int = 800
var max_hp: int = 800
var pos_x: float = 80.0
var pos_y: float = 80.0
var facing: Vector2 = Vector2(0, 1)  # default S
var class_type: int = 0
var speed: int = 128
var shot_dmg: int = 50
var shot_range_tiles: int = 5
var shot_rate_per_sec: float = 1.2
var projectile_kind: String = "axe"
var potion_type: int = 0
var potions: int = 0
var keys: int = 0
var throw_cooldown_ticks: int = 0
var invuln_ticks: int = 0
var aegis_ticks: int = 0
var contact_reduction_fraction: float = 1.0  # 1.0 = full damage; Valkyrie Aegis = 0.5
var moving: bool = false
var move_dir: Vector2 = Vector2.ZERO

func setup_from_class_def(cd: ClassDef) -> void:
	class_type = cd.class_type
	max_hp = cd.hp
	hp = cd.hp
	speed = cd.speed
	shot_dmg = cd.shot_dmg
	shot_range_tiles = cd.shot_range_tiles
	shot_rate_per_sec = cd.shot_rate_per_sec
	projectile_kind = cd.projectile_kind
	potion_type = cd.potion_type

func throw_ready() -> bool:
	return throw_cooldown_ticks <= 0

func start_throw_cooldown() -> void:
	# why: cooldown in ticks = 60 / rate_per_sec
	throw_cooldown_ticks = int(60.0 / shot_rate_per_sec)
	if throw_cooldown_ticks < 1:
		throw_cooldown_ticks = 1

func use_potion() -> bool:
	if potions <= 0:
		return false
	potions -= 1
	return true

func apply_damage(amount: int) -> int:
	# why: returns actual damage applied after reductions
	if invuln_ticks > 0:
		return 0
	var actual: int = int(float(amount) * contact_reduction_fraction)
	hp -= actual
	if hp < 0:
		hp = 0
	return actual

func apply_projectile_damage(amount: int, is_valkyrie_advancing: bool) -> int:
	# why: Valkyrie projectile reduction only while advancing toward threat
	if invuln_ticks > 0 or aegis_ticks > 0:
		return 0
	var actual: int = amount
	if class_type == StateEnums.ClassType.VALKYRIE and is_valkyrie_advancing:
		actual = int(float(amount) * 0.5)
	hp -= actual
	if hp < 0:
		hp = 0
	return actual

func heal(amount: int) -> void:
	hp += amount
	if hp > max_hp:
		hp = max_hp

func is_dead() -> bool:
	return hp <= 0

func set_facing(dx: float, dy: float) -> void:
	if dx == 0 and dy == 0:
		return
	facing = Vector2(dx, dy).normalized()

func tick_cooldowns() -> void:
	if throw_cooldown_ticks > 0:
		throw_cooldown_ticks -= 1
	if invuln_ticks > 0:
		invuln_ticks -= 1
	if aegis_ticks > 0:
		aegis_ticks -= 1
		if aegis_ticks == 0:
			contact_reduction_fraction = 1.0

func to_dict() -> Dictionary:
	return {
		"hp": hp, "max_hp": max_hp, "pos_x": pos_x, "pos_y": pos_y,
		"facing": [facing.x, facing.y], "class_type": class_type,
		"speed": speed, "potions": potions, "keys": keys,
		"throw_cooldown_ticks": throw_cooldown_ticks,
		"invuln_ticks": invuln_ticks, "aegis_ticks": aegis_ticks
	}
