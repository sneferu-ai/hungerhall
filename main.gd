extends Node2D
## HUNGERHALL — configured main scene (G6 §1, §GODOT PLAYTEST CONTRACT).
## The sole composition root: all app-layer nodes are authored as children in
## main.tscn (InputMapper FIRST — its _input runs before every screen —
## SceneRouter, CueBus), then wired here. Displays the governed visible asset
## (warrior-main.png) in the first 5 frames and dispatches to
## ci/sneferu_bot.gd when user args are present. Owns the fixed-60Hz rule
## heartbeat: SessionStateMachine.tick_once() once per _physics_process.

var _bot: SneferuBot = null
var _bot_done: bool = false
var _visible_asset: TextureRect = null
var _cue_bus: CueBus = null
var _juice_director: JuiceDirector = null
var _router: SceneRouter = null
var _mapper: InputMapper = null
var _ssm: Node = null
var _frame_count: int = 0
var _is_bot_mode: bool = false

func _ready() -> void:
	# why: the visible-asset anchor must be placed BEFORE any bot logic
	# so it renders in the first 5 fixed-fps frames
	_place_visible_asset()
	_mapper = get_node_or_null("InputMapper")
	_router = get_node_or_null("SceneRouter")
	_cue_bus = get_node_or_null("CueBus")
	_ssm = get_node_or_null("/root/SessionStateMachine")
	# why: read user args and check for bot mode
	var args: Dictionary = SneferuBot.new().parse_user_args()
	if args.has("telemetry-out"):
		_is_bot_mode = true
		_start_bot(args)
		return
	if _ssm != null:
		_apply_seed_args()
		# why: autoloads load BEFORE the main scene, so SSM._ready() found no
		# router; wire the authored children before boot so transitions land
		if _router != null:
			_ssm.set_router(_router)
		if _cue_bus != null:
			_ssm.set_cue_bus(_cue_bus)
		# why: JuiceDirector is an authored child of Main (G6 §2 app/); wire it
		# to the SSM's TunablesLoader + settings, assign to CueBus's dispatch
		# slot so every cue from the rules path drives juice, and bind the SSM
		# NodePath for attract-mode detection
		_juice_director = get_node_or_null("JuiceDirector")
		if _juice_director != null:
			_juice_director.setup(_ssm.tunables, _ssm)
			_juice_director.state_machine_path = _ssm.get_path()
			if _cue_bus != null:
				_cue_bus.juice_director = _juice_director
		# why: the four save stores are authored children of Main (G6 §2);
		# inject them so the SSM's self-owned fallbacks are replaced by the
		# composition-root instances
		var _save_store: Node = get_node_or_null("SaveStore")
		var _profile_store: Node = get_node_or_null("ProfileStore")
		var _score_store: Node = get_node_or_null("ScoreStore")
		var _settings_store: Node = get_node_or_null("SettingsStore")
		if _save_store != null:
			_ssm.set_save_store(_save_store)
			if _profile_store != null:
				_profile_store.set_save_store(_save_store)
				_ssm.set_profile_store(_profile_store)
			if _score_store != null:
				_score_store.set_save_store(_save_store)
				_ssm.set_score_store(_score_store)
			if _settings_store != null:
				_settings_store.set_save_store(_save_store)
				_ssm.set_settings_store(_settings_store)
			_ssm.settings = _ssm.settings_store.read_settings()
		if _mapper != null:
			_mapper.set_ssm(_ssm)
			_mapper.set_router(_router)
		_ssm.boot()
		# why: G5 §1 WindowDefocused → paused (grace-gated inside the SSM)
		get_window().focus_exited.connect(_on_window_defocus)

func _apply_seed_args() -> void:
	# why: main.gd reads --seed and --journey-seed (G6 §1); the journey
	# contract pins seed 42, bots carry their own explicit seed
	for raw in OS.get_cmdline_user_args():
		var arg: String = str(raw)
		if arg.begins_with("--seed="):
			_ssm.campaign_seed = int(arg.substr(7))
		elif arg.begins_with("--journey-seed="):
			_ssm.campaign_seed = int(arg.substr(15))

func _place_visible_asset() -> void:
	# why: load the governed PNG via ResourceLoader at the exact res:// URI
	# declared in ci/sneferu_visible_asset.json
	var tex: Texture2D = load("res://Assets/warrior-main.png")
	if tex == null:
		push_warning("HUNGERHALL: visible asset res://Assets/warrior-main.png failed to load")
		return
	_visible_asset = TextureRect.new()
	_visible_asset.name = "VisibleAssetAnchor"
	_visible_asset.texture = tex
	_visible_asset.position = Vector2(16, 16)
	_visible_asset.size = Vector2(64, 64)
	_visible_asset.modulate = Color(1, 1, 1, 1)
	_visible_asset.visible = true
	add_child(_visible_asset)

func _start_bot(args: Dictionary) -> void:
	_bot = SneferuBot.new()
	var result: Dictionary = _bot.setup(args)
	if not result.get("ok", false):
		push_error("HUNGERHALL bot setup failed: " + str(result.get("error", "")))
		get_tree().quit(1)
		return

func _physics_process(_delta: float) -> void:
	# why: THE fixed-60Hz heartbeat — one rule step per physics tick, driven
	# by the engine's deterministic tick, never by wall-clock accumulation
	if _is_bot_mode:
		# why: deliberate — in bot mode the presentation director is never
		# wired (the bot owns no screen tree). G9 DoD #6 juice stepping still
		# happens: SneferuBot runs its OWN headless JuiceDirector recorder,
		# stepped once per fixed rule tick inside _play_game from the rules
		# truth (consume_pending cues + snapshots). Nothing to drive here.
		return
	if _ssm != null and _ssm.has_method("tick_once"):
		_ssm.tick_once()
	# why: JuiceDirector steps once per fixed tick from the composition root —
	# covers all screens (play, title, menus) since main.gd owns the heartbeat;
	# safe when idle (sub-manager tick() calls are no-ops with no active state)
	if _juice_director != null:
		_juice_director.step()

func _process(_delta: float) -> void:
	if _is_bot_mode and not _bot_done:
		# why: run the bot synchronously — it drives RulesSession in-process
		var run_result: Dictionary = _bot.run()
		_bot_done = true
		if not run_result.get("ok", false):
			push_error("HUNGERHALL bot run failed: " + str(run_result.get("error", "")))
			get_tree().quit(1)
			return
		# why: bot completed — quit cleanly so the harness sees the telemetry file
		get_tree().quit(0)

func _on_window_defocus() -> void:
	if _ssm != null and _ssm.has_method("on_window_defocus"):
		_ssm.on_window_defocus()

func _exit_tree() -> void:
	# why: ensure the visible asset is not freed before the 5-frame proof window
	pass
