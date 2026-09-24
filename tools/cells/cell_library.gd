extends RefCounted
## HUNGERHALL — tools/cells/ (G6 §2, G2 §7). The 48 hand-authored 10×7-tile
## room cells (12 per zone) + the 7 hand-built full-floor definitions
## (F1, F2, F3, F6, F12, F18, F24). BUILD-TIME DATA ONLY — nothing here is
## runtime logic; tools/floor_baker.gd assembles + gates + freezes these into
## data/floors/base/floor_01..24.tres. Runtime contains ZERO layout RNG.
##
## Cell contract (G2 §7 authoring rules):
##  - 10 cols × 7 rows; chars '#' wall, '.' floor, 'V' void pocket.
##  - Ports are the standardized 2-tile openings: N=(4,0),(5,0);
##    S=(4,6),(5,6); W=(0,3),(0,4); E=(9,3),(9,4). Every cell carries all
##    four, so ANY two cells align on a shared edge (inter-cell
##    compatibility rule: ports at the same position on the shared edge).
##  - (1) every port reaches every other port inside the cell (verified by
##    the baker before assembly); (2) generators are never placed within 4
##    tiles of a port (enforced by the baker's ≥4-from-spawn + placement
##    gates); (3) all corridors ≥2 tiles wide — no '.' tile pinched between
##    two blocking tiles on either axis (solver gate 4, verified per cell);
##    (4) treasure cells contain exactly 1 chest (chest_spot below).
##
## Wall-placement law these cells obey (consequence of rule 3 against the
## cell's own wall ring): horizontal walls live on rows 1/3/5 only, never
## stacked on the same column across adjacent wall rows; vertical features
## stay on cols 1/3-6/8 with the same care. That yields the wide-pillared
## vault rooms the hall's combat reads at speed.

## ---------------------------------------------------------------------------
## Base cell archetypes (audited pinch-free; baker re-verifies every cell)
## ---------------------------------------------------------------------------

static func _corridor_a() -> Array:
	return [
		"####..####",
		"#..#..#..#",
		"#........#",
		"....##....",
		"..........",
		"#........#",
		"####..####",
	]

static func _corridor_b() -> Array:
	return [
		"####..####",
		"#..#..#..#",
		"#........#",
		"....##....",
		"..........",
		"#..#..#..#",
		"####..####",
	]

static func _corridor_c() -> Array:
	return [
		"####..####",
		"##......##",
		"#........#",
		"....##....",
		"..........",
		"#........#",
		"####..####",
	]

static func _arena_a() -> Array:
	return [
		"####..####",
		"#........#",
		"#........#",
		"...####...",
		"..........",
		"#........#",
		"####..####",
	]

static func _arena_b() -> Array:
	return [
		"####..####",
		"##.......#",
		"#........#",
		"...####...",
		"..........",
		"#.......##",
		"####..####",
	]

static func _arena_b_mir() -> Array:
	return [
		"####..####",
		"#.......##",
		"#........#",
		"...####...",
		"..........",
		"##.......#",
		"####..####",
	]

static func _choke_a() -> Array:
	return [
		"####..####",
		"#........#",
		"#........#",
		"..######..",
		"..........",
		"#........#",
		"####..####",
	]

static func _choke_b() -> Array:
	return [
		"####..####",
		"##......##",
		"#........#",
		"..######..",
		"..........",
		"##......##",
		"####..####",
	]

static func _treasure_a() -> Array:
	# chest pocket (5,3): pillar pair at (2,3)-(3,3) guards the left approach;
	# the 2-wide gap from (4,3) onward keeps the corridor pinch-free (rule 3).
	return [
		"####..####",
		"#........#",
		"#........#",
		"...##.....",
		"..........",
		"##......##",
		"####..####",
	]

static func _treasure_a_mir() -> Array:
	# chest pocket (4,3): mirror of _treasure_a — pillar pair at (5,3)-(6,3).
	return [
		"####..####",
		"#........#",
		"#........#",
		".....##...",
		"..........",
		"##......##",
		"####..####",
	]

static func _hub_a() -> Array:
	return [
		"####..####",
		"#........#",
		"#........#",
		"...#..#...",
		"..........",
		"##......##",
		"####..####",
	]

static func _hub_b() -> Array:
	return [
		"####..####",
		"##......##",
		"#........#",
		"....##....",
		"..........",
		"##......##",
		"####..####",
	]

## The per-zone 12-cell roster (3 corridor / 3 arena / 2 choke / 2 treasure
## / 2 hub), order-stable so a given seed always bakes the same floors.
static func _base_roster() -> Array:
	return [
		{"type": "corridor", "rows": _corridor_a(), "chest_spot": []},
		{"type": "corridor", "rows": _corridor_b(), "chest_spot": []},
		{"type": "corridor", "rows": _corridor_c(), "chest_spot": []},
		{"type": "arena", "rows": _arena_a(), "chest_spot": []},
		{"type": "arena", "rows": _arena_b(), "chest_spot": []},
		{"type": "arena", "rows": _arena_b_mir(), "chest_spot": []},
		{"type": "choke", "rows": _choke_a(), "chest_spot": []},
		{"type": "choke", "rows": _choke_b(), "chest_spot": []},
		{"type": "treasure", "rows": _treasure_a(), "chest_spot": [5, 3]},
		{"type": "treasure", "rows": _treasure_a_mir(), "chest_spot": [4, 3]},
		{"type": "hub", "rows": _hub_a(), "chest_spot": []},
		{"type": "hub", "rows": _hub_b(), "chest_spot": []},
	]

## Zone dressing (keeps each of the 48 cells an explicit authored entry):
## zone 0 Drowned Vaults — clean wet stone.
## zone 1 Cindercrypt — burnt pillar nubs in two dead corners ('#').
## zone 2 Starved Deep — void pockets in two dead corners ('V').
## zone 3 The Hollow Throne — void pockets in all four dead corners ('V').
## Corners (1,1),(8,1),(1,5),(8,5) are pinch-safe dressings: a corner block
## can never pinch a neighbour (each corner touches at most one walkable
## tile per axis), and they never touch a port route.
## Pinch guard: a dressing block is SKIPPED if it would squeeze an adjacent
## floor tile to 1-wide on either axis (rule 3). The corner claim above was
## wrong for cells whose row-1/5 pillar pattern already walls the far side
## of the dressing neighbour (corridor_a/b) — the guard makes it honest.
static func _dress(rows: Array, zone: int) -> Array:
	var out: Array = []
	for r in rows:
		out.append(String(r))
	if zone == 0:
		return out
	var spots_2: Array = [[1, 1], [8, 5]]
	var spots_4: Array = [[1, 1], [8, 1], [1, 5], [8, 5]]
	var spots: Array = spots_4 if zone == 3 else spots_2
	var ch: String = "V" if zone >= 2 else "#"
	for s in spots:
		var x: int = s[0]
		var y: int = s[1]
		var row: String = out[y]
		if row[x] == ".":
			if _would_pinch(out, x, y):
				continue
			out[y] = row.left(x) + ch + row.substr(x + 1)
	return out

## Returns true if placing a block at (x,y) would pinch any orthogonal
## floor-tile neighbour to 1-wide on the same axis (authoring rule 3).
static func _would_pinch(rows: Array, x: int, y: int) -> bool:
	var W: int = 10
	var H: int = 7
	var dirs: Array = [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]
	for d in dirs:
		var nx: int = x + d.x
		var ny: int = y + d.y
		if nx < 0 or nx >= W or ny < 0 or ny >= H:
			continue
		if String(rows[ny])[nx] != ".":
			continue
		# the neighbour is floor; check its opposite-side tile along the
		# same axis — if that is already blocking, the new block squeezes it.
		var ox: int = nx + d.x
		var oy: int = ny + d.y
		var opp_blocking: bool = true
		if ox >= 0 and ox < W and oy >= 0 and oy < H:
			var c: String = String(rows[oy])[ox]
			opp_blocking = (c == "#" or c == "V")
		if opp_blocking:
			return true
	return false

## 12 authored cells for one zone (0..3). Each: {id, zone, type, rows,
## chest_spot: [x,y] or []}.
static func cells_for_zone(zone: int) -> Array:
	var roster: Array = _base_roster()
	var out: Array = []
	for i in range(roster.size()):
		var base: Dictionary = roster[i]
		out.append({
			"id": "z%d_c%02d" % [zone, i],
			"zone": zone,
			"type": base.type,
			"rows": _dress(base.rows, zone),
			"chest_spot": base.chest_spot,
		})
	return out

## ---------------------------------------------------------------------------
## The 7 hand-built floors (G2 §7 role table). Each returns the FULL floor
## definition the baker gates and freezes: rows 14×20, spawn, exit, and all
## baked entity placements. No doors/hazards may violate the zone contract.
## ---------------------------------------------------------------------------

static func handbuilt_floor_numbers() -> Array:
	return [1, 2, 3, 6, 12, 18, 24]

static func handbuilt(fn: int) -> Dictionary:
	match fn:
		1: return _f1()
		2: return _f2()
		3: return _f3()
		6: return _f6()
		12: return _f12()
		18: return _f18()
		24: return _f24()
		_: return {}

## F1 — teaches move/throw/kill/generator through shape alone. Open vault,
## one ghost cloche, a single low chest naming the treasure verb. No doors,
## no hazards (zone 0), food ≥ band-1 solver count (3 → 4 baked).
static func _f1() -> Dictionary:
	return {
		"rows": [
			"####################",
			"#..................#",
			"#..................#",
			"#...##......##.....#",
			"#...##......##.....#",
			"#..................#",
			"#..................#",
			"#........##........#",
			"#........##........#",
			"#..................#",
			"#..................#",
			"#................X.#",
			"#..................#",
			"####################",
		],
		"spawn": [2, 2], "exit": [17, 11],
		"doors": [], "keys": [],
		"foods": [[5, 2], [14, 6], [3, 9], [16, 9]],
		"potions": [],
		"chests": [{"pos": [16, 2], "tier": "low"}],
		"generators": [{"pos": [10, 5], "enemy_type": 0}],  # ghost
		"initial_enemies": [],
		"hazards": [],
	}

## F2 — first key/door gate; food placement forces the first greedy detour
## (two pieces sit far off the spawn→key→door→exit spine).
static func _f2() -> Dictionary:
	return {
		"rows": [
			"####################",
			"#..................#",
			"#..................#",
			"#...##....##.......#",
			"#...##....##.......#",
			"#..................#",
			"#..................#",
			"#########DD#########",
			"#..................#",
			"#..................#",
			"#......##...##.....#",
			"#...............X..#",
			"#..................#",
			"####################",
		],
		"spawn": [2, 2], "exit": [16, 11],
		"doors": [[9, 7], [10, 7]],
		"keys": [[16, 3]],
		"foods": [[2, 1], [17, 5], [5, 5], [12, 9]],
		"potions": [],
		"chests": [{"pos": [4, 9], "tier": "low"}],
		"generators": [{"pos": [8, 9], "enemy_type": 1}],  # grunt
		"initial_enemies": [],
		"hazards": [],
	}

## F3 — potions and treasure; first overlapping generator pair (their spawn
## fields intersect mid-floor).
static func _f3() -> Dictionary:
	return {
		"rows": [
			"####################",
			"#..................#",
			"#..................#",
			"#..##..........##..#",
			"#..##..........##..#",
			"#..................#",
			"#.......##.........#",
			"#.......##.........#",
			"#..................#",
			"#..................#",
			"#...##........##...#",
			"#................X.#",
			"#..................#",
			"####################",
		],
		"spawn": [2, 2], "exit": [17, 11],
		"doors": [], "keys": [],
		"foods": [[2, 1], [17, 1], [9, 5], [3, 8], [16, 8], [9, 12]],
		"potions": [[2, 8], [17, 2]],
		"chests": [{"pos": [5, 6], "tier": "low"}, {"pos": [13, 9], "tier": "mid"}],
		"generators": [
			{"pos": [10, 5], "enemy_type": 0},  # ghost
			{"pos": [12, 6], "enemy_type": 1},  # grunt — overlapping pair
		],
		"initial_enemies": [],
		"hazards": [],
	}

## F6 — zone-one capstone: every taught verb examined at once. Two doorway
## runs, two keys, three chests (full tier ladder), three cloches.
static func _f6() -> Dictionary:
	return {
		"rows": [
			"####################",
			"#..................#",
			"#..................#",
			"#...##.......##....#",
			"#..................#",
			"#..................#",
			"######DD######DD####",
			"#..................#",
			"#..................#",
			"#......##....##....#",
			"#......##....##....#",
			"#................X.#",
			"#..................#",
			"####################",
		],
		"spawn": [2, 2], "exit": [17, 11],
		"doors": [[6, 6], [7, 6], [14, 6], [15, 6]],
		"keys": [[3, 2], [17, 2]],
		"foods": [[9, 1], [16, 4], [3, 8], [16, 8], [4, 12], [10, 12]],
		"potions": [[12, 9]],
		"chests": [
			{"pos": [2, 7], "tier": "low"},
			{"pos": [9, 8], "tier": "mid"},
			{"pos": [17, 12], "tier": "high"},
		],
		"generators": [
			{"pos": [9, 4], "enemy_type": 0},
			{"pos": [4, 10], "enemy_type": 0},
			{"pos": [15, 10], "enemy_type": 1},
		],
		"initial_enemies": [{"pos": [12, 2], "type": 0}],
		"hazards": [],
	}

## F12 — zone-two capstone: Lobber-over-wall + Sorcerer combined arms behind
## a keyed seam door; flame jets police the two main lanes.
static func _f12() -> Dictionary:
	return {
		"rows": [
			"####################",
			"#..................#",
			"#..................#",
			"#..##..........##..#",
			"#.............#....#",
			"#....######...#....#",
			"#....######...D....#",
			"#.............D....#",
			"#.............#....#",
			"#.............#....#",
			"#........##...#....#",
			"#...............X..#",
			"#..................#",
			"####################",
		],
		"spawn": [2, 2], "exit": [16, 11],
		"doors": [[14, 6], [14, 7]],
		"keys": [[2, 12]],
		"foods": [[2, 1], [9, 1], [17, 2], [2, 7], [8, 8], [12, 4], [16, 4], [12, 12]],
		"potions": [[3, 4], [11, 8]],
		"chests": [
			{"pos": [2, 4], "tier": "low"},
			{"pos": [7, 12], "tier": "mid"},
			{"pos": [17, 4], "tier": "high"},
		],
		"generators": [
			{"pos": [8, 2], "enemy_type": 3},   # lobber — lobs over the long wall
			{"pos": [3, 8], "enemy_type": 4},   # sorcerer
			{"pos": [12, 11], "enemy_type": 2}, # demon
		],
		"initial_enemies": [
			{"pos": [12, 7], "type": 3},  # lobber
			{"pos": [4, 10], "type": 4},  # sorcerer — combined arms
		],
		"hazards": [
			{"type": 0, "trigger": 0, "phase": 0, "tiles": [[9, 7], [10, 7]]},
			{"type": 0, "trigger": 0, "phase": 60, "tiles": [[6, 9], [7, 9]]},
		],
	}

## F18 — zone-three capstone: Death + twin larder generators, reached across
## a single void bridge that phases between walkable and void.
static func _f18() -> Dictionary:
	return {
		"rows": [
			"####################",
			"#..................#",
			"#..................#",
			"#..##..........##..#",
			"#..................#",
			"#..................#",
			"#VVVVVVV....VVVVVVV#",
			"#VVVVVVV....VVVVVVV#",
			"#..................#",
			"#..................#",
			"#..................#",
			"#................X.#",
			"#..................#",
			"####################",
		],
		"spawn": [2, 2], "exit": [17, 11],
		"doors": [], "keys": [],
		"foods": [
			[2, 1], [9, 1], [17, 4], [5, 4], [8, 5], [2, 8],
			[17, 8], [3, 12], [8, 12], [12, 12], [16, 12], [10, 9],
		],
		"potions": [[16, 4], [3, 9]],
		"chests": [
			{"pos": [2, 11], "tier": "low"},
			{"pos": [16, 9], "tier": "mid"},
			{"pos": [12, 1], "tier": "high"},
		],
		"generators": [
			{"pos": [6, 10], "enemy_type": 3},  # twin larders
			{"pos": [13, 10], "enemy_type": 3},
		],
		"initial_enemies": [
			{"pos": [10, 8], "type": 5},  # DEATH
			{"pos": [4, 8], "type": 4},   # sorcerer
		],
		"hazards": [
			{
				"type": 1, "trigger": 0, "phase": 0,
				"tiles": [[8, 6], [9, 6], [10, 6], [11, 6], [8, 7], [9, 7], [10, 7], [11, 7]],
			},
		],
	}

## F24 — finale: Death, three throne generators, a keyed sealing door over
## the exit chamber, and collapsing void that eats the approach behind you.
static func _f24() -> Dictionary:
	return {
		"rows": [
			"####################",
			"#..................#",
			"#..................#",
			"#..##..........##..#",
			"#..................#",
			"#..................#",
			"#############DD#####",
			"#..................#",
			"#..................#",
			"#....##.......##...#",
			"#....##.......##...#",
			"#..................#",
			"#...............X..#",
			"####################",
		],
		"spawn": [2, 2], "exit": [16, 12],
		"doors": [[13, 6], [14, 6]],
		"keys": [[17, 2]],
		"foods": [
			[2, 1], [9, 1], [16, 1], [5, 4], [14, 4], [8, 5], [17, 5], [3, 5],
			[2, 7], [17, 7], [3, 11], [8, 11], [12, 12], [17, 12], [9, 10], [15, 8],
		],
		"potions": [[4, 4], [15, 5], [2, 12]],
		"chests": [
			{"pos": [3, 8], "tier": "low"},
			{"pos": [16, 8], "tier": "mid"},
			{"pos": [12, 1], "tier": "high"},
		],
		"generators": [
			{"pos": [8, 8], "enemy_type": 4},
			{"pos": [11, 8], "enemy_type": 4},
			{"pos": [16, 9], "enemy_type": 3},
		],
		"initial_enemies": [{"pos": [10, 11], "type": 5}],  # DEATH
		"hazards": [
			{
				"type": 2, "trigger": 2, "phase": 0,
				"tiles": [[9, 7], [10, 7], [11, 7], [2, 8], [17, 8], [15, 11]],
			},
		],
	}
