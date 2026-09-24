extends Control
class_name CaptionBand
## HUNGERHALL — caption band (G6 §2 ui/caption_band.gd, G4 announcer type).
## Bottom readability bar (presentation_contract: y 0.88, h 0.1): 24px
## Silkscreen ALL-CAPS captions, bone on #000000CC backing. Text arrives from
## strings.json via StringsTable — callers pass KEYS, never raw copy. Hold is
## step-counted (fixed 60Hz), never wall-clock; minimum hold 120 steps (2s,
## G3 "captions hold two seconds minimum").

const FONT_PATH: String = "res://Fonts/font_24.tres"
const BACKING: Color = Color(0, 0, 0, 0.8)  # G4: white on #000000CC backing
const C_BONE: Color = Color("#F3EAD9")

var _label: Label = null
var _backing: ColorRect = null
var _hold_remaining: int = 0
var _caption_enabled: bool = true

func _ready() -> void:
	mouse_filter = MOUSE_FILTER_IGNORE
	_backing = ColorRect.new()
	_backing.name = "Backing"
	_backing.color = BACKING
	_backing.position = Vector2(0, 0)
	_backing.size = Vector2(640, 36)
	_backing.visible = false
	_backing.mouse_filter = MOUSE_FILTER_IGNORE
	add_child(_backing)
	_label = Label.new()
	_label.name = "CaptionText"
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_label.position = Vector2(0, 0)
	_label.size = Vector2(640, 36)
	_label.add_theme_color_override("font_color", C_BONE)
	var f: Font = load(FONT_PATH)
	if f != null:
		_label.add_theme_font_override("font", f)
	else:
		_label.add_theme_font_size_override("font_size", 24)
	_label.mouse_filter = MOUSE_FILTER_IGNORE
	add_child(_label)

func set_captions_enabled(enabled: bool) -> void:
	_caption_enabled = enabled
	if not enabled:
		_hide_now()

## Shows the string stored under strings key. hold_steps floors at 120 (2s).
func show_key(key: String, hold_steps: int = 120) -> void:
	if not _caption_enabled:
		return
	var text: String = StringsTable.text(key, "")
	if text == "":
		return
	_label.text = text
	_backing.visible = true
	_hold_remaining = maxi(hold_steps, 120)

func show_text(text: String, hold_steps: int = 120) -> void:
	# why: pre-resolved class-variant lines arrive already composed
	if not _caption_enabled or text == "":
		return
	_label.text = text
	_backing.visible = true
	_hold_remaining = maxi(hold_steps, 120)

## Call once per fixed 60Hz step — counts the caption down deterministically.
func tick() -> void:
	if _hold_remaining <= 0:
		return
	_hold_remaining -= 1
	if _hold_remaining <= 0:
		_hide_now()

func _hide_now() -> void:
	_hold_remaining = 0
	_backing.visible = false
	_label.text = ""
