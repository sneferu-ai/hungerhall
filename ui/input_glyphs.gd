class_name InputGlyphs
extends RefCounted
## HUNGERHALL — 1-bit glyph composition (G6 §2 ui/input_glyphs.gd, G4 §input
## glyph strategy). Directional arrows and generic button-shape outlines in
## text_bone on ui_slate, 24px tall, statically composed in code — not
## dynamically detected, not letter glyphs, no controller icon sheet.

const C_BONE: Color = Color("#F3EAD9")
const C_SLATE: Color = Color("#16111F")
const GLYPH_SIZE: int = 24

## Builds an arrow glyph texture pointing along dir (one of 8 unit dirs).
static func arrow(dir: Vector2) -> ImageTexture:
	var img: Image = Image.create(GLYPH_SIZE, GLYPH_SIZE, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	var c: Vector2 = Vector2(GLYPH_SIZE / 2, GLYPH_SIZE / 2)
	var d: Vector2 = dir.normalized() if dir != Vector2.ZERO else Vector2(0, -1)
	# why: 1-bit arrow = filled triangle head + 2px shaft, drawn pixel by pixel
	for y in range(GLYPH_SIZE):
		for x in range(GLYPH_SIZE):
			var p: Vector2 = Vector2(x + 0.5, y + 0.5)
			var rel: Vector2 = p - c
			# rotate into arrow-local space (forward = -Y before rotation)
			var along: float = rel.dot(d)
			var across: float = absf(rel.dot(Vector2(-d.y, d.x)))
			var half_width: float = 0.0
			if along > 2.0:
				# head: triangle from +2 to +11 along
				half_width = maxf(0.0, (11.0 - along) * 0.9)
			elif along >= -10.0:
				# shaft
				half_width = 2.0
			if half_width > 0.0 and across <= half_width and along <= 11.0:
				img.set_pixel(x, y, C_BONE)
	return ImageTexture.create_from_image(img)

## Generic face-button outline (circle/square/triangle/cross geometry —
## generic shapes, not trademarked controller symbols).
static func face_button(shape: String) -> ImageTexture:
	var img: Image = Image.create(GLYPH_SIZE, GLYPH_SIZE, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	var c: Vector2 = Vector2(GLYPH_SIZE / 2, GLYPH_SIZE / 2)
	for y in range(GLYPH_SIZE):
		for x in range(GLYPH_SIZE):
			var p: Vector2 = Vector2(x + 0.5, y + 0.5)
			var on_edge: bool = false
			match shape:
				"circle":
					var r: float = p.distance_to(c)
					on_edge = r >= 8.0 and r <= 10.0
				"square":
					var m: float = maxf(absf(p.x - c.x), absf(p.y - c.y))
					on_edge = m >= 8.0 and m <= 10.0
				"cross":
					var rel: Vector2 = p - c
					var diag1: float = absf(rel.x - rel.y)
					var diag2: float = absf(rel.x + rel.y)
					on_edge = (diag1 <= 2.0 or diag2 <= 2.0) and absf(rel.x) <= 8.0 and absf(rel.y) <= 8.0
				"triangle":
					var rel: Vector2 = p - c
					var inside: bool = rel.y >= -8.0 and rel.y <= 7.0 and absf(rel.x) <= (rel.y + 8.0) * 0.62
					var shrunk: bool = rel.y >= -5.0 and rel.y <= 7.0 and absf(rel.x) <= (rel.y + 5.0) * 0.62
					on_edge = inside and not shrunk
			if on_edge:
				img.set_pixel(x, y, C_BONE)
	return ImageTexture.create_from_image(img)

## Keycap outline with no letter (tutorial overlays use word + arrow).
static func keycap() -> ImageTexture:
	var img: Image = Image.create(GLYPH_SIZE, GLYPH_SIZE, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	for y in range(4, 20):
		for x in range(2, 22):
			var edge: bool = x <= 3 or x >= 20 or y <= 5 or y >= 18
			if edge:
				img.set_pixel(x, y, C_BONE)
	return ImageTexture.create_from_image(img)
