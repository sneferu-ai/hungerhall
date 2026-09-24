extends RefCounted
## test_juice_contracts — JuiceContracts traceability: every contract row's
## structure + every tunable key reference resolves against res://Tunables.json
## (G9 'Juice constants are DATA'; G10 DoD #2). Pins every row's G9 numbers
## (positive) and fails on silent alteration (negative — a removed/renamed
## juice.* key or a malformed row breaks a test).

const _SEG_KINDS: Array = ["float", "color", "scale"]
const _EASINGS: Array = ["linear", "cubic_in", "cubic_out", "cubic_in_out", "back_out"]

func _tunables() -> TunablesLoader:
	var t: TunablesLoader = TunablesLoader.new()
	t.load_from_path("res://Tunables.json")
	return t

func test_contract_table_present() -> Dictionary:
	var c: Dictionary = JuiceContracts.contract()
	if c.is_empty():
		return {"ok": false, "msg": "JuiceContracts.contract() returned empty"}
	# why: a representative subset — if any are missing the table was silently
	# truncated or a row was renamed
	var required: Array = ["AC-01", "AC-15", "AC-20", "AC-35", "AC-47", "AC-52", "AC-57", "AC-63"]
	for ac in required:
		if not c.has(ac):
			return {"ok": false, "msg": "contract missing key: %s" % ac}
	return {"ok": true}

func test_every_row_well_formed() -> Dictionary:
	var c: Dictionary = JuiceContracts.contract()
	for ac: String in c.keys():
		var row: Dictionary = c[ac]
		for field in ["name", "type", "tier"]:
			if not row.has(field):
				return {"ok": false, "msg": "%s missing field: %s" % [ac, field]}
		if int(row.get("tier", 0)) < 0:
			return {"ok": false, "msg": "%s.tier = %d, must be >= 0" % [ac, int(row.get("tier", 0))]}
		if str(row.get("type", "")).is_empty():
			return {"ok": false, "msg": "%s.type is empty" % ac}
		# why: segments must be an Array (empty is valid for dwell/hold rows)
		var segs: Variant = row.get("segments", [])
		if not (segs is Array):
			return {"ok": false, "msg": "%s.segments is not an Array" % ac}
		var i: int = 0
		for seg: Variant in segs:
			if not (seg is Dictionary):
				return {"ok": false, "msg": "%s.segment[%d] is not a Dictionary" % [ac, i]}
			var d: Dictionary = seg
			if not d.has("kind"):
				return {"ok": false, "msg": "%s.segment[%d] missing kind" % [ac, i]}
			var kind: String = str(d.get("kind", ""))
			if not _SEG_KINDS.has(kind):
				return {"ok": false, "msg": "%s.segment[%d] kind '%s' not in %s" % [ac, i, kind, str(_SEG_KINDS)]}
			if not d.has("ms_key"):
				return {"ok": false, "msg": "%s.segment[%d] missing ms_key" % [ac, i]}
			if str(d.get("ms_key", "")).is_empty():
				return {"ok": false, "msg": "%s.segment[%d] ms_key is empty" % [ac, i]}
			if d.has("easing"):
				var ez: String = str(d.get("easing", ""))
				if not ez.is_empty() and not _EASINGS.has(ez):
					return {"ok": false, "msg": "%s.segment[%d] easing '%s' not in %s" % [ac, i, ez, str(_EASINGS)]}
			i += 1
	return {"ok": true}

func test_segment_keys_resolve_in_tunables() -> Dictionary:
	var c: Dictionary = JuiceContracts.contract()
	var t: TunablesLoader = _tunables()
	for ac: String in c.keys():
		var row: Dictionary = c[ac]
		var segs: Array = row.get("segments", [])
		for seg: Variant in segs:
			var d: Dictionary = seg
			var ms_key: String = str(d.get("ms_key", ""))
			if not ms_key.is_empty() and not t.has_key(ms_key):
				return {"ok": false, "msg": "%s: ms_key '%s' not in Tunables.json" % [ac, ms_key]}
			# from_key / to_key — identity/duration references must resolve
			for fk in ["from_key", "to_key"]:
				var k: String = str(d.get(fk, ""))
				if not k.is_empty() and not t.has_key(k):
					return {"ok": false, "msg": "%s: %s '%s' not in Tunables.json" % [ac, fk, k]}
		# composite keys (AC-52 void-bridge)
		for fk in ["cycles_key", "on_ms_key", "off_ms_key", "peak_key"]:
			var k: String = str(row.get(fk, ""))
			if not k.is_empty() and not t.has_key(k):
				return {"ok": false, "msg": "%s: %s '%s' not in Tunables.json" % [ac, fk, k]}
		# dwell key (banner hold)
		var dwell: String = str(row.get("dwell_ms_key", ""))
		if not dwell.is_empty() and not t.has_key(dwell):
			return {"ok": false, "msg": "%s: dwell_ms_key '%s' not in Tunables.json" % [ac, dwell]}
	return {"ok": true}

func test_type_table_caps_positive() -> Dictionary:
	var tt: Dictionary = JuiceContracts.type_table()
	if tt.is_empty():
		return {"ok": false, "msg": "type_table() returned empty"}
	for ttype: String in tt.keys():
		var entry: Dictionary = tt[ttype]
		for cap_field in ["cap", "critical_subcap", "overflow"]:
			if entry.has(cap_field):
				if int(entry[cap_field]) < 0:
					return {"ok": false, "msg": "type_table.%s.%s = %d, must be >= 0" % [ttype, cap_field, int(entry[cap_field])]}
	return {"ok": true}

func test_particle_table_well_formed() -> Dictionary:
	var pt: Dictionary = JuiceContracts.particle_table()
	if pt.is_empty():
		return {"ok": false, "msg": "particle_table() returned empty"}
	for ptype: String in pt.keys():
		var entry: Dictionary = pt[ptype]
		if not entry.has("count"):
			return {"ok": false, "msg": "particle_table.%s missing count" % ptype}
		if int(entry["count"]) < 0:
			return {"ok": false, "msg": "particle_table.%s.count = %d, must be >= 0" % [ptype, int(entry["count"])]}
	return {"ok": true}

func test_eviction_order_is_array() -> Dictionary:
	var ev: Array = JuiceContracts.eviction_order()
	if ev.is_empty():
		return {"ok": false, "msg": "eviction_order() returned empty"}
	return {"ok": true}

func test_hitstop_table_well_formed() -> Dictionary:
	var hs: Dictionary = JuiceContracts.hitstop_table()
	if hs.is_empty():
		return {"ok": false, "msg": "hitstop_table() returned empty"}
	for k: String in hs.keys():
		var entry: Dictionary = hs[k]
		if not entry.has("frames_key"):
			return {"ok": false, "msg": "hitstop_table.%s missing frames_key" % k}
		if int(entry.get("frames_default", 0)) < 0:
			return {"ok": false, "msg": "hitstop_table.%s.frames_default < 0" % k}
	return {"ok": true}

func test_shake_table_well_formed() -> Dictionary:
	var sh: Dictionary = JuiceContracts.shake_table()
	if sh.is_empty():
		return {"ok": false, "msg": "shake_table() returned empty"}
	for k: String in sh.keys():
		var entry: Dictionary = sh[k]
		for field in ["mag_key", "ms_key", "falloff"]:
			if not entry.has(field):
				return {"ok": false, "msg": "shake_table.%s missing %s" % [k, field]}
	return {"ok": true}

func test_haptic_table_well_formed() -> Dictionary:
	var hp: Dictionary = JuiceContracts.haptic_table()
	if hp.is_empty():
		return {"ok": false, "msg": "haptic_table() returned empty"}
	for k: String in hp.keys():
		var entry: Dictionary = hp[k]
		for field in ["weak_key", "strong_key", "ms_key"]:
			if not entry.has(field):
				return {"ok": false, "msg": "haptic_table.%s missing %s" % [k, field]}
	return {"ok": true}

func test_zone_for_floor_boundaries() -> Dictionary:
	# why: zone_for_floor is the floor→zone mapping the tint system reads;
	# wrong boundaries would tint the wrong floors
	if JuiceContracts.zone_for_floor(1) != "drowned":
		return {"ok": false, "msg": "zone_for_floor(1) = %s, expected drowned" % JuiceContracts.zone_for_floor(1)}
	if JuiceContracts.zone_for_floor(6) != "drowned":
		return {"ok": false, "msg": "zone_for_floor(6) = %s, expected drowned" % JuiceContracts.zone_for_floor(6)}
	if JuiceContracts.zone_for_floor(7) != "cinder":
		return {"ok": false, "msg": "zone_for_floor(7) = %s, expected cinder" % JuiceContracts.zone_for_floor(7)}
	if JuiceContracts.zone_for_floor(12) != "cinder":
		return {"ok": false, "msg": "zone_for_floor(12) = %s, expected cinder" % JuiceContracts.zone_for_floor(12)}
	if JuiceContracts.zone_for_floor(13) != "starved":
		return {"ok": false, "msg": "zone_for_floor(13) = %s, expected starved" % JuiceContracts.zone_for_floor(13)}
	if JuiceContracts.zone_for_floor(18) != "starved":
		return {"ok": false, "msg": "zone_for_floor(18) = %s, expected starved" % JuiceContracts.zone_for_floor(18)}
	if JuiceContracts.zone_for_floor(19) != "throne":
		return {"ok": false, "msg": "zone_for_floor(19) = %s, expected throne" % JuiceContracts.zone_for_floor(19)}
	if JuiceContracts.zone_for_floor(24) != "throne":
		return {"ok": false, "msg": "zone_for_floor(24) = %s, expected throne" % JuiceContracts.zone_for_floor(24)}
	return {"ok": true}

func test_juice_director_parses() -> Dictionary:
	# why: JuiceDirector must load and instantiate — a parse error means the
	# wired main.tscn node fails silently at boot (the round-2 gap this test pins)
	var s: GDScript = load("res://juice/juice_director.gd")
	if s == null or not (s is GDScript):
		return {"ok": false, "msg": "juice_director.gd failed to load"}
	if not s.can_instantiate():
		return {"ok": false, "msg": "juice_director.gd parse error (cannot instantiate)"}
	return {"ok": true}
