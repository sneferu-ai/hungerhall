class_name SneferuBot
extends RefCounted
## G6 §GODOT PLAYTEST CONTRACT — machine-verified bot.
## Drives RulesSession through the SAME core rules the product uses.
## Three policies (GODOT PLAYTEST CONTRACT: at least one LOSABLE agent so
## completed games include real terminal states):
##   0 = min_skill — the G2 §7 minimum-skill agent: greedy objective chain,
##       attacks nearest enemy within 3 tiles, consumes food on contact,
##       does NOT dodge projectiles, kite, use potions, or hit generators.
##       It dies — burning both continue tokens — and yields GAME_OVER.
##   1 = completionist — sweeps rooms beyond the route, uses potions.
##   2 = speedrun — point-blank shots only, keeps moving, uses potions late.
## Writes playtest_telemetry_v1 JSON. NO second toy implementation.

const State = StateEnums.State
const TILE: int = 32  # why: shared tile size — RulesFloor pixel<->tile math

# G9 DoD #6 result codes (machine-play seam, exact):
#   0=complete 1=timeout 2=crash 3=invalid_state 4=impossible_progress 5=loop_detected
const RESULT_COMPLETE: int = 0
const RESULT_TIMEOUT: int = 1
const RESULT_CRASH: int = 2            # unreachable in-process (a crash kills the process); kept for schema completeness
const RESULT_INVALID_STATE: int = 3
const RESULT_IMPOSSIBLE_PROGRESS: int = 4
const RESULT_LOOP_DETECTED: int = 5
const LOOP_RING_SIZE: int = 256        # 128-tick history + 128-tick confirmation
const LOOP_CYCLE_LEN: int = 128

var session: RulesSession = RulesSession.new()
var tunables: TunablesLoader = TunablesLoader.new()
var classes: Array = []
var telemetry_out: String = ""
var games_target: int = 200
var seed_value: int = 1
var frame_budget: int = 36000

# why: per-level aggregate stats keyed by floor number
var level_stats: Dictionary = {}
var games_played: int = 0
var games_completed: int = 0
# ---- G9 DoD #6 — juice telemetry seam (rules truth, headless) ----
var _juice: JuiceDirector = null       # per-game headless recorder (out-of-tree)
var _juice_events: Array = []          # [{game, event, step}] bounded by JUICE_EVENTS_CAP
var _juice_event_total: int = 0
var _result_counts: Dictionary = {
	"complete": 0, "timeout": 0, "crash": 0,
	"invalid_state": 0, "impossible_progress": 0, "loop_detected": 0,
}
var _loop_ring: Array = []
const JUICE_EVENTS_CAP: int = 4096

func setup(args: Dictionary) -> Dictionary:
	telemetry_out = str(args.get("telemetry-out", ""))
	games_target = int(args.get("games", 200))
	seed_value = int(args.get("seed", 1))
	frame_budget = int(args.get("frame-budget", 36000))
	if games_target < 1:
		games_target = 1
	if frame_budget < 1:
		frame_budget = 1
	if not tunables.load_from_path("res://Tunables.json"):
		return {"ok": false, "error": "Tunables.json load failed: " + str(tunables.errors())}
	_build_classes()
	if classes.is_empty():
		return {"ok": false, "error": "no class defs built"}
	return {"ok": true}

func _build_classes() -> void:
	classes.clear()
	for ct in [StateEnums.ClassType.WARRIOR, StateEnums.ClassType.VALKYRIE, StateEnums.ClassType.WIZARD, StateEnums.ClassType.ELF]:
		var cd: ClassDef = ClassDef.new()
		cd.class_type = ct
		match ct:
			StateEnums.ClassType.WARRIOR:
				cd.display_name = "WARRIOR"
				cd.sprite_frames_ref = "res://Assets/warrior-main_sheet.png"
				cd.still_ref = "res://Assets/warrior-main.png"
				cd.potion_type = StateEnums.PotionType.WHIRLWIND
				cd.hp = int(tunables.get_value("warrior_hp", 800))
				cd.speed = int(tunables.get_value("warrior_speed", 128))
				cd.shot_dmg = int(tunables.get_value("warrior_shot_dmg", 50))
				cd.shot_range_tiles = int(tunables.get_value("warrior_shot_range_tiles", 5))
				cd.shot_rate_per_sec = tunables.get_value("warrior_shot_rate", 1.2)
				cd.projectile_kind = "axe"
				cd.projectile_ref = "res://Assets/projectile-axe.png"
			StateEnums.ClassType.VALKYRIE:
				cd.display_name = "VALKYRIE"
				cd.sprite_frames_ref = "res://Assets/valkyrie-main_sheet.png"
				cd.still_ref = "res://Assets/valkyrie-main.png"
				cd.potion_type = StateEnums.PotionType.AEGIS
				cd.hp = int(tunables.get_value("valkyrie_hp", 680))
				cd.speed = int(tunables.get_value("valkyrie_speed", 152))
				cd.shot_dmg = int(tunables.get_value("valkyrie_shot_dmg", 30))
				cd.shot_range_tiles = int(tunables.get_value("valkyrie_shot_range_tiles", 7))
				cd.shot_rate_per_sec = tunables.get_value("valkyrie_shot_rate", 1.6)
				cd.projectile_kind = "spear"
				cd.projectile_ref = "res://Assets/projectile-spear.png"
			StateEnums.ClassType.WIZARD:
				cd.display_name = "WIZARD"
				cd.sprite_frames_ref = "res://Assets/wizard-main_sheet.png"
				cd.still_ref = "res://Assets/wizard-main.png"
				cd.potion_type = StateEnums.PotionType.NOVA
				cd.hp = int(tunables.get_value("wizard_hp", 520))
				cd.speed = int(tunables.get_value("wizard_speed", 144))
				cd.shot_dmg = int(tunables.get_value("wizard_shot_dmg", 20))
				cd.shot_range_tiles = int(tunables.get_value("wizard_shot_range_tiles", 6))
				cd.shot_rate_per_sec = tunables.get_value("wizard_shot_rate", 1.2)
				cd.projectile_kind = "bolt"
				cd.projectile_ref = "res://Assets/projectile-bolt.png"
			StateEnums.ClassType.ELF:
				cd.display_name = "ELF"
				cd.sprite_frames_ref = "res://Assets/elf-main_sheet.png"
				cd.still_ref = "res://Assets/elf-main.png"
				cd.potion_type = StateEnums.PotionType.VOLLEY
				cd.hp = int(tunables.get_value("elf_hp", 560))
				cd.speed = int(tunables.get_value("elf_speed", 192))
				cd.shot_dmg = int(tunables.get_value("elf_shot_dmg", 15))
				cd.shot_range_tiles = int(tunables.get_value("elf_shot_range_tiles", 10))
				cd.shot_rate_per_sec = tunables.get_value("elf_shot_rate", 3.0)
				cd.projectile_kind = "arrow"
				cd.projectile_ref = "res://Assets/projectile-arrow.png"
		classes.append(cd)

func run() -> Dictionary:
	var frames_used: int = 0
	var game_idx: int = 0
	while game_idx < games_target and frames_used < frame_budget:
		var class_idx: int = game_idx % classes.size()
		var policy: int = game_idx % 3  # 0=min_skill(losable), 1=completionist, 2=speedrun
		var cd: ClassDef = classes[class_idx]
		var game_seed: int = seed_value + game_idx * 7919
		session = RulesSession.new()
		session.setup_campaign(tunables, cd, game_seed)
		games_played += 1
		# G9 DoD #6 — headless juice recorder: juice_events are recorded from
		# the RULES truth (consume_pending cues + snapshot deltas), stepped once
		# per fixed rule tick, exactly as the mounted director is stepped by
		# main.gd in human play. Out-of-tree by design (the bot never mounts a
		# presentation tree); setup() mounts the sub-manager ledgers headlessly.
		_juice = _new_juice_recorder()
		_loop_ring.clear()
		var outcome: Dictionary = _play_game(policy, frames_used)
		frames_used += int(outcome.get("frames", 0))
		_collect_juice_events(game_idx)
		_record_result(int(outcome.get("result", RESULT_COMPLETE)))
		game_idx += 1
	return _write_telemetry()

func _play_game(policy: int, frames_before: int) -> Dictionary:
	var frames: int = 0
	var max_frames: int = 18000  # 5 minutes per game max
	var entered_floors: Dictionary = {}  # floor -> entered count
	var result_code: int = RESULT_TIMEOUT  # budget exhaustion is the default terminal
	var prev_floor: int = session.floor_number
	while frames < max_frames and (frames_before + frames) < frame_budget:
		# why: track floor entry for per-level stats
		var current_floor: int = session.floor_number
		if not entered_floors.has(current_floor):
			entered_floors[current_floor] = true
			_ensure_level_stat(current_floor)
			level_stats[current_floor].plays += 1
			level_stats[current_floor].move_limit = session.floor.target_seconds * 60
		# why: drive the bot policy
		var inputs: Array = _decide_inputs(policy, current_floor)
		for inp in inputs:
			session.input(inp)
		session.step()
		frames += 1
		# ---- G9 DoD #6: feed the rules truth to the headless recorder ----
		if _juice != null:
			var pending: Dictionary = session.consume_pending()
			for cue in pending.get("cues", []):
				if cue is Dictionary:
					_juice.on_cue(cue)
			_juice.notify_snapshot(_slim_snapshot())
			_juice.step()
		# why: update level stats
		level_stats[current_floor].moves_accum += 1
		# why: G9 result-code invariants — impossible progress / invalid state
		# surface as telemetry, never as a hang.
		# Round-5 fix (gate FAILED round 4, impossible_progress 10/10): the
		# score-monotonicity clause was a pure death-penalty detector — G2 §2
		# LOCKS a -20%-of-floor-entry-score penalty on every death
		# (core/rules_score.gd on_death), so every dying bot game bailed before
		# the session could walk DYING → CONTINUE_OFFER → GAME_OVER where
		# games_completed increments. Score DROPPING is designed progress here,
		# never impossible progress. The remaining two clauses are true
		# invariants: floor_number has no decrement path in the rules, and
		# heal() clamps at max_hp (core/rules_player.gd), so either firing is a
		# genuine rules violation worth result code 4.
		if session.floor_number < prev_floor \
				or session.player.hp > session.player.max_hp:
			result_code = RESULT_IMPOSSIBLE_PROGRESS
			_finalize_level_avg(current_floor)
			return {"frames": frames, "result": result_code}
		prev_floor = session.floor_number
		if _loop_check():
			# why: a repeated 128-tick movement/progress cycle (oscillation) —
			# stationary starving is EXCLUDED (see _loop_check), so this only
			# fires on genuine cycles. The game yields telemetry, not a hang.
			result_code = RESULT_LOOP_DETECTED
			_finalize_level_avg(current_floor)
			return {"frames": frames, "result": result_code}
		# why: check state transitions
		match session.state:
			State.FLOOR_RESULTS:
				level_stats[current_floor].wins += 1
				if session.floor_number >= 24:
					games_completed += 1
					_finalize_level_avg(current_floor)
					return {"frames": frames, "result": RESULT_COMPLETE}
				# why: advance to next floor
				session.advance_floor()
			State.CAMPAIGN_RESULTS:
				games_completed += 1
				_finalize_level_avg(current_floor)
				return {"frames": frames, "result": RESULT_COMPLETE}
			State.GAME_OVER:
				games_completed += 1
				_finalize_level_avg(current_floor)
				return {"frames": frames, "result": RESULT_COMPLETE}
			State.CONTINUE_OFFER:
				# why: continue if tokens available, else game over
				if session.continue_state.has_tokens():
					session.decide_continue(true)
				else:
					session.decide_continue(false)
			State.DYING:
				pass  # why: dying auto-transitions to continue offer
			State.PLAYING:
				pass
			_:
				# why: any other session state is outside the machine-play
				# contract (campaign sessions only traverse the six states
				# above) — surface it instead of looping on it
				result_code = RESULT_INVALID_STATE
				_finalize_level_avg(current_floor)
				return {"frames": frames, "result": result_code}
	# why: frame budget exhausted — partial play is valid
	_finalize_level_avg(session.floor_number)
	return {"frames": frames, "result": result_code}

# ---- G9 DoD #6 helpers ----

func _new_juice_recorder() -> JuiceDirector:
	var d: JuiceDirector = JuiceDirector.new()
	d.setup(tunables, null)
	return d

func _slim_snapshot() -> Dictionary:
	# why: notify_snapshot only reads player/floor/score/class + ambient counts;
	# RulesSession.snapshot() serializes the full floor_view (280 tile rows) per
	# tick, which a 200-game bot run cannot afford. Same field names as
	# snapshot() — the director sees no difference.
	var gens: Array = []
	for g in session.generators:
		gens.append({"alive": g.alive})
	return {
		"player": {"hp": session.player.hp, "max_hp": session.player.max_hp},
		"floor": session.floor_number,
		"score": {"score": session.score.score},
		"class": session.hero_name,
		"generators": gens,
		"food_remaining": session.pickups.food_count(),
		"keys_held": session.player.keys,
		"potions": session.player.potions,
	}

func _loop_hash() -> int:
	# why: progress-relevant state signature. HP is DELIBERATELY excluded — the
	# hunger clock changes every tick while alive, and standing still to starve
	# is a legal (terminal-seeking) strategy, not a loop. A loop is a repeated
	# movement/progress cycle.
	var enemies_alive: int = 0
	for e in session.enemies:
		if e.alive:
			enemies_alive += 1
	var gens_alive: int = 0
	for g in session.generators:
		if g.alive:
			gens_alive += 1
	var tile: Vector2i = session.floor.pixel_to_tile(session.player.pos_x, session.player.pos_y, TILE)
	var h: int = int(session.state)
	h = (h * 131) + session.floor_number
	h = (h * 131) + tile.x
	h = (h * 131) + tile.y
	h = (h * 131) + session.score.score
	h = (h * 131) + session.player.keys
	h = (h * 131) + session.player.potions
	h = (h * 131) + enemies_alive
	h = (h * 131) + gens_alive
	h = (h * 131) + session.pickups.food_count()
	return h

func _loop_check() -> bool:
	_loop_ring.append(_loop_hash())
	if _loop_ring.size() > LOOP_RING_SIZE:
		_loop_ring.pop_front()
	if _loop_ring.size() < LOOP_RING_SIZE:
		return false
	# why: all-identical ring = stationary (waiting to starve) — valid play
	var first: int = int(_loop_ring[0])
	var stationary: bool = true
	for h in _loop_ring:
		if int(h) != first:
			stationary = false
			break
	if stationary:
		return false
	# why: last 128 hashes identical to the prior 128 = a repeating cycle
	for i in range(LOOP_CYCLE_LEN):
		if int(_loop_ring[i]) != int(_loop_ring[i + LOOP_CYCLE_LEN]):
			return false
	return true

func _collect_juice_events(game_idx: int) -> void:
	if _juice == null:
		return
	for e in _juice.juice_events:
		_juice_event_total += 1
		if _juice_events.size() < JUICE_EVENTS_CAP:
			_juice_events.append({"game": game_idx, "event": str(e.get("event", "")), "step": int(e.get("step", 0))})
	_juice.free()
	_juice = null

func _record_result(code: int) -> void:
	match code:
		RESULT_COMPLETE:
			_result_counts.complete += 1
		RESULT_TIMEOUT:
			_result_counts.timeout += 1
		RESULT_CRASH:
			_result_counts.crash += 1
		RESULT_INVALID_STATE:
			_result_counts.invalid_state += 1
		RESULT_IMPOSSIBLE_PROGRESS:
			_result_counts.impossible_progress += 1
		RESULT_LOOP_DETECTED:
			_result_counts.loop_detected += 1

func _overall_result() -> int:
	# why: severity order — any defective game dominates a clean batch
	if int(_result_counts.crash) > 0:
		return RESULT_CRASH
	if int(_result_counts.invalid_state) > 0:
		return RESULT_INVALID_STATE
	if int(_result_counts.impossible_progress) > 0:
		return RESULT_IMPOSSIBLE_PROGRESS
	if int(_result_counts.loop_detected) > 0:
		return RESULT_LOOP_DETECTED
	if int(_result_counts.timeout) > 0:
		return RESULT_TIMEOUT
	return RESULT_COMPLETE

func _finalize_level_avg(floor_n: int) -> void:
	if level_stats.has(floor_n):
		var s = level_stats[floor_n]
		if s.plays > 0:
			s.avg_moves_used = float(s.moves_accum) / float(s.plays)

func _ensure_level_stat(floor_n: int) -> void:
	if not level_stats.has(floor_n):
		level_stats[floor_n] = {
			"level_id": "floor_" + str(floor_n),
			"plays": 0,
			"wins": 0,
			"moves_accum": 0,
			"avg_moves_used": 0.0,
			"move_limit": 8100,
			"dead_boards": 0
		}

func _decide_inputs(policy: int, floor_n: int) -> Array:
	# why: G2 §7 minimum-skill agent — greedy over the objective chain
	# (key, then door, then exit) via BFS on the REAL RulesFloor tiles.
	# Same proven policy as the solver-validated attract baker
	# (tools/attract_capture.gd), so the machine player and the attract
	# reel share ONE navigation implementation. Round-1 steered
	# straight-line at the exit through walls, which is why avg_moves_used
	# blew past move_limit.
	var inputs: Array = []
	var tile_p: Vector2i = session.floor.pixel_to_tile(session.player.pos_x, session.player.pos_y, TILE)
	# objective chain: key → door (push-to-open) → exit, resolved by BFS over
	# the real tiles. The round-5 session.door_open heuristic was FALSE for
	# doors that seal a corridor instead of sitting on the exit tile
	# (floor_02: doors at the mid row, exit below them), so the bot never
	# fetched the key and stood still until the frame cap.
	var target: Vector2i = session.floor.exit_pos
	var next_tile: Vector2i = _bfs_next_tile(tile_p, target)
	if next_tile == tile_p and tile_p != target:
		# why: exit unreachable right now — a closed door seals every route.
		# Fetch the nearest key; RulesSession._step_movement consumes it on
		# push and the BFS then routes through the opened door.
		if session.player.keys == 0 and not session.pickups.keys.is_empty():
			target = _nearest_key_tile(tile_p)
			next_tile = _bfs_next_tile(tile_p, target)
	var dir: Vector2 = Vector2.ZERO
	if next_tile != tile_p:
		var center: Vector2 = session.floor.tile_to_pixel(next_tile.x, next_tile.y, TILE)
		var delta: Vector2 = center - Vector2(session.player.pos_x, session.player.pos_y)
		# why: axis-aligned unit step — BFS neighbors are 4-adjacent
		if abs(delta.x) > abs(delta.y):
			dir = Vector2(sign(delta.x), 0.0)
		elif abs(delta.y) > 1.0:
			dir = Vector2(0.0, sign(delta.y))
	else:
		# why: standing on the target tile — drift to its center if off by >6px
		var center2: Vector2 = session.floor.tile_to_pixel(target.x, target.y, TILE)
		var delta2: Vector2 = center2 - Vector2(session.player.pos_x, session.player.pos_y)
		if delta2.length() > 6.0:
			dir = delta2.normalized()
	inputs.append({"type": "move", "dx": dir.x, "dy": dir.y})
	# combat: nearest hostile with line of sight; engagement distance and
	# target set are the policy-shaped dials. min_skill (policy 0) is the
	# G2 §7 / §862 floor agent: nearest ENEMY within 3 tiles exactly (96px),
	# never generators (spawns stay live → sustained pressure → it dies),
	# never dodging (it only walks the BFS route), never kiting.
	var throw_range_px: float = float(session.player.shot_range_tiles) * float(TILE)
	var engage_px: float = throw_range_px
	var hit_generators: bool = true
	match policy:
		0:  # min_skill — 3-tile melee-ish band, enemies only (G2 §7)
			engage_px = float(TILE) * 3.0
			hit_generators = false
		1:  # completionist — sweep rooms beyond the route
			engage_px = throw_range_px * 1.25
		2:  # speedrun — only point-blank shots, keep moving
			engage_px = throw_range_px * 0.75
	var hostile_pos: Vector2 = _nearest_hostile_in_range(engage_px, hit_generators)
	if hostile_pos != Vector2(-1.0, -1.0) and session.player.throw_ready():
		inputs.append({"type": "throw"})
	# why: potion floor is class-relative (class HP varies 520–800) and
	# policy-shaped; Warrior whirlwind / Valkyrie aegis are survival tools.
	# min_skill NEVER uses potions (G2 §7: "does not … use potions") — that
	# is what makes it losable and yields real GAME_OVER terminals.
	var potion_frac: float = 0.25
	match policy:
		0:
			potion_frac = 0.0
		1:
			potion_frac = 0.3
		2:
			potion_frac = 0.15
	if potion_frac > 0.0 and session.player.potions > 0 and session.player.hp < int(float(session.player.max_hp) * potion_frac):
		inputs.append({"type": "potion"})
	# why: check dead board — only in PLAYING state; dying/continue are not dead boards
	if session.state == State.PLAYING and not session.has_legal_action():
		var s = level_stats.get(floor_n, null)
		if s != null:
			s.dead_boards += 1
	return inputs

func _nearest_key_tile(from_tile: Vector2i) -> Vector2i:
	var best: Vector2i = session.floor.exit_pos
	var best_d: int = 999999
	for k in session.pickups.keys:
		var kv: Vector2i = k
		var d: int = abs(kv.x - from_tile.x) + abs(kv.y - from_tile.y)
		if d < best_d:
			best_d = d
			best = kv
	return best

func _nearest_hostile_in_range(engage_px: float, include_generators: bool = true) -> Vector2:
	var best_pos: Vector2 = Vector2(-1.0, -1.0)
	var best_d: float = engage_px + 1.0
	var tile_p: Vector2i = session.floor.pixel_to_tile(session.player.pos_x, session.player.pos_y, TILE)
	for e in session.enemies:
		if not e.alive:
			continue
		var d: float = Vector2(e.pos_x - session.player.pos_x, e.pos_y - session.player.pos_y).length()
		if d <= engage_px and d < best_d:
			var tile_e: Vector2i = session.floor.pixel_to_tile(e.pos_x, e.pos_y, TILE)
			if session.floor.has_line_of_sight(tile_p.x, tile_p.y, tile_e.x, tile_e.y):
				best_d = d
				best_pos = Vector2(e.pos_x, e.pos_y)
	if not include_generators:
		return best_pos
	for g in session.generators:
		if not g.alive:
			continue
		var gp: Vector2 = Vector2(g.pos_x, g.pos_y)
		var d2: float = (gp - Vector2(session.player.pos_x, session.player.pos_y)).length()
		if d2 <= engage_px and d2 < best_d:
			var tile_g: Vector2i = Vector2i(g.tile_x, g.tile_y)
			if session.floor.has_line_of_sight(tile_p.x, tile_p.y, tile_g.x, tile_g.y):
				best_d = d2
				best_pos = gp
	return best_pos

func _bfs_next_tile(from_tile: Vector2i, target: Vector2i) -> Vector2i:
	# why: breadth-first search over the real RulesFloor tiles; closed doors
	# are passable only when the player holds a key or the door is already
	# open (walking onto a door tile with a key opens it in _step_pickups).
	if from_tile == target:
		return from_tile
	var w: int = session.floor.grid_w
	var h: int = session.floor.grid_h
	var came_from: Dictionary = {}
	var frontier: Array = [from_tile]
	came_from[from_tile] = from_tile
	var dirs: Array = [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]
	var found: bool = false
	while not frontier.is_empty() and not found:
		var next_frontier: Array = []
		for cur in frontier:
			for d in dirs:
				var n: Vector2i = cur + d
				if n.x < 0 or n.y < 0 or n.x >= w or n.y >= h:
					continue
				if came_from.has(n):
					continue
				if not _passable(n):
					continue
				came_from[n] = cur
				if n == target:
					found = true
					break
				next_frontier.append(n)
			if found:
				break
		frontier = next_frontier
	if not found:
		return from_tile  # why: no path — stand still rather than hug walls
	# why: walk back to the first step after from_tile
	var cur2: Vector2i = target
	while came_from[cur2] != from_tile:
		cur2 = came_from[cur2]
	return cur2

func _passable(tile: Vector2i) -> bool:
	if session.floor.is_wall(tile.x, tile.y):
		return false
	# why: collapsing-void removed tiles are holes
	for hz in session.hazards:
		if hz.hazard_type == StateEnums.HazardType.COLLAPSING_VOID and hz.is_tile_removed(tile.x, tile.y):
			return false
	# why: closed doors block unless a key is held (or that door is already open)
	for d in session.pickups.doors:
		if d.pos.x == tile.x and d.pos.y == tile.y and not d.open:
			if session.player.keys <= 0:
				return false
	return true

func _write_telemetry() -> Dictionary:
	if telemetry_out.is_empty():
		return {"ok": false, "error": "no telemetry-out path"}
	# why: finalize EVERY played floor's average. The per-terminal
	# _finalize_level_avg only touches the floor a game ends on, so cleared
	# mid-floors would report avg_moves_used 0.0 over a real tick spend —
	# a false green by omission. Same unit (ticks) and scope (per-game
	# aggregate) on both sides of the comparison, per the contract note.
	for k in level_stats.keys():
		_finalize_level_avg(k)
	var levels: Array = []
	var floor_keys: Array = level_stats.keys()
	floor_keys.sort()
	for k in floor_keys:
		var s: Dictionary = level_stats[k]
		levels.append({
			"level_id": s.level_id,
			"plays": s.plays,
			"wins": s.wins,
			"avg_moves_used": s.avg_moves_used,
			"move_limit": s.move_limit,
			"dead_boards": s.dead_boards
		})
	var juice_counts: Dictionary = {}
	for e in _juice_events:
		var k: String = str(e.get("event", ""))
		juice_counts[k] = int(juice_counts.get(k, 0)) + 1
	var telemetry: Dictionary = {
		"schema": "playtest_telemetry_v1",
		"engine": "godot",
		"engine_version": Engine.get_version_info().string,
		"game": "HUNGERHALL",
		"games_played": games_played,
		"games_completed": games_completed,
		"seed": seed_value,
		# G9 DoD #6 — result codes: 0=complete, 1=timeout, 2=crash,
		# 3=invalid_state, 4=impossible_progress, 5=loop_detected.
		# `result` is the overall run result (worst per-game code by severity);
		# `results` is the per-game histogram.
		"result": _overall_result(),
		"results": _result_counts.duplicate(),
		# G9 DoD #6 — juice_events recorded from RULES truth by a headless
		# JuiceDirector stepped per fixed tick (consume_pending cues + snapshot
		# deltas; never from presentation). Raw list bounded to 4096 entries;
		# juice_event_total counts everything observed; juice_event_counts is
		# the full histogram.
		"juice_events": _juice_events,
		"juice_event_total": _juice_event_total,
		"juice_event_counts": juice_counts,
		"levels": levels,
		"notes": [
			"avg_moves_used and move_limit are both in TICKS (60Hz physics ticks); one input event may span multiple ticks",
			"three bot policies cycle across games: min_skill (losable G2 §7 agent — no dodging, no kiting, no potions, enemies-only within 3 tiles, never hits generators; dies through both continue tokens to GAME_OVER), completionist, speedrun",
			"four classes cycle across games: warrior, valkyrie, wizard, elf",
			"levels array is per-floor aggregate across all games; each floor row sums plays and wins",
			"G9 DoD #6: result codes per game — 0=complete (reached a real terminal: campaign clear or GAME_OVER through both continue tokens), 1=timeout (frame budget), 3=invalid_state (session state outside the machine-play contract), 4=impossible_progress (floor regression or hp>max — score drops are EXCLUDED by design: G2 §2 locks a death penalty, so falling score is legal progress), 5=loop_detected (repeated 128-tick state cycle; stationary starving excluded — that is legal terminal-seeking), 2=crash reserved (a crash ends the process, so it cannot self-report)",
			"juice_events entries are {game, event, step}; event names are contract rows (AC-*), signature markers (SIG-*), cue records (cue:*), and budget events (particle_capped:*); recorded out-of-tree by the same JuiceDirector class the product mounts"
		]
	}
	# why: write directly to target — temp+rename across res:// and user:// fails
	var f: FileAccess = FileAccess.open(telemetry_out, FileAccess.WRITE)
	if f == null:
		return {"ok": false, "error": "cannot open telemetry file: " + telemetry_out}
	f.store_string(JSON.stringify(telemetry, "  "))
	f.store_string("\n")
	f.flush()
	f.close()
	return {"ok": true, "telemetry": telemetry}

func parse_user_args() -> Dictionary:
	# why: read ONLY the user-arguments after Godot's -- separator
	var raw: PackedStringArray = OS.get_cmdline_user_args()
	var args: Dictionary = {}
	var i: int = 0
	while i < raw.size():
		var arg: String = raw[i]
		if arg == "--telemetry-out" and i + 1 < raw.size():
			args["telemetry-out"] = raw[i + 1]
			i += 2
		elif arg == "--games" and i + 1 < raw.size():
			args["games"] = raw[i + 1]
			i += 2
		elif arg == "--seed" and i + 1 < raw.size():
			args["seed"] = raw[i + 1]
			i += 2
		elif arg == "--frame-budget" and i + 1 < raw.size():
			args["frame-budget"] = raw[i + 1]
			i += 2
		else:
			i += 1
	return args

func run_with_args(args: Dictionary) -> Dictionary:
	## why: convenience method for tests — setup + run in one call
	var setup: Dictionary = setup(args)
	if not setup.get("ok", false):
		return setup
	return run()
