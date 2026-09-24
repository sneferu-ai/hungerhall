extends RefCounted
## test_hazards — the three hazard contracts (G2 §1 / G6 §2): flame_jet
## periodic burn, void_bridge walkable/void phase, collapsing_void permanent
## tile removal.

func _tun() -> TunablesLoader:
	var t: TunablesLoader = TunablesLoader.new()
	t.load_from_path("res://Tunables.json")
	return t

func test_flame_jet_on_off_cycle() -> Dictionary:
	var t: TunablesLoader = _tun()
	var on_ticks: int = t.get_int("flame_jet_on_ticks", 60)
	var off_ticks: int = t.get_int("flame_jet_off_ticks", 120)
	var h: RulesHazard = RulesHazard.new()
	h.setup(0, StateEnums.HazardType.FLAME_JET, 0, [Vector2i(5, 5)], 0)
	# why: first on_ticks of the cycle burn, then off_ticks cold
	for i in range(on_ticks):
		h.tick(t)
		if not h.is_tile_damaging(5, 5):
			return {"ok": false, "msg": "flame jet cold during ON window at tick %d" % i}
	for i in range(off_ticks):
		h.tick(t)
		if h.is_tile_damaging(5, 5):
			return {"ok": false, "msg": "flame jet burning during OFF window at tick %d" % (on_ticks + i)}
	# why: on_ticks + off_ticks ticks have elapsed — that is exactly one full
	# cycle, and the LAST off-window tick still reports cold (its own window).
	# The jet wraps back to ON on the NEXT tick: tick() once more and assert.
	h.tick(t)
	if not h.is_tile_damaging(5, 5):
		return {"ok": false, "msg": "cycle did not wrap back to ON"}
	return {"ok": true}

func test_flame_jet_only_its_tiles() -> Dictionary:
	var t: TunablesLoader = _tun()
	var h: RulesHazard = RulesHazard.new()
	h.setup(0, StateEnums.HazardType.FLAME_JET, 0, [Vector2i(5, 5)], 0)
	h.tick(t)
	if h.is_tile_damaging(6, 5):
		return {"ok": false, "msg": "flame jet damages a tile it does not own"}
	return {"ok": true}

func test_void_bridge_phases() -> Dictionary:
	var t: TunablesLoader = _tun()
	var walkable: int = t.get_int("void_bridge_walkable_ticks", 90)
	var void_t: int = t.get_int("void_bridge_void_ticks", 90)
	var h: RulesHazard = RulesHazard.new()
	h.setup(0, StateEnums.HazardType.VOID_BRIDGE, 0, [Vector2i(3, 3)], 0)
	for i in range(walkable):
		h.tick(t)
		if h.is_tile_damaging(3, 3):
			return {"ok": false, "msg": "bridge damaging during walkable window at tick %d" % i}
	for i in range(void_t):
		h.tick(t)
		if not h.is_tile_damaging(3, 3):
			return {"ok": false, "msg": "bridge safe during void window at tick %d" % (walkable + i)}
	return {"ok": true}

func test_collapsing_void_permanent_removal() -> Dictionary:
	var t: TunablesLoader = _tun()
	var h: RulesHazard = RulesHazard.new()
	h.setup(0, StateEnums.HazardType.COLLAPSING_VOID, 2, [Vector2i(4, 4), Vector2i(4, 5)], 0)
	if h.is_tile_removed(4, 4):
		return {"ok": false, "msg": "tile removed before trigger"}
	h.mark_removed(4, 4)
	if not h.is_tile_removed(4, 4):
		return {"ok": false, "msg": "mark_removed not honored"}
	if h.is_tile_removed(4, 5):
		return {"ok": false, "msg": "sibling tile removed without its own trigger"}
	# why: removal is permanent — ticks never restore the tile
	for i in range(300):
		h.tick(t)
	if not h.is_tile_removed(4, 4):
		return {"ok": false, "msg": "removed tile restored by ticking"}
	if not h.is_tile_damaging(4, 4):
		return {"ok": false, "msg": "removed collapsing-void tile must read damaging (it is a hole)"}
	return {"ok": true}

func test_damage_amounts_from_tunables() -> Dictionary:
	var t: TunablesLoader = _tun()
	var flame: RulesHazard = RulesHazard.new()
	flame.setup(0, StateEnums.HazardType.FLAME_JET, 0, [], 0)
	if flame.damage_amount(t) != t.get_int("flame_jet_dmg", 10):
		return {"ok": false, "msg": "flame_jet damage not tunable-driven"}
	var void_b: RulesHazard = RulesHazard.new()
	void_b.setup(0, StateEnums.HazardType.VOID_BRIDGE, 0, [], 0)
	if void_b.damage_amount(t) != t.get_int("void_bridge_dmg", 100):
		return {"ok": false, "msg": "void_bridge damage not tunable-driven"}
	var cv: RulesHazard = RulesHazard.new()
	cv.setup(0, StateEnums.HazardType.COLLAPSING_VOID, 0, [], 0)
	if cv.damage_amount(t) != t.get_int("collapsing_void_dmg", 100):
		return {"ok": false, "msg": "collapsing_void damage not tunable-driven"}
	return {"ok": true}
