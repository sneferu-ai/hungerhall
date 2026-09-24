class_name CueBus
extends Node
## HUNGERHALL — CueBus (G6 §2 app/, POST-BUILD MUSICIAN HANDOFF).
## The musician handoff seam: stable, named semantic cue events emitted from
## the SAME real controller/rules path used by player actions and terminal
## outcomes. Cues originate in core/rules_session.gd (_push_cue at each real
## semantic site), surface through RulesSession.consume_pending() (G6 §3.3),
## and are forwarded here by the app controller (app/screens/play.gd) after
## each fixed 60Hz step.
##
## Dispatch targets (AudioDirector / Announcer / JuiceDirector) are compact
## replaceable NO-OP hooks until the operator supplies authored audio: any
## node assigned to a slot that implements on_cue(entry: Dictionary) receives
## every cue. No audio is synthesized, downloaded, or played from this seam —
## by design (POST-BUILD MUSICIAN HANDOFF — NON-BLOCKING).
##
## Cue ID → meaning + callsite: res://data/cue_manifest.json

signal cue_emitted(cue_id: StringName, step: int)

## why: journey-contract observation — every cue forwarded since boot (or
## since clear_log()), in emission order. Read-only from outside.
var emitted_log: Array = []

## why: replaceable no-op hook slots, wired by main.gd when the directors exist
var audio_director: Node = null
var announcer: Node = null
var juice_director: Node = null

func emit(cue_id: StringName, step: int = -1) -> void:
	# why: the single cue entry point; keeps emitted_log and dispatch in lockstep
	if cue_id == &"":
		return
	var entry: Dictionary = {"cue_id": cue_id, "step": step}
	emitted_log.append(entry)
	cue_emitted.emit(cue_id, step)
	_dispatch(entry)

func emit_from_pending(pending: Dictionary) -> int:
	# why: forward every cue produced by RulesSession.consume_pending()
	# (G6 §3.3 shape {"cues": [{"cue_id","step"}], "events": [...]}).
	# Events are presentation-layer data and are NOT routed through the bus.
	# Returns the count of cues actually emitted — entries with a missing or
	# empty cue_id are dropped (emit() refuses them) and do NOT increment the
	# count, so the return value is an honest forwarded-cue tally.
	var count: int = 0
	for cue in pending.get("cues", []):
		if not (cue is Dictionary):
			continue
		var cid: String = str(cue.get("cue_id", ""))
		if cid == "":
			continue
		emit(StringName(cid), int(cue.get("step", -1)))
		count += 1
	return count

func clear_log() -> void:
	emitted_log.clear()

func _dispatch(entry: Dictionary) -> void:
	# why: duck-typed no-op hooks — absent directors mean silent no-op, never an error
	if audio_director != null and audio_director.has_method("on_cue"):
		audio_director.on_cue(entry)
	if announcer != null and announcer.has_method("on_cue"):
		announcer.on_cue(entry)
	if juice_director != null and juice_director.has_method("on_cue"):
		juice_director.on_cue(entry)
