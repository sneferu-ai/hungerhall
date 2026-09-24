extends RefCounted
## test_asset_admission — G9 Asset Delivery + Gate R-4: ResourceLoader proof
## for ALL 42 shipped assets (42 positive + 42 negative), the magenta
## fallback marker contract, and asset_debt telemetry (round-5 blocker
## c08d4ac8eaef: the admission battery existed nowhere).
##
## Positive battery: every manifest row loads non-null through
## ResourceLoader, is a Texture2D, and its dimensions match the manifest
## (G9 "dimensions match manifest").
## Negative battery: each asset path broken (moved under a missing dir) →
## JuiceDirector.load_asset returns null AND flags asset_debt; the game
## continues with a visible 32×32 magenta marker — the gap is visible, never
## silent (G9 programmer-art fallback).

const MANIFEST_PATH: String = "res://Assets/ASSET_MANIFEST.json"
const G9_ASSET_COUNT: int = 42  # G9 §3: exactly 42 shipped assets

func _ok(msg: String = "") -> Dictionary:
	return {"ok": true, "msg": msg}

func _fail(msg: String) -> Dictionary:
	return {"ok": false, "msg": msg}

# why: round-7 zero-leak bar — _director() builds a real JuiceDirector (a
# Node carrying 5 add_child'd sub-managers) for the negative battery, the
# fallback-marker probe, and the idempotency probe; teardown() frees it so
# the runner exits clean (test_runner.gd:79 calls teardown per test).
var _owned: Array = []

func teardown() -> void:
	for n in _owned:
		if is_instance_valid(n) and n is Node:
			n.free()
	_owned.clear()

func _manifest_rows() -> Array:
	var f: FileAccess = FileAccess.open(MANIFEST_PATH, FileAccess.READ)
	if f == null:
		return []
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	f.close()
	if not (parsed is Dictionary):
		return []
	var assets: Variant = parsed.get("assets", [])
	return assets if assets is Array else []

func _director() -> JuiceDirector:
	var tun: TunablesLoader = TunablesLoader.new()
	tun.load_from_path("res://Tunables.json")
	var d: JuiceDirector = JuiceDirector.new()
	d.setup(tun, null)
	_owned.append(d)
	return d

# ============================================================ 42 positives

func test_g9_ships_exactly_42_assets() -> Dictionary:
	var rows: Array = _manifest_rows()
	if rows.size() != G9_ASSET_COUNT:
		return _fail("manifest carries %d rows; G9 §3 pins exactly 42 shipped assets" % rows.size())
	return _ok()

func test_positive_battery_every_asset_admits_with_manifest_dimensions() -> Dictionary:
	var rows: Array = _manifest_rows()
	if rows.size() != G9_ASSET_COUNT:
		return _fail("manifest rows %d != 42" % rows.size())
	var admitted: int = 0
	for row_v in rows:
		if not (row_v is Dictionary):
			return _fail("manifest row is not a Dictionary")
		var row: Dictionary = row_v
		var file: String = str(row.get("file", ""))
		if file == "":
			return _fail("manifest row missing 'file'")
		var path: String = "res://" + file
		if not ResourceLoader.exists(path):
			return _fail("%s does not exist for ResourceLoader (import missing?)" % path)
		var res: Resource = ResourceLoader.load(path)
		if res == null:
			return _fail("%s loaded null" % path)
		if not (res is Texture2D):
			return _fail("%s is %s, G9 pins Texture2D for all 42" % [path, res.get_class()])
		var tex: Texture2D = res
		var w: int = int(row.get("width", 0))
		var h: int = int(row.get("height", 0))
		if w > 0 and h > 0 and (tex.get_width() != w or tex.get_height() != h):
			return _fail("%s dims %dx%d != manifest %dx%d" % [path, tex.get_width(), tex.get_height(), w, h])
		if tex.get_width() <= 0 or tex.get_height() <= 0:
			return _fail("%s has zero/negative dimensions" % path)
		admitted += 1
	if admitted != G9_ASSET_COUNT:
		return _fail("only %d/42 assets admitted" % admitted)
	return _ok()

# ============================================================ 42 negatives

func test_negative_battery_every_broken_path_fires_the_fallback() -> Dictionary:
	var rows: Array = _manifest_rows()
	if rows.size() != G9_ASSET_COUNT:
		return _fail("manifest rows %d != 42" % rows.size())
	var d: JuiceDirector = _director()
	var negatives: int = 0
	for row_v in rows:
		var row: Dictionary = row_v
		var file: String = str(row.get("file", ""))
		var semantic: String = file.get_file().get_basename()
		# break the path: same filename under a directory that does not exist
		var broken: String = "res://Assets/__admission_negative__/" + file.get_file()
		var tex: Texture2D = d.load_asset(broken, semantic)
		if tex != null:
			return _fail("broken path %s must load null" % broken)
		if not d.asset_debt.has(semantic):
			return _fail("broken %s must flag asset_debt '%s' (visible, never silent)" % [file, semantic])
		negatives += 1
	if negatives != G9_ASSET_COUNT:
		return _fail("only %d/42 negatives verified" % negatives)
	if d.asset_debt.size() != G9_ASSET_COUNT:
		return _fail("asset_debt must carry exactly one flag per broken asset (%d)" % d.asset_debt.size())
	return _ok()

func test_fallback_marker_contract() -> Dictionary:
	var d: JuiceDirector = _director()
	var marker: ColorRect = d.make_fallback_marker()
	if marker == null:
		return _fail("make_fallback_marker returned null")
	if marker.size != Vector2(32, 32):
		return _fail("fallback marker must be 32x32 (G9 Asset Delivery)")
	if marker.color != Color("#FF00FF"):
		return _fail("fallback marker must be magenta #FF00FF (unmistakable error color)")
	if marker.mouse_filter != Control.MOUSE_FILTER_IGNORE:
		return _fail("fallback marker must be mouse-transparent")
	marker.free()
	return _ok()

func test_asset_debt_is_idempotent_per_semantic_id() -> Dictionary:
	var d: JuiceDirector = _director()
	d.record_asset_debt("dup_probe")
	d.record_asset_debt("dup_probe")
	var count: int = 0
	for entry in d.asset_debt:
		if str(entry) == "dup_probe":
			count += 1
	if count != 1:
		return _fail("asset_debt must dedupe per semantic id (%d entries)" % count)
	return _ok()
