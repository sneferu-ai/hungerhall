extends RefCounted
## test_combat — class distinctness tuples + structure damage rule + potion damage.

func test_class_tuples_distinct() -> Dictionary:
	var t: TunablesLoader = TunablesLoader.new()
	t.load_from_path("res://Tunables.json")
	var classes: Array = []
	for ct in [StateEnums.ClassType.WARRIOR, StateEnums.ClassType.VALKYRIE, StateEnums.ClassType.WIZARD, StateEnums.ClassType.ELF]:
		var cd: ClassDef = ClassDef.new()
		cd.class_type = ct
		match ct:
			StateEnums.ClassType.WARRIOR:
				cd.hp = int(t.get_value("warrior_hp", 800))
				cd.speed = int(t.get_value("warrior_speed", 128))
				cd.shot_dmg = int(t.get_value("warrior_shot_dmg", 50))
				cd.shot_range_tiles = int(t.get_value("warrior_shot_range_tiles", 5))
				cd.shot_rate_per_sec = t.get_value("warrior_shot_rate", 1.2)
				cd.potion_type = StateEnums.PotionType.WHIRLWIND
			StateEnums.ClassType.VALKYRIE:
				cd.hp = int(t.get_value("valkyrie_hp", 680))
				cd.speed = int(t.get_value("valkyrie_speed", 152))
				cd.shot_dmg = int(t.get_value("valkyrie_shot_dmg", 30))
				cd.shot_range_tiles = int(t.get_value("valkyrie_shot_range_tiles", 7))
				cd.shot_rate_per_sec = t.get_value("valkyrie_shot_rate", 1.6)
				cd.potion_type = StateEnums.PotionType.AEGIS
			StateEnums.ClassType.WIZARD:
				cd.hp = int(t.get_value("wizard_hp", 520))
				cd.speed = int(t.get_value("wizard_speed", 144))
				cd.shot_dmg = int(t.get_value("wizard_shot_dmg", 20))
				cd.shot_range_tiles = int(t.get_value("wizard_shot_range_tiles", 6))
				cd.shot_rate_per_sec = t.get_value("wizard_shot_rate", 1.2)
				cd.potion_type = StateEnums.PotionType.NOVA
			StateEnums.ClassType.ELF:
				cd.hp = int(t.get_value("elf_hp", 560))
				cd.speed = int(t.get_value("elf_speed", 192))
				cd.shot_dmg = int(t.get_value("elf_shot_dmg", 15))
				cd.shot_range_tiles = int(t.get_value("elf_shot_range_tiles", 10))
				cd.shot_rate_per_sec = t.get_value("elf_shot_rate", 3.0)
				cd.potion_type = StateEnums.PotionType.VOLLEY
		classes.append(cd)
	if not RulesCombat.all_tuples_distinct(classes):
		return {"ok": false, "msg": "class combat tuples are not all distinct"}
	return {"ok": true}

func test_wizard_structure_excludes_splash() -> Dictionary:
	# why: Wizard does 20 direct damage to generators, NOT 20+12 splash
	var dmg: int = RulesCombat.damage_to_generator(20, StateEnums.ClassType.WIZARD, 12)
	if dmg != 20:
		return {"ok": false, "msg": "Wizard gen damage = %d, expected 20 (direct only)" % dmg}
	return {"ok": true}

func test_warrior_structure_full_damage() -> Dictionary:
	var dmg: int = RulesCombat.damage_to_generator(50, StateEnums.ClassType.WARRIOR, 0)
	if dmg != 50:
		return {"ok": false, "msg": "Warrior gen damage = %d, expected 50" % dmg}
	return {"ok": true}

func test_valkyrie_advancing_detection() -> Dictionary:
	# why: moving directly toward threat = advancing
	var move: Vector2 = Vector2(1, 0)
	var threat: Vector2 = Vector2(1, 0)
	if not RulesCombat.is_valkyrie_advancing(move, threat, 30.0):
		return {"ok": false, "msg": "direct approach not detected as advancing"}
	# why: moving away = not advancing
	var move2: Vector2 = Vector2(-1, 0)
	if RulesCombat.is_valkyrie_advancing(move2, threat, 30.0):
		return {"ok": false, "msg": "retreat detected as advancing"}
	return {"ok": true}

func test_potion_nova_gen_half_damage() -> Dictionary:
	var t: TunablesLoader = TunablesLoader.new()
	t.load_from_path("res://Tunables.json")
	var enemy_dmg: int = RulesCombat.potion_damage_to_enemies(StateEnums.PotionType.NOVA, t)
	var gen_dmg: int = RulesCombat.potion_damage_to_generators(StateEnums.PotionType.NOVA, t)
	if gen_dmg >= enemy_dmg:
		return {"ok": false, "msg": "Nova gen dmg %d should be less than enemy dmg %d" % [gen_dmg, enemy_dmg]}
	return {"ok": true}
