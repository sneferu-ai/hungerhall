extends RefCounted
## test_save — the app/ store layer (G6 §2): atomic I/O, schema v1 on disk,
## migration behavior, mid-floor no-save, FloorResults-entry autosave, and
## the guestbook score path. All I/O runs under a test path prefix and is
## erased in teardown.

const State = StateEnums.State
const Verb = StateEnums.Verb

var _prefix: String = "t_save_"
var _store: SaveStore = null
var _ssm: Node = null

func setup() -> void:
	_store = SaveStore.new()
	_store.path_prefix = _prefix

func teardown() -> void:
	if _store != null:
		_store.erase_all()
		_store.free()
		_store = null
	if _ssm != null:
		_ssm.free()
		_ssm = null

func test_campaign_write_read_roundtrip() -> Dictionary:
	if _store.save_exists():
		return {"ok": false, "msg": "campaign exists before any write"}
	var ok: bool = _store.write_campaign({"floor": 9, "class": "valkyrie", "score": 777, "potions_remaining": 1})
	if not ok:
		return {"ok": false, "msg": "write_campaign failed"}
	if not _store.save_exists():
		return {"ok": false, "msg": "save_exists false after write"}
	var d: Dictionary = _store.read_campaign()
	if int(d.get("floor", 0)) != 9 or str(d.get("class", "")) != "valkyrie" or int(d.get("score", -1)) != 777:
		return {"ok": false, "msg": "roundtrip mismatch: " + str(d)}
	if int(d.get("save_version", 0)) != 1:
		return {"ok": false, "msg": "on-disk schema must be save_version 1"}
	if int(d.get("timestamp", 0)) <= 0:
		return {"ok": false, "msg": "store must inject a wall-clock timestamp"}
	return {"ok": true}

func test_atomic_write_leaves_no_tmp() -> Dictionary:
	_store.write_campaign({"floor": 1, "class": "warrior", "score": 0, "potions_remaining": 0})
	if FileAccess.file_exists("user://" + _prefix + "save_campaign.json.tmp"):
		return {"ok": false, "msg": ".tmp sibling survived the rename — write not atomic"}
	return {"ok": true}

func test_corrupt_and_stale_files_rejected() -> Dictionary:
	var f: FileAccess = FileAccess.open("user://" + _prefix + "save_campaign.json", FileAccess.WRITE)
	if f == null:
		return {"ok": false, "msg": "cannot seed corrupt file"}
	f.store_string("{{{ not json")
	f.close()
	if not _store.read_campaign().is_empty():
		return {"ok": false, "msg": "corrupt file decoded as a save"}
	var f2: FileAccess = FileAccess.open("user://" + _prefix + "save_campaign.json", FileAccess.WRITE)
	f2.store_string('{"save_version": 42, "floor": 3}')
	f2.close()
	var stale: Dictionary = _store.read_campaign()
	if not stale.has("_stale_version"):
		return {"ok": false, "msg": "future version not flagged for fresh-start"}
	return {"ok": true}

func test_scores_guestbook_via_score_store() -> Dictionary:
	var scores: ScoreStore = ScoreStore.new()
	scores.set_save_store(_store)
	for i in range(12):
		scores.add_score("aaa", "elf", i * 50, 3)
	var on_disk: Dictionary = _store.read_scores()
	var entries: Array = on_disk.get("standard", {}).get("elf", [])
	if entries.size() != 10:
		return {"ok": false, "msg": "guestbook kept %d entries, expected top-10" % entries.size()}
	if int(entries[0].score) != 550:
		return {"ok": false, "msg": "top entry %s, expected 550" % str(entries[0])}
	scores.reset_scores()
	if not _store.read_scores().get("standard", {}).is_empty():
		return {"ok": false, "msg": "reset_scores left entries behind"}
	scores.free()
	return {"ok": true}

func test_settings_store_defaults_and_write() -> Dictionary:
	var settings: SettingsStore = SettingsStore.new()
	settings.set_save_store(_store)
	var fresh: Dictionary = settings.read_settings()
	if fresh != SaveCodec.default_settings():
		return {"ok": false, "msg": "absent settings file must yield defaults"}
	settings.write_settings({"sfx_vol": 15, "reduced_motion": true})
	var back: Dictionary = settings.read_settings()
	if int(back.get("sfx_vol", 0)) != 15 or back.get("reduced_motion") != true:
		return {"ok": false, "msg": "settings roundtrip failed: " + str(back)}
	if int(back.get("caption_size", 0)) != 24:
		return {"ok": false, "msg": "unset keys must default-fill on read"}
	settings.reset_to_defaults()
	if settings.read_settings() != SaveCodec.default_settings():
		return {"ok": false, "msg": "reset_to_defaults did not restore defaults"}
	settings.free()
	return {"ok": true}

func test_profile_store_campaign_clear_ledger() -> Dictionary:
	var profile: ProfileStore = ProfileStore.new()
	profile.set_save_store(_store)
	profile.record_campaign_clear("warrior")
	profile.record_campaign_clear("warrior")  # why: double-clear records once
	profile.record_campaign_clear("elf")
	var cleared: Array = profile.classes_cleared()
	if cleared.size() != 2 or not cleared.has("warrior") or not cleared.has("elf"):
		return {"ok": false, "msg": "classes_cleared ledger wrong: " + str(cleared)}
	profile.free()
	return {"ok": true}

func test_ssm_autosave_only_at_floor_results() -> Dictionary:
	# why: G5 — no save is ever written mid-floor; the one writer fires on
	# FloorResults entry
	_ssm = load("res://app/session_state_machine.gd").new()
	_ssm._ready()
	_ssm.set_save_store(_store)
	_ssm.boot()
	var session: RulesSession = RulesSession.new()
	session.setup_campaign(_ssm.tunables, _ssm.get_class_def(0), 71)
	_ssm.session = session
	_ssm._change_state(State.PLAYING)
	for i in range(30):
		_ssm.tick_once()
	if _store.save_exists():
		return {"ok": false, "msg": "save written MID-FLOOR"}
	session.exit_overlap_frames = 3
	_ssm.try_transition(Verb.CLEAR)
	if not _store.save_exists():
		return {"ok": false, "msg": "autosave missing at FloorResults entry"}
	var save: Dictionary = _store.read_campaign()
	if int(save.get("floor", 0)) != session.floor_number + 1:
		return {"ok": false, "msg": "autosave must record the NEXT floor"}
	return {"ok": true}
