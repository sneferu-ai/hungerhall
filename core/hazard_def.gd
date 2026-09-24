class_name HazardDef
extends Resource
## One hazard contract (G2 §1 hazard table).

@export var hazard_type: int = 0  # StateEnums.HazardType
@export var trigger_type: int = 0  # StateEnums.TriggerType
@export var display_name: String = "FLAME JET"
@export var sprite_ref: String = "res://Assets/hazard-flame-jet.png"
@export var damage: int = 10
