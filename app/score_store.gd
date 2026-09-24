class_name ScoreStore
extends Node
## Score domain store (G6 §2 app/score_store.gd): the per-class local
## guestbook. Owns the wall-clock timestamp injection for new entries; the
## append/sort/top-10 shape is the pure SaveCodec.with_score_added. Child of
## Main in main.tscn.

var save_store: SaveStore = null

func set_save_store(s: SaveStore) -> void:
	save_store = s

func read_scores() -> Dictionary:
	return _store().read_scores()

## why: GameOver + CampaignResults record the final score here (G2 §6)
func add_score(initials: String, hero_class_key: String, score_value: int, floor_reached: int) -> Dictionary:
	var current: Dictionary = _store().read_scores()
	var next: Dictionary = SaveCodec.with_score_added(
		current, initials, hero_class_key, score_value, floor_reached,
		int(Time.get_unix_time_from_system()))
	_store().write_scores(next)
	return next

## why: settings Reset Scores is scores-only; campaign/profile survive
func reset_scores() -> bool:
	return _store().write_scores(SaveCodec.default_scores())

func _store() -> SaveStore:
	if save_store == null:
		save_store = SaveStore.new()
	return save_store
