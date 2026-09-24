extends RefCounted
## test_balance_sim — 600 games (200 × 3 policies), in-process against the
## REAL RulesSession (FIX-153 stand-in until the Monte Carlo lands): the
## G2 §7 viability floor evidence. Includes softlock detection — every
## PLAYING tick must report has_legal_action() true — and honest terminal
## accounting (dead / cleared / capped).

const CAP_TICKS: int = 900  # why: 15s per sampled game keeps 600 games bounded

var _stats: Dictionary = {}

func _run_game(policy: int, seed_v: int) -> String:
	var t: TunablesLoader = TunablesLoader.new()
	t.load_from_path("res://Tunables.json")
	var classes: Array = ClassDef.build_all(t)
	var s: RulesSession = RulesSession.new()
	s.setup_campaign(t, classes[seed_v % classes.size()], seed_v)
	var path_cache: Array = []
	var cache_target: Vector2i = Vector2i(-99, -99)
	var cache_from: Vector2i = Vector2i(-99, -99)
	for tick in range(CAP_TICKS):
		if s.state == StateEnums.State.FLOOR_RESULTS:
			s.advance_floor()
			path_cache = []
			cache_target = Vector2i(-99, -99)
			if s.floor_number > 24:
				return "campaign_clear"
			continue
		if s.state == StateEnums.State.GAME_OVER:
			return "dead"
		if s.state == StateEnums.State.DYING:
			s.step()
			continue
		if s.state == StateEnums.State.CONTINUE_OFFER:
			s.decide_continue(s.continue_state.has_tokens())
			path_cache = []
			continue
		if s.state != StateEnums.State.PLAYING:
			s.step()
			continue
		# why: softlock detection — the spec's has_legal_action assertions
		if not s.has_legal_action():
			return "softlock"
		var tile_p: Vector2i = s.floor.pixel_to_tile(s.player.pos_x, s.player.pos_y, 32)
		match policy:
			0:
				# idle — pure drain pressure; the floor of survivability
				s.input({"type": "move", "dx": 0.0, "dy": 0.0})
			1:
				# greedy objective chain (key when sealed, then exit)
				var target: Vector2i = s.floor.exit_pos
				if tile_p != cache_from or target != cache_target or path_cache.is_empty():
					path_cache = _bfs(s, tile_p, target)
					if path_cache.is_empty() and s.player.keys == 0 and not s.pickups.keys.is_empty():
						target = s.pickups.keys[0]
						path_cache = _bfs(s, tile_p, target)
					cache_from = tile_p
					cache_target = target
				if not path_cache.is_empty():
					var wp: Vector2i = path_cache[0]
					if tile_p == wp:
						path_cache.pop_front()
					else:
						var center: Vector2 = s.floor.tile_to_pixel(wp.x, wp.y, 32)
						var delta: Vector2 = center - Vector2(s.player.pos_x, s.player.pos_y)
						if abs(delta.x) > abs(delta.y):
							s.input({"type": "move", "dx": sign(delta.x), "dy": 0.0})
						else:
							s.input({"type": "move", "dx": 0.0, "dy": sign(delta.y)})
				else:
					s.input({"type": "move", "dx": 0.0, "dy": 0.0})
			2:
				# aggro — chase the nearest enemy, throw in range; takes hits
				var best: Vector2 = Vector2(-1, -1)
				var best_d: float = 999999.0
				for e in s.enemies:
					if e.alive:
						var d: float = Vector2(e.pos_x - s.player.pos_x, e.pos_y - s.player.pos_y).length()
						if d < best_d:
							best_d = d
							best = Vector2(e.pos_x, e.pos_y)
				if best != Vector2(-1, -1):
					var delta2: Vector2 = best - Vector2(s.player.pos_x, s.player.pos_y)
					if delta2.length() > 24.0:
						var n: Vector2 = delta2.normalized()
						s.input({"type": "move", "dx": n.x, "dy": n.y})
					else:
						s.input({"type": "move", "dx": 0.0, "dy": 0.0})
					if best_d <= float(s.player.shot_range_tiles) * 32.0 and s.player.throw_ready():
						s.input({"type": "throw"})
				else:
					s.input({"type": "move", "dx": 0.0, "dy": 0.0})
		s.step()
		if s.player.hp < 0:
			return "hp_negative"
	return "capped"

func _bfs(s: RulesSession, from_tile: Vector2i, target: Vector2i) -> Array:
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

func test_600_games_no_softlock() -> Dictionary:
	_stats = {}
	var outcomes: Dictionary = {}
	for policy in range(3):
		for g in range(200):
			var seed_v: int = 1000 + policy * 10000 + g * 7919
			var outcome: String = _run_game(policy, seed_v)
			outcomes[outcome] = int(outcomes.get(outcome, 0)) + 1
			if outcome == "softlock":
				return {"ok": false, "msg": "SOFTLOCK: has_legal_action() false — policy %d game %d" % [policy, g]}
			if outcome == "hp_negative":
				return {"ok": false, "msg": "HP below zero — clamp broken (policy %d game %d)" % [policy, g]}
	_stats = outcomes
	return {"ok": true}

func test_greedy_policy_clears_floors() -> Dictionary:
	# why: a solver-gated floor must actually be clearable by a navigating
	# agent — zero greedy clears would mean the baked chain is broken
	if _stats.is_empty():
		return {"ok": false, "msg": "run order broken: 600-game sweep must run first"}
	# capped includes games still alive past floor 1's exit at tick cap —
	# count any game that cleared at least one floor by re-running a small
	# greedy sample to terminal-or-clear
	var clears: int = 0
	for g in range(20):
		var t: TunablesLoader = TunablesLoader.new()
		t.load_from_path("res://Tunables.json")
		var s: RulesSession = RulesSession.new()
		s.setup_campaign(t, ClassDef.build_all(t)[g % 4], 55000 + g * 7919)
		var cleared: bool = false
		for tick in range(1200):
			if s.state == StateEnums.State.FLOOR_RESULTS:
				cleared = true
				break
			if s.state != StateEnums.State.PLAYING:
				s.step()
				continue
			var tile_p: Vector2i = s.floor.pixel_to_tile(s.player.pos_x, s.player.pos_y, 32)
			var path: Array = _bfs(s, tile_p, s.floor.exit_pos)
			if path.is_empty() and s.player.keys == 0 and not s.pickups.keys.is_empty():
				path = _bfs(s, tile_p, s.pickups.keys[0])
			if not path.is_empty():
				var wp: Vector2i = path[0]
				var center: Vector2 = s.floor.tile_to_pixel(wp.x, wp.y, 32)
				var delta: Vector2 = center - Vector2(s.player.pos_x, s.player.pos_y)
				if abs(delta.x) > abs(delta.y):
					s.input({"type": "move", "dx": sign(delta.x), "dy": 0.0})
				else:
					s.input({"type": "move", "dx": 0.0, "dy": sign(delta.y)})
			else:
				s.input({"type": "move", "dx": 0.0, "dy": 0.0})
			s.step()
		if cleared:
			clears += 1
	if clears < 10:
		return {"ok": false, "msg": "only %d/20 navigating games cleared floor 1 — baked floors or door rule broken" % clears}
	return {"ok": true}
