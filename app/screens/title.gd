extends Control
## HUNGERHALL — TitleScreen (G6 §2 app/screens/title.gd).
## MUST load res://Assets/Replays/attract.replay and drive an ISOLATED
## RulesSession from recorded actions at 30Hz (replay playback behind the
## logo — not live AI, DIS-5). Missing reel → the hall reports it in its own
## voice (error.replay_missing G3 key). Menu: New Game (default focus),
## Continue (rendered only when a save exists), The Guestbook, Settings,
## Credits, Privacy — all copy from G3 strings.json keys.

const Verb = StateEnums.Verb
const SceneId = StateEnums.SceneId
const REPLAY_PATH: String = "res://Assets/Replays/attract.replay"
const TICKS_PER_PLAYBACK_FRAME: int = 2  # why: two 60Hz rule ticks per 30Hz frame
const RESTART_DELAY_TICKS: int = 90      # why: 1.5s hold on the terminal moment
const CAPTION_CYCLE_TICKS: int = 300     # why: 5s of rule ticks per attract line

const C_SLATE: Color = Color("#16111F")
const C_WALL_CAP: Color = Color("#5A4E76")
const C_BONE: Color = Color("#F3EAD9")
const C_AMBER: Color = Color("#F2A23B")

var _attract_viewport: SubViewport = null
var _attract_surface: TextureRect = null
var _attract_projection: AttractProjection = null
var _attract_caption: Label = null
var _attract_session: RulesSession = null
var _attract_tunables: TunablesLoader = null
var _attract_actions: Array = []
var _attract_seed: int = 0
var _attract_tick: int = 0
var _action_index: int = 0
var _attract_active: bool = false
var _attract_dead_ticks: int = 0
var _caption_ticks: int = 0
var _caption_index: int = 0
var _attract_pool: Array = []

var _menu: VBoxContainer = null
var _new_game_btn: Button = null
# ---- G9 juice seams (AC-02 logo settle, AC-03 attract veil) ----
var _juice: Node = null
var _logo_label: Label = null
var _attract_veil: ColorRect = null

func _ready() -> void:
	_juice = get_node_or_null("/root/Main/JuiceDirector")
	_setup_attract()  # why: attract layer first so the menu plaque draws above it
	_build_menu()
	# why: G9 AC-02 — title logo settle 1.04 → 1.0 cubic-out (juice.title.settle_ms)
	if _juice != null and _logo_label != null:
		_logo_label.pivot_offset = _logo_label.size / 2.0
		_juice.bind("title_logo.scale", func(v): _logo_label.scale = Vector2(float(v), float(v)))
		_juice.play_ac("AC-02")

func _exit_tree() -> void:
	# why: director outlives this screen — never leave freed closure targets bound
	if _juice != null and is_instance_valid(_juice) and _juice.has_method("unbind"):
		_juice.unbind("title_logo.scale")
		_juice.unbind("attract_veil.alpha")

func _build_menu() -> void:
	var logo: Label = Label.new()
	logo.name = "Logo"
	logo.text = StringsTable.text("title.logo", "HUNGERHALL")
	logo.position = Vector2(36, 24)
	logo.size = Vector2(360, 48)
	logo.add_theme_font_size_override("font_size", 32)
	logo.add_theme_color_override("font_color", C_BONE)
	add_child(logo)
	_logo_label = logo  # G9 AC-02 bind target
	var tagline: Label = Label.new()
	tagline.name = "Tagline"
	tagline.text = StringsTable.text("title.tagline", "")
	tagline.position = Vector2(36, 72)
	tagline.size = Vector2(420, 20)
	tagline.add_theme_font_size_override("font_size", 12)
	tagline.add_theme_color_override("font_color", C_AMBER)
	add_child(tagline)

	var plaque: PanelContainer = PanelContainer.new()
	plaque.name = "MenuPlaque"
	plaque.position = Vector2(404, 24)
	plaque.size = Vector2(212, 312)
	add_child(plaque)
	_menu = VBoxContainer.new()
	_menu.name = "MenuColumn"
	_menu.add_theme_constant_override("separation", 4)
	plaque.add_child(_menu)

	var ssm: Node = get_node_or_null("/root/SessionStateMachine")
	var save_exists: bool = ssm != null and ssm.save_store.save_exists()

	_new_game_btn = _menu_button("NewGameButton", "button.new_game", "New Game", _on_new_game)
	if save_exists:
		_menu_button("ContinueButton", "button.continue", "Continue", _on_continue)
	_menu_button("GuestbookButton", "title.guestbook_header", "The Guestbook", _on_guestbook)
	_menu_button("SettingsButton", "button.settings", "Settings", _on_settings)
	_menu_button("CreditsButton", "button.credits", "Credits", _on_credits)
	_menu_button("PrivacyButton", "button.privacy", "Privacy", _on_privacy)
	_new_game_btn.grab_focus()  # why: default focus per G5 §1 title screen

func _menu_button(node_name: String, key: String, fallback: String, handler: Callable) -> Button:
	var b: Button = Button.new()
	b.name = node_name
	b.text = StringsTable.text(key, fallback)
	b.custom_minimum_size = Vector2(188, 40)
	b.focus_mode = Control.FOCUS_ALL
	b.pressed.connect(handler)
	_menu.add_child(b)
	return b

## InputMapper contextual confirm (G6 §1: Title → confirm focused item).
func primary_confirm() -> void:
	var focused: Control = get_viewport().gui_get_focus_owner()
	if focused != null and focused is Button and is_ancestor_of(focused):
		(focused as Button).pressed.emit()
		return
	_on_new_game()

## G5 §1: title Back → quit_warn modal ("LEAVE HUNGERHALL?").
func back_pressed() -> void:
	var ssm: Node = get_node_or_null("/root/SessionStateMachine")
	if ssm == null:
		return
	var modal: Node = ssm.mount_modal(SceneId.MODAL_QUIT_WARN)
	if modal != null and "parent_context" in modal:
		modal.parent_context = "title"

func _on_new_game() -> void:
	var ssm: Node = get_node_or_null("/root/SessionStateMachine")
	if ssm == null:
		return
	if ssm.save_store.save_exists():
		# why: G5 §1 — newgame_warn intercepts first when a save exists
		ssm.mount_modal(SceneId.MODAL_NEWGAME_WARN)
		return
	ssm.try_transition(Verb.PRESS)

func _on_continue() -> void:
	var ssm: Node = get_node_or_null("/root/SessionStateMachine")
	if ssm != null:
		ssm.try_transition(Verb.RESUME)

func _on_guestbook() -> void:
	var ssm: Node = get_node_or_null("/root/SessionStateMachine")
	if ssm != null:
		ssm.try_transition(Verb.BACK)

func _on_settings() -> void:
	var ssm: Node = get_node_or_null("/root/SessionStateMachine")
	if ssm != null:
		ssm.try_transition(Verb.SETTINGS)

func _on_credits() -> void:
	var ssm: Node = get_node_or_null("/root/SessionStateMachine")
	if ssm != null:
		ssm.mount_modal(SceneId.MODAL_CREDITS_POP)

func _on_privacy() -> void:
	var ssm: Node = get_node_or_null("/root/SessionStateMachine")
	if ssm != null:
		ssm.mount_modal(SceneId.MODAL_PRIVACY_POP)

# ---- attract replay (isolated session; presentation-only) ----

func _physics_process(_delta: float) -> void:
	if not _attract_active:
		return
	# why: step-driven playback — two fixed 60Hz ticks per 30Hz frame keeps
	# the reel deterministic and never wall-clock-bound
	_advance_playback(TICKS_PER_PLAYBACK_FRAME)

func _advance_playback(ticks: int) -> void:
	for _i in range(ticks):
		if _attract_session == null:
			return
		if _attract_session.state != StateEnums.State.PLAYING:
			_attract_dead_ticks += 1
			if _attract_dead_ticks >= RESTART_DELAY_TICKS:
				_restart_attract()
			return
		while _action_index < _attract_actions.size() and int(_attract_actions[_action_index].tick) == _attract_tick:
			_attract_session.input(_attract_actions[_action_index].event)
			_action_index += 1
		_attract_session.step()
		_attract_tick += 1
		_attract_session.consume_pending()
		if not _attract_actions.is_empty() and _action_index >= _attract_actions.size() \
				and _attract_tick > int(_attract_actions.back().tick) + 240:
			_restart_attract()
			return
	_caption_ticks += 1
	if _caption_ticks >= CAPTION_CYCLE_TICKS:
		_caption_ticks = 0
		_caption_index += 1
		_update_caption()
	if _attract_projection != null:
		_attract_projection.session = _attract_session
		_attract_projection.queue_redraw()

func _restart_attract() -> void:
	var cd: ClassDef = ClassDef.build(
		ClassDef.class_type_for(str((_attract_class_name if _attract_class_name != "" else "warrior"))),
		_attract_tunables)
	_attract_session = RulesSession.new()
	_attract_session.setup_campaign(_attract_tunables, cd, _attract_seed)
	_attract_tick = 0
	_action_index = 0
	_attract_dead_ticks = 0

var _attract_class_name: String = "warrior"

func _setup_attract() -> void:
	_attract_caption = Label.new()
	_attract_caption.name = "AttractCaption"
	_attract_caption.add_theme_font_size_override("font_size", 12)
	_attract_caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_attract_caption.position = Vector2(0, 338)
	_attract_caption.size = Vector2(404, 18)
	_attract_caption.add_theme_color_override("font_color", C_BONE)
	_attract_pool = StringsTable.pool("title.attract")

	var replay: Dictionary = _load_replay()
	if replay.is_empty():
		_attract_caption.text = StringsTable.text("error.replay_missing", "")
		add_child(_attract_caption)
		return

	_attract_tunables = TunablesLoader.new()
	if not _attract_tunables.load_from_path("res://Tunables.json"):
		_attract_caption.text = StringsTable.text("error.replay_missing", "")
		add_child(_attract_caption)
		return

	_attract_seed = int(replay.get("seed", 57005))
	_attract_actions = replay.get("actions", [])
	_attract_class_name = str(replay.get("class", "warrior"))
	if _attract_actions.is_empty():
		_attract_caption.text = StringsTable.text("error.replay_missing", "")
		add_child(_attract_caption)
		return

	var cd: ClassDef = ClassDef.build(ClassDef.class_type_for(_attract_class_name), _attract_tunables)
	_attract_session = RulesSession.new()
	_attract_session.setup_campaign(_attract_tunables, cd, _attract_seed)

	_attract_viewport = SubViewport.new()
	_attract_viewport.name = "AttractViewport"
	_attract_viewport.size = Vector2i(640, 360)
	_attract_viewport.transparent_bg = false
	_attract_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS

	_attract_projection = AttractProjection.new()
	_attract_projection.name = "AttractProjection"
	_attract_projection.session = _attract_session
	_attract_viewport.add_child(_attract_projection)
	add_child(_attract_viewport)

	_attract_surface = TextureRect.new()
	_attract_surface.name = "AttractSurface"
	_attract_surface.texture = _attract_viewport.get_texture()
	_attract_surface.position = Vector2(0, 0)
	_attract_surface.size = Vector2(640, 360)
	_attract_surface.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_attract_surface)

	# why: G9 AC-03 — attract veil 0 → 0.35 cubic-out (juice.attract.veil_ms)
	# over the reel surface; added BEFORE the caption so the caption stays
	# fully legible above the veil (draw order = child order).
	_attract_veil = ColorRect.new()
	_attract_veil.name = "AttractVeil"
	_attract_veil.position = Vector2.ZERO
	_attract_veil.size = Vector2(640, 360)
	_attract_veil.color = Color(0, 0, 0, 0)
	_attract_veil.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_attract_veil)
	if _juice != null and _juice.has_method("bind"):
		_juice.bind("attract_veil.alpha", func(v): _attract_veil.color.a = float(v))

	add_child(_attract_caption)
	_update_caption()
	_attract_active = true
	# why: AC-03 fires exactly when attract mode becomes active
	if _juice != null and _juice.has_method("play_ac"):
		_juice.play_ac("AC-03")

func _update_caption() -> void:
	if _attract_caption == null or _attract_pool.is_empty():
		return
	_attract_caption.text = str(_attract_pool[_caption_index % _attract_pool.size()])

func _load_replay() -> Dictionary:
	if not FileAccess.file_exists(REPLAY_PATH):
		return {}
	var f: FileAccess = FileAccess.open(REPLAY_PATH, FileAccess.READ)
	if f == null:
		return {}
	var text: String = f.get_as_text()
	f.close()
	var parsed: Variant = JSON.parse_string(text)
	if not (parsed is Dictionary):
		return {}
	if str(parsed.get("schema", "")) != "hungerhall_replay_v1":
		return {}
	return parsed

class AttractProjection:
	extends Node2D
	## Compact attract-replay projection inside AttractViewport — draws the
	## isolated session state with palette tokens and a clamped camera.

	const C_CANVAS: Color = Color("#0B0A13")
	const C_FLOOR: Color = Color("#252039")
	const C_WALL: Color = Color("#191526")
	const C_WALL_CAP: Color = Color("#5A4E76")
	const C_EXIT: Color = Color("#F2A23B")
	const C_KEY: Color = Color("#D9DEE2")
	const C_FOOD: Color = Color("#EFC258")
	const C_POTION: Color = Color("#79D6C9")
	const C_ENEMY: Color = Color("#D94836")
	const C_GEN: Color = Color("#8169AE")
	const C_HERO: Color = Color("#C87040")

	var session: RulesSession = null

	func _draw() -> void:
		if session == null:
			return
		var f: RulesFloor = session.floor
		var world_w: float = float(f.grid_w * 32)
		var world_h: float = float(f.grid_h * 32)
		draw_rect(Rect2(0, 0, 640, 360), C_CANVAS)
		var cam_x: float = clampf(session.player.pos_x - 320.0, 0.0, maxf(0.0, world_w - 640.0))
		var cam_y: float = clampf(session.player.pos_y - 180.0, 0.0, maxf(0.0, world_h - 360.0))
		draw_set_transform(Vector2(-cam_x, -cam_y))
		for y in range(f.grid_h):
			for x in range(f.grid_w):
				var r: Rect2 = Rect2(x * 32, y * 32, 32, 32)
				if f.is_wall(x, y):
					draw_rect(r, C_WALL)
					draw_rect(Rect2(r.position, Vector2(32, 4)), C_WALL_CAP)
				else:
					draw_rect(r, C_FLOOR)
		draw_rect(Rect2(f.exit_pos.x * 32 + 2, f.exit_pos.y * 32 + 2, 28, 28), C_EXIT)
		for d in session.pickups.doors:
			if not d.open:
				draw_rect(Rect2(d.pos.x * 32 + 4, d.pos.y * 32 + 4, 24, 24), C_KEY)
		for k in session.pickups.keys:
			draw_rect(Rect2(k.x * 32 + 11, k.y * 32 + 11, 10, 10), C_KEY)
		for fd in session.pickups.foods:
			if session.pickups.is_food_consumed(fd.x, fd.y):
				continue
			draw_rect(Rect2(fd.x * 32 + 10, fd.y * 32 + 10, 12, 12), C_FOOD)
		for pt in session.pickups.potions:
			draw_rect(Rect2(pt.x * 32 + 11, pt.y * 32 + 9, 10, 14), C_POTION)
		for g in session.generators:
			if g.alive:
				draw_rect(Rect2(g.pos_x - 14, g.pos_y - 14, 28, 28), C_GEN)
		for e in session.enemies:
			if e.alive:
				draw_rect(Rect2(e.pos_x - 10, e.pos_y - 10, 20, 20), C_ENEMY)
		draw_rect(Rect2(session.player.pos_x - 11, session.player.pos_y - 11, 22, 22), C_HERO)
		draw_set_transform(Vector2.ZERO)
