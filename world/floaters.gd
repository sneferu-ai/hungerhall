extends Node2D
class_name Floaters
## HUNGERHALL — pooled score/HP numerals (G6 §2 world/floaters.gd, pool limit
## 16). Fixed-ratio honesty (G2 §5): the exact arithmetic rises off the plate.
## Step-driven; never wall-clock.

const POOL_LIMIT: int = 16
const RISE_PER_TICK: float = 0.5
const LIFE_TICKS: int = 60
const C_BONE: Color = Color("#F3EAD9")

var _pool: Array = []
var _active: Array = []  # [{label, ticks_left}]

func spawn(at: Vector2, text: String, color: Color = C_BONE) -> void:
	var l: Label = null
	if not _pool.is_empty():
		l = _pool.pop_back()
	elif _active.size() < POOL_LIMIT:
		l = Label.new()
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		l.custom_minimum_size = Vector2(96, 20)
		l.add_theme_font_size_override("font_size", 16)
		add_child(l)
	else:
		# why: cap reached — recycle the oldest numeral rather than allocate
		var oldest: Dictionary = _active.pop_front()
		l = oldest.label
	l.text = text
	l.add_theme_color_override("font_color", color)
	l.position = at + Vector2(-48, -24)
	l.visible = true
	_active.append({"label": l, "ticks_left": LIFE_TICKS})

## Call once per fixed 60Hz step.
func step() -> void:
	var i: int = _active.size() - 1
	while i >= 0:
		var f: Dictionary = _active[i]
		f.ticks_left -= 1
		var l: Label = f.label
		l.position.y -= RISE_PER_TICK
		l.modulate.a = clampf(float(f.ticks_left) / float(LIFE_TICKS), 0.0, 1.0)
		if f.ticks_left <= 0:
			l.visible = false
			_pool.append(l)
			_active.remove_at(i)
		i -= 1
