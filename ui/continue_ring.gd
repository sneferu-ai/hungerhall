extends Control
class_name ContinueRing
## HUNGERHALL — circular continue-timer arc (G6 §2 ui/continue_ring.gd).
## The 600-step (10s) ring drains clockwise; amber while time remains, brick
## inside the final second. Set from the SSM step counters each fixed tick —
## no wall-clock. "Continue? xN" rides above the ring (continue.ring G3 key).

const C_AMBER: Color = Color("#F2A23B")     # palette.service_amber
const C_BRICK: Color = Color("#D94836")     # palette.critical_brick
const C_SLATE: Color = Color("#16111F")     # palette.ui_slate
const C_BONE: Color = Color("#F3EAD9")      # palette.text_bone

var _total_steps: int = 600
var _remaining_steps: int = 600
var _tokens: int = 2
var _zero_token_mode: bool = false

var _ring: Control = null
var _label: Label = null
var _token_label: Label = null

func _ready() -> void:
	mouse_filter = MOUSE_FILTER_IGNORE
	custom_minimum_size = Vector2(120, 120)
	_ring = RingDraw.new()
	_ring.name = "RingDraw"
	_ring.position = Vector2.ZERO
	_ring.size = Vector2(120, 120)
	_ring.mouse_filter = MOUSE_FILTER_IGNORE
	add_child(_ring)
	_label = Label.new()
	_label.name = "RingHeader"
	_label.text = StringsTable.text("continue.ring", "Continue? x[N]")
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.position = Vector2(-60, -40)
	_label.size = Vector2(240, 28)
	_label.add_theme_font_size_override("font_size", 24)
	_label.mouse_filter = MOUSE_FILTER_IGNORE
	add_child(_label)
	_token_label = Label.new()
	_token_label.name = "RingCount"
	_token_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_token_label.position = Vector2(10, 40)
	_token_label.size = Vector2(100, 40)
	_token_label.add_theme_font_size_override("font_size", 32)
	_token_label.add_theme_color_override("font_color", C_BONE)
	_token_label.mouse_filter = MOUSE_FILTER_IGNORE
	add_child(_token_label)

func configure(total_steps: int, tokens: int) -> void:
	_total_steps = maxi(total_steps, 1)
	_remaining_steps = _total_steps
	_tokens = tokens
	_token_label.text = str(_tokens)

func set_zero_token_mode(hold_steps: int) -> void:
	# why: G2 §2 — at zero tokens the ring shows NO CONTINUES for 2s (120
	# steps) instead of a dead 10-second wait
	_zero_token_mode = true
	_total_steps = maxi(hold_steps, 1)
	_remaining_steps = _total_steps
	_label.text = StringsTable.text("continue.zero_ui", "No continues")
	_token_label.text = "0"

## Call once per fixed 60Hz step.
func tick() -> void:
	if _remaining_steps > 0:
		_remaining_steps -= 1
	var frac: float = float(_remaining_steps) / float(_total_steps)
	_ring.set_progress(frac, _remaining_steps <= 60 or _zero_token_mode)

class RingDraw:
	extends Control
	var _progress: float = 1.0
	var _urgent: bool = false
	func set_progress(p: float, urgent: bool) -> void:
		_progress = clampf(p, 0.0, 1.0)
		_urgent = urgent
		queue_redraw()
	func _draw() -> void:
		var c: Vector2 = Vector2(60, 60)
		draw_arc(c, 46.0, 0.0, TAU, 48, C_SLATE, 8.0)
		if _progress <= 0.0:
			return
		var col: Color = C_BRICK if _urgent else C_AMBER
		# why: drain clockwise from 12 o'clock
		draw_arc(c, 46.0, -PI / 2.0, -PI / 2.0 + TAU * _progress, 48, col, 8.0)
