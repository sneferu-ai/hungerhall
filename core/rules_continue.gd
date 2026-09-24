class_name RulesContinue
extends RefCounted
## Continue rebuild contract; token decrement logic (G6 §2 core/).
## Pure deterministic. No Node.

var tokens: int = 2

func reset_for_floor_entry(tunables: TunablesLoader) -> void:
	tokens = tunables.get_int("continue_tokens_per_floor", 2)

func consume() -> bool:
	if tokens <= 0:
		return false
	tokens -= 1
	return true

func has_tokens() -> bool:
	return tokens > 0

## Continue rebuild: player at spawn, HP = 50% class max, potions zeroed,
## keys zeroed, food NOT restored (eaten stays eaten).
static func rebuild_floor(player: RulesPlayer, floor: RulesFloor, class_max_hp: int, tunables: TunablesLoader) -> void:
	var spawn_px: Vector2 = floor.tile_to_pixel(floor.spawn.x, floor.spawn.y, 32)
	player.pos_x = spawn_px.x
	player.pos_y = spawn_px.y
	player.hp = int(float(class_max_hp) * tunables.get_value("continue_hp_fraction", 0.5))
	player.potions = 0
	player.keys = 0
	player.invuln_ticks = 18  # 300ms input grace = 18 ticks at 60Hz
	player.aegis_ticks = 0
	player.contact_reduction_fraction = 1.0
	player.facing = Vector2(0, 1)

func to_dict() -> Dictionary:
	return {"tokens": tokens}
