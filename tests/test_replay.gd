extends RefCounted
## test_replay — seed + ordered semantic actions → SHA-256 identical digest
## (rules_replay.gd is the codec + HashingContext seam); actions are the only
## recorded truth, so a session with no inputs records nothing.

func _make_session(seed_v: int) -> RulesSession:
	var t: TunablesLoader = TunablesLoader.new()
	t.load_from_path("res://Tunables.json")
	var s: RulesSession = RulesSession.new()
	s.setup_campaign(t, ClassDef.build_all(t)[0], seed_v)
	return s

func _scripted_run(seed_v: int, throws: bool) -> String:
	var s: RulesSession = _make_session(seed_v)
	for i in range(120):
		s.input({"type": "move", "dx": 1.0, "dy": 0.0})
		if throws and i % 40 == 10:
			s.input({"type": "throw"})
		s.step()
	return s.replay.digest_sha256()

func test_same_seed_same_actions_same_sha256() -> Dictionary:
	var a: String = _scripted_run(5, true)
	var b: String = _scripted_run(5, true)
	if a.length() != 64:
		return {"ok": false, "msg": "digest is not a 64-hex SHA-256: '%s'" % a}
	if a != b:
		return {"ok": false, "msg": "identical seed+actions diverged: %s vs %s" % [a, b]}
	return {"ok": true}

func test_different_actions_different_sha256() -> Dictionary:
	var a: String = _scripted_run(5, true)
	var b: String = _scripted_run(5, false)
	if a == b:
		return {"ok": false, "msg": "action change did not move the digest — replay not action-bound"}
	return {"ok": true}

func test_no_inputs_record_nothing() -> Dictionary:
	var s: RulesSession = _make_session(9)
	for i in range(60):
		s.step()
	if not s.replay.frames.is_empty():
		return {"ok": false, "msg": "replay recorded %d frames without any input event" % s.replay.frames.size()}
	return {"ok": true}

func test_semantic_actions_only() -> Dictionary:
	# why: replays record semantic actions (move/throw/potion/pause/confirm),
	# never raw pointer coordinates — the codec's frame vocabulary
	var s: RulesSession = _make_session(13)
	s.input({"type": "move", "dx": 0.5, "dy": -1.0})
	s.input({"type": "throw"})
	s.step()
	var ok_types: Array = ["move", "throw", "potion", "pause", "confirm", "auto_fire_on", "auto_fire_off"]
	for fr in s.replay.frames:
		if not ok_types.has(str(fr.event_type)):
			return {"ok": false, "msg": "non-semantic frame type recorded: %s" % str(fr.event_type)}
	if s.replay.frames.size() != 2:
		return {"ok": false, "msg": "expected 2 frames, got %d" % s.replay.frames.size()}
	return {"ok": true}
