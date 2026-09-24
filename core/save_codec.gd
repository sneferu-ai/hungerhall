class_name SaveCodec
extends RefCounted
## Pure dict encode/decode/migrate for save v1 (G6 §2 core/save_codec.gd).
## ZERO FileAccess, ZERO DirAccess, ZERO wall-clock: file I/O, atomic
## temp+rename, and timestamp injection live in the four app/ store Nodes
## (SaveStore / ProfileStore / ScoreStore / SettingsStore). save_schema.json
## is documentation-only; this file is the authoritative shape.

const SAVE_VERSION = 1
const PROFILE_VERSION = 1
const SCORES_VERSION = 1
const SETTINGS_VERSION = 1

## ---- campaign ----

static func encode_campaign(data: Dictionary, now_unix: int) -> Dictionary:
	return {
		"save_version": SAVE_VERSION,
		"floor": int(data.get("floor", 1)),
		"class": str(data.get("class", "warrior")),
		"score": int(data.get("score", 0)),
		"potions_remaining": int(data.get("potions_remaining", 0)),
		"ng_plus": false,
		"timestamp": int(now_unix)
	}

static func decode_campaign(text: String) -> Dictionary:
	var d: Dictionary = _parse(text)
	if d.is_empty():
		return {}
	return migrate_campaign(d)

static func migrate_campaign(d: Dictionary) -> Dictionary:
	# why: G2 §6 — unrecognized version triggers a fresh start with
	# notification; the SSM/title read "_stale_version" as "no usable save"
	if int(d.get("save_version", 0)) != SAVE_VERSION:
		return {"_stale_version": true}
	return d

static func default_campaign() -> Dictionary:
	return {}

## ---- profile ----

static func encode_profile(data: Dictionary) -> Dictionary:
	var cleared: Array = []
	var raw: Variant = data.get("classes_cleared", [])
	if raw is Array:
		for entry in raw:
			cleared.append(str(entry))
	return {
		"profile_version": PROFILE_VERSION,
		"ng_plus_unlocked": bool(data.get("ng_plus_unlocked", false)),
		"classes_cleared": cleared
	}

static func decode_profile(text: String) -> Dictionary:
	var d: Dictionary = _parse(text)
	if d.is_empty():
		return default_profile()
	return migrate_profile(d)

static func migrate_profile(d: Dictionary) -> Dictionary:
	if int(d.get("profile_version", 0)) != PROFILE_VERSION:
		return default_profile()
	var base: Dictionary = default_profile()
	base["ng_plus_unlocked"] = bool(d.get("ng_plus_unlocked", false))
	var cleared: Array = []
	var raw: Variant = d.get("classes_cleared", [])
	if raw is Array:
		for entry in raw:
			cleared.append(str(entry))
	base["classes_cleared"] = cleared
	return base

static func default_profile() -> Dictionary:
	return {"ng_plus_unlocked": false, "classes_cleared": []}

## ---- scores ----

static func encode_scores(data: Dictionary) -> Dictionary:
	var standard: Dictionary = {}
	var raw: Variant = data.get("standard", {})
	if raw is Dictionary:
		standard = raw
	return {
		"scores_version": SCORES_VERSION,
		"standard": standard
	}

static func decode_scores(text: String) -> Dictionary:
	var d: Dictionary = _parse(text)
	if d.is_empty():
		return default_scores()
	return migrate_scores(d)

static func migrate_scores(d: Dictionary) -> Dictionary:
	if int(d.get("scores_version", 0)) != SCORES_VERSION:
		return default_scores()
	var standard: Variant = d.get("standard", {})
	if not (standard is Dictionary):
		return default_scores()
	return {"standard": standard}

static func default_scores() -> Dictionary:
	return {"standard": {}}

## why: pure score-append — returns the NEW scores dict; the ScoreStore owns
## the wall-clock timestamp parameter and the write (G6 §2 app/).
static func with_score_added(scores: Dictionary, initials: String, hero_class: String, score_value: int, floor_reached: int, now_unix: int) -> Dictionary:
	var standard: Dictionary = scores.get("standard", {})
	var class_entries: Array = []
	var existing: Variant = standard.get(hero_class, [])
	if existing is Array:
		class_entries = existing.duplicate(true)
	class_entries.append({
		"initials": initials.to_upper(),
		"score": score_value,
		"floor": floor_reached,
		"timestamp": int(now_unix)
	})
	class_entries.sort_custom(func(a, b): return int(a.score) > int(b.score))
	if class_entries.size() > 10:
		# why: per-class local guestbook keeps its top 10 only
		class_entries = class_entries.slice(0, 10)
	var new_standard: Dictionary = standard.duplicate(true)
	new_standard[hero_class] = class_entries
	return {"standard": new_standard}

## ---- settings ----

static func encode_settings(data: Dictionary) -> Dictionary:
	return {
		"settings_version": SETTINGS_VERSION,
		"sfx_vol": int(data.get("sfx_vol", 80)),
		"music_vol": int(data.get("music_vol", 60)),
		"captions": bool(data.get("captions", true)),
		"caption_size": int(data.get("caption_size", 24)),
		"reduced_motion": bool(data.get("reduced_motion", false)),
		"rumble_intensity": int(data.get("rumble_intensity", 50)),
		"auto_fire": bool(data.get("auto_fire", false)),
		"fullscreen": bool(data.get("fullscreen", false)),
		"bindings": data.get("bindings", {})
	}

static func decode_settings(text: String) -> Dictionary:
	var d: Dictionary = _parse(text)
	if d.is_empty():
		return default_settings()
	if int(d.get("settings_version", 0)) != SETTINGS_VERSION:
		return default_settings()
	return normalize_settings(d)

## why: forward-fill — a missing key takes its default, an extra key survives.
## JSON.parse returns every number as a FLOAT; the canonical record is int/
## bool typed, and GDScript Dictionary == distinguishes 24.0 from 24 — so a
## parsed record must be coerced back to the defaults' Variant types or
## decode(encode(x)) never compares equal to default_settings().
static func normalize_settings(d: Dictionary) -> Dictionary:
	var out: Dictionary = d.duplicate(true)
	var defaults: Dictionary = default_settings()
	for key in defaults:
		if not out.has(key):
			out[key] = defaults[key]
		else:
			out[key] = _coerce_to(out[key], defaults[key])
	return out

static func _coerce_to(value: Variant, default_value: Variant) -> Variant:
	match typeof(default_value):
		TYPE_INT:
			return int(value)
		TYPE_BOOL:
			return bool(value)
		TYPE_DICTIONARY:
			return value if value is Dictionary else default_value.duplicate(true)
		_:
			return value

static func default_settings() -> Dictionary:
	# why: the canonical record carries settings_version (save_schema.json
	# documents it in the settings shape and encode_settings always writes it).
	# Keeping it here makes decode(encode(default_settings())) == default_settings()
	# — reset_to_defaults can then round-trip back to exactly this record.
	return {
		"settings_version": SETTINGS_VERSION,
		"sfx_vol": 80, "music_vol": 60, "captions": true,
		"caption_size": 24, "reduced_motion": false,
		"rumble_intensity": 50, "auto_fire": false,
		"fullscreen": false, "bindings": {}
	}

## ---- shared pure helpers ----

static func to_json(data: Dictionary) -> String:
	return JSON.stringify(data, "  ") + "\n"

static func _parse(text: String) -> Dictionary:
	if text.strip_edges().is_empty():
		return {}
	var json: JSON = JSON.new()
	if json.parse(text) != OK:
		return {}
	if not (json.data is Dictionary):
		return {}
	return json.data
