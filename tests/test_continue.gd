extends RefCounted
## test_continue — floor-reset exactness + token decrement (G2 §2 / G6 §2).
## Continue rebuild: player at spawn, HP 50%, potions zeroed, keys zeroed,
## food NOT restored; two tokens per floor; refusing or running dry ends
## the game.

func _make_session() -> RulesSession:
	var t: TunablesLoader = TunablesLoader.new()
	t.load_from_path("res://Tunables.json")
	var s: RulesSession = RulesSession.new()
	s.setup_campaign(t, ClassDef.build_all(t)[0], 23)
	return s

func test_continue_rebuild_exactness() -> Dictionary:
	var s: RulesSession = _make_session()
	# why: dirty the pre-continue state on every axis the contract names
	s.player.pos_x += 96.0
	s.player.pos_y += 64.0
	s.player.hp = 77
	s.player.potions = 2
	s.player.keys = 1
	var food_before: int = s.pickups.foods.size()
	if food_before < 1:
		return {"ok": false, "msg": "floor_01 baked without food"}
	var eaten_tile: Vector2i = s.pickups.foods[0]
	var healed: int = s.pickups.try_eat_food(eaten_tile.x, eaten_tile.y, 150)
	s.pickups.mark_food_consumed(eaten_tile.x, eaten_tile.y)
	if healed <= 0:
		return {"ok": false, "msg": "setup eat failed"}
	s.continue_floor()
	var max_hp: int = s.player.max_hp
	var half: int = int(float(max_hp) * s.tunables.get_value("continue_hp_fraction", 0.5))
	if s.player.hp != half:
		return {"ok": false, "msg": "continue HP %d, expected 50%% (%d)" % [s.player.hp, half]}
	if s.player.potions != 0:
		return {"ok": false, "msg": "potions not zeroed on continue"}
	if s.player.keys != 0:
		return {"ok": false, "msg": "keys not zeroed on continue"}
	var spawn_px: Vector2 = s.floor.tile_to_pixel(s.floor.spawn.x, s.floor.spawn.y, 32)
	if abs(s.player.pos_x - spawn_px.x) > 0.01 or abs(s.player.pos_y - spawn_px.y) > 0.01:
		return {"ok": false, "msg": "player not returned to spawn"}
	if s.pickups.foods.size() != food_before - 1:
		return {"ok": false, "msg": "eaten food RESTORED on continue: %d foods, expected %d" % [s.pickups.foods.size(), food_before - 1]}
	if not s.pickups.is_food_consumed(eaten_tile.x, eaten_tile.y):
		return {"ok": false, "msg": "consumed-food ledger lost on continue"}
	if s.state != StateEnums.State.PLAYING:
		return {"ok": false, "msg": "continue did not return to PLAYING"}
	return {"ok": true}

func test_token_decrement_two_to_zero() -> Dictionary:
	var s: RulesSession = _make_session()
	var start_tokens: int = s.continue_state.tokens
	if start_tokens != s.tunables.get_int("continue_tokens_per_floor", 2):
		return {"ok": false, "msg": "floor entry tokens %d, expected 2" % start_tokens}
	s.continue_floor()
	if s.continue_state.tokens != start_tokens - 1:
		return {"ok": false, "msg": "first continue left %d tokens" % s.continue_state.tokens}
	s.continue_floor()
	if s.continue_state.tokens != start_tokens - 2:
		return {"ok": false, "msg": "second continue left %d tokens" % s.continue_state.tokens}
	if s.continue_state.consume():
		return {"ok": false, "msg": "third consume succeeded at zero tokens"}
	return {"ok": true}

func test_refuse_continue_ends_game() -> Dictionary:
	var s: RulesSession = _make_session()
	s.state = StateEnums.State.CONTINUE_OFFER
	s.decide_continue(false)
	if s.state != StateEnums.State.GAME_OVER:
		return {"ok": false, "msg": "refusal landed in state %d, expected GAME_OVER" % s.state}
	if s.continue_decision != "no":
		return {"ok": false, "msg": "decision recorded as '%s'" % s.continue_decision}
	return {"ok": true}

func test_accept_without_tokens_ends_game() -> Dictionary:
	var s: RulesSession = _make_session()
	s.continue_state.tokens = 0
	s.state = StateEnums.State.CONTINUE_OFFER
	s.decide_continue(true)
	if s.state != StateEnums.State.GAME_OVER:
		return {"ok": false, "msg": "token-less accept landed in state %d" % s.state}
	if s.continue_decision != "no_tokens":
		return {"ok": false, "msg": "decision recorded as '%s'" % s.continue_decision}
	return {"ok": true}

func test_death_path_reaches_continue_offer() -> Dictionary:
	# why: the full runtime ladder — hp zero → countdown → DYING → offer —
	# driven only by step(), so the bot's terminal path is the player's path
	var s: RulesSession = _make_session()
	s.player.hp = 0
	s.player.invuln_ticks = 0
	var reached_offer: bool = false
	for i in range(240):
		s.step()
		if s.state == StateEnums.State.CONTINUE_OFFER:
			reached_offer = true
			break
	if not reached_offer:
		return {"ok": false, "msg": "death never surfaced the continue offer (state %d)" % s.state}
	return {"ok": true}
