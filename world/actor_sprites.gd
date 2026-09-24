extends Node2D
class_name ActorSprites
## HUNGERHALL — hero/enemy/generator/projectile frame drivers (G6 §2 world/).
## Pooled Sprite2D actors positioned from the Play snapshot each fixed step.
## Identity by entity id; sprites are reused across frames and freed only when
## their id leaves the snapshot. No rules math — projection only.

const HERO_TEX: Dictionary = {
	0: "res://Assets/warrior-main.png", 1: "res://Assets/valkyrie-main.png",
	2: "res://Assets/wizard-main.png", 3: "res://Assets/elf-main.png",
}
## G4 enemy roster maps to the kitchen-brigade sprite set
const ENEMY_TEX: Dictionary = {
	0: "res://Assets/enemy-scullion.png",   # ghost
	1: "res://Assets/enemy-porter.png",     # grunt
	2: "res://Assets/enemy-broiler.png",    # demon
	3: "res://Assets/enemy-carver.png",     # lobber
	4: "res://Assets/enemy-maitre-d.png",   # sorcerer
	5: "res://Assets/enemy-cleaver-brute.png",  # death
}
const GEN_TEX: String = "res://Assets/generator-cloche.png"
const PROJ_TEX: Dictionary = {
	"axe": "res://Assets/projectile-axe.png", "spear": "res://Assets/projectile-spear.png",
	"bolt": "res://Assets/projectile-bolt.png", "arrow": "res://Assets/projectile-arrow.png",
	"enemy": "res://Assets/projectile-enemy.png",
}

var _hero: Sprite2D = null
var _enemies: Dictionary = {}     # id → Sprite2D
var _generators: Dictionary = {}  # id → Sprite2D
var _projectiles: Dictionary = {} # id → Sprite2D
var _tex_cache: Dictionary = {}
# ---- G9 juice projection multipliers (WorldView owns the decay) ----
var _juice_hero_scale: float = 1.0
var _juice_hero_modulate: Color = Color.WHITE
var _juice_hero_alpha: float = 1.0

func hero_sprite() -> Sprite2D:
	return _hero

## G9 juice seam — multiplicative scale over the arm-pose base scale.
func set_hero_juice_scale(v: float) -> void:
	_juice_hero_scale = clampf(v, 0.0, 4.0)

## G9 juice seam — hero hurt flash / death tint (rest = Color.WHITE).
func set_hero_juice_modulate(c: Color) -> void:
	_juice_hero_modulate = c

## G9 juice seam — hero death collapse alpha (AC-58, rest = 1.0).
func set_hero_juice_alpha(v: float) -> void:
	_juice_hero_alpha = clampf(v, 0.0, 1.0)

## G9 juice seam — locate a pooled actor sprite by entity id (enemies,
## generators, projectiles) so world juice can flash/tint one actor.
func actor_sprite(eid: int) -> Sprite2D:
	var s: Sprite2D = _enemies.get(eid, null)
	if s != null:
		return s
	s = _generators.get(eid, null)
	if s != null:
		return s
	return _projectiles.get(eid, null)

## G9 juice seam — the victim's texture path for the death-ghost composite.
func texture_path_for(eid: int) -> String:
	var s: Sprite2D = actor_sprite(eid)
	if s == null or s.texture == null:
		return ""
	return str(s.texture.resource_path)

func _ready() -> void:
	_hero = Sprite2D.new()
	_hero.name = "Hero"
	_hero.centered = true
	add_child(_hero)

func _tex(path: String) -> Texture2D:
	if _tex_cache.has(path):
		return _tex_cache[path]
	var t: Texture2D = null
	if ResourceLoader.exists(path):
		t = load(path)
	_tex_cache[path] = t
	return t

func update(snapshot: Dictionary) -> void:
	var player: Dictionary = snapshot.get("player", {})
	_hero.position = Vector2(float(player.get("pos_x", 0.0)), float(player.get("pos_y", 0.0)))
	_hero.texture = _tex(str(HERO_TEX.get(int(player.get("class_type", 0)), HERO_TEX[0])))
	# why: 3-frame arm pose reads as a throw without a full animation rig; the
	# G9 juice scale (AC-29 spawn / AC-31 swing / streak bonus) multiplies it
	_hero.scale = Vector2.ONE * (1.06 if int(player.get("throw_cooldown_ticks", 0)) > 9 else 1.0) * _juice_hero_scale
	_hero.modulate = Color(_juice_hero_modulate.r, _juice_hero_modulate.g, _juice_hero_modulate.b, _juice_hero_alpha)
	_sync_pool(_enemies, snapshot.get("enemies", []), _enemy_tex_for)
	_sync_pool(_generators, snapshot.get("generators", []), _gen_tex_for)
	_sync_pool(_projectiles, snapshot.get("projectiles", []), _proj_tex_for)

func _enemy_tex_for(e: Dictionary) -> String:
	return str(ENEMY_TEX.get(int(e.get("ai_type", 1)), ENEMY_TEX[1]))

func _gen_tex_for(_g: Dictionary) -> String:
	return GEN_TEX

func _proj_tex_for(pr: Dictionary) -> String:
	# why: faction 0 = player projectile (class kind); anything else is enemy shot
	if int(pr.get("faction", 0)) != 0:
		return PROJ_TEX["enemy"]
	return str(PROJ_TEX.get(str(pr.get("kind", "axe")), PROJ_TEX["axe"]))

func _sync_pool(pool: Dictionary, entries: Array, tex_for: Callable) -> void:
	var seen: Dictionary = {}
	for e in entries:
		if not (e is Dictionary):
			continue
		var eid: int = int(e.get("id", -1))
		seen[eid] = true
		var sprite: Sprite2D = pool.get(eid, null)
		if sprite == null:
			sprite = Sprite2D.new()
			sprite.name = "Actor%d" % eid
			sprite.centered = true
			add_child(sprite)
			pool[eid] = sprite
		sprite.position = Vector2(float(e.get("pos_x", 0.0)), float(e.get("pos_y", 0.0)))
		var t: Texture2D = _tex(tex_for.call(e))
		if sprite.texture != t:
			sprite.texture = t
	for eid in pool.keys():
		if not seen.has(eid):
			pool[eid].queue_free()
			pool.erase(eid)
