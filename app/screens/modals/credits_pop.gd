extends Control
## HUNGERHALL — credits_pop modal (G5 §1: pop-up modal over title/settings;
## original text from strings.json credits category).

func _ready() -> void:
	var dim: ColorRect = ColorRect.new()
	dim.name = "Dim"
	dim.color = Color(0.0, 0.0, 0.0, 0.7)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(dim)
	var plaque: PanelContainer = PanelContainer.new()
	plaque.name = "Plaque"
	plaque.position = Vector2(120, 90)
	plaque.size = Vector2(400, 180)
	add_child(plaque)
	var col: VBoxContainer = VBoxContainer.new()
	col.add_theme_constant_override("separation", 10)
	plaque.add_child(col)
	var header: Label = Label.new()
	header.text = StringsTable.text("button.credits", "Credits")
	header.add_theme_font_size_override("font_size", 24)
	col.add_child(header)
	var body: Label = Label.new()
	body.name = "CreditsBody"
	body.text = StringsTable.text("credits.body", "")
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.custom_minimum_size = Vector2(360, 90)
	body.add_theme_font_size_override("font_size", 12)
	col.add_child(body)
	var done: Button = Button.new()
	done.name = "DoneButton"
	done.text = StringsTable.text("button.done", "Done")
	done.custom_minimum_size = Vector2(120, 36)
	done.focus_mode = Control.FOCUS_ALL
	done.pressed.connect(cancel)
	col.add_child(done)
	done.grab_focus()

func primary_confirm() -> void:
	cancel()

func cancel() -> void:
	var ssm: Node = get_node_or_null("/root/SessionStateMachine")
	if ssm != null:
		ssm.dismiss_modal(StateEnums.SceneId.MODAL_CREDITS_POP)
