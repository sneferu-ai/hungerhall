extends Node
## HUNGERHALL — SessionStateMachine autoload (G6 §2 app/session_state_machine.gd).
## The one app-layer state machine. Reads core/transition_table, evaluates the
## G6 §3.2 condition predicates (REAL — no stubbed-true shortcuts), counts
## splash/dying/continue steps at fixed 60Hz, steps the rules session exactly
## once per physics tick, and notifies the SceneRouter. No class_name
## (OBL-55: this script is an autoload; a global class name registration for
## "SessionStateMachine" would collide with the autoload node name).

const State = StateEnums.State
const Verb = StateEnums.Verb
const SceneId = StateEnums.SceneId

## Step-count contracts (G5 §1 / G6 §3.1, fixed 60Hz):
const SPLASH_TOTAL_STEPS: int = 72    # 1.2s splash mark
const SPLASH_SKIP_STEPS: int = 18     # 300ms skippable-on-input floor
const DYING_STEPS: int = 72           # crumble hold
const DYING_STEPS_REDUCED: int = 12   # reduced-motion crumble (LAR-4)
const CONTINUE_RING_STEPS: int = 600  # 10s ring
const CONTINUE_GRACE_STEPS: int = 18  # 300ms input-suppression grace (G5 DIS-9)
const ZERO_TOKEN_HOLD_STEPS: int = 120  # "No continues" 2s hold (G2 §2)
const DEFOCUS_GRACE_TICKS: int = 120  # why: headless harnesses report spurious focus loss at boot

signal state_changed(old_state: int, new_state: int)

var current_state: int = State.SPLASH
var previous_state: int = State.SPLASH
var entered_from: int = -1
var _last_verb: int = -1

## G9 §attract-mode detection (LOCKED): "Set true on title enter, false on any
## player input or state transition away from title." JuiceDirector reads this
## flag via its state_machine_path NodePath binding (juice/juice_director.gd
## _in_attract_mode) to suppress the floor-clear presentation (SIG-5 caption/
## banner/hitstop/SIG5BorderRect/darken/camera) while the title attract reel
## plays — G9 §9. Attract mode is title-screen-only; pause is not reachable
## during attract (player input exits attract before any game state).
var attract_mode: bool = false

## The 12-row contextual resolution table names current_screen — alias of the
## state (every state in the table is a screen; modals are not screens).
var current_screen: int:
	get:
		return current_state

var session: RulesSession = null
## The four app/ store Nodes (G6 §2) — setter-injected by the composition root
## (main.gd); core/save_codec.gd stays pure dict encode/decode/migrate, all
## file I/O and wall-clock timestamps live in the stores.
var save_store: SaveStore = null
var profile_store: ProfileStore = null
var score_store: ScoreStore = null
var settings_store: SettingsStore = null
var settings: Dictionary = {}
var class_index: int = 0
var tunables: TunablesLoader = null
var classes: Array = []
var campaign_seed: int = 42

## why: duck-typed on purpose — the SSM only calls mount/hide/get_active_scene/
## on_state_changed, and suites drive it with mock routers (G6 §3.4: no
## autoloads, mock router) that are Nodes, not SceneRouter subclasses.
var _router: Node = null
var _cue_bus: CueBus = null

## Step counters — all presentation timing lives here, counted per fixed tick.
var _splash_step_count: int = 0
var _splash_input_received: bool = false
var _dying_step_count: int = 0
var _continue_step_count: int = 0
var _continue_decision: String = ""
var _hall_caller: int = State.TITLE
var _banked_score: int = 0
var _floor_start_tick: int = 0
var last_autosave_ok: bool = true
var _autosave_written_once: bool = false

func _ready() -> void:
	_ensure_stores()
	tunables = TunablesLoader.new()
	if not tunables.load_from_path("res://Tunables.json"):
		push_error("SessionStateMachine: failed to load Tunables.json: "
			+ "; ".join(tunables.get_errors()))
	classes = ClassDef.build_all(tunables)
	settings = settings_store.read_settings()

## why: composition root injects the authored Main children; tests and
## headless suites that instantiate the SSM bare get self-owned stores —
## the I/O stays in app/ either way.
func _ensure_stores() -> void:
	if save_store == null:
		save_store = SaveStore.new()
	if profile_store == null:
		profile_store = ProfileStore.new()
		profile_store.set_save_store(save_store)
	if score_store == null:
		score_store = ScoreStore.new()
		score_store.set_save_store(save_store)
	if settings_store == null:
		settings_store = SettingsStore.new()
		settings_store.set_save_store(save_store)

func set_save_store(s: SaveStore) -> void:
	var old: SaveStore = save_store
	save_store = s
	if old != null and old != s and not old.is_inside_tree():
		# why: the other three self-owned stores captured the OLD save_store in
		# _ensure_stores; repoint any surviving dependent BEFORE freeing old so
		# a partially-injected composition root can never hold a dangling
		# reference (an injected in-tree dependent was already repointed by
		# main.gd and is skipped by the is_inside_tree guard).
		if profile_store != null and not profile_store.is_inside_tree():
			profile_store.set_save_store(s)
		if score_store != null and not score_store.is_inside_tree():
			score_store.set_save_store(s)
		if settings_store != null and not settings_store.is_inside_tree():
			settings_store.set_save_store(s)
		old.free()

func set_profile_store(p: ProfileStore) -> void:
	var old: ProfileStore = profile_store
	profile_store = p
	_free_orphan_store(old, p)

func set_score_store(s: ScoreStore) -> void:
	var old: ScoreStore = score_store
	score_store = s
	_free_orphan_store(old, s)

func set_settings_store(s: SettingsStore) -> void:
	var old: SettingsStore = settings_store
	settings_store = s
	_free_orphan_store(old, s)

## why: the autoload _ready runs BEFORE the main scene, so _ensure_stores
## created self-owned fallback stores via .new(); when the composition root
## (main.gd:45-59) injects the authored Main children, the replaced orphans
## must be freed explicitly — Nodes are NOT refcounted, and unparented Nodes
## leaked at exit as the round-6 gate product_fail ("4 resources still in
## use" = the four store GDScripts pinned by the leaked Nodes, "9 ObjectDB
## instances leaked" = 4 store Nodes + 4 GDScripts + 1 GDScriptNativeClass).
## Authored in-tree children are NEVER freed (is_inside_tree guard), and a
## same-instance re-injection is a no-op, so this cannot double-free.
func _free_orphan_store(old: Node, replacement: Node) -> void:
	if old == null or old == replacement:
		return
	if not is_instance_valid(old) or old.is_inside_tree():
		return
	old.free()

## why: cover the paths where no composition root ever injects — script-mode
## runs (the test runner loads this autoload; main.tscn never mounts, so the
## self-owned stores live until process exit) and bare Node instantiation in
## suites (test_state_machine frees the SSM directly). NOTIFICATION_PREDELETE
## fires on free()/memdelete even for nodes never added to a tree, where
## _exit_tree would never run. In-tree authored stores are skipped, and
## orphans already freed by the setters are no longer referenced — guarded
## no-op, never a double-free.
func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		# why: UNTYPED loop on purpose — a teardown may free an injected store
		# before freeing the SSM (test_save does exactly this); a typed
		# Array[Node] iteration rejects the freed reference with a TypedArray
		# validation ERROR and aborts the loop, leaking the remaining stores.
		var owned: Array = [save_store, profile_store, score_store, settings_store]
		for store in owned:
			if store != null and is_instance_valid(store) and not store.is_inside_tree():
				store.free()

func set_router(r: Node) -> void:
	_router = r

func set_cue_bus(c: CueBus) -> void:
	_cue_bus = c

## Composition-root call: splash first, always. The 72-step mark and the
## 18-step skip floor are counted in tick_once — boot never skips ahead.
func boot() -> void:
	_splash_step_count = 0
	_splash_input_received = false
	_change_state(State.SPLASH)

## THE fixed-60Hz heartbeat. main.gd calls this once per _physics_process in
## production; tests drive it directly (G6 §2 EARS contract — no rule state
## depends on wall-clock or frame rate).
func tick_once() -> void:
	match current_state:
		State.SPLASH:
			_splash_step_count += 1
			if _splash_step_count >= SPLASH_TOTAL_STEPS:
				try_transition(Verb.PRESS)
		State.PLAYING:
			if session != null:
				session.step()
				_drain_pending()
				_sync_from_session_state()
		State.DYING:
			# why: SSM owns the crumble timing (G5 §1 — step-counted in SSM);
			# the session is NOT stepped here so core timers cannot double-drive
			_dying_step_count += 1
			if _dying_step_count >= dying_steps_needed():
				try_transition(Verb.PROMPT)
		State.CONTINUE_OFFER:
			_continue_step_count += 1
			var tokens: int = session.continue_state.tokens if session != null else 0
			if tokens <= 0:
				if _continue_step_count >= ZERO_TOKEN_HOLD_STEPS:
					try_transition(Verb.EXPIRE)
			elif _continue_step_count >= CONTINUE_RING_STEPS:
				_continue_decision = "timeout"
				try_transition(Verb.EXPIRE)
		_:
			pass

func dying_steps_needed() -> int:
	return DYING_STEPS_REDUCED if reduced_motion_enabled() else DYING_STEPS

func reduced_motion_enabled() -> bool:
	return bool(settings.get("reduced_motion", false))

func continue_grace_active() -> bool:
	return _continue_step_count < CONTINUE_GRACE_STEPS

## G6 §3.2 predicates — evaluated for real against counters and session state.
func _evaluate_condition(cond: String) -> bool:
	match cond:
		"splash_complete_or_skippable":
			return _splash_step_count >= SPLASH_TOTAL_STEPS \
				or (_splash_input_received and _splash_step_count >= SPLASH_SKIP_STEPS)
		"save_exists":
			return _save_exists()
		"no_save":
			return not _save_exists()
		"hp_zero":
			return session != null and session.player.hp <= 0
		"exit_overlap_3 AND floor_lt_24":
			return session != null and session.exit_overlap_frames >= 3 and session.floor_number < 24
		"exit_overlap_3 AND floor_eq_24":
			return session != null and session.exit_overlap_frames >= 3 and session.floor_number >= 24
		"tokens_gt_0 AND yes":
			return session != null and session.continue_state.tokens > 0 and _continue_decision == "yes"
		"no OR timeout OR tokens_eq_0":
			return _continue_decision == "no" or _continue_decision == "timeout" \
				or _continue_step_count >= CONTINUE_RING_STEPS \
				or (session != null and session.continue_state.tokens <= 0)
		"dying_complete":
			return _dying_step_count >= dying_steps_needed()
		"entered_from_paused":
			return entered_from == State.PAUSED
		"entered_from_title":
			return entered_from == State.TITLE
		"always":
			return true
		"":
			return true
		_:
			push_error("SessionStateMachine: unknown condition '%s'" % cond)
			return false

func try_transition(verb: int) -> bool:
	# why: (from, verb) keys are CONDITION-AMBIGUOUS in the table — SETTINGS+
	# BACK has two rows (entered_from_paused / entered_from_title). The round-6
	# find_transition returned only the FIRST row, so Settings-Back from TITLE
	# evaluated the paused-route condition, failed, and never reached the
	# title-route row ("Settings Back refused"). Every candidate row must be
	# tried in table order until one condition passes.
	var candidates: Array = TransitionTable.find_all_transitions(current_state, verb)
	if candidates.is_empty():
		return false
	var t: Dictionary = {}
	for row: Dictionary in candidates:
		if _evaluate_condition(str(row.get("condition", ""))):
			t = row
			break
	if t.is_empty():
		return false
	_last_verb = verb
	# why: settings Back routes to caller (G6 §3.2 entered_from predicates)
	if current_state == State.TITLE or current_state == State.PAUSED:
		entered_from = current_state
	# why: transition rows are keyed "to" (core/transition_table.gd:9) — round 4
	# read "to_state", so Dictionary.get fell back to current_state and EVERY
	# transition silently self-looped (journey passed_steps 0/4). The consumer
	# must read the producer's key; tests/test_state_machine.gd pins this side.
	_change_state(int(t.get("to", current_state)))
	return true

func _change_state(new_state: int) -> void:
	previous_state = current_state
	current_state = new_state
	# why: G9 attract-mode law — true on title enter, false on ANY transition
	# away from title. The other half (false on any player input, even one
	# that does not transition) rides note_player_input() from InputMapper.
	if new_state == State.TITLE:
		attract_mode = true
	elif previous_state == State.TITLE:
		attract_mode = false
	_on_state_entered(new_state)
	state_changed.emit(previous_state, new_state)
	if _router != null:
		_router.on_state_changed(new_state)

## G9: "false on any player input" — InputMapper routes every non-echo press
## edge through here BEFORE dispatch, so an input that produces no transition
## (e.g. a movement key on the title screen) still ends the attract reel.
func note_player_input() -> void:
	if attract_mode:
		attract_mode = false

func _on_state_entered(new_state: int) -> void:
	match new_state:
		State.SPLASH:
			_splash_step_count = 0
		State.TITLE:
			pass
		State.PLAYING:
			_on_enter_playing()
		State.DYING:
			_dying_step_count = 0
			if session != null:
				session.state = State.DYING
		State.CONTINUE_OFFER:
			_continue_step_count = 0
			_continue_decision = ""
			if session != null:
				session.state = State.CONTINUE_OFFER
		State.GAME_OVER:
			if session != null:
				session.state = State.GAME_OVER
		State.FLOOR_RESULTS:
			_banked_score = int(session.score.score) if session != null else _banked_score
			_autosave_campaign()
		State.CAMPAIGN_RESULTS:
			_banked_score = int(session.score.score) if session != null else _banked_score
			_record_campaign_clear()
		State.HALL_OF_HEROES:
			_hall_caller = previous_state
		_:
			pass

func _on_enter_playing() -> void:
	if session == null:
		return
	if not session.last_floor_load_ok:
		# why: G5 §1 floor-missing seam — a baked .tres that failed to load is
		# never a silent blank floor; mount the modal (skip-forward / title)
		mount_modal(SceneId.MODAL_FLOOR_MISSING)
		return
	match _last_verb:
		Verb.CONTINUE:
			# predicate already proved tokens > 0 and decision "yes"
			if session != null:
				session.continue_decision = "yes"
				session.continue_floor()
		Verb.RETRY:
			session.retry_floor()
		Verb.ADVANCE:
			session.advance_floor()
		Verb.RESUME, Verb.CONFIRM:
			if previous_state == State.TITLE:
				_load_from_save()
		_:
			pass
	_floor_start_tick = session.tick

## G2 §6 / §490 — "save_exists" means read_campaign returns usable data:
## present, parseable, current version. A stale-version file is "no save"
## (fresh start with notification), matching SaveCodec.migrate_campaign.
func _save_exists() -> bool:
	var save: Dictionary = save_store.read_campaign()
	return not save.is_empty() and not save.has("_stale_version")

## title.ContinueChosen — loads the next unfinished floor: full HP, 2 tokens,
## potions as last floor ended (G5 §1).
func _load_from_save() -> void:
	var save: Dictionary = save_store.read_campaign()
	if save.is_empty() or save.has("_stale_version"):
		return
	# why: the campaign save stores the class KEY string ("warrior") per
	# save_schema.json — int() on that string silently read 0 (always Warrior)
	class_index = _class_index_for(str(save.get("class", "warrior")))
	var cd: ClassDef = get_class_def(class_index)
	session = RulesSession.new()
	session.setup_campaign(tunables, cd, campaign_seed)
	var target_floor: int = clampi(int(save.get("floor", 1)), 1, 24)
	# why: a completed campaign (floor 25) replays the last floor rather than
	# tripping advance_floor's campaign-results branch mid-load; a baked-floor
	# load failure aborts the climb (the floor-missing seam handles it)
	while session.floor_number < target_floor and session.last_floor_load_ok:
		session.advance_floor()
	session.score.score = int(save.get("score", 0))
	session.player.potions = int(save.get("potions_remaining", 0))
	session.player.hp = session.player.max_hp
	session.state = StateEnums.State.PLAYING

## The death/clear sync — the core session transitions itself out of PLAYING;
## the SSM mirrors it through the real transition table.
func _sync_from_session_state() -> void:
	if session == null:
		return
	match session.state:
		State.DYING:
			if current_state == State.PLAYING:
				try_transition(Verb.DRAIN)
		State.FLOOR_RESULTS:
			if current_state == State.PLAYING:
				try_transition(Verb.CLEAR)
		State.CAMPAIGN_RESULTS:
			if current_state == State.PLAYING:
				try_transition(Verb.FINISH)
		_:
			pass

func _drain_pending() -> void:
	if session == null:
		return
	var pending: Dictionary = session.consume_pending()
	if _cue_bus != null:
		_cue_bus.emit_from_pending(pending)
	if _router != null:
		var screen: Node = _router.get_active_scene()
		if screen != null and screen.has_method("consume_events"):
			screen.consume_events(pending.get("events", []))

## InputMapper reports any input during splash so the skip floor can arm.
func mark_splash_input() -> void:
	if current_state == State.SPLASH:
		_splash_input_received = true

## ContinueOfferScreen routes its yes/no here (grate-gated per G5 DIS-9).
func choose_continue(yes: bool) -> void:
	if current_state != State.CONTINUE_OFFER or continue_grace_active():
		return
	if yes:
		if session == null or session.continue_state.tokens <= 0:
			return
		_continue_decision = "yes"
		try_transition(Verb.CONTINUE)
	else:
		_continue_decision = "no"
		try_transition(Verb.EXPIRE)

## G5 Persistence Declaration: the campaign save is written in exactly ONE
## place — entry into floor_results — atomically by the SaveStore.
func _autosave_campaign() -> void:
	if session == null:
		return
	var data: Dictionary = {
		"floor": session.floor_number + 1,
		"class": session.hero_name,
		"score": int(session.score.score),
		"potions_remaining": int(session.player.potions),
	}
	last_autosave_ok = save_store.write_campaign(data)
	_autosave_written_once = true
	if not last_autosave_ok:
		mount_modal(SceneId.MODAL_SAVE_FAIL)

## SaveFailModal retry seam (G5: up to 3 retries, 0.1s apart).
func retry_autosave() -> bool:
	if session == null:
		return false
	var data: Dictionary = {
		"floor": session.floor_number + 1,
		"class": session.hero_name,
		"score": int(session.score.score),
		"potions_remaining": int(session.player.potions),
	}
	last_autosave_ok = save_store.write_campaign(data)
	return last_autosave_ok

func _record_campaign_clear() -> void:
	# why: the profile ledger is the ProfileStore's domain (classes_cleared is
	# an ARRAY of class keys; the round-5 int-increment shape never matched it)
	if not profile_store.record_campaign_clear(class_key(class_index)):
		push_error("SessionStateMachine: profile write failed at campaign clear")

func banked_score() -> int:
	return _banked_score

func floor_start_tick() -> int:
	return _floor_start_tick

## ---- start / select ----

func start_new_game(selected_class: int) -> void:
	class_index = selected_class
	var cd: ClassDef = get_class_def(selected_class)
	session = RulesSession.new()
	session.setup_campaign(tunables, cd, campaign_seed)
	_banked_score = 0
	_floor_start_tick = 0

func get_class_def(idx: int) -> ClassDef:
	if idx < 0 or idx >= classes.size():
		return classes[0]
	return classes[idx]

func class_key(idx: int) -> String:
	# why: G3 class_variants keys are warrior/valkyrie/wizard/elf
	match idx:
		0: return "warrior"
		1: return "valkyrie"
		2: return "wizard"
		_: return "elf"

func _class_index_for(key: String) -> int:
	match key.to_lower():
		"warrior": return 0
		"valkyrie": return 1
		"wizard": return 2
		"elf": return 3
		_: return 0

func state_name() -> String:
	match current_state:
		State.SPLASH: return "SPLASH"
		State.TITLE: return "TITLE"
		State.CLASS_SELECT: return "CLASS_SELECT"
		State.PLAYING: return "PLAYING"
		State.PAUSED: return "PAUSED"
		State.SETTINGS: return "SETTINGS"
		State.HALL_OF_HEROES: return "HALL_OF_HEROES"
		State.DYING: return "DYING"
		State.CONTINUE_OFFER: return "CONTINUE_OFFER"
		State.GAME_OVER: return "GAME_OVER"
		State.FLOOR_RESULTS: return "FLOOR_RESULTS"
		State.CAMPAIGN_RESULTS: return "CAMPAIGN_RESULTS"
		_: return "UNKNOWN"

## ---- modals ----

func mount_modal(modal_scene_id: int) -> Node:
	if _router == null:
		return null
	return _router.mount(modal_scene_id)

func dismiss_modal(modal_scene_id: int) -> void:
	if _router != null:
		_router.hide(modal_scene_id)

## ---- hall caller (G5 §1: hall_of_heroes → caller on BackOut) ----

func leave_hall() -> void:
	if current_state != State.HALL_OF_HEROES:
		return
	_last_verb = Verb.BACK
	_change_state(_hall_caller)

## ---- interruptions ----

## InputMapper: a connected pad vanished mid-run. Auto-pause first, then the
## pad_lost modal mounts over paused (G5 §1).
func on_pad_lost() -> void:
	if current_state == State.PLAYING:
		try_transition(Verb.PAUSE)
	if current_state == State.PAUSED:
		mount_modal(SceneId.MODAL_PAD_LOST)

## G5 §1 WindowDefocused → paused. Grace period: headless/CI harnesses report
## spurious focus loss at boot (// why: DEFOCUS_GRACE_TICKS, not a skip).
func on_window_defocus() -> void:
	if current_state == State.PLAYING and session != null and session.tick > DEFOCUS_GRACE_TICKS:
		try_transition(Verb.PAUSE)

## FloorMissingModal seam — when a baked .tres fails to load (post-baker):
## F1–23 skip-forward, F24 back to title (G5 §1).
func resolve_floor_missing(skip: bool) -> void:
	dismiss_modal(SceneId.MODAL_FLOOR_MISSING)
	if session == null:
		_change_state(State.TITLE)
		return
	if not skip or session.floor_number >= 24:
		_change_state(State.TITLE)
		return
	session.advance_floor()
	_change_state(State.PLAYING)
