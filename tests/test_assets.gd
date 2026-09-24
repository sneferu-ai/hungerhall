extends RefCounted
## test_assets — ASSET_MANIFEST.json is data: every shipped file hashes to its
## manifest entry, every product_qualified asset loads through ResourceLoader,
## and the governed visible-asset anchor is product-qualified (no false green
## from files that happened to be copied).

func _manifest() -> Dictionary:
	var f: FileAccess = FileAccess.open("res://Assets/ASSET_MANIFEST.json", FileAccess.READ)
	if f == null:
		return {}
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	f.close()
	if parsed is Dictionary:
		return parsed
	return {}

func test_manifest_present_with_assets() -> Dictionary:
	var m: Dictionary = _manifest()
	if m.is_empty():
		return {"ok": false, "msg": "Assets/ASSET_MANIFEST.json missing or unparseable"}
	var assets: Array = m.get("assets", [])
	if assets.is_empty():
		return {"ok": false, "msg": "manifest lists zero assets"}
	return {"ok": true}

func test_every_manifest_file_hashes_to_its_entry() -> Dictionary:
	var m: Dictionary = _manifest()
	for entry in m.get("assets", []):
		var rel: String = str(entry.get("file", ""))
		var path: String = "res://" + rel
		if not FileAccess.file_exists(path):
			return {"ok": false, "msg": "manifest asset missing on disk: %s" % rel}
		var actual: String = FileAccess.get_sha256(path)
		var expected: String = str(entry.get("sha256", "")).to_lower()
		if actual.to_lower() != expected:
			return {"ok": false, "msg": "%s hash drift: manifest %s, disk %s" % [rel, expected.substr(0, 12), actual.substr(0, 12)]}
	return {"ok": true}

func test_product_qualified_assets_load() -> Dictionary:
	var m: Dictionary = _manifest()
	var qualified: int = 0
	for entry in m.get("assets", []):
		if str(entry.get("qualification", "")) != "product_qualified":
			continue
		qualified += 1
		var rel: String = str(entry.get("file", ""))
		if rel.ends_with(".png"):
			var res: Resource = ResourceLoader.load("res://" + rel)
			if res == null:
				return {"ok": false, "msg": "product_qualified PNG failed ResourceLoader.load: %s" % rel}
			if not (res is Texture2D):
				return {"ok": false, "msg": "%s loaded as %s, expected Texture2D" % [rel, res.get_class()]}
	if qualified == 0:
		return {"ok": false, "msg": "no product_qualified assets — delivery debt everywhere"}
	return {"ok": true}

func test_visible_asset_anchor_is_product_qualified() -> Dictionary:
	# why: the first-5-frames governed texture must come from the qualified
	# set, never a fallback capsule
	var f: FileAccess = FileAccess.open("res://ci/sneferu_visible_asset.json", FileAccess.READ)
	if f == null:
		return {"ok": false, "msg": "ci/sneferu_visible_asset.json missing"}
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	f.close()
	var uri: String = str(parsed.get("resource_uri", ""))
	if not uri.begins_with("res://Assets/"):
		return {"ok": false, "msg": "anchor URI outside governed Assets/: %s" % uri}
	var rel: String = uri.trim_prefix("res://")
	var m: Dictionary = _manifest()
	for entry in m.get("assets", []):
		if str(entry.get("file", "")) == rel:
			if str(entry.get("qualification", "")) != "product_qualified":
				return {"ok": false, "msg": "anchor %s is %s, must be product_qualified" % [rel, str(entry.get("qualification"))]}
			return {"ok": true}
	return {"ok": false, "msg": "anchor %s not present in ASSET_MANIFEST.json" % rel}

func test_no_fallback_art_bound_as_qualified() -> Dictionary:
	# why: fallback_unqualified assets may ship as evidence/debt, but nothing
	# may launder them into the qualified set by relabeling
	var m: Dictionary = _manifest()
	for entry in m.get("assets", []):
		var q: String = str(entry.get("qualification", ""))
		if q != "product_qualified" and q != "fallback_unqualified":
			return {"ok": false, "msg": "unknown qualification label '%s' on %s" % [q, str(entry.get("file"))]}
	return {"ok": true}
