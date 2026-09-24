extends Control
## HUNGERHALL — remap_capture modal (G6 §2: single key capture per action
## row; conflict detection "IN USE BY [action]" with swap). Captures the next
## physical key press; Esc/B cancels; while capturing, InputMapper passes raw
## keys through (is_capturing() == true).

var _capturing: bool = false
var _action: String = ""
var _settings_screen: Node = null

var _status: Label = null
var _conflict_note: Label = null
var _conflict_ticks: int = 0

## SettingsScreen starts the capture for one InputMap action.
func begin_capture(action: String, settings_screen: Node) -> void:
	_action = action
	_settings_screen = settings_screen
	_capturing = true
	_status.text = StringsTable.text("remap.prompt", "Press a key")

func is_capturing() -> bool:
	return _capturing

func _ready() -> void:
	var dim: ColorRect = ColorRect.new()
	dim.name = "Dim"
	dim.color = Color(0.0, 0.0, 0.0, 0.7)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(dim)
	var plaque: PanelContainer = PanelContainer.new()
	plaque.name = "Plaque"
	plaque.position = Vector2(170, 130)
	plaque.size = Vector2(300, 100)
	add_child(plaque)
	var col: VBoxContainer = VBoxContainer.new()
	col.add_theme_constant_override("separation", 8)
	plaque.add_child(col)
	_status = Label.new()
	_status.name = "CaptureStatus"
	_status.text = StringsTable.text("remap.prompt", "Press a key")
	_status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_status.add_theme_font_size_override("font_size", 16)
	col.add_child(_status)
	_conflict_note = Label.new()
	_conflict_note.name = "ConflictNote"
	_conflict_note.text = ""
	_conflict_note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_conflict_note.add_theme_font_size_override("font_size", 12)
	_conflict_note.add_theme_color_override("font_color", Color("#D94836"))
	col.add_child(_conflict_note)

func _physics_process(_delta: float) -> void:
	if _conflict_ticks > 0:
		_conflict_ticks -= 1
		if _conflict_ticks <= 0:
			_conflict_note.text = ""

func _input(event: InputEvent) -> void:
	if not _capturing:
		return
	if not (event is InputEventKey) or not event.pressed or event.echo:
		return
	if event.physical_keycode == KEY_ESCAPE:
		_capturing = false
		_dismiss()
		get_viewport().set_input_as_handled()
		return
	_apply_capture(int(event.physical_keycode))
	get_viewport().set_input_as_handled()

func _apply_capture(keycode: int) -> void:
	var conflict_action: String = _find_conflict(keycode)
	if conflict_action != "" and conflict_action != _action:
		# why: G6 §2 — conflict detection with swap: the displaced action takes
		# this action's old key instead of going unbound
		var old_keycode: int = _first_key_of(_action)
		if _settings_screen != null and _settings_screen.has_method("apply_binding"):
			_settings_screen.apply_binding(conflict_action, old_keycode)
		_conflict_note.text = "%s %s" % [StringsTable.text("remap.in_use", "IN USE BY"), conflict_action]
		_conflict_ticks = 90
	var ssm: Node = get_node_or_null("/root/SessionStateMachine")
	if ssm != null:
		_capturing = false
		_dismiss()
		if _settings_screen != null and _settings_screen.has_method("apply_binding"):
			_settings_screen.apply_binding(_action, keycode)

func _find_conflict(keycode: int) -> String:
	for action in ["hh_throw", "hh_potion", "hh_pause", "move_up", "move_down", "move_left", "move_right"]:
		if action == _action:
			continue
		if _first_key_of(action) == keycode:
			return action
	return ""

func _first_key_of(action: String) -> int:
	if not InputMap.has_action(action):
		return 0
	for ev in InputMap.action_get_events(action):
		if ev is InputEventKey:
			return int(ev.physical_keycode)
	return 0

func primary_confirm() -> void:
	pass  # why: during capture the key itself is the confirm

func cancel() -> void:
	_capturing = false
	_dismiss()

func _dismiss() -> void:
	var ssm: Node = get_node_or_null("/root/SessionStateMachine")
	if ssm != null:
		ssm.dismiss_modal(StateEnums.SceneId.MODAL_REMAP_CAPTURE)
