extends RefCounted
## test_bot_telemetry — bot runs and produces valid playtest_telemetry_v1.

func test_bot_runs_and_writes_telemetry() -> Dictionary:
	var bot: SneferuBot = SneferuBot.new()
	var out_path: String = "user://test_telemetry.json"
	var args: Dictionary = {
		"telemetry-out": out_path,
		"games": 2,
		"seed": 1,
		"frame-budget": 5000
	}
	var setup: Dictionary = bot.setup(args)
	if not setup.get("ok", false):
		return {"ok": false, "msg": "setup failed: " + str(setup.get("error", ""))}
	var result: Dictionary = bot.run()
	if not result.get("ok", false):
		return {"ok": false, "msg": "run failed: " + str(result.get("error", ""))}
	var telemetry: Dictionary = result.telemetry
	if telemetry.schema != "playtest_telemetry_v1":
		return {"ok": false, "msg": "schema = %s" % str(telemetry.get("schema", ""))}
	if telemetry.games_played < 1:
		return {"ok": false, "msg": "games_played = %d" % telemetry.games_played}
	if not telemetry.has("levels"):
		return {"ok": false, "msg": "no levels array"}
	var total_plays: int = 0
	var total_wins: int = 0
	for level in telemetry.levels:
		total_plays += level.plays
		total_wins += level.wins
	if total_plays < 1:
		return {"ok": false, "msg": "no level plays recorded"}
	return {"ok": true}

func test_bot_telemetry_level_fields() -> Dictionary:
	var bot: SneferuBot = SneferuBot.new()
	var result: Dictionary = bot.run_with_args({
		"telemetry-out": "user://test_telemetry2.json",
		"games": 1,
		"seed": 7,
		"frame-budget": 3000
	})
	if not result.get("ok", false):
		return {"ok": false, "msg": result.get("error", "run failed")}
	var levels: Array = result.telemetry.levels
	for level in levels:
		if not level.has("level_id"):
			return {"ok": false, "msg": "level missing level_id"}
		if not level.has("plays"):
			return {"ok": false, "msg": "level missing plays"}
		if not level.has("wins"):
			return {"ok": false, "msg": "level missing wins"}
		if not level.has("avg_moves_used"):
			return {"ok": false, "msg": "level missing avg_moves_used"}
		if not level.has("move_limit"):
			return {"ok": false, "msg": "level missing move_limit"}
		if not level.has("dead_boards"):
			return {"ok": false, "msg": "level missing dead_boards"}
	return {"ok": true}

func test_bot_parse_args() -> Dictionary:
	# why: verify the arg parser handles the standard harness args
	var bot: SneferuBot = SneferuBot.new()
	var args: Dictionary = bot.parse_user_args()
	# why: in test mode there are no user args; this just verifies the method works
	# and returns a Dictionary without crashing
	if not args is Dictionary:
		return {"ok": false, "msg": "parse_user_args did not return Dictionary"}
	return {"ok": true}
