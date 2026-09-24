extends Control
## HUNGERHALL — HallOfHeroesScreen (G5 §1: Standard tab only; Back → caller).
## The Guestbook's local top-10 rows per class, fed from the score store by
## the SSM's codec (the screen never opens files itself).

func _ready() -> void:
	var header: Label = Label.new()
	header.name = "HallHeader"
	header.text = StringsTable.text("hall.header", "Hall of Heroes")
	header.position = Vector2(220, 16)
	header.size = Vector2(200, 28)
	header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	header.add_theme_font_size_override("font_size", 24)
	add_child(header)
	var sub: Label = Label.new()
	sub.name = "StandardTab"
	sub.text = StringsTable.text("title.guestbook_header", "The Guestbook")
	sub.position = Vector2(220, 46)
	sub.size = Vector2(200, 20)
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.add_theme_font_size_override("font_size", 16)
	sub.add_theme_color_override("font_color", Color("#F2A23B"))
	add_child(sub)
	var table: GuestbookTable = GuestbookTable.new()
	table.name = "Guestbook"
	table.position = Vector2(80, 72)
	table.size = Vector2(520, 260)
	add_child(table)
	var ssm: Node = get_node_or_null("/root/SessionStateMachine")
	var scores: Dictionary = ssm.score_store.read_scores() if ssm != null else {}
	table.populate(scores)

## G6 §1 row 7: primary action here is "back".
func primary_confirm() -> void:
	back_pressed()

func back_pressed() -> void:
	var ssm: Node = get_node_or_null("/root/SessionStateMachine")
	if ssm != null:
		ssm.leave_hall()
