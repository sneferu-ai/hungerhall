extends RefCounted
## test_presentation — presentation_contract.json schema + palette + ui_regions
## + frame_floors validation (G6 §2 tests tree; FIX-776 machine-measured look
## contract). Pure data validation: no rendering, no audio, no engine nodes.
## Verifies the contract the playtest frame-sanity gates and the g6 art-bible
## delivery both read from.

const _PATH: String = "res://presentation_contract.json"

func _contract() -> Dictionary:
	var f: FileAccess = FileAccess.open(_PATH, FileAccess.READ)
	if f == null:
		return {}
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	f.close()
	if parsed is Dictionary:
		return parsed
	return {}

func test_file_present_and_parseable() -> Dictionary:
	var c: Dictionary = _contract()
	if c.is_empty():
		return {"ok": false, "msg": "presentation_contract.json missing or unparseable"}
	return {"ok": true}

func test_schema_token() -> Dictionary:
	var c: Dictionary = _contract()
	if c.is_empty():
		return {"ok": false, "msg": "contract missing"}
	if str(c.get("schema", "")) != "presentation_contract_v1":
		return {"ok": false, "msg": "schema = '%s', expected presentation_contract_v1" % str(c.get("schema", ""))}
	return {"ok": true}

func test_dimension_block_complete() -> Dictionary:
	var c: Dictionary = _contract()
	var d: Dictionary = c.get("dimension", {})
	if d.is_empty():
		return {"ok": false, "msg": "dimension block missing"}
	for key in ["viewport_width", "viewport_height", "window_width", "window_height", "tile_size", "floor_grid_w", "floor_grid_h"]:
		if not d.has(key):
			return {"ok": false, "msg": "dimension missing key: %s" % key}
		if int(d[key]) <= 0:
			return {"ok": false, "msg": "dimension.%s = %d, must be > 0" % [key, int(d[key])]}
	# why: window must be >= viewport (the spec's 640×360 base → 1280×720 window)
	if int(d["window_width"]) < int(d["viewport_width"]) or int(d["window_height"]) < int(d["viewport_height"]):
		return {"ok": false, "msg": "window smaller than viewport: %dx%d vs %dx%d" % [int(d["window_width"]), int(d["window_height"]), int(d["viewport_width"]), int(d["viewport_height"])]}
	return {"ok": true}

func test_palette_hex_values_parse_to_valid_color() -> Dictionary:
	var c: Dictionary = _contract()
	var palette: Dictionary = c.get("palette", {})
	if palette.is_empty():
		return {"ok": false, "msg": "palette block missing"}
	for key in palette:
		var hex: String = str(palette[key])
		if not hex.begins_with("#"):
			return {"ok": false, "msg": "palette.%s = '%s', expected #rrggbb hex" % [key, hex]}
		if not Color.html_is_valid(hex):
			return {"ok": false, "msg": "palette.%s = '%s', not a valid hex color" % [key, hex]}
		var col: Color = Color.html(hex)
		# why: a hex that parses to fully transparent (a=0) is a malformed token
		if col.a < 1.0:
			return {"ok": false, "msg": "palette.%s = '%s' parsed with alpha %.2f, expected opaque" % [key, hex, col.a]}
	return {"ok": true}

func test_palette_has_locked_tokens() -> Dictionary:
	# why: G4 Palette A locks these named tokens; the HUD/world/zone rendering
	# all read from them — a missing token is a broken binding, not a style choice
	var c: Dictionary = _contract()
	var palette: Dictionary = c.get("palette", {})
	var required: Array = [
		"canvas", "floor_mid", "wall_body", "wall_cap", "text_bone", "ui_slate",
		"service_amber", "critical_brick", "food_gold", "key_silver", "spectral_cyan",
		"hero_warrior", "hero_valkyrie", "hero_wizard", "hero_elf",
		"zone_drowned", "zone_cinder", "zone_starved", "zone_throne"
	]
	for tok in required:
		if not palette.has(tok):
			return {"ok": false, "msg": "palette missing locked token: %s" % tok}
	return {"ok": true}

func test_ui_regions_within_unit_bounds() -> Dictionary:
	var c: Dictionary = _contract()
	var regions: Array = c.get("ui_regions", [])
	if regions.is_empty():
		return {"ok": false, "msg": "ui_regions missing or empty"}
	for r in regions:
		if not (r is Dictionary):
			return {"ok": false, "msg": "ui_regions entry is not a Dictionary: %s" % str(r)}
		var x: float = float(r.get("x", -1.0))
		var y: float = float(r.get("y", -1.0))
		var w: float = float(r.get("w", -1.0))
		var h: float = float(r.get("h", -1.0))
		for pair in [["x", x], ["y", y], ["w", w], ["h", h]]:
			if pair[1] < 0.0 or pair[1] > 1.0:
				return {"ok": false, "msg": "region '%s' %s = %.3f, outside [0,1]" % [str(r.get("name", "?")), pair[0], pair[1]]}
		if w <= 0.0 or h <= 0.0:
			return {"ok": false, "msg": "region '%s' has non-positive w/h: %.3f×%.3f" % [str(r.get("name", "?")), w, h]}
		if x + w > 1.0 + 0.0001:
			return {"ok": false, "msg": "region '%s' x+w = %.3f exceeds 1.0" % [str(r.get("name", "?")), x + w]}
		if y + h > 1.0 + 0.0001:
			return {"ok": false, "msg": "region '%s' y+h = %.3f exceeds 1.0" % [str(r.get("name", "?")), y + h]}
	return {"ok": true}

func test_ui_regions_non_overlapping() -> Dictionary:
	# why: overlapping HUD safe zones mean two widgets compete for the same
	# screen fraction — a presentation contract that allows this is lying about
	# the layout. AABB overlap: two boxes overlap iff they intersect on both axes.
	var c: Dictionary = _contract()
	var regions: Array = c.get("ui_regions", [])
	for i in range(regions.size()):
		var a: Dictionary = regions[i]
		var ax0: float = float(a.get("x", 0.0))
		var ay0: float = float(a.get("y", 0.0))
		var ax1: float = ax0 + float(a.get("w", 0.0))
		var ay1: float = ay0 + float(a.get("h", 0.0))
		for j in range(i + 1, regions.size()):
			var b: Dictionary = regions[j]
			var bx0: float = float(b.get("x", 0.0))
			var by0: float = float(b.get("y", 0.0))
			var bx1: float = bx0 + float(b.get("w", 0.0))
			var by1: float = by0 + float(b.get("h", 0.0))
			var overlap_x: bool = ax0 < bx1 and bx0 < ax1
			var overlap_y: bool = ay0 < by1 and by0 < ay1
			if overlap_x and overlap_y:
				return {"ok": false, "msg": "ui_regions '%s' and '%s' overlap" % [str(a.get("name", "?")), str(b.get("name", "?"))]}
	return {"ok": true}

func test_frame_floors_within_valid_ranges() -> Dictionary:
	# why: frame_floors are fractions in [0,1] consumed by the playtest
	# frame-sanity gates (FIX-776). A value outside [0,1] is a malformed gate
	# threshold that would either never fire or fire on every frame.
	var c: Dictionary = _contract()
	var ff: Dictionary = c.get("frame_floors", {})
	if ff.is_empty():
		return {"ok": false, "msg": "frame_floors block missing"}
	var keys: Array = ["near_black_max_fraction", "near_uniform_max_fraction", "min_channel_spread", "letterbox_max_fraction"]
	for key in keys:
		if not ff.has(key):
			return {"ok": false, "msg": "frame_floors missing key: %s" % key}
		var v: float = float(ff[key])
		if v < 0.0 or v > 1.0:
			return {"ok": false, "msg": "frame_floors.%s = %.3f, outside [0,1]" % [key, v]}
	# why: near_uniform_max must exceed near_black_max (a uniform frame is a
	# stricter condition than a black frame — the floor must sit higher)
	if float(ff["near_uniform_max_fraction"]) <= float(ff["near_black_max_fraction"]):
		return {"ok": false, "msg": "near_uniform_max (%.3f) must exceed near_black_max (%.3f)" % [float(ff["near_uniform_max_fraction"]), float(ff["near_black_max_fraction"])]}
	return {"ok": true}

func test_readability_bar_block() -> Dictionary:
	var c: Dictionary = _contract()
	var rb: Dictionary = c.get("readability_bar", {})
	if rb.is_empty():
		return {"ok": false, "msg": "readability_bar block missing"}
	if not rb.has("min_contrast"):
		return {"ok": false, "msg": "readability_bar missing min_contrast"}
	var mc: float = float(rb["min_contrast"])
	if mc <= 0.0:
		return {"ok": false, "msg": "readability_bar.min_contrast = %.2f, must be > 0" % mc}
	if not rb.has("height_fraction"):
		return {"ok": false, "msg": "readability_bar missing height_fraction"}
	var hf: float = float(rb["height_fraction"])
	if hf <= 0.0 or hf > 1.0:
		return {"ok": false, "msg": "readability_bar.height_fraction = %.3f, outside (0,1]" % hf}
	return {"ok": true}

func test_camera_block() -> Dictionary:
	var c: Dictionary = _contract()
	var cam: Dictionary = c.get("camera", {})
	if cam.is_empty():
		return {"ok": false, "msg": "camera block missing"}
	for key in ["dead_zone_x", "dead_zone_y", "lead_px", "trauma_kick_px"]:
		if not cam.has(key):
			return {"ok": false, "msg": "camera missing key: %s" % key}
		if float(cam[key]) < 0.0:
			return {"ok": false, "msg": "camera.%s = %.1f, must be >= 0" % [key, float(cam[key])]}
	return {"ok": true}
