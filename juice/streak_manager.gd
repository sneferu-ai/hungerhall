class_name StreakManager
extends Node
## G10 — StreakManager (G9 JuiceDirector partition, AC-Streak). Tracks
## kill-streak tiers from cue.enemy.death internally (G9 OBL-33: the cue
## payload carries NO streak data — this manager owns it). Presentation-only:
## tiers escalate a hero scale bonus inside juice.streak.window_ms, capped at
## juice.streak.max_tiers. Deterministic fixed-tick window, never wall-clock.

var tier: int = 0
var kills: int = 0
var ticks_left: int = 0

var _window_ticks: int = 90      # 1500ms default at 60Hz
var _max_tiers: int = 3

func setup(tun: TunablesLoader) -> void:
	if tun == null:
		return
	_window_ticks = maxi(1, int(round(tun.get_value("juice.streak.window_ms", 1500.0) * 60.0 / 1000.0)))
	_max_tiers = tun.get_int("juice.streak.max_tiers", 3)

func register_kill() -> void:
	kills += 1
	tier = mini(kills, _max_tiers)
	ticks_left = _window_ticks

func tick() -> void:
	if ticks_left <= 0:
		return
	ticks_left -= 1
	if ticks_left <= 0:
		# why: window lapsed — streak resets (presentation state only)
		tier = 0
		kills = 0
