extends SceneTree
## HUNGERHALL — tools/floor_baker.gd (G6 §2, G2 §7). BUILD-TIME ONLY.
## Cell assembly + the 7 hand-built floors, frozen into 24 solver-passed
## FloorData resources. Runtime contains ZERO layout RNG — this baker and
## tools/solver.gd are the only places floor geometry is ever decided.
##
## Command (spec-pinned):
##   godot --headless --script tools/floor_baker.gd -- \
##     --output data/floors/base/ --tunables Tunables.json --seed 12345
##
## Contract:
##  - --seed <int> is REQUIRED (bakes are reproducible; missing seed = exit 1).
##  - 200-attempt cap per assembled floor: each attempt re-draws cells and
##    entity placements from PrngSeeder(seed + fn*1000 + attempt); the FIRST
##    attempt passing solver gates 1–9 (core/rules_solver_check.gd) is saved.
##  - Failure writes bake_failure.json (attempted layouts + failed gate IDs)
##    next to the output dir and exits 1. Success exits 0.
##  - Hand-built floors (F1,F2,F3,F6,F12,F18,F24) are stamped verbatim from
##    tools/cells/cell_library.gd and gated exactly like assembled ones.

const CELL_W: int = 10
const CELL_H: int = 7
const MAX_ATTEMPTS: int = 200

var _cell_lib: RefCounted = null

func _init() -> void:
	var code: int = _main()
	quit(code)

func _main() -> int:
	var args: Dictionary = _parse_args(OS.get_cmdline_user_args())
	if args.has("_usage_error"):
		push_error(str(args._usage_error))
		print("usage: godot --headless --script tools/floor_baker.gd -- --output data/floors/base/ --tunables Tunables.json --seed 12345")
		return 1
	var output_arg: String = args.output
	var tunables_arg: String = args.tunables
	var seed_value: int = int(args.seed)

	var tunables_path: String = _res_path(tunables_arg)
	var tunables: TunablesLoader = TunablesLoader.new()
	if not tunables.load_from_path(tunables_path):
		push_error("floor_baker: cannot load tunables at %s: %s" % [tunables_path, "; ".join(tunables.get_errors())])
		return 1

	_cell_lib = load("res://tools/cells/cell_library.gd").new()

	var class_hps: Array = []
	for cd in ClassDef.build_all(tunables):
		class_hps.append(cd.hp)

	var output_path: String = _res_path(output_arg)
	if output_path.ends_with("/"):
		output_path = output_path.left(output_path.length() - 1)
	if DirAccess.make_dir_recursive_absolute(output_path) != OK and not DirAccess.dir_exists_absolute(output_path):
		push_error("floor_baker: cannot create output dir %s" % output_path)
		return 1

	# Validate the authored cell pool BEFORE spending any bake attempts.
	var cell_report: Dictionary = _validate_cell_pool()
	if not cell_report.ok:
		push_error("floor_baker: cell pool invalid: " + str(cell_report.errors))
		return 1

	var failures: Array = []
	var receipt_rows: Array = []
	for fn in range(1, 25):
		var result: Dictionary = _bake_floor(fn, seed_value, tunables, class_hps)
		if not result.ok:
			failures.append({"floor": fn, "attempts": result.attempts})
			continue
		var save_path: String = "%s/floor_%02d.tres" % [output_path, fn]
		var err: int = ResourceSaver.save(result.floor_data, save_path)
		if err != OK:
			failures.append({"floor": fn, "attempts": [{"error": "ResourceSaver.save failed: %d" % err}]})
			continue
		if not ResourceLoader.exists(save_path):
			failures.append({"floor": fn, "attempts": [{"error": "saved resource does not exist at %s" % save_path}]})
			continue
		receipt_rows.append({
			"floor": fn,
			"path": save_path,
			"kind": result.kind,
			"attempt": int(result.attempt),
			"cells": result.get("cells", []),
			"gates": _gate_msgs(result.gates),
		})
		print("baked floor_%02d.tres (%s, attempt %d)" % [fn, result.kind, int(result.attempt)])

	if not failures.is_empty():
		var failure_doc: Dictionary = {
			"schema": "hungerhall_bake_failure_v1",
			"seed": seed_value,
			"floors_failed": failures,
		}
		var failure_path: String = output_path + "/bake_failure.json"
		var f: FileAccess = FileAccess.open(failure_path, FileAccess.WRITE)
		if f != null:
			f.store_string(JSON.stringify(failure_doc, "  "))
			f.close()
		push_error("floor_baker: %d floor(s) failed to bake within %d attempts; wrote %s" % [failures.size(), MAX_ATTEMPTS, failure_path])
		return 1

	print("floor_baker: all 24 floors baked and solver-gated (seed %d) -> %s" % [seed_value, output_path])
	return 0

func _parse_args(raw: Array) -> Dictionary:
	var out: Dictionary = {}
	var i: int = 0
	while i < raw.size():
		var a: String = str(raw[i])
		if a.begins_with("--") and i + 1 < raw.size():
			out[a.substr(2)] = str(raw[i + 1])
			i += 2
		else:
			i += 1
	for required in ["output", "tunables", "seed"]:
		if not out.has(required):
			return {"_usage_error": "missing required argument --%s" % required}
	if not str(out.seed).is_valid_int():
		return {"_usage_error": "--seed must be an integer, got '%s'" % str(out.seed)}
	return out

func _res_path(p: String) -> String:
	if p.begins_with("res://") or p.begins_with("user://") or p.is_absolute_path():
		return p
	return "res://" + p

func _gate_msgs(gates: Dictionary) -> Dictionary:
	var out: Dictionary = {}
	for k in gates:
		out[k] = str(gates[k].msg)
	return out

## ---------------------------------------------------------------------------
## Cell pool validation (authoring rules 1 + 3, per-cell):
## every port reaches every other port; no pinched corridor tile.
## ---------------------------------------------------------------------------

func _validate_cell_pool() -> Dictionary:
	var errors: Array = []
	for zone in range(4):
		var cells: Array = _cell_lib.cells_for_zone(zone)
		if cells.size() != 12:
			errors.append("zone %d has %d cells, expected 12" % [zone, cells.size()])
			continue
		for cell in cells:
			var id: String = cell.id
			var rows: Array = cell.rows
			if rows.size() != CELL_H:
				errors.append("%s: %d rows" % [id, rows.size()])
				continue
			for y in range(CELL_H):
				if String(rows[y]).length() != CELL_W:
					errors.append("%s: row %d length %d" % [id, y, String(rows[y]).length()])
			# ports
			var ports: Dictionary = {
				"N": [Vector2i(4, 0), Vector2i(5, 0)],
				"S": [Vector2i(4, 6), Vector2i(5, 6)],
				"W": [Vector2i(0, 3), Vector2i(0, 4)],
				"E": [Vector2i(9, 3), Vector2i(9, 4)],
			}
			for pname in ports:
				for pv in ports[pname]:
					if String(rows[pv.y])[pv.x] != ".":
						errors.append("%s: port %s blocked at (%d,%d)" % [id, pname, pv.x, pv.y])
			# port-to-port reachability through the cell interior
			var reach: Dictionary = _cell_reach(rows, Vector2i(4, 1))
			for pname in ports:
				for pv in ports[pname]:
					var inner: Vector2i = pv + Vector2i(0, 0)
					# step one tile inside from the port opening
					if pv.y == 0:
						inner = Vector2i(pv.x, 1)
					elif pv.y == CELL_H - 1:
						inner = Vector2i(pv.x, CELL_H - 2)
					elif pv.x == 0:
						inner = Vector2i(1, pv.y)
					else:
						inner = Vector2i(CELL_W - 2, pv.y)
					if not reach.has("%d,%d" % [inner.x, inner.y]):
						errors.append("%s: port %s unreachable from interior" % [id, pname])
			# pinch rule (solver gate 4 at authoring level)
			for y in range(CELL_H):
				for x in range(CELL_W):
					if String(rows[y])[x] != ".":
						continue
					var up_b: bool = _cell_blocking(rows, x, y - 1)
					var dn_b: bool = _cell_blocking(rows, x, y + 1)
					var lf_b: bool = _cell_blocking(rows, x - 1, y)
					var rt_b: bool = _cell_blocking(rows, x + 1, y)
					if up_b and dn_b:
						errors.append("%s: vertical squeeze at (%d,%d)" % [id, x, y])
					if lf_b and rt_b:
						errors.append("%s: horizontal squeeze at (%d,%d)" % [id, x, y])
			# treasure rule 4: exactly 1 chest spot on treasure cells
			if cell.type == "treasure" and (cell.chest_spot is Array and cell.chest_spot.is_empty()):
				errors.append("%s: treasure cell without chest_spot" % id)
	return {"ok": errors.is_empty(), "errors": errors}

func _cell_blocking(rows: Array, x: int, y: int) -> bool:
	if x < 0 or x >= CELL_W or y < 0 or y >= CELL_H:
		return true
	var c: String = String(rows[y])[x]
	return c == "#" or c == "V"

func _cell_reach(rows: Array, start: Vector2i) -> Dictionary:
	var dist: Dictionary = {}
	if _cell_blocking(rows, start.x, start.y):
		return dist
	dist["%d,%d" % [start.x, start.y]] = 0
	var frontier: Array = [start]
	var head: int = 0
	while head < frontier.size():
		var cur: Vector2i = frontier[head]
		head += 1
		var cur_steps: int = int(dist["%d,%d" % [cur.x, cur.y]])
		for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
			var nk: String = "%d,%d" % [cur.x + d.x, cur.y + d.y]
			if dist.has(nk) or _cell_blocking(rows, cur.x + d.x, cur.y + d.y):
				continue
			dist[nk] = cur_steps + 1
			frontier.append(cur + d)
	return dist

## ---------------------------------------------------------------------------
## Baking
## ---------------------------------------------------------------------------

func _bake_floor(fn: int, seed_value: int, tunables: TunablesLoader, class_hps: Array) -> Dictionary:
	var zone: int = RulesSolverCheck.zone_for_floor(fn)
	var handbuilt_nums: Array = _cell_lib.handbuilt_floor_numbers()
	var attempts_log: Array = []
	if handbuilt_nums.has(fn):
		var fd: FloorData = _floor_data_from_handbuilt(fn, zone, tunables)
		var gates: Dictionary = RulesSolverCheck.run_all_gates(fd, tunables, class_hps)
		if gates.pass:
			return {"ok": true, "floor_data": fd, "attempt": 1, "kind": "hand-built", "gates": gates.gates, "cells": []}
		attempts_log.append({"kind": "hand-built", "failed_gates": _failed_gate_ids(gates.gates)})
		return {"ok": false, "attempts": attempts_log}
	# assembled from cells
	for attempt in range(MAX_ATTEMPTS):
		var rng: PrngSeeder = PrngSeeder.new(seed_value + fn * 1000 + attempt)
		var built: Dictionary = _assemble_floor(fn, zone, rng, tunables)
		var fd: FloorData = built.floor_data
		var gates: Dictionary = RulesSolverCheck.run_all_gates(fd, tunables, class_hps)
		if gates.pass:
			return {"ok": true, "floor_data": fd, "attempt": attempt + 1, "kind": "assembled", "gates": gates.gates, "cells": built.cells}
		attempts_log.append({
			"attempt": attempt + 1,
			"cells": built.cells,
			"failed_gates": _failed_gate_ids(gates.gates),
		})
	return {"ok": false, "attempts": attempts_log}

func _failed_gate_ids(gates: Dictionary) -> Array:
	var ids: Array = []
	for k in gates:
		if not gates[k].pass:
			ids.append(k)
	return ids

func _floor_data_from_handbuilt(fn: int, zone: int, tunables: TunablesLoader) -> FloorData:
	var def: Dictionary = _cell_lib.handbuilt(fn)
	var fd: FloorData = FloorData.new()
	fd.floor_number = fn
	fd.zone = zone
	var rows: PackedStringArray = PackedStringArray()
	for r in def.rows:
		rows.append(String(r))
	fd.tiles = rows
	fd.spawn = Vector2i(def.spawn[0], def.spawn[1])
	fd.exit_pos = Vector2i(def.exit[0], def.exit[1])
	fd.doors = _vec_array(def.doors)
	fd.keys = _vec_array(def.keys)
	fd.foods = _vec_array(def.foods)
	fd.potions = _vec_array(def.potions)
	fd.chests = _chests(def.chests, zone, tunables)
	fd.generators = []
	for g in def.generators:
		fd.generators.append({"x": g.pos[0], "y": g.pos[1], "enemy_type": int(g.enemy_type)})
	fd.initial_enemies = []
	for e in def.initial_enemies:
		fd.initial_enemies.append({"x": e.pos[0], "y": e.pos[1], "type": int(e.type)})
	fd.hazards = []
	for h in def.hazards:
		fd.hazards.append({
			"type": int(h.type), "trigger": int(h.trigger),
			"tiles": _plain_vecs(h.tiles), "phase": int(h.phase),
		})
	_stamp_band_fields(fd, fn, zone, tunables)
	return fd

func _vec_array(list: Array) -> PackedVector2Array:
	var out: PackedVector2Array = PackedVector2Array()
	for v in list:
		out.append(Vector2(Vector2i(v[0], v[1])))
	return out

func _plain_vecs(list: Array) -> Array:
	var out: Array = []
	for v in list:
		out.append(Vector2i(v[0], v[1]))
	return out

## Chest value = chest_base_value(tier) × zone_mult, computed at bake time
## (G6 §2). why this multiplier table: 1.0/1.0/1.25/1.5 keeps every baked
## value INSIDE the tier's declared Tunables band (low 50–150, mid 150–350,
## high 300–750) while still paying deeper halls better.
const ZONE_CHEST_MULT: Array = [1.0, 1.0, 1.25, 1.5]

func _chest_value(tier: String, zone: int, tunables: TunablesLoader) -> int:
	var base_key: String = "chest_value_low"
	match tier:
		"mid": base_key = "chest_value_mid"
		"high": base_key = "chest_value_high"
		_: base_key = "chest_value_low"
	var base: int = tunables.get_int(base_key, 100)
	return int(float(base) * float(ZONE_CHEST_MULT[zone]))

func _chests(list: Array, zone: int, tunables: TunablesLoader) -> Array:
	var out: Array = []
	for c in list:
		out.append({"x": c.pos[0], "y": c.pos[1], "value": _chest_value(str(c.tier), zone, tunables)})
	return out

func _stamp_band_fields(fd: FloorData, fn: int, zone: int, tunables: TunablesLoader) -> void:
	var band: int = RulesSolverCheck.band_for_floor(fn)
	fd.drain_hp_per_sec = RulesSolverCheck.drain_hp_for_band(band, tunables)
	fd.target_seconds = RulesSolverCheck.target_seconds_for_band(band, tunables)
	fd.chest_total = 0
	for c in fd.chests:
		fd.chest_total += int(c.value)
	# generator hp/cadence bake from the zone's band constants (runtime never
	# recomputes them — FloorData carries them frozen)
	match zone:
		0:
			fd.generator_hp = tunables.get_int("gen_hp_drowned", 60)
			fd.generator_cadence_ticks = tunables.get_int("gen_cadence_drowned", 180)
		1:
			fd.generator_hp = tunables.get_int("gen_hp_cinder", 90)
			fd.generator_cadence_ticks = tunables.get_int("gen_cadence_cinder", 150)
		2:
			fd.generator_hp = tunables.get_int("gen_hp_starved", 120)
			fd.generator_cadence_ticks = tunables.get_int("gen_cadence_starved", 120)
		_:
			fd.generator_hp = tunables.get_int("gen_hp_throne", 160)
			fd.generator_cadence_ticks = tunables.get_int("gen_cadence_throne_early", 108)

## ---------------------------------------------------------------------------
## Procedural assembly: 2×2 cell quadrants on the 20×14 grid, seam doors,
## banded entity placement. The seeded PrngSeeder is the ONLY randomness and
## it lives at bake time — the frozen .tres is what ships.
## ---------------------------------------------------------------------------

const SPAWN_TILE: Array = [2, 2]
const EXIT_TILE: Array = [17, 11]  # SE cell local (7,4) — r4 is open in every cell

## The four inner-seam 2×2 doorway openings (cell ports on the shared edges).
const SEAM_DOORS: Array = [
	[[9, 3], [10, 3], [9, 4], [10, 4]],    # vertical seam, north
	[[9, 10], [10, 10], [9, 11], [10, 11]], # vertical seam, south
	[[4, 6], [5, 6], [4, 7], [5, 7]],       # horizontal seam, west
	[[14, 6], [15, 6], [14, 7], [15, 7]],   # horizontal seam, east
]
const KEY_TILE: Array = [7, 1]  # NW cell r1 x7 — open in every authored cell

## Entity candidate spots per quadrant (LOCAL cell coords). All sit on rows
## 2/4 which are open floor in every authored cell.
const FOOD_CANDIDATES: Array = [[1, 2], [3, 2], [5, 2], [8, 2], [1, 4], [3, 4], [5, 4], [8, 4]]
const GEN_SPOTS: Array = [[7, 2], [7, 2], [7, 4], [2, 2]]      # NW, NE, SW, SE
const ENEMY_SPOTS: Array = [[2, 4], [2, 4]]                     # NE, SW
const CHEST_GENERIC_SPOTS: Array = [[4, 4], [4, 2], [4, 4], [4, 2]]  # NW, NE, SW, SE
const POTION_SPOTS: Array = [[6, 4], [6, 2]]                    # SW, NE

const GEN_COUNT_BY_ZONE: Array = [2, 2, 3, 3]
const POTION_COUNT_BY_ZONE: Array = [1, 2, 2, 2]
const CHEST_TARGET_BY_ZONE: Array = [2, 2, 3, 3]
const GEN_TYPES_BY_ZONE: Array = [[0, 1], [2, 3], [3, 4], [4, 3]]
const ENEMY_TYPE_BY_ZONE: Array = [0, 1, 2, 4]

func _quadrant_origin(q: int) -> Vector2i:
	match q:
		0: return Vector2i(0, 0)
		1: return Vector2i(10, 0)
		2: return Vector2i(0, 7)
		_: return Vector2i(10, 7)

func _assemble_floor(fn: int, zone: int, rng: PrngSeeder, tunables: TunablesLoader) -> Dictionary:
	var cells: Array = _cell_lib.cells_for_zone(zone)
	var chosen: Array = []
	var chosen_ids: Array = []
	for q in range(4):
		var cell: Dictionary = cells[rng.next_range(cells.size())]
		chosen.append(cell)
		chosen_ids.append(cell.id)

	# compose the 20×14 grid from the four quadrants
	var rows: Array = []
	for gy in range(14):
		var row: String = ""
		for gx in range(20):
			var q: int = (0 if gx < 10 else 1) + (0 if gy < 7 else 2)
			var lx: int = gx % CELL_W
			var ly: int = gy % CELL_H
			row += String(chosen[q].rows[ly])[lx]
		rows.append(row)
	# re-seal the outer perimeter (outer-facing cell ports close against it)
	rows[0] = "####################"
	rows[13] = "####################"
	for y in range(1, 13):
		var r: String = rows[y]
		rows[y] = "#" + r.substr(1, 18) + "#"
	# stamp the exit
	var ex: int = EXIT_TILE[0]
	var ey: int = EXIT_TILE[1]
	rows[ey] = rows[ey].left(ex) + "X" + rows[ey].substr(ex + 1)

	var occupied: Dictionary = {}
	occupied["%d,%d" % [SPAWN_TILE[0], SPAWN_TILE[1]]] = "spawn"
	occupied["%d,%d" % [ex, ey]] = "exit"

	var doors_out: PackedVector2Array = PackedVector2Array()
	var keys_out: PackedVector2Array = PackedVector2Array()
	# ~half the floors earn a keyed seam door (the key always spawns in the NW
	# quadrant, reachable before any door opens — solver gate 3 proves it)
	if rng.next_float() < 0.5:
		var seam: Array = SEAM_DOORS[rng.next_range(SEAM_DOORS.size())]
		for dv in seam:
			var dx: int = dv[0]
			var dy: int = dv[1]
			rows[dy] = rows[dy].left(dx) + "D" + rows[dy].substr(dx + 1)
			doors_out.append(Vector2(Vector2i(dx, dy)))
			occupied["%d,%d" % [dx, dy]] = "door"
		keys_out.append(Vector2(Vector2i(KEY_TILE[0], KEY_TILE[1])))
		occupied["%d,%d" % [KEY_TILE[0], KEY_TILE[1]]] = "key"

	# hazards (zone contract) — placed before pickups so occupancy rejects
	var hazards_out: Array = []
	if zone == 1:
		hazards_out.append({"type": 0, "trigger": 0, "phase": 0, "tiles": [Vector2i(13, 4), Vector2i(14, 4)]})
	elif zone == 2:
		# the void bridge rides a seam opening the door did not claim
		var bridge: Array = [[14, 6], [15, 6], [14, 7], [15, 7]]
		for dv in bridge:
			if occupied.has("%d,%d" % [dv[0], dv[1]]):
				bridge = [[4, 6], [5, 6], [4, 7], [5, 7]]
				break
		var bridge_tiles: Array = []
		for dv in bridge:
			bridge_tiles.append(Vector2i(dv[0], dv[1]))
		hazards_out.append({"type": 1, "trigger": 0, "phase": 0, "tiles": bridge_tiles})
	elif zone == 3:
		hazards_out.append({
			"type": 2, "trigger": 2, "phase": 0,
			"tiles": [Vector2i(13, 11), Vector2i(14, 11), Vector2i(3, 9), Vector2i(4, 9)],
		})

	var foods_out: PackedVector2Array = PackedVector2Array()
	var potions_out: PackedVector2Array = PackedVector2Array()
	var chests_out: Array = []
	var gens_out: Array = []
	var enemies_out: Array = []

	# chests: treasure cells' spots first (authoring rule 4: exactly 1 chest
	# per treasure cell), then generic spots up to the zone target
	var tiers: Array = ["low", "mid", "high"]
	var tier_i: int = 0
	for q in range(4):
		var cell: Dictionary = chosen[q]
		if cell.chest_spot is Array and not cell.chest_spot.is_empty() and chests_out.size() < CHEST_TARGET_BY_ZONE[zone]:
			var origin: Vector2i = _quadrant_origin(q)
			var cx: int = origin.x + int(cell.chest_spot[0])
			var cy: int = origin.y + int(cell.chest_spot[1])
			var key: String = "%d,%d" % [cx, cy]
			if not occupied.has(key) and rows[cy][cx] == ".":
				occupied[key] = "chest"
				chests_out.append({"x": cx, "y": cy, "value": _chest_value(tiers[tier_i % tiers.size()], zone, tunables)})
				tier_i += 1
	for q in range(4):
		if chests_out.size() >= CHEST_TARGET_BY_ZONE[zone]:
			break
		var origin: Vector2i = _quadrant_origin(q)
		var spot: Array = CHEST_GENERIC_SPOTS[q]
		var cx: int = origin.x + spot[0]
		var cy: int = origin.y + spot[1]
		var key: String = "%d,%d" % [cx, cy]
		if not occupied.has(key) and rows[cy][cx] == ".":
			occupied[key] = "chest"
			chests_out.append({"x": cx, "y": cy, "value": _chest_value(tiers[tier_i % tiers.size()], zone, tunables)})
			tier_i += 1

	# generators on the fixed quadrant spots
	var gen_types: Array = GEN_TYPES_BY_ZONE[zone]
	for g_i in range(GEN_COUNT_BY_ZONE[zone]):
		var origin: Vector2i = _quadrant_origin(g_i)
		var spot: Array = GEN_SPOTS[g_i]
		var gx: int = origin.x + spot[0]
		var gy: int = origin.y + spot[1]
		var key: String = "%d,%d" % [gx, gy]
		if not occupied.has(key) and rows[gy][gx] == ".":
			occupied[key] = "generator"
			gens_out.append({"x": gx, "y": gy, "enemy_type": int(gen_types[g_i % gen_types.size()])})

	# one scripted patrol enemy
	var e_origin: Vector2i = _quadrant_origin(1)
	var e_spot: Array = ENEMY_SPOTS[0]
	var ex2: int = e_origin.x + e_spot[0]
	var ey2: int = e_origin.y + e_spot[1]
	if not occupied.has("%d,%d" % [ex2, ey2]) and rows[ey2][ex2] == ".":
		occupied["%d,%d" % [ex2, ey2]] = "enemy"
		enemies_out.append({"x": ex2, "y": ey2, "type": int(ENEMY_TYPE_BY_ZONE[zone])})

	# potions
	for p_i in range(POTION_COUNT_BY_ZONE[zone]):
		var q: int = 2 if p_i == 0 else 1  # SW then NE
		var origin: Vector2i = _quadrant_origin(q)
		var spot: Array = POTION_SPOTS[p_i]
		var px: int = origin.x + spot[0]
		var py: int = origin.y + spot[1]
		var key: String = "%d,%d" % [px, py]
		if not occupied.has(key) and rows[py][px] == ".":
			occupied[key] = "potion"
			potions_out.append(Vector2(Vector2i(px, py)))

	# food: exactly the G2 §3 locked solver count, quadrant round-robin with
	# seeded candidate draws + occupancy rejection
	var band: int = RulesSolverCheck.band_for_floor(fn)
	var food_need: int = RulesSolverCheck.food_pieces_for_band(band, tunables)
	var quad_order: Array = [0, 1, 2, 3]
	var placed_food: int = 0
	var rounds: int = 0
	while placed_food < food_need and rounds < 64:
		var q: int = quad_order[rounds % 4]
		var origin: Vector2i = _quadrant_origin(q)
		var cand: Array = FOOD_CANDIDATES[rng.next_range(FOOD_CANDIDATES.size())]
		var fx: int = origin.x + cand[0]
		var fy: int = origin.y + cand[1]
		var key: String = "%d,%d" % [fx, fy]
		if not occupied.has(key) and rows[fy][fx] == ".":
			occupied[key] = "food"
			foods_out.append(Vector2(Vector2i(fx, fy)))
			placed_food += 1
		rounds += 1

	var fd: FloorData = FloorData.new()
	fd.floor_number = fn
	fd.zone = zone
	var packed_rows: PackedStringArray = PackedStringArray()
	for r in rows:
		packed_rows.append(r)
	fd.tiles = packed_rows
	fd.spawn = Vector2i(SPAWN_TILE[0], SPAWN_TILE[1])
	fd.exit_pos = Vector2i(ex, ey)
	fd.doors = doors_out
	fd.keys = keys_out
	fd.foods = foods_out
	fd.potions = potions_out
	fd.chests = chests_out
	fd.generators = gens_out
	fd.initial_enemies = enemies_out
	fd.hazards = hazards_out
	_stamp_band_fields(fd, fn, zone, tunables)
	return {"floor_data": fd, "cells": chosen_ids}
