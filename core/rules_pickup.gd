class_name RulesPickup
extends RefCounted
## Food, keys, potions, chests, doors, exit (G6 §2 core/).
## Pure deterministic pickup state. No Node.

var foods: Array = []       # Array[Vector2i] — remaining food positions
var keys: Array = []        # Array[Vector2i] — remaining key positions
var potions: Array = []     # Array[Vector2i] — remaining potion positions
var chests: Array = []      # Array[{x,y,value,taken}]
var doors: Array = []       # Array[{pos: Vector2i, open: bool}]
var consumed_foods: Array = []  # positions of eaten food (persists across continue)

func setup_from_floor(floor: RulesFloor) -> void:
	foods = floor.foods.duplicate()
	keys = floor.keys.duplicate()
	potions = floor.potions.duplicate()
	consumed_foods = []
	chests = []
	for c in floor.chests:
		chests.append({"x": c.x, "y": c.y, "value": c.value, "taken": false})
	doors = []
	for d in floor.doors:
		doors.append({"pos": d, "open": false})

func food_count() -> int:
	return foods.size()

func try_eat_food(tx: int, ty: int, food_hp: int) -> int:
	# why: returns HP restored (0 if no food at tile)
	for i in range(foods.size()):
		if foods[i].x == tx and foods[i].y == ty:
			foods.remove_at(i)
			return food_hp
	return 0

func try_collect_key(tx: int, ty: int) -> bool:
	for i in range(keys.size()):
		if keys[i].x == tx and keys[i].y == ty:
			keys.remove_at(i)
			return true
	return false

func try_collect_potion(tx: int, ty: int, cap: int, current_potions: int) -> bool:
	if current_potions >= cap:
		return false
	for i in range(potions.size()):
		if potions[i].x == tx and potions[i].y == ty:
			potions.remove_at(i)
			return true
	return false

func try_open_chest(tx: int, ty: int) -> int:
	# why: returns chest value (0 if no chest or already taken)
	for c in chests:
		if c.x == tx and c.y == ty and not c.taken:
			c.taken = true
			return c.value
	return 0

func try_open_door(tx: int, ty: int, has_key: bool) -> bool:
	# why: returns true if door is now open (or already open)
	for d in doors:
		if d.pos.x == tx and d.pos.y == ty:
			if d.open:
				return true
			if has_key:
				d.open = true
				return true
			return false
	# why: not a door tile — walkable check is caller's job
	return true

func is_door_open(tx: int, ty: int) -> bool:
	for d in doors:
		if d.pos.x == tx and d.pos.y == ty:
			return d.open
	return true  # not a door = no blocking

func is_exit(tx: int, ty: int, exit_pos: Vector2i) -> bool:
	return tx == exit_pos.x and ty == exit_pos.y

func mark_food_consumed(tx: int, ty: int) -> void:
	consumed_foods.append(Vector2i(tx, ty))

func is_food_consumed(tx: int, ty: int) -> bool:
	for v in consumed_foods:
		if v.x == tx and v.y == ty:
			return true
	return false

func to_dict() -> Dictionary:
	return {
		"foods": foods, "keys": keys, "potions": potions,
		"chests": chests, "doors": doors, "consumed_foods": consumed_foods
	}
