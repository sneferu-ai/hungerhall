class_name FloorData
extends Resource
## Baked, solver-passed, read-only floor structure (G6 §2, §7).
## NO gameplay constants live here — only structural data. Band parameters
## (drain, cadence, generator HP) are copied in at bake time from Tunables.json
## so runtime never recomputes them.

@export var floor_number: int = 1
@export var zone: int = 0  # 0 Drowned Vaults, 1 Cindercrypt, 2 Starved Deep, 3 Hollow Throne
## 14 rows × 20 chars. '#'=wall '.'=floor 'D'=door 'X'=exit 'V'=void tile.
@export var tiles: PackedStringArray = PackedStringArray()
@export var spawn: Vector2i = Vector2i(2, 2)
@export var exit_pos: Vector2i = Vector2i(17, 2)
@export var doors: PackedVector2Array = PackedVector2Array()
@export var foods: PackedVector2Array = PackedVector2Array()
@export var keys: PackedVector2Array = PackedVector2Array()
@export var potions: PackedVector2Array = PackedVector2Array()
## Each: {"x": int, "y": int, "value": int} — baked chest_base_value, deterministic.
@export var chests: Array = []
## Each: {"x": int, "y": int, "enemy_type": int} — baked generator placements.
@export var generators: Array = []
## Each: {"x": int, "y": int, "type": int} — baked initial enemy placements.
@export var initial_enemies: Array = []
## Each: {"type": int, "tiles": [[x,y],...], "phase": int} — baked hazard layout.
@export var hazards: Array = []
## Baked at bake time from Tunables drain_band_N (HP/s for this floor's band).
@export var drain_hp_per_sec: float = 2.0
## Baked at bake time from Tunables target_seconds_band_N (solver budget).
@export var target_seconds: int = 135
## Baked sum of chest values — determinism witness for test_score.
@export var chest_total: int = 0
## Baked generator HP / spawn cadence (ticks) for this floor's band.
@export var generator_hp: int = 60
@export var generator_cadence_ticks: int = 180
