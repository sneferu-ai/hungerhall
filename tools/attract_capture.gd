extends SceneTree
## HUNGERHALL — attract replay baker (G6 §2 tools/). Bakes
## res://Assets/Replays/attract.replay from a seed-locked greedy-killer bot
## run: seed 0xDEAD (57005), Warrior, floor 1. Solver-validates floor 1
## BEFORE recording, records hold-until-change semantic actions, verifies
## deterministic playback against a fresh isolated session (SHA-256 receipt
## via HashingContext), then writes hungerhall_replay_v1 atomically.
## Imports core/ + data defs ONLY (no app/, no ci/).
##
## Command:
##   godot --headless --path . --script res://tools/attract_capture.gd -- \
##     --output Assets/Replays/attract.replay --seed 57005

const State = StateEnums.State
const TILE: int = 32

var _tunables: TunablesLoader = TunablesLoader.new()
var _actions: Array = []
var _last_move: Vector2 = Vector2(999.0, 999.0)  # sentinel: no move recorded yet

func _init() -> void:
	var args: Dictionary = _parse_args()
	var out_rel: String = str(args.get("output", "Assets/Replays/attract.replay"))
	var seed_value: int = int(args.get("seed", 57005))  # why: 0xDEAD per G6 §2
	var max_ticks: int = int(args.get("max-ticks", 16200))  # why: 2x floor-1 target_seconds*60
	var result: Dictionary = _bake(seed_value, max_ticks)
	if not result.get("ok", false):
		push_error("attract_capture FAILED: " + str(result.get("error", "unknown")))
		print("ATTRACT_CAPTURE: FAIL — " + str(result.get("error", "unknown")))
		quit(1)
		return
	var write_result: Dictionary = _write_replay(out_rel, seed_value, result)
	if not write_result.get("ok", false):
		push_error("attract_capture WRITE FAILED: " + str(write_result.get("error", "unknown")))
		print("ATTRACT_CAPTURE: FAIL — " + str(write_result.get("error", "unknown")))
		quit(1)
		return
	print("ATTRACT_CAPTURE: OK — wrote " + str(write_result.path))
	print("ATTRACT_CAPTURE: seed=" + str(seed_value) + " class=warrior floor=1 actions=" + str(_actions.size()) + " length_ticks=" + str(result.length_ticks) + " receipt_sha256=" + str(result.receipt_sha256))
	quit(0)

func _parse_args() -> Dictionary:
	# why: read ONLY the user-arguments after Godot's -- separator
	var raw: PackedStringArray = OS.get_cmdline_user_args()
	var args: Dictionary = {}
	var i: int = 0
	while i < raw.size():
		var arg: String = raw[i]
		if arg == "--output" and i + 1 < raw.size():
			args["output"] = raw[i + 1]
			i += 2
		elif arg == "--seed" and i + 1 < raw.size():
			args["seed"] = raw[i + 1]
			i += 2
		elif arg == "--max-ticks" and i + 1 < raw.size():
			args["max-ticks"] = raw[i + 1]
			i += 2
		else:
			i += 1
	return args

func _bake(seed_value: int, max_ticks: int) -> Dictionary:
	if not _tunables.load_from_path("res://Tunables.json"):
		return {"ok": false, "error": "Tunables.json load failed: " + str(_tunables.errors())}
	var warrior: ClassDef = ClassDef.build(StateEnums.ClassType.WARRIOR, _tunables)
	# why: G6 §2 — attract is solver-validated BEFORE packaging
	var gate: Dictionary = RulesSolverCheck.check_floor(1, warrior.hp, _tunables)
	if not gate.get("total_ok", false):
		return {"ok": false, "error": "solver gate failed for floor 1: " + JSON.stringify(gate)}
	var session: RulesSession = RulesSession.new()
	session.setup_campaign(_tunables, warrior, seed_value)
	_actions.clear()
	_last_move = Vector2(999.0, 999.0)
	var outcome: String = ""
	while session.tick < max_ticks:
		if session.state != State.PLAYING:
			break
		for event in _decide_inputs(session):
			session.input(event)
			_record(session.tick, event)
		session.step()
	if session.state == State.FLOOR_RESULTS:
		outcome = "floor_clear"
	elif session.state == State.PLAYING:
		return {"ok": false, "error": "tick budget exhausted without floor clear (stall)"}
	else:
		return {"ok": false, "error": "attract run ended in state " + str(session.state) + " — a death reel is not an attract reel"}
	var capture_sha: String = _sha256_of(JSON.stringify(session.snapshot()))
	var length_ticks: int = session.tick
	# why: deterministic-playback proof — a fresh isolated session fed the
	# recorded actions at their recorded ticks must reproduce the exact
	# terminal snapshot (G2 §1 replay determinism; test_attract_replay seam).
	var verify: Dictionary = _verify_playback(seed_value, length_ticks)
	if not verify.get("ok", false):
		return {"ok": false, "error": "playback verification failed: " + str(verify.get("error", ""))}
	if verify.sha256 != capture_sha:
		return {"ok": false, "error": "receipt mismatch: capture=" + capture_sha + " playback=" + str(verify.sha256)}
	return {
		"ok": true,
		"outcome": outcome,
		"length_ticks": length_ticks,
		"receipt_sha256": capture_sha,
		"solver_gate": gate,
		"class_name": ClassDef.class_name_for(StateEnums.ClassType.WARRIOR)
	}

func _verify_playback(seed_value: int, length_ticks: int) -> Dictionary:
	var warrior: ClassDef = ClassDef.build(StateEnums.ClassType.WARRIOR, _tunables)
	var session: RulesSession = RulesSession.new()
	session.setup_campaign(_tunables, warrior, seed_value)
	var action_index: int = 0
	# why: run 30 ticks past the capture terminal so exit-overlap state settles identically
	var total: int = length_ticks + 30
	for t in range(total):
		if session.state != State.PLAYING:
			break
		while action_index < _actions.size() and int(_actions[action_index].tick) == t:
			session.input(_actions[action_index].event)
			action_index += 1
		session.step()
	if session.state != State.FLOOR_RESULTS:
		return {"ok": false, "error": "playback did not reach FLOOR_RESULTS (state=" + str(session.state) + ")"}
	return {"ok": true, "sha256": _sha256_of(JSON.stringify(session.snapshot()))}

func _record(tick: int, event: Dictionary) -> void:
	# why: hold-until-change — move events persist until the next move event,
	# so only direction CHANGES are recorded (compact + deterministic)
	if event.get("type", "") == "move":
		var dir: Vector2 = Vector2(float(event.get("dx", 0.0)), float(event.get("dy", 0.0)))
		if dir == _last_move:
			return
		_last_move = dir
	_actions.append({"tick": tick, "event": event.duplicate(true)})

func _decide_inputs(session: RulesSession) -> Array:
	# why: G2 §7 minimum-skill agent — greedy-killer: BFS path toward the
	# objective chain (key, then door, then exit); throws at the nearest
	# enemy/generator in range with line of sight; potions below 25% HP.
	var inputs: Array = []
	var tile_p: Vector2i = session.floor.pixel_to_tile(session.player.pos_x, session.player.pos_y, TILE)
	# objective chain
	var exit_blocked: bool = not session.door_open and not session._exit_door_is_open()
	var target: Vector2i = session.floor.exit_pos
	if exit_blocked and session.player.keys == 0 and not session.pickups.keys.is_empty():
		target = _nearest_key_tile(session, tile_p)
	var next_tile: Vector2i = _bfs_next_tile(session, tile_p, target)
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
	# combat: nearest hostile in shot range with line of sight
	var throw_target_pos: Vector2 = _nearest_hostile_in_range(session)
	if throw_target_pos != Vector2(-1.0, -1.0) and session.player.throw_ready():
		inputs.append({"type": "throw"})
	# why: Warrior whirlwind is an AoE escape tool — spend below 25% HP
	if session.player.potions > 0 and session.player.hp < int(float(session.player.max_hp) * 0.25):
		inputs.append({"type": "potion"})
	return inputs

func _nearest_key_tile(session: RulesSession, from_tile: Vector2i) -> Vector2i:
	var best: Vector2i = session.floor.exit_pos
	var best_d: int = 999999
	for k in session.pickups.keys:
		var kv: Vector2i = k
		var d: int = abs(kv.x - from_tile.x) + abs(kv.y - from_tile.y)
		if d < best_d:
			best_d = d
			best = kv
	return best

func _nearest_hostile_in_range(session: RulesSession) -> Vector2:
	var range_px: float = float(session.player.shot_range_tiles) * float(TILE)
	var best_pos: Vector2 = Vector2(-1.0, -1.0)
	var best_d: float = range_px + 1.0
	var tile_p: Vector2i = session.floor.pixel_to_tile(session.player.pos_x, session.player.pos_y, TILE)
	for e in session.enemies:
		if not e.alive:
			continue
		var d: float = Vector2(e.pos_x - session.player.pos_x, e.pos_y - session.player.pos_y).length()
		if d <= range_px and d < best_d:
			var tile_e: Vector2i = session.floor.pixel_to_tile(e.pos_x, e.pos_y, TILE)
			if session.floor.has_line_of_sight(tile_p.x, tile_p.y, tile_e.x, tile_e.y):
				best_d = d
				best_pos = Vector2(e.pos_x, e.pos_y)
	for g in session.generators:
		if not g.alive:
			continue
		var gp: Vector2 = Vector2(g.pos_x, g.pos_y)
		var d2: float = (gp - Vector2(session.player.pos_x, session.player.pos_y)).length()
		if d2 <= range_px and d2 < best_d:
			var tile_g: Vector2i = Vector2i(g.tile_x, g.tile_y)
			if session.floor.has_line_of_sight(tile_p.x, tile_p.y, tile_g.x, tile_g.y):
				best_d = d2
				best_pos = gp
	return best_pos

func _bfs_next_tile(session: RulesSession, from_tile: Vector2i, target: Vector2i) -> Vector2i:
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
				if not _passable(session, n):
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

func _passable(session: RulesSession, tile: Vector2i) -> bool:
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

func _sha256_of(text: String) -> String:
	var ctx: HashingContext = HashingContext.new()
	ctx.start(HashingContext.HASH_SHA256)
	ctx.update(text.to_utf8_buffer())
	return ctx.finish().hex_encode()

func _write_replay(out_rel: String, seed_value: int, result: Dictionary) -> Dictionary:
	var out_path: String = out_rel
	if out_path.begins_with("/"):
		pass  # why: absolute host path — write as-is
	elif not out_path.begins_with("res://"):
		out_path = "res://" + out_path
	var replay: Dictionary = {
		"schema": "hungerhall_replay_v1",
		"game": "HUNGERHALL",
		"seed": seed_value,
		"class": result.get("class_name", "warrior"),
		"floor": 1,
		"tick_rate": 60,
		"playback_rate": 30,
		"baked_by": "tools/attract_capture.gd",
		"outcome": result.outcome,
		"frame_count": _actions.size(),
		"length_ticks": result.length_ticks,
		"receipt_sha256": result.receipt_sha256,
		"solver_gate": result.solver_gate,
		"actions": _actions.duplicate(true)
	}
	var text: String = JSON.stringify(replay, "  ") + "\n"
	# why: atomic sibling-temp-then-rename (the telemetry-atomicity contract)
	var tmp_path: String = out_path + ".tmp"
	var parent: String = out_path.get_base_dir()
	if parent != "" and not DirAccess.dir_exists_absolute(parent):
		var mk_err: int = DirAccess.make_dir_recursive_absolute(parent)
		if mk_err != OK:
			return {"ok": false, "error": "cannot create dir " + parent + " err=" + str(mk_err)}
	var f: FileAccess = FileAccess.open(tmp_path, FileAccess.WRITE)
	if f == null:
		return {"ok": false, "error": "cannot open " + tmp_path + " err=" + str(FileAccess.get_open_error())}
	f.store_string(text)
	f.flush()
	f.close()
	var rn_err: int = DirAccess.rename_absolute(tmp_path, out_path)
	if rn_err != OK:
		return {"ok": false, "error": "rename failed " + tmp_path + " -> " + out_path + " err=" + str(rn_err)}
	return {"ok": true, "path": out_path, "bytes": text.length()}
