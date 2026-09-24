class_name RulesSolverCheck
extends RefCounted
## Bake-time static solver gate (G2 §7 check 2 / G6 §3.2): the STATIC HP
## BUDGET — a floor is completable iff
##   (drain × target_mid + combat_damage_estimate)
##     ≤ (class_hp + food_pieces × food_hp − margin_hp)
## where food_pieces comes from G2 §3's locked formula
##   max(1, ceil((drain × target_mid + combat − min_class_hp + margin_hp)
##               / food_hp))
## and all band constants come from Tunables.json, which carries G2 §3's
## LOCKED difficulty table (target s/floor rising 120–150 → 270–300; combat
## 500/700/700/850/950/1100/1100/1250). The food term is load-bearing:
## without it the Wizard fails every band at the locked constants.
## Pure deterministic verification (A* reachability — G2 §7 check 1 —
## belongs to the bake pipeline's floor assembler).

static func band_for_floor(floor_number: int) -> int:
	# why: 24 floors across 8 drain bands (3 floors each)
	var band: int = int((floor_number - 1) / 3) + 1
	if band < 1:
		band = 1
	if band > 8:
		band = 8
	return band

static func drain_hp_for_band(band: int, tunables: TunablesLoader) -> float:
	return tunables.get_value("drain_band_" + str(band), 2.0)

static func target_seconds_for_band(band: int, tunables: TunablesLoader) -> int:
	return tunables.get_int("target_seconds_band_" + str(band), 135)

static func combat_damage_for_band(band: int, tunables: TunablesLoader) -> int:
	return tunables.get_int("combat_damage_estimate_band_" + str(band), 500)

## G2 §3 food formula (the locked per-band food column 3/5/6/8/11/12/14/16
## is this formula's output, not a hand-set value):
##   max(1, ceil((drain×target_mid + combat − min_class_HP + margin_HP)
##               / food_hp))
## Targets the most vulnerable class (Wizard, min_class_hp); other classes
## gain the surplus as a class advantage.
static func food_pieces_for_band(band: int, tunables: TunablesLoader) -> int:
	var drain: float = drain_hp_for_band(band, tunables)
	var target_mid: int = target_seconds_for_band(band, tunables)
	var combat: int = combat_damage_for_band(band, tunables)
	var min_class_hp: int = tunables.get_int("min_class_hp", 520)
	var margin_hp: int = tunables.get_int("margin_hp", 52)
	var food_hp: int = tunables.get_int("food_hp", 150)
	if food_hp <= 0:
		food_hp = 150
	var numerator: float = drain * float(target_mid) + float(combat) - float(min_class_hp) + float(margin_hp)
	return maxi(1, int(ceil(numerator / float(food_hp))))

## Solvability check for one class on one floor (G2 §7 static HP budget):
##   (target_seconds × drain) + combat_damage_estimate
##     ≤ class_hp + food_pieces × food_hp − margin_hp
## margin_hp = 52 (10% of Wizard max 520): remaining HP at exit ≥ 52 HP —
## an absolute number, not a percentage of current HP.
static func check_floor(floor_number: int, class_hp: int, tunables: TunablesLoader) -> Dictionary:
	var band: int = band_for_floor(floor_number)
	var drain: float = drain_hp_for_band(band, tunables)
	var target_s: int = target_seconds_for_band(band, tunables)
	var combat: int = combat_damage_for_band(band, tunables)
	var drain_total: int = int(float(target_s) * drain)
	var margin_hp: int = tunables.get_int("margin_hp", 52)
	var min_class_hp: int = tunables.get_int("min_class_hp", 520)
	var food_hp: int = tunables.get_int("food_hp", 150)
	var food_pieces: int = food_pieces_for_band(band, tunables)
	var food_heal_total: int = food_pieces * food_hp
	var drain_plus_combat: int = drain_total + combat
	# why: exact float comparison per G2 §7 (drain×target can be fractional,
	# e.g. 5.5×285 = 1567.5 — integer truncation must never decide the gate)
	var spend_exact: float = drain * float(target_s) + float(combat)
	var effective_hp_budget: int = class_hp + food_heal_total - margin_hp
	var completable: bool = spend_exact <= float(effective_hp_budget)
	var meets_floor: bool = class_hp >= min_class_hp
	return {
		"floor": floor_number,
		"band": band,
		"drain_per_sec": drain,
		"target_seconds": target_s,
		"drain_total": drain_total,
		"combat_estimate": combat,
		"drain_plus_combat": drain_plus_combat,
		"food_pieces": food_pieces,
		"food_hp": food_hp,
		"food_heal_total": food_heal_total,
		"class_hp": class_hp,
		"margin_hp": margin_hp,
		"effective_hp_budget": effective_hp_budget,
		"hp_surplus": float(effective_hp_budget) - spend_exact,
		"completable": completable,
		"meets_floor": meets_floor,
		"total_ok": completable and meets_floor
	}

static func check_all_floors(class_hp: int, tunables: TunablesLoader) -> Dictionary:
	var results: Array = []
	var all_ok: bool = true
	for fn in range(1, 25):
		var r: Dictionary = check_floor(fn, class_hp, tunables)
		results.append(r)
		if not r.total_ok:
			all_ok = false
	return {"all_ok": all_ok, "floors": results}

static func check_all_classes(classes: Array, tunables: TunablesLoader) -> Dictionary:
	var per_class: Dictionary = {}
	var all_ok: bool = true
	for cd in classes:
		var r: Dictionary = check_all_floors(cd.hp, tunables)
		per_class[cd.display_name] = r
		if not r.all_ok:
			all_ok = false
	return {"all_ok": all_ok, "per_class": per_class}

# ===========================================================================
# Bake-time solver GATES 1–9 (G2 §7 / G6 §2). Called by tools/floor_baker.gd
# (per-attempt assembly gate, 200-attempt cap) and tools/solver.gd
# (re-verification of the 24 shipped .tres). Pure static — no Node, no I/O,
# no RNG. A* reachability (G2 §7 check 1) lives HERE per spec: the bake
# pipeline's assembler calls into core; the static HP budget (check 2) is
# check_floor above.
# ===========================================================================

const GRID_W: int = 20
const GRID_H: int = 14
## why: the solver's reference walker is the slowest locked hero speed class
## (128 px/s → 0.25 s per 32px tile) so drain-time edge weights bound every
## class; combat stays a band-constant budget, never a per-tile weight (G2 §7).
const SECONDS_PER_TILE: float = 0.25

static func zone_for_floor(floor_number: int) -> int:
	return clampi(int((floor_number - 1) / 6), 0, 3)

static func _tile_char(fd: FloorData, x: int, y: int) -> String:
	if x < 0 or x >= GRID_W or y < 0 or y >= GRID_H:
		return "#"
	if y >= fd.tiles.size():
		return "#"
	var row: String = fd.tiles[y]
	if x >= row.length():
		return "#"
	return row[x]

## Blocking for reachability: '#' and 'V' always block; 'D' blocks only while
## doors are closed; '.' and 'X' are open.
static func _blocking(c: String, doors_open: bool) -> bool:
	if c == "#" or c == "V":
		return true
	if c == "D" and not doors_open:
		return true
	return false

## 4-directional BFS/A* (uniform-cost on a grid = breadth-first) with
## drain-time edge weighting reported as evidence. Returns
## {dist: Dictionary{"x,y": steps}, path_seconds: Dictionary{"x,y": float}}.
static func _reach(fd: FloorData, start: Vector2i, doors_open: bool) -> Dictionary:
	var dist: Dictionary = {}
	var seconds: Dictionary = {}
	var key: String = "%d,%d" % [start.x, start.y]
	if _blocking(_tile_char(fd, start.x, start.y), doors_open):
		return {"dist": {}, "path_seconds": {}}
	dist[key] = 0
	seconds[key] = 0.0
	var frontier: Array = [start]
	var head: int = 0
	while head < frontier.size():
		var cur: Vector2i = frontier[head]
		head += 1
		var cur_key: String = "%d,%d" % [cur.x, cur.y]
		var cur_steps: int = int(dist[cur_key])
		for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
			var nx: int = cur.x + d.x
			var ny: int = cur.y + d.y
			var nk: String = "%d,%d" % [nx, ny]
			if dist.has(nk):
				continue
			if _blocking(_tile_char(fd, nx, ny), doors_open):
				continue
			dist[nk] = cur_steps + 1
			seconds[nk] = float(cur_steps + 1) * SECONDS_PER_TILE
			frontier.append(Vector2i(nx, ny))
	return {"dist": dist, "path_seconds": seconds}

static func _ok(passed: bool, msg: String) -> Dictionary:
	return {"pass": passed, "msg": msg}

## GATE 1 — grid shape: 14 rows × 20 chars, only legal chars, wall perimeter.
static func gate_1_grid_shape(fd: FloorData) -> Dictionary:
	if fd.tiles.size() != GRID_H:
		return _ok(false, "grid has %d rows, expected %d" % [fd.tiles.size(), GRID_H])
	for y in range(GRID_H):
		var row: String = fd.tiles[y]
		if row.length() != GRID_W:
			return _ok(false, "row %d has %d chars, expected %d" % [y, row.length(), GRID_W])
		for x in range(GRID_W):
			var c: String = row[x]
			if c != "#" and c != "." and c != "D" and c != "X" and c != "V":
				return _ok(false, "illegal char '%s' at (%d,%d)" % [c, x, y])
			if (x == 0 or x == GRID_W - 1 or y == 0 or y == GRID_H - 1) and c != "#":
				return _ok(false, "perimeter not wall at (%d,%d): '%s'" % [x, y, c])
	return _ok(true, "grid shape ok")

## GATE 2 — spawn/exit: in bounds, on open tiles, distinct, exit stamped 'X'.
static func gate_2_spawn_exit(fd: FloorData) -> Dictionary:
	var s: String = _tile_char(fd, fd.spawn.x, fd.spawn.y)
	if s != ".":
		return _ok(false, "spawn (%d,%d) on '%s', expected '.'" % [fd.spawn.x, fd.spawn.y, s])
	var e: String = _tile_char(fd, fd.exit_pos.x, fd.exit_pos.y)
	if e != "X":
		return _ok(false, "exit (%d,%d) on '%s', expected 'X'" % [fd.exit_pos.x, fd.exit_pos.y, e])
	if fd.spawn == fd.exit_pos:
		return _ok(false, "spawn == exit")
	return _ok(true, "spawn/exit ok")

## GATE 3 — A* reachability (G2 §7 check 1): spawn→every key with doors
## CLOSED, then spawn→exit and spawn→every door tile with doors OPEN.
static func gate_3_reachability(fd: FloorData) -> Dictionary:
	var closed: Dictionary = _reach(fd, fd.spawn, false)
	var closed_dist: Dictionary = closed.dist
	for k in fd.keys:
		var kk: String = "%d,%d" % [int(k.x), int(k.y)]
		if not closed_dist.has(kk):
			return _ok(false, "key (%d,%d) unreachable with doors closed" % [int(k.x), int(k.y)])
	var opened: Dictionary = _reach(fd, fd.spawn, true)
	var opened_dist: Dictionary = opened.dist
	var ek: String = "%d,%d" % [fd.exit_pos.x, fd.exit_pos.y]
	if not opened_dist.has(ek):
		return _ok(false, "exit unreachable with doors open")
	for d in fd.doors:
		var dk: String = "%d,%d" % [int(d.x), int(d.y)]
		if not opened_dist.has(dk):
			return _ok(false, "door tile (%d,%d) unreachable" % [int(d.x), int(d.y)])
	var walk_secs: float = float(opened.path_seconds.get(ek, 0.0))
	var drain_cost: float = walk_secs * fd.drain_hp_per_sec
	return _ok(true, "spawn→keys→doors→exit ok (exit walk %.1fs, drain %.1f HP)" % [walk_secs, drain_cost])

## GATE 4 — corridor width ≥2 (authoring rule 3): no walkable '.' tile
## pinched between two blocking tiles on either axis. Door/exit tiles are the
## 2-tile doorway cuts (G3 §architecture) and are exempt as test subjects;
## doors/exit count OPEN for their neighbours' pinch test, void counts closed.
static func gate_4_corridor_width(fd: FloorData) -> Dictionary:
	for y in range(GRID_H):
		for x in range(GRID_W):
			if _tile_char(fd, x, y) != ".":
				continue
			var up: String = _tile_char(fd, x, y - 1)
			var dn: String = _tile_char(fd, x, y + 1)
			var lf: String = _tile_char(fd, x - 1, y)
			var rt: String = _tile_char(fd, x + 1, y)
			var up_b: bool = up == "#" or up == "V"
			var dn_b: bool = dn == "#" or dn == "V"
			var lf_b: bool = lf == "#" or lf == "V"
			var rt_b: bool = rt == "#" or rt == "V"
			if up_b and dn_b:
				return _ok(false, "1-wide vertical squeeze at (%d,%d)" % [x, y])
			if lf_b and rt_b:
				return _ok(false, "1-wide horizontal squeeze at (%d,%d)" % [x, y])
	return _ok(true, "all corridors >= 2 wide")

## Group orthogonally-contiguous 'D' tiles into doorway runs.
static func door_runs(fd: FloorData) -> Array:
	var seen: Dictionary = {}
	var runs: Array = []
	for y in range(GRID_H):
		for x in range(GRID_W):
			if _tile_char(fd, x, y) != "D":
				continue
			var key: String = "%d,%d" % [x, y]
			if seen.has(key):
				continue
			var run: Array = []
			var stack: Array = [Vector2i(x, y)]
			while not stack.is_empty():
				var cur: Vector2i = stack.pop_back()
				var ck: String = "%d,%d" % [cur.x, cur.y]
				if seen.has(ck):
					continue
				if _tile_char(fd, cur.x, cur.y) != "D":
					continue
				seen[ck] = true
				run.append(cur)
				for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
					stack.append(cur + d)
			runs.append(run)
	return runs

## GATE 5 — key/door integrity: every doorway run has a key, door entries
## match the grid 'D' tiles exactly, keys sit on open floor.
static func gate_5_key_door(fd: FloorData) -> Dictionary:
	var runs: Array = door_runs(fd)
	if fd.keys.size() < runs.size():
		return _ok(false, "%d doorway runs but only %d keys" % [runs.size(), fd.keys.size()])
	var grid_doors: Dictionary = {}
	for r in runs:
		for v in r:
			grid_doors["%d,%d" % [v.x, v.y]] = true
	var entry_doors: Dictionary = {}
	for d in fd.doors:
		entry_doors["%d,%d" % [int(d.x), int(d.y)]] = true
	if grid_doors.size() != entry_doors.size():
		return _ok(false, "grid has %d D tiles, doors array has %d entries" % [grid_doors.size(), entry_doors.size()])
	for k in grid_doors:
		if not entry_doors.has(k):
			return _ok(false, "grid D tile %s missing from doors array" % k)
	for k in fd.keys:
		if _tile_char(fd, int(k.x), int(k.y)) != ".":
			return _ok(false, "key (%d,%d) not on open floor" % [int(k.x), int(k.y)])
	return _ok(true, "%d doorway run(s), %d key(s)" % [runs.size(), fd.keys.size()])

## GATE 6 — placement: every entity on open floor, no overlaps, nothing on
## spawn/exit, generators + scripted enemies ≥4 tiles from spawn
## (anti-spawn-snipe, authoring rule 2), hazards never on keys/doors/exit.
static func gate_6_placement(fd: FloorData) -> Dictionary:
	var occupied: Dictionary = {}
	var spawn_key: String = "%d,%d" % [fd.spawn.x, fd.spawn.y]
	var exit_key: String = "%d,%d" % [fd.exit_pos.x, fd.exit_pos.y]
	var spots: Array = []
	for f in fd.foods:
		spots.append({"pos": Vector2i(int(f.x), int(f.y)), "kind": "food", "min_spawn_dist": 0})
	for k in fd.keys:
		spots.append({"pos": Vector2i(int(k.x), int(k.y)), "kind": "key", "min_spawn_dist": 0})
	for p in fd.potions:
		spots.append({"pos": Vector2i(int(p.x), int(p.y)), "kind": "potion", "min_spawn_dist": 0})
	for c in fd.chests:
		spots.append({"pos": Vector2i(int(c.x), int(c.y)), "kind": "chest", "min_spawn_dist": 0})
	for g in fd.generators:
		spots.append({"pos": Vector2i(int(g.x), int(g.y)), "kind": "generator", "min_spawn_dist": 4})
	for e in fd.initial_enemies:
		spots.append({"pos": Vector2i(int(e.x), int(e.y)), "kind": "enemy", "min_spawn_dist": 4})
	for h in fd.hazards:
		for t in h.tiles:
			spots.append({"pos": Vector2i(int(t.x), int(t.y)), "kind": "hazard", "min_spawn_dist": 0})
	for spot in spots:
		var pos: Vector2i = spot.pos
		var key: String = "%d,%d" % [pos.x, pos.y]
		var c: String = _tile_char(fd, pos.x, pos.y)
		if c != ".":
			return _ok(false, "%s at (%d,%d) on '%s', expected '.'" % [spot.kind, pos.x, pos.y, c])
		if key == spawn_key:
			return _ok(false, "%s placed on spawn" % spot.kind)
		if key == exit_key:
			return _ok(false, "%s placed on exit" % spot.kind)
		if occupied.has(key) and not (spot.kind == "hazard" or occupied[key] == "hazard"):
			return _ok(false, "%s overlaps %s at (%d,%d)" % [spot.kind, occupied[key], pos.x, pos.y])
		occupied[key] = spot.kind
		var min_dist: int = int(spot.min_spawn_dist)
		if min_dist > 0:
			var manhattan: int = abs(pos.x - fd.spawn.x) + abs(pos.y - fd.spawn.y)
			if manhattan < min_dist:
				return _ok(false, "%s at (%d,%d) only %d tiles from spawn (<%d)" % [spot.kind, pos.x, pos.y, manhattan, min_dist])
	for h in fd.hazards:
		for t in h.tiles:
			var key: String = "%d,%d" % [int(t.x), int(t.y)]
			for k in fd.keys:
				if "%d,%d" % [int(k.x), int(k.y)] == key:
					return _ok(false, "hazard covers key (%d,%d)" % [int(t.x), int(t.y)])
			for d in fd.doors:
				if "%d,%d" % [int(d.x), int(d.y)] == key:
					return _ok(false, "hazard covers door (%d,%d)" % [int(t.x), int(t.y)])
	return _ok(true, "all %d entity placements legal" % spots.size())

## GATE 7 — food count: baked pieces ≥ G2 §3 locked formula per band.
static func gate_7_food_count(fd: FloorData, tunables: TunablesLoader) -> Dictionary:
	var band: int = band_for_floor(fd.floor_number)
	var need: int = food_pieces_for_band(band, tunables)
	if fd.foods.size() < need:
		return _ok(false, "band %d needs %d food pieces, floor has %d" % [band, need, fd.foods.size()])
	return _ok(true, "%d food pieces >= band %d requirement %d" % [fd.foods.size(), band, need])

## GATE 8 — static HP budget (G2 §7 check 2) for every class.
static func gate_8_hp_budget(fd: FloorData, tunables: TunablesLoader, class_hps: Array) -> Dictionary:
	var worst: Dictionary = {}
	for hp in class_hps:
		var r: Dictionary = check_floor(fd.floor_number, int(hp), tunables)
		if not r.total_ok:
			return _ok(false, "class hp %d fails budget: drain+combat %d > budget %d (band %d)" % [int(hp), r.drain_plus_combat, r.effective_hp_budget, r.band])
		if worst.is_empty() or float(r.hp_surplus) < float(worst.hp_surplus):
			worst = r
	return _ok(true, "all %d classes pass; worst surplus %.1f HP (band %d)" % [class_hps.size(), float(worst.hp_surplus), int(worst.band)])

## GATE 9 — zone integrity: zone index matches floor number and the stored
## field; hazard types obey the zone contract (0 none / 1 flame_jet /
## 2 void_bridge / 3 collapsing_void); chests legal and total consistent.
static func gate_9_zone(fd: FloorData) -> Dictionary:
	var zone: int = zone_for_floor(fd.floor_number)
	if fd.zone != zone:
		return _ok(false, "floor %d zone field %d, expected %d" % [fd.floor_number, fd.zone, zone])
	var allowed: Array = []
	match zone:
		0: allowed = []
		1: allowed = [StateEnums.HazardType.FLAME_JET]
		2: allowed = [StateEnums.HazardType.VOID_BRIDGE]
		_: allowed = [StateEnums.HazardType.COLLAPSING_VOID]
	for h in fd.hazards:
		if not allowed.has(int(h.type)):
			return _ok(false, "zone %d forbids hazard type %d" % [zone, int(h.type)])
	if fd.chests.size() < 1:
		return _ok(false, "floor has no chests (treasure contract)")
	var total: int = 0
	for c in fd.chests:
		var v: int = int(c.value)
		if v <= 0:
			return _ok(false, "chest at (%d,%d) has non-positive value" % [int(c.x), int(c.y)])
		total += v
	if total != fd.chest_total:
		return _ok(false, "chest_total %d != sum of chest values %d" % [fd.chest_total, total])
	return _ok(true, "zone %d contract ok (%d hazards, %d chests, total %d)" % [zone, fd.hazards.size(), fd.chests.size(), total])

## Run gates 1–9 on one baked floor. Returns {pass: bool, gates: {1..9: {pass, msg}}}.
static func run_all_gates(fd: FloorData, tunables: TunablesLoader, class_hps: Array) -> Dictionary:
	var gates: Dictionary = {}
	var all_ok: bool = true
	gates[1] = gate_1_grid_shape(fd)
	gates[2] = gate_2_spawn_exit(fd)
	gates[3] = gate_3_reachability(fd)
	gates[4] = gate_4_corridor_width(fd)
	gates[5] = gate_5_key_door(fd)
	gates[6] = gate_6_placement(fd)
	gates[7] = gate_7_food_count(fd, tunables)
	gates[8] = gate_8_hp_budget(fd, tunables, class_hps)
	gates[9] = gate_9_zone(fd)
	for i in range(1, 10):
		if not gates[i].pass:
			all_ok = false
	return {"pass": all_ok, "gates": gates}
