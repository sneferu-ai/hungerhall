class_name TransitionTable
extends RefCounted
## G2 §1 + G5 LAR transition edges as pure data (G6 §3.2).
## Legality checks live here; condition vocabulary is evaluated by SSM.

const State = StateEnums.State
const Verb = StateEnums.Verb

## Each row: {from: int, verb: int, to: int, condition: String}
static func all_rows() -> Array:
	return [
		{from = State.SPLASH, verb = Verb.PRESS, to = State.TITLE, condition = "splash_complete_or_skippable"},
		{from = State.TITLE, verb = Verb.PRESS, to = State.CLASS_SELECT, condition = "always"},
		{from = State.TITLE, verb = Verb.RESUME, to = State.PLAYING, condition = "save_exists"},
		{from = State.TITLE, verb = Verb.SETTINGS, to = State.SETTINGS, condition = "always"},
		{from = State.TITLE, verb = Verb.BACK, to = State.HALL_OF_HEROES, condition = "always"},
		{from = State.HALL_OF_HEROES, verb = Verb.BACK, to = State.TITLE, condition = "always"},
		{from = State.CLASS_SELECT, verb = Verb.CHOOSE, to = State.PLAYING, condition = "always"},
		{from = State.PLAYING, verb = Verb.PAUSE, to = State.PAUSED, condition = "always"},
		{from = State.PAUSED, verb = Verb.RESUME, to = State.PLAYING, condition = "always"},
		{from = State.PAUSED, verb = Verb.SETTINGS, to = State.SETTINGS, condition = "always"},
		{from = State.PAUSED, verb = Verb.QUIT, to = State.TITLE, condition = "always"},
		{from = State.SETTINGS, verb = Verb.BACK, to = State.PAUSED, condition = "entered_from_paused"},
		{from = State.SETTINGS, verb = Verb.BACK, to = State.TITLE, condition = "entered_from_title"},
		{from = State.PLAYING, verb = Verb.CLEAR, to = State.FLOOR_RESULTS, condition = "exit_overlap_3 AND floor_lt_24"},
		{from = State.PLAYING, verb = Verb.FINISH, to = State.CAMPAIGN_RESULTS, condition = "exit_overlap_3 AND floor_eq_24"},
		{from = State.FLOOR_RESULTS, verb = Verb.ADVANCE, to = State.PLAYING, condition = "always"},
		{from = State.FLOOR_RESULTS, verb = Verb.SAVE_QUIT, to = State.TITLE, condition = "always"},
		{from = State.CAMPAIGN_RESULTS, verb = Verb.ENTER, to = State.TITLE, condition = "always"},
		{from = State.PLAYING, verb = Verb.DRAIN, to = State.DYING, condition = "hp_zero"},
		{from = State.DYING, verb = Verb.PROMPT, to = State.CONTINUE_OFFER, condition = "dying_complete"},
		{from = State.CONTINUE_OFFER, verb = Verb.CONTINUE, to = State.PLAYING, condition = "tokens_gt_0 AND yes"},
		{from = State.CONTINUE_OFFER, verb = Verb.EXPIRE, to = State.GAME_OVER, condition = "no OR timeout OR tokens_eq_0"},
		{from = State.GAME_OVER, verb = Verb.RETRY, to = State.PLAYING, condition = "always"},
		{from = State.GAME_OVER, verb = Verb.ENTER, to = State.TITLE, condition = "always"},
		{from = State.TITLE, verb = Verb.CONFIRM, to = State.PLAYING, condition = "save_exists"},
		# G5 §1 edge additions (binding for G7; §3.2's enumeration omits them):
		# class_select → title on BackOut (no warn — nothing committed)
		{from = State.CLASS_SELECT, verb = Verb.BACK, to = State.TITLE, condition = "always"},
		# game_over / campaign_results → hall_of_heroes on ScoresChosen (no warn)
		{from = State.GAME_OVER, verb = Verb.BACK, to = State.HALL_OF_HEROES, condition = "always"},
		{from = State.CAMPAIGN_RESULTS, verb = Verb.BACK, to = State.HALL_OF_HEROES, condition = "always"},
	]

static func find_transition(from_state: int, verb: int) -> Dictionary:
	for row in all_rows():
		if row.from == from_state and row.verb == verb:
			return row
	return {}

## why: (from, verb) pairs may be CONDITION-AMBIGUOUS — SETTINGS+BACK routes
## on entered_from_paused / entered_from_title (two rows share the key). A
## caller that evaluates conditions (the SSM) needs EVERY candidate in table
## order, not just the first, or the second route can never fire.
static func find_all_transitions(from_state: int, verb: int) -> Array:
	var out: Array = []
	for row in all_rows():
		if row.from == from_state and row.verb == verb:
			out.append(row)
	return out

static func is_legal(from_state: int, verb: int) -> bool:
	return not find_transition(from_state, verb).is_empty()

static func verb_name(v: int) -> String:
	for name in ["PRESS","RESUME","CHOOSE","PAUSE","QUIT","CLEAR","FINISH","ADVANCE","SAVE_QUIT","ENTER","DRAIN","PROMPT","CONTINUE","EXPIRE","BACK","SETTINGS","RETRY","SKIP","CONFIRM","CANCEL","TIMEOUT"]:
		if Verb[name] == v:
			return name
	return "UNKNOWN"

static func state_name(s: int) -> String:
	for name in ["SPLASH","TITLE","CLASS_SELECT","PLAYING","PAUSED","SETTINGS","HALL_OF_HEROES","DYING","CONTINUE_OFFER","GAME_OVER","FLOOR_RESULTS","CAMPAIGN_RESULTS"]:
		if State[name] == s:
			return name
	return "UNKNOWN"
