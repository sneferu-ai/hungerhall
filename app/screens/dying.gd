extends Control
## HUNGERHALL — DyingScreen (G5 §1: non-interactive; 72 steps, or 12 under
## reduced motion — the SSM counts and fires PROMPT). Renders the class-falls
## caption and a step-driven crumble of the hero mark. No input path exists.

const C_CANVAS: Color = Color("#0B0A13")
const C_BONE: Color = Color("#F3EAD9")
const C_BRICK: Color = Color("#D94836")
const C_SLATE: Color = Color("#16111F")
const CLASS_COLORS: Dictionary = {
	0: Color("#C87040"), 1: Color("#5090B0"), 2: Color("#9060B0"), 3: Color("#50B070"),
}

var _step: int = 0
var _total_steps: int = 72
var _caption_font: Font = null

func _ready() -> void:
	var ssm: Node = get_node_or_null("/root/SessionStateMachine")
	if ssm != null:
		_total_steps = ssm.dying_steps_needed()
	var f: Variant = load("res://Fonts/font_24.tres")
	if f is Font:
		_caption_font = f

func _physics_process(_delta: float) -> void:
	if _step < _total_steps:
		_step += 1
		queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(0, 0, 640, 360), C_CANVAS)
	draw_rect(Rect2(140, 90, 360, 180), C_SLATE)
	draw_rect(Rect2(140, 90, 360, 180), C_BRICK, false, 2.0)
	var ssm: Node = get_node_or_null("/root/SessionStateMachine")
	var class_idx: int = int(ssm.class_index) if ssm != null else 0
	var class_key: String = "warrior"
	if ssm != null and ssm.has_method("class_key"):
		class_key = ssm.class_key(class_idx)
	# why: G3 death-bark priority — THE [CLASS] FALLS. is the fixed bark
	var line: String = StringsTable.text_for_class("event.death.fixed", class_key, "")
	var col: Color = CLASS_COLORS.get(class_idx, C_BRICK)
	if _caption_font != null:
		draw_string(_caption_font, Vector2(170, 140), line, HORIZONTAL_ALIGNMENT_LEFT, 300, 24, col)
	else:
		draw_string(ThemeDB.fallback_font, Vector2(170, 140), line, HORIZONTAL_ALIGNMENT_LEFT, 300, 24, col)
	# step-driven crumble: the hero mark collapses into shards as the count runs
	var frac: float = clampf(float(_step) / float(_total_steps), 0.0, 1.0)
	var shard_count: int = 8
	for i in range(shard_count):
		var alive_frac: float = clampf(1.0 - frac * float(shard_count) / float(i + 2), 0.0, 1.0)
		if alive_frac <= 0.0:
			continue
		var x: float = 280.0 + float(i % 4) * 20.0 + float(i) * frac * 6.0
		var y: float = 190.0 + float(i / 4) * 20.0 + frac * float(i * 9)
		draw_rect(Rect2(x, y, 14.0 * alive_frac, 14.0 * alive_frac), col)
