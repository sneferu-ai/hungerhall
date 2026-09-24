class_name RulesHazard
extends RefCounted
## flame_jet / void_bridge / collapsing_void (G6 §2 core/).
## Pure deterministic hazard state. No Node, no rendering.

var id: int = 0
var hazard_type: int = 0
var trigger_type: int = 0
var tiles: Array = []  # Array[Vector2i]
var phase: int = 0        # current phase offset in ticks
var active: bool = false
var removed_tiles: Array = []  # for collapsing_void — permanently removed

func setup(hid: int, h_type: int, t_type: int, h_tiles: Array, h_phase: int) -> void:
	id = hid
	hazard_type = h_type
	trigger_type = t_type
	tiles = h_tiles.duplicate()
	phase = h_phase
	active = false

func tick(tunables: TunablesLoader) -> void:
	match hazard_type:
		StateEnums.HazardType.FLAME_JET:
			_tick_flame_jet(tunables)
		StateEnums.HazardType.VOID_BRIDGE:
			_tick_void_bridge(tunables)
		StateEnums.HazardType.COLLAPSING_VOID:
			_tick_collapsing_void(tunables)

func _tick_flame_jet(t: TunablesLoader) -> void:
	# why: periodic 1.0s on / 2.0s off = 60 on / 120 off
	var on_ticks: int = t.get_int("flame_jet_on_ticks", 60)
	var off_ticks: int = t.get_int("flame_jet_off_ticks", 120)
	var cycle: int = on_ticks + off_ticks
	var pos_in_cycle: int = phase % cycle
	active = pos_in_cycle < on_ticks
	phase += 1

func _tick_void_bridge(t: TunablesLoader) -> void:
	# why: bridge walkable 1.5s / void 1.5s = 90/90
	var walkable: int = t.get_int("void_bridge_walkable_ticks", 90)
	var void_t: int = t.get_int("void_bridge_void_ticks", 90)
	var cycle: int = walkable + void_t
	var pos_in_cycle: int = phase % cycle
	active = pos_in_cycle >= walkable  # active = void (damaging)
	phase += 1

func _tick_collapsing_void(t: TunablesLoader) -> void:
	# why: tile removes 2.0s after player steps — handled by RulesSession via remove_timer
	# here we just advance phase for telegraph timing
	phase += 1

func is_tile_damaging(tx: int, ty: int) -> bool:
	if hazard_type == StateEnums.HazardType.FLAME_JET:
		if not active:
			return false
		return _has_tile(tx, ty)
	if hazard_type == StateEnums.HazardType.VOID_BRIDGE:
		if not active:
			return false
		return _has_tile(tx, ty)
	if hazard_type == StateEnums.HazardType.COLLAPSING_VOID:
		return _is_removed(tx, ty)
	return false

func is_tile_removed(tx: int, ty: int) -> bool:
	return _is_removed(tx, ty)

func _has_tile(tx: int, ty: int) -> bool:
	for v in tiles:
		if v.x == tx and v.y == ty:
			return true
	return false

func _is_removed(tx: int, ty: int) -> bool:
	for v in removed_tiles:
		if v.x == tx and v.y == ty:
			return true
	return false

func mark_removed(tx: int, ty: int) -> void:
	if not _is_removed(tx, ty):
		removed_tiles.append(Vector2i(tx, ty))

func damage_amount(tunables: TunablesLoader) -> int:
	match hazard_type:
		StateEnums.HazardType.FLAME_JET:
			return tunables.get_int("flame_jet_dmg", 10)
		StateEnums.HazardType.VOID_BRIDGE:
			return tunables.get_int("void_bridge_dmg", 100)
		StateEnums.HazardType.COLLAPSING_VOID:
			return tunables.get_int("collapsing_void_dmg", 100)
	return 0

func to_dict() -> Dictionary:
	return {
		"id": id, "hazard_type": hazard_type, "active": active,
		"tiles": tiles, "removed_tiles": removed_tiles
	}
