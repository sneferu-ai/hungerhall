class_name TunablesLoader
extends RefCounted
## Parses and validates Tunables.json (game_tunables_v1, DIS-3 comprehensive).
## Single runtime + bake-time authority for every gameplay knob. Each entry:
## {"value": num, "band": [min, max], "step": num, "affects": [str, ...]}.
## Validation: value inside band, step >= 0, affects non-empty.

var _constants: Dictionary = {}
var _errors: Array = []

func load_from_dict(root: Dictionary) -> bool:
	_errors.clear()
	_constants = {}
	if root.get("schema", "") != "game_tunables_v1":
		_errors.append("schema is not game_tunables_v1")
		return false
	var consts = root.get("constants", {})
	if not (consts is Dictionary) or consts.is_empty():
		_errors.append("constants missing or empty")
		return false
	for key in consts:
		var entry = consts[key]
		if not (entry is Dictionary):
			_errors.append(str(key) + ": entry is not a dict")
			continue
		if not entry.has("value"):
			_errors.append(str(key) + ": missing value")
			continue
		var value = entry["value"]
		var band = entry.get("band", null)
		var step = entry.get("step", 0)
		var affects = entry.get("affects", [])
		# why: G10 juice identity keys (colors) ship {"band": null, "step": null,
		# "value": "#RRGGBB"} per G9 "Fixed identity keys". String values are
		# accepted ONLY for band==null && step==null identity entries — every
		# band-carrying key stays strictly numeric, so gameplay validation is
		# unchanged. A null step normalizes to 0 (the pre-G10 implicit default).
		if band == null and step == null:
			if not (value is int or value is float or value is String):
				_errors.append(str(key) + ": identity value must be numeric or string")
				continue
			if not (affects is Array) or affects.is_empty():
				_errors.append(str(key) + ": affects must be a non-empty array")
				continue
			_constants[key] = value
			continue
		if not (value is int or value is float):
			_errors.append(str(key) + ": value not numeric")
			continue
		if band != null:
			if not (band is Array) or band.size() != 2 or band[0] > band[1]:
				_errors.append(str(key) + ": malformed band")
				continue
			if value < band[0] or value > band[1]:
				_errors.append(str(key) + ": value outside band")
				continue
		if step == null:
			step = 0
		if not (step is int or step is float) or step < 0:
			_errors.append(str(key) + ": step must be numeric >= 0")
			continue
		if not (affects is Array) or affects.is_empty():
			_errors.append(str(key) + ": affects must be a non-empty array")
			continue
		_constants[key] = value
	return _errors.is_empty()

func load_from_path(path: String) -> bool:
	if not FileAccess.file_exists(path):
		_errors.clear()
		_errors.append("tunables file missing: " + path)
		return false
	var f := FileAccess.open(path, FileAccess.READ)
	var text := f.get_as_text()
	f.close()
	var parsed = JSON.parse_string(text)
	if parsed == null or not (parsed is Dictionary):
		_errors.clear()
		_errors.append("tunables file is not a JSON object")
		return false
	return load_from_dict(parsed)

func get_value(key: String, fallback: float = 0.0) -> float:
	if _constants.has(key):
		return float(_constants[key])
	return fallback

func get_int(key: String, fallback: int = 0) -> int:
	if _constants.has(key):
		return int(_constants[key])
	return fallback

## G10 juice identity keys — colors ship as "#RRGGBB" strings (band null /
## step null). Returns the parsed Color, or fallback for missing/malformed keys.
func get_color(key: String, fallback: Color = Color.WHITE) -> Color:
	if _constants.has(key) and _constants[key] is String:
		return Color(str(_constants[key]))
	return fallback

func has_key(key: String) -> bool:
	return _constants.has(key)

func keys() -> Array:
	return _constants.keys()

func errors() -> Array:
	return _errors.duplicate()

## Solver support: value overridden to a band extreme (or reset).
func with_override(key: String, value: float) -> TunablesLoader:
	var clone := TunablesLoader.new()
	clone._constants = _constants.duplicate()
	clone._constants[key] = value
	return clone

func band_of(key: String) -> Array:
	return []  # bands are validated at load; extremes are baked into floor data
