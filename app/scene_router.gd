class_name SceneRouter
extends Node
## HUNGERHALL — SceneRouter (G6 §2 app/scene_router.gd).
## @export scene_map: Dictionary (SceneId → PackedScene); mount(scene_id) /
## hide(scene_id) / current_scene_id; get_active_scene() → Node. Screens swap
## (journey node_absent assertions hold); modals overlay their parent in a
## stack and seize input (G5 §1: modals are not screens). No back-imports to
## screens/ — the router only knows PackedScenes and duck-typed methods.

const SceneId = StateEnums.SceneId
const State = StateEnums.State

@export var scene_map: Dictionary = {}

## Pinned scene paths (G6 §2 layout; screens authored under app/screens/).
const SCENE_PATHS: Dictionary = {
	SceneId.SPLASH: "res://app/screens/splash.tscn",
	SceneId.TITLE: "res://app/screens/title.tscn",
	SceneId.CLASS_SELECT: "res://app/screens/class_select.tscn",
	SceneId.PLAY: "res://app/screens/play.tscn",
	SceneId.PAUSED: "res://app/screens/paused.tscn",
	SceneId.SETTINGS: "res://app/screens/settings.tscn",
	SceneId.HALL_OF_HEROES: "res://app/screens/hall_of_heroes.tscn",
	SceneId.DYING: "res://app/screens/dying.tscn",
	SceneId.CONTINUE_OFFER: "res://app/screens/continue_offer.tscn",
	SceneId.GAME_OVER: "res://app/screens/game_over.tscn",
	SceneId.FLOOR_RESULTS: "res://app/screens/floor_results.tscn",
	SceneId.CAMPAIGN_RESULTS: "res://app/screens/campaign_results.tscn",
	SceneId.MODAL_QUIT_WARN: "res://app/screens/modals/quit_warn.tscn",
	SceneId.MODAL_NEWGAME_WARN: "res://app/screens/modals/newgame_warn.tscn",
	SceneId.MODAL_ERASE_WARN: "res://app/screens/modals/erase_warn.tscn",
	SceneId.MODAL_RESET_WARN: "res://app/screens/modals/reset_warn.tscn",
	SceneId.MODAL_REMAP_CAPTURE: "res://app/screens/modals/remap_capture.tscn",
	SceneId.MODAL_CREDITS_POP: "res://app/screens/modals/credits_pop.tscn",
	SceneId.MODAL_PRIVACY_POP: "res://app/screens/modals/privacy_pop.tscn",
	SceneId.MODAL_PAD_LOST: "res://app/screens/modals/pad_lost.tscn",
	SceneId.MODAL_SAVE_FAIL: "res://app/screens/modals/save_fail.tscn",
	SceneId.MODAL_FLOOR_MISSING: "res://app/screens/modals/floor_missing.tscn",
}

const STATE_TO_SCENE: Dictionary = {
	State.SPLASH: SceneId.SPLASH,
	State.TITLE: SceneId.TITLE,
	State.CLASS_SELECT: SceneId.CLASS_SELECT,
	State.PLAYING: SceneId.PLAY,
	State.PAUSED: SceneId.PAUSED,
	State.SETTINGS: SceneId.SETTINGS,
	State.HALL_OF_HEROES: SceneId.HALL_OF_HEROES,
	State.DYING: SceneId.DYING,
	State.CONTINUE_OFFER: SceneId.CONTINUE_OFFER,
	State.GAME_OVER: SceneId.GAME_OVER,
	State.FLOOR_RESULTS: SceneId.FLOOR_RESULTS,
	State.CAMPAIGN_RESULTS: SceneId.CAMPAIGN_RESULTS,
}

const MODAL_IDS: Array = [
	SceneId.MODAL_QUIT_WARN, SceneId.MODAL_NEWGAME_WARN, SceneId.MODAL_ERASE_WARN,
	SceneId.MODAL_RESET_WARN, SceneId.MODAL_REMAP_CAPTURE, SceneId.MODAL_CREDITS_POP,
	SceneId.MODAL_PRIVACY_POP, SceneId.MODAL_PAD_LOST, SceneId.MODAL_SAVE_FAIL,
	SceneId.MODAL_FLOOR_MISSING,
]

var current_scene_id: int = -1
var _active_screen: Node = null
var _modal_stack: Array = []
var _theme: Theme = null

func _ready() -> void:
	var loaded: Variant = load("res://ui/hungerhall_theme.tres")
	if loaded is Theme:
		_theme = loaded
	else:
		push_error("SceneRouter: ui/hungerhall_theme.tres failed to load")
	if scene_map.is_empty():
		_build_scene_map()

func _build_scene_map() -> void:
	for sid in SCENE_PATHS:
		var path: String = str(SCENE_PATHS[sid])
		if ResourceLoader.exists(path):
			var packed: Variant = load(path)
			if packed is PackedScene:
				scene_map[sid] = packed
			else:
				push_error("SceneRouter: not a PackedScene: " + path)
		else:
			push_error("SceneRouter: missing scene: " + path)

## SSM notification entry — maps session states to screen scenes.
func on_state_changed(new_state: int) -> void:
	var sid: int = int(STATE_TO_SCENE.get(new_state, -1))
	if sid >= 0:
		mount(sid)

## Instantiates the scene for scene_id. Screens replace the active screen;
## modals stack above it. Returns the mounted node (null on failure).
func mount(scene_id: int) -> Node:
	var packed: PackedScene = scene_map.get(scene_id, null)
	if packed == null:
		push_error("SceneRouter: mount failed — no PackedScene for SceneId %d" % scene_id)
		return null
	if MODAL_IDS.has(scene_id):
		return _mount_modal(scene_id, packed)
	return _mount_screen(scene_id, packed)

func _mount_screen(scene_id: int, packed: PackedScene) -> Node:
	# why: dismiss any open modals when the underlying screen changes
	_dismiss_all_modals()
	if _active_screen != null and is_instance_valid(_active_screen):
		_active_screen.queue_free()
		_active_screen = null
	var inst: Node = packed.instantiate()
	if inst is Control and _theme != null:
		(inst as Control).theme = _theme
	add_child(inst)
	_active_screen = inst
	current_scene_id = scene_id
	return inst

func _mount_modal(scene_id: int, packed: PackedScene) -> Node:
	# why: one modal at a time per parent in G5; a new mount supersedes
	for m in _modal_stack.duplicate():
		_remove_modal_node(m)
	var inst: Node = packed.instantiate()
	if inst is Control and _theme != null:
		(inst as Control).theme = _theme
	add_child(inst)
	_modal_stack.append({"id": scene_id, "node": inst})
	return inst

## Removes the scene registered under scene_id (modal dismiss).
func hide(scene_id: int) -> void:
	if not MODAL_IDS.has(scene_id):
		if current_scene_id == scene_id and _active_screen != null:
			_active_screen.queue_free()
			_active_screen = null
			current_scene_id = -1
		return
	for entry in _modal_stack.duplicate():
		if int(entry.id) == scene_id:
			_remove_modal_node(entry)

func _remove_modal_node(entry: Dictionary) -> void:
	_modal_stack.erase(entry)
	var node: Node = entry.get("node", null)
	if node != null and is_instance_valid(node):
		node.queue_free()

func _dismiss_all_modals() -> void:
	for entry in _modal_stack.duplicate():
		_remove_modal_node(entry)

func get_active_scene() -> Node:
	return _active_screen

func get_active_modal() -> Node:
	if _modal_stack.is_empty():
		return null
	return _modal_stack.back().get("node", null)

func get_active_modal_id() -> int:
	if _modal_stack.is_empty():
		return -1
	return int(_modal_stack.back().get("id", -1))

func get_current_screen_name() -> String:
	if _active_screen == null:
		return ""
	return str(_active_screen.name)
