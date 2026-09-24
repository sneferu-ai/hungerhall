extends Control
## HUNGERHALL — GameOverScreen (G5 §1: initials entry auto-fires only if the
## score qualifies for the Standard table; Back skips; after commit focus
## moves to RETRY FLOOR N; RETRY/RECLAIM both → play via the RETRY verb;
## Scores → hall; Return to Title via ENTER). LAR-3: RETRY FLOOR N.

const Verb = StateEnums.Verb
const SceneId = StateEnums.SceneId
const C_BONE: Color = Color("#F3EAD9")
const C_AMBER: Color = Color("#F2A23B")
const C_DIM: Color = Color("#5A4E76")

var _ssm: Node = null
var _initials: InitialsEntry = null
var _retry_btn: Button = null
var _title_btn: Button = null
var _scores_btn: Button = null
var _final_score: int = 0
var _committed: bool = false
var _qualifies: bool = false
var _juice: Node = null  # G9 AC-62 entry seam

func _ready() -> void:
	_ssm = get_node_or_null("/root/SessionStateMachine")
	_final_score = _ssm.banked_score() if _ssm != null else 0
	var header: Label = _label("GameOverHeader", StringsTable.text("lose.header", "Game Over"), 24, Vector2(220, 20), C_AMBER)
	add_child(header)
	# why: G3 fixed game-over line, then the numbers
	var bark: Label = _label("GameOverBark", StringsTable.text("lose.game_over.fixed", ""), 16, Vector2(170, 56), C_BONE)
	add_child(bark)
	var score_line: Label = _label("FinalScoreLine",
		"%s %d" % [StringsTable.text("label.final_score", "Final Score"), _final_score],
		24, Vector2(200, 96), C_BONE)
	add_child(score_line)
	var floor_reached: int = _ssm.session.floor_number if _ssm != null and _ssm.session != null else 1
	var save_line: Label = _label("CampaignSaveLine",
		"%s %d" % [StringsTable.text("label.campaign_save", "Campaign Save: Floor"), floor_reached],
		12, Vector2(200, 130), C_DIM)
	add_child(save_line)

	_initials = InitialsEntry.new()
	_initials.name = "InitialsEntry"
	_initials.position = Vector2(260, 160)
	_initials.initials_committed.connect(_on_initials_done)
	_initials.initials_skipped.connect(_on_initials_done)
	add_child(_initials)

	_qualifies = _score_qualifies(_final_score)
	if _qualifies:
		_initials.begin()

	var buttons: HBoxContainer = HBoxContainer.new()
	buttons.name = "ButtonRow"
	buttons.position = Vector2(120, 250)
	buttons.add_theme_constant_override("separation", 12)
	add_child(buttons)
	_retry_btn = _btn("RetryButton", "%s %d" % [StringsTable.text("button.retry_floor", "Retry Floor"), floor_reached], _on_retry)
	buttons.add_child(_retry_btn)
	_scores_btn = _btn("ScoresButton", StringsTable.text("button.scores", "Scores"), _on_scores)
	buttons.add_child(_scores_btn)
	_title_btn = _btn("TitleButton", StringsTable.text("button.return_title", "Return to Title"), _on_title)
	buttons.add_child(_title_btn)
	if not _qualifies:
		_retry_btn.grab_focus()
	_bind_juice()

## G9 juice wiring — AC-62 (game-over entry: alpha 0 → 1, scale 0.8 → 1.0,
## 500ms cubic-out, juice.gameover.entry_ms). Round-5 fix: row was zero-trigger
## (ledger 064cf689a9e3). No director (headless/tests) = screen renders at rest.
func _bind_juice() -> void:
	_juice = get_node_or_null("/root/Main/JuiceDirector")
	if _juice == null or not _juice.has_method("bind"):
		return
	pivot_offset = size / 2.0
	modulate.a = 0.0
	scale = Vector2(0.8, 0.8)
	_juice.bind("gameover.alpha", func(v): modulate.a = float(v))
	_juice.bind("gameover.scale", func(v): scale = Vector2(float(v), float(v)))
	_juice.play_ac("AC-62")

func _exit_tree() -> void:
	# why: director outlives this screen — never leave freed closure targets bound
	if _juice != null and is_instance_valid(_juice) and _juice.has_method("unbind"):
		_juice.unbind("gameover.alpha")
		_juice.unbind("gameover.scale")

func _score_qualifies(score: int) -> bool:
	if _ssm == null or score <= 0:
		return false
	var class_key: String = _ssm.class_key(int(_ssm.class_index)) if _ssm.has_method("class_key") else "warrior"
	var standard: Dictionary = _ssm.score_store.read_scores().get("standard", {})
	var entries: Array = standard.get(class_key, [])
	if entries.size() < 10:
		return true
	return score > int(entries.back().get("score", 0))

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

func _btn(node_name: String, text: String, handler: Callable) -> Button:
	var b: Button = Button.new()
	b.name = node_name
	b.text = text
	b.custom_minimum_size = Vector2(140, 40)
	b.focus_mode = Control.FOCUS_ALL
	b.pressed.connect(handler)
	return b

func _on_initials_done(_initials_text: Variant = null) -> void:
	if _committed:
		return
	_committed = true
	var text: String = _initials.initials()
	if _qualifies and text != "---" and _ssm != null:
		var class_key: String = _ssm.class_key(int(_ssm.class_index)) if _ssm.has_method("class_key") else "warrior"
		var floor_reached: int = _ssm.session.floor_number if _ssm.session != null else 1
		_ssm.score_store.add_score(text, class_key, _final_score, floor_reached)
	_retry_btn.grab_focus()

## G6 §1 row 10: GameOver → confirm (focused item).
func primary_confirm() -> void:
	if _initials.active:
		_initials.confirm_slot()
		return
	var focused: Control = get_viewport().gui_get_focus_owner()
	if focused != null and focused is Button and is_ancestor_of(focused):
		(focused as Button).pressed.emit()
		return
	_on_retry()

## G5 §1: game_over.Back = initials skip; then → hall on ScoresChosen.
func back_pressed() -> void:
	if _initials.active:
		_initials.back_pressed()
		return
	_on_scores()

func _on_retry() -> void:
	var ssm: Node = _ssm
	if ssm != null:
		ssm.try_transition(Verb.RETRY)

func _on_scores() -> void:
	var ssm: Node = _ssm
	if ssm != null:
		ssm.try_transition(Verb.BACK)

func _on_title() -> void:
	var ssm: Node = _ssm
	if ssm != null:
		ssm.try_transition(Verb.ENTER)
