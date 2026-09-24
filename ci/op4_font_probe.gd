extends SceneTree
## HUNGERHALL — OP-4 acceptance item 12 font probe (G6 §2 Fonts).
## Verifies all five G4-sized font resources load as FontFile via ResourceLoader.
## Invoke: godot --headless --script ci/op4_font_probe.gd
## exit 0 = all five load as FontFile; exit 1 = at least one failed.

const PATHS: Array = [
	"res://Fonts/font_8.tres",
	"res://Fonts/font_16.tres",
	"res://Fonts/font_24.tres",
	"res://Fonts/font_32.tres",
	"res://Fonts/announcer_font.tres",
]

func _init() -> void:
	var all_ok: bool = true
	for p in PATHS:
		var f = load(p)
		if f == null:
			print("FAIL: " + p + " did not load")
			all_ok = false
			continue
		var cls: String = f.get_class()
		if cls != "FontFile":
			print("FAIL: " + p + " is " + cls + ", not FontFile")
			all_ok = false
			continue
		print("OK: " + p + " -> " + cls)
	quit(0 if all_ok else 1)
