extends RefCounted
## test_cue_bus — CueBus musician handoff seam (G6 §2, §3.3).
## Verifies the cue bus emit/clear/forward/dispatch/signal contract and the
## end-to-end seam: a real RulesSession throw produces cue.player.throw in
## consume_pending() output (G6 §3.3 {cues, events}), and the second drain is
## empty (the drain contract).

class MockDirector extends Node:
	# why: duck-typed dispatch target — RefCounted with on_cue would also work
	# but the slot is typed Node, so the mock extends Node to satisfy the type
	# annotation without a parser warning.
	var received: Array = []
	func on_cue(entry: Dictionary) -> void:
		received.append(entry)

func _make_tunables() -> TunablesLoader:
	var t: TunablesLoader = TunablesLoader.new()
	t.load_from_path("res://Tunables.json")
	return t

func _make_warrior(t: TunablesLoader) -> ClassDef:
	var cd: ClassDef = ClassDef.new()
	cd.class_type = StateEnums.ClassType.WARRIOR
	cd.display_name = "WARRIOR"
	cd.potion_type = StateEnums.PotionType.WHIRLWIND
	cd.hp = int(t.get_value("warrior_hp", 800))
	cd.speed = int(t.get_value("warrior_speed", 128))
	cd.shot_dmg = int(t.get_value("warrior_shot_dmg", 50))
	cd.shot_range_tiles = int(t.get_value("warrior_shot_range_tiles", 5))
	cd.shot_rate_per_sec = t.get_value("warrior_shot_rate", 1.2)
	cd.projectile_kind = "axe"
	return cd

func test_emit_records_in_log() -> Dictionary:
	var bus: CueBus = CueBus.new()
	bus.emit(&"cue.player.throw", 42)
	if bus.emitted_log.size() != 1:
		bus.free()
		return {"ok": false, "msg": "expected 1 entry, got %d" % bus.emitted_log.size()}
	var entry: Dictionary = bus.emitted_log[0]
	if str(entry.get("cue_id", "")) != "cue.player.throw":
		bus.free()
		return {"ok": false, "msg": "cue_id mismatch: %s" % str(entry.get("cue_id", ""))}
	if int(entry.get("step", -1)) != 42:
		bus.free()
		return {"ok": false, "msg": "step mismatch: %d" % int(entry.get("step", -1))}
	bus.free()
	return {"ok": true}

func test_emit_default_step_is_minus_one() -> Dictionary:
	var bus: CueBus = CueBus.new()
	bus.emit(&"cue.player.throw")
	if bus.emitted_log.size() != 1:
		bus.free()
		return {"ok": false, "msg": "expected 1 entry, got %d" % bus.emitted_log.size()}
	if int(bus.emitted_log[0].get("step", -999)) != -1:
		bus.free()
		return {"ok": false, "msg": "default step should be -1, got %d" % int(bus.emitted_log[0].get("step", -999))}
	bus.free()
	return {"ok": true}

func test_emit_empty_cue_dropped() -> Dictionary:
	var bus: CueBus = CueBus.new()
	bus.emit(&"", 5)
	if bus.emitted_log.size() != 0:
		bus.free()
		return {"ok": false, "msg": "empty cue was not dropped, log size %d" % bus.emitted_log.size()}
	bus.free()
	return {"ok": true}

func test_clear_log() -> Dictionary:
	var bus: CueBus = CueBus.new()
	bus.emit(&"cue.player.throw", 1)
	bus.emit(&"cue.player.potion", 2)
	if bus.emitted_log.size() != 2:
		bus.free()
		return {"ok": false, "msg": "expected 2 entries, got %d" % bus.emitted_log.size()}
	bus.clear_log()
	if bus.emitted_log.size() != 0:
		bus.free()
		return {"ok": false, "msg": "clear_log did not empty the log, size %d" % bus.emitted_log.size()}
	bus.free()
	return {"ok": true}

func test_emit_from_pending_forwards_cues() -> Dictionary:
	var bus: CueBus = CueBus.new()
	var pending: Dictionary = {
		"cues": [
			{"cue_id": "cue.player.throw", "step": 5},
			{"cue_id": "cue.enemy.hurt", "step": 6}
		],
		"events": []
	}
	var count: int = bus.emit_from_pending(pending)
	if count != 2:
		bus.free()
		return {"ok": false, "msg": "expected count 2, got %d" % count}
	if bus.emitted_log.size() != 2:
		bus.free()
		return {"ok": false, "msg": "log size %d, expected 2" % bus.emitted_log.size()}
	if str(bus.emitted_log[0].get("cue_id", "")) != "cue.player.throw":
		bus.free()
		return {"ok": false, "msg": "first forwarded cue mismatch: %s" % str(bus.emitted_log[0].get("cue_id", ""))}
	bus.free()
	return {"ok": true}

func test_emit_from_pending_skips_non_dict() -> Dictionary:
	var bus: CueBus = CueBus.new()
	var pending: Dictionary = {
		"cues": ["not a dict", 42, {"cue_id": "cue.player.throw", "step": 1}],
		"events": []
	}
	var count: int = bus.emit_from_pending(pending)
	if count != 1:
		bus.free()
		return {"ok": false, "msg": "expected 1 valid cue, got %d" % count}
	if bus.emitted_log.size() != 1:
		bus.free()
		return {"ok": false, "msg": "log size %d, expected 1" % bus.emitted_log.size()}
	bus.free()
	return {"ok": true}

func test_emit_from_pending_drops_empty_cue_id() -> Dictionary:
	# why: a pending cue with a missing/empty cue_id is not a cue — emit()
	# refuses it and the count must not include it
	var bus: CueBus = CueBus.new()
	var pending: Dictionary = {
		"cues": [
			{"cue_id": "", "step": 1},
			{"step": 2},
			{"cue_id": "cue.player.throw", "step": 3}
		],
		"events": []
	}
	var count: int = bus.emit_from_pending(pending)
	if count != 1:
		bus.free()
		return {"ok": false, "msg": "empty/missing cue_id should not count, got %d" % count}
	if bus.emitted_log.size() != 1:
		bus.free()
		return {"ok": false, "msg": "log should have 1 entry, got %d" % bus.emitted_log.size()}
	if str(bus.emitted_log[0].get("cue_id", "")) != "cue.player.throw":
		bus.free()
		return {"ok": false, "msg": "wrong cue forwarded"}
	bus.free()
	return {"ok": true}

func test_emit_from_pending_empty_dict() -> Dictionary:
	var bus: CueBus = CueBus.new()
	var count: int = bus.emit_from_pending({})
	if count != 0:
		bus.free()
		return {"ok": false, "msg": "expected 0 from empty pending, got %d" % count}
	bus.free()
	return {"ok": true}

func test_emit_from_pending_missing_cues_key() -> Dictionary:
	var bus: CueBus = CueBus.new()
	var count: int = bus.emit_from_pending({"events": []})
	if count != 0:
		bus.free()
		return {"ok": false, "msg": "expected 0 with no cues key, got %d" % count}
	bus.free()
	return {"ok": true}

func test_dispatch_to_director_hook() -> Dictionary:
	var bus: CueBus = CueBus.new()
	var mock: MockDirector = MockDirector.new()
	bus.audio_director = mock
	bus.emit(&"cue.player.throw", 7)
	if mock.received.size() != 1:
		bus.free()
		mock.free()
		return {"ok": false, "msg": "director did not receive the cue, got %d" % mock.received.size()}
	if str(mock.received[0].get("cue_id", "")) != "cue.player.throw":
		bus.free()
		mock.free()
		return {"ok": false, "msg": "director received wrong cue_id: %s" % str(mock.received[0].get("cue_id", ""))}
	bus.free()
	mock.free()
	return {"ok": true}

func test_dispatch_silent_when_no_director() -> Dictionary:
	var bus: CueBus = CueBus.new()
	# why: no directors set — emit must not error and must still record
	bus.emit(&"cue.player.throw", 7)
	if bus.emitted_log.size() != 1:
		bus.free()
		return {"ok": false, "msg": "log should still record without directors, got %d" % bus.emitted_log.size()}
	bus.free()
	return {"ok": true}

func test_dispatch_skips_director_without_on_cue() -> Dictionary:
	var bus: CueBus = CueBus.new()
	var bad: Node = Node.new()
	bus.audio_director = bad  # why: plain Node has no on_cue method
	bus.emit(&"cue.player.throw", 7)
	if bus.emitted_log.size() != 1:
		bus.free()
		bad.free()
		return {"ok": false, "msg": "log should still record, got %d" % bus.emitted_log.size()}
	bus.free()
	bad.free()
	return {"ok": true}

func test_dispatch_to_all_three_directors() -> Dictionary:
	var bus: CueBus = CueBus.new()
	var a: MockDirector = MockDirector.new()
	var b: MockDirector = MockDirector.new()
	var c: MockDirector = MockDirector.new()
	bus.audio_director = a
	bus.announcer = b
	bus.juice_director = c
	bus.emit(&"cue.enemy.killed", 11)
	if a.received.size() != 1 or b.received.size() != 1 or c.received.size() != 1:
		bus.free()
		a.free()
		b.free()
		c.free()
		return {"ok": false, "msg": "not all directors received: a=%d b=%d c=%d" % [a.received.size(), b.received.size(), c.received.size()]}
	bus.free()
	a.free()
	b.free()
	c.free()
	return {"ok": true}

func test_cue_signal_emits() -> Dictionary:
	var bus: CueBus = CueBus.new()
	var captured: Array = []
	var handler = func(cid: StringName, step: int) -> void:
		captured.append([str(cid), step])
	bus.cue_emitted.connect(handler)
	bus.emit(&"cue.player.throw", 99)
	if captured.size() != 1:
		bus.free()
		return {"ok": false, "msg": "signal did not fire, got %d" % captured.size()}
	if str(captured[0][0]) != "cue.player.throw" or int(captured[0][1]) != 99:
		bus.free()
		return {"ok": false, "msg": "signal payload wrong: %s" % str(captured[0])}
	bus.free()
	return {"ok": true}

func test_e2e_throw_emits_cue_through_consume_pending() -> Dictionary:
	# why: the musician handoff end-to-end — a real RulesSession throw
	# produces cue.player.throw in consume_pending() output (G6 §3.3)
	var t: TunablesLoader = _make_tunables()
	var cd: ClassDef = _make_warrior(t)
	var s: RulesSession = RulesSession.new()
	s.setup_campaign(t, cd, 42)
	s.input({"type": "throw"})
	s.step()
	var pending: Dictionary = s.consume_pending()
	var cues: Array = pending.get("cues", [])
	var found: bool = false
	for cue in cues:
		if str(cue.get("cue_id", "")) == "cue.player.throw":
			found = true
			break
	if not found:
		return {"ok": false, "msg": "cue.player.throw not in consume_pending cues (%d cues)" % cues.size()}
	return {"ok": true}

func test_e2e_consume_pending_drains_queue() -> Dictionary:
	# why: second consume_pending must return empty cues (the drain contract)
	var t: TunablesLoader = _make_tunables()
	var cd: ClassDef = _make_warrior(t)
	var s: RulesSession = RulesSession.new()
	s.setup_campaign(t, cd, 42)
	s.input({"type": "throw"})
	s.step()
	var first: Dictionary = s.consume_pending()
	var second: Dictionary = s.consume_pending()
	if first.get("cues", []).size() == 0:
		return {"ok": false, "msg": "first drain had no cues — throw did not emit"}
	if second.get("cues", []).size() != 0:
		return {"ok": false, "msg": "second drain should be empty, got %d cues" % second.get("cues", []).size()}
	return {"ok": true}

func test_e2e_cue_bus_forwards_session_cues() -> Dictionary:
	# why: the full forward path — RulesSession.consume_pending() output
	# piped through CueBus.emit_from_pending lands every cue in emitted_log
	var t: TunablesLoader = _make_tunables()
	var cd: ClassDef = _make_warrior(t)
	var s: RulesSession = RulesSession.new()
	s.setup_campaign(t, cd, 42)
	s.input({"type": "throw"})
	s.step()
	var bus: CueBus = CueBus.new()
	var count: int = bus.emit_from_pending(s.consume_pending())
	if count < 1:
		bus.free()
		return {"ok": false, "msg": "expected at least 1 cue forwarded, got %d" % count}
	if bus.emitted_log.size() != count:
		bus.free()
		return {"ok": false, "msg": "log size %d != count %d" % [bus.emitted_log.size(), count]}
	# why: cue.player.throw must be in the forwarded set
	var has_throw: bool = false
	for entry in bus.emitted_log:
		if str(entry.get("cue_id", "")) == "cue.player.throw":
			has_throw = true
			break
	if not has_throw:
		bus.free()
		return {"ok": false, "msg": "cue.player.throw missing from forwarded log"}
	bus.free()
	return {"ok": true}
