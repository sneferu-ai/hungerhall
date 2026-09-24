extends RefCounted
## test_attract_replay — the shipped attract reel loads, carries the G2
## solver-gate receipt, and replays deterministically against a fresh isolated
## RulesSession (the hungerhall_replay_v1 contract). This is the test_attract_replay
## seam the baker (tools/attract_capture.gd) names in its playback-verification
## comment: a regression here means either the replay file is stale, the rules
## core changed under the baked actions, or the solver gate drifted from G2 §3.

const REPLAY_PATH: String = "res://Assets/Replays/attract.replay"
## why: receipt re-pinned 2026-08-15 — the reel was re-baked by
## tools/attract_capture.gd after the _step_drain float-accumulator fix
## (int-tick drain) changed the terminal snapshot under the SAME baked
## actions (seed 57005, 9 actions, 348 ticks, floor_clear — unchanged).
## Old receipt stamped under the buggy drain: fc96d7d3a761c21d26b201a8bdaa76a9faec1235f80aed65f59ce037d24ff3b5
const EXPECTED_RECEIPT: String = "f5981978e07ce2a188d5d0f592d8cdfc01af61cd2bcb316b5dc1912a0311a9db"
const EXPECTED_SEED: int = 57005
const TICKS_SETTLE: int = 30  # why: matches the baker's _verify_playback settle window

func _load_replay() -> Dictionary:
	if not FileAccess.file_exists(REPLAY_PATH):
		return {}
	var f: FileAccess = FileAccess.open(REPLAY_PATH, FileAccess.READ)
	if f == null:
		return {}
	var text: String = f.get_as_text()
	f.close()
	var parsed = JSON.parse_string(text)
	if not (parsed is Dictionary):
		return {}
	return parsed

func test_attract_replay_loads_and_schema() -> Dictionary:
	# why: the shipped reel must exist, parse, and carry the v1 schema + locked
	# identity fields (seed/class/floor/outcome). A missing or corrupt reel is
	# the title-screen G3 error.replay_missing path — this test pins the shipped
	# artifact, not the degradation.
	var replay: Dictionary = _load_replay()
	if replay.is_empty():
		return {"ok": false, "msg": "cannot load " + REPLAY_PATH}
	if str(replay.get("schema", "")) != "hungerhall_replay_v1":
		return {"ok": false, "msg": "schema=%s, expected hungerhall_replay_v1" % str(replay.get("schema", ""))}
	if str(replay.get("game", "")) != "HUNGERHALL":
		return {"ok": false, "msg": "game=%s" % str(replay.get("game", ""))}
	if int(replay.get("seed", -1)) != EXPECTED_SEED:
		return {"ok": false, "msg": "seed=%d, expected %d (0xDEAD)" % [int(replay.get("seed", -1)), EXPECTED_SEED]}
	if str(replay.get("class", "")) != "warrior":
		return {"ok": false, "msg": "class=%s, expected warrior" % str(replay.get("class", ""))}
	if int(replay.get("floor", -1)) != 1:
		return {"ok": false, "msg": "floor=%d, expected 1" % int(replay.get("floor", -1))}
	if str(replay.get("outcome", "")) != "floor_clear":
		return {"ok": false, "msg": "outcome=%s, expected floor_clear" % str(replay.get("outcome", ""))}
	var actions: Array = replay.get("actions", [])
	if actions.is_empty():
		return {"ok": false, "msg": "no recorded actions"}
	if int(replay.get("frame_count", -1)) != actions.size():
		return {"ok": false, "msg": "frame_count=%d vs actions.size=%d" % [int(replay.get("frame_count", -1)), actions.size()]}
	if int(replay.get("length_ticks", -1)) <= 0:
		return {"ok": false, "msg": "length_ticks=%d must be positive" % int(replay.get("length_ticks", -1))}
	return {"ok": true}

func test_attract_replay_solver_gate_g2_locked() -> Dictionary:
	# why: the reel's embedded solver_gate receipt must carry G2 §3's F1–3
	# worked example (combat 500 / food_pieces 3 / drain_plus_combat 770 /
	# total_ok true). This is the round-3 correction — round-1's degenerate
	# constants would show combat ~120 and food_pieces ≤1 here.
	var replay: Dictionary = _load_replay()
	if replay.is_empty():
		return {"ok": false, "msg": "cannot load replay"}
	var gate: Dictionary = replay.get("solver_gate", {})
	if gate.is_empty():
		return {"ok": false, "msg": "replay missing solver_gate receipt"}
	if int(gate.get("combat_estimate", -1)) != 500:
		return {"ok": false, "msg": "solver_gate combat=%s, G2 §3 locks 500" % str(gate.get("combat_estimate"))}
	if int(gate.get("food_pieces", -1)) != 3:
		return {"ok": false, "msg": "solver_gate food_pieces=%s, G2 §3 locks 3" % str(gate.get("food_pieces"))}
	if int(gate.get("drain_plus_combat", -1)) != 770:
		return {"ok": false, "msg": "solver_gate drain_plus_combat=%s, G2 §3 F1–3 example is 770" % str(gate.get("drain_plus_combat"))}
	if int(gate.get("target_seconds", -1)) != 135:
		return {"ok": false, "msg": "solver_gate target_seconds=%s, G2 §3 band-1 midpoint is 135" % str(gate.get("target_seconds"))}
	if not bool(gate.get("total_ok", false)):
		return {"ok": false, "msg": "solver_gate total_ok=false, must be true for a shipped reel"}
	if str(replay.get("receipt_sha256", "")) != EXPECTED_RECEIPT:
		return {"ok": false, "msg": "receipt=%s, expected %s" % [str(replay.get("receipt_sha256", "")), EXPECTED_RECEIPT]}
	return {"ok": true}

func test_attract_replay_deterministic_playback() -> Dictionary:
	# why: a fresh isolated RulesSession fed the recorded actions at their
	# recorded ticks must (1) reach FLOOR_RESULTS and (2) reproduce the exact
	# terminal snapshot SHA-256 stamped in the file. This is the G2 §1 replay
	# determinism proof — if the rules core drifts under the baked actions the
	# receipt breaks, which is exactly the regression signal we want.
	var replay: Dictionary = _load_replay()
	if replay.is_empty():
		return {"ok": false, "msg": "cannot load replay"}
	var tunables: TunablesLoader = TunablesLoader.new()
	if not tunables.load_from_path("res://Tunables.json"):
		return {"ok": false, "msg": "tunables load failed: " + str(tunables.errors())}
	var cd: ClassDef = ClassDef.build(StateEnums.ClassType.WARRIOR, tunables)
	var session: RulesSession = RulesSession.new()
	session.setup_campaign(tunables, cd, int(replay.get("seed", EXPECTED_SEED)))
	var actions: Array = replay.get("actions", [])
	var length_ticks: int = int(replay.get("length_ticks", 0))
	if length_ticks <= 0:
		return {"ok": false, "msg": "length_ticks not positive in replay"}
	var action_index: int = 0
	var total: int = length_ticks + TICKS_SETTLE
	for t in range(total):
		if session.state != StateEnums.State.PLAYING:
			break
		while action_index < actions.size() and int(actions[action_index].tick) == t:
			session.input(actions[action_index].event)
			action_index += 1
		session.step()
	if session.state != StateEnums.State.FLOOR_RESULTS:
		return {"ok": false, "msg": "playback did not reach FLOOR_RESULTS (state=%d tick=%d)" % [session.state, session.tick]}
	var playback_sha: String = _sha256_of(JSON.stringify(session.snapshot()))
	var stamped: String = str(replay.get("receipt_sha256", ""))
	if playback_sha != stamped:
		return {"ok": false, "msg": "receipt mismatch: playback=%s stamped=%s — rules core drifted under baked actions" % [playback_sha, stamped]}
	return {"ok": true}

func _sha256_of(text: String) -> String:
	var ctx: HashingContext = HashingContext.new()
	ctx.start(HashingContext.HASH_SHA256)
	ctx.update(text.to_utf8_buffer())
	return ctx.finish().hex_encode()
