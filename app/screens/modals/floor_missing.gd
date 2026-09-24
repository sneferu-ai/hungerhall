extends Control
## HUNGERHALL — floor_missing modal (G5 §1: fired when a baked floor .tres
## fails to load — F1–23 Skip Floor advances save.floor, F24 returns to
## title; Back = same as Back to Title, no warn).

func _ready() -> void:
	var dim: ColorRect = ColorRect.new()
	dim.name = "Dim"
	dim.color = Color(0.0, 0.0, 0.0, 0.7)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(dim)
	var plaque: PanelContainer = PanelContainer.new()
	plaque.name = "Plaque"
	plaque.position = Vector2(150, 120)
	plaque.size = Vector2(340, 130)
	add_child(plaque)
	var col: VBoxContainer = VBoxContainer.new()
	col.add_theme_constant_override("separation", 8)
	plaque.add_child(col)
	var text: Label = Label.new()
	text.text = StringsTable.text("floor_missing.text", "")
	text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	text.add_theme_font_size_override("font_size", 16)
	col.add_child(text)
	var row: HBoxContainer = HBoxContainer.new()
	row.add_theme_constant_override("separation", 16)
	col.add_child(row)
	var skip: Button = Button.new()
	skip.name = "SkipButton"
	skip.text = StringsTable.text("floor_missing.skip", "Skip Floor")
	skip.custom_minimum_size = Vector2(130, 36)
	skip.pressed.connect(_on_skip)
	row.add_child(skip)
	var back: Button = Button.new()
	back.name = "BackTitleButton"
	back.text = StringsTable.text("floor_missing.back_title", "Back to Title")
	back.custom_minimum_size = Vector2(150, 36)
	back.focus_mode = Control.FOCUS_ALL
	back.pressed.connect(_on_back_title)
	row.add_child(back)
	back.grab_focus()

func primary_confirm() -> void:
	var focused: Control = get_viewport().gui_get_focus_owner()
	if focused != null and focused is Button and is_ancestor_of(focused):
		(focused as Button).pressed.emit()
		return
	_on_back_title()

func cancel() -> void:
	_on_back_title()

func _on_skip() -> void:
	var ssm: Node = get_node_or_null("/root/SessionStateMachine")
	if ssm != null:
		ssm.resolve_floor_missing(true)

func _on_back_title() -> void:
	var ssm: Node = get_node_or_null("/root/SessionStateMachine")
	if ssm != null:
		ssm.resolve_floor_missing(false)
