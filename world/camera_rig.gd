extends Camera2D
class_name CameraRig
## HUNGERHALL — dead-zone follow camera (G6 §2 world/camera_rig.gd,
## presentation_contract camera: dead zone 48×32, lead 16px, trauma kick 2px).
## Steps once per fixed tick through set_target() — no wall-clock, no
## position smoothing (hand-stepped so pause/resume never jumps).

const DEAD_X: float = 48.0
const DEAD_Y: float = 32.0
const LEAD_PX: float = 16.0
const KICK_PX: float = 2.0
const FOLLOW_FRACTION: float = 0.2  # why: per-tick catch-up; ~5 ticks to close

var _target: Vector2 = Vector2(320, 224)
var _facing: Vector2 = Vector2(0, 1)
var _trauma: float = 0.0
var _step: int = 0
var _world_w: float = 640.0
var _world_h: float = 448.0

# ---- G9 §4 juice camera channels (step-driven, deterministic) ----
# why: G9 shake policy — EXACTLY three shake events (generator/death/clear);
# the JuiceDirector converts tunable magnitude_px + ms into a kick here.
var _shake_ticks_left: int = 0
var _shake_ticks_total: int = 0
var _shake_mag: float = 0.0
var _shake_falloff: String = "linear"
# why: G9 camera zoom punch — 1.0 → peak → 1.0 over 2 × half_ticks
var _zoom_half_ticks: int = 0
var _zoom_ticks_left: int = 0
var _zoom_peak: float = 1.0
# why: G9 SIG-5 camera drift — target drifts toward the exit, then back
var _drift_origin: Vector2 = Vector2.ZERO
var _drift_target: Vector2 = Vector2.ZERO
var _drift_ticks: int = 0
var _drift_return_ticks: int = 0
var _drift_phase: int = 0  # 0 idle, 1 out, 2 back
var _drift_t: int = 0

func _ready() -> void:
	make_current()
	position_smoothing_enabled = false
	# why: the floor is exactly viewport-width; vertical scroll is the only axis
	limit_left = 0
	limit_top = 0
	limit_right = 640
	limit_bottom = 448

func set_world_size(w: float, h: float) -> void:
	_world_w = w
	_world_h = h
	limit_right = int(w)
	limit_bottom = int(h)

func set_target(pos: Vector2, facing: Vector2, step_counter: int) -> void:
	_step = step_counter
	_target = pos
	if facing != Vector2.ZERO:
		_facing = facing.normalized()
	_apply()

func add_trauma(amount: float) -> void:
	_trauma = clampf(_trauma + amount, 0.0, 1.0)

## G9 §4 shake — magnitude in px, duration in fixed ticks, falloff
## "linear"|"cubic_out". A new kick supersedes (never stacks beyond the
## strongest active magnitude — G9 shake is rare by design).
func shake_kick(mag_px: float, ticks: int, falloff: String) -> void:
	if ticks <= 0 or mag_px <= 0.0:
		return
	if mag_px >= _shake_mag or _shake_ticks_left <= 0:
		_shake_mag = mag_px
		_shake_ticks_total = maxi(1, ticks)
		_shake_ticks_left = _shake_ticks_total
		_shake_falloff = falloff

## G9 camera zoom punch — zoom 1.0 → peak → 1.0, half_ticks per leg.
func zoom_punch(peak: float, half_ticks: int) -> void:
	if half_ticks <= 0 or peak <= 1.0:
		return
	_zoom_peak = peak
	_zoom_half_ticks = maxi(1, half_ticks)
	_zoom_ticks_left = _zoom_half_ticks * 2

## G9 SIG-5 — camera drifts toward the exit over drift_ticks, holds none,
## returns over return_ticks (G9 phases 6-7 of AC-SIG5).
func drift_to_and_back(target: Vector2, drift_ticks: int, return_ticks: int) -> void:
	if drift_ticks <= 0:
		return
	_drift_origin = _target
	_drift_target = target
	_drift_ticks = maxi(1, drift_ticks)
	_drift_return_ticks = maxi(1, return_ticks)
	_drift_phase = 1
	_drift_t = 0

func _apply() -> void:
	# ---- G9 SIG-5 drift channel — the follow target rides the drift legs ----
	var follow_target: Vector2 = _target
	if _drift_phase == 1:
		_drift_t += 1
		var xd: float = clampf(float(_drift_t) / float(_drift_ticks), 0.0, 1.0)
		follow_target = _drift_origin.lerp(_drift_target, 1.0 - pow(1.0 - xd, 3.0))
		if _drift_t >= _drift_ticks:
			_drift_phase = 2
			_drift_t = 0
	elif _drift_phase == 2:
		_drift_t += 1
		var xr: float = clampf(float(_drift_t) / float(_drift_return_ticks), 0.0, 1.0)
		follow_target = _drift_target.lerp(_drift_origin, 1.0 - pow(1.0 - xr, 3.0))
		if _drift_t >= _drift_return_ticks:
			_drift_phase = 0
	var desired: Vector2 = follow_target + _facing * LEAD_PX
	var delta: Vector2 = desired - position
	# why: dead zone — no movement while the drift sits inside 48×32
	if absf(delta.x) > DEAD_X:
		position.x += (delta.x - signf(delta.x) * DEAD_X) * FOLLOW_FRACTION
	if absf(delta.y) > DEAD_Y:
		position.y += (delta.y - signf(delta.y) * DEAD_Y) * FOLLOW_FRACTION
	# why: offset = G7 trauma kick + G9 §4 shake channel (deterministic wobble
	# from the step counter — replay-safe, never wall-clock)
	var off: Vector2 = Vector2.ZERO
	if _trauma > 0.0:
		var shake: float = _trauma * _trauma * KICK_PX
		off += Vector2(sin(_step * 1.7) * shake, cos(_step * 2.3) * shake)
		_trauma = maxf(0.0, _trauma - 0.05)
	if _shake_ticks_left > 0:
		var prog: float = 1.0 - float(_shake_ticks_left) / float(maxi(1, _shake_ticks_total))
		var atten: float = (1.0 - prog) if _shake_falloff == "linear" else pow(1.0 - prog, 3.0)
		off += Vector2(sin(_step * 2.9), cos(_step * 3.7)) * _shake_mag * atten
		_shake_ticks_left -= 1
	offset = off
	# why: G9 zoom punch — 1.0 → peak → 1.0, cubic-out per leg, step-counted
	if _zoom_ticks_left > 0:
		_zoom_ticks_left -= 1
		var elapsed: int = _zoom_half_ticks * 2 - _zoom_ticks_left
		var z: float = 1.0
		if elapsed <= _zoom_half_ticks:
			var x1: float = clampf(float(elapsed) / float(_zoom_half_ticks), 0.0, 1.0)
			z = 1.0 + (_zoom_peak - 1.0) * (1.0 - pow(1.0 - x1, 3.0))
		else:
			var x2: float = clampf(float(elapsed - _zoom_half_ticks) / float(_zoom_half_ticks), 0.0, 1.0)
			z = _zoom_peak - (_zoom_peak - 1.0) * (1.0 - pow(1.0 - x2, 3.0))
		zoom = Vector2(z, z)
	else:
		zoom = Vector2.ONE
	# why: keep the frame inside the floor (640×448 vs 640×360 viewport)
	position.x = clampf(position.x, 320.0, maxf(320.0, _world_w - 320.0))
	position.y = clampf(position.y, 180.0, maxf(180.0, _world_h - 180.0))
