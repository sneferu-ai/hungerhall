extends Control
class_name InitialsEntry
## HUNGERHALL — arcade initials entry (G6 §2 ui/initials_entry.gd).
## Three A-Z slots; ui_left/ui_right cycle the active letter, ui_accept (or
## sneferu primary via the screen) advances; committing the third slot fires
## committed. Esc/B skips (initials show "---", G3 DIS-3). Keyboard letter
## presses jump the active slot to that letter and advance — the arcade way.

signal initials_committed(initials: String)
signal initials_skipped

const C_BONE: Color = Color("#F3EAD9")
const C_AMBER: Color = Color("#F2A23B")
const C_SLATE: Color = Color("#16111F")
const ALPHABET: String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

var active: bool = false
var slot_index: int = 0
var letters: PackedStringArray = PackedStringArray(["A", "A", "A"])

var _slots: Array = []
var _prompt: Label = null
var _skipped: bool = false

func _ready() -> void:
	_prompt = Label.new()
	_prompt.name = "InitialsPrompt"
	_prompt.text = StringsTable.text("initials.prompt", "Sign the guestbook.")
	_prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_prompt.position = Vector2(-110, -34)
	_prompt.size = Vector2(340, 24)
	_prompt.add_theme_font_size_override("font_size", 16)
	_prompt.mouse_filter = MOUSE_FILTER_IGNORE
	add_child(_prompt)
	for i in range(3):
		var slot: Label = Label.new()
		slot.name = "Slot%d" % i
		slot.text = "A"
		slot.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		slot.position = Vector2(i * 44 - 44, 0)
		slot.size = Vector2(36, 44)
		slot.add_theme_font_size_override("font_size", 32)
		slot.mouse_filter = MOUSE_FILTER_IGNORE
		add_child(slot)
		_slots.append(slot)
	_refresh()

func begin() -> void:
	active = true
	slot_index = 0
	_skipped = false
	letters = PackedStringArray(["A", "A", "A"])
	_refresh()

## Screens route their Back rule here; returns true while the entry consumed
## the back press (skip), false once inactive.
func back_pressed() -> bool:
	if not active:
		return false
	active = false
	_skipped = true
	initials_skipped.emit()
	return true

func advance_letter(delta: int) -> void:
	if not active:
		return
	var idx: int = ALPHABET.find(letters[slot_index])
	idx = posmod(idx + delta, ALPHABET.length())
	letters[slot_index] = ALPHABET[idx]
	_refresh()

func confirm_slot() -> void:
	if not active:
		return
	slot_index += 1
	if slot_index >= 3:
		active = false
		initials_committed.emit(initials())
	_refresh()

func jump_to_letter(c: String) -> void:
	if not active:
		return
	var up: String = c.to_upper()
	if ALPHABET.find(up) < 0:
		return
	letters[slot_index] = up
	confirm_slot()

func initials() -> String:
	if _skipped:
		return "---"
	return letters[0] + letters[1] + letters[2]

func _refresh() -> void:
	for i in range(3):
		var slot: Label = _slots[i]
		slot.text = letters[i] if not _skipped else "-"
		if active and i == slot_index:
			slot.add_theme_color_override("font_color", C_AMBER)
		else:
			slot.add_theme_color_override("font_color", C_BONE)

func _unhandled_key_input(event: InputEvent) -> void:
	# why: direct letter typing — only while the entry is live
	if not active or not (event is InputEventKey) or not event.pressed or event.echo:
		return
	var kc: int = event.physical_keycode
	if kc >= KEY_A and kc <= KEY_Z:
		jump_to_letter(char(kc))
		get_viewport().set_input_as_handled()
