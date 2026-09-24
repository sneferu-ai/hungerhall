extends SceneTree
## HUNGERHALL — tools/solver.gd (G6 §2, G2 §7). BUILD-TIME ONLY.
## Re-verifies solver gates 1–9 (core/rules_solver_check.gd) on every baked
## floor resource. The runtime contains zero layout RNG; this tool is the
## proof that what shipped actually passed the gates at bake time.
##
## Command (spec-pinned):
##   godot --headless --script tools/solver.gd -- \
##     --floors data/floors/base/ --tunables Tunables.json [--check-band-extremes]
##
## Exit 0 = all 24 floors pass gates 1–9 at the current locked tunables.
## Exit 1 = missing floors or any gate failure.
##
## --check-band-extremes (advisory): re-runs the static HP budget (gate 8)
## at the min/max of each tunable band's declared range. A failing extreme
## does NOT fail the build — per G2 §7 it is the signal that the band would
## need narrowing before that extreme could be adopted; the tool prints the
## narrowing report and the bake keeps the locked current values.

func _init() -> void:
	var code: int = _main()
	quit(code)

func _main() -> int:
	var raw: Array = OS.get_cmdline_user_args()
	var args: Dictionary = {}
	var check_extremes: bool = false
	var i: int = 0
	while i < raw.size():
		var a: String = str(raw[i])
		if a == "--check-band-extremes":
			check_extremes = true
			i += 1
		elif a.begins_with("--") and i + 1 < raw.size():
			args[a.substr(2)] = str(raw[i + 1])
			i += 2
		else:
			i += 1
	for required in ["floors", "tunables"]:
		if not args.has(required):
			push_error("solver: missing required argument --%s" % required)
			print("usage: godot --headless --script tools/solver.gd -- --floors data/floors/base/ --tunables Tunables.json [--check-band-extremes]")
			return 1

	var floors_path: String = _res_path(args.floors)
	if floors_path.ends_with("/"):
		floors_path = floors_path.left(floors_path.length() - 1)
	var tunables: TunablesLoader = TunablesLoader.new()
	if not tunables.load_from_path(_res_path(args.tunables)):
		push_error("solver: cannot load tunables: " + "; ".join(tunables.get_errors()))
		return 1

	var class_hps: Array = []
	for cd in ClassDef.build_all(tunables):
		class_hps.append(cd.hp)

	var failures: int = 0
	for fn in range(1, 25):
		var path: String = "%s/floor_%02d.tres" % [floors_path, fn]
		if not ResourceLoader.exists(path):
			print("floor_%02d: MISSING (%s)" % [fn, path])
			failures += 1
			continue
		var res: Resource = load(path)
		if not (res is FloorData):
			print("floor_%02d: NOT A FloorData resource" % fn)
			failures += 1
			continue
		var fd: FloorData = res
		if fd.floor_number != fn:
			print("floor_%02d: floor_number field is %d" % [fn, fd.floor_number])
			failures += 1
			continue
		var result: Dictionary = RulesSolverCheck.run_all_gates(fd, tunables, class_hps)
		if result.pass:
			print("floor_%02d: PASS (zone %d, %d food, gates 1-9 green)" % [fn, fd.zone, fd.foods.size()])
			for g in range(1, 10):
				print("   gate %d: %s" % [g, result.gates[g].msg])
		else:
			failures += 1
			print("floor_%02d: FAIL" % fn)
			for g in range(1, 10):
				if not result.gates[g].pass:
					print("   gate %d FAILED: %s" % [g, result.gates[g].msg])

	if check_extremes:
		print("\n--- band-extreme budget probe (advisory; failures would narrow the band) ---")
		var min_hp: int = 1 << 30
		for hp in class_hps:
			min_hp = mini(min_hp, int(hp))
		for band in range(1, 9):
			var drain_key: String = "drain_band_%d" % band
			var target_key: String = "target_seconds_band_%d" % band
			var combat_key: String = "combat_damage_estimate_band_%d" % band
			var drain_band: Array = tunables.band_of(drain_key)
			var target_band: Array = tunables.band_of(target_key)
			var combat_band: Array = tunables.band_of(combat_key)
			if drain_band.is_empty() or target_band.is_empty() or combat_band.is_empty():
				print("band %d: missing band metadata, skipped" % band)
				continue
			var fn_for_band: int = band * 3 - 2  # first floor of the band
			var extremes_ok: bool = true
			for drain_v in [float(drain_band[0]), float(drain_band[1])]:
				for target_v in [int(target_band[0]), int(target_band[1])]:
					for combat_v in [int(combat_band[0]), int(combat_band[1])]:
						var t2: TunablesLoader = tunables.with_override(drain_key, drain_v)
						t2 = t2.with_override(target_key, float(target_v))
						t2 = t2.with_override(combat_key, float(combat_v))
						var r: Dictionary = RulesSolverCheck.check_floor(fn_for_band, min_hp, t2)
						if not r.total_ok:
							extremes_ok = false
							print("band %d: extreme drain=%.1f target=%d combat=%d FAILS min-class budget by %.1f HP -> band would need narrowing" % [band, drain_v, target_v, combat_v, -float(r.hp_surplus)])
			if extremes_ok:
				print("band %d: all 8 extremes hold" % band)

	if failures > 0:
		push_error("solver: %d floor(s) failed verification" % failures)
		return 1
	print("solver: all 24 floors pass gates 1-9")
	return 0

func _res_path(p: String) -> String:
	if p.begins_with("res://") or p.begins_with("user://") or p.is_absolute_path():
		return p
	return "res://" + p
