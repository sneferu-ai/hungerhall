extends Control
## HUNGERHALL — SettingsScreen (G5 §1 LAR-4: ONE flat scrollable column).
## Sliders/toggles write atomically on release/change — no Apply button. Rows:
## volumes, captions, caption size, reduced motion, rumble, auto-fire,
## fullscreen, three remap rows, credits, privacy, reset defaults, erase
## save. Back routes to caller via the SSM entered_from predicates.

const Verb = StateEnums.Verb
const SceneId = StateEnums.SceneId

var _ssm: Node = null
var _settings: Dictionary = {}
var _column: VBoxContainer = null
var _remap_labels: Dictionary = {}

func _ready() -> void:
	_ssm = get_node_or_null("/root/SessionStateMachine")
	_settings = _ssm.settings.duplicate(true) if _ssm != null else {}
	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.name = "SettingsScroll"
	scroll.position = Vector2(120, 8)
	scroll.size = Vector2(400, 320)
	add_child(scroll)
	_column = VBoxContainer.new()
	_column.name = "SettingsColumn"
	_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_column.add_theme_constant_override("separation", 4)
	scroll.add_child(_column)
	var header: Label = _label(StringsTable.text("settings.header", "Settings"), 24)
	_column.add_child(header)
	_slider_row("label.sfx_volume", "SFX Volume", "sfx_vol", 0, 100)
	_slider_row("label.music_volume", "Music Volume", "music_vol", 0, 100)
	_toggle_row("label.captions", "Captions", "captions")
	_option_row("label.caption_size", "Caption Size", "caption_size", [16, 24, 32])
	_toggle_row("label.reduced_motion", "Reduced Motion", "reduced_motion")
	_slider_row("label.rumble", "Rumble", "rumble_intensity", 0, 100)
	_toggle_row("label.auto_fire", "Auto-Fire", "auto_fire")
	_toggle_row("label.fullscreen", "Fullscreen", "fullscreen")
	_remap_row("label.binding_throw", "Throw", "hh_throw")
	_remap_row("label.binding_potion", "Potion", "hh_potion")
	_remap_row("label.binding_pause", "Pause", "hh_pause")
	_button_row("button.credits", "Credits", _on_credits)
	_button_row("button.privacy", "Privacy", _on_privacy)
	_button_row("button.reset_defaults", "Reset Defaults", _on_reset_defaults)
	_button_row("label.erase_save", "Erase Save", _on_erase_save)
	_button_row("button.back", "Back", back_pressed)

func _label(text: String, size: int) -> Label:
	var l: Label = Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	return l

func _slider_row(key: String, fallback: String, setting: String, lo: int, hi: int) -> void:
	var row: HBoxContainer = HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	row.add_child(_label(StringsTable.text(key, fallback), 16))
	var slider: HSlider = HSlider.new()
	slider.min_value = lo
	slider.max_value = hi
	slider.value = int(_settings.get(setting, (lo + hi) / 2))
	slider.custom_minimum_size = Vector2(160, 20)
	slider.drag_ended.connect(func() -> void: _save_setting(setting, int(slider.value)))
	row.add_child(slider)
	_column.add_child(row)

func _toggle_row(key: String, fallback: String, setting: String) -> void:
	var row: HBoxContainer = HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	row.add_child(_label(StringsTable.text(key, fallback), 16))
	var check: CheckBox = CheckBox.new()
	check.button_pressed = bool(_settings.get(setting, false))
	check.toggled.connect(func(on: bool) -> void:
		_save_setting(setting, on)
		if setting == "fullscreen":
			_apply_fullscreen(on)
	)
	row.add_child(check)
	_column.add_child(row)

func _option_row(key: String, fallback: String, setting: String, options: Array) -> void:
	var row: HBoxContainer = HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	row.add_child(_label(StringsTable.text(key, fallback), 16))
	var opt: OptionButton = OptionButton.new()
	for o in options:
		opt.add_item(str(o))
	opt.selected = options.find(int(_settings.get(setting, options[0])))
	opt.item_selected.connect(func(idx: int) -> void: _save_setting(setting, options[idx]))
	row.add_child(opt)
	_column.add_child(row)

func _remap_row(key: String, fallback: String, action: String) -> void:
	var row: HBoxContainer = HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	row.add_child(_label(StringsTable.text(key, fallback), 16))
	var b: Button = Button.new()
	b.text = _binding_text(action)
	b.custom_minimum_size = Vector2(120, 28)
	b.pressed.connect(_on_remap.bind(action))
	_remap_labels[action] = b
	row.add_child(b)
	_column.add_child(row)

func _binding_text(action: String) -> String:
	var custom: Dictionary = _settings.get("bindings", {})
	if custom is Dictionary and custom.has(action):
		return OS.get_keycode_string(DisplayServer.keyboard_get_keycode_from_physical(int(custom[action])))
	for ev in InputMap.action_get_events(action):
		if ev is InputEventKey:
			return OS.get_keycode_string(DisplayServer.keyboard_get_keycode_from_physical(ev.physical_keycode))
	return "-"

func _button_row(key: String, fallback: String, handler: Callable) -> void:
	var b: Button = Button.new()
	b.text = StringsTable.text(key, fallback)
	b.custom_minimum_size = Vector2(240, 32)
	b.pressed.connect(handler)
	_column.add_child(b)

func _save_setting(setting: String, value: Variant) -> void:
	_settings[setting] = value
	if _ssm != null:
		_ssm.settings[setting] = value
		_ssm.settings_store.write_settings(_settings)

func _apply_fullscreen(on: bool) -> void:
	if on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _on_remap(action: String) -> void:
	var ssm: Node = _ssm
	if ssm == null:
		return
	var modal: Node = ssm.mount_modal(SceneId.MODAL_REMAP_CAPTURE)
	if modal != null and modal.has_method("begin_capture"):
		modal.begin_capture(action, self)

## RemapCaptureModal reports back here.
func apply_binding(action: String, physical_keycode: int) -> void:
	var bindings: Dictionary = _settings.get("bindings", {})
	if not (bindings is Dictionary):
		bindings = {}
	bindings[action] = physical_keycode
	_settings["bindings"] = bindings
	if _ssm != null:
		_ssm.settings["bindings"] = bindings
		_ssm.settings_store.write_settings(_settings)
	for ev in InputMap.action_get_events(action):
		if ev is InputEventKey:
			InputMap.action_erase_event(action, ev)
	var new_ev: InputEventKey = InputEventKey.new()
	new_ev.physical_keycode = physical_keycode
	InputMap.action_add_event(action, new_ev)
	if _remap_labels.has(action):
		_remap_labels[action].text = OS.get_keycode_string(DisplayServer.keyboard_get_keycode_from_physical(physical_keycode))

func _on_credits() -> void:
	if _ssm != null:
		_ssm.mount_modal(SceneId.MODAL_CREDITS_POP)

func _on_privacy() -> void:
	if _ssm != null:
		_ssm.mount_modal(SceneId.MODAL_PRIVACY_POP)

func _on_reset_defaults() -> void:
	if _ssm != null:
		_ssm.mount_modal(SceneId.MODAL_RESET_WARN)

func _on_erase_save() -> void:
	if _ssm != null:
		_ssm.mount_modal(SceneId.MODAL_ERASE_WARN)

## ResetWarnModal seam — restores the schema defaults (settings only; the
## guestbook survives). Also clears custom bindings from the live InputMap.
func apply_reset_defaults() -> void:
	if _ssm == null:
		return
	var defaults: Dictionary = SaveCodec.default_settings()
	_settings = defaults.duplicate(true)
	_ssm.settings = defaults.duplicate(true)
	_ssm.settings_store.write_settings(defaults)
	_apply_fullscreen(bool(defaults.get("fullscreen", false)))

## G5 §1: settings Back → caller (entered_from predicates in the table).
func back_pressed() -> void:
	var ssm: Node = _ssm
	if ssm != null:
		ssm.try_transition(Verb.BACK)
