extends Control
## HUNGERHALL — CampaignResultsScreen (G5 §1: entered after clearing floor 24;
## closing lines, class laurel (cosmetic), FINAL TOTAL; initials entry ALWAYS
## fires here; RETURN TO TITLE CTA. NG+ is OUT (DIS-8) — the ng_plus profile
## flag is only ever written false by the SSM).

const Verb = StateEnums.Verb
const C_BONE: Color = Color("#F3EAD9")
const C_AMBER: Color = Color("#F2A23B")
const CLASS_COLORS: Dictionary = {
	0: Color("#C87040"), 1: Color("#5090B0"), 2: Color("#9060B0"), 3: Color("#50B070"),
}

var _ssm: Node = null
var _initials: InitialsEntry = null
var _title_btn: Button = null
var _committed: bool = false

func _ready() -> void:
	_ssm = get_node_or_null("/root/SessionStateMachine")
	var class_idx: int = int(_ssm.class_index) if _ssm != null else 0
	var class_key: String = _ssm.class_key(class_idx) if _ssm != null and _ssm.has_method("class_key") else "warrior"
	var laurel_color: Color = CLASS_COLORS.get(class_idx, C_AMBER)
	_draw_laurel(laurel_color)
	var line1: Label = _label("ClosingLine1", StringsTable.text("win.campaign.1.fixed", ""), 24, Vector2(170, 60), C_AMBER)
	add_child(line1)
	var line2: Label = _label("ClosingLine2", StringsTable.text_for_class("win.campaign.2.fixed", class_key, ""), 24, Vector2(170, 96), C_BONE)
	add_child(line2)
	var total: int = _ssm.banked_score() if _ssm != null else 0
	var total_line: Label = _label("FinalTotal", "%s %d" % [StringsTable.text("label.final_score", "Final Score"), total], 24, Vector2(170, 132), C_BONE)
	add_child(total_line)

	_initials = InitialsEntry.new()
	_initials.name = "InitialsEntry"
	_initials.position = Vector2(260, 180)
	_initials.initials_committed.connect(_on_initials_done)
	_initials.initials_skipped.connect(_on_initials_done)
	add_child(_initials)
	_initials.begin()  # why: G5 — initials ALWAYS fire after a campaign clear

	_title_btn = Button.new()
	_title_btn.name = "ReturnTitleButton"
	_title_btn.text = StringsTable.text("button.return_title", "Return to Title")
	_title_btn.position = Vector2(220, 280)
	_title_btn.size = Vector2(200, 44)
	_title_btn.focus_mode = Control.FOCUS_ALL
	_title_btn.pressed.connect(_on_title)
	add_child(_title_btn)

func _draw_laurel(color: Color) -> void:
	# why: cosmetic class laurel — one arc + leaf dots, an inner Node2D drawer
	var laurel: LaurelDraw = LaurelDraw.new()
	laurel.name = "Laurel"
	laurel.position = Vector2(270, 8)
	laurel.laurel_color = color
	add_child(laurel)

func _label(node_name: String, text: String, size: int, pos: Vector2, color: Color) -> Label:
	var l: Label = Label.new()
	l.name = node_name
	l.text = text
	l.position = pos
	l.size = Vector2(300, 34)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	return l

func _on_initials_done(_arg: Variant = null) -> void:
	if _committed:
		return
	_committed = true
	var text: String = _initials.initials()
	if _ssm != null and text != "---":
		var class_key: String = _ssm.class_key(int(_ssm.class_index)) if _ssm.has_method("class_key") else "warrior"
		_ssm.score_store.add_score(text, class_key, _ssm.banked_score(), 24)
	_title_btn.grab_focus()

## G6 §1 row 12: CampaignResults → confirm (focused item).
func primary_confirm() -> void:
	if _initials.active:
		_initials.confirm_slot()
		return
	var focused: Control = get_viewport().gui_get_focus_owner()
	if focused != null and focused is Button and is_ancestor_of(focused):
		(focused as Button).pressed.emit()
		return
	_on_title()

## G5 §1: campaign_results.Back = initials skip; then ScoresChosen → hall.
func back_pressed() -> void:
	if _initials.active:
		_initials.back_pressed()
		return
	var ssm: Node = _ssm
	if ssm != null:
		ssm.try_transition(Verb.BACK)

func _on_title() -> void:
	var ssm: Node = _ssm
	if ssm != null:
		ssm.try_transition(Verb.ENTER)

class LaurelDraw:
	extends Node2D
	var laurel_color: Color = Color("#F2A23B")
	func _ready() -> void:
		queue_redraw()
	func _draw() -> void:
		draw_arc(Vector2(50, 24), 20.0, PI * 0.6, PI * 1.4, 16, laurel_color, 3.0)
		for i in range(5):
			var ang: float = PI * 0.65 + float(i) * PI * 0.15
			draw_circle(Vector2(50, 24) + Vector2(cos(ang), sin(ang)) * 20.0, 3.0, laurel_color)
