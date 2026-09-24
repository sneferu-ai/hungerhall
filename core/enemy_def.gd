class_name EnemyDef
extends Resource
## One enemy encounter contract (G2 §1 roster). display_name carries the G4
## kitchen-staff identity; ai_type carries the G2 mechanical contract.

@export var ai_type: int = 0  # StateEnums.EnemyAIType
@export var display_name: String = "SCULLION"
@export var sprite_frames_ref: String = "res://Assets/enemy-scullion.png"
@export var sprite_ref: String = "res://Assets/enemy-scullion.png"
@export var hp: int = 14
@export var speed: int = 100  # px/s
@export var contact_dmg: int = 10  # per 0.5s contact tick
@export var wall_pass: bool = false
@export var projectile_kind: String = ""  # "" = melee only
