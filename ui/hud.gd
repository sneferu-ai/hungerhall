extends Control
class_name Hud
## HUNGERHALL — wordless HUD (G3: numerals and icons only; G6 §2 ui/hud.gd).
## HP numeral (32px), score numeral, floor numeral, potion/key counts with
## icons from ui-hud-icons.png (three 16×16 cells at 48×16). Updated from the
## Play snapshot dictionary each fixed step — never reads rules state directly.

const C_BONE: Color = Color("#F3EAD9")      # palette.text_bone
const C_AMBER: Color = Color("#F2A23B")     # palette.service_amber
const C_BRICK: Color = Color("#D94836")     # palette.critical_brick
const ICON_SHEET: String = "res://Assets/ui-hud-icons.png"

var _hp_label: Label = null
var _hp_status_label: Label = null
var _score_label: Label = null
var _floor_label: Label = null
var _potion_icon: TextureRect = null
var _potion_count: Label = null
var _key_icon: TextureRect = null
var _key_count: Label = null
var _icons: Texture2D = null
## G9 SIG-1 owns the HP numeral color once the JuiceDirector binds (white →
## amber ≤50% → crimson ≤25% → deep red ≤10%, AC-16/17/17b). Until a juice
## binding exists the G7 drain-flash rule (brick at ≤25%) stays the fallback.
var juice_color_owned: bool = false

func _ready() -> void:
	mouse_filter = MOUSE_FILTER_IGNORE
	_icons = load(ICON_SHEET)
	_hp_label = _make_label("HPNumeral", 32, Vector2(8, 2), C_BONE)
	_hp_status_label = _make_label("HPStatusLabel", 12, Vector2(10, 40), C_AMBER)
	_hp_status_label.text = ""
	_score_label = _make_label("ScoreNumeral", 16, Vector2(430, 4), C_BONE)
	_floor_label = _make_label("FloorNumeral", 16, Vector2(560, 4), C_AMBER)
	_potion_icon = _make_icon("PotionIcon", 0, Vector2(180, 6))
	_potion_count = _make_label("PotionCount", 16, Vector2(200, 6), C_BONE)
	_key_icon = _make_icon("KeyIcon", 1, Vector2(240, 6))
	_key_count = _make_label("KeyCount", 16, Vector2(260, 6), C_BONE)

## G9 juice seam — engine-prop appliers for the HUD surface. PlayScreen
## forwards this table to JuiceDirector.bind(); the colorblind non-color
## channel (HPStatusLabel FAIR/LOW/CRITICAL) rides _overlay_nodes["hp_status"]
## on the same director. Scale pivots center so pops read as pulses, not
## top-left growth.
func juice_bindings() -> Dictionary:
	_hp_label.pivot_offset = _hp_label.size / 2.0
	_hp_status_label.pivot_offset = _hp_status_label.size / 2.0
	_score_label.pivot_offset = _score_label.size / 2.0
	_floor_label.pivot_offset = _floor_label.size / 2.0
	_key_icon.pivot_offset = Vector2(8, 8)
	_potion_icon.pivot_offset = Vector2(8, 8)
	return {
		"hp_numeral.scale": func(v): _hp_label.scale = Vector2(float(v), float(v)),
		"hp_numeral.color": func(v): set_hp_color(v),
		"hp_label.alpha": func(v): _hp_status_label.modulate.a = float(v),
		"score.scale": func(v): _score_label.scale = Vector2(float(v), float(v)),
		"floor_counter.scale": func(v): _floor_label.scale = Vector2(float(v), float(v)),
		"key_icon.scale": func(v): _key_icon.scale = Vector2(float(v), float(v)),
		"potion_icon.scale": func(v): _potion_icon.scale = Vector2(float(v), float(v)),
	}

func hp_status_label() -> Label:
	return _hp_status_label

## G9 SIG-1 color path + band-0 reset (juice.hp.color.white) applier.
func set_hp_color(v: Variant) -> void:
	if v is Color:
		_hp_label.add_theme_color_override("font_color", v)

func _make_label(node_name: String, font_size: int, pos: Vector2, color: Color) -> Label:
	var l: Label = Label.new()
	l.name = node_name
	l.position = pos
	l.size = Vector2(220, font_size + 8)
	l.add_theme_font_size_override("font_size", font_size)
	l.add_theme_color_override("font_color", color)
	l.mouse_filter = MOUSE_FILTER_IGNORE
	add_child(l)
	return l

func _make_icon(node_name: String, cell: int, pos: Vector2) -> TextureRect:
	var t: TextureRect = TextureRect.new()
	t.name = node_name
	t.position = pos
	t.custom_minimum_size = Vector2(16, 16)
	t.size = Vector2(16, 16)
	t.mouse_filter = MOUSE_FILTER_IGNORE
	t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	t.stretch_mode = TextureRect.STRETCH_KEEP
	if _icons != null:
		var atlas: AtlasTexture = AtlasTexture.new()
		atlas.atlas = _icons
		# why: ui-hud-icons.png is 48×16 = three 16×16 icon cells
		atlas.region = Rect2(cell * 16, 0, 16, 16)
		t.texture = atlas
	add_child(t)
	return t

## Called once per fixed 60Hz step with the Play snapshot (G6 §3.3 sibling).
func update_from_snapshot(snap: Dictionary) -> void:
	var player: Dictionary = snap.get("player", {})
	var score: Dictionary = snap.get("score", {})
	var hp: int = int(player.get("hp", 0))
	_hp_label.text = str(hp)
	# why: G2 drain flash — the numeral turns brick as the hall takes its cut.
	# G9 SIG-1 (AC-16/17/17b) SUPERSEDES this once the JuiceDirector binds the
	# hp_numeral.color prop — juice_color_owned flips at binding time and the
	# threshold color path (white→amber→crimson→deep red) owns the numeral.
	if not juice_color_owned:
		_hp_label.add_theme_color_override("font_color", C_BRICK if hp <= int(player.get("max_hp", 1)) / 4 else C_BONE)
	_score_label.text = str(int(score.get("score", 0)))
	_floor_label.text = "F" + str(int(snap.get("floor", 1)))
	_potion_count.text = str(int(player.get("potions", 0)))
	_key_count.text = str(int(player.get("keys", 0)))
