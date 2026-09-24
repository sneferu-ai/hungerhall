extends Node2D
class_name WorldView
## HUNGERHALL — Node2D projection of the Play snapshot (G6 §2 world/).
## Zero rules: renders the snapshot Dictionary only. Owns tile layers, the
## actor sprite pool, camera rig, life-light grade, particles, and floaters.
## render(snapshot) once per fixed step; consume_events(events) drains G6
## §3.3 presentation events into juice.

const TILE: int = 32
const C_CANVAS: Color = Color("#0B0A13")
const C_FLOOR: Color = Color("#252039")
const C_WALL: Color = Color("#191526")
const C_WALL_CAP: Color = Color("#5A4E76")
const C_VOID: Color = Color("#0B0A13")
const C_EXIT: Color = Color("#79D6C9")     # palette.spectral_cyan (exit glow)
const C_AMBER: Color = Color("#F2A23B")
const C_KEY: Color = Color("#D9DEE2")
const C_FOOD: Color = Color("#EFC258")
const C_POTION: Color = Color("#D9DEE2")
const C_DOOR: Color = Color("#191526")

const ZONE_TEXTURES: Dictionary = {
	"drowned": {"floor": "res://Assets/tile-floor-drowned.png", "wall": "res://Assets/tile-wall-drowned.png"},
	"cinder": {"floor": "res://Assets/tile-floor-cinder.png", "wall": "res://Assets/tile-wall-cinder.png"},
	"starved": {"floor": "res://Assets/tile-floor-starved.png", "wall": "res://Assets/tile-wall-starved.png"},
	"throne": {"floor": "res://Assets/tile-floor-throne.png", "wall": "res://Assets/tile-wall-throne.png"},
}

var _actors: ActorSprites = null
var _camera: CameraRig = null
var _life_light: LifeLight = null
var _particles: Particles = null
var _floaters: Floaters = null

var _floor_tex: Texture2D = null
var _wall_tex: Texture2D = null
var _food_tex: Texture2D = null
var _key_tex: Texture2D = null
var _potion_tex: Texture2D = null
var _door_tex: Texture2D = null
var _exit_tex: Texture2D = null

var _view: Dictionary = {}
var _view_floor: int = -1
var _step_counter: int = 0

# ---- G9 juice projection layer (bound by PlayScreen to the JuiceDirector) ----
# why: the G9 scene tree names ZoneTintRect / VoidBridgeOverlay / OverlayRect /
# BannerLabel under WorldView — they live here, world-space, and every one is
# driven through juice_bindings() props or the named projection methods the
# JuiceDirector calls (shake/zoom_punch/drift/juice_burst/juice_floater/
# spawn_ghost/flash_actor/hero_hurt_flash/actor_texture_for/edge_flash/
# apply_zone_tint). Zero rules — the director owns the choreography.
var _zone_tint: ColorRect = null
var _overlay_rect: ColorRect = null   # AC-53 floor-clear darken
var _void_bridge: ColorRect = null    # AC-52 void-bridge warning pulse
var _banner: Label = null             # AC-54/56 floor banner (y + alpha)
var _ghosts: Node2D = null            # death-ghost sprites (AC-36/43 phases 2-3)
var _edge_rect: ColorRect = null      # screen-edge flash — attached by PlayScreen (UI layer)
var _juice_director: Node = null      # asset_debt reporting seam (G9 Asset Delivery)
var _actor_flash: Dictionary = {}     # eid → {left, total} hit-flash decay
var _actor_telegraph: Dictionary = {} # eid → {left, total} ranged-telegraph brighten (AC-37)
var _hero_flash_ticks: int = 0
var _hero_flash_total: int = 0
var _edge_flash_ticks: int = 0
var _edge_flash_total: int = 0
var _edge_flash_peak: float = 0.0
var _particle_tex_cache: Dictionary = {}

func _ready() -> void:
	_food_tex = _try_tex("res://Assets/pickup-food.png")
	_key_tex = _try_tex("res://Assets/pickup-key.png")
	_potion_tex = _try_tex("res://Assets/pickup-potion.png")
	_door_tex = _try_tex("res://Assets/prop-door.png")
	_exit_tex = _try_tex("res://Assets/prop-exit.png")
	_life_light = LifeLight.new()
	_life_light.name = "LifeLight"
	add_child(_life_light)
	_actors = ActorSprites.new()
	_actors.name = "ActorSprites"
	add_child(_actors)
	_particles = Particles.new()
	_particles.name = "Particles"
	add_child(_particles)
	_floaters = Floaters.new()
	_floaters.name = "Floaters"
	add_child(_floaters)
	_camera = CameraRig.new()
	_camera.name = "CameraRig"
	add_child(_camera)
	# ---- G9 world-space overlay rects (after the actors: tint reads over them) ----
	_zone_tint = ColorRect.new()
	_zone_tint.name = "ZoneTintRect"
	_zone_tint.position = Vector2.ZERO
	_zone_tint.size = Vector2(640, 448)
	_zone_tint.color = Color(0, 0, 0, 0)
	_zone_tint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_zone_tint)
	_void_bridge = ColorRect.new()
	_void_bridge.name = "VoidBridgeOverlay"
	_void_bridge.size = Vector2(96, 96)
	_void_bridge.color = Color("#8169AE")
	_void_bridge.color.a = 0.0
	_void_bridge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_void_bridge)
	_overlay_rect = ColorRect.new()
	_overlay_rect.name = "OverlayRect"
	_overlay_rect.position = Vector2.ZERO
	_overlay_rect.size = Vector2(640, 448)
	_overlay_rect.color = Color(0, 0, 0, 0)
	_overlay_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_overlay_rect)
	_ghosts = Node2D.new()
	_ghosts.name = "Ghosts"
	add_child(_ghosts)
	_banner = Label.new()
	_banner.name = "BannerLabel"
	_banner.position = Vector2(0, 60)
	_banner.size = Vector2(640, 40)
	_banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_banner.add_theme_font_size_override("font_size", 24)
	_banner.add_theme_color_override("font_color", Color("#F2A23B"))
	_banner.modulate.a = 0.0
	_banner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_banner)

func _try_tex(path: String) -> Texture2D:
	if not ResourceLoader.exists(path):
		return null
	return load(path)

## Called once per fixed 60Hz step with the Play snapshot.
func render(snapshot: Dictionary) -> void:
	_step_counter += 1
	_view = snapshot.get("floor_view", {})
	var fn: int = int(_view.get("floor_number", 1))
	if fn != _view_floor:
		_view_floor = fn
		_bind_zone_textures(fn)
	var player: Dictionary = snapshot.get("player", {})
	var px: float = float(player.get("pos_x", 0.0))
	var py: float = float(player.get("pos_y", 0.0))
	var facing: Array = player.get("facing", [0.0, 1.0])
	_camera.set_target(Vector2(px, py), Vector2(float(facing[0]) if facing.size() > 0 else 0.0, float(facing[1]) if facing.size() > 1 else 1.0), _step_counter)
	var max_hp: int = maxi(int(player.get("max_hp", 1)), 1)
	_life_light.set_hp_fraction(float(player.get("hp", max_hp)) / float(max_hp))
	_actors.update(snapshot)
	_particles.step()
	_floaters.step()
	_juice_decay()
	queue_redraw()

## G6 §3.3 events → juice. Positions are world pixels.
func consume_events(events: Array) -> void:
	for e in events:
		if not (e is Dictionary):
			continue
		var etype: String = str(e.get("type", ""))
		var pos: Variant = e.get("position", [0.0, 0.0])
		var p: Vector2 = Vector2(float(pos[0]) if pos is Array and pos.size() > 0 else 0.0, float(pos[1]) if pos is Array and pos.size() > 1 else 0.0)
		var amount: int = int(e.get("amount", 0))
		match etype:
			"generator_destroyed":
				_particles.burst(p, C_AMBER, 12)
				_camera.add_trauma(0.6)
				if amount > 0:
					_floaters.spawn(p, "+%d" % amount, C_AMBER)
			"player_hit":
				_particles.burst(p, Color("#D94836"), 6)
				_camera.add_trauma(0.35)
			"food_consumed":
				_particles.burst(p, C_FOOD, 5)
				if amount > 0:
					_floaters.spawn(p, "+%d" % amount, C_FOOD)
			"key_collected":
				_particles.burst(p, C_KEY, 6)
			"potion_used":
				_particles.burst(p, Color("#9060B0"), 10)
				_camera.add_trauma(0.3)
			"door_opened":
				_particles.burst(p, C_KEY, 8)
			"chest_opened":
				_particles.burst(p, C_FOOD, 10)
				if amount > 0:
					_floaters.spawn(p, "+%d" % amount, C_FOOD)
			"projectile_hit":
				_particles.burst(p, Color("#F3EAD9"), 3)
			"death":
				_particles.burst(p, Color("#D94836"), 16)
				_camera.add_trauma(1.0)
			"throw":
				_particles.burst(p, Color("#F3EAD9", 0.7), 2)
			_:
				pass

func _bind_zone_textures(floor_number: int) -> void:
	# why: G2 §3 zones — drowned F1–6, cinder F7–12, starved F13–18, throne F19–24
	var zone: String = "drowned"
	if floor_number >= 19:
		zone = "throne"
	elif floor_number >= 13:
		zone = "starved"
	elif floor_number >= 7:
		zone = "cinder"
	var paths: Dictionary = ZONE_TEXTURES[zone]
	_floor_tex = _try_tex(str(paths.floor))
	_wall_tex = _try_tex(str(paths.wall))

# ============================================================ G9 juice projection
## The JuiceDirector reaches the presentation through EXACTLY this surface:
## juice_bindings() props (engine tweens) + the named methods below. PlayScreen
## wires both at mount (app/screens/play.gd _ready) and clears them at exit.

func set_juice_director(d: Node) -> void:
	_juice_director = d

## Screen-edge flash rect lives in the UI CanvasLayer (PlayScreen owns it).
func attach_screen_edge(rect: ColorRect) -> void:
	_edge_rect = rect

## Engine-prop binding table — PlayScreen forwards these to JuiceDirector.bind().
## Rest values: banner y-offset 0 (position.y 60), tilemap/banner/overlay/void
## alpha as authored. Props absent here are documented per-row blockers in the
## G10 brief (per-entity sprite rows ride the G7 draw-based projection).
func juice_bindings() -> Dictionary:
	return {
		"hero.scale": func(v): _actors.set_hero_juice_scale(float(v)),
		"hero.alpha": func(v): _actors.set_hero_juice_alpha(float(v)),
		"tilemap.alpha": func(v): self_modulate.a = float(v),
		"banner.y": func(v): _banner.position.y = 60.0 + float(v),
		"banner.alpha": func(v): _banner.modulate.a = float(v),
		"overlay.alpha": func(v): _overlay_rect.color.a = float(v),
		"void_bridge.alpha": func(v): _void_bridge.color.a = float(v),
	}

## G9 zone atmosphere (AC-Zone1-4) — persistent ColorRect, normal alpha blend.
func apply_zone_tint(_floor_n: int, color: Color, alpha: float) -> void:
	_zone_tint.color = Color(color.r, color.g, color.b, alpha)

## G9 §4 shake — one of exactly three shake events; mag in px, duration ticks.
func shake(mag_px: float, ticks: int, falloff: String) -> void:
	_camera.shake_kick(mag_px, ticks, falloff)

## G9 camera zoom punch (SIG-2 phase) — 1.0 → peak → 1.0.
func zoom_punch(peak: float, half_ticks: int) -> void:
	_camera.zoom_punch(peak, half_ticks)

## G9 SIG-5 phases 6-7 — camera drifts to the exit, then back to the hero.
func drift_to_exit_and_back(drift_ticks: int, return_ticks: int) -> void:
	var ex: Dictionary = _view.get("exit", {})
	var target: Vector2 = Vector2(int(ex.get("x", 17)) * TILE + TILE / 2, int(ex.get("y", 2)) * TILE + TILE / 2)
	_camera.drift_to_and_back(target, drift_ticks, return_ticks)

## AC-52 — center the warning-pulse rect on the Death-type spawn position.
func place_void_bridge(pos: Vector2) -> void:
	_void_bridge.position = pos - _void_bridge.size / 2.0

## G9 §3 particle projection — the ParticleManager ledger has already gated
## this burst; render exactly the admitted count with the PT row's texture.
func juice_burst(ptype: String, pos: Vector2, tint: Color, count: int, life_s: float, _max_inst: int, _critical: bool, _global_cap: int) -> void:
	var life_ticks: int = maxi(1, int(round(life_s * 60.0)))
	_particles.burst_cfg(pos, tint, count, _particle_tex(ptype), life_ticks)

func _particle_tex(ptype: String) -> Texture2D:
	if _particle_tex_cache.has(ptype):
		return _particle_tex_cache[ptype]
	var path: String = str(JuiceContracts.particle_table().get(ptype, {}).get("texture", ""))
	var tex: Texture2D = null
	if path != "" and ResourceLoader.exists(path):
		tex = load(path)
	_particle_tex_cache[ptype] = tex
	return tex

## G9 floaters (+score/+value numerals) — pooled, step-driven.
func juice_floater(pos: Vector2, text: String, color: Color) -> void:
	_floaters.spawn(pos, text, color)

## G9 death-ghost (AC-36/AC-43 phases 2-3). G9 Asset Delivery fallback: a
## missing texture substitutes an unmistakable 32×32 magenta marker and flags
## asset_debt — the gap is visible, never silent.
func spawn_ghost(pos: Vector2, tex_path: String) -> Node:
	var tex: Texture2D = null
	if tex_path != "" and ResourceLoader.exists(tex_path):
		tex = load(tex_path)
	if tex != null:
		var s: Sprite2D = Sprite2D.new()
		s.centered = true
		s.texture = tex
		s.position = pos
		_ghosts.add_child(s)
		return s
	_record_asset_debt(tex_path)
	var rect: ColorRect = ColorRect.new()
	rect.color = Color("#FF00FF")  # G9: unmistakable magenta error color
	rect.size = Vector2(32, 32)
	rect.position = pos - Vector2(16, 16)
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ghosts.add_child(rect)
	return rect

func _record_asset_debt(path: String) -> void:
	push_warning("WorldView: juice asset failed ResourceLoader load: " + str(path))
	if _juice_director != null and _juice_director.has_method("record_asset_debt"):
		_juice_director.record_asset_debt(path)

## G9 projectile-impact hit flash (AC-41) — white blowout, step-counted decay.
func flash_actor(eid: int, ticks: int, enabled: bool) -> void:
	if not enabled or ticks <= 0:
		return
	if _actors.actor_sprite(eid) == null:
		return
	_actor_flash[eid] = {"left": maxi(1, ticks), "total": maxi(1, ticks)}

## G9 AC-37 enemy ranged telegraph — modulate brighten 1.0 → 1.15, cubic-out,
## juice.enemy.telegraph_ms (250ms). Step-counted decay; the sprite restores to
## WHITE exactly once when the contracted window lapses. Fired from the rules'
## fire-moment seam (core/rules_session.gd :: _enemy_fire → enemy_telegraph
## event; the G2-locked rules have no windup state — documented supersession).
func telegraph_actor(eid: int, ticks: int) -> void:
	if ticks <= 0:
		return
	if _actors.actor_sprite(eid) == null:
		return
	_actor_telegraph[eid] = {"left": maxi(1, ticks), "total": maxi(1, ticks)}

## G9 AC-33 phase 1 — hero modulate set red → white over ticks.
func hero_hurt_flash(ticks: int) -> void:
	_hero_flash_total = maxi(1, ticks)
	_hero_flash_ticks = _hero_flash_total

## G9 death-ghost texture hint — the victim's current texture path.
func actor_texture_for(eid: int) -> String:
	return _actors.texture_path_for(eid)

## G9 screen-edge flash fallback lane (player_hit event path) — the primary
## lane is AC-33 phase 3 through the PlayScreen-owned ScreenEdgeRect overlay.
func edge_flash(color: Color, alpha_peak: float, ticks: int) -> void:
	if _edge_rect == null or ticks <= 0:
		return
	_edge_rect.color = Color(color.r, color.g, color.b, alpha_peak)
	_edge_flash_peak = alpha_peak
	_edge_flash_total = maxi(1, ticks)
	_edge_flash_ticks = _edge_flash_total

## Step-counted juice decays — one call per fixed tick from render().
func _juice_decay() -> void:
	for eid in _actor_flash.keys():
		var rec: Dictionary = _actor_flash[eid]
		var s: Sprite2D = _actors.actor_sprite(int(eid))
		if s == null:
			_actor_flash.erase(eid)
			continue
		rec.left = int(rec.left) - 1
		if int(rec.left) <= 0:
			s.modulate = Color.WHITE
			_actor_flash.erase(eid)
		else:
			s.modulate = Color(3.0, 3.0, 3.0)  # white blowout set → normal
	for eid in _actor_telegraph.keys():
		var rec: Dictionary = _actor_telegraph[eid]
		var s: Sprite2D = _actors.actor_sprite(int(eid))
		if s == null:
			_actor_telegraph.erase(eid)
			continue
		if _actor_flash.has(eid):
			continue  # hit-flash blowout owns the sprite this tick
		rec.left = int(rec.left) - 1
		if int(rec.left) <= 0:
			s.modulate = Color.WHITE
			_actor_telegraph.erase(eid)
		else:
			var total: int = maxi(1, int(rec.total))
			var x: float = clampf(1.0 - float(int(rec.left)) / float(total), 0.0, 1.0)
			var b: float = 1.0 + 0.15 * JuiceTweenEngine.ease_value("cubic_out", x)
			s.modulate = Color(b, b, b)
	if _hero_flash_ticks > 0:
		_hero_flash_ticks -= 1
		var x: float = 1.0 - float(_hero_flash_ticks) / float(maxi(1, _hero_flash_total))
		_actors.set_hero_juice_modulate(Color("#D94836").lerp(Color.WHITE, x))
		if _hero_flash_ticks <= 0:
			_actors.set_hero_juice_modulate(Color.WHITE)
	if _edge_flash_ticks > 0 and _edge_rect != null:
		_edge_flash_ticks -= 1
		var x2: float = 1.0 - float(_edge_flash_ticks) / float(maxi(1, _edge_flash_total))
		_edge_rect.color.a = _edge_flash_peak * (1.0 - x2)
		if _edge_flash_ticks <= 0:
			_edge_rect.color.a = 0.0

func _draw() -> void:
	var tiles: Array = _view.get("tiles", [])
	var gw: int = int(_view.get("grid_w", 20))
	var gh: int = int(_view.get("grid_h", 14))
	# why: canvas letterbox behind the grid (world 640×448 > viewport 640×360)
	draw_rect(Rect2(-64, -64, gw * TILE + 128, gh * TILE + 128), C_CANVAS)
	for y in range(mini(gh, tiles.size())):
		var row: String = str(tiles[y])
		for x in range(mini(gw, row.length())):
			var r: Rect2 = Rect2(x * TILE, y * TILE, TILE, TILE)
			var c: String = row[x]
			match c:
				"#":
					if _wall_tex != null:
						draw_texture_rect(_wall_tex, r, false)
					else:
						draw_rect(r, C_WALL)
					draw_rect(Rect2(r.position, Vector2(TILE, 4)), C_WALL_CAP)
				"V":
					draw_rect(r, C_VOID)
				_:
					if _floor_tex != null:
						draw_texture_rect(_floor_tex, r, false)
					else:
						draw_rect(r, C_FLOOR)
	# exit door
	var ex: Dictionary = _view.get("exit", {})
	var exit_r: Rect2 = Rect2(int(ex.get("x", 17)) * TILE, int(ex.get("y", 2)) * TILE, TILE, TILE)
	if _exit_tex != null:
		draw_texture_rect(_exit_tex, exit_r, false)
	else:
		draw_rect(exit_r, C_EXIT)
	if bool(_view.get("door_open", false)):
		# why: open exit pulses — the one global directional cue toward escape
		var pulse: float = 0.5 + 0.5 * sin(_step_counter * 0.15)
		draw_rect(exit_r.grow(-4), Color(C_AMBER.r, C_AMBER.g, C_AMBER.b, 0.25 + 0.35 * pulse))
	# locked door tiles
	for d in _view.get("doors", []):
		if bool(d.get("open", false)):
			continue
		var dr: Rect2 = Rect2(int(d.x) * TILE, int(d.y) * TILE, TILE, TILE)
		if _door_tex != null:
			draw_texture_rect(_door_tex, dr, false)
		else:
			draw_rect(dr.grow(-4), C_DOOR)
			draw_rect(Rect2(dr.position + Vector2(12, 12), Vector2(8, 8)), C_KEY)
	# pickups
	for f in _view.get("foods", []):
		var fr: Rect2 = Rect2(int(f.x) * TILE + 8, int(f.y) * TILE + 8, 16, 16)
		if _food_tex != null:
			draw_texture_rect(_food_tex, fr, false)
		else:
			draw_rect(fr, C_FOOD)
	for k in _view.get("keys", []):
		var kr: Rect2 = Rect2(int(k.x) * TILE + 8, int(k.y) * TILE + 8, 16, 16)
		if _key_tex != null:
			draw_texture_rect(_key_tex, kr, false)
		else:
			draw_rect(kr, C_KEY)
	for pt in _view.get("potions", []):
		var pr: Rect2 = Rect2(int(pt.x) * TILE + 8, int(pt.y) * TILE + 6, 16, 20)
		if _potion_tex != null:
			draw_texture_rect(_potion_tex, Rect2(int(pt.x) * TILE + 8, int(pt.y) * TILE + 8, 16, 16), false)
		else:
			draw_rect(pr, C_POTION)
	for ch in _view.get("chests", []):
		if bool(ch.get("taken", false)):
			continue
		var cr: Rect2 = Rect2(int(ch.x) * TILE + 6, int(ch.y) * TILE + 8, 20, 16)
		draw_rect(cr, C_FOOD)
		draw_rect(Rect2(cr.position, Vector2(20, 4)), C_AMBER)
