extends RefCounted
## test_tunables — TunablesLoader validation + value/band/get.

func test_load_from_path() -> Dictionary:
	var t: TunablesLoader = TunablesLoader.new()
	if not t.load_from_path("res://Tunables.json"):
		return {"ok": false, "msg": "load failed: " + str(t.errors())}
	if not t.errors().is_empty():
		return {"ok": false, "msg": "load produced errors: " + str(t.errors())}
	return {"ok": true}

func test_known_values() -> Dictionary:
	var t: TunablesLoader = TunablesLoader.new()
	t.load_from_path("res://Tunables.json")
	if t.get_int("food_hp", 0) != 150:
		return {"ok": false, "msg": "food_hp = %d, expected 150" % t.get_int("food_hp", 0)}
	if t.get_value("warrior_hp", 0) != 800:
		return {"ok": false, "msg": "warrior_hp = %f, expected 800" % t.get_value("warrior_hp", 0)}
	return {"ok": true}

func test_fallback_on_missing_key() -> Dictionary:
	var t: TunablesLoader = TunablesLoader.new()
	t.load_from_path("res://Tunables.json")
	if t.get_int("nonexistent_key", 42) != 42:
		return {"ok": false, "msg": "missing key did not return fallback"}
	return {"ok": true}

func test_all_drain_bands_present() -> Dictionary:
	var t: TunablesLoader = TunablesLoader.new()
	t.load_from_path("res://Tunables.json")
	for i in range(1, 9):
		if not t.has_key("drain_band_" + str(i)):
			return {"ok": false, "msg": "drain_band_%d missing" % i}
		if not t.has_key("target_seconds_band_" + str(i)):
			return {"ok": false, "msg": "target_seconds_band_%d missing" % i}
	return {"ok": true}

func test_class_hp_distinct() -> Dictionary:
	var t: TunablesLoader = TunablesLoader.new()
	t.load_from_path("res://Tunables.json")
	var hps: Array = [
		t.get_int("warrior_hp"), t.get_int("valkyrie_hp"),
		t.get_int("wizard_hp"), t.get_int("elf_hp")
	]
	var seen: Dictionary = {}
	for hp in hps:
		if seen.has(hp):
			return {"ok": false, "msg": "duplicate class HP: %d" % hp}
		seen[hp] = true
	return {"ok": true}
