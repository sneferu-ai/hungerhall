extends RefCounted
## test_main_scene_contract — G9 Gate R-4 + R-1 anchor: the configured main
## scene carries the juice/composition nodes the contract names, the governed
## visible-asset anchor still points at a product-qualified texture, the
## director mounts its five real sub-manager classes, and the bot telemetry
## contract (G9 DoD #6: result + juice_events) is wired in ci/sneferu_bot.gd.
## Each test FAILS when its contract breaks (R-4). Structural by design —
## instantiating the live scene here would fire _ready against a tree with no
## autoloads; the runner proves the journey, this suite proves the wiring.

func _ok(msg: String = "") -> Dictionary:
	return {"ok": true, "msg": msg}

func _fail(msg: String) -> Dictionary:
	return {"ok": false, "msg": msg}

# why: round-7 zero-leak bar — the sub-manager probe instantiates a real
# JuiceDirector (a Node carrying 5 add_child'd sub-managers); teardown()
# frees it so the runner exits clean (test_runner.gd:79 calls teardown).
var _owned: Array = []

func teardown() -> void:
	for n in _owned:
		if is_instance_valid(n) and n is Node:
			n.free()
	_owned.clear()

func _file_text(path: String) -> String:
	var f: FileAccess = FileAccess.open(path, FileAccess.READ)
	if f == null:
		return ""
	var t: String = f.get_as_text()
	f.close()
	return t

func test_main_scene_is_configured_and_parses() -> Dictionary:
	var project: String = _file_text("res://project.godot")
	if project.find("run/main_scene=\"res://main.tscn\"") < 0:
		return _fail("project.godot must configure res://main.tscn as the main scene")
	var scene: Variant = load("res://main.tscn")
	if scene == null or not (scene is PackedScene):
		return _fail("main.tscn failed to load as a PackedScene")
	return _ok()

func test_main_scene_carries_the_composition_nodes() -> Dictionary:
	var scene: PackedScene = load("res://main.tscn")
	var inst: Node = scene.instantiate()  # not added to the tree — no _ready
	var required: Array = ["InputMapper", "SceneRouter", "CueBus", "JuiceDirector"]
	for child_name in required:
		if inst.get_node_or_null(child_name) == null:
			inst.free()
			return _fail("main.tscn lost its %s child (composition-root contract)" % str(child_name))
	var director: Node = inst.get_node("JuiceDirector")
	if director == null or not director.has_method("on_cue") or not director.has_method("step") \
			or not director.has_method("bind") or not director.has_method("play_caption"):
		inst.free()
		return _fail("JuiceDirector node must expose the cue/step/bind/play_caption API")
	inst.free()
	return _ok()

func test_director_mounts_five_real_submanager_classes() -> Dictionary:
	var tun: TunablesLoader = TunablesLoader.new()
	if not tun.load_from_path("res://Tunables.json"):
		return _fail("Tunables.json failed to load")
	var d: JuiceDirector = JuiceDirector.new()
	d.setup(tun, null)  # headless path — _ensure_managers, not _ready
	_owned.append(d)
	# why: `is` resolves the script class_name — get_class() would report the
	# native base ("Node") and mask a bare-Node regression. Round-4 blocker:
	# sub-managers must be the REAL partition classes, not placeholder Nodes.
	if not (d.tween_manager is TweenManager):
		return _fail("tween_manager is not the TweenManager class")
	if not (d.particle_manager is ParticleManager):
		return _fail("particle_manager is not the ParticleManager class")
	if not (d.hitstop_manager is HitstopManager):
		return _fail("hitstop_manager is not the HitstopManager class")
	if not (d.streak_manager is StreakManager):
		return _fail("streak_manager is not the StreakManager class")
	if not (d.void_bridge_manager is VoidBridgeManager):
		return _fail("void_bridge_manager is not the VoidBridgeManager class")
	return _ok()

func test_visible_asset_anchor_is_product_qualified() -> Dictionary:
	# R-1: warrior-main.png is the governed visible asset; its plan file must
	# name a manifest-qualified texture, and that texture must admit.
	var text: String = _file_text("res://ci/sneferu_visible_asset.json")
	if text == "":
		return _fail("ci/sneferu_visible_asset.json unreadable")
	var parsed: Variant = JSON.parse_string(text)
	if not (parsed is Dictionary):
		return _fail("sneferu_visible_asset.json is not valid JSON")
	var plan: Dictionary = parsed
	var uri: String = str(plan.get("resource_uri", ""))
	if uri != "res://Assets/warrior-main.png":
		return _fail("visible-asset anchor moved off warrior-main.png (R-1 regression): %s" % uri)
	if str(plan.get("plan_sha256", "")) != "c141f0d1d9a251773a67f19e4a203b4ce811190cf375dec1c867b05d8491d302":
		return _fail("plan_sha256 drifted from the governed value c141f0d1…")
	var mf: FileAccess = FileAccess.open("res://Assets/ASSET_MANIFEST.json", FileAccess.READ)
	if mf == null:
		return _fail("ASSET_MANIFEST.json unreadable")
	var manifest: Variant = JSON.parse_string(mf.get_as_text())
	mf.close()
	var qualified: bool = false
	for row_v in (manifest as Dictionary).get("assets", []):
		var row: Dictionary = row_v
		if "res://" + str(row.get("file", "")) == uri and str(row.get("qualification", "")) == "product_qualified":
			qualified = true
			break
	if not qualified:
		return _fail("the visible-asset anchor is not product_qualified in the manifest")
	var res: Resource = ResourceLoader.load(uri)
	if res == null or not (res is Texture2D):
		return _fail("the anchored texture does not admit through ResourceLoader")
	return _ok()

func test_bot_telemetry_contract_carries_result_and_juice_events() -> Dictionary:
	# G9 DoD #6: telemetry records juice_events and result. Structural pin —
	# the runtime proof is the pre-review bot run; this test fails if the
	# contract keys are ever removed from the writer.
	var src: String = _file_text("res://ci/sneferu_bot.gd")
	if src == "":
		return _fail("ci/sneferu_bot.gd unreadable")
	for needle in ["\"juice_events\"", "\"juice_event_total\"", "\"juice_event_counts\"", "\"result\"", "\"results\"", "RESULT_IMPOSSIBLE_PROGRESS", "RESULT_LOOP_DETECTED"]:
		if src.find(needle) < 0:
			return _fail("bot telemetry lost %s (G9 DoD #6 regression)" % needle)
	# the round-5 guard fix: score monotonicity must stay OUT of the
	# impossible-progress check (G2 locks a death penalty — score drops are legal)
	if src.find("session.score.score < prev_score") >= 0:
		return _fail("impossible-progress guard re-gained the score-monotonicity clause (death-penalty misclassification)")
	return _ok()

func test_rules_emit_the_telegraph_seam() -> Dictionary:
	# G9 §9 row 8 promotion: cue.enemy.telegraph is a REAL cue at the rules
	# fire site, registered in the musician-handoff cue manifest.
	var src: String = _file_text("res://core/rules_session.gd")
	if src.find("_push_cue(&\"cue.enemy.telegraph\")") < 0:
		return _fail("rules_session lost the cue.enemy.telegraph push (AC-37 zero-trigger regression)")
	if src.find("\"enemy_telegraph\"") < 0:
		return _fail("rules_session lost the enemy_telegraph presentation event")
	var cm: String = _file_text("res://data/cue_manifest.json")
	if cm.find("cue.enemy.telegraph") < 0:
		return _fail("cue_manifest.json must register cue.enemy.telegraph")
	return _ok()
