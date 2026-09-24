extends RefCounted
## test_state_machine — all 12 states, the splash/step counters, LAR-3 retry,
## Title→Settings→caller routing, and the pin for the "to"-key consumer.
## The SSM is instantiated as a REGULAR Node (G6 §3.4: no autoloads in the
## runner) and driven through tick_once() directly.

const State = StateEnums.State
const Verb = StateEnums.Verb

var _ssm: Node = null
var _prefix: String = "t_sm_"

func _make_ssm() -> Node:
	var ssm: Node = load("res://app/session_state_machine.gd").new()
	# why: not in the tree under the runner — call _ready() by hand so
	# tunables/classes/settings/stores initialize exactly like production
	ssm._ready()
	ssm.save_store.path_prefix = _prefix
	return ssm

func setup() -> void:
	_ssm = _make_ssm()

func teardown() -> void:
	if _ssm != null:
		_ssm.save_store.erase_all()
		_ssm.free()
		_ssm = null

func test_boot_lands_splash() -> Dictionary:
	_ssm.boot()
	if _ssm.current_state != State.SPLASH:
		return {"ok": false, "msg": "boot landed on %s" % _ssm.state_name()}
	return {"ok": true}

func test_splash_72_ticks_to_title() -> Dictionary:
	_ssm.boot()
	for i in range(71):
		_ssm.tick_once()
	if _ssm.current_state != State.SPLASH:
		return {"ok": false, "msg": "splash left early at tick 71"}
	_ssm.tick_once()
	if _ssm.current_state != State.TITLE:
		return {"ok": false, "msg": "tick 72 landed on %s, expected TITLE" % _ssm.state_name()}
	return {"ok": true}

func test_splash_skip_needs_input_and_18_ticks() -> Dictionary:
	_ssm.boot()
	for i in range(17):
		_ssm.tick_once()
	_ssm.mark_splash_input()
	if _ssm.try_transition(Verb.PRESS):
		return {"ok": false, "msg": "skip armed before the 18-step floor"}
	_ssm.tick_once()
	if not _ssm.try_transition(Verb.PRESS):
		return {"ok": false, "msg": "skip refused at 18 ticks with input received"}
	if _ssm.current_state != State.TITLE:
		return {"ok": false, "msg": "skip landed on %s" % _ssm.state_name()}
	return {"ok": true}

func test_title_to_settings_and_back_to_title() -> Dictionary:
	_ssm.boot()
	_ssm._change_state(State.TITLE)
	if not _ssm.try_transition(Verb.SETTINGS):
		return {"ok": false, "msg": "Title→Settings refused"}
	if _ssm.current_state != State.SETTINGS:
		return {"ok": false, "msg": "SETTINGS verb landed on %s" % _ssm.state_name()}
	if not _ssm.try_transition(Verb.BACK):
		return {"ok": false, "msg": "Settings Back refused"}
	if _ssm.current_state != State.TITLE:
		return {"ok": false, "msg": "Back from title-entered settings landed on %s (entered_from routing)" % _ssm.state_name()}
	return {"ok": true}

func test_paused_settings_back_returns_to_paused() -> Dictionary:
	_ssm.boot()
	_ssm.session = _make_session()
	_ssm._change_state(State.PLAYING)
	_ssm.try_transition(Verb.PAUSE)
	if _ssm.current_state != State.PAUSED:
		return {"ok": false, "msg": "pause refused"}
	_ssm.try_transition(Verb.SETTINGS)
	_ssm.try_transition(Verb.BACK)
	if _ssm.current_state != State.PAUSED:
		return {"ok": false, "msg": "Back from paused-entered settings landed on %s" % _ssm.state_name()}
	return {"ok": true}

## THE pin for app/session_state_machine.gd try_transition: transition rows
## are keyed "to" (core/transition_table.gd). Round 4 read "to_state", every
## transition silently self-looped, and the journey gate saw passed_steps 0/4.
func test_transition_reads_to_key_not_self_loop() -> Dictionary:
	_ssm.boot()
	_ssm.session = _make_session()
	_ssm._change_state(State.PLAYING)
	_ssm.session.exit_overlap_frames = 3
	if not _ssm.try_transition(Verb.CLEAR):
		return {"ok": false, "msg": "CLEAR refused with exit_overlap 3 on floor 1"}
	if _ssm.current_state != State.FLOOR_RESULTS:
		return {"ok": false, "msg": "CLEAR landed on %s — a self-loop means the 'to' key is not being read" % _ssm.state_name()}
	return {"ok": true}

func test_floor_results_autosave_fires_once() -> Dictionary:
	# why: G5 Persistence Declaration — the campaign file is written exactly at
	# FLOOR_RESULTS entry, never mid-floor (the store split made this app/ I/O)
	_ssm.boot()
	_ssm.session = _make_session()
	_ssm._change_state(State.PLAYING)
	for i in range(10):
		_ssm.tick_once()
	if _ssm.save_store.save_exists():
		return {"ok": false, "msg": "campaign save written MID-FLOOR"}
	_ssm.session.exit_overlap_frames = 3
	_ssm.try_transition(Verb.CLEAR)
	if not _ssm.save_store.save_exists():
		return {"ok": false, "msg": "autosave did not fire on FLOOR_RESULTS entry"}
	var save: Dictionary = _ssm.save_store.read_campaign()
	if int(save.get("floor", 0)) != 2:
		return {"ok": false, "msg": "autosave must record the NEXT floor (2), got %s" % str(save.get("floor"))}
	return {"ok": true}

func test_lar3_game_over_retry_floor() -> Dictionary:
	# why: G5 LAR-3 — GAME_OVER → RETRY restarts the failed floor
	_ssm.boot()
	_ssm.session = _make_session()
	_ssm._change_state(State.GAME_OVER)
	if not _ssm.try_transition(Verb.RETRY):
		return {"ok": false, "msg": "RETRY refused from GAME_OVER"}
	if _ssm.current_state != State.PLAYING:
		return {"ok": false, "msg": "RETRY landed on %s" % _ssm.state_name()}
	return {"ok": true}

func test_zero_token_continue_expires_to_game_over() -> Dictionary:
	_ssm.boot()
	_ssm.session = _make_session()
	_ssm.session.continue_state.tokens = 0
	_ssm._change_state(State.CONTINUE_OFFER)
	for i in range(119):
		_ssm.tick_once()
	if _ssm.current_state != State.CONTINUE_OFFER:
		return {"ok": false, "msg": "zero-token offer left before the 120-step hold"}
	_ssm.tick_once()
	if _ssm.current_state != State.GAME_OVER:
		return {"ok": false, "msg": "zero-token expire landed on %s" % _ssm.state_name()}
	return {"ok": true}

func test_all_12_states_named() -> Dictionary:
	# why: the state enum has exactly 12 screens; a rename silently breaks the
	# scene_map keys if the SSM's name table drifts
	var names: Array = ["SPLASH","TITLE","CLASS_SELECT","PLAYING","PAUSED","SETTINGS","HALL_OF_HEROES","DYING","CONTINUE_OFFER","GAME_OVER","FLOOR_RESULTS","CAMPAIGN_RESULTS"]
	for n in names:
		if not State.has(n):
			return {"ok": false, "msg": "State enum missing %s" % n}
	if State.size() != 12:
		return {"ok": false, "msg": "State enum has %d entries, expected 12" % State.size()}
	return {"ok": true}

func _make_session() -> RulesSession:
	var s: RulesSession = RulesSession.new()
	s.setup_campaign(_ssm.tunables, _ssm.get_class_def(0), 42)
	return s
