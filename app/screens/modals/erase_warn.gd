extends Control
## HUNGERHALL — erase_warn modal (G5 §1: settings-only destructive path;
## irreversible; DOUBLE CONFIRM; Yes erases campaign + scores, not settings,
## and returns to title; No returns to settings).

func _ready() -> void:
	var dim: ColorRect = ColorRect.new()
	dim.name = "Dim"
	dim.color = Color(0.0, 0.0, 0.0, 0.7)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(dim)
	_plaque("warn.erase", "StageOne")

var _stage: int = 1

func _plaque(text_key: String, tag: String) -> void:
	var plaque: PanelContainer = PanelContainer.new()
	plaque.name = "Plaque" + tag
	plaque.position = Vector2(150, 110)
	plaque.size = Vector2(340, 140)
	add_child(plaque)
	var col: VBoxContainer = VBoxContainer.new()
	col.add_theme_constant_override("separation", 10)
	plaque.add_child(col)
	var text: Label = Label.new()
	text.name = "WarnText"
	text.text = StringsTable.text(text_key, "")
	text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text.add_theme_font_size_override("font_size", 16)
	col.add_child(text)
	var row: HBoxContainer = HBoxContainer.new()
	row.add_theme_constant_override("separation", 16)
	col.add_child(row)
	var yes: Button = Button.new()
	yes.name = "YesButton"
	yes.text = StringsTable.text("quit.yes", "Quit") if _stage == 1 else StringsTable.text("label.erase_save", "Erase Save")
	yes.custom_minimum_size = Vector2(140, 36)
	yes.pressed.connect(_on_yes)
	row.add_child(yes)
	var no: Button = Button.new()
	no.name = "NoButton"
	no.text = StringsTable.text("quit.no", "Stay") if _stage == 1 else StringsTable.text("button.back", "Back")
	no.custom_minimum_size = Vector2(110, 36)
	no.focus_mode = Control.FOCUS_ALL
	no.pressed.connect(cancel)
	row.add_child(no)
	no.grab_focus()

func primary_confirm() -> void:
	_on_yes()

func cancel() -> void:
	_dismiss()

func _on_yes() -> void:
	if _stage == 1:
		# why: G5 — double confirm before anything is destroyed
		_stage = 2
		var plaque: Node = get_node_or_null("PlaqueStageOne")
		if plaque != null:
			plaque.queue_free()
		_plaque("warn.erase_again", "StageTwo")
		return
	var ssm: Node = get_node_or_null("/root/SessionStateMachine")
	if ssm != null:
		ssm.save_store.erase_campaign()
		# why: scores are part of the guestbook wipe (G5: all data erased)
		ssm.score_store.reset_scores()
	_dismiss()
	if ssm != null:
		ssm.try_transition(StateEnums.Verb.QUIT)

func _dismiss() -> void:
	var ssm: Node = get_node_or_null("/root/SessionStateMachine")
	if ssm != null:
		ssm.dismiss_modal(StateEnums.SceneId.MODAL_ERASE_WARN)
