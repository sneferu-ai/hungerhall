extends RefCounted
## test_accessibility — reduced-motion step contracts, caption minimum hold +
## contrast colors, G3 string style (ALL CAPS, terminated, ≤6-word barks),
## and settings-value floors. All checks are step-counted or data-read —
## never wall-clock.

const State = StateEnums.State

func _ssm() -> Node:
	var ssm: Node = load("res://app/session_state_machine.gd").new()
	ssm._ready()
	return ssm

func test_reduced_motion_shortens_dying() -> Dictionary:
	var ssm: Node = _ssm()
	ssm.settings["reduced_motion"] = false
	var full: int = ssm.dying_steps_needed()
	ssm.settings["reduced_motion"] = true
	var reduced: int = ssm.dying_steps_needed()
	ssm.free()
	if full != 72:
		return {"ok": false, "msg": "full-motion crumble %d, expected 72 steps (1.2s)" % full}
	if reduced != 12:
		return {"ok": false, "msg": "reduced-motion crumble %d, expected 12 steps" % reduced}
	return {"ok": true}

func test_caption_hold_floors_at_two_seconds() -> Dictionary:
	var band: CaptionBand = CaptionBand.new()
	band._ready()
	band.show_text("TEST", 10)  # why: a 10-step request must floor at 120
	if band._hold_remaining != 120:
		return {"ok": false, "msg": "caption hold %d, must floor at 120 steps (2s G3 minimum)" % band._hold_remaining}
	band.show_text("TEST", 300)
	if band._hold_remaining != 300:
		return {"ok": false, "msg": "longer holds must be honored verbatim"}
	for i in range(300):
		band.tick()
	if band._backing.visible:
		return {"ok": false, "msg": "caption still visible after its hold expired"}
	band.free()
	return {"ok": true}

func test_caption_colors_match_g3() -> Dictionary:
	# why: G3 locks white-on-semi-black captions (#FFFFFF / #000000CC family);
	# the band ships bone-on-#000000CC per the G4 announcer type
	if CaptionBand.BACKING != Color(0, 0, 0, 0.8):
		return {"ok": false, "msg": "caption backing drifted from #000000CC"}
	if CaptionBand.C_BONE != Color("#F3EAD9"):
		return {"ok": false, "msg": "caption text color drifted from text_bone"}
	return {"ok": true}

func test_g3_string_style() -> Dictionary:
	# why: G3 — barks/captions ALL CAPS; multi-word lines terminated; barks
	# max six words. Single-word caption labels name objects (KEY, FOOD) and
	# carry no terminator by design.
	var f: FileAccess = FileAccess.open("res://data/strings.json", FileAccess.READ)
	if f == null:
		return {"ok": false, "msg": "data/strings.json missing"}
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	f.close()
	if not (parsed is Dictionary):
		return {"ok": false, "msg": "strings.json parse failed"}
	var keys: Dictionary = parsed.get("keys", {})
	if keys.is_empty():
		return {"ok": false, "msg": "strings.json has no keys"}
	for key in keys:
		var entry: Dictionary = keys[key]
		var text: String = str(entry.get("text", ""))
		var category: String = str(entry.get("category", ""))
		if category != "bark" and category != "caption":
			continue
		if text != text.to_upper():
			return {"ok": false, "msg": "%s: not ALL CAPS: '%s'" % [key, text]}
		var words: PackedStringArray = text.split(" ", false)
		if words.size() > 1 and not (text.ends_with(".") or text.ends_with("?") or text.ends_with("!")):
			return {"ok": false, "msg": "%s: unterminated line '%s'" % [key, text]}
		if category == "bark" and words.size() > 6:
			return {"ok": false, "msg": "%s: bark over six words: '%s'" % [key, text]}
	return {"ok": true}

func test_contrast_contract_floor() -> Dictionary:
	var f: FileAccess = FileAccess.open("res://presentation_contract.json", FileAccess.READ)
	if f == null:
		return {"ok": false, "msg": "presentation_contract.json missing"}
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	f.close()
	var bar: Dictionary = parsed.get("readability_bar", {})
	if float(bar.get("min_contrast", 0.0)) < 4.5:
		return {"ok": false, "msg": "readability bar min_contrast below the 4.5 floor"}
	if float(bar.get("height_fraction", 0.0)) <= 0.0:
		return {"ok": false, "msg": "readability bar has no height"}
	return {"ok": true}

func test_settings_accessibility_values() -> Dictionary:
	var defaults: Dictionary = SaveCodec.default_settings()
	if int(defaults.get("caption_size", 0)) < 24:
		return {"ok": false, "msg": "caption_size default below the 24px floor"}
	if int(defaults.get("sfx_vol", -1)) < 0 or int(defaults.get("sfx_vol", 101)) > 100:
		return {"ok": false, "msg": "sfx_vol default outside 0..100"}
	if not defaults.has("reduced_motion") or not defaults.has("captions"):
		return {"ok": false, "msg": "accessibility toggles missing from the settings schema"}
	return {"ok": true}

func test_ssm_respects_reduced_motion_flag() -> Dictionary:
	var ssm: Node = _ssm()
	ssm.settings = SaveCodec.default_settings()
	if ssm.reduced_motion_enabled():
		return {"ok": false, "msg": "reduced_motion defaults to ON"}
	ssm.settings["reduced_motion"] = true
	if not ssm.reduced_motion_enabled():
		return {"ok": false, "msg": "SSM ignores the reduced_motion setting"}
	ssm.free()
	return {"ok": true}
