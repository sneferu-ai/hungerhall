extends RefCounted
## test_exit_overlap — the exit door requires 3 CONSECUTIVE physics frames of
## overlap (G2 §1 / G6 §3.2): 2 frames does not clear, leaving resets.

func _make_session() -> RulesSession:
	var t: TunablesLoader = TunablesLoader.new()
	t.load_from_path("res://Tunables.json")
	var s: RulesSession = RulesSession.new()
	var classes: Array = ClassDef.build_all(t)
	# why: baked floor_01 has no door row, so the overlap rule is isolated
	s.setup_campaign(t, classes[0], 99)
	return s

func _stand_on_exit(s: RulesSession) -> void:
	var px: Vector2 = s.floor.tile_to_pixel(s.floor.exit_pos.x, s.floor.exit_pos.y, 32)
	s.player.pos_x = px.x
	s.player.pos_y = px.y
	s.input({"type": "move", "dx": 0.0, "dy": 0.0})

func test_three_consecutive_frames_clear() -> Dictionary:
	var s: RulesSession = _make_session()
	var required: int = s.tunables.get_int("exit_overlap_required_frames", 3)
	_stand_on_exit(s)
	for i in range(required):
		s.input({"type": "move", "dx": 0.0, "dy": 0.0})
		s.step()
	if s.exit_overlap_frames != required:
		return {"ok": false, "msg": "overlap counter at %d after %d frames" % [s.exit_overlap_frames, required]}
	if s.state != StateEnums.State.FLOOR_RESULTS:
		return {"ok": false, "msg": "state %d after full overlap, expected FLOOR_RESULTS" % s.state}
	return {"ok": true}

func test_two_frames_do_not_clear() -> Dictionary:
	var s: RulesSession = _make_session()
	var required: int = s.tunables.get_int("exit_overlap_required_frames", 3)
	if required < 3:
		return {"ok": false, "msg": "contract requires >=3 frames, tunable says %d" % required}
	_stand_on_exit(s)
	for i in range(required - 1):
		s.input({"type": "move", "dx": 0.0, "dy": 0.0})
		s.step()
	if s.state != StateEnums.State.PLAYING:
		return {"ok": false, "msg": "cleared after only %d frames" % (required - 1)}
	if s.exit_overlap_frames != required - 1:
		return {"ok": false, "msg": "counter %d, expected %d" % [s.exit_overlap_frames, required - 1]}
	return {"ok": true}

func test_leaving_resets_consecutive_count() -> Dictionary:
	var s: RulesSession = _make_session()
	_stand_on_exit(s)
	for i in range(2):
		s.input({"type": "move", "dx": 0.0, "dy": 0.0})
		s.step()
	# why: step off the exit tile — the counter must fall to zero
	var beside: Vector2 = s.floor.tile_to_pixel(s.floor.exit_pos.x - 1, s.floor.exit_pos.y, 32)
	s.player.pos_x = beside.x
	s.player.pos_y = beside.y
	s.input({"type": "move", "dx": 0.0, "dy": 0.0})
	s.step()
	if s.exit_overlap_frames != 0:
		return {"ok": false, "msg": "overlap counter not reset after leaving: %d" % s.exit_overlap_frames}
	if s.state != StateEnums.State.PLAYING:
		return {"ok": false, "msg": "state changed after a broken overlap"}
	return {"ok": true}
