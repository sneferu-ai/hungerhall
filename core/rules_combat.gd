class_name RulesCombat
extends RefCounted
## (Static) damage resolution, structure rule, potion effects (G6 §2 core/).
## Pure functions. No instance state.

const ClassType = StateEnums.ClassType
const PotionType = StateEnums.PotionType

## Regular weapon damage to generators: full listed damage.
## Wizard splash does NOT apply to structures — only the direct bolt.
static func damage_to_generator(shot_dmg: int, class_type: int, splash_dmg: int) -> int:
	# why: G2 §1 structure damage rule — Wizard splash excluded from structures
	if class_type == ClassType.WIZARD:
		return shot_dmg  # only the direct bolt (20), not splash (12)
	return shot_dmg

## Potion damage: full to enemies, half to generators.
static func potion_damage_to_enemies(potion_type: int, tunables: TunablesLoader) -> int:
	match potion_type:
		PotionType.WHIRLWIND:
			return tunables.get_int("potion_whirlwind_dmg", 150)
		PotionType.NOVA:
			return tunables.get_int("potion_nova_dmg", 250)
		PotionType.VOLLEY:
			return tunables.get_int("potion_volley_dmg", 15)
		PotionType.AEGIS:
			return 0  # defensive — no damage
	return 0

static func potion_damage_to_generators(potion_type: int, tunables: TunablesLoader) -> int:
	# why: half to generators (hardened structures)
	var full: int = potion_damage_to_enemies(potion_type, tunables)
	if potion_type == PotionType.NOVA:
		return tunables.get_int("potion_nova_gen_dmg", 125)
	return int(float(full) * 0.5)

static func potion_radius_tiles(potion_type: int, tunables: TunablesLoader) -> int:
	match potion_type:
		PotionType.WHIRLWIND:
			return tunables.get_int("potion_whirlwind_radius_tiles", 4)
		PotionType.NOVA:
			return tunables.get_int("potion_nova_radius_tiles", 5)
		PotionType.VOLLEY:
			return tunables.get_int("potion_volley_range_tiles", 10)
		PotionType.AEGIS:
			return 0
	return 0

## Valkyrie advancing check: is velocity within ±30° of direction to nearest threat?
static func is_valkyrie_advancing(move_dir: Vector2, to_threat: Vector2, angle_deg: float) -> bool:
	if move_dir.length() < 0.01:
		return false
	if to_threat.length() < 0.01:
		return false
	var angle: float = rad_to_deg(move_dir.angle_to(to_threat))
	return abs(angle) <= angle_deg

## Class distinctness tuple — must be unique across all four classes.
static func class_tuple(cd: ClassDef) -> Array:
	return [cd.hp, cd.speed, cd.shot_dmg, cd.shot_range_tiles, cd.shot_rate_per_sec, cd.potion_type]

static func all_tuples_distinct(classes: Array) -> bool:
	# why: G6 novelty thesis — no two classes share the same combat signature tuple
	var seen: Dictionary = {}
	for cd in classes:
		var t: Array = class_tuple(cd)
		var key: String = str(t)
		if seen.has(key):
			return false
		seen[key] = true
	return true
