class_name SaveStore
extends Node
## Atomic JSON I/O for all four save files (G6 §2 app/save_store.gd).
## The ONLY writer of user://save_*.json: temp+rename so no partial file is
## ever observed. Wall-clock timestamps are injected HERE, never in core/ —
## shapes come from the pure SaveCodec. Child of Main in main.tscn; the SSM
## receives it via set_save_store (tests may instantiate standalone).

const CAMPAIGN_PATH: String = "user://save_campaign.json"
const PROFILE_PATH: String = "user://save_profile.json"
const SCORES_PATH: String = "user://save_scores.json"
const SETTINGS_PATH: String = "user://save_settings.json"

## why: test seam — a suite may point the store at a scratch user:// prefix
var path_prefix: String = ""

func save_exists() -> bool:
	return FileAccess.file_exists(_p(CAMPAIGN_PATH))

func write_campaign(data: Dictionary) -> bool:
	return _atomic_write(_p(CAMPAIGN_PATH), SaveCodec.encode_campaign(data, _now()))

func read_campaign() -> Dictionary:
	return SaveCodec.decode_campaign(_read_text(_p(CAMPAIGN_PATH)))

func write_profile(data: Dictionary) -> bool:
	return _atomic_write(_p(PROFILE_PATH), SaveCodec.encode_profile(data))

func read_profile() -> Dictionary:
	return SaveCodec.decode_profile(_read_text(_p(PROFILE_PATH)))

func write_scores(data: Dictionary) -> bool:
	return _atomic_write(_p(SCORES_PATH), SaveCodec.encode_scores(data))

func read_scores() -> Dictionary:
	return SaveCodec.decode_scores(_read_text(_p(SCORES_PATH)))

func write_settings(data: Dictionary) -> bool:
	return _atomic_write(_p(SETTINGS_PATH), SaveCodec.encode_settings(data))

func read_settings() -> Dictionary:
	return SaveCodec.decode_settings(_read_text(_p(SETTINGS_PATH)))

func erase_campaign() -> bool:
	# why: new-game flow deletes the campaign save; profile/scores survive
	return _remove(_p(CAMPAIGN_PATH))

func erase_settings() -> bool:
	return _remove(_p(SETTINGS_PATH))

func erase_all() -> void:
	_remove(_p(CAMPAIGN_PATH))
	_remove(_p(PROFILE_PATH))
	_remove(_p(SCORES_PATH))
	_remove(_p(SETTINGS_PATH))

func _p(path: String) -> String:
	if path_prefix.is_empty():
		return path
	return "user://" + path_prefix + path.trim_prefix("user://")

func _now() -> int:
	return int(Time.get_unix_time_from_system())

func _read_text(path: String) -> String:
	if not FileAccess.file_exists(path):
		return ""
	var f: FileAccess = FileAccess.open(path, FileAccess.READ)
	if f == null:
		return ""
	var text: String = f.get_as_text()
	f.close()
	return text

func _atomic_write(path: String, data: Dictionary) -> bool:
	var temp_path: String = path + ".tmp"
	var f: FileAccess = FileAccess.open(temp_path, FileAccess.WRITE)
	if f == null:
		return false
	f.store_string(SaveCodec.to_json(data))
	f.flush()
	f.close()
	var dir: DirAccess = DirAccess.open("user://")
	if dir == null:
		return false
	# why: atomic rename — temp + rename guarantees no partial file is ever seen
	return dir.rename(temp_path, path) == OK

func _remove(path: String) -> bool:
	if not FileAccess.file_exists(path):
		return true
	var dir: DirAccess = DirAccess.open("user://")
	if dir == null:
		return false
	return dir.remove(path) == OK
