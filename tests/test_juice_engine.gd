extends RefCounted
## test_juice_engine — G9 §10 budget gates on the product's fixed-step tween
## engine (JuiceTweenEngine). The file juice/juice_tween_engine.gd:37 cites
## THIS suite (round-4 blocker: dangling citation). Every assertion is step or
## sample-counted — structural budget math, never wall-clock (G9 "frame-rate
## assertions are structural, not wall-clock flaky").
##
## G9 pins exercised here:
##  - one-shot cap 48 / critical sub-cap 23 / ambient cap 16 (juice.tween.cap,
##    juice.tween.critical_subcap, juice.ambient.cap — Tunables-resolved);
##  - enforcement order: per-type caps FIRST, then global priority cull
##    (OBL-55), critical never culled;
##  - OQ-21 TRANS_BACK overshoot ≤8% at 1ms granularity on a 32px sprite;
##  - per-type overflow behavior for EVERY type in JuiceContracts.type_table.

const EASE: String = "cubic_out"

func _ok(msg: String = "") -> Dictionary:
	return {"ok": true, "msg": msg}

func _fail(msg: String) -> Dictionary:
	return {"ok": false, "msg": msg}

func _new_engine() -> JuiceTweenEngine:
	var tun: TunablesLoader = TunablesLoader.new()
	tun.load_from_path("res://Tunables.json")
	var e: JuiceTweenEngine = JuiceTweenEngine.new()
	e.configure(tun)  # caps resolve from Tunables — the code never hardcodes 48/23/16
	return e

## One minimal 1-unit spec bound to a recorder closure.
func _spec(ac: String, ttype: String, units: int, critical: bool, priority: int, ticks: int, recorder: Dictionary, ambient: bool = false) -> Dictionary:
	return {
		"ac": ac, "type": ttype, "units": units, "critical": critical,
		"priority": priority, "ambient": ambient, "loop_pp": false,
		"world": false, "cap": JuiceContracts.type_table().get(ttype, {}).get("cap", 0),
		"overflow": str(JuiceContracts.type_table().get(ttype, {}).get("overflow", "snap_oldest")),
		"segments": [{
			"apply": func(v: Variant) -> void: recorder["last"] = float(v),
			"kind": "float", "from": 0.0, "to": 1.0, "ticks": ticks,
			"easing": EASE, "delay_ticks": 0,
		}],
	}

# ============================================================ curves (deterministic samples)

func test_curve_endpoints_and_monotonicity() -> Dictionary:
	for easing in ["linear", "cubic_out", "cubic_in_out"]:
		var v0: float = JuiceTweenEngine.ease_value(easing, 0.0)
		var v1: float = JuiceTweenEngine.ease_value(easing, 1.0)
		if absf(v0) > 0.0001 or absf(v1 - 1.0) > 0.0001:
			return _fail(easing + " must map 0->0 and 1->1 (got %f -> %f)" % [v0, v1])
		var prev: float = -1.0
		for i in range(0, 101):
			var v: float = JuiceTweenEngine.ease_value(easing, float(i) / 100.0)
			if v < prev - 0.0001:
				return _fail(easing + " not monotonic at t=%f" % (float(i) / 100.0))
			prev = v
	return _ok()

func test_oq21_back_out_overshoot_at_1ms_granularity() -> Dictionary:
	# OQ-21: sample the max bounding box across the FULL tween at 1ms
	# granularity; assert <= 34.56px on a 32px sprite (8% overshoot ceiling,
	# G9 preamble "one sanctioned overshoot exception"). A 400ms tween = 400
	# samples of the back_out curve — exact G9 procedure, deterministic.
	var sprite_px: float = 32.0
	var max_px: float = sprite_px
	var tween_ms: int = 400
	for ms in range(0, tween_ms + 1):
		var t: float = float(ms) / float(tween_ms)
		var scale_v: float = JuiceTweenEngine.ease_value("back_out", t)
		max_px = maxf(max_px, sprite_px * scale_v)
	if max_px > 34.5601:
		return _fail("OQ-21: back_out peaked at %.3fpx on a 32px sprite (> 34.56px ceiling)" % max_px)
	return _ok()

func test_back_overshoot_bound_constant_pinned() -> Dictionary:
	# why: the engine's sanctioned overshoot constant is exactly 8% (G9).
	# A silent retune of BACK_S that breaks the 8% ceiling must fail here.
	var peak: float = 0.0
	for i in range(0, 1001):
		peak = maxf(peak, JuiceTweenEngine.ease_value("back_out", float(i) / 1000.0))
	var overshoot: float = peak - 1.0
	if overshoot > 0.0801 or overshoot < 0.04:
		return _fail("back_out overshoot %.4f outside the sanctioned ~8%% band" % overshoot)
	return _ok()

# ============================================================ ms -> tick determinism

func test_ms_to_tick_math_is_structural() -> Dictionary:
	# why: fixed 60Hz conversion — animation-timing tests assert TICKS, not
	# wall-clock. These pins are the G9 durations expressed as frame budget.
	var cases: Array = [
		[160.0, 10],   # AC-26 caption in
		[180.0, 11],   # AC-28 caption out
		[250.0, 15],   # AC-59 results panel / AC-37 telegraph
		[350.0, 21],   # AC-60 score countup
		[500.0, 30],   # AC-62 game-over entry
		[80.0, 5],     # hit flash
		[40.0, 2],     # hit flash under Reduce Motion (halved)
	]
	for c in cases:
		var got: int = JuiceTweenEngine.ms_to_ticks(float(c[0]))
		if got != int(c[1]):
			return _fail("ms_to_ticks(%s) = %d, G9 expects %d" % [str(c[0]), got, int(c[1])])
	return _ok()

func test_caps_resolve_from_tunables_not_hardcoded() -> Dictionary:
	var e: JuiceTweenEngine = _new_engine()
	if e.oneshot_cap != 48 or e.critical_subcap != 23 or e.ambient_cap != 16:
		return _fail("caps %d/%d/%d != G9 48/23/16 from Tunables" % [e.oneshot_cap, e.critical_subcap, e.ambient_cap])
	return _ok()

# ============================================================ tween cap enforcement (G9 matrix: 3)

func test_cap_boundary_exactly_48_units_fit() -> Dictionary:
	var e: JuiceTweenEngine = _new_engine()
	var rec: Dictionary = {}
	# 23 critical (sub-cap max) + 25 normal = exactly 48 one-unit tweens
	for i in range(23):
		var s: Dictionary = _spec("crit_%d" % i, "sig5", 1, true, 3, 60, rec)
		s["cap"] = 0  # bypass per-type for the pure budget probe
		if not e.request(s):
			return _fail("critical %d rejected below sub-cap" % i)
	for i in range(25):
		var s: Dictionary = _spec("norm_%d" % i, "enemy_death", 1, false, 2, 60, rec)
		s["cap"] = 0
		if not e.request(s):
			return _fail("normal %d rejected below the 48 cap" % i)
	if e.active_unit_count() != 48:
		return _fail("boundary: active units %d != 48" % e.active_unit_count())
	# the 49th one-unit request must NOT push the engine past 48: either it is
	# rejected or the priority cull frees a slot (G9 enforcement order)
	var extra: Dictionary = _spec("extra", "enemy_death", 1, false, 2, 60, rec)
	extra["cap"] = 0
	e.request(extra)
	if e.active_unit_count() > 48:
		return _fail("boundary: active units %d > 48 after the 49th request" % e.active_unit_count())
	return _ok()

func test_critical_subcap_overflow_rejected() -> Dictionary:
	var e: JuiceTweenEngine = _new_engine()
	var rec: Dictionary = {}
	# 23 critical one-unit tweens fit; the 24th is rejected at the sub-cap
	for i in range(23):
		var s: Dictionary = _spec("crit_%d" % i, "sig5", 1, true, 3, 60, rec)
		s["cap"] = 0
		if not e.request(s):
			return _fail("critical %d rejected below the 23 sub-cap" % i)
	var s24: Dictionary = _spec("crit_23", "sig5", 1, true, 3, 60, rec)
	s24["cap"] = 0
	if e.request(s24):
		return _fail("24th critical unit accepted — sub-cap 23 not enforced")
	if e.critical_unit_count() != 23:
		return _fail("critical units %d != 23" % e.critical_unit_count())
	# and the global cull must NEVER touch criticals to make room
	var n: Dictionary = _spec("norm", "enemy_death", 1, false, 2, 60, rec)
	n["cap"] = 0
	e.request(n)
	if e.critical_unit_count() != 23:
		return _fail("priority cull killed a critical tween")
	return _ok()

func test_same_property_flash_pattern_is_one_unit() -> Dictionary:
	# G9 counting rule: flash pattern (instant set to peak + tween back on the
	# SAME property) = 1 budget unit, and it returns the property to rest.
	var e: JuiceTweenEngine = _new_engine()
	var rec: Dictionary = {"last": -1.0}
	var s: Dictionary = _spec("flash", "hit_flash", 1, false, 1, 5, rec)
	s["cap"] = 0
	s["segments"] = [
		{"apply": func(v: Variant) -> void: rec["last"] = float(v), "kind": "float", "from": 0.0, "to": 0.85, "ticks": 1, "easing": "linear", "delay_ticks": 0, "set_instant": true},
		{"apply": func(v: Variant) -> void: rec["last"] = float(v), "kind": "float", "from": 0.85, "to": 0.0, "ticks": 5, "easing": EASE, "delay_ticks": 0},
	]
	if not e.request(s):
		return _fail("flash spec rejected")
	if e.active_unit_count() != 1:
		return _fail("flash pattern must occupy 1 budget unit, got %d" % e.active_unit_count())
	if absf(float(rec.get("last", -1.0)) - 0.85) > 0.0001:
		return _fail("instant set must land at peak 0.85 immediately, got %s" % str(rec.get("last")))
	for i in range(6):
		e.step(false)
	if e.active_count() != 0:
		return _fail("flash tween did not complete in its tick budget")
	if absf(float(rec.get("last", -1.0))) > 0.0001:
		return _fail("flash must rest at 0.0, got %s" % str(rec.get("last")))
	return _ok()

func test_ambient_cap_16_enforced() -> Dictionary:
	var e: JuiceTweenEngine = _new_engine()
	var rec: Dictionary = {}
	for i in range(16):
		var s: Dictionary = _spec("amb_%d" % i, "gen_idle", 1, false, 1, 60, rec, true)
		s["cap"] = 0
		if not e.request(s):
			return _fail("ambient %d rejected below the 16 cap" % i)
	var s17: Dictionary = _spec("amb_16", "gen_idle", 1, false, 1, 60, rec, true)
	s17["cap"] = 0
	if e.request(s17):
		return _fail("17th ambient unit accepted — ambient cap 16 not enforced")
	return _ok()

func test_global_priority_cull_kills_low_first_and_spare_critical() -> Dictionary:
	var e: JuiceTweenEngine = _new_engine()
	var rec_low: Dictionary = {}
	var rec_high: Dictionary = {}
	var rec_crit: Dictionary = {}
	# fill 48: 23 critical(p3) + 20 high(p2) + 5 low(p0)
	for i in range(23):
		var s: Dictionary = _spec("c%d" % i, "sig5", 1, true, 3, 60, rec_crit)
		s["cap"] = 0
		e.request(s)
	for i in range(20):
		var s: Dictionary = _spec("h%d" % i, "enemy_death", 1, false, 2, 60, rec_high)
		s["cap"] = 0
		e.request(s)
	for i in range(5):
		var s: Dictionary = _spec("l%d" % i, "projectile_spawn", 1, false, 0, 60, rec_low)
		s["cap"] = 0
		e.request(s)
	if e.active_unit_count() != 48:
		return _fail("setup failed: %d != 48" % e.active_unit_count())
	# a new 2-unit HIGH request forces a cull: low(p0) dies first
	var incoming: Dictionary = _spec("h_in", "floater", 2, false, 2, 60, rec_high)
	incoming["cap"] = 0
	if not e.request(incoming):
		return _fail("incoming high request rejected even though low-priority cullables exist")
	var lows_left: int = e.tweens_of_type("projectile_spawn").size()
	if lows_left != 3:
		return _fail("cull killed %d low tweens, expected exactly 2 (oldest-first)" % (5 - lows_left))
	if e.critical_unit_count() != 23:
		return _fail("cull touched criticals")
	if e.active_unit_count() != 48:
		return _fail("post-cull units %d != 48" % e.active_unit_count())
	return _ok()

func test_hitstop_freezes_world_tweens_advances_ui() -> Dictionary:
	var e: JuiceTweenEngine = _new_engine()
	var rec_w: Dictionary = {"last": -1.0}
	var rec_u: Dictionary = {"last": -1.0}
	var sw: Dictionary = _spec("world", "enemy_death", 1, false, 2, 10, rec_w)
	sw["cap"] = 0
	sw["world"] = true
	var su: Dictionary = _spec("ui", "hit_flash", 1, false, 1, 10, rec_u)
	su["cap"] = 0
	su["world"] = false
	e.request(sw)
	e.request(su)
	e.step(true)  # hitstop active
	e.step(true)
	var w_frozen: float = float(rec_w.get("last", -1.0))
	var u_moved: float = float(rec_u.get("last", -1.0))
	if absf(w_frozen - (-1.0)) > 0.0001:
		return _fail("world tween advanced during hitstop (OBL-31 violation)")
	if absf(u_moved - (-1.0)) < 0.0001:
		return _fail("UI tween frozen during hitstop — UI juice must keep advancing")
	return _ok()

# ============================================================ per-type overflow (G9 matrix: 1 per type)

func test_per_type_overflow_battery_every_type_table_row() -> Dictionary:
	# G9 §10 "Per-type overflow | 1 per type with defined overflow". This
	# battery walks EVERY row of JuiceContracts.type_table and asserts the
	# contracted behavior at the cap boundary:
	#   reject       -> (cap+1)th request refused, count stays at cap
	#   snap_oldest  -> (cap+1)th accepted, count stays at cap, oldest freed
	#   new_kills    -> same shape as snap_oldest (oldest instance dies)
	var table: Dictionary = JuiceContracts.type_table()
	if table.size() < 28:
		return _fail("type_table has %d rows, G9 pins 28 per-type caps" % table.size())
	for ttype in table.keys():
		var row: Dictionary = table[ttype]
		var cap: int = int(row.get("cap", 0))
		var overflow: String = str(row.get("overflow", ""))
		var priority: int = int(row.get("priority", 1))
		var critical: bool = priority >= 3  # G9 priority taxonomy: 3 = critical
		var e: JuiceTweenEngine = _new_engine()
		var rec: Dictionary = {}
		for i in range(cap):
			var s: Dictionary = _spec("t%d" % i, ttype, 1, critical, priority, 60, rec)
			if not e.request(s):
				return _fail("[%s] instance %d/%d rejected below its own cap" % [ttype, i, cap])
		var extra: Dictionary = _spec("overflow", ttype, 1, critical, priority, 60, rec)
		var accepted: bool = e.request(extra)
		var live: int = e.tweens_of_type(ttype).size()
		if overflow == "reject":
			if accepted:
				return _fail("[%s] overflow=reject but the %dth instance was accepted" % [ttype, cap + 1])
			if live != cap:
				return _fail("[%s] post-reject count %d != cap %d" % [ttype, live, cap])
		else:
			if not accepted:
				return _fail("[%s] overflow=%s but the %dth instance was rejected" % [ttype, overflow, cap + 1])
			if live != cap:
				return _fail("[%s] post-overflow count %d != cap %d (oldest must free first)" % [ttype, live, cap])
	return _ok()

func test_gen_destroy_two_per_burst_matches_rules_invariant() -> Dictionary:
	# OBL-1/74/93: gen_destroy per-type cap 2 mirrors
	# rules_floor.max_destructible_generators_per_burst = 2. A 3rd destruction
	# inside the burst window snap-completes the oldest — never rejects, never
	# exceeds 2 live composites.
	var e: JuiceTweenEngine = _new_engine()
	var rec: Dictionary = {}
	for i in range(3):
		if not e.request(_spec("gen_%d" % i, "gen_destroy", 7, true, 3, 60, rec)):
			return _fail("gen destruction %d rejected (cap 2 must snap-oldest, not reject)" % i)
	if e.tweens_of_type("gen_destroy").size() != 2:
		return _fail("3 bursts left %d live composites, G9 caps 2" % e.tweens_of_type("gen_destroy").size())
	if e.critical_unit_count() != 14:
		return _fail("2 live 7-unit composites = 14 critical units, got %d" % e.critical_unit_count())
	return _ok()
