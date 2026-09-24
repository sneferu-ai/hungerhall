class_name TweenManager
extends Node
## G10 — TweenManager (G9 JuiceDirector partition). Owns the tween lifecycle
## step: advances the JuiceTweenEngine exactly once per fixed 60Hz tick. The
## engine instance is owned by the JuiceDirector (bindings register against it
## before the partition mounts); TweenManager is the step chokepoint so the
## director's step() advances every sub-manager through typed calls — never
## Object.call() against bare Nodes.

var engine: JuiceTweenEngine = null

func attach(e: JuiceTweenEngine) -> void:
	engine = e

## Advances the engine one fixed tick. hitstop_active freezes world-juice
## tweens while UI-juice tweens keep advancing (G9 OBL-31 — the split lives
## inside JuiceTweenEngine.step).
func tick(hitstop_active: bool) -> void:
	if engine != null:
		engine.step(hitstop_active)
