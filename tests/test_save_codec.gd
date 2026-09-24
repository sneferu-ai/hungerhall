extends RefCounted
## test_save_codec — pure codec roundtrips + corruption/version rejection.
## The codec is dict encode/decode/migrate only (G6 §2): NO FileAccess, NO
## wall-clock. Store I/O coverage lives in test_save.gd.

func test_campaign_roundtrip() -> Dictionary:
	var encoded: Dictionary = SaveCodec.encode_campaign({
		"floor": 7, "class": "wizard", "score": 4200, "potions_remaining": 2
	}, 1720000000)
	if int(encoded.get("save_version", 0)) != SaveCodec.SAVE_VERSION:
		return {"ok": false, "msg": "save_version not stamped"}
	if int(encoded.get("timestamp", 0)) != 1720000000:
		return {"ok": false, "msg": "timestamp must be injected by the caller (pure codec)"}
	var decoded: Dictionary = SaveCodec.decode_campaign(SaveCodec.to_json(encoded))
	if int(decoded.get("floor", 0)) != 7 or str(decoded.get("class", "")) != "wizard":
		return {"ok": false, "msg": "roundtrip lost fields: " + str(decoded)}
	return {"ok": true}

func test_campaign_corruption_rejected() -> Dictionary:
	if not SaveCodec.decode_campaign("{ not json").is_empty():
		return {"ok": false, "msg": "corrupt text must decode to empty"}
	if not SaveCodec.decode_campaign("").is_empty():
		return {"ok": false, "msg": "empty text must decode to empty"}
	if not SaveCodec.decode_campaign("[1,2,3]").is_empty():
		return {"ok": false, "msg": "non-dict JSON must decode to empty"}
	return {"ok": true}

func test_campaign_stale_version_flagged() -> Dictionary:
	# why: G2 §6 — unrecognized version triggers a fresh start with notification
	var stale: Dictionary = SaveCodec.decode_campaign('{"save_version": 99, "floor": 3}')
	if not stale.has("_stale_version"):
		return {"ok": false, "msg": "future version must be flagged _stale_version"}
	return {"ok": true}

func test_profile_roundtrip_and_default() -> Dictionary:
	var d: Dictionary = SaveCodec.default_profile()
	if d.get("classes_cleared") is Array and d.get("ng_plus_unlocked") == false:
		pass
	else:
		return {"ok": false, "msg": "default profile shape wrong: " + str(d)}
	var encoded: Dictionary = SaveCodec.encode_profile({"classes_cleared": ["warrior", "elf"]})
	var decoded: Dictionary = SaveCodec.decode_profile(SaveCodec.to_json(encoded))
	if (decoded.get("classes_cleared") as Array).size() != 2:
		return {"ok": false, "msg": "classes_cleared lost: " + str(decoded)}
	return {"ok": true}

func test_scores_top10_sorted() -> Dictionary:
	var scores: Dictionary = SaveCodec.default_scores()
	for i in range(12):
		scores = SaveCodec.with_score_added(scores, "abc", "warrior", i * 100, 5, 1720000000 + i)
	var entries: Array = scores.get("standard", {}).get("warrior", [])
	if entries.size() != 10:
		return {"ok": false, "msg": "guestbook must cap at 10, got %d" % entries.size()}
	if int(entries[0].score) != 1100:
		return {"ok": false, "msg": "entries not score-sorted: top=%s" % str(entries[0])}
	if str(entries[0].initials) != "ABC":
		return {"ok": false, "msg": "initials must be uppercased"}
	return {"ok": true}

func test_settings_default_fill() -> Dictionary:
	var partial: Dictionary = SaveCodec.decode_settings('{"settings_version": 1, "sfx_vol": 33}')
	if int(partial.get("sfx_vol", 0)) != 33:
		return {"ok": false, "msg": "explicit setting overwritten"}
	if int(partial.get("caption_size", 0)) != 24:
		return {"ok": false, "msg": "missing keys must take defaults"}
	var fresh: Dictionary = SaveCodec.decode_settings("")
	if fresh != SaveCodec.default_settings():
		return {"ok": false, "msg": "absent file must yield exact defaults"}
	return {"ok": true}

func test_migration_identity_v1() -> Dictionary:
	var v1: Dictionary = SaveCodec.encode_campaign({"floor": 2, "class": "elf", "score": 10, "potions_remaining": 0}, 123)
	if SaveCodec.migrate_campaign(v1) != v1:
		return {"ok": false, "msg": "v1 migration must be identity"}
	return {"ok": true}
