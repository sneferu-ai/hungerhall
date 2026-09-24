class_name JuiceDirector
extends Node
## G10 — HUNGERHALL JuiceDirector (G9 runtime architecture, adapted).
##
## MOUNTED AS AN AUTHORED CHILD OF MAIN, NOT AN AUTOLOAD — conscious
## supersession of the G9 "[Autoloads]" tree: G6 §1 locks "exactly one
## autoload SessionStateMachine" (project.godot:17-19). JuiceDirector gets
## the identical lifetime it needs (present from boot, never paused — its
## sub-managers check pause/hitstop internally) by mounting beside CueBus in
## main.tscn. Composition-root wiring (REAL, main.gd::_ready): the director
## is set up with the SSM's TunablesLoader, assigned to CueBus's
## juice_director dispatch slot (app/cue_bus.gd:28), given the SSM NodePath
## for the attract_mode flag, and stepped once per fixed 60Hz tick by
## main.gd::_physics_process (the composition-root heartbeat — covers all
## screens: play, title, menus).
##
## Partition (G9): TweenManager (tween lifecycle step chokepoint) wraps
## JuiceTweenEngine; ParticleManager (particle caps + eviction ledger);
## HitstopManager (physics-tick freeze counter); StreakManager (kill-streak
## tiers); VoidBridgeManager (warning pulse state). All five are REAL script
## classes (juice/*.gd) instantiated in _ready — sub-manager calls are typed
## method calls, never Object.call() against bare Nodes.
##
## Determinism: everything advances from step() — the same fixed-60Hz
## heartbeat play.gd renders from. juice_events are recorded from the RULES
## truth (snapshot deltas + consume_pending cues forwarded by CueBus), never
## invented by presentation (G9 OBL-4/32 seam, adapted: HUNGERHALL rules
## surface through consume_pending()/snapshot, not RefCounted signals).

const Ticks = preload("res://juice/juice_tween_engine.gd")  # static helper alias

var tunables: TunablesLoader = null
var engine: JuiceTweenEngine = JuiceTweenEngine.new()

# ---- sub-managers (G9 partition — real classes, instantiated in _ready) ----
var tween_manager: TweenManager = null      # owns the engine step chokepoint
var particle_manager: ParticleManager = null # caps + eviction ledger
var hitstop_manager: HitstopManager = null  # physics-tick freeze counter
var streak_manager: StreakManager = null    # kill-streak tiers
var void_bridge_manager: VoidBridgeManager = null  # AC-52 pulse state

# ---- bindings into the product ----
var _settings_source: Node = null   # SSM (reads .settings)
var _world_view: Node = null        # WorldView (particles/camera/floaters)
var _hud: Node = null               # Hud (HP numeral/labels)
var _overlay_nodes: Dictionary = {} # vignette/death_vignette/screen_edge/overlay/flash/class_tint/sig5/banner rects

var juice_events: Array = []        # [{event, step}] — telemetry seam
var asset_debt: Array = []          # G9 Asset Delivery — semantic ids/paths that fell back to magenta
var _step: int = 0
var _last_hp: int = -1
var _last_max_hp: int = -1
var _last_score: int = -1
var _last_floor: int = -1
var _hp_band: int = -1              # 0=>50% 1=<=50% 2=<=25% 3=<=10%
var _first_food_seen: bool = true   # cue-side (AC-47 vs AC-47r), flips in _on_food
var _first_food_burst_done: bool = false  # event-side (PT-07), flips in consume_events
var _potion_cooldown_ticks: int = 0
var _haptic_hit_cooldown_ticks: int = 0
var _flame_ticks_left: int = 0
var _reduce_motion: bool = false

## G9 attract-mode detection — read via NodePath binding (assigned by
## Main._ready to the SSM's path), never group lookup (OBL-45).
var state_machine_path: NodePath = NodePath("")

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS  # G9: JuiceDirector ALWAYS
	_ensure_managers()
	# why: setup() may run BEFORE mounting (tests) or after — sub-managers
	# that arrived after setup() still get the tunables they need
	if tunables != null:
		streak_manager.setup(tunables)
		particle_manager.configure(tunables)

## Idempotent sub-manager mount. _ready() calls it for the mounted product
## director; setup() calls it for HEADLESS recorders (the bot's telemetry seam
## runs a director OUT of the scene tree — _ready never fires there, and the
## G9 DoD #6 recorder needs the real hitstop/streak/particle ledgers, not the
## null-tolerant degraded path).
func _ensure_managers() -> void:
	if tween_manager != null:
		return
	tween_manager = TweenManager.new()
	tween_manager.name = "TweenManager"
	add_child(tween_manager)
	tween_manager.attach(engine)
	particle_manager = ParticleManager.new()
	particle_manager.name = "ParticleManager"
	add_child(particle_manager)
	hitstop_manager = HitstopManager.new()
	hitstop_manager.name = "HitstopManager"
	add_child(hitstop_manager)
	streak_manager = StreakManager.new()
	streak_manager.name = "StreakManager"
	add_child(streak_manager)
	void_bridge_manager = VoidBridgeManager.new()
	void_bridge_manager.name = "VoidBridgeManager"
	add_child(void_bridge_manager)

## Composition-root wiring (main.gd after store injection).
func setup(tun: TunablesLoader, settings_source: Node) -> void:
	tunables = tun
	_settings_source = settings_source
	_ensure_managers()
	engine.configure(tun)
	_reduce_motion = reduce_motion_enabled()
	if streak_manager != null:
		streak_manager.setup(tun)
	if particle_manager != null:
		particle_manager.configure(tun)

func attach_world(wv: Node) -> void:
	_world_view = wv

func attach_hud(hud: Node) -> void:
	_hud = hud

func bind(prop: String, applier: Callable) -> void:
	engine.bind(prop, applier)

## Screen teardown counterpart to bind() — a screen that outlives nothing
## (splash/title/results/game-over are freed on transition while the director
## is a Main child) must drop its prop bindings so a later tween can never
## fire into a freed closure target.
func unbind(prop: String) -> void:
	engine.unbind(prop)

func set_overlay_nodes(nodes: Dictionary) -> void:
	_overlay_nodes = nodes

## Screen teardown (PlayScreen._exit_tree) — the director is a Main child and
## OUTLIVES the mounted screen; holding freed WorldView/Hud references would
## let the next screen's juice fire into dangling objects. Unbound/empty =
## every projection guard no-ops until the next screen binds.
func clear_screen() -> void:
	_world_view = null
	_hud = null
	_overlay_nodes = {}
	engine.clear_bindings()

# ============================================================ stepping

## Called once per fixed 60Hz tick by main.gd (the composition-root heartbeat;
## covers all screens). Advances every sub-manager deterministically.
func step() -> void:
	_step += 1
	_reduce_motion = reduce_motion_enabled()
	if _potion_cooldown_ticks > 0:
		_potion_cooldown_ticks -= 1
	if _haptic_hit_cooldown_ticks > 0:
		_haptic_hit_cooldown_ticks -= 1
	if _flame_ticks_left > 0:
		_flame_ticks_left -= 1
		if _flame_ticks_left == 0:
			_flame_overlay_exit()
	if hitstop_manager != null:
		hitstop_manager.tick()
	if tween_manager != null:
		tween_manager.tick(hitstop_active())
	else:
		engine.step(hitstop_active())
	if streak_manager != null:
		streak_manager.tick()
	if void_bridge_manager != null:
		void_bridge_manager.tick()
	if particle_manager != null:
		particle_manager.tick()
	# why: SIG-5 banner out — the dwell is step-counted (AC-55), then the
	# banner-out tween (AC-56) fires exactly once
	if _banner_out_countdown > 0:
		_banner_out_countdown -= 1
		if _banner_out_countdown <= 0:
			play_ac("AC-56")
	# why: caption out (AC-28) — the in tween (AC-26) + dwell (AC-27) are
	# step-counted, then the caption-out alpha fade fires exactly once. Mirrors
	# the banner lifecycle above (G9 §2 Death/Results rows AC-54/55/56 parity).
	if _caption_out_countdown > 0:
		_caption_out_countdown -= 1
		if _caption_out_countdown <= 0:
			play_ac("AC-28")

func reduce_motion_enabled() -> bool:
	if _settings_source != null and _settings_source.has_method("reduced_motion_enabled"):
		return bool(_settings_source.reduced_motion_enabled())
	return false

func hitstop_active() -> bool:
	return hitstop_manager != null and hitstop_manager.active

## G9 §9 attract-mode suppression query — true while the SSM reports
## attract_mode (title-screen attract reel). NodePath binding, no group
## lookup (OBL-45); unbound/absent SSM = not in attract.
func _in_attract_mode() -> bool:
	if state_machine_path == NodePath(""):
		return false
	var sm: Node = get_node_or_null(state_machine_path)
	if sm == null:
		return false
	return bool(sm.get("attract_mode"))

## World-juice freeze gate for the projection layer (particles/floaters/
## camera decay + idle ambient advance stop during hitstop; OBL-31: UI juice
## keeps advancing — engine.step already splits world vs UI tweens).
func world_frozen() -> bool:
	# why: is_inside_tree guard — the bot's headless recorder runs OUT of the
	# scene tree; calling get_tree() on an unmounted Node prints an engine
	# ERROR before returning null (32 errors per test run). is_inside_tree is
	# the Godot-blessed guard that avoids the null-tree warning entirely.
	if not is_inside_tree():
		return hitstop_active()
	var tree: SceneTree = get_tree()
	return tree.paused or hitstop_active()

# ============================================================ hitstop (G9 §2)

func request_hitstop(kind: String) -> void:
	# why: hitstop is a FREEZE, not motion — Reduce Motion keeps it (G9 RM row
	# "Hitstop: REMAINS"). Pause supersedes hitstop (G9): never start while paused.
	# is_inside_tree guard — the bot's headless recorder runs OUT of the scene
	# tree; get_tree() on an unmounted Node prints an engine ERROR (the 32-error
	# spam this guard eliminates). Out-of-tree = never paused = proceed.
	if is_inside_tree():
		var tree: SceneTree = get_tree()
		if tree.paused:
			return
	var table: Dictionary = JuiceContracts.hitstop_table()
	var row: Dictionary = table.get(kind, {})
	var frames: int = int(row.get("frames_default", 0))
	if tunables != null and str(row.get("frames_key", "")) != "":
		frames = tunables.get_int(str(row.get("frames_key", "")), frames)
	if hitstop_manager != null:
		hitstop_manager.request(frames)
	_record_event("hitstop_" + kind)

# ============================================================ shake (G9 §4)

func shake(kind: String) -> void:
	# why: exactly three shake events (generator/death/clear) — G9 §4 policy;
	# Reduce Motion turns ALL shake OFF
	if _reduce_motion:
		return
	var table: Dictionary = JuiceContracts.shake_table()
	if not table.has(kind):
		return
	var row: Dictionary = table[kind]
	var mag: float = tunables.get_value(str(row.get("mag_key", "")), 1.0)
	var ms: float = tunables.get_value(str(row.get("ms_key", "")), 60.0)
	if _world_view != null and _world_view.has_method("shake"):
		_world_view.shake(mag, Ticks.ms_to_ticks(ms), str(row.get("falloff", "linear")))

# ============================================================ camera (G9 §4)

func camera_zoom_punch(peak: float, ms_total: float) -> void:
	if _reduce_motion:
		return
	if _world_view != null and _world_view.has_method("zoom_punch"):
		_world_view.zoom_punch(peak, Ticks.ms_to_ticks(ms_total / 2.0))

func camera_drift_to_exit_and_back(drift_ms: float, return_ms: float) -> void:
	if _reduce_motion:
		return
	if _world_view != null and _world_view.has_method("drift_to_exit_and_back"):
		_world_view.drift_to_exit_and_back(Ticks.ms_to_ticks(drift_ms), Ticks.ms_to_ticks(return_ms))

# ============================================================ haptics (G9 §5)

func haptic(kind: String) -> void:
	# why: gamepad only, system rumble setting respected (settings
	# rumble_intensity 0..100 — LAR-2), durations converted ms→s via
	# juice.haptic.duration_conversion (G9 preamble)
	if _settings_source != null:
		var settings: Dictionary = _settings_source.get("settings") if _settings_source.get("settings") is Dictionary else {}
		var intensity: int = int(settings.get("rumble_intensity", 100))
		if intensity <= 0:
			return
	var row: Dictionary = JuiceContracts.haptic_table().get(kind, {})
	if row.is_empty() or tunables == null:
		return
	var weak: float = tunables.get_value(str(row.get("weak_key", "")), 0.0)
	var strong: float = tunables.get_value(str(row.get("strong_key", "")), 0.0)
	var ms: float = tunables.get_value(str(row.get("ms_key", "")), 50.0)
	var conv: float = tunables.get_value("juice.haptic.duration_conversion", 0.001)
	# why: telemetry seam — a haptic REQUEST that passed the settings gate is a
	# juice event even when no joypad is connected (headless/bot runs); the
	# intensity-off gate above means rumble_intensity=0 records nothing, which
	# is exactly what the accessibility battery asserts.
	_record_event("haptic:" + kind)
	for device in Input.get_connected_joypads():
		Input.start_joy_vibration(device, weak, strong, ms * conv)

# ============================================================ contract play

## Resolve a G9 contract row into an engine spec (tunables resolve here —
## the runtime path never hardcodes a tuned number).
func _spec_for(ac: String) -> Dictionary:
	var row: Dictionary = JuiceContracts.contract().get(ac, {})
	if row.is_empty():
		return {}
	var ttable: Dictionary = JuiceContracts.type_table()
	var trow: Dictionary = ttable.get(str(row.get("type", "")), {})
	var segments: Array = []
	for seg in row.get("segments", []):
		segments.append(_resolve_segment(seg))
	return {
		"ac": ac,
		"type": str(row.get("type", "")),
		"units": int(row.get("units", 1)),
		"critical": bool(row.get("critical", false)) and int(row.get("units", 1)) > 0,
		"priority": int(trow.get("priority", 1)),
		"ambient": bool(row.get("ambient", false)),
		"loop_pp": bool(row.get("loop_pp", false)),
		"world": bool(row.get("world", false)),
		"cap": int(trow.get("cap", 0)),
		"overflow": str(trow.get("overflow", "snap_oldest")),
		"segments": segments,
	}

func _resolve_segment(seg: Dictionary) -> Dictionary:
	var out: Dictionary = seg.duplicate(true)
	var ms: float = 0.0
	if seg.has("ms"):
		ms = float(seg.get("ms", 0.0))
	elif seg.has("ms_key") and tunables != null:
		ms = tunables.get_value(str(seg.get("ms_key", "")), 100.0)
	if bool(seg.get("half", false)):
		ms = ms / 2.0
	# why: Reduce Motion halves these specific durations (G9 accessibility rows)
	if _reduce_motion:
		var mk: String = str(seg.get("ms_key", ""))
		if mk in ["juice.enemy.hit_flash_ms", "juice.hero.hurt_modulate_ms", "juice.hero.hurt_edge_flash_ms", "juice.projectile.impact_ms"]:
			ms = ms / 2.0
	out["ticks"] = Ticks.ms_to_ticks(ms)
	if seg.has("delay_ms_key") and tunables != null:
		out["delay_ticks"] = Ticks.ms_to_ticks(tunables.get_value(str(seg.get("delay_ms_key", "")), 0.0))
	elif seg.has("delay_ms"):
		out["delay_ticks"] = Ticks.ms_to_ticks(float(seg.get("delay_ms", 0.0)))
	if seg.has("from_key") and tunables != null:
		out["from"] = _key_value(str(seg.get("from_key", "")), seg.get("from", 0.0))
	if seg.has("to_key") and tunables != null:
		out["to"] = _key_value(str(seg.get("to_key", "")), seg.get("to", 0.0))
	# why: Reduce Motion intensity halves (G9 accessibility rows)
	if _reduce_motion:
		var tk: String = str(seg.get("to_key", ""))
		if tk == "juice.potion.flash_alpha" and out.get("to") is float:
			out["to"] = float(out["to"]) * 0.5 / 0.85 * 0.4  # 0.85 -> 0.4 exact
			out["to"] = 0.4
		if tk == "juice.potion.bloom_alpha":
			out["to"] = 0.3  # G9: 0.6 -> 0.3 exact
		if tk == "juice.hero.hurt_edge_alpha":
			out["to"] = 0.075  # G9: 0.15 -> 0.075 exact
		if tk == "juice.results.best_flash_alpha":
			out["to"] = 0.125  # G9: 0.25 -> 0.125 exact
	return out

func _key_value(key: String, fallback: Variant) -> Variant:
	if tunables == null:
		return fallback
	if key.begins_with("juice.hp.color.") or key.begins_with("juice.class.tint.") or key.begins_with("juice.zone."):
		if tunables.has_key(key):
			return tunables.get_color(key, Color.WHITE)
	return tunables.get_value(key, float(fallback) if fallback is int or fallback is float else 0.0)

## Play a contract row. Returns true if accepted by the budget gates.
func play_ac(ac: String) -> bool:
	var spec: Dictionary = _spec_for(ac)
	if spec.is_empty() or (spec.get("segments", []) as Array).is_empty():
		return false
	var accepted: bool = engine.request(spec)
	if accepted:
		_record_event(ac)
	return accepted

## G9 AC-08 — class card pop-in ×4 with the contracted 60ms stagger
## (juice.class.popin_stagger_ms). One engine instance per card, each with its
## own prop suffix (.0–.3) so the four cards animate independently; the screen
## binds class_card.scale.N / class_card.alpha.N per card N.
func play_class_popin() -> void:
	var base: Dictionary = _spec_for("AC-08")
	if base.is_empty():
		return
	var stagger: int = Ticks.ms_to_ticks(_tun("juice.class.popin_stagger_ms", 60.0))
	for i in range(4):
		var inst: Dictionary = base.duplicate(true)
		for seg in inst.get("segments", []):
			seg["prop"] = str(seg.get("prop", "")) + "." + str(i)
			seg["delay_ticks"] = i * stagger
		if engine.request(inst):
			_record_event("AC-08." + str(i))

## Ambient loops — start once, stop by type. Reduce Motion keeps world/static
## surfaces at rest: ALL ambient loops OFF under RM (G9 accessibility).
func start_ambient(ac: String) -> bool:
	if _reduce_motion:
		return false
	if engine.has_type(str(JuiceContracts.contract().get(ac, {}).get("type", ""))):
		return true  # already running
	return play_ac(ac)

func stop_ambient_type(ttype: String) -> void:
	engine.stop_type(ttype)

func ambient_instance_count(ttype: String) -> int:
	return engine.tweens_of_type(ttype).size()

# ============================================================ cue intake (CueBus hook)

## CueBus dispatch slot (app/cue_bus.gd _dispatch) — every real semantic cue
## from the rules path lands here.
func on_cue(entry: Dictionary) -> void:
	var cue: String = str(entry.get("cue_id", ""))
	var step_at: int = int(entry.get("step", -1))
	match cue:
		"cue.hp.tick":
			_on_hp_tick()
		"cue.player.hurt":
			_on_hero_hurt()
		"cue.enemy.hurt":
			_on_hit_confirm()
		"cue.enemy.killed":
			_on_enemy_killed()
		"cue.generator.hurt":
			play_ac("AC-42b")  # G9: generator pre-death flicker (50ms, argued inline)
		"cue.generator.destroyed":
			_on_generator_destroyed()
		"cue.hazard.flame_preon":
			play_ac("AC-39")  # G9: flame-jet pre-ON flicker (rules telegraph cue)
		"cue.enemy.telegraph":
			# G9 §9 row 8 → AC-37 ranged telegraph (rules fire-moment seam; the
			# per-actor modulate projection rides the sibling enemy_telegraph
			# event lane in consume_events — same split as projectile impact)
			play_ac("AC-37")
		"cue.pickup.food":
			_on_food()
		"cue.pickup.key":
			_on_key_pickup()
		"cue.pickup.chest":
			play_ac("AC-49")
			haptic("light")
		"cue.pickup.potion":
			play_ac("AC-50")
		"cue.player.potion":
			_on_potion_used()
		"cue.player.throw":
			_on_throw()
		"cue.door.open":
			play_ac("AC-44")
		"cue.floor.clear":
			_on_floor_clear()
		"cue.campaign.clear":
			_on_floor_clear()
		"cue.player.death":
			_on_player_death()
		"cue.projectile.impact":
			play_ac("AC-41")
		_:
			pass
	if cue != "":
		_record_event("cue:" + cue)

# ============================================================ event intake (play.gd)

## G6 §3.3 presentation events forwarded by play.gd after each step —
## positional data for particles + entity-scoped world juice.
func consume_events(events: Array) -> void:
	for e in events:
		if not (e is Dictionary):
			continue
		var etype: String = str(e.get("type", ""))
		var pos: Variant = e.get("position", [0.0, 0.0])
		var p: Vector2 = Vector2(float(pos[0]) if pos is Array and pos.size() > 0 else 0.0, float(pos[1]) if pos is Array and pos.size() > 1 else 0.0)
		var amount: int = int(e.get("amount", 0))
		var eid: int = int(e.get("entity_id", 0))
		match etype:
			"generator_destroyed":
				particle_burst("PT-06", p, Color("#F2A23B"))
				_spawn_death_ghost("PT-06", p, "res://Assets/generator-cloche.png", "juice.gen.burst_scale_ms", "juice.gen.burst_fade_ms", 1.25)
				_floater_at(p, "+%d" % amount if amount > 0 else "+100", Color("#F2A23B"))
			"enemy_killed":
				particle_burst("PT-05a", p, Color("#8A8098"))
				particle_burst("PT-05b", p, Color("#F3EAD9"))
				_spawn_death_ghost("PT-05a", p, _enemy_tex_hint(eid), "juice.enemy.death_scale_ms", "juice.enemy.death_fade_ms", 1.15)
			"projectile_hit":
				particle_burst("PT-03", p, Color("#F3EAD9"))
				if _world_view != null and _world_view.has_method("flash_actor"):
					_world_view.flash_actor(eid, Ticks.ms_to_ticks(_tun("juice.enemy.hit_flash_ms", 80.0)), not _reduce_motion)
			"food_consumed":
				if not _first_food_burst_done:
					particle_burst("PT-07", p, Color("#EFC258"))
					_first_food_burst_done = true
			"key_collected":
				particle_burst("PT-10", p, Color("#D9DEE2"))
			"chest_opened":
				particle_burst("PT-11", p, Color("#EFC258"))
				_floater_at(p, "+%d" % amount if amount > 0 else "", Color("#EFC258"))
			"door_opened":
				particle_burst("PT-12", p, Color("#D9DEE2"))
			"potion_used":
				particle_burst("PT-09", p, Color("#9060B0"))
			"player_hit":
				# why: the PRIMARY screen-edge flash lane is AC-33 phase 3
				# (cue.player.hurt → _on_hero_hurt → _play_flash("screen_edge"))
				# through the PlayScreen-owned ScreenEdgeRect overlay. This event
				# lane is the FALLBACK: it fires only when no overlay rect is
				# bound, so the same hit can never double-flash.
				if not _overlay_nodes.has("screen_edge") and _world_view != null and _world_view.has_method("edge_flash"):
					var ea: float = _tun("juice.hero.hurt_edge_alpha", 0.15)
					if _reduce_motion:
						ea = 0.075
					_world_view.edge_flash(Color("#D94836"), ea, Ticks.ms_to_ticks(_tun("juice.hero.hurt_edge_flash_ms", 80.0)))
			"hp_tick":
				pass  # SIG-1 driven by cue.hp.tick (OBL-4)
			"enemy_spawned":
				_on_enemy_spawned(int(e.get("amount", 1)), p)
			"enemy_telegraph":
				# G9 AC-37 per-actor projection lane (entity id rides the event,
				# not the cue — HUNGERHALL cue entries carry {cue_id, step} only)
				if _world_view != null and _world_view.has_method("telegraph_actor"):
					_world_view.telegraph_actor(eid, Ticks.ms_to_ticks(_tun("juice.enemy.telegraph_ms", 250.0)))
			"throw":
				pass  # swing/lunge fired from cue.player.throw
			_:
				pass

func _tun(key: String, fallback: float) -> float:
	if tunables == null:
		return fallback
	return tunables.get_value(key, fallback)

func _enemy_tex_hint(eid: int) -> String:
	# why: death-ghost uses the victim's texture when the projection can
	# resolve it; falls back to the scullion still (never blocks juice)
	if _world_view != null and _world_view.has_method("actor_texture_for"):
		var t: Variant = _world_view.actor_texture_for(eid)
		if t is String and t != "":
			return t
	return "res://Assets/enemy-scullion.png"

# ============================================================ SIG-1 The Heartbeat

func _on_hp_tick() -> void:
	# AC-15 drain pulse — every integer HP decrement
	play_ac("AC-15")

## Snapshot-driven thresholds (SIG-1 color path + vignettes + pulse freq).
## Called by play.gd each step with the rules snapshot.
func notify_snapshot(snap: Dictionary) -> void:
	var player: Dictionary = snap.get("player", {})
	var hp: int = int(player.get("hp", 0))
	var max_hp: int = maxi(int(player.get("max_hp", 1)), 1)
	var floor_n: int = int(snap.get("floor", 1))
	var score: Dictionary = snap.get("score", {})
	var sc: int = int(score.get("score", 0))
	# why: class identity for SIG-4's class-tinted bloom arrives with the rules
	# snapshot ("class": hero_name, core/rules_session.gd snapshot()) — HUNGERHALL
	# cue entries carry {cue_id, step} only, so the snapshot is the honest seam
	_last_class = str(snap.get("class", _last_class))
	# floor change → spawn + drop-in + zone tint events (feel only).
	# G9 §8 first-30-seconds Handshake beat 3: the floor-begin composite MUST
	# also fire on the FIRST snapshot — floor 1 entry is a floor begin too
	# (round-3 defect: `_last_floor != -1` skipped hero-spawn/drop-in/floor-pop
	# on floor 1, making the handshake unplayable at campaign start).
	if _last_floor == -1 or floor_n != _last_floor:
		play_ac("AC-29")
		play_ac("AC-63")
		play_ac("AC-23")
		# why: PT-01 hero-spawn spark (handshake beat 3) — 8 sparks at the
		# hero's entry tile, class-tinted so the spawn visual reinforces class
		# identity at the moment of entry (B3 fix: contract row existed, no
		# burst site). _last_class is set above from the same snapshot.
		var _p_pos: Dictionary = snap.get("player", {})
		particle_burst("PT-01", Vector2(float(_p_pos.get("pos_x", 0.0)), float(_p_pos.get("pos_y", 0.0))), _class_tint())
		if _world_view != null and _world_view.has_method("apply_zone_tint"):
			_world_view.apply_zone_tint(floor_n, _zone_color(floor_n), _zone_alpha(floor_n))
		_start_floor_ambients(snap)
	_last_floor = floor_n
	if _last_score != -1 and sc > _last_score:
		play_ac("AC-21")
	_last_score = sc
	if hp == _last_hp:
		return
	var raised: bool = _last_hp != -1 and hp > _last_hp
	_last_hp = hp
	_last_max_hp = max_hp
	var band: int = _hp_band_for(hp, max_hp)
	if band != _hp_band:
		_apply_hp_band(band)
		_hp_band = band
	if raised:
		# SIG-3 tail: food-tick pop + tint per restored point (capped burst)
		play_ac("AC-18")
		play_ac("AC-19")

func _hp_band_for(hp: int, max_hp: int) -> int:
	var frac: float = float(hp) / float(max_hp)
	if frac <= 0.10:
		return 3
	if frac <= 0.25:
		return 2
	if frac <= 0.50:
		return 1
	return 0

func _apply_hp_band(band: int) -> void:
	match band:
		1:
			play_ac("AC-16")
			play_ac("AC-16b")
			_set_hp_status_text("FAIR")
			stop_ambient_type("hp_vignette")
			stop_ambient_type("hp_pulse_freq")
		2:
			play_ac("AC-17")
			play_ac("AC-17c")
			_set_hp_status_text("LOW")
			if _reduce_motion:
				_set_vignette_static(0.18)  # G9 RM: static 0.18, no pulse
			else:
				stop_ambient_type("hp_vignette")
				play_ac("AC-20")
			_start_pulse_freq("juice.ac20c.period_50")
		3:
			play_ac("AC-17b")
			_set_hp_status_text("CRITICAL")
			if _reduce_motion:
				_set_vignette_static(0.30)  # G9 RM: static 0.30, no pulse
			else:
				stop_ambient_type("hp_vignette")
				play_ac("AC-20b")
			_start_pulse_freq("juice.ac20c.period_10")
		0:
			stop_ambient_type("hp_vignette")
			stop_ambient_type("hp_pulse_freq")
			_set_vignette_static(0.0)
			_set_hp_status_text("")
			_reset_hp_color()

## G9 colorblind support (SIG-1): the HPStatusLabel text change is an INSTANT
## Label.text assignment (not tweened); only the label alpha rides the
## AC-16b/17c/17b tweens. Non-color redundant channel at all three thresholds.
func _set_hp_status_text(text: String) -> void:
	if not _overlay_nodes.has("hp_status"):
		return
	var label: Node = _overlay_nodes["hp_status"]
	if label is Label:
		(label as Label).text = text

func _start_pulse_freq(period_key: String) -> void:
	# AC-20c — pulse frequency escalation; period swaps by threshold band.
	# Reduce Motion: OFF entirely (G9).
	if _reduce_motion:
		return
	stop_ambient_type("hp_pulse_freq")
	var spec: Dictionary = _spec_for("AC-20c")
	if spec.is_empty():
		return
	var segs: Array = spec.get("segments", [])
	if not segs.is_empty() and tunables != null:
		var seg: Dictionary = segs[0]
		seg["ticks"] = Ticks.ms_to_ticks(tunables.get_value(period_key, 1200.0))
	engine.request(spec)

func _set_vignette_static(alpha: float) -> void:
	if _overlay_nodes.has("vignette"):
		var rect: ColorRect = _overlay_nodes["vignette"]
		rect.color.a = alpha

func _reset_hp_color() -> void:
	if tunables != null and _overlay_nodes.has("hp_color_reset"):
		(_overlay_nodes["hp_color_reset"] as Callable).call(tunables.get_color("juice.hp.color.white", Color.WHITE))

# ============================================================ SIG-2 The Cloche Pops

func _on_generator_destroyed() -> void:
	request_hitstop("HS-2")
	shake("generator")
	camera_zoom_punch(_tun("juice.camera.gen_zoom", 1.03), _tun("juice.camera.gen_zoom_ms", 200.0))
	_play_gen_burst_tweens()
	haptic("medium")

func _play_gen_burst_tweens() -> void:
	# AC-43 phases 2-3 on the death ghost (scale 1.25->0, alpha ->0) ride
	# _spawn_death_ghost; floater + caption-in are the HUD legs (phases 4-5).
	# The caption OUT is scheduled with the in tween so the band never parks at
	# peak alpha (the tutorial caption lane also schedules via play_caption —
	# a re-schedule just refreshes the countdown, never a double out).
	play_ac("AC-26")
	_schedule_caption_out()

# ============================================================ SIG-3 The Clock Reverses

func _on_food() -> void:
	haptic("light")
	# G9 SIG-3: FIRST food gets the full composite (AC-47 — pop+fade, HP
	# ×3 tick pops, FOOD caption); routine food gets AC-47r (phases 1-2 only).
	# OQ-22 seam: first_food is tracked locally from the rules cue stream.
	# The flag flips HERE (cue side); the PT-07 particle burst rides the
	# event stream with its own flag (consume_events) — CueBus dispatch
	# precedes event dispatch each step (SSM._drain_pending order), so the
	# two flags keep the tween and the burst each exactly-once.
	if _first_food_seen:
		_first_food_seen = false
		play_ac("AC-47")
		_record_event("SIG-3")
	else:
		play_ac("AC-47r")

# ============================================================ SIG-4 The Panic Button

func _on_potion_used() -> void:
	# AC-51 cooldown: 2nd request within juice.potion.cooldown_ms is REJECTED
	# (presentation-side replay gate only — rules own the real potion logic)
	var cooldown_ticks: int = Ticks.ms_to_ticks(_tun("juice.potion.cooldown_ms", 1000.0))
	if _potion_cooldown_ticks > 0:
		return
	_potion_cooldown_ticks = cooldown_ticks
	request_hitstop("HS-3")
	# phase 2: white flash — set peak then ease back (flash pattern, 1 unit)
	_play_flash("flash", _tun("juice.potion.flash_alpha", 0.85), "juice.potion.flash_ms", Color.WHITE)
	# phase 3: class-tinted bloom — additive class tint
	_play_flash("class_tint", _tun("juice.potion.bloom_alpha", 0.6), "juice.potion.bloom_ms", _class_tint())
	# phase 4: hero pop back-out — _play_hero_pop re-requests the AC-31 spec
	# re-typed as potion_use at juice.potion.hero_pop_ms. The round-3 bare
	# play_ac("AC-31") beside it double-fired the hero scale in the same tick
	# (reviewer QUESTION, resolved: the bare call is dropped — the pop alone
	# is the contracted phase-4 beat).
	_play_hero_pop()
	haptic("light")
	_record_event("SIG-4")

func _play_hero_pop() -> void:
	var spec: Dictionary = _spec_for("AC-31")
	if spec.is_empty():
		return
	spec["type"] = "potion_use"
	spec["critical"] = true
	spec["units"] = 1
	var segs: Array = spec.get("segments", [])
	for seg in segs:
		seg["ticks"] = Ticks.ms_to_ticks(_tun("juice.potion.hero_pop_ms", 120.0))
	engine.request(spec)

func _play_flash(node_key: String, peak: float, ms_key: String, tint: Color) -> void:
	if not _overlay_nodes.has(node_key):
		return
	var rect: ColorRect = _overlay_nodes[node_key]
	var half: bool = _reduce_motion and node_key in ["flash", "class_tint"]
	var actual_peak: float = peak * (0.5 if half else 1.0)
	var ticks: int = Ticks.ms_to_ticks(_tun(ms_key, 120.0))
	rect.color = Color(tint.r, tint.g, tint.b, actual_peak)
	var tw: Dictionary = {
		"ac": "flash_" + node_key, "type": "potion_use" if node_key != "flash" else "potion_use",
		"units": 1, "critical": true, "priority": 3, "ambient": false, "world": false,
		"cap": 1, "overflow": "reject",
		"segments": [{"apply": func(v: float) -> void: rect.color.a = v, "kind": "float", "from": actual_peak, "to": 0.0, "ticks": ticks, "easing": "cubic_out", "delay_ticks": 0}],
	}
	engine.request(tw)

func _class_tint() -> Color:
	if tunables == null:
		return Color("#8B0000")
	# class identity colors ship as fixed keys; the active class arrives via
	# the last snapshot's "class" field when bound, warrior fallback
	var cls: String = str(_last_class) if _last_class != "" else "warrior"
	return tunables.get_color("juice.class.tint." + cls, Color("#8B0000"))

var _last_class: String = ""

# ============================================================ SIG-5 The Gold Door

func _on_floor_clear() -> void:
	# G9 §9 attract-mode suppression: while the title attract reel plays, the
	# floor-clear PRESENTATION (caption/banner/hitstop/SIG5BorderRect/darken/
	# camera) is suppressed. The cue still records for telemetry — on_cue's
	# trailing "cue:" event rides regardless; only the visuals skip.
	if _in_attract_mode():
		_record_event("SIG-5-suppressed-attract")
		return
	request_hitstop("HS-4")
	shake("clear")
	play_ac("AC-53")   # phase 2 darken
	_play_sig5_border()  # phases 3-4 golden border
	play_ac("AC-54")   # phase 5 banner in
	camera_drift_to_exit_and_back(_tun("juice.camera.clear_drift_ms", 600.0), _tun("juice.camera.clear_return_ms", 400.0))  # phases 6-7
	haptic("light")
	_record_event("SIG-5")
	_schedule_banner_out()

func _play_sig5_border() -> void:
	if not _overlay_nodes.has("sig5"):
		return
	var rect: Node = _overlay_nodes["sig5"]
	var ticks: int = Ticks.ms_to_ticks(_tun("juice.sig5.border_fade_ms", 400.0))
	var half_ticks: int = maxi(1, ticks / 2)
	var alpha_peak: float = 0.5 if _reduce_motion else 1.0  # G9 RM: alpha halved
	var scale_on: bool = not _reduce_motion  # G9 RM: scale motion OFF (static 1.0)
	var sticks: int = Ticks.ms_to_ticks(_tun("juice.sig5.border_scale_ms", 400.0))
	var fade: Array = [
		{"apply": func(v: float) -> void: rect.modulate.a = v, "kind": "float", "from": 0.0, "to": alpha_peak, "ticks": half_ticks, "easing": "cubic_out", "delay_ticks": 0},
		{"apply": func(v: float) -> void: rect.modulate.a = v, "kind": "float", "from": alpha_peak, "to": 0.0, "ticks": half_ticks, "easing": "cubic_out", "delay_ticks": 0},
	]
	var spec: Dictionary = {
		"ac": "AC-SIG5", "type": "sig5", "units": 2, "critical": true, "priority": 3,
		"ambient": false, "world": false, "cap": 1, "overflow": "reject", "segments": fade,
	}
	engine.request(spec)
	if scale_on:
		var shalf: int = maxi(1, sticks / 2)
		var sspec: Dictionary = {
			"ac": "AC-SIG5-scale", "type": "sig5", "units": 1, "critical": true, "priority": 3,
			"ambient": false, "world": false, "cap": 0, "overflow": "reject",
			"segments": [
				{"apply": func(v: float) -> void: rect.scale = Vector2(v, v), "kind": "float", "from": 1.0, "to": 1.02, "ticks": shalf, "easing": "cubic_out", "delay_ticks": 0},
				{"apply": func(v: float) -> void: rect.scale = Vector2(v, v), "kind": "float", "from": 1.02, "to": 1.0, "ticks": shalf, "easing": "cubic_out", "delay_ticks": 0},
			],
		}
		engine.request(sspec)

var _banner_out_countdown: int = -1

func _schedule_banner_out() -> void:
	var dwell: int = Ticks.ms_to_ticks(_tun("juice.floor.banner_hold_ms", 600.0))
	var in_ms: int = Ticks.ms_to_ticks(_tun("juice.floor.banner_in_ms", 250.0))
	_banner_out_countdown = in_ms + dwell

# ============================================================ caption lifecycle (AC-26/27/28)

var _caption_out_countdown: int = -1
var _caption_show: Callable = Callable()

## PlayScreen attaches the CaptionBand text lane (composition root owns the
## node; the director owns only the motion). func(text: String) -> void.
func attach_caption(handler: Callable) -> void:
	_caption_show = handler

## G9 caption lifecycle — in (AC-26) → dwell (AC-27) → out (AC-28), all
## step-counted, mirroring the SIG-5 banner pattern. The TEXT itself rides the
## attached CaptionBand handler (G3 copy + 2s minimum hold live there); this
## method owns the contracted motion and the exactly-once out tween. Round-5
## fix: AC-28 previously had no implementation site (ledger 064cf689a9e3).
func play_caption(text: String) -> void:
	if text == "":
		return
	if _caption_show.is_valid():
		_caption_show.call(text)
	play_ac("AC-26")
	_schedule_caption_out()
	_record_event("caption")

func _schedule_caption_out() -> void:
	# why: dwell floors at G3's two-second caption minimum (CaptionBand parity —
	# 120 fixed steps) even though juice.caption.dwell_ms defaults to 1400ms;
	# the out fade (juice.caption.out_ms) fires once the dwell lapses.
	var dwell: int = maxi(Ticks.ms_to_ticks(_tun("juice.caption.dwell_ms", 1400.0)), 120)
	var in_ms: int = Ticks.ms_to_ticks(_tun("juice.caption.in_ms", 160.0))
	_caption_out_countdown = in_ms + dwell

# ============================================================ AC-33 hero hurt / death

func _on_hero_hurt() -> void:
	_play_hero_hurt()

func _play_hero_hurt() -> void:
	# phase 1: hurt modulate set red -> white 80ms (world tween — critical)
	if _world_view != null and _world_view.has_method("hero_hurt_flash"):
		var ms: float = _tun("juice.hero.hurt_modulate_ms", 80.0)
		if _reduce_motion:
			ms = ms / 2.0  # G9 RM: duration halved 80 -> 40
		_world_view.hero_hurt_flash(Ticks.ms_to_ticks(ms))
	# phase 2: HP numeral pop back-out 100ms 1.0 -> 1.12 -> 1.0
	var pop: Dictionary = _spec_for("AC-15")
	if not pop.is_empty():
		pop["ac"] = "AC-33-pop"
		pop["type"] = "hero_hurt"
		pop["critical"] = true
		pop["priority"] = 3
		var segs: Array = pop.get("segments", [])
		for seg in segs:
			seg["ticks"] = Ticks.ms_to_ticks(_tun("juice.hero.hurt_pop_ms", 100.0) / 2.0)
			if seg.has("to_key"):
				seg["to"] = _tun("juice.hero.hurt_pop_scale", 1.12)
				seg.erase("to_key")
			if seg.has("from_key"):
				seg["from"] = _tun("juice.hero.hurt_pop_scale", 1.12)
				seg.erase("from_key")
			seg["easing"] = "back_out"
		engine.request(pop)
	# phase 3: screen-edge red flash set 0.15 -> 0 (RM: intensity halved)
	var edge_alpha: float = _tun("juice.hero.hurt_edge_alpha", 0.15)
	if _reduce_motion:
		edge_alpha = 0.075
	_play_flash("screen_edge", edge_alpha, "juice.hero.hurt_edge_flash_ms", Color("#D94836"))
	_record_event("AC-33")

func _on_hit_confirm() -> void:
	play_ac("AC-35")  # G9: enemy knockback (world tween; per-entity projection note in G10 brief)
	request_hitstop("HS-1")  # G9: light-hit 2f freeze (handshake beat 4; B3 fix: contract row existed, no call site)
	# haptic light on hit confirm, throttled max 1 per juice.haptic.hit.throttle_ms
	if _haptic_hit_cooldown_ticks <= 0:
		haptic("light")
		_haptic_hit_cooldown_ticks = Ticks.ms_to_ticks(_tun("juice.haptic.hit.throttle_ms", 200.0))

func _on_enemy_killed() -> void:
	if streak_manager != null:
		streak_manager.register_kill()
	_apply_streak_scale()

func _on_throw() -> void:
	play_ac("AC-31")
	play_ac("AC-32")

func _on_key_pickup() -> void:
	play_ac("AC-48")
	play_ac("AC-24")
	haptic("light")

func _on_player_death() -> void:
	play_ac("AC-57")
	play_ac("AC-58")
	shake("death")
	haptic("heavy")
	stop_ambient_type("hp_vignette")
	stop_ambient_type("hp_pulse_freq")

func _on_enemy_spawned(ai_type: int, pos: Vector2) -> void:
	play_ac("AC-38")
	# AC-52 void-bridge warning pulse: Death-type spawns near the bridges
	# (HUNGERHALL ai_type 5 = cleaver-brute "death", actor_sprites.gd:19)
	if ai_type == 5:
		_play_void_bridge_pulse(pos)
		particle_burst("PT-17", pos, Color("#8169AE"))

## AC-52 — void-bridge warning pulse: 0 → peak → 0, sequential chain ×cycles
## (juice.ac52.cycles), cubic-in-out, 900ms on / 300ms off (both argued inline
## in G9 §2). Suppress under Reduce Motion (ambient-loop family) and attract.
func _play_void_bridge_pulse(pos: Vector2) -> void:
	if _reduce_motion or _in_attract_mode():
		return
	var cycles: int = int(_tun("juice.ac52.cycles", 3.0))
	var on_ticks: int = Ticks.ms_to_ticks(_tun("juice.ac52.on_ms", 900.0))
	var off_ticks: int = Ticks.ms_to_ticks(_tun("juice.ac52.off_ms", 300.0))
	var peak: float = _tun("juice.ac52.alpha_peak", 0.25)
	var segs: Array = []
	for _i in range(cycles):
		segs.append({"prop": "void_bridge.alpha", "kind": "float", "from": 0.0, "to": peak, "ticks": on_ticks, "easing": "cubic_in_out", "delay_ticks": 0})
		segs.append({"prop": "void_bridge.alpha", "kind": "float", "from": peak, "to": 0.0, "ticks": off_ticks, "easing": "cubic_in_out", "delay_ticks": 0})
	if void_bridge_manager != null:
		void_bridge_manager.trigger(pos, (on_ticks + off_ticks) * cycles)
	if _world_view != null and _world_view.has_method("place_void_bridge"):
		_world_view.place_void_bridge(pos)
	var spec: Dictionary = {
		"ac": "AC-52", "type": "void_bridge", "units": 2, "critical": false, "priority": 1,
		"ambient": false, "world": true, "cap": 2, "overflow": "reject", "segments": segs,
	}
	engine.request(spec)
	_record_event("AC-52")

func _on_flame_adjacent() -> void:
	# AC-Flame entry then flicker loop; called by play.gd hazard proximity
	if _flame_ticks_left > 0:
		return
	_flame_ticks_left = Ticks.ms_to_ticks(_tun("juice.acflame.loop_period_ms", 200.0)) * 2
	play_ac("AC-Flame")
	if _reduce_motion:
		# G9 RM: flicker OFF, static at 0.6 alpha
		if _overlay_nodes.has("hero_flame"):
			(_overlay_nodes["hero_flame"] as Node).modulate.a = 0.6
	else:
		start_ambient("AC-Flame-L")

func _flame_overlay_exit() -> void:
	stop_ambient_type("flame_loop")
	play_ac("AC-Flame-X")

# ============================================================ streaks

func _apply_streak_scale() -> void:
	if _reduce_motion:
		return  # G9 RM: AC-Streak brightness bonus OFF
	var tiers: int = int(streak_manager.get("tier"))
	if tiers <= 0:
		return
	var spec: Dictionary = _spec_for("AC-21")
	if spec.is_empty():
		return
	spec["ac"] = "AC-Streak"
	spec["type"] = "streak_scale"
	var mult: float = _tun("juice.streak.scale_mult_per_tier", 0.05)
	var peak: float = 1.0 + mult * float(tiers)
	var segs: Array = spec.get("segments", [])
	for seg in segs:
		seg["prop"] = "hero.streak_scale"
		if seg.has("to_key"):
			seg.erase("to_key")
		if seg.has("from_key"):
			seg.erase("from_key")
	var first: Dictionary = segs[0]
	first["from"] = 1.0
	first["to"] = peak
	first["easing"] = "back_out"
	if segs.size() > 1:
		var second: Dictionary = segs[1]
		second["from"] = peak
		second["to"] = 1.0
	engine.request(spec)

# ============================================================ particles + floaters

func particle_burst(ptype: String, pos: Vector2, tint: Color) -> void:
	var table: Dictionary = JuiceContracts.particle_table()
	if not table.has(ptype):
		return
	var row: Dictionary = table[ptype]
	var count: int = int(row.get("count", 4))
	var life_ticks: int = Ticks.ms_to_ticks(float(row.get("life_s", 0.3)) * 1000.0)
	var critical: bool = bool(row.get("critical", false))
	var max_inst: int = int(row.get("max_inst", 1))
	# why: G9 §3 — counts are HARD caps, enforced in code by the ParticleManager
	# ledger before anything reaches the projection (per-type caps apply to
	# critical particles too; global eviction never kills critical emitters)
	if particle_manager != null:
		if not particle_manager.request(ptype, count, life_ticks, critical, max_inst):
			_record_event("particle_capped:" + ptype)
			return
	if _world_view == null or not _world_view.has_method("juice_burst"):
		return
	var cap: int = int(tunables.get_int("juice.particles.global_cap", 160)) if tunables != null else 160
	_world_view.juice_burst(ptype, pos, tint, count, float(row.get("life_s", 0.3)), max_inst, critical, cap)

func _spawn_death_ghost(ptype: String, pos: Vector2, tex_path: String, scale_ms_key: String, fade_ms_key: String, start_scale: float) -> void:
	# AC-36 / AC-43 phases 2-3: the victim sprite collapses (set peak -> 0)
	# while its particles fly — played as engine tweens over a ghost sprite so
	# the fixed-step budget gates own it like every other contract
	if _world_view == null or not _world_view.has_method("spawn_ghost"):
		return
	var ghost: Variant = _world_view.spawn_ghost(pos, tex_path)
	if ghost == null:
		return
	var g: Node2D = ghost
	g.scale = Vector2(start_scale, start_scale)
	var st: int = Ticks.ms_to_ticks(_tun(scale_ms_key, 200.0))
	var ft: int = Ticks.ms_to_ticks(_tun(fade_ms_key, 200.0))
	var spec: Dictionary = {
		"ac": "ghost_" + ptype, "type": "enemy_death" if ptype != "PT-06" else "gen_destroy",
		"units": 2, "critical": ptype == "PT-06", "priority": 3 if ptype == "PT-06" else 2,
		"ambient": false, "world": true,
		"cap": 2 if ptype == "PT-06" else 4, "overflow": "snap_oldest",
		"segments": [
			{"apply": func(v: float) -> void: g.scale = Vector2(v, v) if is_instance_valid(g) else null, "kind": "float", "from": start_scale, "to": 0.0, "ticks": st, "easing": "cubic_out", "delay_ticks": 0, "set_instant": true},
			{"apply": func(v: float) -> void: g.modulate.a = v if is_instance_valid(g) else null, "kind": "float", "from": 1.0, "to": 0.0, "ticks": ft, "easing": "cubic_out", "delay_ticks": Ticks.ms_to_ticks(_tun("juice.enemy.death_fade_delay_ms", 0.0))},
		],
	}
	var done_marker: Dictionary = {"freed": false}
	spec["segments"][1]["apply"] = func(v: float) -> void:
		if is_instance_valid(g):
			g.modulate.a = v
			if v <= 0.01 and not done_marker.freed:
				done_marker.freed = true
				g.queue_free()
	engine.request(spec)

func _floater_at(pos: Vector2, text: String, color: Color) -> void:
	if text == "" or _world_view == null or not _world_view.has_method("juice_floater"):
		return
	_world_view.juice_floater(pos, text, color)

# ============================================================ zone tint

## G9 §2 ambient rows that belong to a floor's SETTLE state, started once at
## every floor begin (incl. floor 1 — see the notify_snapshot branch):
##   AC-42 generator idle pulse — 1 instance per live generator, max 4 (G9 §10
##         ambient per-type cap 4; 5th oldest-stops is moot under the max-4 start);
##   AC-45 exit idle glow      — exactly 1 instance;
##   AC-46 pickup idle bob     — 1 instance per remaining pickup, max 6
##         (G9 §10: 7th = static/no bob — we simply never start a 7th).
## Reduce Motion: start_ambient() refuses ALL ambients (G9 accessibility).
## A floor change stops the previous floor's instances first so the per-type
## caps never accumulate across floors.
func _start_floor_ambients(snap: Dictionary) -> void:
	engine.stop_type("gen_idle")
	engine.stop_type("exit_glow")
	engine.stop_type("pickup_bob")
	var gens: int = 0
	for g in snap.get("generators", []):
		if g is Dictionary and bool(g.get("alive", true)):
			gens += 1
	for _i in range(mini(gens, 4)):
		play_ac("AC-42")
	play_ac("AC-45")
	var pickups: int = int(snap.get("food_remaining", 0)) + int(snap.get("keys_held", 0)) + int(snap.get("potions", 0))
	for _i in range(mini(pickups, 6)):
		play_ac("AC-46")
	_record_event("floor_ambients_started")

## G9 zone atmosphere rows (AC-Zone1-4) — persistent ColorRect, normal blend.
func _zone_color(floor_n: int) -> Color:
	var zone: String = JuiceContracts.zone_for_floor(floor_n)
	if tunables == null:
		return Color("#0D1F2D")
	return tunables.get_color("juice.zone." + zone + "_tint", Color("#0D1F2D"))

func _zone_alpha(floor_n: int) -> float:
	var zone: String = JuiceContracts.zone_for_floor(floor_n)
	return _tun("juice.zone." + zone + "_alpha", 0.15)

# ============================================================ telemetry seam

func _record_event(ev: String) -> void:
	juice_events.append({"event": ev, "step": _step})
	if juice_events.size() > 4096:
		juice_events.pop_front()

func juice_event_count() -> int:
	return juice_events.size()

func juice_event_histogram() -> Dictionary:
	var hist: Dictionary = {}
	for e in juice_events:
		var k: String = str(e.get("event", ""))
		hist[k] = int(hist.get(k, 0)) + 1
	return hist

# ============================================================ G9 Asset Delivery
## "If any asset fails ResourceLoader load at runtime: log the failure,
## substitute a visible 32×32 magenta ColorRect (unmistakable error color),
## and flag asset_debt in telemetry. The game continues; the gap is visible,
## not silent."

func record_asset_debt(semantic_id: String) -> void:
	if semantic_id == "" or asset_debt.has(semantic_id):
		return
	asset_debt.append(semantic_id)
	push_error("JuiceDirector: asset_debt flagged — " + semantic_id)

## G9 fallback marker — 32×32 magenta ColorRect, mouse-transparent.
func make_fallback_marker() -> ColorRect:
	var rect: ColorRect = ColorRect.new()
	rect.color = Color("#FF00FF")
	rect.size = Vector2(32, 32)
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return rect

## Runtime load through the fallback seam: non-null Texture2D on success;
## on failure logs, flags asset_debt, and returns null — callers substitute
## make_fallback_marker() where a visual must exist (WorldView.spawn_ghost).
func load_asset(path: String, semantic_id: String) -> Texture2D:
	if path != "" and ResourceLoader.exists(path):
		var res: Resource = ResourceLoader.load(path)
		if res is Texture2D:
			return res
	record_asset_debt(semantic_id if semantic_id != "" else path)
	return null
