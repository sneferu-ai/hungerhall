extends Control
## HUNGERHALL — ClassSelectScreen (G6 §3.1: four class cards; Warrior
## pre-highlighted; DESCEND is the default focused button; LockedIn begins a
## new campaign in memory only — no save write here, G5 Persistence
## Declaration). All copy is G3 strings.json keys — class.card.* verbatim.

const C_BONE: Color = Color("#F3EAD9")
const C_AMBER: Color = Color("#F2A23B")
const C_SLATE: Color = Color("#16111F")
const C_CANVAS: Color = Color("#0B0A13")
const CLASS_COLORS: Dictionary = {
	0: Color("#C87040"), 1: Color("#5090B0"), 2: Color("#9060B0"), 3: Color("#50B070"),
}

var highlighted: int = 0
var _cards: Array = []
var _descend: Button = null
var _back_hint: Label = null
# ---- G9 juice seams (AC-08 pop-in, AC-10 confirm) ----
var _juice: Node = null

func _ready() -> void:
	var header: Label = Label.new()
	header.name = "Header"
	header.text = StringsTable.text("class.header", "Tonight's Menu")
	header.position = Vector2(220, 24)
	header.size = Vector2(200, 32)
	header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	header.add_theme_font_size_override("font_size", 24)
	add_child(header)
	var ssm: Node = get_node_or_null("/root/SessionStateMachine")
	for i in range(4):
		var card: Button = _build_card(i, ssm)
		_cards.append(card)
		add_child(card)
	_bind_juice()
	_descend = Button.new()
	_descend.name = "DescendButton"
	_descend.text = StringsTable.text("button.descend", "Descend")
	_descend.position = Vector2(256, 312)
	_descend.size = Vector2(128, 34)
	_descend.focus_mode = Control.FOCUS_ALL
	_descend.pressed.connect(_lock_in)
	add_child(_descend)
	_back_hint = Label.new()
	_back_hint.name = "BackHint"
	_back_hint.text = ""
	_back_hint.position = Vector2(8, 336)
	_back_hint.size = Vector2(300, 18)
	_back_hint.add_theme_font_size_override("font_size", 12)
	_back_hint.add_theme_color_override("font_color", Color("#5A4E76"))
	add_child(_back_hint)
	_refresh_highlights()
	_descend.grab_focus()

func _build_card(i: int, ssm: Node) -> Button:
	var card: Button = Button.new()
	card.name = "ClassCard%d" % i
	card.custom_minimum_size = Vector2(300, 110)
	card.position = Vector2(16 + (i % 2) * 316, 64 + (i / 2) * 122)
	card.size = Vector2(296, 114)
	card.alignment = HORIZONTAL_ALIGNMENT_LEFT
	var card_key: String = ["class.card.warrior", "class.card.valkyrie", "class.card.wizard", "class.card.elf"][i]
	var kit: String = ""
	if ssm != null and ssm.has_method("get_class_def"):
		var cd: ClassDef = ssm.get_class_def(i)
		kit = "%s %d  ·  %s %d  ·  %s %d  ·  %s %d" % [
			StringsTable.text("label.hp", "HP"), cd.hp,
			StringsTable.text("label.speed", "Speed"), cd.speed,
			StringsTable.text("label.shot", "Shot"), cd.shot_dmg,
			StringsTable.text("label.potion", "Potion"), cd.potion_type,
		]
	card.text = StringsTable.text(card_key, "") + "\n" + kit
	card.pressed.connect(func() -> void:
		highlighted = i
		_refresh_highlights()
	)
	return card

func _refresh_highlights() -> void:
	for i in range(_cards.size()):
		var card: Button = _cards[i]
		if i == highlighted:
			card.add_theme_color_override("font_color", CLASS_COLORS.get(i, C_AMBER))
		else:
			card.remove_theme_color_override("font_color")

## G9 juice wiring — AC-08 (×4 pop-in, 60ms stagger) + AC-10 (confirm).
## Cards are preset to the contracted FROM values (0.94 scale, 0 alpha) so the
## staggered tweens reveal them one by one; without a director (headless) the
## cards simply render at rest — no juice, no breakage.
func _bind_juice() -> void:
	_juice = get_node_or_null("/root/Main/JuiceDirector")
	if _juice == null or not _juice.has_method("bind"):
		return
	for i in range(_cards.size()):
		var card: Button = _cards[i]
		card.scale = Vector2(0.94, 0.94)
		card.modulate.a = 0.0
		var idx: int = i
		# why: pivot must follow the POST-layout size — at _ready time the Button
		# is still (0,0), so a pivot set here would scale around the corner
		# (reviewer note round 4). Recomputed on each scale application.
		_juice.bind("class_card.scale." + str(idx), func(v):
			card.pivot_offset = card.size / 2.0
			card.scale = Vector2(float(v), float(v)))
		_juice.bind("class_card.alpha." + str(idx), func(v): card.modulate.a = float(v))
	_juice.bind("class_confirm.scale", func(v):
		if highlighted >= 0 and highlighted < _cards.size():
			_cards[highlighted].pivot_offset = _cards[highlighted].size / 2.0
			_cards[highlighted].scale = Vector2(float(v), float(v)))
	_juice.play_class_popin()

func _exit_tree() -> void:
	# why: director outlives this screen — drop every binding this screen made
	if _juice != null and is_instance_valid(_juice) and _juice.has_method("unbind"):
		for i in range(_cards.size()):
			_juice.unbind("class_card.scale." + str(i))
			_juice.unbind("class_card.alpha." + str(i))
		_juice.unbind("class_confirm.scale")

## InputMapper contextual confirm (G6 §1: ClassSelect → confirm = lock class).
func primary_confirm() -> void:
	_lock_in()

func _lock_in() -> void:
	var ssm: Node = get_node_or_null("/root/SessionStateMachine")
	if ssm == null:
		return
	# why: AC-10 class-confirm punch (1.06→0.94→1.0) + haptic light fire
	# BEFORE the CHOOSE transition tears the screen down — the confirm tween
	# rides the class_confirm.scale binding this screen owns (B2 fix: the
	# contract row + binding existed but no trigger fired).
	if _juice != null and is_instance_valid(_juice):
		if _juice.has_method("play_ac"):
			_juice.play_ac("AC-10")
		if _juice.has_method("haptic"):
			_juice.haptic("light")
	# why: CHOOSE first would mount Play before the session exists
	ssm.start_new_game(highlighted)
	ssm.try_transition(StateEnums.Verb.CHOOSE)

## G5 §1: class_select → title on BackOut, no warn (nothing committed).
func back_pressed() -> void:
	var ssm: Node = get_node_or_null("/root/SessionStateMachine")
	if ssm != null:
		ssm.try_transition(StateEnums.Verb.BACK)

func _gui_input(event: InputEvent) -> void:
	# why: keep keyboard focus inside the card grid while it is held
	if event is InputEventMouseButton and event.pressed:
		pass
