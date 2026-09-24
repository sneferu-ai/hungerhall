extends Control
## HUNGERHALL — PausedScreen (G5 §1: rules frozen; Back = ResumeChosen).
## Buttons: Resume (default focus), Settings, Quit to Title (quit_warn modal).

const Verb = StateEnums.Verb
const SceneId = StateEnums.SceneId

func _ready() -> void:
	var dim: ColorRect = ColorRect.new()
	dim.name = "Dim"
	dim.color = Color(0.0, 0.0, 0.0, 0.6)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(dim)
	var plaque: PanelContainer = PanelContainer.new()
	plaque.name = "PausePlaque"
	plaque.position = Vector2(200, 80)
	plaque.size = Vector2(240, 200)
	add_child(plaque)
	var col: VBoxContainer = VBoxContainer.new()
	col.name = "PauseColumn"
	col.add_theme_constant_override("separation", 8)
	plaque.add_child(col)
	var header: Label = Label.new()
	header.name = "PauseHeader"
	header.text = StringsTable.text("pause.header", "Paused")
	header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	header.add_theme_font_size_override("font_size", 24)
	col.add_child(header)
	_button(col, "ResumeButton", "button.resume", "Resume", _on_resume, true)
	_button(col, "SettingsButton", "button.settings", "Settings", _on_settings, false)
	_button(col, "QuitButton", "button.quit_to_title", "Quit to Title", _on_quit, false)

func _button(parent: Control, node_name: String, key: String, fallback: String, handler: Callable, default_focus: bool) -> Button:
	var b: Button = Button.new()
	b.name = node_name
	b.text = StringsTable.text(key, fallback)
	b.custom_minimum_size = Vector2(200, 36)
	b.focus_mode = Control.FOCUS_ALL
	b.pressed.connect(handler)
	parent.add_child(b)
	if default_focus:
		b.grab_focus()
	return b

## G6 §1: Paused → resume.
func resume_pressed() -> void:
	_on_resume()

func primary_confirm() -> void:
	_on_resume()

## G5 §1: paused.Back = ResumeChosen (exception B=Resume).
func back_pressed() -> void:
	_on_resume()

func _on_resume() -> void:
	var ssm: Node = get_node_or_null("/root/SessionStateMachine")
	if ssm != null:
		ssm.try_transition(Verb.RESUME)

func _on_settings() -> void:
	var ssm: Node = get_node_or_null("/root/SessionStateMachine")
	if ssm != null:
		ssm.try_transition(Verb.SETTINGS)

func _on_quit() -> void:
	var ssm: Node = get_node_or_null("/root/SessionStateMachine")
	if ssm == null:
		return
	var modal: Node = ssm.mount_modal(SceneId.MODAL_QUIT_WARN)
	if modal != null and "parent_context" in modal:
		modal.parent_context = "paused"
