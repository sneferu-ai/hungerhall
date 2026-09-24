extends RefCounted
## test_modals — modal transition logic via a MOCK router (G6 §3.4): mount/
## dismiss routing, pad_lost auto-pause + priority mount, and the
## floor-missing skip/return seam.

const State = StateEnums.State
const SceneId = StateEnums.SceneId

class MockRouter extends Node:
	var mounted: Array = []
	var hidden: Array = []
	# why: mount() creates bare Nodes; track them so teardown frees them
	# (round 7: two leaked modal Nodes surfaced as ObjectDB warnings)
	var created: Array = []
	func mount(id: int) -> Node:
		mounted.append(id)
		var n: Node = Node.new()
		n.name = "MockModal%d" % id
		created.append(n)
		return n
	func hide(id: int) -> void:
		hidden.append(id)
	func get_active_scene() -> Node:
		return null
	func on_state_changed(_s: int) -> void:
		pass

var _ssm: Node = null
var _router: MockRouter = null

func setup() -> void:
	_ssm = load("res://app/session_state_machine.gd").new()
	_ssm._ready()
	_router = MockRouter.new()
	_ssm.set_router(_router)
	_ssm.save_store.path_prefix = "t_modals_"

func teardown() -> void:
	if _ssm != null:
		_ssm.save_store.erase_all()
		_ssm.free()
		_ssm = null
	if _router != null:
		for n: Node in _router.created:
			if is_instance_valid(n):
				n.free()
		_router.created.clear()
		_router.free()
		_router = null

func test_mount_and_dismiss_route_through_router() -> Dictionary:
	var n: Node = _ssm.mount_modal(SceneId.MODAL_QUIT_WARN)
	if n == null:
		return {"ok": false, "msg": "mount_modal returned null"}
	if _router.mounted.size() != 1 or int(_router.mounted[0]) != SceneId.MODAL_QUIT_WARN:
		return {"ok": false, "msg": "router did not receive the mount: " + str(_router.mounted)}
	_ssm.dismiss_modal(SceneId.MODAL_QUIT_WARN)
	if _router.hidden.size() != 1 or int(_router.hidden[0]) != SceneId.MODAL_QUIT_WARN:
		return {"ok": false, "msg": "router did not receive the hide: " + str(_router.hidden)}
	return {"ok": true}

func test_pad_lost_auto_pauses_then_mounts() -> Dictionary:
	# why: G5 §1 — a vanished pad mid-run: PadLostAutoPause FIRST, then the
	# modal mounts over paused; modals never stack but pad_lost outranks all
	_ssm.boot()
	_ssm._change_state(State.PLAYING)
	_ssm.on_pad_lost()
	if _ssm.current_state != State.PAUSED:
		return {"ok": false, "msg": "pad_lost did not auto-pause (state %s)" % _ssm.state_name()}
	if _router.mounted.is_empty() or int(_router.mounted.back()) != SceneId.MODAL_PAD_LOST:
		return {"ok": false, "msg": "pad_lost modal not mounted: " + str(_router.mounted)}
	return {"ok": true}

func test_floor_missing_skip_advances_floor() -> Dictionary:
	# why: G5 §1 — a baked .tres that fails to load: F1–23 skip-forward
	_ssm.boot()
	var session: RulesSession = RulesSession.new()
	session.setup_campaign(_ssm.tunables, _ssm.get_class_def(0), 61)
	_ssm.session = session
	_ssm._change_state(State.PLAYING)
	var floor_before: int = session.floor_number
	_ssm.resolve_floor_missing(true)
	if session.floor_number != floor_before + 1:
		return {"ok": false, "msg": "skip-forward stayed on floor %d" % session.floor_number}
	if _ssm.current_state != State.PLAYING:
		return {"ok": false, "msg": "skip-forward left PLAYING (%s)" % _ssm.state_name()}
	return {"ok": true}

func test_floor_missing_f24_returns_title() -> Dictionary:
	_ssm.boot()
	var session: RulesSession = RulesSession.new()
	session.setup_campaign(_ssm.tunables, _ssm.get_class_def(0), 67)
	while session.floor_number < 24 and session.last_floor_load_ok:
		session.advance_floor()
	_ssm.session = session
	_ssm._change_state(State.PLAYING)
	_ssm.resolve_floor_missing(true)
	if _ssm.current_state != State.TITLE:
		return {"ok": false, "msg": "F24 skip must return to TITLE, got %s" % _ssm.state_name()}
	return {"ok": true}

func test_hall_caller_round_trip() -> Dictionary:
	# why: G5 §1 — hall_of_heroes returns to its CALLER, not always title
	_ssm.boot()
	_ssm._change_state(State.GAME_OVER)
	_ssm.try_transition(StateEnums.Verb.BACK)  # game_over → hall
	if _ssm.current_state != State.HALL_OF_HEROES:
		return {"ok": false, "msg": "hall not entered from game_over"}
	_ssm.leave_hall()
	if _ssm.current_state != State.GAME_OVER:
		return {"ok": false, "msg": "hall left to %s, expected caller GAME_OVER" % _ssm.state_name()}
	return {"ok": true}
