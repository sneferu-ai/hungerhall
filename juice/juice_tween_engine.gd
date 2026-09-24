class_name JuiceTweenEngine
extends RefCounted
## G10 — HUNGERHALL juice tween engine (G9 §2 counting rules, implemented on
## the product's locked determinism rail).
##
## CONSCIOUS SUPERSession (documented in POLISH_BRIEF §1): G9 names Godot
## Tween/AnimationPlayer as the engine-native rail, but this product's G6 §1
## contract fixes ALL presentation timing to the fixed-60Hz step heartbeat
## ("never wall-clock" — Particles, Floaters, CameraRig, CaptionBand are all
## step-driven) and headless test trees never advance frame-driven Tweens.
## The engine therefore evaluates identical curves (cubic-out, cubic-in-out,
## back-out) as pure step-counted math: deterministic, replay-stable, and
## testable without a render loop. No new dependency — GDScript math only.
##
## Counting rules (G9 §2, exact):
##  - one tween = one (target, property) animation = its segment chain;
##  - a round trip A→B→A = 2 sequential segments = 1 ACTIVE Tweener at any
##    time = 1 budget unit;
##  - flash pattern = instant set to peak + 1 segment back = 1 budget unit;
##  - parallel properties = separate tweens = 1 unit each;
##  - ambient ping-pong loop = 1 unit per instance until stopped.
## Caps (G9 §2 / §10, tunable): one-shot cap juice.tween.cap (48) active
## units, critical sub-cap juice.tween.critical_subcap (23), ambient cap
## juice.ambient.cap (16) on a separate budget. Enforcement order (OBL-55):
## per-type instance caps FIRST (snap-complete oldest of the overflowing type),
## then global priority cull (lowest priority non-critical first).

const PRIORITY_LOW: int = 0
const PRIORITY_NORMAL: int = 1
const PRIORITY_HIGH: int = 2
const PRIORITY_CRITICAL: int = 3

## G9 OQ-21: TRANS_BACK overshoot must be ≤8% on a 32px sprite (≤34.56px).
## Standard back-out (s=1.70158) overshoots ~10% — exceeds the contract.
## s=1.4 gives max overshoot 4·s³/(27·(s+1)²) ≈ 7.06% ≤ 8%, so the engine
## ships the sanctioned cubic-out-family back curve INSIDE the 8% ceiling.
## test_juice_engine samples the curve at 1ms granularity over a 400ms tween
## and asserts the 34.56px bound (the OQ-21 verification, exact).
const BACK_S: float = 1.4
const BACK_MAX_OVERSHOOT: float = 0.08

var oneshot_cap: int = 48
var critical_subcap: int = 23
var ambient_cap: int = 16

var _active: Array = []            # Array[Dictionary] live tweens
var _bindings: Dictionary = {}     # prop key -> Callable(value Variant)
var _history: Array = []           # last 64 accepted/rejected request records
var _time_ticks: int = 0

static func ms_to_ticks(ms: float) -> int:
	# why: fixed 60Hz — one tick = 1000/60 ms; floor 1 so no animation vanishes
	return maxi(1, int(round(ms * 60.0 / 1000.0)))

static func ease_value(easing: String, t: float) -> float:
	t = clampf(t, 0.0, 1.0)
	match easing:
		"linear":
			return t
		"cubic_out":
			return 1.0 - pow(1.0 - t, 3.0)
		"cubic_in_out":
			if t < 0.5:
				return 4.0 * t * t * t
			return 1.0 - pow(-2.0 * t + 2.0, 3.0) / 2.0
		"back_out":
			var u: float = t - 1.0
			return 1.0 + (BACK_S + 1.0) * u * u * u + BACK_S * u * u
		_:
			return t

func configure(tun: TunablesLoader) -> void:
	oneshot_cap = tun.get_int("juice.tween.cap", 48)
	critical_subcap = tun.get_int("juice.tween.critical_subcap", 23)
	ambient_cap = tun.get_int("juice.ambient.cap", 16)

func bind(prop: String, applier: Callable) -> void:
	_bindings[prop] = applier

func unbind(prop: String) -> void:
	_bindings.erase(prop)

func clear_bindings() -> void:
	_bindings.clear()

## spec: {ac, type, units, critical, priority, ambient, world, loop_pp,
##        cap, overflow, segments: [{prop|apply, kind, from, to, ticks,
##        easing, delay_ticks, set_instant}]}
## Returns true when the tween was accepted.
func request(spec: Dictionary) -> bool:
	var units: int = int(spec.get("units", 1))
	var ambient: bool = bool(spec.get("ambient", false))
	var ttype: String = str(spec.get("type", ""))
	var cap: int = int(spec.get("cap", 0))
	var overflow: String = str(spec.get("overflow", "snap_oldest"))
	# ---- per-type instance caps FIRST (OBL-55) ----
	if cap > 0 and ttype != "":
		var live: Array = tweens_of_type(ttype)
		while live.size() >= cap:
			match overflow:
				"reject":
					_record(spec, false, "type_cap_reject")
					return false
				"new_kills", "snap_oldest":
					# why: snap-complete the oldest instance of the overflowing
					# type; frees budget BEFORE the new instance starts, so
					# per-type overflow never causes global overflow (G9 §2)
					_snap_complete(live[0])
					live = tweens_of_type(ttype)
				_:
					_snap_complete(live[0])
					live = tweens_of_type(ttype)
	# ---- budget gates ----
	if ambient:
		if ambient_unit_count() + units > ambient_cap:
			_record(spec, false, "ambient_cap_reject")
			return false
	else:
		var critical: bool = bool(spec.get("critical", false))
		if critical and critical_unit_count() + units > critical_subcap:
			_record(spec, false, "critical_subcap_reject")
			return false
		if active_unit_count() + units > oneshot_cap:
			_global_priority_cull(units)
			if active_unit_count() + units > oneshot_cap:
				_record(spec, false, "global_cap_reject")
				return false
	var tween: Dictionary = {
		"ac": str(spec.get("ac", "")),
		"type": ttype,
		"units": units,
		"critical": bool(spec.get("critical", false)),
		"priority": int(spec.get("priority", PRIORITY_NORMAL)),
		"ambient": ambient,
		"world": bool(spec.get("world", false)),
		"loop_pp": bool(spec.get("loop_pp", false)),
		"segments": spec.get("segments", []),
		"seg": 0,
		"t": 0,
		"born": _time_ticks,
	}
	if not (tween.segments is Array) or (tween.segments as Array).is_empty():
		_record(spec, false, "no_segments")
		return false
	_apply_instant_sets(tween)
	_active.append(tween)
	_record(spec, true, "accepted")
	return true

func _apply_instant_sets(tween: Dictionary) -> void:
	# why: flash pattern — the first segment may be an instant property set to
	# peak (set_instant: true); 0 ticks, no budget of its own (G9 flash = 1 unit)
	var segs: Array = tween.segments
	while not segs.is_empty():
		var seg: Dictionary = segs[0]
		if not bool(seg.get("set_instant", false)):
			break
		_apply_value(tween, seg, seg.get("to", seg.get("from", 0.0)))
		segs.remove_at(0)
	if segs.is_empty():
		segs.append({"prop": "", "kind": "float", "from": 0.0, "to": 0.0, "ticks": 1, "easing": "linear", "delay_ticks": 0})

## Advance every live tween by ONE fixed 60Hz tick. hitstop_active freezes
## world-juice tweens while UI-juice tweens keep advancing (G9 OBL-31).
func step(hitstop_active: bool) -> void:
	_time_ticks += 1
	var i: int = _active.size() - 1
	while i >= 0:
		var tw: Dictionary = _active[i]
		if bool(tw.world) and hitstop_active and not bool(tw.ambient):
			# why: new world tweens created during hitstop start paused and
			# resume when hitstop ends (G9 §2 pause behavior)
			i -= 1
			continue
		if bool(tw.ambient) and hitstop_active:
			# why: ambient loops are world-juice; frozen during hitstop too
			i -= 1
			continue
		if _advance(tw):
			_active.remove_at(i)
		i -= 1

## Returns true when the tween completed this tick.
func _advance(tw: Dictionary) -> bool:
	var segs: Array = tw.segments
	if tw.seg >= segs.size():
		return true
	var seg: Dictionary = segs[tw.seg]
	var delay: int = int(seg.get("delay_ticks", 0))
	if tw.t < delay:
		tw.t += 1
		return false
	var ticks: int = maxi(1, int(seg.get("ticks", 1)))
	var local: int = tw.t - delay + 1
	tw.t += 1
	var x: float = clampf(float(local) / float(ticks), 0.0, 1.0)
	var v: Variant = _eval(seg, x)
	_apply_value(tw, seg, v)
	if local >= ticks:
		if bool(tw.loop_pp):
			# why: cubic-in-out ping-pong autoreverse = 1 budget unit (G9 §2).
			# loop_pp is single-segment by contract (vignette/pulse/idle loops);
			# multi-cycle sequences (AC-52) unroll as explicit segment chains.
			var tmp = seg.get("from", 0.0)
			seg["from"] = seg.get("to", 0.0)
			seg["to"] = tmp
			tw.seg = 0
			tw.t = 0
			return false
		tw.seg += 1
		tw.t = 0
		if tw.seg >= segs.size():
			return true
	return false

func _eval(seg: Dictionary, x: float) -> Variant:
	var eased: float = ease_value(str(seg.get("easing", "cubic_out")), x)
	var kind: String = str(seg.get("kind", "float"))
	if kind == "color":
		var c0: Color = seg.get("from", Color.WHITE)
		var c1: Color = seg.get("to", Color.WHITE)
		return c0.lerp(c1, eased)
	var f0: float = float(seg.get("from", 0.0))
	var f1: float = float(seg.get("to", 0.0))
	return f0 + (f1 - f0) * eased

func _apply_value(tw: Dictionary, seg: Dictionary, value: Variant) -> void:
	if seg.has("apply") and seg.apply is Callable:
		seg.apply.call(value)
		return
	var prop: String = str(seg.get("prop", ""))
	if prop != "" and _bindings.has(prop):
		(_bindings[prop] as Callable).call(value)

## Snap-complete: jump to the final resting value and free the budget now.
func _snap_complete(tw: Dictionary) -> void:
	var segs: Array = tw.segments
	if not segs.is_empty():
		var last: Dictionary = segs[segs.size() - 1]
		_apply_value(tw, last, last.get("to", last.get("from", 0.0)))
	var idx: int = _active.find(tw)
	if idx >= 0:
		_active.remove_at(idx)

func _global_priority_cull(needed_units: int) -> void:
	# why: kill LOWEST-priority Tweens until the request fits; never critical
	# (G9 enforcement order). Stable by (priority asc, born asc).
	var candidates: Array = []
	for tw in _active:
		if not bool(tw.critical) and not bool(tw.ambient):
			candidates.append(tw)
	candidates.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		if int(a.priority) != int(b.priority):
			return int(a.priority) < int(b.priority)
		return int(a.born) < int(b.born))
	for tw in candidates:
		if active_unit_count() + needed_units <= oneshot_cap:
			break
		_snap_complete(tw)

func stop_type(ttype: String, snap_to_end: bool = false) -> int:
	var count: int = 0
	var i: int = _active.size() - 1
	while i >= 0:
		var tw: Dictionary = _active[i]
		if str(tw.type) == ttype:
			if snap_to_end:
				var segs: Array = tw.segments
				if not segs.is_empty():
					var last: Dictionary = segs[segs.size() - 1]
					_apply_value(tw, last, last.get("to", last.get("from", 0.0)))
			_active.remove_at(i)
			count += 1
		i -= 1
	return count

func stop_ac(ac: String) -> int:
	var count: int = 0
	var i: int = _active.size() - 1
	while i >= 0:
		if str(_active[i].ac) == ac:
			_active.remove_at(i)
			count += 1
		i -= 1
	return count

func kill_all() -> void:
	_active.clear()

# ---- queries (tests + director) ----

func active_count() -> int:
	return _active.size()

func active_unit_count() -> int:
	var total: int = 0
	for tw in _active:
		if not bool(tw.ambient):
			total += int(tw.units)
	return total

func critical_unit_count() -> int:
	var total: int = 0
	for tw in _active:
		if bool(tw.critical) and not bool(tw.ambient):
			total += int(tw.units)
	return total

func ambient_unit_count() -> int:
	var total: int = 0
	for tw in _active:
		if bool(tw.ambient):
			total += int(tw.units)
	return total

func tweens_of_type(ttype: String) -> Array:
	var out: Array = []
	for tw in _active:
		if str(tw.type) == ttype:
			out.append(tw)
	return out

func has_type(ttype: String) -> bool:
	return not tweens_of_type(ttype).is_empty()

func live_summary() -> Array:
	var out: Array = []
	for tw in _active:
		out.append({"ac": tw.ac, "type": tw.type, "units": tw.units, "critical": tw.critical, "ambient": tw.ambient, "seg": tw.seg, "segments": tw.segments.size()})
	return out

func history() -> Array:
	return _history.duplicate()

func _record(spec: Dictionary, accepted: bool, reason: String) -> void:
	_history.append({"ac": str(spec.get("ac", "")), "type": str(spec.get("type", "")), "accepted": accepted, "reason": reason, "at": _time_ticks})
	if _history.size() > 64:
		_history.pop_front()
