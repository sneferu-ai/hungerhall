extends RefCounted
## test_score — scoring rules: kill score, clear bonus, floor multiplier.

func _make_tunables() -> TunablesLoader:
	var t: TunablesLoader = TunablesLoader.new()
	t.load_from_path("res://Tunables.json")
	return t

func test_reset() -> Dictionary:
	var s: RulesScore = RulesScore.new()
	s.reset()
	if s.score != 0:
		return {"ok": false, "msg": "score after reset = %d, expected 0" % s.score}
	return {"ok": true}

func test_kill_awards_points() -> Dictionary:
	var t: TunablesLoader = _make_tunables()
	var s: RulesScore = RulesScore.new()
	s.reset()
	s.add_kill(StateEnums.EnemyAIType.GHOST, t)
	if s.score <= 0:
		return {"ok": false, "msg": "kill did not award score"}
	return {"ok": true}

func test_clear_bonus_positive() -> Dictionary:
	var t: TunablesLoader = _make_tunables()
	var s: RulesScore = RulesScore.new()
	s.reset()
	var reward: int = s.on_floor_clear(t)
	if reward <= 0:
		return {"ok": false, "msg": "clear bonus not awarded"}
	return {"ok": true}

func test_death_kills_score_distinct() -> Dictionary:
	var t: TunablesLoader = _make_tunables()
	var s: RulesScore = RulesScore.new()
	s.reset()
	# why: accumulate some score first
	s.score = 1000
	s.on_floor_entry()
	s.on_death(t)
	if s.score >= 1000:
		return {"ok": false, "msg": "death did not penalize score (score=%d)" % s.score}
	return {"ok": true}

func test_higher_enemy_worth_more() -> Dictionary:
	var t: TunablesLoader = _make_tunables()
	var s: RulesScore = RulesScore.new()
	s.reset()
	var ghost_reward: int = s.kill_reward(StateEnums.EnemyAIType.GHOST, t)
	var death_reward: int = s.kill_reward(StateEnums.EnemyAIType.DEATH, t)
	if death_reward <= ghost_reward:
		return {"ok": false, "msg": "death reward (%d) should exceed ghost (%d)" % [death_reward, ghost_reward]}
	return {"ok": true}
