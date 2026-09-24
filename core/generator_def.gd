class_name GeneratorDef
extends Resource
## One zone generator stat block (G2 §1). max_alive_per_generator is the
## per-generator cap of 6 (G2 concurrency model); the per-floor cap of 28
## lives in Tunables.

@export var generator_type: String = "drowned"  # drowned|cinder|starved|throne
@export var display_name: String = "CLOCHE"
@export var sprite_frames_ref: String = "res://Assets/generator-cloche.png"
@export var enemy_type: int = 0  # StateEnums.EnemyAIType spawned
@export var hp: int = 60
@export var spawn_cadence_ticks: int = 180  # 3.0s at 60Hz
@export var max_alive_per_generator: int = 6  # why: G2 §1 per-generator alive cap
