extends Control
class_name IdlePrompts
## HUNGERHALL — idle tutorial overlays (G3 tutorial ledger: MOVE at T+4 idle,
## THROW at T+10 idle; overlaid on the floor-1 play screen, not a separate
## screen). Step-driven from the session tick — never wall-clock. Speedrun
## rule (G3): if the prompted action already happened before the prompt fires,
## the prompt is silently skipped; no queued prompt survives its condition.

const MOVE_IDLE_TICKS: int = 240   # why: T+4s at fixed 60Hz
const THROW_IDLE_TICKS: int = 600  # why: T+10s at fixed 60Hz
const HOLD_TICKS: int = 120        # why: 2s hold matches caption minimum

var _move_shown: bool = false
var _throw_shown: bool = false
var _has_moved: bool = false
var _has_thrown: bool = false
var _hold_remaining: int = 0
var _current: TextureRect = null
var _current_word: Label = null

func _ready() -> void:
	mouse_filter = MOUSE_FILTER_IGNORE
	visible = false

## PlayScreen reports semantic actions here each fixed step.
func report_action(moved: bool, thrown: bool) -> void:
	if moved:
		_has_moved = true
	if thrown:
		_has_thrown = true

## Call once per fixed 60Hz step with the session tick and whether input is
## currently idle (zero movement vector this tick).
func tick(session_tick: int, idle_this_tick: bool) -> void:
	if _hold_remaining > 0:
		_hold_remaining -= 1
		if _hold_remaining <= 0:
			visible = false
		return
	if not idle_this_tick:
		return
	if session_tick == MOVE_IDLE_TICKS and not _move_shown and not _has_moved:
		_move_shown = true
		_show("tutorial.move", InputGlyphs.arrow(Vector2(0, -1)))
	elif session_tick == THROW_IDLE_TICKS and not _throw_shown and not _has_thrown:
		_throw_shown = true
		_show("tutorial.throw", InputGlyphs.face_button("circle"))

func _show(key: String, glyph: Texture2D) -> void:
	for child in get_children():
		child.queue_free()
	_current = TextureRect.new()
	_current.name = "PromptGlyph"
	_current.texture = glyph
	_current.position = Vector2(-40, -12)
	_current.size = Vector2(24, 24)
	_current.mouse_filter = MOUSE_FILTER_IGNORE
	add_child(_current)
	_current_word = Label.new()
	_current_word.name = "PromptWord"
	_current_word.text = StringsTable.text(key, "")
	_current_word.position = Vector2(-12, -14)
	_current_word.size = Vector2(120, 28)
	_current_word.add_theme_font_size_override("font_size", 16)
	_current_word.mouse_filter = MOUSE_FILTER_IGNORE
	add_child(_current_word)
	visible = true
	_hold_remaining = HOLD_TICKS
