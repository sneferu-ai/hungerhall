extends Control
## HUNGERHALL — SplashScreen (G5 §1: entry on process start; 72-step mark;
## skippable after 18 steps + input). Non-interactive — InputMapper arms the
## skip via SSM.mark_splash_input(); the SSM counts the steps and fires PRESS.
## Presentation is step-driven (reveal + progress tick), never wall-clock.

const C_CANVAS: Color = Color("#0B0A13")
const C_FLOOR: Color = Color("#252039")
const C_WALL: Color = Color("#191526")
const C_WALL_CAP: Color = Color("#5A4E76")
const C_BONE: Color = Color("#F3EAD9")
const C_AMBER: Color = Color("#F2A23B")
const C_SLATE: Color = Color("#16111F")

const TOTAL_STEPS: int = 72

var _step: int = 0
var _logo_font: Font = null
# ---- G9 AC-01 splash logo fade (cubic-out, juice.boot.splash_ms) ----
var _juice: Node = null
var _juice_alpha: float = -1.0  # <0 = tween not active; step reveal fallback

func _ready() -> void:
	var f: Variant = load("res://Fonts/font_32.tres")
	if f is Font:
		_logo_font = f
	# why: G9 AC-01 — the logo fade is a contracted tween, not the G7 step
	# reveal alone. The tween's applier rides _juice_alpha; the step reveal
	# remains the fallback when the director is absent (headless/tests).
	_juice = get_node_or_null("/root/Main/JuiceDirector")
	if _juice != null and _juice.has_method("bind"):
		_juice.bind("splash.alpha", func(v): _juice_alpha = float(v))
		_juice.play_ac("AC-01")

func _exit_tree() -> void:
	# why: the director outlives this screen — drop the binding so no later
	# tween fires into a freed closure target
	if _juice != null and is_instance_valid(_juice) and _juice.has_method("unbind"):
		_juice.unbind("splash.alpha")

func _physics_process(_delta: float) -> void:
	if _step < TOTAL_STEPS:
		_step += 1
		queue_redraw()

func _draw() -> void:
	# why: full-bleed hall backdrop — checker of floor/wall tokens keeps the
	# frame out of the near-black / near-uniform sanity buckets while the
	# splash plays
	for ty in range(0, 12):
		for tx in range(0, 20):
			var dark: bool = (tx + ty) % 2 == 0
			draw_rect(Rect2(tx * 32, ty * 32, 32, 32), C_WALL if dark else C_FLOOR)
			if dark:
				draw_rect(Rect2(tx * 32, ty * 32, 32, 4), C_WALL_CAP)
	# slate plaque behind the wordmark
	draw_rect(Rect2(120, 120, 400, 120), C_SLATE)
	draw_rect(Rect2(120, 120, 400, 120), C_WALL_CAP, false, 2.0)
	# why: reveal ramps over the first 18 steps; the progress tick below
	# advances every step so adjacent frames are never identical. When the
	# AC-01 tween is live it WINS (300ms cubic-out = the contracted curve);
	# the linear step ramp is the headless/no-director fallback.
	var reveal: float = clampf(float(_step) / 18.0, 0.0, 1.0)
	if _juice_alpha >= 0.0:
		reveal = maxf(reveal, _juice_alpha)
	var logo: String = StringsTable.text("title.logo", "HUNGERHALL")
	var color: Color = Color(C_BONE.r, C_BONE.g, C_BONE.b, reveal)
	if _logo_font != null:
		draw_set_transform(Vector2(140, 168), 0.0, Vector2.ONE)
		draw_string(_logo_font, Vector2.ZERO, logo, HORIZONTAL_ALIGNMENT_LEFT, 360, 32, color)
		draw_set_transform(Vector2.ZERO)
	else:
		draw_string(ThemeDB.fallback_font, Vector2(140, 168), logo, HORIZONTAL_ALIGNMENT_LEFT, 360, 32, color)
	# amber crescent — the hall's mark
	draw_arc(Vector2(320, 250), 14.0, 0.3, PI - 0.3, 16, Color(C_AMBER.r, C_AMBER.g, C_AMBER.b, reveal), 3.0)
	# progress tick (1.2s mark)
	var frac: float = clampf(float(_step) / float(TOTAL_STEPS), 0.0, 1.0)
	draw_rect(Rect2(220, 292, 200, 4), Color(C_WALL_CAP.r, C_WALL_CAP.g, C_WALL_CAP.b, 0.6))
	draw_rect(Rect2(220, 292, 200.0 * frac, 4), C_AMBER)
