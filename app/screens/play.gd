extends Control
## HUNGERHALL — PlayScreen (G6 §2 app/screens/play.gd).
## Two layers: world/ projection (WorldView + actors + camera + life-light +
## particles + floaters) and ui/ layer (wordless HUD + caption band + idle
## prompts). Rules are NOT stepped here — main.gd drives
## SessionStateMachine.tick_once() once per _physics_process (fixed 60Hz);
## this screen queues semantic inputs and renders the resulting snapshot.
## Journey-contract properties: is_playing, hp, shots_fired, player_tile_x,
## player_tile_y.

const TILE: int = 32

var is_playing: bool = false
var hp: int = 0
var shots_fired: int = 0
var player_tile_x: int = 0
var player_tile_y: int = 0

var _session: RulesSession = null
var _ssm: Node = null
var _world_view: Node2D = null
var _hud: Hud = null
var _caption_band: CaptionBand = null
var _idle_prompts: IdlePrompts = null
var _throw_held_last: bool = false
var _captioned_events: Dictionary = {}
var _idle_this_tick: bool = true
# ---- G9 juice binding seam (composition → JuiceDirector, mounted on Main) ----
var _director: Node = null
var _vignette: ColorRect = null
var _death_vignette: ColorRect = null
var _screen_edge: ColorRect = null

func _ready() -> void:
	# ---- world/ layer ----
	var world_layer: Node2D = Node2D.new()
	world_layer.name = "WorldLayer"
	add_child(world_layer)
	_world_view = WorldView.new()
	_world_view.name = "WorldView"
	world_layer.add_child(_world_view)
	# ---- ui/ layer ----
	var ui_layer: CanvasLayer = CanvasLayer.new()
	ui_layer.name = "UILayer"
	ui_layer.layer = 10
	add_child(ui_layer)
	_hud = Hud.new()
	_hud.name = "Hud"
	ui_layer.add_child(_hud)
	_caption_band = CaptionBand.new()
	_caption_band.name = "CaptionBand"
	_caption_band.position = Vector2(0, 317)  # why: presentation_contract y 0.88
	ui_layer.add_child(_caption_band)
	_idle_prompts = IdlePrompts.new()
	_idle_prompts.name = "IdlePrompts"
	_idle_prompts.position = Vector2(256, 120)
	ui_layer.add_child(_idle_prompts)
	var ssm: Node = get_node_or_null("/root/SessionStateMachine")
	if ssm != null:
		_ssm = ssm
		_session = ssm.session
		_caption_band.set_captions_enabled(bool(ssm.settings.get("captions", true)))
	_bind_juice_director()

## G9 presentation-layer wiring (OQ-3: "G10's first task"). The JuiceDirector
## is an authored child of Main (outlives this screen); this screen attaches
## its world + HUD, supplies the overlay rects it owns (UI + transition
## layers), registers every engine-prop applier, and feeds snapshots/events
## each fixed step. _exit_tree clears the seam — a freed screen can never
## leave dangling references on the director.
func _bind_juice_director() -> void:
	var director: Node = get_node_or_null("/root/Main/JuiceDirector")
	if director == null or not director.has_method("attach_world"):
		return
	_director = director
	director.attach_world(_world_view)
	director.attach_hud(_hud)
	if _world_view.has_method("set_juice_director"):
		_world_view.set_juice_director(director)
	# ---- screen-space overlay rects (G9 HUDCanvas + TransitionOverlay rows) ----
	var ui_layer: CanvasLayer = get_node("UILayer")
	_vignette = _make_overlay_rect("VignetteRect", Color("#300508"), ui_layer)
	_death_vignette = _make_overlay_rect("DeathVignetteRect", Color("#400000"), ui_layer)
	_screen_edge = _make_overlay_rect("ScreenEdgeRect", Color("#D94836"), ui_layer)
	if _world_view.has_method("attach_screen_edge"):
		_world_view.attach_screen_edge(_screen_edge)
	var trans_layer: CanvasLayer = CanvasLayer.new()
	trans_layer.name = "JuiceTransitionLayer"
	trans_layer.layer = 20
	add_child(trans_layer)
	var flash_rect: ColorRect = _make_overlay_rect("FlashRect", Color.WHITE, trans_layer)
	var class_tint_rect: ColorRect = _make_overlay_rect("ClassTintRect", Color("#8B0000"), trans_layer)
	var additive: CanvasItemMaterial = CanvasItemMaterial.new()
	additive.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	class_tint_rect.material = additive  # G9: ClassTintRect is additive blend
	var sig5_rect: TextureRect = TextureRect.new()
	sig5_rect.name = "SIG5BorderRect"
	sig5_rect.position = Vector2.ZERO
	sig5_rect.size = Vector2(640, 360)
	sig5_rect.pivot_offset = Vector2(320, 180)
	sig5_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	sig5_rect.stretch_mode = TextureRect.STRETCH_SCALE
	sig5_rect.modulate.a = 0.0
	sig5_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var glow: Texture2D = null
	if ResourceLoader.exists("res://Assets/particle-glow.png"):
		glow = load("res://Assets/particle-glow.png")
	if glow is Texture2D:
		sig5_rect.texture = glow
	trans_layer.add_child(sig5_rect)
	# ---- overlay node table + engine-prop bindings ----
	var hud_label: Label = _hud.hp_status_label()
	director.set_overlay_nodes({
		"vignette": _vignette,
		"death_vignette": _death_vignette,
		"screen_edge": _screen_edge,
		"overlay": _world_view.get_node_or_null("OverlayRect"),
		"flash": flash_rect,
		"class_tint": class_tint_rect,
		"sig5": sig5_rect,
		"banner": _world_view.get_node_or_null("BannerLabel"),
		"hp_status": hud_label,
		"hp_color_reset": func(c): _hud.set_hp_color(c),
	})
	for prop: String in _world_view.juice_bindings():
		director.bind(prop, _world_view.juice_bindings()[prop])
	for prop: String in _hud.juice_bindings():
		director.bind(prop, _hud.juice_bindings()[prop])
	director.bind("vignette.alpha", func(v): _vignette.color.a = float(v))
	director.bind("death_vignette.alpha", func(v): _death_vignette.color.a = float(v))
	director.bind("screen_edge.alpha", func(v): _screen_edge.color.a = float(v))
	director.bind("caption.y", func(v): _caption_band.position.y = 317.0 + float(v))
	director.bind("caption.alpha", func(v): _caption_band.modulate.a = float(v))
	# G9 caption lifecycle (AC-26/27/28): the director owns the in/hold/out
	# motion; the band stays the text + G3 two-second-minimum lane.
	if director.has_method("attach_caption"):
		director.attach_caption(func(key): _caption_band.show_key(key))
	_hud.juice_color_owned = true  # G9 SIG-1 owns the numeral color from here
	if _session != null:
		director.notify_snapshot(_session.snapshot())

func _make_overlay_rect(rect_name: String, color: Color, parent: Node) -> ColorRect:
	var rect: ColorRect = ColorRect.new()
	rect.name = rect_name
	rect.position = Vector2.ZERO
	rect.size = Vector2(640, 360)
	rect.color = Color(color.r, color.g, color.b, 0.0)
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(rect)
	return rect

func _exit_tree() -> void:
	if _director != null and is_instance_valid(_director) and _director.has_method("clear_screen"):
		_director.clear_screen()

func _physics_process(_delta: float) -> void:
	var ssm: Node = _ssm if _ssm != null else get_node_or_null("/root/SessionStateMachine")
	if ssm == null:
		is_playing = false
		return
	_session = ssm.session
	is_playing = ssm.current_state == StateEnums.State.PLAYING
	if not is_playing or _session == null:
		return
	_queue_inputs()
	# ---- project the post-step snapshot (main.gd stepped the rules first) ----
	var snapshot: Dictionary = _session.snapshot()
	var player: Dictionary = snapshot.get("player", {})
	hp = int(player.get("hp", 0))
	player_tile_x = int(round(float(player.get("pos_x", 0.0)) / TILE))
	player_tile_y = int(round(float(player.get("pos_y", 0.0)) / TILE))
	_world_view.render(snapshot)
	_hud.update_from_snapshot(snapshot)
	# why: G9 SIG-1/SIG-4/zone atmosphere — the director reads the rules
	# snapshot each fixed step (threshold bands, class identity, floor change)
	if _director != null and _director.has_method("notify_snapshot"):
		_director.notify_snapshot(snapshot)
	_caption_band.tick()
	_idle_prompts.tick(_session.tick, _idle_this_tick)

func _queue_inputs() -> void:
	# why: one semantic input batch per fixed tick; the SSM steps the session
	# with this batch on the next tick — deterministic, frame-rate independent
	var mv: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	_idle_this_tick = mv == Vector2.ZERO
	if mv != Vector2.ZERO:
		_session.input({"type": "move", "dx": mv.x, "dy": mv.y})
		_idle_prompts.report_action(true, false)
	# hold-to-auto-throw (G2 §1: hold = auto-throw on the real controller path)
	var held: bool = Input.is_action_pressed("hh_throw")
	if held and not _throw_held_last:
		_session.input({"type": "auto_fire_on"})
	elif not held and _throw_held_last:
		_session.input({"type": "auto_fire_off"})
	_throw_held_last = held

## InputMapper routes the throw press edge here (at most one per edge).
func throw_pressed() -> void:
	if not is_playing or _session == null:
		return
	shots_fired += 1
	_session.input({"type": "throw"})
	_idle_prompts.report_action(false, true)

func throw_released() -> void:
	if _session != null:
		_session.input({"type": "auto_fire_off"})

## InputMapper routes hh_potion — and B during play (G5 §8 exception).
func potion_pressed() -> void:
	if not is_playing or _session == null:
		return
	_session.input({"type": "potion"})

## G6 §3.3 presentation events → captions, world juice, director juice. Cues
## are drained by the SSM at the step chokepoint (CueBus dispatch precedes
## this call — the director's cue-side flags flip before the event side, per
## its SIG-3 exactly-once contract); only the event array arrives here.
func consume_events(events: Array) -> void:
	if _director != null and _director.has_method("consume_events"):
		_director.consume_events(events)
	if _world_view != null:
		_world_view.consume_events(events)
	for e in events:
		if not (e is Dictionary):
			continue
		_maybe_caption(str(e.get("type", "")))

## G2 tutorial ledger: first-event barks with caption mirror, floor 1 only.
func _maybe_caption(event_type: String) -> void:
	if _session == null or _session.floor_number != 1:
		return
	if _captioned_events.has(event_type):
		return
	var key: String = ""
	match event_type:
		"generator_destroyed":
			key = "caption.generator"
		"key_collected":
			key = "caption.key"
		"food_consumed":
			key = "caption.food"
		"floor_clear":
			key = "caption.cleared"
		_:
			return
	_captioned_events[event_type] = true
	# G9 AC-26/27/28: the director owns the caption motion lifecycle (in →
	# dwell → out); the band resolves the key and keeps the G3 hold floor.
	if _director != null and is_instance_valid(_director) and _director.has_method("play_caption"):
		_director.play_caption(key)
	else:
		_caption_band.show_key(key)
