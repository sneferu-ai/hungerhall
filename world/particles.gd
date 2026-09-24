extends Node2D
class_name Particles
## HUNGERHALL — pooled spark/smoke bursts (G6 §2 world/particles.gd, pool
## limit 128). Step-driven lifetimes (one tick = one fixed 60Hz step) — never
## wall-clock, so pause freezes the sparks mid-air.

const POOL_LIMIT: int = 128
const TEX_PATH: String = "res://Assets/particle-spark.png"

var _pool: Array = []          # free Sprite2Ds
var _active: Array = []        # [{sprite, vel, ticks_left}]
var _tex: Texture2D = null

func _ready() -> void:
	if ResourceLoader.exists(TEX_PATH):
		_tex = load(TEX_PATH)

func burst(at: Vector2, col: Color, count: int) -> void:
	for i in range(count):
		if _active.size() + _pool.size() >= POOL_LIMIT and _pool.is_empty():
			# why: hard cap — recycle the oldest live spark rather than allocate
			var oldest: Dictionary = _active.pop_front()
			oldest.sprite.visible = false
			_pool.append(oldest.sprite)
		var s: Sprite2D = null
		if not _pool.is_empty():
			s = _pool.pop_back()
		else:
			s = Sprite2D.new()
			s.centered = true
			if _tex != null:
				s.texture = _tex
			add_child(s)
		s.position = at
		s.scale = Vector2.ONE * 0.12
		s.modulate = col
		s.visible = true
		# why: deterministic radial spread from the burst index, no global RNG
		var ang: float = TAU * float(i) / float(maxi(count, 1)) + float(_active.size()) * 0.37
		var speed: float = 1.5 + float(i % 3) * 0.8
		_active.append({"sprite": s, "vel": Vector2(cos(ang), sin(ang)) * speed, "ticks_left": 24 + (i % 3) * 6})

## G9 juice seam — contract-shaped burst: explicit texture (PT rows name
## spark/smoke/glow/trail) and lifetime in fixed ticks (G9 life_s × 60).
## Falls back to the spark texture when the named one is missing (never
## blocks juice).
func burst_cfg(at: Vector2, col: Color, count: int, tex: Texture2D, life_ticks: int) -> void:
	for i in range(count):
		if _active.size() + _pool.size() >= POOL_LIMIT and _pool.is_empty():
			var oldest: Dictionary = _active.pop_front()
			oldest.sprite.visible = false
			_pool.append(oldest.sprite)
		var s: Sprite2D = null
		if not _pool.is_empty():
			s = _pool.pop_back()
		else:
			s = Sprite2D.new()
			s.centered = true
			add_child(s)
		if tex != null:
			s.texture = tex
		elif _tex != null:
			s.texture = _tex
		s.position = at
		s.scale = Vector2.ONE * 0.12
		s.modulate = col
		s.visible = true
		var ang: float = TAU * float(i) / float(maxi(count, 1)) + float(_active.size()) * 0.37
		var speed: float = 1.5 + float(i % 3) * 0.8
		_active.append({"sprite": s, "vel": Vector2(cos(ang), sin(ang)) * speed, "ticks_left": maxi(1, life_ticks)})

## Call once per fixed 60Hz step.
func step() -> void:
	var i: int = _active.size() - 1
	while i >= 0:
		var p: Dictionary = _active[i]
		p.ticks_left -= 1
		var s: Sprite2D = p.sprite
		s.position += p.vel
		s.modulate.a = clampf(float(p.ticks_left) / 30.0, 0.0, 1.0)
		if p.ticks_left <= 0:
			s.visible = false
			_pool.append(s)
			_active.remove_at(i)
		i -= 1
