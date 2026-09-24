extends RefCounted
## test_juice_director_behavior — G9 §10 test-matrix behavior battery on the
## real JuiceDirector class (run OUT of the scene tree, exactly like the bot's
## headless recorder): SIG composite positives + negatives, Reduce Motion,
## haptics-off, colorblind HP labels, the caption in→hold→out lifecycle
## (AC-26/27/28 — round-5 fix), the AC-37 telegraph two-lane trigger
## (round-5 fix), particle caps + critical survival, and the asset-debt
## fallback. All checks are step-counted or source-structural — never
## wall-clock (G9 "frame-rate assertions are structural").

class SettingsStub:
	extends Node
	var settings: Dictionary = {"reduced_motion": false, "rumble_intensity": 100}
	func reduced_motion_enabled() -> bool:
		return bool(settings.get("reduced_motion", false))

class AttractStub:
	extends Node
	var attract_mode: bool = true

class WorldStub:
	extends Node
	var telegraph_calls: Array = []
	var shake_calls: Array = []
	var hero_hurt_calls: Array = []
	func telegraph_actor(eid: int, ticks: int) -> void:
		telegraph_calls.append({"eid": eid, "ticks": ticks})
	func shake(mag: float, ticks: int, falloff: String) -> void:
		shake_calls.append({"mag": mag, "ticks": ticks, "falloff": falloff})
	func hero_hurt_flash(ticks: int) -> void:
		hero_hurt_calls.append(ticks)

func _ok(msg: String = "") -> Dictionary:
	return {"ok": true, "msg": msg}

func _fail(msg: String) -> Dictionary:
	return {"ok": false, "msg": msg}

# why: round-7 set a zero-leak bar at exit; every Node this suite creates
# (JuiceDirector + its 5 add_child'd sub-managers, SettingsStub, the
# standalone ParticleManager probes, and the WorldStub the RM twin never
# freed) is tracked here and freed by teardown() — the runner calls it after
# every test (test_runner.gd:79), so early-return failures leak nothing.
var _owned: Array = []

func teardown() -> void:
	for n in _owned:
		if is_instance_valid(n) and n is Node:
			n.free()
	_owned.clear()

## Headless director, mirroring ci/sneferu_bot.gd's recorder setup.
func _director(rm: bool = false, rumble: int = 100) -> Array:
	var tun: TunablesLoader = TunablesLoader.new()
	if not tun.load_from_path("res://Tunables.json"):
		return []
	var settings: SettingsStub = SettingsStub.new()
	settings.settings["reduced_motion"] = rm
	settings.settings["rumble_intensity"] = rumble
	var d: JuiceDirector = JuiceDirector.new()
	d.setup(tun, settings)
	_owned.append(d)
	_owned.append(settings)
	return [d, settings]

func _hist(d: JuiceDirector) -> Dictionary:
	return d.juice_event_histogram()

# ============================================================ SIG composites (G9 matrix: 1 pos + 1 neg each)

func test_sig1_heartbeat_pulse_and_band_thresholds() -> Dictionary:
	var arr: Array = _director()
	if arr.is_empty():
		return _fail("tunables failed to load")
	var d: JuiceDirector = arr[0]
	d.on_cue({"cue_id": "cue.hp.tick", "step": 1})
	if int(_hist(d).get("AC-15", 0)) != 1:
		return _fail("cue.hp.tick must play AC-15 (SIG-1 drain pulse)")
	# negative: a snapshot with UNCHANGED hp adds no band events
	d.notify_snapshot({"player": {"hp": 800, "max_hp": 800}, "floor": 1, "score": {"score": 0}, "class": "warrior"})
	var before: int = d.juice_event_count()
	d.notify_snapshot({"player": {"hp": 800, "max_hp": 800}, "floor": 1, "score": {"score": 0}, "class": "warrior"})
	if d.juice_event_count() != before:
		return _fail("unchanged HP must not fire new juice events")
	return _ok()

func test_sig1_colorblind_labels_at_all_three_thresholds() -> Dictionary:
	var arr: Array = _director()
	var d: JuiceDirector = arr[0]
	var label: Label = Label.new()
	var vignette: ColorRect = ColorRect.new()
	d.set_overlay_nodes({"hp_status": label, "vignette": vignette})
	# baseline full HP (band 0), then cross 50% / 25% / 10%
	d.notify_snapshot({"player": {"hp": 800, "max_hp": 800}, "floor": 1, "score": {"score": 0}})
	d.notify_snapshot({"player": {"hp": 380, "max_hp": 800}, "floor": 1, "score": {"score": 0}})  # 47.5% -> FAIR
	if label.text != "FAIR":
		return _fail("HP <=50%% must set HPStatusLabel FAIR instantly (colorblind channel), got '%s'" % label.text)
	if int(_hist(d).get("AC-16b", 0)) != 1:
		return _fail("AC-16b (FAIR label tween) must fire at the 50%% threshold")
	d.notify_snapshot({"player": {"hp": 180, "max_hp": 800}, "floor": 1, "score": {"score": 0}})  # 22.5% -> LOW
	if label.text != "LOW":
		return _fail("HP <=25%% must set HPStatusLabel LOW, got '%s'" % label.text)
	if int(_hist(d).get("AC-17c", 0)) != 1:
		return _fail("AC-17c must fire at the 25%% threshold")
	d.notify_snapshot({"player": {"hp": 60, "max_hp": 800}, "floor": 1, "score": {"score": 0}})  # 7.5% -> CRITICAL
	if label.text != "CRITICAL":
		return _fail("HP <=10%% must set HPStatusLabel CRITICAL, got '%s'" % label.text)
	if int(_hist(d).get("AC-17b", 0)) != 1:
		return _fail("AC-17b must fire at the 10%% threshold")
	label.free()
	vignette.free()
	return _ok()

func test_sig2_generator_destroyed_composite() -> Dictionary:
	var arr: Array = _director()
	var d: JuiceDirector = arr[0]
	d.on_cue({"cue_id": "cue.generator.destroyed", "step": 10})
	var h: Dictionary = _hist(d)
	if int(h.get("hitstop_HS-2", 0)) != 1:
		return _fail("SIG-2 must request the HS-2 generator hitstop")
	if int(h.get("AC-26", 0)) != 1:
		return _fail("SIG-2 must play the caption-in leg (AC-26)")
	if int(h.get("haptic:medium", 0)) != 1:
		return _fail("SIG-2 must request the medium haptic (G9 §5 row 3)")
	if int(h.get("cue:cue.generator.destroyed", 0)) != 1:
		return _fail("the cue itself must record for telemetry")
	if not d.hitstop_active():
		return _fail("hitstop must be active the tick after SIG-2 (4f default)")
	return _ok()

func test_sig3_first_food_full_then_routine() -> Dictionary:
	var arr: Array = _director()
	var d: JuiceDirector = arr[0]
	d.on_cue({"cue_id": "cue.pickup.food", "step": 5})
	var h: Dictionary = _hist(d)
	if int(h.get("SIG-3", 0)) != 1 or int(h.get("AC-47", 0)) != 1:
		return _fail("FIRST food must play the full AC-47 composite + SIG-3 marker")
	d.on_cue({"cue_id": "cue.pickup.food", "step": 50})
	h = _hist(d)
	if int(h.get("SIG-3", 0)) != 1:
		return _fail("routine food must NOT re-fire SIG-3 (negative)")
	if int(h.get("AC-47r", 0)) != 1:
		return _fail("routine food must play AC-47r")
	return _ok()

func test_sig4_potion_cooldown_rejects_replay() -> Dictionary:
	var arr: Array = _director()
	var d: JuiceDirector = arr[0]
	d.on_cue({"cue_id": "cue.player.potion", "step": 5})
	if int(_hist(d).get("SIG-4", 0)) != 1 or int(_hist(d).get("hitstop_HS-3", 0)) != 1:
		return _fail("first potion must fire SIG-4 + HS-3")
	d.on_cue({"cue_id": "cue.player.potion", "step": 6})  # inside cooldown (1000ms = 60 ticks)
	if int(_hist(d).get("SIG-4", 0)) != 1:
		return _fail("2nd potion inside juice.potion.cooldown_ms must be REJECTED (negative)")
	for i in range(61):
		d.step()
	d.on_cue({"cue_id": "cue.player.potion", "step": 70})
	if int(_hist(d).get("SIG-4", 0)) != 2:
		return _fail("potion after the cooldown lapses must fire again")
	return _ok()

func test_sig5_floor_clear_and_banner_out_exactly_once() -> Dictionary:
	var arr: Array = _director()
	var d: JuiceDirector = arr[0]
	d.on_cue({"cue_id": "cue.floor.clear", "step": 5})
	var h: Dictionary = _hist(d)
	for key in ["SIG-5", "hitstop_HS-4", "AC-53", "AC-54", "haptic:light"]:
		if int(h.get(key, 0)) != 1:
			return _fail("SIG-5 missing component %s (hist %s)" % [key, str(h)])
	# banner out (AC-56) fires after the in+dwell countdown — exactly once.
	# Countdown is step-counted from the SAME tunables the director reads.
	var in_ticks: int = JuiceTweenEngine.ms_to_ticks(d.tunables.get_value("juice.floor.banner_in_ms", 250.0))
	var hold_ticks: int = JuiceTweenEngine.ms_to_ticks(d.tunables.get_value("juice.floor.banner_hold_ms", 600.0))
	for i in range(in_ticks + hold_ticks + 2):
		d.step()
	if int(_hist(d).get("AC-56", 0)) != 1:
		return _fail("AC-56 banner out must fire within the dwell window, got %d" % int(_hist(d).get("AC-56", 0)))
	for i in range(60):
		d.step()
	if int(_hist(d).get("AC-56", 0)) != 1:
		return _fail("AC-56 fired more than once (negative)")
	return _ok()

func test_sig5_suppressed_in_attract_mode() -> Dictionary:
	var arr: Array = _director()
	var d: JuiceDirector = arr[0]
	var stub: AttractStub = AttractStub.new()
	stub.name = "AttractStub"
	d.add_child(stub)
	d.state_machine_path = d.get_path_to(stub)
	stub.attract_mode = true
	d.on_cue({"cue_id": "cue.floor.clear", "step": 5})
	var h: Dictionary = _hist(d)
	if int(h.get("SIG-5-suppressed-attract", 0)) != 1:
		return _fail("attract-mode floor clear must record the suppression marker")
	if int(h.get("SIG-5", 0)) != 0 or int(h.get("hitstop_HS-4", 0)) != 0:
		return _fail("attract mode must suppress SIG-5 presentation (negative)")
	if int(h.get("cue:cue.floor.clear", 0)) != 1:
		return _fail("the cue must still record for telemetry even when suppressed")
	stub.free()
	return _ok()

# ============================================================ caption lifecycle — AC-26/27/28 (round-5 fix)

func test_caption_in_hold_out_lifecycle() -> Dictionary:
	var arr: Array = _director()
	var d: JuiceDirector = arr[0]
	var got: Dictionary = {"key": ""}
	d.attach_caption(func(key: String) -> void: got["key"] = key)
	d.play_caption("caption.food")
	if str(got.get("key")) != "caption.food":
		return _fail("play_caption must deliver the key to the attached CaptionBand lane")
	var h: Dictionary = _hist(d)
	if int(h.get("AC-26", 0)) != 1 or int(h.get("caption", 0)) != 1:
		return _fail("caption in must play AC-26 + record the caption event")
	# G9 countdown = in (160ms = 10 ticks) + dwell (max(1400ms=84, G3 2s=120))
	var in_ticks: int = JuiceTweenEngine.ms_to_ticks(160.0)
	var dwell_ticks: int = maxi(JuiceTweenEngine.ms_to_ticks(1400.0), 120)
	var out_at: int = in_ticks + dwell_ticks
	for i in range(out_at - 1):
		d.step()
	if int(_hist(d).get("AC-28", 0)) != 0:
		return _fail("AC-28 fired before the contracted in+dwell window")
	d.step()
	if int(_hist(d).get("AC-28", 0)) != 1:
		return _fail("AC-28 caption out must fire exactly at in+dwell (round-5 fix — was zero-trigger)")
	for i in range(30):
		d.step()
	if int(_hist(d).get("AC-28", 0)) != 1:
		return _fail("AC-28 fired more than once (negative)")
	return _ok()

# ============================================================ AC-37 telegraph — two-lane trigger (round-5 fix)

func test_ac37_telegraph_cue_and_event_lanes() -> Dictionary:
	var arr: Array = _director()
	var d: JuiceDirector = arr[0]
	var world: WorldStub = WorldStub.new()
	d.attach_world(world)
	d.on_cue({"cue_id": "cue.enemy.telegraph", "step": 9})
	if int(_hist(d).get("AC-37", 0)) != 1:
		return _fail("cue.enemy.telegraph must play AC-37 (round-5 fix — was zero-trigger)")
	var tw: Array = d.engine.tweens_of_type("telegraph")
	if tw.size() != 1:
		return _fail("AC-37 must occupy exactly one telegraph tween")
	var segs: Array = (tw[0] as Dictionary).get("segments", [])
	if segs.is_empty() or int((segs[0] as Dictionary).get("ticks", -1)) != JuiceTweenEngine.ms_to_ticks(250.0):
		return _fail("AC-37 duration must resolve to juice.enemy.telegraph_ms (250ms = %d ticks)" % JuiceTweenEngine.ms_to_ticks(250.0))
	# event lane: per-actor projection carries the entity id
	d.consume_events([{"type": "enemy_telegraph", "position": [96.0, 64.0], "entity_id": 7, "amount": 0}])
	if world.telegraph_calls.size() != 1:
		return _fail("enemy_telegraph event must drive WorldView.telegraph_actor")
	if int(world.telegraph_calls[0].get("eid", -1)) != 7:
		return _fail("telegraph projection must target the firing enemy (eid 7)")
	if int(world.telegraph_calls[0].get("ticks", -1)) != JuiceTweenEngine.ms_to_ticks(250.0):
		return _fail("telegraph projection window must equal juice.enemy.telegraph_ms")
	world.free()
	return _ok()

# ============================================================ new trigger sites land where the screens wire them (round-5)

func _file_text(path: String) -> String:
	var f: FileAccess = FileAccess.open(path, FileAccess.READ)
	if f == null:
		return ""
	var t: String = f.get_as_text()
	f.close()
	return t

func test_ac59_ac60_floor_results_trigger_site() -> Dictionary:
	var src: String = _file_text("res://app/screens/floor_results.gd")
	if src == "":
		return _fail("floor_results.gd unreadable")
	for needle in ["play_ac(\"AC-59\")", "play_ac(\"AC-60\")", "results.y", "results.alpha", "results.countup"]:
		if src.find(needle) < 0:
			return _fail("floor_results.gd lost its %s wiring (AC-59/AC-60 zero-trigger regression)" % needle)
	# behavior twin: the director actually accepts both rows with contracted durations
	var arr: Array = _director()
	var d: JuiceDirector = arr[0]
	if not d.play_ac("AC-59") or not d.play_ac("AC-60"):
		return _fail("AC-59/AC-60 rejected by the budget gates")
	var panel: Array = d.engine.tweens_of_type("results_panel")
	var countup: Array = d.engine.tweens_of_type("results_countup")
	if panel.is_empty() or countup.is_empty():
		return _fail("AC-59/AC-60 did not produce their contracted tweens")
	var pseg: Dictionary = (panel[0] as Dictionary).get("segments", [])[0]
	if int(pseg.get("ticks", -1)) != JuiceTweenEngine.ms_to_ticks(250.0):
		return _fail("AC-59 panel duration must resolve juice.results.panel_ms (250ms)")
	var cseg: Dictionary = (countup[0] as Dictionary).get("segments", [])[0]
	if int(cseg.get("ticks", -1)) != JuiceTweenEngine.ms_to_ticks(350.0):
		return _fail("AC-60 count-up duration must resolve juice.results.countup_ms (350ms)")
	return _ok()

func test_ac62_game_over_trigger_site() -> Dictionary:
	var src: String = _file_text("res://app/screens/game_over.gd")
	if src == "":
		return _fail("game_over.gd unreadable")
	for needle in ["play_ac(\"AC-62\")", "gameover.alpha", "gameover.scale"]:
		if src.find(needle) < 0:
			return _fail("game_over.gd lost its %s wiring (AC-62 zero-trigger regression)" % needle)
	var arr: Array = _director()
	var d: JuiceDirector = arr[0]
	if not d.play_ac("AC-62"):
		return _fail("AC-62 rejected by the budget gates")
	var entry: Array = d.engine.tweens_of_type("gameover_entry")
	if entry.is_empty():
		return _fail("AC-62 did not produce its tween")
	var seg: Dictionary = (entry[0] as Dictionary).get("segments", [])[0]
	if int(seg.get("ticks", -1)) != JuiceTweenEngine.ms_to_ticks(500.0):
		return _fail("AC-62 duration must resolve juice.gameover.entry_ms (500ms, scene-boundary exception)")
	return _ok()

# ============================================================ accessibility battery (G9 matrix: 3)

func test_reduce_motion_battery() -> Dictionary:
	var arr: Array = _director(true)
	var d: JuiceDirector = arr[0]
	var settings: SettingsStub = arr[1]
	d.step()  # refresh _reduce_motion from the settings source
	# 1. ALL ambient loops OFF under RM (G9 accessibility row)
	if d.start_ambient("AC-42"):
		return _fail("Reduce Motion must refuse ambient loops (AC-42)")
	# 2. shake OFF under RM
	var world: WorldStub = WorldStub.new()
	d.attach_world(world)
	d.shake("generator")
	if not world.shake_calls.is_empty():
		return _fail("Reduce Motion must suppress all screen shake")
	# 3. hurt-modulate duration HALVED (G9 RM row: AC-33 phase 1, 80ms -> 40ms
	# = 5 -> 2 ticks). Observed on the projection seam — AC-34's own row is a
	# set_instant flash whose duration resolves at request time, so the
	# contract-named halving is pinned where G9 names it: the hurt modulate.
	d.on_cue({"cue_id": "cue.player.hurt", "step": 3})
	if world.hero_hurt_calls.size() != 1:
		return _fail("cue.player.hurt must drive the hero hurt-modulate projection")
	if int(world.hero_hurt_calls[0]) != JuiceTweenEngine.ms_to_ticks(40.0):
		return _fail("hurt modulate under RM must halve 80ms->40ms (%d ticks), got %s" % [JuiceTweenEngine.ms_to_ticks(40.0), str(world.hero_hurt_calls[0])])
	# positive twin at full motion: the same cue resolves the unhalved 80ms
	var arr_full: Array = _director(false)
	var d_full: JuiceDirector = arr_full[0]
	var world_full: WorldStub = WorldStub.new()
	_owned.append(world_full)
	d_full.attach_world(world_full)
	d_full.on_cue({"cue_id": "cue.player.hurt", "step": 3})
	if world_full.hero_hurt_calls.size() != 1 or int(world_full.hero_hurt_calls[0]) != JuiceTweenEngine.ms_to_ticks(80.0):
		return _fail("full-motion hurt modulate must resolve the unhalved 80ms (%d ticks)" % JuiceTweenEngine.ms_to_ticks(80.0))
	# 4. low-HP vignette STATIC (no pulse loop), CRITICAL static 0.30
	var vignette: ColorRect = ColorRect.new()
	var label: Label = Label.new()
	d.set_overlay_nodes({"vignette": vignette, "hp_status": label})
	d.notify_snapshot({"player": {"hp": 60, "max_hp": 800}, "floor": 1, "score": {"score": 0}})
	d.notify_snapshot({"player": {"hp": 59, "max_hp": 800}, "floor": 1, "score": {"score": 0}})
	if absf(vignette.color.a - 0.30) > 0.001:
		return _fail("RM critical vignette must be static 0.30, got %f" % vignette.color.a)
	if not d.engine.tweens_of_type("hp_vignette").is_empty():
		return _fail("RM must not run the pulsing vignette loop")
	if not d.engine.tweens_of_type("hp_pulse_freq").is_empty():
		return _fail("RM must turn the AC-20c pulse-frequency loop OFF")
	if label.text != "CRITICAL":
		return _fail("RM keeps the colorblind text labels (sole non-color channel)")
	# 5. hitstop REMAINS under RM (a freeze is not motion)
	d.request_hitstop("HS-1")
	if not d.hitstop_active():
		return _fail("hitstop must REMAIN under Reduce Motion")
	settings.free()
	world.free()
	vignette.free()
	label.free()
	return _ok()

func test_haptics_off_records_nothing() -> Dictionary:
	var arr: Array = _director(false, 0)  # rumble_intensity 0 = system haptics OFF
	var d: JuiceDirector = arr[0]
	d.haptic("light")
	d.haptic("medium")
	d.haptic("heavy")
	var h: Dictionary = _hist(d)
	if int(h.get("haptic:light", 0)) + int(h.get("haptic:medium", 0)) + int(h.get("haptic:heavy", 0)) != 0:
		return _fail("rumble_intensity=0 must record NO haptic events")
	# positive twin: intensity on -> requests record (headless has no joypad)
	var arr2: Array = _director(false, 100)
	var d2: JuiceDirector = arr2[0]
	d2.haptic("light")
	if int(_hist(d2).get("haptic:light", 0)) != 1:
		return _fail("a passing haptic request must record for telemetry")
	return _ok()

# ============================================================ particles (G9 matrix: 2 — eviction, critical survival)

func test_particle_per_type_cap_evicts_oldest() -> Dictionary:
	var pm: ParticleManager = ParticleManager.new()
	_owned.append(pm)
	var row: Dictionary = JuiceContracts.particle_table()["PT-02"]  # max_inst 4
	for i in range(5):
		if not pm.request("PT-02", int(row.count), 30, false, int(row.max_inst)):
			return _fail("PT-02 instance %d refused" % i)
	if pm.instances_of("PT-02").size() != 4:
		return _fail("PT-02 per-type cap 4 not enforced (%d live)" % pm.instances_of("PT-02").size())
	return _ok()

func test_particle_global_cap_eviction_and_critical_survival() -> Dictionary:
	var pm: ParticleManager = ParticleManager.new()
	_owned.append(pm)
	var table: Dictionary = JuiceContracts.particle_table()
	# fill 152 non-critical particles across several eviction-order types
	var fill: Array = [["PT-16", 8], ["PT-03", 6], ["PT-02", 4], ["PT-11", 2], ["PT-13", 1], ["PT-10", 2], ["PT-08", 1], ["PT-12", 1], ["PT-01", 1]]
	var units: int = 0
	for f in fill:
		var row: Dictionary = table[f[0]]
		for i in range(int(f[1])):
			pm.request(f[0], int(row.count), 60, false, int(row.max_inst))
			units += int(row.count)
	if units != 152 or pm.particle_units() != 152:
		return _fail("fill setup wrong: %d units" % pm.particle_units())
	# a critical PT-06 burst (14) must be admitted via whole-emitter eviction
	var gen: Dictionary = table["PT-06"]
	if not pm.request("PT-06", int(gen.count), 60, true, int(gen.max_inst)):
		return _fail("critical PT-06 burst refused at 152/160 live")
	if pm.particle_units() > 160:
		return _fail("global cap 160 violated: %d live" % pm.particle_units())
	if pm.critical_units() != 14:
		return _fail("critical particles must survive global eviction")
	# eviction order is G9-contracted: PT-16 dies first
	if pm.instances_of("PT-16").size() != 6:
		return _fail("eviction must kill PT-16 first (order table), %d remain" % pm.instances_of("PT-16").size())
	# per-type cap applies to criticals too: 3rd PT-06 snaps the oldest (new wins)
	pm.request("PT-06", int(gen.count), 60, true, int(gen.max_inst))
	if pm.instances_of("PT-06").size() != 2:
		return _fail("critical per-type cap 2 not enforced")
	return _ok()

# ============================================================ G9 Asset Delivery fallback

func test_asset_debt_fallback_seam() -> Dictionary:
	var arr: Array = _director()
	var d: JuiceDirector = arr[0]
	var tex: Texture2D = d.load_asset("res://Assets/__definitely_missing__.png", "debt_probe")
	if tex != null:
		return _fail("a broken asset path must return null")
	if not d.asset_debt.has("debt_probe"):
		return _fail("the failed load must flag asset_debt (visible, never silent)")
	var marker: ColorRect = d.make_fallback_marker()
	if marker.size != Vector2(32, 32) or marker.color != Color("#FF00FF"):
		return _fail("fallback marker must be a 32x32 magenta ColorRect")
	marker.free()
	# positive twin: the governed anchor asset loads through the same seam
	var good: Texture2D = d.load_asset("res://Assets/warrior-main.png", "warrior_main")
	if good == null:
		return _fail("warrior-main.png must admit through the fallback seam")
	if d.asset_debt.has("warrior_main"):
		return _fail("a successful load must not flag asset_debt")
	return _ok()

# ============================================================ B2/B3 trigger-site closures (round 6 pair-coder)

## B2 — AC-10 class-confirm trigger. The contract row + class_confirm.scale
## binding existed; the trigger (play_ac + haptic) was missing from
## class_select.gd::_lock_in. Source-structural pin + behavior twin.
func test_ac10_class_confirm_trigger_site() -> Dictionary:
	var src: String = _file_text("res://app/screens/class_select.gd")
	if src == "":
		return _fail("class_select.gd unreadable")
	for needle in ["play_ac(\"AC-10\")", "haptic(\"light\")", "class_confirm.scale"]:
		if src.find(needle) < 0:
			return _fail("class_select.gd lost its %s wiring (AC-10 zero-trigger regression)" % needle)
	# behavior twin: the director accepts AC-10 and records it
	var arr: Array = _director()
	if arr.is_empty():
		return _fail("tunables failed to load")
	var d: JuiceDirector = arr[0]
	if not d.play_ac("AC-10"):
		return _fail("play_ac(\"AC-10\") must be accepted by the budget gates")
	if int(_hist(d).get("AC-10", 0)) != 1:
		return _fail("AC-10 must record a juice event on play")
	return _ok()

## B3 — HS-1 light-hit hitstop (handshake beat 4). The hitstop_table row
## existed; no call site in the tree fired request_hitstop("HS-1"). The
## light-hit cue is cue.enemy.hurt → _on_hit_confirm.
func test_hs1_hitstop_fires_on_hit_confirm() -> Dictionary:
	var arr: Array = _director()
	if arr.is_empty():
		return _fail("tunables failed to load")
	var d: JuiceDirector = arr[0]
	if d.hitstop_active():
		return _fail("hitstop must be inactive before any hit cue")
	d.on_cue({"cue_id": "cue.enemy.hurt", "step": 1})
	if not d.hitstop_active():
		return _fail("cue.enemy.hurt must fire HS-1 hitstop (handshake beat 4)")
	# why: HS-1 default is 2 frames (juice.hitstop.light_frames) — two ticks clear
	d.step()
	d.step()
	if d.hitstop_active():
		return _fail("HS-1 (2f) hitstop must clear after 2 ticks")
	return _ok()

## B3 — PT-01 hero-spawn spark (handshake beat 3). The particle_table row
## existed; no burst site fired it. The hero-spawn trigger is the floor-change
## branch of notify_snapshot (which also fires AC-29). The ParticleManager
## ledger tracks the admitted instance even headless (no world view).
func test_pt01_hero_spawn_spark_fires_on_floor_change() -> Dictionary:
	var arr: Array = _director()
	if arr.is_empty():
		return _fail("tunables failed to load")
	var d: JuiceDirector = arr[0]
	if d.particle_manager == null:
		return _fail("ParticleManager must be present")
	if d.particle_manager.instances_of("PT-01").size() != 0:
		return _fail("PT-01 must not be live before any floor change")
	# first snapshot = floor 1 entry (handshake beat 3 fires on the FIRST snapshot)
	d.notify_snapshot({"player": {"hp": 800, "max_hp": 800, "pos_x": 320.0, "pos_y": 176.0}, "floor": 1, "score": {"score": 0}, "class": "warrior"})
	if d.particle_manager.instances_of("PT-01").size() != 1:
		return _fail("first snapshot must fire PT-01 hero-spawn spark, got %d" % d.particle_manager.instances_of("PT-01").size())
	# same-floor snapshot must NOT re-fire (the floor-change gate prevents the call)
	var before: int = d.particle_manager.instance_count()
	d.notify_snapshot({"player": {"hp": 800, "max_hp": 800, "pos_x": 320.0, "pos_y": 176.0}, "floor": 1, "score": {"score": 0}, "class": "warrior"})
	if d.particle_manager.instance_count() != before:
		return _fail("same-floor snapshot must not fire a new PT-01 burst")
	# floor CHANGE (1→2) must fire PT-01 again (max_inst 1 snaps the old; new wins)
	d.notify_snapshot({"player": {"hp": 780, "max_hp": 800, "pos_x": 64.0, "pos_y": 64.0}, "floor": 2, "score": {"score": 0}, "class": "warrior"})
	if d.particle_manager.instances_of("PT-01").size() != 1:
		return _fail("floor change 1→2 must fire PT-01 (max_inst 1), got %d" % d.particle_manager.instances_of("PT-01").size())
	return _ok()
