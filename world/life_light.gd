extends CanvasModulate
class_name LifeLight
## HUNGERHALL — the hall dims as the guest fades (G6 §2 world/life_light.gd:
## CanvasModulate grades ×1.0 / ×0.80 / ×0.62). Thresholds at half and quarter
## HP — the same boundaries the G3 low-HP barks use — so the light, the
## numeral, and the voice agree.

const GRADE_FULL: float = 1.0
const GRADE_DIM: float = 0.80
const GRADE_LOW: float = 0.62

var _grade: float = GRADE_FULL

func set_hp_fraction(frac: float) -> void:
	var target: float = GRADE_FULL
	if frac <= 0.25:
		target = GRADE_LOW
	elif frac <= 0.5:
		target = GRADE_DIM
	if target == _grade:
		return
	# why: step the grade over 12 ticks instead of snapping — a light that
	# dims in one frame reads as a glitch, not as dying
	_grade = move_toward(_grade, target, (GRADE_FULL - GRADE_LOW) / 12.0)
	color = Color(_grade, _grade, _grade, 1.0)
