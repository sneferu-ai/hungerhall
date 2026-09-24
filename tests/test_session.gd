extends RefCounted
## test_session — RulesSession determinism + HP drain + win/lose.

func _make_tunables() -> TunablesLoader:
	var t: TunablesLoader = TunablesLoader.new()
	t.load_from_path("res://Tunables.json")
	return t

func _make_warrior(t: TunablesLoader) -> ClassDef:
	var cd: ClassDef = ClassDef.new()
	cd.class_type = StateEnums.ClassType.WARRIOR
	cd.display_name = "WARRIOR"
	cd.potion_type = StateEnums.PotionType.WHIRLWIND
	cd.hp = int(t.get_value("warrior_hp", 800))
	cd.speed = int(t.get_value("warrior_speed", 128))
	cd.shot_dmg = int(t.get_value("warrior_shot_dmg", 50))
	cd.shot_range_tiles = int(t.get_value("warrior_shot_range_tiles", 5))
	cd.shot_rate_per_sec = t.get_value("warrior_shot_rate", 1.2)
	cd.projectile_kind = "axe"
	return cd

func test_setup_campaign_floor_1() -> Dictionary:
	var t: TunablesLoader = _make_tunables()
	var cd: ClassDef = _make_warrior(t)
	var s: RulesSession = RulesSession.new()
	s.setup_campaign(t, cd, 42)
	if s.floor_number != 1:
		return {"ok": false, "msg": "floor_number = %d, expected 1" % s.floor_number}
	if s.state != StateEnums.State.PLAYING:
		return {"ok": false, "msg": "state = %d, expected PLAYING" % s.state}
	return {"ok": true}

func test_deterministic_same_seed() -> Dictionary:
	var t: TunablesLoader = _make_tunables()
	var cd: ClassDef = _make_warrior(t)
	var a: RulesSession = RulesSession.new()
	var b: RulesSession = RulesSession.new()
	a.setup_campaign(t, cd, 42)
	b.setup_campaign(t, cd, 42)
	for i in range(300):
		a.input({"type": "move", "dx": 1.0, "dy": 0.0})
		b.input({"type": "move", "dx": 1.0, "dy": 0.0})
		a.step()
		b.step()
		var sa: Dictionary = a.snapshot()
		var sb: Dictionary = b.snapshot()
		if sa.player.hp != sb.player.hp:
			return {"ok": false, "msg": "HP diverged at tick %d: %d vs %d" % [i, sa.player.hp, sb.player.hp]}
		if sa.player.pos_x != sb.player.pos_x:
			return {"ok": false, "msg": "pos_x diverged at tick %d" % i}
	return {"ok": true}

func test_hp_drain_over_time() -> Dictionary:
	var t: TunablesLoader = _make_tunables()
	var cd: ClassDef = _make_warrior(t)
	var s: RulesSession = RulesSession.new()
	s.setup_campaign(t, cd, 42)
	var start_hp: int = s.player.hp
	# why: stand still for 60 ticks = 1 second
	for i in range(60):
		s.input({"type": "move", "dx": 0.0, "dy": 0.0})
		s.step()
	var drained: int = start_hp - s.player.hp
	if drained <= 0:
		return {"ok": false, "msg": "no HP drained over 60 ticks (drained=%d)" % drained}
	if drained > 10:
		return {"ok": false, "msg": "drained %d in 1s, expected ~2-3 for band 1" % drained}
	return {"ok": true}

func test_snapshot_has_required_fields() -> Dictionary:
	var t: TunablesLoader = _make_tunables()
	var cd: ClassDef = _make_warrior(t)
	var s: RulesSession = RulesSession.new()
	s.setup_campaign(t, cd, 42)
	var snap: Dictionary = s.snapshot()
	var required: Array = ["tick", "state", "floor", "player", "enemies", "generators", "projectiles", "score", "continue"]
	for key in required:
		if not snap.has(key):
			return {"ok": false, "msg": "snapshot missing key: " + key}
	return {"ok": true}

func test_throw_creates_projectile() -> Dictionary:
	var t: TunablesLoader = _make_tunables()
	var cd: ClassDef = _make_warrior(t)
	var s: RulesSession = RulesSession.new()
	s.setup_campaign(t, cd, 42)
	s.input({"type": "throw"})
	s.step()
	if s.projectiles.is_empty():
		return {"ok": false, "msg": "no projectile created after throw"}
	return {"ok": true}
