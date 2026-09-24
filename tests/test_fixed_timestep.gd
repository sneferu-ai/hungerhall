extends RefCounted
## test_fixed_timestep — the rules advance on a fixed 60Hz tick: no wall-clock
## in the loop, deterministic across split stepping, and paused states make
## zero rule progress (no jump on resume).

func _make_session(seed_v: int) -> RulesSession:
	var t: TunablesLoader = TunablesLoader.new()
	t.load_from_path("res://Tunables.json")
	var s: RulesSession = RulesSession.new()
	s.setup_campaign(t, ClassDef.build_all(t)[0], seed_v)
	return s

func test_drain_is_tick_based_60hz() -> Dictionary:
	var s: RulesSession = _make_session(5)
	s.player.invuln_ticks = 0  # why: isolate drain from the spawn grace window
	var hp0: int = s.player.hp
	var drain_per_sec: float = s.floor.drain_hp_per_sec
	for i in range(60):
		s.input({"type": "move", "dx": 0.0, "dy": 0.0})
		s.step()
	var expected: int = hp0 - int(drain_per_sec)
	if s.player.hp != expected:
		return {"ok": false, "msg": "60 ticks at %.1f HP/s: hp %d, expected %d" % [drain_per_sec, s.player.hp, expected]}
	return {"ok": true}

func test_determinism_split_stepping() -> Dictionary:
	# why: two identical seeds, one stepped 120 straight, one 60+60 — snapshots
	# must match exactly. Any wall-clock or hidden RNG would break this.
	var a: RulesSession = _make_session(11)
	var b: RulesSession = _make_session(11)
	for i in range(120):
		a.input({"type": "move", "dx": 0.0, "dy": 0.0})
		a.step()
	for i in range(60):
		b.input({"type": "move", "dx": 0.0, "dy": 0.0})
		b.step()
	for i in range(60):
		b.input({"type": "move", "dx": 0.0, "dy": 0.0})
		b.step()
	var sa: Dictionary = a.snapshot()
	var sb: Dictionary = b.snapshot()
	if str(sa) != str(sb):
		return {"ok": false, "msg": "split-stepped session diverged from straight-stepped"}
	return {"ok": true}

func test_paused_state_makes_no_rule_progress() -> Dictionary:
	# why: pause/resume must not jump — a non-PLAYING session advances only its
	# UI tick counter; no rules state changes while paused
	var s: RulesSession = _make_session(13)
	s.player.invuln_ticks = 0
	for i in range(30):
		s.input({"type": "move", "dx": 0.0, "dy": 0.0})
		s.step()
	var hp_before_pause: int = s.player.hp
	var tick_before: int = s.tick
	s.state = StateEnums.State.PAUSED
	for i in range(600):
		s.step()
	if s.player.hp != hp_before_pause:
		return {"ok": false, "msg": "rules advanced while PAUSED (hp moved)"}
	if s.tick == tick_before:
		return {"ok": false, "msg": "UI tick counter must still advance while paused"}
	s.state = StateEnums.State.PLAYING
	# why: drain subtracts whole HP only once the per-tick fraction
	# accumulates past 1.0 — give it a full second after resume
	for i in range(60):
		s.input({"type": "move", "dx": 0.0, "dy": 0.0})
		s.step()
	if s.player.hp >= hp_before_pause:
		return {"ok": false, "msg": "drain did not resume after unpause"}
	return {"ok": true}

func test_movement_speed_tick_based() -> Dictionary:
	# why: 128 px/s at 60Hz = 2.133 px/tick; 30 ticks ≈ 64px = exactly 2 tiles
	var s: RulesSession = _make_session(17)
	var speed: int = s.player.speed
	var x0: float = s.player.pos_x
	for i in range(30):
		s.input({"type": "move", "dx": 1.0, "dy": 0.0})
		s.step()
	var moved: float = s.player.pos_x - x0
	var expected: float = float(speed) * 30.0 / 60.0
	if abs(moved - expected) > 1.0:
		return {"ok": false, "msg": "30 ticks moved %.1f px, expected %.1f (wall-blocked?)" % [moved, expected]}
	return {"ok": true}
