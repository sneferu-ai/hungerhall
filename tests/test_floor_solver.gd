extends RefCounted
## test_floor_solver — re-verifies solver gates 1–9 on ALL 24 baked floors
## (tools/floor_baker.gd output). Gate 3's reachability assumes doors open;
## test_pickups joins that assumption to the runtime push-to-open rule.

func _tun() -> TunablesLoader:
	var t: TunablesLoader = TunablesLoader.new()
	t.load_from_path("res://Tunables.json")
	return t

func _class_hps(t: TunablesLoader) -> Array:
	return [
		int(t.get_value("warrior_hp", 800)),
		int(t.get_value("valkyrie_hp", 680)),
		int(t.get_value("wizard_hp", 520)),
		int(t.get_value("elf_hp", 560))
	]

func test_all_24_baked_floors_exist_and_load() -> Dictionary:
	for fn in range(1, 25):
		var path: String = RulesSession.baked_floor_path(fn)
		if not ResourceLoader.exists(path):
			return {"ok": false, "msg": "missing baked floor %s" % path}
		var res: Resource = load(path)
		if not (res is FloorData):
			return {"ok": false, "msg": "%s did not load as FloorData" % path}
		if res.floor_number != fn:
			return {"ok": false, "msg": "%s stamps floor_number %d" % [path, res.floor_number]}
	return {"ok": true}

func test_gates_1_through_9_all_floors() -> Dictionary:
	var t: TunablesLoader = _tun()
	var hps: Array = _class_hps(t)
	for fn in range(1, 25):
		var fd: FloorData = load(RulesSession.baked_floor_path(fn))
		var result: Dictionary = RulesSolverCheck.run_all_gates(fd, t, hps)
		if not result.get("pass", false):
			var failed: Array = []
			var gates: Dictionary = result.get("gates", {})
			for i in range(1, 10):
				if not gates[i].pass:
					failed.append("gate%d:%s" % [i, str(gates[i].get("msg", ""))])
			return {"ok": false, "msg": "floor %d failed: %s" % [fn, "; ".join(failed)]}
	return {"ok": true}

func test_gate3_doors_open_reachability() -> Dictionary:
	# why: gate 3 is the spawn→key→door→exit chain with doors treated open —
	# pin that assumption explicitly on a door-gated floor (floor_02)
	var fd: FloorData = load(RulesSession.baked_floor_path(2))
	if fd.doors.is_empty():
		return {"ok": false, "msg": "floor_02 no longer door-gated — pick a new fixture"}
	var g3: Dictionary = RulesSolverCheck.gate_3_reachability(fd)
	if not g3.pass:
		return {"ok": false, "msg": "gate 3 failed on floor_02: %s" % str(g3.get("msg", ""))}
	return {"ok": true}

func test_band_fields_frozen_in_floor_data() -> Dictionary:
	# why: runtime never recomputes band constants — the .tres carries them
	# frozen from the bake; spot the band-1 and band-8 anchors
	var t: TunablesLoader = _tun()
	var f1: FloorData = load(RulesSession.baked_floor_path(1))
	if abs(f1.drain_hp_per_sec - RulesSolverCheck.drain_hp_for_band(1, t)) > 0.001:
		return {"ok": false, "msg": "floor_01 drain %f != band-1 %f" % [f1.drain_hp_per_sec, RulesSolverCheck.drain_hp_for_band(1, t)]}
	var f24: FloorData = load(RulesSession.baked_floor_path(24))
	if abs(f24.drain_hp_per_sec - RulesSolverCheck.drain_hp_for_band(8, t)) > 0.001:
		return {"ok": false, "msg": "floor_24 drain %f != band-8 %f" % [f24.drain_hp_per_sec, RulesSolverCheck.drain_hp_for_band(8, t)]}
	if f24.target_seconds != RulesSolverCheck.target_seconds_for_band(8, t):
		return {"ok": false, "msg": "floor_24 target %d != band-8" % f24.target_seconds}
	return {"ok": true}
