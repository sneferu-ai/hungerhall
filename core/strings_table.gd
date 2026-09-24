class_name StringsTable
extends RefCounted
## HUNGERHALL — G3 string manifest reader (G6 §2 data/strings.json).
## {key: {text, category, pool_index, class_variants}}; categories are
## "bark", "caption", "ui", "credits", "privacy". Loaded once via FileAccess,
## cached in a static dictionary (G6 §2 caption_band loading contract — the
## same table serves every screen; core/ owns it because FileAccess/JSON are
## GDScript standard library and ui/ must not import core/ for strings).
## Pure data. No Node, no rendering.

const MANIFEST_PATH: String = "res://data/strings.json"

static var _keys: Dictionary = {}
static var _loaded: bool = false
static var _load_error: String = ""

static func ensure_loaded() -> void:
	if _loaded:
		return
	_loaded = true
	_keys = {}
	_load_error = ""
	if not FileAccess.file_exists(MANIFEST_PATH):
		_load_error = "missing " + MANIFEST_PATH
		push_error("StringsTable: " + _load_error)
		return
	var f: FileAccess = FileAccess.open(MANIFEST_PATH, FileAccess.READ)
	if f == null:
		_load_error = "open failed " + MANIFEST_PATH
		push_error("StringsTable: " + _load_error)
		return
	var text: String = f.get_as_text()
	f.close()
	var parsed: Variant = JSON.parse_string(text)
	if not (parsed is Dictionary):
		_load_error = "parse failed " + MANIFEST_PATH
		push_error("StringsTable: " + _load_error)
		return
	var table: Variant = parsed.get("keys", {})
	if table is Dictionary:
		_keys = table

static func load_error() -> String:
	ensure_loaded()
	return _load_error

static func has_key(key: String) -> bool:
	ensure_loaded()
	return _keys.has(key)

## Primary accessor. Returns the entry text or fallback when absent.
static func text(key: String, fallback: String = "") -> String:
	ensure_loaded()
	var entry: Variant = _keys.get(key, null)
	if entry is Dictionary:
		return str(entry.get("text", fallback))
	return fallback

## Class-variant accessor (G3 [CLASS] slots): prefers class_variants[name],
## falls back to the base text, then to fallback.
static func text_for_class(key: String, class_name_key: String, fallback: String = "") -> String:
	ensure_loaded()
	var entry: Variant = _keys.get(key, null)
	if entry is Dictionary:
		var variants: Variant = entry.get("class_variants", null)
		if variants is Dictionary and variants.has(class_name_key):
			return str(variants[class_name_key])
		return str(entry.get("text", fallback))
	return fallback

## Ordered pool: collects keys "<prefix>.<n>" (n = 1..32) by pool_index.
## Missing indices are skipped; pools under 1 entry return [].
static func pool(prefix: String) -> Array:
	ensure_loaded()
	var entries: Array = []
	for i in range(1, 33):
		var key: String = prefix + "." + str(i)
		var entry: Variant = _keys.get(key, null)
		if entry is Dictionary:
			entries.append({"text": str(entry.get("text", "")), "index": int(entry.get("pool_index", i)), "class_variants": entry.get("class_variants", null)})
	entries.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return int(a.index) < int(b.index))
	var out: Array = []
	for e in entries:
		out.append(e.text)
	return out

## Pool entry with class variant resolved for one specific class.
static func pool_line_for_class(prefix: String, idx: int, class_name_key: String, fallback: String = "") -> String:
	ensure_loaded()
	var key: String = prefix + "." + str(idx)
	var entry: Variant = _keys.get(key, null)
	if entry is Dictionary:
		var variants: Variant = entry.get("class_variants", null)
		if variants is Dictionary and variants.has(class_name_key):
			return str(variants[class_name_key])
		return str(entry.get("text", fallback))
	return fallback

static func category_of(key: String) -> String:
	ensure_loaded()
	var entry: Variant = _keys.get(key, null)
	if entry is Dictionary:
		return str(entry.get("category", ""))
	return ""
