class_name RulesEnemy
extends RefCounted
## Six AI contracts, pathfinding, wall-pass, blink, aura (G6 §2 core/).
## Pure deterministic state. No Node, no rendering.

var id: int = 0
var ai_type: int = 0
var hp: int = 14
var max_hp: int = 14
var pos_x: float = 0.0
var pos_y: float = 0.0
var speed: int = 100
var contact_dmg: int = 10
var wall_pass: bool = false
var contact_tick_counter: int = 0
var fire_cooldown_ticks: int = 0
var blink_cooldown_ticks: int = 0
var no_los_ticks: int = 0
var alive: bool = true
var generator_id: int = -1  # -1 = scripted spawn (Death)

func setup_from_def(ed: EnemyDef, eid: int) -> void:
	id = eid
	ai_type = ed.ai_type
	hp = ed.hp
	max_hp = ed.hp
	speed = ed.speed
	contact_dmg = ed.contact_dmg
	wall_pass = ed.wall_pass

func take_damage(amount: int) -> void:
	hp -= amount
	if hp <= 0:
		hp = 0
		alive = false

func is_dead() -> bool:
	return not alive

func tick_cooldowns() -> void:
	if fire_cooldown_ticks > 0:
		fire_cooldown_ticks -= 1
	if blink_cooldown_ticks > 0:
		blink_cooldown_ticks -= 1
	if contact_tick_counter > 0:
		contact_tick_counter -= 1

func can_contact_damage() -> bool:
	# why: contact damage per 0.5s = 30 ticks at 60Hz
	if contact_tick_counter > 0:
		return false
	contact_tick_counter = 30
	return true

func can_fire() -> bool:
	return fire_cooldown_ticks <= 0

func start_fire_cooldown(cadence_ticks: int) -> void:
	fire_cooldown_ticks = cadence_ticks

func to_dict() -> Dictionary:
	return {
		"id": id, "ai_type": ai_type, "hp": hp, "pos_x": pos_x, "pos_y": pos_y,
		"alive": alive, "generator_id": generator_id
	}
