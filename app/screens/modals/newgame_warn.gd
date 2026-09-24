extends Control
## HUNGERHALL — newgame_warn modal (G5 §1: intercepts New Game when a save
## exists; Yes → class_select — the old save survives until the first
## floor_results entry of the new run, G5 Persistence Declaration).

const Verb = StateEnums.Verb

func _ready() -> void:
	var dim: ColorRect = ColorRect.new()
	dim.name = "Dim"
	dim.color = Color(0.0, 0.0, 0.0, 0.7)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(dim)
	var plaque: PanelContainer = PanelContainer.new()
	plaque.name = "Plaque"
	plaque.position = Vector2(160, 120)
	plaque.size = Vector2(320, 120)
	add_child(plaque)
	var col: VBoxContainer = VBoxContainer.new()
	col.add_theme_constant_override("separation", 10)
	plaque.add_child(col)
	var text: Label = Label.new()
	text.name = "WarnText"
	text.text = StringsTable.text("warn.newgame", "")
	text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text.add_theme_font_size_override("font_size", 16)
	col.add_child(text)
	var row: HBoxContainer = HBoxContainer.new()
	row.add_theme_constant_override("separation", 16)
	col.add_child(row)
	var yes: Button = Button.new()
	yes.name = "YesButton"
	yes.text = StringsTable.text("button.new_game", "New Game")
	yes.custom_minimum_size = Vector2(130, 36)
	yes.pressed.connect(_on_yes)
	row.add_child(yes)
	var no: Button = Button.new()
	no.name = "NoButton"
	no.text = StringsTable.text("button.back", "Back")
	no.custom_minimum_size = Vector2(110, 36)
	no.focus_mode = Control.FOCUS_ALL
	no.pressed.connect(cancel)
	row.add_child(no)
	yes.grab_focus()

func primary_confirm() -> void:
	_on_yes()

func cancel() -> void:
	_dismiss()

func _on_yes() -> void:
	var ssm: Node = get_node_or_null("/root/SessionStateMachine")
	_dismiss()
	if ssm != null:
		ssm.try_transition(Verb.PRESS)

func _dismiss() -> void:
	var ssm: Node = get_node_or_null("/root/SessionStateMachine")
	if ssm != null:
		ssm.dismiss_modal(StateEnums.SceneId.MODAL_NEWGAME_WARN)
