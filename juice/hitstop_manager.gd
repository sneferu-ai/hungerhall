class_name HitstopManager
extends Node
## G10 — HitstopManager (G9 JuiceDirector partition). Owns the physics-tick
## freeze counter. Hitstop freezes WORLD-juice for N fixed ticks; UI juice
## keeps advancing (OBL-31 — enforced by JuiceTweenEngine.step's split).
## Pause supersedes hitstop: JuiceDirector never starts one while paused,
## and a freeze in flight stays dormant under pause because the whole tree's
## world process is gated.

var active: bool = false
var ticks_left: int = 0

func request(frames: int) -> void:
	if frames <= 0:
		return
	# why: overlapping hitstops extend to the longer remaining freeze — a
	# truncating overwrite would let a 2f tick eat a 4f SIG-2 freeze
	ticks_left = maxi(ticks_left, frames)
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
