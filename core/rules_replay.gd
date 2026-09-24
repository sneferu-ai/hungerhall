class_name RulesReplay
extends RefCounted
## Semantic action codec + SHA-256 via HashingContext (G6 §2 core/).
## Records all input events and frame deltas for a deterministic death-replay.
## Two sessions fed the same seed + the same ordered actions MUST produce an
## identical digest (test_replay pins this).

var frames: Array = []  # Array[{tick, event_type, data}]
var start_tick: int = 0

func start(tick: int) -> void:
	start_tick = tick
	frames.clear()

func record(tick: int, event_type: String, data: Dictionary) -> void:
	frames.append({"tick": tick - start_tick, "event_type": event_type, "data": data})

func length_ticks() -> int:
	if frames.is_empty():
		return 0
	var last: Dictionary = frames.back()
	return int(last.tick)

## why: deterministic SHA-256 over the recorded semantic actions — the replay
## identity receipt (same seed + same ordered actions ⇒ identical digest).
## JSON.stringify with sorted output is stable for the recorded dict shapes
## (tick/event_type/data), and HashingContext streams it without building one
## giant string.
func digest_sha256() -> String:
	var ctx: HashingContext = HashingContext.new()
	ctx.start(HashingContext.HASH_SHA256)
	for fr in frames:
		var line: String = str(int(fr.tick)) + "|" + str(fr.event_type) + "|" + JSON.stringify(fr.data) + "\n"
		ctx.update(line.to_utf8_buffer())
	return ctx.finish().hex_encode()

func to_dict() -> Dictionary:
	return {
		"frame_count": frames.size(),
		"length_ticks": length_ticks(),
		"frames": frames.duplicate(true)
	}
