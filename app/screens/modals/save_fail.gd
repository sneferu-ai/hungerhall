extends Control
## HUNGERHALL — save_fail modal (G5 §1: mounted on floor_results when the
## atomic autosave fails; Retry up to 3 times at 0.1s (6-step) intervals;
## after the third failure Skip Save takes over and the hall warns the run
## will not survive app close).

const MAX_RETRIES: int = 3
const RETRY_INTERVAL_STEPS: int = 6  # why: 0.1s at fixed 60Hz

var _retries_left: int = MAX_RETRIES
var _cooldown_steps: int = 0
var _retry_btn: Button = null
var _skip_btn: Button = null
var _note: Label = null

func _ready() -> void:
	var dim: ColorRect = ColorRect.new()
	dim.name = "Dim"
	dim.color = Color(0.0, 0.0, 0.0, 0.7)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(dim)
	var plaque: PanelContainer = PanelContainer.new()
	plaque.name = "Plaque"
	plaque.position = Vector2(150, 110)
	plaque.size = Vector2(340, 150)
	add_child(plaque)
	var col: VBoxContainer = VBoxContainer.new()
	col.add_theme_constant_override("separation", 8)
	plaque.add_child(col)
	var text: Label = Label.new()
	text.text = StringsTable.text("save_fail.text", "")
	text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	text.add_theme_font_size_override("font_size", 16)
	col.add_child(text)
	_note = Label.new()
	_note.name = "NoteLine"
	_note.text = ""
	_note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_note.add_theme_font_size_override("font_size", 12)
	_note.add_theme_color_override("font_color", Color("#D94836"))
	col.add_child(_note)
	var row: HBoxContainer = HBoxContainer.new()
	row.add_theme_constant_override("separation", 16)
	col.add_child(row)
	_retry_btn = Button.new()
	_retry_btn.name = "RetryButton"
	_retry_btn.text = StringsTable.text("save_fail.retry", "Retry")
	_retry_btn.custom_minimum_size = Vector2(120, 36)
	_retry_btn.pressed.connect(_on_retry)
	row.add_child(_retry_btn)
	_skip_btn = Button.new()
	_skip_btn.name = "SkipButton"
	_skip_btn.text = StringsTable.text("save_fail.skip", "Skip Save")
	_skip_btn.custom_minimum_size = Vector2(130, 36)
	_skip_btn.disabled = true
	_skip_btn.pressed.connect(_on_skip)
	row.add_child(_skip_btn)
	_retry_btn.grab_focus()

func _physics_process(_delta: float) -> void:
	if _cooldown_steps > 0:
		_cooldown_steps -= 1
		if _cooldown_steps <= 0:
			_retry_btn.disabled = false

func primary_confirm() -> void:
	if _skip_btn.disabled:
		_on_retry()
	else:
		_on_skip()

func cancel() -> void:
	if not _skip_btn.disabled:
		_on_skip()

func _on_retry() -> void:
	if _cooldown_steps > 0 or _retries_left <= 0:
		return
	var ssm: Node = get_node_or_null("/root/SessionStateMachine")
	if ssm == null:
		return
	_retries_left -= 1
	if ssm.retry_autosave():
		_dismiss()
		return
	if _retries_left <= 0:
		# why: G5 — after 3 failures Skip Save takes over with the warning
		_retry_btn.disabled = true
		_skip_btn.disabled = false
		_note.text = StringsTable.text("save_fail.warn", "")
		_skip_btn.grab_focus()
	else:
		_cooldown_steps = RETRY_INTERVAL_STEPS
		_retry_btn.disabled = true

func _on_skip() -> void:
	_dismiss()
	var ssm: Node = get_node_or_null("/root/SessionStateMachine")
	if ssm != null:
		ssm.try_transition(StateEnums.Verb.SAVE_QUIT)

func _dismiss() -> void:
	var ssm: Node = get_node_or_null("/root/SessionStateMachine")
	if ssm != null:
		ssm.dismiss_modal(StateEnums.SceneId.MODAL_SAVE_FAIL)
