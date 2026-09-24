class_name ClassDef
extends Resource
## One hero class kit (G2 §1 class combat signatures). The distinctness tuple
## (hp, speed, shot_dmg, shot_range, shot_rate, potion_type) is mechanically
## unique across all four classes — verified by test_combat.

@export var class_type: int = 0  # StateEnums.ClassType
@export var display_name: String = "WARRIOR"
@export var sprite_frames_ref: String = "res://Assets/warrior-main_sheet.png"
@export var still_ref: String = "res://Assets/warrior-main.png"
@export var potion_type: int = 0  # StateEnums.PotionType
@export var hp: int = 800
@export var speed: int = 128  # px/s
@export var shot_dmg: int = 50
@export var shot_range_tiles: int = 5
@export var shot_rate_per_sec: float = 1.2
@export var projectile_kind: String = "axe"  # axe|spear|bolt|arrow
@export var projectile_ref: String = "res://Assets/projectile-axe.png"

static func build_all(t: TunablesLoader) -> Array:
	# why: the four locked class kits in enum order — one call for SSM/screens
	var out: Array = []
	for ct in range(4):
		out.append(build(ct, t))
	return out

static func build(ct: int, t: TunablesLoader) -> ClassDef:
	# why: single core-owned construction path for the four locked class kits
	# (G2 §1 combat signatures, tunables-driven). Tools (attract baker) and
	# replay playback reconstruct the exact kit without importing ci/ or
	# duplicating kit data — one source of truth for determinism.
	var cd: ClassDef = ClassDef.new()
	cd.class_type = ct
	match ct:
		StateEnums.ClassType.WARRIOR:
			cd.display_name = "WARRIOR"
			cd.sprite_frames_ref = "res://Assets/warrior-main_sheet.png"
			cd.still_ref = "res://Assets/warrior-main.png"
			cd.potion_type = StateEnums.PotionType.WHIRLWIND
			cd.hp = int(t.get_value("warrior_hp", 800))
			cd.speed = int(t.get_value("warrior_speed", 128))
			cd.shot_dmg = int(t.get_value("warrior_shot_dmg", 50))
			cd.shot_range_tiles = int(t.get_value("warrior_shot_range_tiles", 5))
			cd.shot_rate_per_sec = t.get_value("warrior_shot_rate", 1.2)
			cd.projectile_kind = "axe"
			cd.projectile_ref = "res://Assets/projectile-axe.png"
		StateEnums.ClassType.VALKYRIE:
			cd.display_name = "VALKYRIE"
			cd.sprite_frames_ref = "res://Assets/valkyrie-main_sheet.png"
			cd.still_ref = "res://Assets/valkyrie-main.png"
			cd.potion_type = StateEnums.PotionType.AEGIS
			cd.hp = int(t.get_value("valkyrie_hp", 680))
			cd.speed = int(t.get_value("valkyrie_speed", 152))
			cd.shot_dmg = int(t.get_value("valkyrie_shot_dmg", 30))
			cd.shot_range_tiles = int(t.get_value("valkyrie_shot_range_tiles", 7))
			cd.shot_rate_per_sec = t.get_value("valkyrie_shot_rate", 1.6)
			cd.projectile_kind = "spear"
			cd.projectile_ref = "res://Assets/projectile-spear.png"
		StateEnums.ClassType.WIZARD:
			cd.display_name = "WIZARD"
			cd.sprite_frames_ref = "res://Assets/wizard-main_sheet.png"
			cd.still_ref = "res://Assets/wizard-main.png"
			cd.potion_type = StateEnums.PotionType.NOVA
			cd.hp = int(t.get_value("wizard_hp", 520))
			cd.speed = int(t.get_value("wizard_speed", 144))
			cd.shot_dmg = int(t.get_value("wizard_shot_dmg", 20))
			cd.shot_range_tiles = int(t.get_value("wizard_shot_range_tiles", 6))
			cd.shot_rate_per_sec = t.get_value("wizard_shot_rate", 1.2)
			cd.projectile_kind = "bolt"
			cd.projectile_ref = "res://Assets/projectile-bolt.png"
		StateEnums.ClassType.ELF:
			cd.display_name = "ELF"
			cd.sprite_frames_ref = "res://Assets/elf-main_sheet.png"
			cd.still_ref = "res://Assets/elf-main.png"
			cd.potion_type = StateEnums.PotionType.VOLLEY
			cd.hp = int(t.get_value("elf_hp", 560))
			cd.speed = int(t.get_value("elf_speed", 192))
			cd.shot_dmg = int(t.get_value("elf_shot_dmg", 15))
			cd.shot_range_tiles = int(t.get_value("elf_shot_range_tiles", 10))
			cd.shot_rate_per_sec = t.get_value("elf_shot_rate", 3.0)
			cd.projectile_kind = "arrow"
			cd.projectile_ref = "res://Assets/projectile-arrow.png"
	return cd

static func class_name_for(ct: int) -> String:
	match ct:
		StateEnums.ClassType.WARRIOR:
			return "warrior"
		StateEnums.ClassType.VALKYRIE:
			return "valkyrie"
		StateEnums.ClassType.WIZARD:
			return "wizard"
		StateEnums.ClassType.ELF:
			return "elf"
	return "warrior"

static func class_type_for(lower_name: String) -> int:
	match lower_name.to_lower():
		"warrior":
			return StateEnums.ClassType.WARRIOR
		"valkyrie":
			return StateEnums.ClassType.VALKYRIE
		"wizard":
			return StateEnums.ClassType.WIZARD
		"elf":
			return StateEnums.ClassType.ELF
	return StateEnums.ClassType.WARRIOR
