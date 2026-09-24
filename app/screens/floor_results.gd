extends Control
## HUNGERHALL — FloorResultsScreen (G5 §1: entered after every cleared floor;
## the campaign save was already written by the SSM on entry — the Persistence
## Declaration's ONE place. Shows floor time/kills/food/running total + SAVED
## tag; NEXT FLOOR CTA ≥30px; Back = SaveQuit, no warn).

const Verb = StateEnums.Verb
const C_BONE: Color = Color("#F3EAD9")
const C_AMBER: Color = Color("#F2A23B")
const C_DIM: Color = Color("#5A4E76")
const C_FOOD: Color = Color("#EFC258")

# ---- G9 juice seams (AC-59 panel slide-in, AC-60 score count-up) ----
var _juice: Node = null
var _panel: PanelContainer = null
var _score_value: Label = null
var _final_score: int = 0

func _ready() -> void:
	var ssm: Node = get_node_or_null("/root/SessionStateMachine")
	var session: RulesSession = ssm.session if ssm != null else null
	var floor_number: int = session.floor_number if session != null else 1
	var ticks: int = session.tick - ssm.floor_start_tick() if session != null and ssm != null else 0
	var seconds: float = float(ticks) / 60.0
	var snap: Dictionary = session.snapshot() if session != null else {}

	var header: Label = _label("ResultsHeader", "FLOOR %d" % floor_number, 24, Vector2(220, 24), C_AMBER)
	add_child(header)
	var panel: PanelContainer = PanelContainer.new()
	panel.name = "ResultsPanel"
	panel.position = Vector2(180, 64)
	panel.size = Vector2(280, 170)
	add_child(panel)
	_panel = panel
	var col: VBoxContainer = VBoxContainer.new()
	col.add_theme_constant_override("separation", 6)
	panel.add_child(col)
	_row(col, StringsTable.text("label.time", "Time"), "%.1fs" % seconds, C_BONE)
	_row(col, StringsTable.text("label.kills", "Kills"), str(int(snap.get("kills_this_floor", 0))), C_BONE)
	_row(col, StringsTable.text("label.food", "Food"), str(int(snap.get("food_eaten", 0))), C_FOOD)
	_final_score = int(snap.get("score", {}).get("score", 0))
	_score_value = _row(col, StringsTable.text("label.score", "Score"), str(_final_score), C_BONE)
	var saved: Label = Label.new()
	saved.name = "SavedTag"
	saved.text = StringsTable.text("tag.saved", "SAVED") if ssm != null and ssm.last_autosave_ok else ""
	saved.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	saved.add_theme_font_size_override("font_size", 12)
	saved.add_theme_color_override("font_color", C_DIM)
	col.add_child(saved)

	var next_btn: Button = Button.new()
	next_btn.name = "NextFloorButton"
	next_btn.text = StringsTable.text("button.next_floor", "Next Floor")
	next_btn.position = Vector2(220, 260)
	next_btn.size = Vector2(200, 48)  # why: G5 — NEXT FLOOR CTA at 30px minimum
	next_btn.add_theme_font_size_override("font_size", 24)
	next_btn.focus_mode = Control.FOCUS_ALL
	next_btn.pressed.connect(advance_pressed)
	add_child(next_btn)
	var quit_btn: Button = Button.new()
	quit_btn.name = "SaveQuitButton"
	quit_btn.text = StringsTable.text("button.save_quit", "Save and Quit")
	quit_btn.position = Vector2(240, 318)
	quit_btn.size = Vector2(160, 30)
	quit_btn.focus_mode = Control.FOCUS_ALL
	quit_btn.pressed.connect(_on_save_quit)
	add_child(quit_btn)
	next_btn.grab_focus()
	_bind_juice()

## G9 juice wiring — AC-59 (panel slide-in: y +24 → 0, alpha 0 → 1, 250ms
## cubic-out, juice.results.panel_ms) + AC-60 (score count-up 0 → final,
## 350ms cubic-out, juice.results.countup_ms). Round-5 fix: both rows were
## zero-trigger (ledger 064cf689a9e3). Headless/no-director = the screen
## renders at rest — no juice, no breakage (class_select pattern).
func _bind_juice() -> void:
	_juice = get_node_or_null("/root/Main/JuiceDirector")
	if _juice == null or not _juice.has_method("bind") or _panel == null:
		return
	var base_y: float = _panel.position.y
	_panel.position.y = base_y + 24.0
	_panel.modulate.a = 0.0
	_juice.bind("results.y", func(v): _panel.position.y = base_y + float(v))
	_juice.bind("results.alpha", func(v): _panel.modulate.a = float(v))
	if _score_value != null:
		var target: int = _final_score
		_score_value.text = "0"
		_juice.bind("results.countup", func(v): _score_value.text = str(int(round(float(v) * float(target)))))
	_juice.play_ac("AC-59")
	_juice.play_ac("AC-60")

func _exit_tree() -> void:
	# why: director outlives this screen — never leave freed closure targets bound
	if _juice != null and is_instance_valid(_juice) and _juice.has_method("unbind"):
		_juice.unbind("results.y")
		_juice.unbind("results.alpha")
		_juice.unbind("results.countup")

func _label(node_name: String, text: String, size: int, pos: Vector2, color: Color) -> Label:
	var l: Label = Label.new()
	l.name = node_name
	l.text = text
	l.position = pos
	l.size = Vector2(200, 34)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	return l

func _row(parent: Control, left: String, right: String, color: Color) -> Label:
	var row: HBoxContainer = HBoxContainer.new()
	row.add_theme_constant_override("separation", 24)
	var l: Label = Label.new()
	l.text = left
	l.custom_minimum_size = Vector2(120, 24)
	l.add_theme_font_size_override("font_size", 16)
	row.add_child(l)
	var r: Label = Label.new()
	r.text = right
	r.custom_minimum_size = Vector2(100, 24)
	r.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	r.add_theme_font_size_override("font_size", 16)
	r.add_theme_color_override("font_color", color)
	row.add_child(r)
	parent.add_child(row)
	return r  # AC-60 count-up binds this label

## G6 §1 row 11: primary action here is "advance".
func advance_pressed() -> void:
	var ssm: Node = get_node_or_null("/root/SessionStateMachine")
	if ssm != null:
		ssm.try_transition(Verb.ADVANCE)

## G5 §1: floor_results.Back = SaveQuit, no warn.
func back_pressed() -> void:
	_on_save_quit()

func _on_save_quit() -> void:
	var ssm: Node = get_node_or_null("/root/SessionStateMachine")
	if ssm != null:
		ssm.try_transition(Verb.SAVE_QUIT)
