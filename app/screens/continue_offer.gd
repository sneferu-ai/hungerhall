extends Control
## HUNGERHALL — ContinueOfferScreen (G5 §1: 600-step ring; 300ms grace on
## entry suppresses input — DIS-9; Back = no, no warn; zero tokens = "No
## continues" 2s hold then auto game over — SSM drives both timers).

const SceneId = StateEnums.SceneId

var _ring: ContinueRing = null
var _yes_btn: Button = null
var _no_btn: Button = null
var _grace_label: Label = null

func _ready() -> void:
	var dim: ColorRect = ColorRect.new()
	dim.name = "Dim"
	dim.color = Color(0.0, 0.0, 0.0, 0.55)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(dim)
	var ssm: Node = get_node_or_null("/root/SessionStateMachine")
	var tokens: int = ssm.session.continue_state.tokens if ssm != null and ssm.session != null else 0

	_ring = ContinueRing.new()
	_ring.name = "ContinueRing"
	_ring.position = Vector2(260, 90)
	add_child(_ring)
	if tokens <= 0:
		# why: G2 §2 — no tokens shows the 2s "No continues" hold, not the ring
		_ring.set_zero_token_mode(120)
	else:
		_ring.configure(600, tokens)

	_yes_btn = Button.new()
	_yes_btn.name = "YesButton"
	_yes_btn.text = StringsTable.text("continue.yes", "Yes")
	_yes_btn.position = Vector2(240, 250)
	_yes_btn.size = Vector2(80, 36)
	_yes_btn.focus_mode = Control.FOCUS_ALL
	_yes_btn.pressed.connect(_choose_yes)
	add_child(_yes_btn)
	_no_btn = Button.new()
	_no_btn.name = "NoButton"
	_no_btn.text = StringsTable.text("continue.no", "No")
	_no_btn.position = Vector2(336, 250)
	_no_btn.size = Vector2(80, 36)
	_no_btn.focus_mode = Control.FOCUS_ALL
	_no_btn.pressed.connect(_choose_no)
	add_child(_no_btn)
	_grace_label = Label.new()
	_grace_label.name = "GraceNote"
	_grace_label.text = ""
	_grace_label.position = Vector2(220, 296)
	_grace_label.size = Vector2(200, 18)
	_grace_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_grace_label.add_theme_font_size_override("font_size", 12)
	_grace_label.add_theme_color_override("font_color", Color("#5A4E76"))
	add_child(_grace_label)
	_yes_btn.grab_focus()  # why: G5 — YES pre-highlighted

func _physics_process(_delta: float) -> void:
	_ring.tick()
	var ssm: Node = get_node_or_null("/root/SessionStateMachine")
	if ssm != null and ssm.continue_grace_active():
		_yes_btn.disabled = true
		_no_btn.disabled = true
	else:
		_yes_btn.disabled = false
		_no_btn.disabled = false

## G6 §1 row 9: ContinueOffer → yes.
func primary_confirm() -> void:
	_choose_yes()

func choose_no() -> void:
	_choose_no()

func _choose_yes() -> void:
	var ssm: Node = get_node_or_null("/root/SessionStateMachine")
	if ssm != null:
		ssm.choose_continue(true)

func _choose_no() -> void:
	var ssm: Node = get_node_or_null("/root/SessionStateMachine")
	if ssm != null:
		ssm.choose_continue(false)
