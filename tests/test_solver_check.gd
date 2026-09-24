extends RefCounted
## test_solver_check — every floor completable for every class.

func test_band_mapping() -> Dictionary:
	# why: 24 floors → 8 bands of 3
	if RulesSolverCheck.band_for_floor(1) != 1:
		return {"ok": false, "msg": "floor 1 → band %d, expected 1" % RulesSolverCheck.band_for_floor(1)}
	if RulesSolverCheck.band_for_floor(3) != 1:
		return {"ok": false, "msg": "floor 3 → band %d, expected 1" % RulesSolverCheck.band_for_floor(3)}
	if RulesSolverCheck.band_for_floor(4) != 2:
		return {"ok": false, "msg": "floor 4 → band %d, expected 2" % RulesSolverCheck.band_for_floor(4)}
	if RulesSolverCheck.band_for_floor(24) != 8:
		return {"ok": false, "msg": "floor 24 → band %d, expected 8" % RulesSolverCheck.band_for_floor(24)}
	return {"ok": true}

func test_all_floors_completable_warrior() -> Dictionary:
	var t: TunablesLoader = TunablesLoader.new()
	t.load_from_path("res://Tunables.json")
	var result: Dictionary = RulesSolverCheck.check_all_floors(int(t.get_value("warrior_hp", 800)), t)
	if not result.all_ok:
		var fails: Array = []
		for fr in result.floors:
			if not fr.total_ok:
				fails.append("floor %d: drain+combat=%d vs hp_budget=%d" % [fr.floor, fr.drain_plus_combat, fr.effective_hp_budget])
		return {"ok": false, "msg": "warrior fails floors: " + str(fails)}
	return {"ok": true}

func test_all_classes_all_floors() -> Dictionary:
	var t: TunablesLoader = TunablesLoader.new()
	t.load_from_path("res://Tunables.json")
	var classes: Array = []
	for ct in [StateEnums.ClassType.WARRIOR, StateEnums.ClassType.VALKYRIE, StateEnums.ClassType.WIZARD, StateEnums.ClassType.ELF]:
		var cd: ClassDef = ClassDef.new()
		cd.class_type = ct
		match ct:
			StateEnums.ClassType.WARRIOR: cd.hp = int(t.get_value("warrior_hp", 800))
			StateEnums.ClassType.VALKYRIE: cd.hp = int(t.get_value("valkyrie_hp", 680))
			StateEnums.ClassType.WIZARD: cd.hp = int(t.get_value("wizard_hp", 520))
			StateEnums.ClassType.ELF: cd.hp = int(t.get_value("elf_hp", 560))
		classes.append(cd)
	var result: Dictionary = RulesSolverCheck.check_all_classes(classes, t)
	if not result.all_ok:
		return {"ok": false, "msg": "not all class/floor combinations are completable"}
	return {"ok": true}

func test_g2_locked_difficulty_table() -> Dictionary:
	# why: G2 §3 LOCKS the difficulty table — target s/floor RISING
	# 120–150 → 270–300 and combat estimates 500..1250. Tunables.json is the
	# runtime/bake authority (DIS-3) and must carry EXACTLY the locked
	# values; round 1 shipped them falling 135→30 / combat 120→200, which
	# contradicted the lock (round-2 review blocker).
	var locked_targets: Array = [135, 165, 195, 225, 255, 255, 285, 285]
	var locked_bands: Array = [
		[120, 150], [150, 180], [180, 210], [210, 240],
		[240, 270], [240, 270], [270, 300], [270, 300]
	]
	var locked_combat: Array = [500, 700, 700, 850, 950, 1100, 1100, 1250]
	var f := FileAccess.open("res://Tunables.json", FileAccess.READ)
	if f == null:
		return {"ok": false, "msg": "cannot open res://Tunables.json"}
	var text: String = f.get_as_text()
	f.close()
	var parsed = JSON.parse_string(text)
	if not (parsed is Dictionary):
		return {"ok": false, "msg": "Tunables.json did not parse to a dict"}
	var consts: Dictionary = parsed.get("constants", {})
	for i in range(8):
		var b: int = i + 1
		var te = consts.get("target_seconds_band_" + str(b), null)
		if not (te is Dictionary):
			return {"ok": false, "msg": "target_seconds_band_%d missing" % b}
		if int(te.get("value", -1)) != locked_targets[i]:
			return {"ok": false, "msg": "target_seconds_band_%d value=%s, G2 §3 locks %d" % [b, str(te.get("value")), locked_targets[i]]}
		var tband = te.get("band", [])
		if not (tband is Array) or tband.size() != 2 or int(tband[0]) != locked_bands[i][0] or int(tband[1]) != locked_bands[i][1]:
			return {"ok": false, "msg": "target_seconds_band_%d band=%s, G2 §3 locks %s" % [b, str(tband), str(locked_bands[i])]}
		var ce = consts.get("combat_damage_estimate_band_" + str(b), null)
		if not (ce is Dictionary):
			return {"ok": false, "msg": "combat_damage_estimate_band_%d missing" % b}
		if int(ce.get("value", -1)) != locked_combat[i]:
			return {"ok": false, "msg": "combat_damage_estimate_band_%d value=%s, G2 §3 locks %d" % [b, str(ce.get("value")), locked_combat[i]]}
	return {"ok": true}

func test_food_formula_g2_locked_column() -> Dictionary:
	# why: G2 §3 food formula
	#   max(1, ceil((drain×target_mid + combat − min_class_HP + margin_HP) / food_hp))
	# must reproduce the locked per-band food column 3/5/6/8/11/12/14/16;
	# under round-1's degenerate constants band 8 computed ≤1 piece where
	# G2's worked example requires 16.
	var t: TunablesLoader = TunablesLoader.new()
	if not t.load_from_path("res://Tunables.json"):
		return {"ok": false, "msg": "tunables load failed: " + str(t.errors())}
	var expected: Array = [3, 5, 6, 8, 11, 12, 14, 16]
	for i in range(8):
		var b: int = i + 1
		var pieces: int = RulesSolverCheck.food_pieces_for_band(b, t)
		if pieces != expected[i]:
			return {"ok": false, "msg": "band %d food_pieces=%d, G2 §3 locks %d" % [b, pieces, expected[i]]}
	return {"ok": true}

func test_static_hp_budget_g2_worked_examples() -> Dictionary:
	# why: G2 §7 static HP budget —
	#   (drain×target_mid + combat) ≤ (class_hp + food_pieces×food_hp − margin_hp)
	# Spec worked examples: F1–3 Wizard spends 270+500=770 vs 520+450−52=918
	# (margin 200); F22–24 Wizard spends 1567.5+1250=2817.5 vs 520+2400−52=2868
	# (margin 102.5). The budget is INCOMPLETE without the food term — the
	# round-1 solver omitted it and passed only because combat was 4–6× low.
	var t: TunablesLoader = TunablesLoader.new()
	if not t.load_from_path("res://Tunables.json"):
		return {"ok": false, "msg": "tunables load failed: " + str(t.errors())}
	var wizard_hp: int = int(t.get_value("wizard_hp", 520))
	var r1: Dictionary = RulesSolverCheck.check_floor(1, wizard_hp, t)
	if not r1.get("total_ok", false):
		return {"ok": false, "msg": "floor 1 wizard fails: " + JSON.stringify(r1)}
	if int(r1.get("drain_plus_combat", -1)) != 770:
		return {"ok": false, "msg": "floor 1 spend=%s, G2 §3 worked example is 770" % str(r1.get("drain_plus_combat"))}
	if int(r1.get("effective_hp_budget", -1)) != 918:
		return {"ok": false, "msg": "floor 1 budget=%s, G2 §3 worked example is 918" % str(r1.get("effective_hp_budget"))}
	var r24: Dictionary = RulesSolverCheck.check_floor(24, wizard_hp, t)
	if not r24.get("total_ok", false):
		return {"ok": false, "msg": "floor 24 wizard fails: " + JSON.stringify(r24)}
	if int(r24.get("drain_plus_combat", -1)) != 2817:
		return {"ok": false, "msg": "floor 24 spend=%s, G2 §3 worked example is 2817.5 (int 2817)" % str(r24.get("drain_plus_combat"))}
	if int(r24.get("effective_hp_budget", -1)) != 2868:
		return {"ok": false, "msg": "floor 24 budget=%s, G2 §3 worked example is 2868" % str(r24.get("effective_hp_budget"))}
	return {"ok": true}

func test_band_for_floor_clamping() -> Dictionary:
	# why: band_for_floor clamps to [1,8] — floors outside [1,24] must not
	# index an out-of-range band (would KeyError the Tunables lookup). Floor 0
	# and floors past 24 are the guard rails.
	if RulesSolverCheck.band_for_floor(0) != 1:
		return {"ok": false, "msg": "floor 0 → band %d, expected 1 (clamped)" % RulesSolverCheck.band_for_floor(0)}
	if RulesSolverCheck.band_for_floor(-3) != 1:
		return {"ok": false, "msg": "floor -3 → band %d, expected 1 (clamped)" % RulesSolverCheck.band_for_floor(-3)}
	if RulesSolverCheck.band_for_floor(25) != 8:
		return {"ok": false, "msg": "floor 25 → band %d, expected 8 (clamped)" % RulesSolverCheck.band_for_floor(25)}
	if RulesSolverCheck.band_for_floor(100) != 8:
		return {"ok": false, "msg": "floor 100 → band %d, expected 8 (clamped)" % RulesSolverCheck.band_for_floor(100)}
	return {"ok": true}

func test_food_pieces_food_hp_zero_guard() -> Dictionary:
	# why: food_pieces_for_band must never divide by zero — the food_hp<=0
	# guard falls back to 150. Verify with a tunables clone carrying food_hp=0;
	# the result must equal the normal food_pieces for that band.
	var t: TunablesLoader = TunablesLoader.new()
	if not t.load_from_path("res://Tunables.json"):
		return {"ok": false, "msg": "tunables load failed: " + str(t.errors())}
	var t_zero: TunablesLoader = t.with_override("food_hp", 0.0)
	var normal_b1: int = RulesSolverCheck.food_pieces_for_band(1, t)
	var guard_b1: int = RulesSolverCheck.food_pieces_for_band(1, t_zero)
	if guard_b1 != normal_b1:
		return {"ok": false, "msg": "food_hp=0 guard produced %d, expected %d (normal band-1)" % [guard_b1, normal_b1]}
	if guard_b1 < 1:
		return {"ok": false, "msg": "food_hp=0 guard produced %d, must be >=1 (max(1,...) floor)" % guard_b1}
	return {"ok": true}

func test_check_floor_meets_floor_false_for_low_hp() -> Dictionary:
	# why: meets_floor guards against a class below the locked min_class_hp
	# (520 = Wizard). Even if the static HP budget math passes for a high-drain
	# floor with a tiny HP pool (it won't, but the guard is belt-and-suspenders),
	# total_ok must be false when class_hp < min_class_hp.
	var t: TunablesLoader = TunablesLoader.new()
	if not t.load_from_path("res://Tunables.json"):
		return {"ok": false, "msg": "tunables load failed: " + str(t.errors())}
	var r: Dictionary = RulesSolverCheck.check_floor(1, 400, t)
	if bool(r.get("meets_floor", true)):
		return {"ok": false, "msg": "class_hp=400 should fail meets_floor (min_class_hp=520)"}
	if bool(r.get("total_ok", true)):
		return {"ok": false, "msg": "total_ok must be false when meets_floor is false"}
	return {"ok": true}
