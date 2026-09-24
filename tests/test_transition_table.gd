extends RefCounted
## test_transition_table — legal/illegal transitions + condition vocab.

func test_title_press_to_class_select() -> Dictionary:
	var row: Dictionary = TransitionTable.find_transition(StateEnums.State.TITLE, StateEnums.Verb.PRESS)
	if row.is_empty():
		return {"ok": false, "msg": "TITLE→PRESS not found"}
	if row.to != StateEnums.State.CLASS_SELECT:
		return {"ok": false, "msg": "TITLE→PRESS goes to %d, expected CLASS_SELECT" % row.to}
	return {"ok": true}

func test_playing_drain_to_dying() -> Dictionary:
	var row: Dictionary = TransitionTable.find_transition(StateEnums.State.PLAYING, StateEnums.Verb.DRAIN)
	if row.is_empty():
		return {"ok": false, "msg": "PLAYING→DRAIN not found"}
	if row.to != StateEnums.State.DYING:
		return {"ok": false, "msg": "PLAYING→DRAIN goes to %d, expected DYING" % row.to}
	if row.condition != "hp_zero":
		return {"ok": false, "msg": "condition is '%s', expected 'hp_zero'" % row.condition}
	return {"ok": true}

func test_illegal_transition() -> Dictionary:
	# why: GAME_OVER → PRESS should not exist
	var row: Dictionary = TransitionTable.find_transition(StateEnums.State.GAME_OVER, StateEnums.Verb.PRESS)
	if not row.is_empty():
		return {"ok": false, "msg": "GAME_OVER→PRESS should be illegal"}
	return {"ok": true}

func test_floor_results_advance() -> Dictionary:
	var row: Dictionary = TransitionTable.find_transition(StateEnums.State.FLOOR_RESULTS, StateEnums.Verb.ADVANCE)
	if row.is_empty():
		return {"ok": false, "msg": "FLOOR_RESULTS→ADVANCE not found"}
	if row.to != StateEnums.State.PLAYING:
		return {"ok": false, "msg": "FLOOR_RESULTS→ADVANCE goes to %d, expected PLAYING" % row.to}
	return {"ok": true}

func test_continue_offer_paths() -> Dictionary:
	var cont: Dictionary = TransitionTable.find_transition(StateEnums.State.CONTINUE_OFFER, StateEnums.Verb.CONTINUE)
	var expire: Dictionary = TransitionTable.find_transition(StateEnums.State.CONTINUE_OFFER, StateEnums.Verb.EXPIRE)
	if cont.is_empty():
		return {"ok": false, "msg": "CONTINUE_OFFER→CONTINUE not found"}
	if expire.is_empty():
		return {"ok": false, "msg": "CONTINUE_OFFER→EXPIRE not found"}
	if cont.to != StateEnums.State.PLAYING:
		return {"ok": false, "msg": "CONTINUE goes to %d, expected PLAYING" % cont.to}
	if expire.to != StateEnums.State.GAME_OVER:
		return {"ok": false, "msg": "EXPIRE goes to %d, expected GAME_OVER" % expire.to}
	return {"ok": true}
