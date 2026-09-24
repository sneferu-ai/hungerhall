class_name InputMapper
extends Node
## HUNGERHALL — InputMapper (G6 §1 + §2 app/input_mapper.gd).
## Resolves InputMap → semantic actions. sneferu_primary_action (the Space /
## accessibility binding) is resolved CONTEXTUALLY using
## SessionStateMachine.current_screen per the G6 §1 12-row table — it rides
## the real controller path, never a test-only branch. One physical press
## edge yields AT MOST ONE application transition (release latch + echo
## filter). Also owns joypad disconnect detection for pad_lost (G5 §1).
##
## Tree order is load-bearing: this node is authored FIRST under Main so its
## _input runs before every screen — set_input_as_handled() here suppresses
## the duplicate ui_accept/hh_throw fan-out that triple-bound bindings used
## to produce.

const State = StateEnums.State
const SceneId = StateEnums.SceneId

var _ssm: Node = null
var _router: SceneRouter = null
var _known_pads: Array = []
var _ever_connected_pad: bool = false
var _latched_actions: Dictionary = {}  # action → true until release

func _ready() -> void:
	_ssm = get_node_or_null("/root/SessionStateMachine")
	_router = get_node_or_null("../SceneRouter")
	_known_pads = Input.get_connected_joypads().duplicate()
	_ever_connected_pad = not _known_pads.is_empty()
	_apply_saved_bindings()

func set_ssm(ssm: Node) -> void:
	_ssm = ssm

func set_router(r: SceneRouter) -> void:
	_router = r

## Settings "bindings": {action: physical_keycode} — restore on boot.
func _apply_saved_bindings() -> void:
	var settings: Dictionary = {}
	if _ssm != null and "settings" in _ssm:
		settings = _ssm.settings
	var bindings: Variant = settings.get("bindings", {})
	if not (bindings is Dictionary):
		return
	for action in bindings:
		var keycode: int = int(bindings[action])
		if keycode <= 0 or not InputMap.has_action(action):
			continue
		# why: replace only the keyboard event; pad paths stay untouched
		var existing: InputEventKey = _first_key_event(action)
		if existing != null:
			InputMap.action_erase_event(action, existing)
		var ev: InputEventKey = InputEventKey.new()
		ev.physical_keycode = keycode
		InputMap.action_add_event(action, ev)

static func _first_key_event(action: String) -> InputEventKey:
	for ev in InputMap.action_get_events(action):
		if ev is InputEventKey:
			return ev
	return null

func _input(event: InputEvent) -> void:
	if event.is_echo():
		return  # why: auto-repeat is never a new press edge
	# why: G9 attract-mode law — ANY player input ends the title attract reel
	# ("false on any player input or state transition away from title"), even
	# an input the state machine does not transition on. Echoes were filtered
	# above, so this fires exactly once per real press edge.
	if _ssm != null and _ssm.has_method("note_player_input"):
		if event is InputEventKey or event is InputEventJoypadButton or event is InputEventJoypadMotion:
			if event.is_pressed():
				_ssm.note_player_input()
	# ---- modal-first routing (G5: a modal seizes input over its parent) ----
	var modal: Node = _router.get_active_modal() if _router != null else null
	if modal != null and is_instance_valid(modal):
		if modal.has_method("is_capturing") and modal.is_capturing():
			return  # remap_capture eats raw keys itself
		if event.is_action_pressed("sneferu_primary_action") or event.is_action_pressed("ui_accept"):
			if modal.has_method("primary_confirm"):
				modal.primary_confirm()
			get_viewport().set_input_as_handled()
			return
		if event.is_action_pressed("ui_cancel"):
			if modal.has_method("cancel"):
				modal.cancel()
			get_viewport().set_input_as_handled()
			return
		# why: everything else dies on the modal's floor
		if event is InputEventKey or event is InputEventJoypadButton:
			get_viewport().set_input_as_handled()
		return
	# ---- release latch bookkeeping ----
	# why: ui_accept MUST be in the erase list — _edge() latches it on press
	# (line below via _edge(event, "ui_accept")); without a release-erase it
	# fires exactly once per process and every later Enter/A press is dead
	# (title→class_select worked, DESCEND via Enter never did).
	for action in ["sneferu_primary_action", "hh_throw", "hh_potion", "hh_pause", "ui_cancel", "ui_accept"]:
		if event.is_action_released(action):
			_latched_actions.erase(action)
	# ---- the 12-row contextual resolution table (G6 §1) ----
	if _ssm == null:
		return
	var screen: int = int(_ssm.current_screen)
	match screen:
		State.SPLASH:
			if _edge(event, "sneferu_primary_action") or _edge(event, "ui_accept"):
				_ssm.mark_splash_input()
				_ssm.try_transition(StateEnums.Verb.PRESS)
				_consume(event)
		State.TITLE, State.CLASS_SELECT, State.GAME_OVER, State.CAMPAIGN_RESULTS:
			if _edge(event, "sneferu_primary_action") or _edge(event, "ui_accept"):
				_forward_screen("primary_confirm")
				_consume(event)
			elif _edge(event, "ui_cancel"):
				_forward_screen("back_pressed")
				_consume(event)
		State.PLAYING:
			if _edge(event, "hh_throw"):
				_forward_screen("throw_pressed")
				_consume(event)
			elif event.is_action_released("hh_throw"):
				_forward_screen("throw_released")
			elif _edge(event, "hh_potion") or _edge(event, "ui_cancel"):
				# why: G5 §8 B-exception — B is Potion during play, not Back
				_forward_screen("potion_pressed")
				_consume(event)
			elif _edge(event, "hh_pause"):
				_ssm.try_transition(StateEnums.Verb.PAUSE)
				_consume(event)
			elif _edge(event, "sneferu_primary_action"):
				# why: the accessibility binding resolves to throw in play
				_forward_screen("throw_pressed")
				_consume(event)
		State.PAUSED:
			if _edge(event, "hh_pause") or _edge(event, "sneferu_primary_action") or _edge(event, "ui_accept"):
				_forward_screen("resume_pressed")
				_consume(event)
			elif _edge(event, "ui_cancel"):
				# why: G5 paused.Back = ResumeChosen (exception B=Resume)
				_forward_screen("resume_pressed")
				_consume(event)
		State.SETTINGS:
			if _edge(event, "ui_cancel"):
				_forward_screen("back_pressed")
				_consume(event)
		State.HALL_OF_HEROES:
			if _edge(event, "sneferu_primary_action") or _edge(event, "ui_accept") or _edge(event, "ui_cancel"):
				# why: G6 §1 row 7 — primary action here is "back"
				_forward_screen("back_pressed")
				_consume(event)
		State.DYING:
			pass  # row 8: non-interactive
		State.CONTINUE_OFFER:
			if _edge(event, "sneferu_primary_action") or _edge(event, "ui_accept"):
				_forward_screen("primary_confirm")
				_consume(event)
			elif _edge(event, "ui_cancel"):
				# why: G5 continue_offer.Back = no, no warn
				_forward_screen("choose_no")
				_consume(event)
		State.FLOOR_RESULTS:
			if _edge(event, "sneferu_primary_action") or _edge(event, "ui_accept") or _edge(event, "ui_cancel"):
				# why: G6 §1 row 11 — primary action here is "advance";
				# G5 floor_results.Back = SaveQuit, no warn (same seam)
				_forward_screen("advance_pressed")
				_consume(event)
		_:
			pass

## Press-edge test with the release latch: one physical press = one dispatch.
func _edge(event: InputEvent, action: String) -> bool:
	if not event.is_action_pressed(action):
		return false
	if _latched_actions.has(action):
		return false
	_latched_actions[action] = true
	return true

func _consume(event: InputEvent) -> void:
	get_viewport().set_input_as_handled()

func _forward_screen(method_name: String) -> void:
	if _router == null:
		return
	var screen: Node = _router.get_active_scene()
	if screen != null and is_instance_valid(screen) and screen.has_method(method_name):
		screen.call(method_name)

## ---- joypad disconnect (pad_lost) ----

func _physics_process(_delta: float) -> void:
	var pads: Array = Input.get_connected_joypads()
	if pads.size() > _known_pads.size() or (pads.size() > 0 and _known_pads.is_empty()):
		if not pads.is_empty():
			_ever_connected_pad = true
	if _ever_connected_pad and not _known_pads.is_empty() and pads.is_empty():
		if _ssm != null:
			_ssm.on_pad_lost()
	if _router != null:
		var modal: Node = _router.get_active_modal()
		if modal != null and is_instance_valid(modal) and modal.has_method("on_pad_reconnected"):
			if _router.get_active_modal_id() == SceneId.MODAL_PAD_LOST and not pads.is_empty():
				modal.on_pad_reconnected()
	_known_pads = pads.duplicate()
