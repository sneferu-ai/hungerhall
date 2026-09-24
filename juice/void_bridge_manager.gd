class_name VoidBridgeManager
extends Node
## G10 — VoidBridgeManager (G9 JuiceDirector partition). Owns the void-bridge
## warning PULSE STATE (AC-52): how many pulses are in flight, where the last
## one fired, and when the warning window lapses. The tween choreography
## (0 → 0.25 → 0, ×3 cycles, cubic-in-out) rides the JuiceTweenEngine like
## every other contract row — this manager is the deterministic state the
## director and tests query. Fixed-tick window, never wall-clock.

var active: bool = false
var ticks_left: int = 0
var pulses_triggered: int = 0
var last_pos: Vector2 = Vector2.ZERO

## Fire a warning pulse. duration_ticks = the full AC-52 chain length
## ((on + off) × cycles) computed by the director from Tunables.
func trigger(pos: Vector2, duration_ticks: int) -> void:
	pulses_triggered += 1
	last_pos = pos
	# why: overlapping pulses extend to the longer remaining window — a
	# truncating overwrite would let a short pulse eat a live warning
	ticks_left = maxi(ticks_left, maxi(1, duration_ticks))
	active = true

func tick() -> void:
	if not active:
		return
	ticks_left -= 1
	if ticks_left <= 0:
		ticks_left = 0
		active = false

func cancel() -> void:
	ticks_left = 0
	active = false
