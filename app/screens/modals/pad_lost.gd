extends Control
## HUNGERHALL — pad_lost modal (G5 §1: mounts over paused after auto-pause;
## the game stays paused; dismisses on any keyboard key or on pad reconnect).

var _status: Label = null

func _ready() -> void:
	var dim: ColorRect = ColorRect.new()
	dim.name = "Dim"
	dim.color = Color(0.0, 0.0, 0.0, 0.7)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(dim)
	var plaque: PanelContainer = PanelContainer.new()
	plaque.name = "Plaque"
	plaque.position = Vector2(150, 130)
	plaque.size = Vector2(340, 100)
	add_child(plaque)
	var col: VBoxContainer = VBoxContainer.new()
	col.add_theme_constant_override("separation", 8)
	plaque.add_child(col)
	var text: Label = Label.new()
	text.text = StringsTable.text("pad_lost.text", "")
	text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	text.add_theme_font_size_override("font_size", 16)
	col.add_child(text)
	_status = Label.new()
	_status.name = "HintLine"
	_status.text = StringsTable.text("pad_lost.hint", "")
	_status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_status.add_theme_font_size_override("font_size", 12)
	_status.add_theme_color_override("font_color", Color("#5A4E76"))
	col.add_child(_status)

## InputMapper passes raw keys through while this modal waits for one.
func is_capturing() -> bool:
	return true

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		_dismiss()
		get_viewport().set_input_as_handled()

## InputMapper: a pad came back while we were open.
func on_pad_reconnected() -> void:
	_dismiss()

func primary_confirm() -> void:
	_dismiss()

func cancel() -> void:
	_dismiss()

func _dismiss() -> void:
	var ssm: Node = get_node_or_null("/root/SessionStateMachine")
	if ssm != null:
		ssm.dismiss_modal(StateEnums.SceneId.MODAL_PAD_LOST)
