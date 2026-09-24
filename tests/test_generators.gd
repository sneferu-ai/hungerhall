extends RefCounted
## test_generators — spawn cadence, per-generator cap 6, per-floor cap 28
## (G2 §1 / G6 §2 rules_generator.gd).

func _make_session() -> RulesSession:
	var t: TunablesLoader = TunablesLoader.new()
	t.load_from_path("res://Tunables.json")
	var s: RulesSession = RulesSession.new()
	# why: baked floor_01 carries exactly one drowned (ghost) generator
	s.setup_campaign(t, ClassDef.build_all(t)[0], 31)
	return s

func test_no_spawn_before_cadence() -> Dictionary:
	var s: RulesSession = _make_session()
	var cadence: int = s.generators[0].spawn_cadence_ticks
	if cadence < 2:
		return {"ok": false, "msg": "unexpected cadence %d" % cadence}
	for i in range(cadence - 10):
		s.player.hp = s.player.max_hp
		s.input({"type": "move", "dx": 0.0, "dy": 0.0})
		s.step()
	if s.enemies.size() != 0:
		return {"ok": false, "msg": "spawn fired before cadence (%d enemies at tick %d)" % [s.enemies.size(), cadence - 10]}
	return {"ok": true}

func test_spawn_fires_after_cadence() -> Dictionary:
	var s: RulesSession = _make_session()
	var cadence: int = s.generators[0].spawn_cadence_ticks
	for i in range(cadence + 60):
		s.player.hp = s.player.max_hp
		s.input({"type": "move", "dx": 0.0, "dy": 0.0})
		s.step()
		if s.state != StateEnums.State.PLAYING:
			return {"ok": false, "msg": "session left PLAYING during spawn window"}
	if s.enemies.size() < 1:
		return {"ok": false, "msg": "no spawn %d ticks past cadence" % 60}
	return {"ok": true}

func test_per_generator_cap_six() -> Dictionary:
	var s: RulesSession = _make_session()
	# why: 4000 ticks ≈ 22 cadence windows — plenty of spawn chances; the
	# player is kept alive so the session never leaves PLAYING
	for i in range(4000):
		s.player.hp = s.player.max_hp
		s.input({"type": "move", "dx": 0.0, "dy": 0.0})
		s.step()
		if s.state != StateEnums.State.PLAYING:
			return {"ok": false, "msg": "session left PLAYING at tick %d" % i}
		var alive: int = 0
		for e in s.enemies:
			if e.alive:
				alive += 1
		if alive > 28:
			return {"ok": false, "msg": "floor cap 28 violated: %d alive" % alive}
	var alive_final: int = 0
	var gen_children: int = 0
	for e in s.enemies:
		if e.alive:
			alive_final += 1
			if e.generator_id == 0:
				gen_children += 1
	if gen_children > 6:
		return {"ok": false, "msg": "per-generator cap 6 violated: %d children of gen 0" % gen_children}
	if alive_final < 1:
		return {"ok": false, "msg": "generator produced nothing over 4000 ticks"}
	return {"ok": true}

func test_ready_to_spawn_gates() -> Dictionary:
	var gd: GeneratorDef = GeneratorDef.new()
	gd.hp = 60
	gd.spawn_cadence_ticks = 180
	gd.enemy_type = StateEnums.EnemyAIType.GHOST
	var g: RulesGenerator = RulesGenerator.new()
	g.setup(gd, 0, 5, 5, 32)
	if g.ready_to_spawn(0, 0, 28):
		return {"ok": false, "msg": "spawn ready before the first cadence elapses"}
	g.spawn_counter = 0
	if not g.ready_to_spawn(5, 10, 28):
		return {"ok": false, "msg": "spawn refused under both caps"}
	if g.ready_to_spawn(6, 10, 28):
		return {"ok": false, "msg": "per-generator cap 6 not enforced"}
	if g.ready_to_spawn(0, 28, 28):
		return {"ok": false, "msg": "per-floor cap 28 not enforced"}
	return {"ok": true}

func test_destroyed_generator_stops_spawning() -> Dictionary:
	var s: RulesSession = _make_session()
	s.generators[0].take_damage(9999)
	for i in range(600):
		s.player.hp = s.player.max_hp
		s.input({"type": "move", "dx": 0.0, "dy": 0.0})
		s.step()
	if s.enemies.size() != 0:
		return {"ok": false, "msg": "dead generator still spawning (%d enemies)" % s.enemies.size()}
	return {"ok": true}
