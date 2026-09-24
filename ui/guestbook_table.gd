extends Control
class_name GuestbookTable
## HUNGERHALL — the Guestbook, Standard tab only (G6 §2 ui/guestbook_table.gd,
## G5 hall_of_heroes). Local top-10 score rows per class, read from the score
## store data passed in (ui/ never reaches into stores itself — the hall
## screen hands the table its dictionary).

const C_BONE: Color = Color("#F3EAD9")
const C_AMBER: Color = Color("#F2A23B")
const C_DIM: Color = Color("#5A4E76")

const CLASS_ORDER: Array = ["warrior", "valkyrie", "wizard", "elf"]
const CLASS_COLORS: Dictionary = {
	"warrior": Color("#C87040"), "valkyrie": Color("#5090B0"),
	"wizard": Color("#9060B0"), "elf": Color("#50B070"),
}

var _rows_root: VBoxContainer = null

func _ready() -> void:
	_rows_root = VBoxContainer.new()
	_rows_root.name = "Rows"
	_rows_root.position = Vector2(0, 0)
	_rows_root.size = Vector2(520, 260)
	_rows_root.add_theme_constant_override("separation", 2)
	add_child(_rows_root)

## scores: {"standard": {<class>: [{initials, score, floor}, ...]}}
func populate(scores: Dictionary) -> void:
	for child in _rows_root.get_children():
		child.queue_free()
	var standard: Dictionary = scores.get("standard", {})
	for class_key in CLASS_ORDER:
		_rows_root.add_child(_class_header(class_key))
		var entries: Array = standard.get(class_key, [])
		if entries.is_empty():
			_rows_root.add_child(_row("  -", "", "", Color("#5A4E76")))
			continue
		for i in range(mini(entries.size(), 10)):
			var e: Dictionary = entries[i]
			_rows_root.add_child(_row(
				"  %2d" % (i + 1),
				str(e.get("initials", "---")),
				"%d" % int(e.get("score", 0)),
				C_BONE if i > 0 else C_AMBER,
			))

func _class_header(class_key: String) -> Label:
	var l: Label = Label.new()
	l.text = class_key.to_upper()
	l.add_theme_font_size_override("font_size", 16)
	l.add_theme_color_override("font_color", CLASS_COLORS.get(class_key, C_BONE))
	return l

func _row(rank: String, initials: String, score: String, color: Color) -> HBoxContainer:
	var row: HBoxContainer = HBoxContainer.new()
	row.add_theme_constant_override("separation", 16)
	var r: Label = _cell(rank, 48, C_DIM)
	var n: Label = _cell(initials, 96, color)
	var s: Label = _cell(score, 140, color)
	s.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	row.add_child(r)
	row.add_child(n)
	row.add_child(s)
	return row

func _cell(text: String, width: float, color: Color) -> Label:
	var l: Label = Label.new()
	l.text = text
	l.custom_minimum_size = Vector2(width, 20)
	l.add_theme_font_size_override("font_size", 16)
	l.add_theme_color_override("font_color", color)
	return l
