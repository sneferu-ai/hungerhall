class_name ClippedPlaqueStyleBox
extends StyleBoxFlat
## HUNGERHALL — destructive crescent-corner plaque (G4 "the bill" interaction,
## G6 §2 ui/clipped_plaque_stylebox.gd). A slate plaque whose top-right corner
## carries a bite-mark crescent: the hall's one destructive-action seam. The
## crescent is a real cut — a canvas-colored disc over the corner radius — not
## a texture. Tokens: ui_slate fill, wall_cap border, canvas bite.

const C_CANVAS: Color = Color("#0B0A13")     # palette.canvas (bite disc)
const C_FILL: Color = Color("#16111F")       # palette.ui_slate
const C_BORDER: Color = Color("#5A4E76")     # palette.wall_cap
const C_RIM: Color = Color("#F3EAD9", 0.35)  # palette.text_bone (bite rim accent)

## why: bite radius as a fraction of the smaller plaque dimension (0.18 keeps
## the crescent readable at 30px-high buttons without swallowing the label)
var bite_fraction: float = 0.18

func _init() -> void:
	bg_color = C_FILL
	border_width_left = 2
	border_width_top = 2
	border_width_right = 2
	border_width_bottom = 2
	border_color = C_BORDER
	corner_radius_top_left = 2
	corner_radius_top_right = 2
	corner_radius_bottom_right = 2
	corner_radius_bottom_left = 2
	content_margin_left = 12.0
	content_margin_top = 6.0
	content_margin_right = 16.0
	content_margin_bottom = 6.0

## why: StyleBox._draw is a C++ virtual with signature (RID, Rect2). GDScript
## cannot call super._draw() on a C++ virtual, so we draw the plaque (fill +
## border) ourselves via RenderingServer, then the crescent cut on top. The
## 2px corner_radius is sub-pixel at 32px tile / 2× scale, so a plain rect
## fill is visually identical to the rounded StyleBoxFlat base here.
func _draw(to_canvas_item: RID, to_rect: Rect2) -> void:
	var rs := RenderingServer
	# Fill
	rs.canvas_item_add_rect(to_canvas_item, to_rect, bg_color)
	# Border (drawn inside the rect, per StyleBoxFlat convention)
	var bw: float = float(border_width_left)
	var pos := to_rect.position
	var endp := to_rect.end
	rs.canvas_item_add_rect(to_canvas_item, Rect2(pos.x, pos.y, to_rect.size.x, bw), border_color)
	rs.canvas_item_add_rect(to_canvas_item, Rect2(pos.x, endp.y - bw, to_rect.size.x, bw), border_color)
	rs.canvas_item_add_rect(to_canvas_item, Rect2(pos.x, pos.y, bw, to_rect.size.y), border_color)
	rs.canvas_item_add_rect(to_canvas_item, Rect2(endp.x - bw, pos.y, bw, to_rect.size.y), border_color)
	# Crescent cut — canvas-colored disc removes a bite from the top-right corner
	var bite_r: float = minf(to_rect.size.x, to_rect.size.y) * bite_fraction
	if bite_r < 3.0:
		return
	var center: Vector2 = Vector2(to_rect.end.x - bite_r * 0.45, to_rect.position.y + bite_r * 0.45)
	rs.canvas_item_add_circle(to_canvas_item, center, bite_r, C_CANVAS)
	# why: thin bone arc along the bite rim so the crescent reads as a cut
	# edge, not a smudge (G4: hierarchy is value-plus-inlay)
	var rim_start: float = deg_to_rad(100.0)
	var rim_end: float = deg_to_rad(260.0)
	var segments: int = 12
	var pts := PackedVector2Array()
	var cols := PackedColorArray()
	for i in range(segments + 1):
		var a: float = lerpf(rim_start, rim_end, float(i) / float(segments))
		pts.append(center + Vector2(cos(a), sin(a)) * bite_r)
		cols.append(C_RIM)
	rs.canvas_item_add_polyline(to_canvas_item, pts, cols, 1.0)
