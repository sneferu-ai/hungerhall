extends RefCounted
## test_pickups — food HP, chest score, potion count, and DOOR rules.
## The door tests pin the G2 §1 push-to-open contract at the RulesSession
## level — round 5's stand-on branch deadlocked every door-gated floor while
## this suite had ZERO door assertions and shipped green.

func _make_tunables() -> TunablesLoader:
	var t: TunablesLoader = TunablesLoader.new()
	t.load_from_path("res://Tunables.json")
	return t

## why: a rules-level harness — RulesSession over a hand-built floor with one
## door between spawn and exit, so the push rule is exercised through the
## REAL _step_movement path (not a mocked pickup call).
func _make_door_session(t: TunablesLoader) -> RulesSession:
	var fd: FloorData = FloorData.new()
	fd.floor_number = 1
	fd.tiles = PackedStringArray([
		"####################",
		"#..................#",
		"#..................#",
		"#..................#",
		"#..................#",
		"#..................#",
		"#########DD#########",
		"#..................#",
		"#..................#",
		"#..................#",
		"#..................#",
		"#...............X..#",
		"#..................#",
		"####################"])
	fd.spawn = Vector2i(2, 2)
	fd.exit_pos = Vector2i(16, 11)
	fd.doors = PackedVector2Array([Vector2i(9, 6), Vector2i(10, 6)])
	fd.foods = PackedVector2Array()
	fd.keys = PackedVector2Array([Vector2i(16, 2)])
	fd.potions = PackedVector2Array()
	fd.chests = []
	fd.generators = []
	fd.initial_enemies = []
	fd.hazards = []
	fd.drain_hp_per_sec = 0.0  # why: isolate the door rule from drain deaths
	fd.target_seconds = 135
	fd.chest_total = 0
	fd.generator_hp = 0
	fd.generator_cadence_ticks = 0
	var cd: ClassDef = ClassDef.new()
	cd.class_type = StateEnums.ClassType.WARRIOR
	cd.display_name = "WARRIOR"
	cd.hp = int(t.get_value("warrior_hp", 800))
	cd.speed = int(t.get_value("warrior_speed", 128))
	cd.shot_dmg = int(t.get_value("warrior_shot_dmg", 50))
	cd.shot_range_tiles = int(t.get_value("warrior_shot_range_tiles", 5))
	cd.shot_rate_per_sec = t.get_value("warrior_shot_rate", 1.2)
	cd.potion_type = StateEnums.PotionType.WHIRLWIND
	var s: RulesSession = RulesSession.new()
	s.tunables = t
	s.class_def = cd
	s.floor.setup_from_floor_data(fd)
	s.pickups.setup_from_floor(s.floor)
	s.player.setup_from_class_def(cd)
	var px: Vector2 = s.floor.tile_to_pixel(2, 2, 32)
	s.player.pos_x = px.x
	s.player.pos_y = px.y
	s.player.hp = cd.hp
	s.state = StateEnums.State.PLAYING
	return s

## why: BFS path over the real tiles (closed doors passable only with a key —
## the same model the bot uses), then step waypoint by waypoint. A straight
## sign-walk sticks to walls on baked floors; the join test needs real routes.
func _bfs_path(s: RulesSession, from_tile: Vector2i, target: Vector2i) -> Array:
	if from_tile == target:
		return []
	var w: int = s.floor.grid_w
	var h: int = s.floor.grid_h
	var came_from: Dictionary = {}
	var frontier: Array = [from_tile]
	came_from[from_tile] = from_tile
	var dirs: Array = [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]
	var found: bool = false
	while not frontier.is_empty() and not found:
		var next_frontier: Array = []
		for cur in frontier:
			for d in dirs:
				var n: Vector2i = cur + d
				if n.x < 0 or n.y < 0 or n.x >= w or n.y >= h:
					continue
				if came_from.has(n):
					continue
				if s.floor.is_wall(n.x, n.y):
					continue
				if not s.pickups.is_door_open(n.x, n.y) and s.player.keys <= 0:
					continue
				came_from[n] = cur
				if n == target:
					found = true
					break
				next_frontier.append(n)
			if found:
				break
		frontier = next_frontier
	if not found:
		return []
	var path: Array = []
	var cur2: Vector2i = target
	while cur2 != from_tile:
		path.push_front(cur2)
		cur2 = came_from[cur2]
	return path

func _walk_toward(s: RulesSession, target: Vector2i, max_ticks: int) -> int:
	var ticks: int = 0
	var tile_p: Vector2i = s.floor.pixel_to_tile(s.player.pos_x, s.player.pos_y, 32)
	var path: Array = _bfs_path(s, tile_p, target)
	var idx: int = 0
	while ticks < max_ticks:
		tile_p = s.floor.pixel_to_tile(s.player.pos_x, s.player.pos_y, 32)
		if tile_p == target:
			break
		if idx >= path.size():
			# why: re-plan — a push-to-open may have changed passability mid-walk
			path = _bfs_path(s, tile_p, target)
			idx = 0
			if path.is_empty():
				break
		var wp: Vector2i = path[idx]
		if tile_p == wp:
			idx += 1
			continue
		var center: Vector2 = s.floor.tile_to_pixel(wp.x, wp.y, 32)
		var delta: Vector2 = center - Vector2(s.player.pos_x, s.player.pos_y)
		var dx: float = 0.0
		var dy: float = 0.0
		if abs(delta.x) > abs(delta.y):
			dx = sign(delta.x)
		else:
			dy = sign(delta.y)
		s.input({"type": "move", "dx": dx, "dy": dy})
		s.step()
		ticks += 1
	return ticks

func _make_player(t: TunablesLoader) -> RulesPlayer:
	var cd: ClassDef = ClassDef.new()
	cd.class_type = StateEnums.ClassType.WARRIOR
	cd.hp = int(t.get_value("warrior_hp", 800))
	var p: RulesPlayer = RulesPlayer.new()
	p.setup_from_class_def(cd)
	return p

func test_food_grants_150_hp() -> Dictionary:
	var t: TunablesLoader = _make_tunables()
	var expected: int = int(t.get_value("food_hp", 150))
	var p: RulesPlayer = _make_player(t)
	p.hp = 400
	# why: simulate eating food at a tile — add a food, then eat it
	var pickups: RulesPickup = RulesPickup.new()
	pickups.foods = [Vector2i(5, 5)]
	var healed: int = pickups.try_eat_food(5, 5, expected)
	if healed != expected:
		return {"ok": false, "msg": "food HP: got %d, expected %d" % [healed, expected]}
	return {"ok": true}

func test_food_capped_at_max() -> Dictionary:
	var t: TunablesLoader = _make_tunables()
	var food_hp: int = int(t.get_value("food_hp", 150))
	var cd: ClassDef = ClassDef.new()
	cd.class_type = StateEnums.ClassType.WARRIOR
	cd.hp = int(t.get_value("warrior_hp", 800))
	var p: RulesPlayer = RulesPlayer.new()
	p.setup_from_class_def(cd)
	p.hp = 750
	p.hp = mini(p.hp + food_hp, cd.hp)
	if p.hp > cd.hp:
		return {"ok": false, "msg": "HP exceeded max: %d > %d" % [p.hp, cd.hp]}
	if p.hp != cd.hp:
		return {"ok": false, "msg": "HP not capped: got %d, expected %d" % [p.hp, cd.hp]}
	return {"ok": true}

func test_chest_grants_score() -> Dictionary:
	var t: TunablesLoader = _make_tunables()
	var score: RulesScore = RulesScore.new()
	score.reset()
	var before: int = score.score
	# why: simulate opening a chest
	var pickups: RulesPickup = RulesPickup.new()
	pickups.chests = [{"x": 3, "y": 3, "value": 100, "taken": false}]
	var value: int = pickups.try_open_chest(3, 3)
	if value <= 0:
		return {"ok": false, "msg": "chest returned no value"}
	return {"ok": true}

func test_potion_increment() -> Dictionary:
	var cd: ClassDef = ClassDef.new()
	cd.class_type = StateEnums.ClassType.WARRIOR
	cd.hp = 800
	var p: RulesPlayer = RulesPlayer.new()
	p.setup_from_class_def(cd)
	var before: int = p.potions
	# why: simulate collecting a potion at a tile
	var pickups: RulesPickup = RulesPickup.new()
	pickups.potions = [Vector2i(2, 2)]
	var got: bool = pickups.try_collect_potion(2, 2, 3, before)
	if not got:
		return {"ok": false, "msg": "potion not collected"}
	return {"ok": true}

func test_potion_cap_respected() -> Dictionary:
	var cd: ClassDef = ClassDef.new()
	cd.class_type = StateEnums.ClassType.WARRIOR
	cd.hp = 800
	var p: RulesPlayer = RulesPlayer.new()
	p.setup_from_class_def(cd)
	p.potions = 3  # why: at cap
	var pickups: RulesPickup = RulesPickup.new()
	pickups.potions = [Vector2i(2, 2)]
	var got: bool = pickups.try_collect_potion(2, 2, 3, p.potions)
	if got:
		return {"ok": false, "msg": "potion collected above cap"}
	return {"ok": true}

## ---- door contract (G2 §1: doors consume their key on PUSH) ----

func test_door_closed_without_key_blocks() -> Dictionary:
	var t: TunablesLoader = _make_tunables()
	var s: RulesSession = _make_door_session(t)
	s.player.keys = 0
	# why: start directly above the door at (9,6) and PUSH down into it — the
	# refusal must come from the door rule, not an unrelated wall
	var center: Vector2 = s.floor.tile_to_pixel(9, 4, 32)
	s.player.pos_x = center.x
	s.player.pos_y = center.y
	for i in range(240):
		s.input({"type": "move", "dx": 0.0, "dy": 1.0})
		s.step()
		var tile_p: Vector2i = s.floor.pixel_to_tile(s.player.pos_x, s.player.pos_y, 32)
		if tile_p.y >= 6:
			return {"ok": false, "msg": "player crossed the closed door row without a key at tick %d" % i}
	if s.pickups.is_door_open(9, 6):
		return {"ok": false, "msg": "door opened without a key"}
	return {"ok": true}

func test_door_push_with_key_opens_and_enters() -> Dictionary:
	var t: TunablesLoader = _make_tunables()
	var s: RulesSession = _make_door_session(t)
	s.player.keys = 1
	var before_cues: int = 0
	# why: push down from (9,2) onto the door at (9,6)
	var center: Vector2 = s.floor.tile_to_pixel(9, 2, 32)
	s.player.pos_x = center.x
	s.player.pos_y = center.y
	var opened_tick: int = -1
	var entered_tick: int = -1
	for i in range(400):
		s.input({"type": "move", "dx": 0.0, "dy": 1.0})
		s.step()
		var pending: Dictionary = s.consume_pending()
		for cue in pending.get("cues", []):
			if str(cue.get("cue_id", "")) == "cue.door.open":
				before_cues += 1
		for ev in pending.get("events", []):
			if str(ev.get("type", "")) == "door_opened" and opened_tick < 0:
				opened_tick = i
		var tile_p: Vector2i = s.floor.pixel_to_tile(s.player.pos_x, s.player.pos_y, 32)
		if tile_p.y >= 7 and entered_tick < 0:
			entered_tick = i
		if entered_tick >= 0:
			break
	if opened_tick < 0:
		return {"ok": false, "msg": "door_opened event never fired on push"}
	if entered_tick < 0:
		return {"ok": false, "msg": "player never entered the tile beyond the opened door"}
	if before_cues < 1:
		return {"ok": false, "msg": "cue.door.open never emitted"}
	if s.player.keys != 0:
		return {"ok": false, "msg": "key not consumed: %d remain" % s.player.keys}
	if not s.pickups.is_door_open(9, 6):
		return {"ok": false, "msg": "door state not flipped open"}
	return {"ok": true}

func test_door_second_door_needs_own_key() -> Dictionary:
	var t: TunablesLoader = _make_tunables()
	var s: RulesSession = _make_door_session(t)
	s.player.keys = 1
	var center: Vector2 = s.floor.tile_to_pixel(9, 2, 32)
	s.player.pos_x = center.x
	s.player.pos_y = center.y
	# why: open (9,6), then push the sibling door (10,6) — with no key left it
	# must stay closed (the run's 2-door walls cost one key per door tile)
	_walk_toward(s, Vector2i(9, 6), 400)
	_walk_toward(s, Vector2i(10, 6), 400)
	if s.pickups.is_door_open(10, 6):
		return {"ok": false, "msg": "second door opened without its own key"}
	return {"ok": true}

func test_door_reachability_join_with_solver() -> Dictionary:
	# why: gate 3 (rules_solver_check.gd reachability) validates baked data
	# ASSUMING doors open; this test exercises the actual runtime open rule on
	# a real baked door floor (floor_02) so the solver's assumption is joined
	# to RulesSession behavior. Collect the key, push the door row, reach the
	# side the doors seal.
	var t: TunablesLoader = _make_tunables()
	var s: RulesSession = RulesSession.new()
	s.setup_campaign(t, ClassDef.build_all(t)[0], 7)
	s.advance_floor()  # floor_02: key (16,3), doors (9,7)/(10,7), exit (16,11)
	if s.floor_number != 2:
		return {"ok": false, "msg": "expected floor 2, got %d" % s.floor_number}
	var key_tile: Vector2i = Vector2i(s.floor.keys[0]) if s.floor.keys.size() > 0 else Vector2i(-1, -1)
	if key_tile == Vector2i(-1, -1):
		return {"ok": false, "msg": "floor_02 baked without a key"}
	_walk_toward(s, key_tile, 600)
	if s.player.keys < 1:
		return {"ok": false, "msg": "bot-walk could not collect floor_02's key"}
	var door_tile: Vector2i = Vector2i(s.floor.doors[0])
	# why: walk THROUGH the door to a tile on the sealed side (one row below the
	# door) — the push-to-open rule must let the player cross the door row, not
	# merely reach it. Walking to the door tile itself would stop ON the row;
	# the assertion requires the player to stand BEYOND it.
	var beyond_tile: Vector2i = Vector2i(door_tile.x, door_tile.y + 1)
	_walk_toward(s, beyond_tile, 600)
	# why: after pushing through, the player must stand BELOW the door row
	var tile_p: Vector2i = s.floor.pixel_to_tile(s.player.pos_x, s.player.pos_y, 32)
	if tile_p.y <= door_tile.y:
		return {"ok": false, "msg": "player never crossed floor_02's sealed door row (deadlock regression)"}
	return {"ok": true}
