extends RefCounted
## test_enemy_ai — the six AI contracts (G2 §1 table). Exercised through the
## REAL RulesSession step: Ghost wall-pass + kamikaze contact, Grunt
## wall-respecting pathfinding, Lobber no-LOS arc fire, contact damage with
## the 0.5s cooldown and the invulnerability gate.

func _make_session() -> RulesSession:
	var t: TunablesLoader = TunablesLoader.new()
	t.load_from_path("res://Tunables.json")
	var s: RulesSession = RulesSession.new()
	s.setup_campaign(t, ClassDef.build_all(t)[0], 47)
	return s

func _add_enemy(s: RulesSession, ai_type: int, tx: int, ty: int) -> RulesEnemy:
	var ed: EnemyDef = EnemyDef.new()
	ed.ai_type = ai_type
	match ai_type:
		StateEnums.EnemyAIType.GHOST:
			ed.hp = 14; ed.speed = 100; ed.contact_dmg = 10; ed.wall_pass = true
		StateEnums.EnemyAIType.GRUNT:
			ed.hp = 30; ed.speed = 80; ed.contact_dmg = 15; ed.wall_pass = false
		StateEnums.EnemyAIType.LOBBER:
			ed.hp = 50; ed.speed = 70; ed.contact_dmg = 15; ed.wall_pass = false
		_:
			ed.hp = 30; ed.speed = 80; ed.contact_dmg = 15; ed.wall_pass = false
	var e: RulesEnemy = RulesEnemy.new()
	e.setup_from_def(ed, s.enemies.size() + 900)
	var px: Vector2 = s.floor.tile_to_pixel(tx, ty, 32)
	e.pos_x = px.x
	e.pos_y = px.y
	s.enemies.append(e)
	return e

func test_ghost_wall_passes_toward_player() -> Dictionary:
	var s: RulesSession = _make_session()
	# why: floor_01's wall block at columns 8-9 rows 7-8 sits on the straight
	# line from (12,11) to (2,2) — a wall-respecting mover must detour, the
	# Ghost contract says ignore wall collision entirely
	var g: RulesEnemy = _add_enemy(s, StateEnums.EnemyAIType.GHOST, 12, 11)
	s.player.invuln_ticks = 0
	var d0: float = Vector2(g.pos_x - s.player.pos_x, g.pos_y - s.player.pos_y).length()
	var stood_on_wall: bool = false
	for i in range(200):
		s.player.hp = s.player.max_hp
		s.input({"type": "move", "dx": 0.0, "dy": 0.0})
		s.step()
		if not g.alive:
			break
		var tile_g: Vector2i = s.floor.pixel_to_tile(g.pos_x, g.pos_y, 32)
		if s.floor.is_wall(tile_g.x, tile_g.y):
			stood_on_wall = true
	if not stood_on_wall:
		return {"ok": false, "msg": "ghost never occupied a wall tile — wall-pass contract broken"}
	return {"ok": true}

func test_ghost_kamikaze_dies_on_contact() -> Dictionary:
	var s: RulesSession = _make_session()
	var g: RulesEnemy = _add_enemy(s, StateEnums.EnemyAIType.GHOST, 3, 2)
	s.player.invuln_ticks = 0
	var hp0: int = s.player.hp
	for i in range(240):
		s.input({"type": "move", "dx": 0.0, "dy": 0.0})
		s.step()
		if not g.alive:
			break
	if g.alive:
		return {"ok": false, "msg": "ghost survived contact with the player"}
	if s.player.hp >= hp0:
		return {"ok": false, "msg": "ghost contact dealt no damage"}
	return {"ok": true}

func test_grunt_pathfinds_without_entering_walls() -> Dictionary:
	var s: RulesSession = _make_session()
	var g: RulesEnemy = _add_enemy(s, StateEnums.EnemyAIType.GRUNT, 15, 2)
	s.player.invuln_ticks = 0
	var d0: float = Vector2(g.pos_x - s.player.pos_x, g.pos_y - s.player.pos_y).length()
	var min_d: float = d0
	for i in range(240):
		s.player.hp = s.player.max_hp
		s.input({"type": "move", "dx": 0.0, "dy": 0.0})
		s.step()
		var tile_g: Vector2i = s.floor.pixel_to_tile(g.pos_x, g.pos_y, 32)
		if s.floor.is_wall(tile_g.x, tile_g.y):
			return {"ok": false, "msg": "grunt entered a wall tile at tick %d" % i}
		var d: float = Vector2(g.pos_x - s.player.pos_x, g.pos_y - s.player.pos_y).length()
		if d < min_d:
			min_d = d
	if min_d >= d0:
		return {"ok": false, "msg": "grunt never closed distance (d0=%.1f min=%.1f)" % [d0, min_d]}
	return {"ok": true}

func test_lobber_fires_arcs_without_los() -> Dictionary:
	var s: RulesSession = _make_session()
	# why: put a wall line between lobber and player — the contract is
	# lob-fire over walls, no LOS needed
	_add_enemy(s, StateEnums.EnemyAIType.LOBBER, 12, 11)
	s.player.invuln_ticks = 999
	var fired: bool = false
	for i in range(300):
		s.player.hp = s.player.max_hp
		s.input({"type": "move", "dx": 0.0, "dy": 0.0})
		s.step()
		if s.projectiles.size() > 0:
			fired = true
			break
	if not fired:
		return {"ok": false, "msg": "lobber produced no projectile in 300 ticks"}
	return {"ok": true}

func test_contact_damage_cooldown_half_second() -> Dictionary:
	var s: RulesSession = _make_session()
	var g: RulesEnemy = _add_enemy(s, StateEnums.EnemyAIType.GRUNT, 2, 2)
	s.player.invuln_ticks = 0
	s.player.hp = s.player.max_hp
	var hp0: int = s.player.hp
	for i in range(29):
		s.input({"type": "move", "dx": 0.0, "dy": 0.0})
		s.step()
	var taken: int = hp0 - s.player.hp
	if taken != g.contact_dmg:
		return {"ok": false, "msg": "29 ticks of contact: %d dmg, expected exactly one %d-dmg hit (0.5s cooldown)" % [taken, g.contact_dmg]}
	return {"ok": true}

func test_invulnerability_blocks_contact() -> Dictionary:
	var s: RulesSession = _make_session()
	_add_enemy(s, StateEnums.EnemyAIType.GRUNT, 2, 2)
	s.player.invuln_ticks = 60
	s.player.hp = s.player.max_hp
	var hp0: int = s.player.hp
	for i in range(30):
		s.input({"type": "move", "dx": 0.0, "dy": 0.0})
		s.step()
	if s.player.hp != hp0:
		return {"ok": false, "msg": "contact damage landed during invulnerability"}
	return {"ok": true}
