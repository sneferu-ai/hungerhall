class_name RulesScore
extends RefCounted
## Fixed-ratio reward table, death penalty, totals (G6 §2 core/).
## Pure deterministic score tracking.

var score: int = 0
var kills: int = 0
var floor_entry_score: int = 0
var deaths_this_floor: int = 0

func reset() -> void:
	score = 0
	kills = 0
	floor_entry_score = 0
	deaths_this_floor = 0

func on_floor_entry() -> void:
	floor_entry_score = score
	deaths_this_floor = 0

func add_kill(ai_type: int, tunables: TunablesLoader) -> int:
	var reward: int = kill_reward(ai_type, tunables)
	score += reward
	kills += 1
	return reward

func kill_reward(ai_type: int, tunables: TunablesLoader) -> int:
	match ai_type:
		StateEnums.EnemyAIType.GHOST:
			return tunables.get_int("score_ghost_kill", 10)
		StateEnums.EnemyAIType.GRUNT:
			return tunables.get_int("score_grunt_kill", 25)
		StateEnums.EnemyAIType.DEMON:
			return tunables.get_int("score_demon_kill", 40)
		StateEnums.EnemyAIType.LOBBER:
			return tunables.get_int("score_lobber_kill", 50)
		StateEnums.EnemyAIType.SORCERER:
			return tunables.get_int("score_sorcerer_kill", 60)
		StateEnums.EnemyAIType.DEATH:
			return tunables.get_int("score_death_kill", 200)
	return 0

func on_generator_destroyed(tunables: TunablesLoader) -> int:
	var reward: int = tunables.get_int("score_generator_destroyed", 100)
	score += reward
	return reward

func on_chest_opened(value: int) -> int:
	score += value
	return value

func on_food_eaten() -> void:
	# why: food gives HP not score (G2 §5 reward table)
	pass

func on_floor_clear(tunables: TunablesLoader) -> int:
	var reward: int = tunables.get_int("score_floor_clear", 500)
	score += reward
	return reward

func on_campaign_clear(tunables: TunablesLoader) -> int:
	var reward: int = tunables.get_int("score_campaign_clear", 2000)
	score += reward
	return reward

func on_death(tunables: TunablesLoader) -> int:
	# why: -20% of floor-entry score, flat per death (G2 §2)
	deaths_this_floor += 1
	var penalty: int = int(float(floor_entry_score) * tunables.get_value("death_penalty_fraction", 0.2))
	score -= penalty
	if score < 0:
		score = 0
	return penalty

func to_dict() -> Dictionary:
	return {
		"score": score, "kills": kills, "floor_entry_score": floor_entry_score,
		"deaths_this_floor": deaths_this_floor
	}
