extends Control
## HUNGERHALL — quit_warn modal (G5 §1: fires on title Back and paused Quit;
## no default focus — the player chooses deliberately; G3 quit.text copy;
## title context asks LEAVE HUNGERHALL and Yes exits the app, paused context
## Yes quits to title via the QUIT verb).

const Verb = StateEnums.Verb

var parent_context: String = "paused"  # "title" | "paused"

func _ready() -> void:
	# why: parent_context is stamped by the mounting screen right after
	# mount_modal() returns — defer the build one frame so the copy picks the
	# right context ("LEAVE HUNGERHALL?" vs the paused-floor warning)
	call_deferred("_build")

func _build() -> void:
	var dim: ColorRect = ColorRect.new()
	dim.name = "Dim"
	dim.color = Color(0.0, 0.0, 0.0, 0.7)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(dim)
	var plaque: PanelContainer = PanelContainer.new()
	plaque.name = "Plaque"
	plaque.position = Vector2(170, 120)
	plaque.size = Vector2(300, 120)
	add_child(plaque)
	var col: VBoxContainer = VBoxContainer.new()
	col.add_theme_constant_override("separation", 10)
	plaque.add_child(col)
	var copy: String = StringsTable.text("quit.leave_title", "") if parent_context == "title" \
		else StringsTable.text("quit.text", "")
	var text: Label = Label.new()
	text.name = "WarnText"
	text.text = copy
	text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text.add_theme_font_size_override("font_size", 16)
	col.add_child(text)
	var row: HBoxContainer = HBoxContainer.new()
	row.add_theme_constant_override("separation", 16)
	col.add_child(row)
	var yes: Button = Button.new()
	yes.name = "YesButton"
	yes.text = StringsTable.text("quit.yes", "Quit")
	yes.custom_minimum_size = Vector2(110, 36)
	yes.pressed.connect(_on_yes)
	row.add_child(yes)
	var no: Button = Button.new()
	no.name = "NoButton"
	no.text = StringsTable.text("quit.no", "Stay")
	no.custom_minimum_size = Vector2(110, 36)
	no.focus_mode = Control.FOCUS_ALL
	no.pressed.connect(cancel)
	row.add_child(no)
	no.grab_focus()  # why: G5 — NO is the default for the title-side warn

## InputMapper: primary action confirms the modal.
func primary_confirm() -> void:
	var focused: Control = get_viewport().gui_get_focus_owner()
	if focused != null and focused is Button and is_ancestor_of(focused):
		(focused as Button).pressed.emit()
		return
	_on_yes()

func cancel() -> void:
	_dismiss()

func _on_yes() -> void:
	var ssm: Node = get_node_or_null("/root/SessionStateMachine")
	_dismiss()
	if parent_context == "title":
		# why: G5 window-close rules — from the title the hall exits for good
		get_tree().quit()
	elif ssm != null:
		ssm.try_transition(Verb.QUIT)

func _dismiss() -> void:
	var ssm: Node = get_node_or_null("/root/SessionStateMachine")
	if ssm != null:
		ssm.dismiss_modal(StateEnums.SceneId.MODAL_QUIT_WARN)
