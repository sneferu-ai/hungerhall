class_name RulesSession
extends RefCounted
## The pure game loop driver (G6 §3.1). Drives floor + player + enemies +
## generators + projectiles + hazards + pickups + score + continue + replay.
## ZERO engine RNG. ZERO Node dependency. Deterministic from seed.

const Tile = StateEnums.Tile
const ClassType = StateEnums.ClassType
const EnemyAIType = StateEnums.EnemyAIType
const HazardType = StateEnums.HazardType

var tunables: TunablesLoader = null
var floor: RulesFloor = RulesFloor.new()
var player: RulesPlayer = RulesPlayer.new()
var enemies: Array = []            # Array[RulesEnemy]
var generators: Array = []         # Array[RulesGenerator]
var projectiles: Array = []        # Array[RulesProjectile]
var hazards: Array = []            # Array[RulesHazard]
var pickups: RulesPickup = RulesPickup.new()
var score: RulesScore = RulesScore.new()
var continue_state: RulesContinue = RulesContinue.new()
var replay: RulesReplay = RulesReplay.new()
var seed_value: int = 42

var floor_number: int = 1
var hero_name: String = "warrior"
var class_def: ClassDef = null
var tick: int = 0
var state: int = StateEnums.State.PLAYING
var door_open: bool = false
var exit_overlap_frames: int = 0
var death_countdown_ticks: int = 0
var dying_ticks: int = 0
var continue_timer_ticks: int = 0
var continue_decision: String = ""  # "yes", "no", ""
var collapsing_remove_timers: Array = []  # [{hazard, tiles_to_remove, ticks_left}]
var potion_freeze_ticks: int = 0
var _pending_input: Array = []
var _pending_cues: Array = []    # Array[{cue_id: StringName, step: int}] — G6 §3.3 musician cue seam
var _pending_events: Array = []  # Array[{type, step, position, entity_id, amount}] — G6 §3.3 presentation events
var _auto_fire_held: bool = false
var _auto_fire_counter: int = 0
var _food_eaten: int = 0
var _kills_this_floor: int = 0
var _gen_destroyed_this_floor: int = 0
var _drain_ticks: int = 0
var _drain_damage_applied: int = 0

func setup_campaign(t: TunablesLoader, cd: ClassDef, s: int) -> void:
	tunables = t
	class_def = cd
	hero_name = cd.display_name.to_lower()
	seed_value = s
	score.reset()
	floor_number = 1
	_load_floor(floor_number)
	player.setup_from_class_def(cd)
	_place_player_at_spawn()

func load_floor(t: TunablesLoader, fd: FloorData) -> void:
	tunables = t
	floor_number = fd.floor_number
	floor.setup_from_floor_data(fd)
	score.on_floor_entry()
	continue_state.reset_for_floor_entry(tunables)
	_reset_floor_state()
	_load_initial_entities()

func continue_floor() -> void:
	# why: rebuild from spawn, HP 50%, potions zeroed, keys zeroed, food NOT
	# restored (G2 §2: eaten stays eaten — a continue is not a scum). The
	# floor reset re-derives pickups from baked data, so the consumed ledger
	# is carried across explicitly and the eaten pieces removed again.
	var eaten: Array = pickups.consumed_foods.duplicate()
	RulesContinue.rebuild_floor(player, floor, class_def.hp, tunables)
	_clear_transient_entities()
	_reset_floor_state()
	for v in eaten:
		pickups.mark_food_consumed(v.x, v.y)
		for i in range(pickups.foods.size() - 1, -1, -1):
			if pickups.foods[i].x == v.x and pickups.foods[i].y == v.y:
				pickups.foods.remove_at(i)
				break
	continue_state.consume()
	player.invuln_ticks = 18
	state = StateEnums.State.PLAYING

func retry_floor() -> void:
	# why: same as load_floor but keeps score penalties; restart from save point
	score.on_floor_entry()
	continue_state.reset_for_floor_entry(tunables)
	_clear_transient_entities()
	_reset_floor_state()
	_load_initial_entities()
	_place_player_at_spawn()
	state = StateEnums.State.PLAYING

func advance_floor() -> void:
	floor_number += 1
	if floor_number > 24:
		state = StateEnums.State.CAMPAIGN_RESULTS
		score.on_campaign_clear(tunables)
		return
	_load_floor(floor_number)
	_place_player_at_spawn()
	score.on_floor_entry()
	continue_state.reset_for_floor_entry(tunables)
	state = StateEnums.State.PLAYING

# ---- baked floor loading (G2 §7: runtime contains ZERO layout RNG) ----
# All 24 layouts are solver-gated bake-time artifacts at
# res://data/floors/base/floor_01..24.tres, produced by tools/floor_baker.gd
# and re-verified by tools/solver.gd. The seed no longer shapes layouts —
# identical floors ship for all players; replay/identity is carried by the
# frozen resources themselves.

var last_floor_load_ok: bool = true

static func baked_floor_path(fn: int) -> String:
	return "res://data/floors/base/floor_%02d.tres" % fn

func _load_floor(fn: int) -> void:
	last_floor_load_ok = true
	var fd: FloorData = _baked_floor_for(fn)
	if fd == null:
		# why: a missing/corrupt baked floor is a content fault, not a crash —
		# the SSM mounts MODAL_FLOOR_MISSING (G5 §1 skip/return seam) when it
		# sees last_floor_load_ok == false on entry to PLAYING
		last_floor_load_ok = false
		push_error("RulesSession: baked floor %s failed to load" % baked_floor_path(fn))
		return
	floor.setup_from_floor_data(fd)
	score.on_floor_entry()
	continue_state.reset_for_floor_entry(tunables)
	_reset_floor_state()
	_load_initial_entities()

func _baked_floor_for(fn: int) -> FloorData:
	if fn < 1 or fn > 24:
		return null
	var path: String = baked_floor_path(fn)
	if not ResourceLoader.exists(path):
		return null
	var res: Resource = load(path)
	if res is FloorData:
		return res
	return null

func _reset_floor_state() -> void:
	tick = 0
	exit_overlap_frames = 0
	death_countdown_ticks = 0
	dying_ticks = 0
	continue_timer_ticks = 0
	continue_decision = ""
	projectiles.clear()
	potion_freeze_ticks = 0
	collapsing_remove_timers.clear()
	_pending_cues.clear()
	_pending_events.clear()
	_food_eaten = 0
	_kills_this_floor = 0
	_gen_destroyed_this_floor = 0
	_drain_ticks = 0
	_drain_damage_applied = 0
	pickups.setup_from_floor(floor)
	door_open = false
	for h in hazards:
		h.phase = 0

func _clear_transient_entities() -> void:
	enemies.clear()
	generators.clear()
	projectiles.clear()
	hazards.clear()
	_load_initial_entities()

func _place_player_at_spawn() -> void:
	var px: Vector2 = floor.tile_to_pixel(floor.spawn.x, floor.spawn.y, 32)
	player.pos_x = px.x
	player.pos_y = px.y
	player.hp = player.max_hp
	player.potions = 0
	player.keys = 0
	player.facing = Vector2(0, 1)
	player.invuln_ticks = 18
	player.aegis_ticks = 0
	player.contact_reduction_fraction = 1.0

func _load_initial_entities() -> void:
	# why: instantiate generators from floor data
	var gid: int = 0
	for g in floor.generators:
		var gen: RulesGenerator = RulesGenerator.new()
		var gd: GeneratorDef = _generator_def_for(g.enemy_type, tunables)
		gen.setup(gd, gid, g.x, g.y, 32)
		generators.append(gen)
		gid += 1
	# why: instantiate hazards from floor data
	var hid: int = 0
	for h in floor.hazards:
		var hazard: RulesHazard = RulesHazard.new()
		hazard.setup(hid, h.type, h.trigger, h.tiles, h.phase)
		hazards.append(hazard)
		hid += 1
	# why: instantiate scripted initial enemies (Death spawns scripted)
	var eid: int = 0
	for e in floor.initial_enemies:
		var enemy: RulesEnemy = RulesEnemy.new()
		var ed: EnemyDef = _enemy_def_for(e.type, tunables)
		enemy.setup_from_def(ed, eid)
		var ep: Vector2 = floor.tile_to_pixel(e.x, e.y, 32)
		enemy.pos_x = ep.x
		enemy.pos_y = ep.y
		enemy.generator_id = -1
		enemies.append(enemy)
		eid += 1

func input(event: Dictionary) -> void:
	# why: queue input events for the next step()
	_pending_input.append(event)

func has_legal_action() -> bool:
	# why: in PLAYING/DYING/CONTINUE_OFFER there's always at least one legal input
	if state == StateEnums.State.PLAYING:
		return true
	if state == StateEnums.State.CONTINUE_OFFER:
		return continue_state.has_tokens()
	if state == StateEnums.State.GAME_OVER:
		return true  # retry or title
	return false

func consume_pending() -> Dictionary:
	# why: G6 §3.3 — {cues: Array[Dictionary], events: Array[Dictionary]}.
	# Cues are the stable named semantic cue events for the musician handoff
	# (forwarded to app/CueBus by the app controller); events feed the
	# presentation layer (play.gd consume_events).
	var out: Dictionary = {
		"cues": _pending_cues.duplicate(true),
		"events": _pending_events.duplicate(true)
	}
	_pending_cues.clear()
	_pending_events.clear()
	return out

func _drain_input() -> Array:
	var pending: Array = _pending_input.duplicate()
	_pending_input.clear()
	return pending

func _push_cue(cue_id: StringName) -> void:
	_pending_cues.append({"cue_id": cue_id, "step": tick})
	_justify_pending(_pending_cues)

func _push_event(type: StringName, px: float, py: float, entity_id: int, amount: int) -> void:
	_pending_events.append({
		"type": type,
		"step": tick,
		"position": [int(px), int(py)],
		"entity_id": entity_id,
		"amount": amount
	})
	_justify_pending(_pending_events)

func _justify_pending(queue: Array) -> void:
	# why: bounded queue — the app controller drains every step, but headless
	# bot runs never consume; an undrained queue must not grow unbounded
	if queue.size() > 1024:
		var overflow: int = queue.size() - 1024
		for _i in range(overflow):
			queue.pop_front()

func step() -> void:
	if state != StateEnums.State.PLAYING and state != StateEnums.State.DYING and state != StateEnums.State.CONTINUE_OFFER:
		# why: non-active states still advance tick for UI timers
		tick += 1
		return
	if state == StateEnums.State.DYING:
		_step_dying()
		tick += 1
		return
	if state == StateEnums.State.CONTINUE_OFFER:
		_step_continue_offer()
		tick += 1
		return
	# PLAYING
	var events: Array = _drain_input()
	for event in events:
		_process_input(event)
	_step_auto_fire()
	_step_movement()
	_step_drain()
	_step_enemies()
	_step_generators()
	_step_projectiles()
	_step_hazards()
	_step_collapsing_void()
	_step_pickups()
	_step_win_check()
	_step_death_check()
	player.tick_cooldowns()
	if potion_freeze_ticks > 0:
		potion_freeze_ticks -= 1
	tick += 1

func snapshot() -> Dictionary:
	return {
		"tick": tick,
		"state": state,
		"floor": floor_number,
		"class": hero_name,
		"player": player.to_dict(),
		"enemies": _enemies_to_array(),
		"generators": _generators_to_array(),
		"projectiles": _projectiles_to_array(),
		"score": score.to_dict(),
		"continue": continue_state.to_dict(),
		"exit_overlap_frames": exit_overlap_frames,
		"door_open": door_open,
		"food_eaten": _food_eaten,
		"kills_this_floor": _kills_this_floor,
		"generators_destroyed": _gen_destroyed_this_floor,
		"food_remaining": pickups.food_count(),
		"keys_held": player.keys,
		"potions": player.potions,
		"floor_view": _floor_view(),
	}

## Presentation seam (G6 §2 world/ imports core/ only): a JSON-safe view of
## the current floor's layout + pickup state so the projection never touches
## rules objects directly. Additive — pre-existing snapshot keys unchanged.
func _floor_view() -> Dictionary:
	var tile_rows: Array = []
	for row in floor.tiles:
		tile_rows.append(String(row))
	var doors_out: Array = []
	for d in pickups.doors:
		var p: Vector2i = d.pos
		doors_out.append({"x": p.x, "y": p.y, "open": bool(d.open)})
	var foods_out: Array = []
	for v in pickups.foods:
		foods_out.append({"x": v.x, "y": v.y})
	var keys_out: Array = []
	for v in pickups.keys:
		keys_out.append({"x": v.x, "y": v.y})
	var potions_out: Array = []
	for v in pickups.potions:
		potions_out.append({"x": v.x, "y": v.y})
	var chests_out: Array = []
	for c in pickups.chests:
		chests_out.append({"x": int(c.x), "y": int(c.y), "taken": bool(c.taken)})
	return {
		"grid_w": floor.grid_w,
		"grid_h": floor.grid_h,
		"tiles": tile_rows,
		"floor_number": floor_number,
		"spawn": {"x": floor.spawn.x, "y": floor.spawn.y},
		"exit": {"x": floor.exit_pos.x, "y": floor.exit_pos.y},
		"door_open": door_open,
		"doors": doors_out,
		"foods": foods_out,
		"keys": keys_out,
		"potions": potions_out,
		"chests": chests_out,
	}

func _process_input(event: Dictionary) -> void:
	var etype: String = event.get("type", "")
	match etype:
		"move":
			var dx: float = float(event.get("dx", 0.0))
			var dy: float = float(event.get("dy", 0.0))
			player.move_dir = Vector2(dx, dy)
			if dx != 0 or dy != 0:
				player.set_facing(dx, dy)
			replay.record(tick, "move", {"dx": dx, "dy": dy})
		"throw":
			_do_throw()
			replay.record(tick, "throw", {})
		"potion":
			_do_potion()
			replay.record(tick, "potion", {})
		"pause":
			# why: pause is a state transition handled by SSM; session just records
			replay.record(tick, "pause", {})
		"confirm":
			# why: primary action (menu confirm / throw / advance)
			_do_throw()
			replay.record(tick, "confirm", {})
		"auto_fire_on":
			_auto_fire_held = true
		"auto_fire_off":
			_auto_fire_held = false
			_auto_fire_counter = 0

func _step_auto_fire() -> void:
	if not _auto_fire_held:
		return
	if player.throw_ready():
		_do_throw()

func _do_throw() -> void:
	if not player.throw_ready():
		return
	if projectiles.size() >= 64:
		return  # why: safety cap to prevent projectile flood
	var p: RulesProjectile = RulesProjectile.new()
	p.setup(projectiles.size(), player.pos_x, player.pos_y, player.facing.x, player.facing.y, 320, player.shot_dmg, player.shot_range_tiles, 32, player.projectile_kind)
	if class_def.class_type == ClassType.WIZARD:
		p.splash_dmg = tunables.get_int("wizard_splash_dmg", 12)
		p.splash_radius_tiles = 1
	projectiles.append(p)
	player.start_throw_cooldown()
	_push_cue(&"cue.player.throw")
	_push_event(&"throw", player.pos_x, player.pos_y, 0, 0)

func _do_potion() -> void:
	if not player.use_potion():
		return
	potion_freeze_ticks = tunables.get_int("potion_freeze_ticks", 6)
	_push_cue(&"cue.player.potion")
	_push_event(&"potion_used", player.pos_x, player.pos_y, 0, 0)
	match class_def.potion_type:
		StateEnums.PotionType.AEGIS:
			player.aegis_ticks = tunables.get_int("potion_aegis_duration_ticks", 180)
			player.contact_reduction_fraction = tunables.get_value("valkyrie_reduce_fraction", 0.5)
			# why: Aegis halves contact damage for 3.0s
		StateEnums.PotionType.WHIRLWIND:
			_apply_aoe_damage(player.pos_x, player.pos_y, RulesCombat.potion_damage_to_enemies(StateEnums.PotionType.WHIRLWIND, tunables), RulesCombat.potion_damage_to_generators(StateEnums.PotionType.WHIRLWIND, tunables), RulesCombat.potion_radius_tiles(StateEnums.PotionType.WHIRLWIND, tunables), true)
		StateEnums.PotionType.NOVA:
			_apply_aoe_damage(player.pos_x, player.pos_y, RulesCombat.potion_damage_to_enemies(StateEnums.PotionType.NOVA, tunables), RulesCombat.potion_damage_to_generators(StateEnums.PotionType.NOVA, tunables), RulesCombat.potion_radius_tiles(StateEnums.PotionType.NOVA, tunables), false)
		StateEnums.PotionType.VOLLEY:
			_apply_volley()

func _apply_aoe_damage(cx: float, cy: float, enemy_dmg: int, gen_dmg: int, radius_tiles: int, knockback: bool) -> void:
	var radius_px: float = float(radius_tiles * 32)
	for e in enemies:
		if not e.alive:
			continue
		var dist: float = Vector2(e.pos_x - cx, e.pos_y - cy).length()
		if dist <= radius_px:
			e.take_damage(enemy_dmg)
			if knockback:
				# why: knockback 8px in direction from center
				var dir: Vector2 = Vector2(e.pos_x - cx, e.pos_y - cy)
				if dir.length() > 0:
					dir = dir.normalized() * 8
					e.pos_x += dir.x
					e.pos_y += dir.y
	for g in generators:
		if not g.alive:
			continue
		var dist: float = Vector2(g.pos_x - cx, g.pos_y - cy).length()
		if dist <= radius_px:
			g.take_damage(gen_dmg)
			if g.is_dead():
				_on_generator_destroyed(g)

func _apply_volley() -> void:
	# why: Elf fires 12 seeking projectiles at 15 dmg each in all directions
	var count: int = tunables.get_int("potion_volley_count", 12)
	var dmg: int = tunables.get_int("potion_volley_dmg", 15)
	for i in range(count):
		var angle: float = (float(i) / float(count)) * TAU
		var p: RulesProjectile = RulesProjectile.new()
		p.setup(projectiles.size(), player.pos_x, player.pos_y, cos(angle), sin(angle), 320, dmg, tunables.get_int("potion_volley_range_tiles", 10), 32, "arrow")
		projectiles.append(p)

func _step_movement() -> void:
	var dt: float = 1.0 / 60.0
	var new_x: float = player.pos_x + player.move_dir.x * player.speed * dt
	var new_y: float = player.pos_y + player.move_dir.y * player.speed * dt
	var tile: Vector2i = floor.pixel_to_tile(new_x, new_y, 32)
	# why: G2 §1 — "doors consume their key on push". Pushing into a closed
	# door with a key opens it (key consumed, cue + event fired) and the push
	# continues into the tile the same tick; without a key the push is refused
	# exactly like a wall. Round 5 opened doors only from _step_pickups while
	# STANDING ON the tile — unreachable while closed, which deadlocked every
	# door-gated floor (floor_02 onward) and failed the machine gate.
	var closed_door: Dictionary = {}
	for d in pickups.doors:
		if d.pos.x == tile.x and d.pos.y == tile.y and not d.open:
			closed_door = d
			break
	if not closed_door.is_empty():
		if player.keys <= 0:
			player.moving = player.move_dir.length() > 0.01
			return
		closed_door.open = true
		player.keys -= 1
		_push_cue(&"cue.door.open")
		_push_event(&"door_opened", player.pos_x, player.pos_y, 0, 0)
	# why: check walkable; allow movement if target tile is walkable
	var walkable: bool = floor.is_walkable(tile.x, tile.y, pickups.is_door_open(tile.x, tile.y))
	# why: also check collapsing-void removed tiles
	for h in hazards:
		if h.hazard_type == HazardType.COLLAPSING_VOID and h.is_tile_removed(tile.x, tile.y):
			walkable = false
			break
	if walkable:
		player.pos_x = new_x
		player.pos_y = new_y
	player.moving = player.move_dir.length() > 0.01

func _step_drain() -> void:
	if player.invuln_ticks > 0:
		return
	if player.hp <= 0:
		return
	# why: INTEGER-tick drain at fixed 60Hz — total HP owed after T drain ticks
	# is int(T * drain_hp_per_sec / 60). The round-6 float accumulator added
	# 2.0/60.0 sixty times = 1.9999… and silently dropped 1 HP per second at
	# every integer drain band (test_drain_is_tick_based_60hz). T * rate is
	# exact for the locked .0/.5 drain bands; the division floors partial HP
	# until it is whole — deterministic and replay-stable.
	_drain_ticks += 1
	var owed_total: int = int((_drain_ticks * floor.drain_hp_per_sec) / 60.0)
	var whole: int = owed_total - _drain_damage_applied
	if whole > 0:
		_drain_damage_applied += whole
		player.hp -= whole
		# why: G9 DoD #8 — cue.hp.tick promoted PROPOSED→REAL: fires on every
		# INTEGER HP decrement of the drain clock (SIG-1 The Heartbeat). The
		# presentation dispatch (CueBus → JuiceDirector AC-15 drain pulse) and
		# the bot telemetry seam both read it from this same rules path.
		_push_cue(&"cue.hp.tick")
	if player.hp < 0:
		player.hp = 0

func _step_enemies() -> void:
	if potion_freeze_ticks > 0:
		return  # why: potion freezes enemies for 0.1s
	for e in enemies:
		if not e.alive:
			continue
		e.tick_cooldowns()
		_step_enemy_ai(e)

func _step_enemy_ai(e: RulesEnemy) -> void:
	var dt: float = 1.0 / 60.0
	var to_player: Vector2 = Vector2(player.pos_x - e.pos_x, player.pos_y - e.pos_y)
	var dist_px: float = to_player.length()
	var tile_e: Vector2i = floor.pixel_to_tile(e.pos_x, e.pos_y, 32)
	var tile_p: Vector2i = floor.pixel_to_tile(player.pos_x, player.pos_y, 32)
	match e.ai_type:
		EnemyAIType.GHOST:
			# why: Ghost wall-passes straight toward player
			if dist_px > 1.0:
				var dir: Vector2 = to_player.normalized()
				e.pos_x += dir.x * e.speed * dt
				e.pos_y += dir.y * e.speed * dt
			_check_contact(e)
		EnemyAIType.GRUNT:
			# why: Grunt pathfinds around walls toward player
			var next: Vector2i = _pathfind_step(tile_e, tile_p, e.wall_pass)
			var target_px: Vector2 = floor.tile_to_pixel(next.x, next.y, 32)
			var move_dir: Vector2 = Vector2(target_px.x - e.pos_x, target_px.y - e.pos_y)
			if move_dir.length() > 1.0:
				move_dir = move_dir.normalized()
				e.pos_x += move_dir.x * e.speed * dt
				e.pos_y += move_dir.y * e.speed * dt
			_check_contact(e)
		EnemyAIType.DEMON:
			# why: Demon maintains distance, fires projectiles
			var maintain_tiles: int = tunables.get_int("demon_maintain_distance_tiles", 4)
			var maintain_px: float = float(maintain_tiles * 32)
			if dist_px > maintain_px + 8:
				var dir: Vector2 = to_player.normalized()
				e.pos_x += dir.x * e.speed * dt
				e.pos_y += dir.y * e.speed * dt
			elif dist_px < maintain_px - 8:
				var dir: Vector2 = -to_player.normalized()
				e.pos_x += dir.x * e.speed * dt
				e.pos_y += dir.y * e.speed * dt
			if e.can_fire() and floor.has_line_of_sight(tile_e.x, tile_e.y, tile_p.x, tile_p.y):
				_enemy_fire(e, player.pos_x, player.pos_y, tunables.get_int("demon_projectile_speed", 200), tunables.get_int("demon_projectile_dmg", 15), "demon_bolt", false)
				e.start_fire_cooldown(tunables.get_int("demon_fire_cadence_ticks", 120))
			_check_contact(e)
		EnemyAIType.LOBBER:
			# why: Lobber lob-fire arcs over walls, no LOS needed
			if e.can_fire():
				_enemy_fire(e, player.pos_x, player.pos_y, tunables.get_int("lobber_projectile_speed", 220), tunables.get_int("lobber_projectile_dmg", 20), "lobber_lob", true)
				e.start_fire_cooldown(tunables.get_int("lobber_fire_cadence_ticks", 150))
			_check_contact(e)
		EnemyAIType.SORCERER:
			# why: Sorcerer blinks when no LOS for 2s or HP < 40%; fires when LOS
			if floor.has_line_of_sight(tile_e.x, tile_e.y, tile_p.x, tile_p.y):
				e.no_los_ticks = 0
				if e.can_fire():
					_enemy_fire(e, player.pos_x, player.pos_y, tunables.get_int("demon_projectile_speed", 200), tunables.get_int("demon_projectile_dmg", 15), "sorcerer_bolt", false)
					e.start_fire_cooldown(tunables.get_int("demon_fire_cadence_ticks", 120))
			else:
				e.no_los_ticks += 1
				var blink_threshold: int = tunables.get_int("sorcerer_blink_hp_threshold", 40)
				var blink_no_los: int = tunables.get_int("sorcerer_blink_no_los_ticks", 120)
				if (e.hp < blink_threshold or e.no_los_ticks > blink_no_los) and e.blink_cooldown_ticks <= 0:
					_sorcerer_blink(e, tile_p)
					e.blink_cooldown_ticks = tunables.get_int("sorcerer_blink_cooldown_ticks", 300)
					e.no_los_ticks = 0
			_check_contact(e)
		EnemyAIType.DEATH:
			# why: Death is slow but deadly — 50 contact dmg, scripted spawn
			if dist_px > 1.0:
				var dir: Vector2 = to_player.normalized()
				e.pos_x += dir.x * e.speed * dt
				e.pos_y += dir.y * e.speed * dt
			_check_contact(e)

func _check_contact(e: RulesEnemy) -> void:
	var tile_e: Vector2i = floor.pixel_to_tile(e.pos_x, e.pos_y, 32)
	var tile_p: Vector2i = floor.pixel_to_tile(player.pos_x, player.pos_y, 32)
	if tile_e == tile_p and e.can_contact_damage():
		var advancing: bool = RulesCombat.is_valkyrie_advancing(player.move_dir, Vector2(e.pos_x - player.pos_x, e.pos_y - player.pos_y), tunables.get_value("valkyrie_reduce_angle_deg", 30.0))
		player.apply_damage(e.contact_dmg)
		_push_cue(&"cue.player.hurt")
		_push_event(&"player_hit", player.pos_x, player.pos_y, e.id, e.contact_dmg)
		if e.ai_type == EnemyAIType.GHOST:
			# why: Ghost dies on contact (kamikaze)
			e.take_damage(999)

func _enemy_fire(e: RulesEnemy, target_x: float, target_y: float, p_speed: int, p_dmg: int, p_kind: String, ignores_walls: bool) -> void:
	if projectiles.size() >= 64:
		return
	var p: RulesProjectile = RulesProjectile.new()
	p.setup_enemy(projectiles.size(), e.pos_x, e.pos_y, target_x - e.pos_x, target_y - e.pos_y, p_speed, p_dmg, p_kind, ignores_walls)
	projectiles.append(p)
	# why: G9 §9 row 8 (cue.enemy.telegraph, AC-37 ranged telegraph) — promoted
	# here exactly as cue.hp.tick / cue.projectile.impact were (DoD #8 pattern):
	# a presentation-seam cue at the REAL rules site, zero rules change. G9
	# frames the trigger as a "ranged windup"; the G2-locked rules have NO
	# windup state (enemies fire the same tick they decide), so the fire moment
	# is the only ranged-intent seam the locked runtime exposes. Adding a true
	# windup state would be a mechanic change — out of G10 polish scope and
	# documented as a supersession in PROTOTYPE_BRIEF §6. The cue drives the
	# AC-37 contract tween (JuiceDirector.on_cue); the sibling event carries the
	# entity id for the per-actor modulate projection (WorldView.telegraph_actor),
	# mirroring the projectile_hit/AC-41 two-lane split.
	_push_cue(&"cue.enemy.telegraph")
	_push_event(&"enemy_telegraph", e.pos_x, e.pos_y, e.id, 0)

func _sorcerer_blink(e: RulesEnemy, tile_p: Vector2i) -> void:
	# why: blink to a walkable tile within range_tiles, prefer flanking
	var range_tiles: int = tunables.get_int("sorcerer_blink_range_tiles", 6)
	var best: Vector2i = tile_p
	var best_dist: int = 999999
	for dx in range(-range_tiles, range_tiles + 1):
		for dy in range(-range_tiles, range_tiles + 1):
			var nx: int = tile_p.x + dx
			var ny: int = tile_p.y + dy
			if floor.is_walkable(nx, ny, true):
				var d: int = abs(dx) + abs(dy)
				if d >= 3 and d < best_dist:
					best_dist = d
					best = Vector2i(nx, ny)
	var px: Vector2 = floor.tile_to_pixel(best.x, best.y, 32)
	e.pos_x = px.x
	e.pos_y = px.y

func _pathfind_step(from: Vector2i, to: Vector2i, wall_pass: bool) -> Vector2i:
	# why: greedy BFS one-step — move toward target on walkable tile
	if from == to:
		return from
	var dx: int = to.x - from.x
	var dy: int = to.y - from.y
	var sx: int = 1 if dx > 0 else (-1 if dx < 0 else 0)
	var sy: int = 1 if dy > 0 else (-1 if dy < 0 else 0)
	# why: try diagonal first (8-way), then cardinal
	var candidates: Array = [
		Vector2i(from.x + sx, from.y + sy),
		Vector2i(from.x + sx, from.y),
		Vector2i(from.x, from.y + sy),
	]
	for c in candidates:
		if wall_pass or floor.is_walkable(c.x, c.y, true):
			return c
	return from

func _step_generators() -> void:
	if potion_freeze_ticks > 0:
		return
	var alive_count: int = 0
	for e in enemies:
		if e.alive:
			alive_count += 1
	var floor_cap: int = tunables.get_int("gen_max_alive_per_floor", 28)
	for g in generators:
		if not g.alive:
			continue
		g.tick()
		var children_alive: int = 0
		for e in enemies:
			if e.alive and e.generator_id == g.id:
				children_alive += 1
		if g.ready_to_spawn(children_alive, alive_count, floor_cap):
			_spawn_from_generator(g)
			g.reset_spawn_counter()

func _spawn_from_generator(g: RulesGenerator) -> void:
	var ed: EnemyDef = _enemy_def_for(g.enemy_type, tunables)
	var enemy: RulesEnemy = RulesEnemy.new()
	enemy.setup_from_def(ed, enemies.size())
	enemy.pos_x = g.pos_x
	enemy.pos_y = g.pos_y
	enemy.generator_id = g.id
	enemies.append(enemy)

func _step_projectiles() -> void:
	for p in projectiles:
		if not p.alive:
			continue
		var result: Dictionary = p.tick(32, floor)
		if p.faction == 0:
			_check_player_projectile_hits(p)
		else:
			_check_enemy_projectile_hits(p)
	# why: prune dead projectiles
	var alive_projectiles: Array = []
	for p in projectiles:
		if p.alive:
			alive_projectiles.append(p)
	projectiles = alive_projectiles

func _check_player_projectile_hits(p: RulesProjectile) -> void:
	# why: check enemy hits
	for e in enemies:
		if not e.alive:
			continue
		if p.hit_entities.has(e.id):
			continue
		var tile_e: Vector2i = floor.pixel_to_tile(e.pos_x, e.pos_y, 32)
		var tile_p: Vector2i = floor.pixel_to_tile(p.pos_x, p.pos_y, 32)
		if tile_e == tile_p:
			e.take_damage(p.dmg)
			p.hit_entities.append(e.id)
			_push_cue(&"cue.enemy.hurt")
			# why: G9 DoD #8 — cue.projectile.impact promoted PROPOSED→REAL:
			# AC-41 impact flash triggers from this cue (G9 §9 row 20)
			_push_cue(&"cue.projectile.impact")
			_push_event(&"projectile_hit", e.pos_x, e.pos_y, e.id, p.dmg)
			if p.splash_dmg > 0:
				_apply_splash(p.pos_x, p.pos_y, p.splash_dmg, p.splash_radius_tiles, false)
			if e.is_dead():
				_on_enemy_killed(e)
			if not p.pierces:
				p.alive = false
				return
	# why: check generator hits
	for g in generators:
		if not g.alive:
			continue
		var tile_g: Vector2i = Vector2i(g.tile_x, g.tile_y)
		var tile_p: Vector2i = floor.pixel_to_tile(p.pos_x, p.pos_y, 32)
		if tile_g == tile_p:
			var dmg: int = RulesCombat.damage_to_generator(p.dmg, class_def.class_type, p.splash_dmg)
			g.take_damage(dmg)
			_push_cue(&"cue.generator.hurt")
			_push_cue(&"cue.projectile.impact")  # G9 §9 row 20 — projectile hits
			_push_event(&"projectile_hit", g.pos_x, g.pos_y, g.id, dmg)
			if g.is_dead():
				_on_generator_destroyed(g)
			p.alive = false
			return

func _check_enemy_projectile_hits(p: RulesProjectile) -> void:
	var tile_p: Vector2i = floor.pixel_to_tile(p.pos_x, p.pos_y, 32)
	var tile_player: Vector2i = floor.pixel_to_tile(player.pos_x, player.pos_y, 32)
	if tile_p == tile_player:
		var advancing: bool = RulesCombat.is_valkyrie_advancing(player.move_dir, Vector2(p.pos_x - player.pos_x, p.pos_y - player.pos_y), tunables.get_value("valkyrie_reduce_angle_deg", 30.0))
		player.apply_projectile_damage(p.dmg, advancing)
		_push_cue(&"cue.player.hurt")
		_push_cue(&"cue.projectile.impact")  # G9 §9 row 20 — projectile hits
		_push_event(&"player_hit", player.pos_x, player.pos_y, p.id, p.dmg)
		p.alive = false

func _apply_splash(cx: float, cy: float, splash_dmg: int, radius_tiles: int, hit_gens: bool) -> void:
	var radius_px: float = float(radius_tiles * 32)
	for e in enemies:
		if not e.alive:
			continue
		var dist: float = Vector2(e.pos_x - cx, e.pos_y - cy).length()
		if dist <= radius_px:
			e.take_damage(splash_dmg)
			if e.is_dead():
				_on_enemy_killed(e)

func _on_enemy_killed(e: RulesEnemy) -> void:
	score.add_kill(e.ai_type, tunables)
	_kills_this_floor += 1
	_push_cue(&"cue.enemy.killed")
	_push_event(&"enemy_killed", e.pos_x, e.pos_y, e.id, 0)

func _on_generator_destroyed(g: RulesGenerator) -> void:
	score.on_generator_destroyed(tunables)
	_gen_destroyed_this_floor += 1
	_push_cue(&"cue.generator.destroyed")
	_push_event(&"generator_destroyed", g.pos_x, g.pos_y, g.id, 0)
	# why: kill children of this generator
	for e in enemies:
		if e.alive and e.generator_id == g.id:
			e.take_damage(999)

func _step_hazards() -> void:
	for h in hazards:
		if h.hazard_type == StateEnums.HazardType.FLAME_JET:
			# why: G9 AC-39 (flame-jet pre-ON flicker) needs a deterministic rules
			# truth to trigger from. The jet's clock is the rules-owned phase;
			# emit the cue exactly flame_jet_preon_ticks BEFORE the damage phase
			# starts. Cue emission only — the active/damage window below is
			# untouched, so this is presentation seam, not a mechanic change.
			var on_t: int = tunables.get_int("flame_jet_on_ticks", 60)
			var off_t: int = tunables.get_int("flame_jet_off_ticks", 120)
			var preon_t: int = tunables.get_int("flame_jet_preon_ticks", 9)
			if h.phase % (on_t + off_t) == (on_t + off_t - preon_t):
				_push_cue(&"cue.hazard.flame_preon")
		h.tick(tunables)
		# why: check if player is on a damaging hazard tile
		var tile_p: Vector2i = floor.pixel_to_tile(player.pos_x, player.pos_y, 32)
		if h.is_tile_damaging(tile_p.x, tile_p.y):
			if player.invuln_ticks <= 0 and player.aegis_ticks <= 0:
				var hazard_dmg: int = h.damage_amount(tunables)
				player.apply_damage(hazard_dmg)
				_push_cue(&"cue.player.hurt")
				_push_event(&"player_hit", player.pos_x, player.pos_y, h.id, hazard_dmg)

func _step_collapsing_void() -> void:
	# why: track player steps on collapsing-void tiles; remove after timer
	for h in hazards:
		if h.hazard_type != HazardType.COLLAPSING_VOID:
			continue
		var tile_p: Vector2i = floor.pixel_to_tile(player.pos_x, player.pos_y, 32)
		for v in h.tiles:
			if v.x == tile_p.x and v.y == tile_p.y and not h.is_tile_removed(v.x, v.y):
				# why: start removal timer for this tile
				var already_tracked: bool = false
				for timer in collapsing_remove_timers:
					if timer.hazard == h and timer.tiles_to_remove.has(v):
						already_tracked = true
						break
				if not already_tracked:
					collapsing_remove_timers.append({
						"hazard": h,
						"tiles_to_remove": [v],
						"ticks_left": tunables.get_int("collapsing_void_remove_after_ticks", 120)
					})
	# why: advance timers and remove tiles
	var still_active: Array = []
	for timer in collapsing_remove_timers:
		timer.ticks_left -= 1
		if timer.ticks_left <= 0:
			for v in timer.tiles_to_remove:
				timer.hazard.mark_removed(v.x, v.y)
		else:
			still_active.append(timer)
	collapsing_remove_timers = still_active

func _step_pickups() -> void:
	var tile_p: Vector2i = floor.pixel_to_tile(player.pos_x, player.pos_y, 32)
	# why: food
	if not pickups.is_food_consumed(tile_p.x, tile_p.y):
		var heal: int = pickups.try_eat_food(tile_p.x, tile_p.y, tunables.get_int("food_hp", 150))
		if heal > 0:
			player.heal(heal)
			_food_eaten += 1
			pickups.mark_food_consumed(tile_p.x, tile_p.y)
			score.on_food_eaten()
			_push_cue(&"cue.pickup.food")
			_push_event(&"food_consumed", player.pos_x, player.pos_y, 0, heal)
	# why: keys
	if pickups.try_collect_key(tile_p.x, tile_p.y):
		player.keys += 1
		_push_cue(&"cue.pickup.key")
		_push_event(&"key_collected", player.pos_x, player.pos_y, 0, 1)
	# why: potions
	if pickups.try_collect_potion(tile_p.x, tile_p.y, tunables.get_int("potion_cap", 3), player.potions):
		player.potions += 1
		_push_cue(&"cue.pickup.potion")
		_push_event(&"potion_collected", player.pos_x, player.pos_y, 0, 1)
	# why: chests
	var chest_value: int = pickups.try_open_chest(tile_p.x, tile_p.y)
	if chest_value > 0:
		score.on_chest_opened(chest_value)
		_push_cue(&"cue.pickup.chest")
		_push_event(&"chest_opened", player.pos_x, player.pos_y, 0, chest_value)
	# why: doors open on PUSH into the closed tile (G2 §1) — that rule lives in
	# _step_movement. A player can only stand on a door tile that is already
	# open, so there is no stand-on open path here (the round-5 stand-on branch
	# was unreachable dead code that masked the deadlock).
	# why: update door_open flag for win check
	door_open = pickups.is_door_open(floor.exit_pos.x, floor.exit_pos.y) or _exit_door_is_open()

func _exit_door_is_open() -> bool:
	# why: exit door requires a key to open; check if the exit-adjacent door is open
	for d in pickups.doors:
		if d.pos.x == floor.exit_pos.x and d.pos.y == floor.exit_pos.y:
			return d.open
	# why: if no door on exit tile, it's always accessible
	return true

func _step_win_check() -> void:
	var tile_p: Vector2i = floor.pixel_to_tile(player.pos_x, player.pos_y, 32)
	if tile_p.x == floor.exit_pos.x and tile_p.y == floor.exit_pos.y and door_open:
		exit_overlap_frames += 1
	else:
		exit_overlap_frames = 0
	if exit_overlap_frames >= tunables.get_int("exit_overlap_required_frames", 3):
		if floor_number >= 24:
			score.on_campaign_clear(tunables)
			state = StateEnums.State.CAMPAIGN_RESULTS
			_push_cue(&"cue.campaign.clear")
			_push_event(&"campaign_clear", player.pos_x, player.pos_y, 0, floor_number)
		else:
			score.on_floor_clear(tunables)
			state = StateEnums.State.FLOOR_RESULTS
			_push_cue(&"cue.floor.clear")
			_push_event(&"floor_clear", player.pos_x, player.pos_y, 0, floor_number)

func _step_death_check() -> void:
	if player.hp <= 0 and death_countdown_ticks == 0:
		death_countdown_ticks = tunables.get_int("death_countdown_ticks", 24)
	if death_countdown_ticks > 0:
		death_countdown_ticks -= 1
		if death_countdown_ticks == 0:
			score.on_death(tunables)
			state = StateEnums.State.DYING
			_push_cue(&"cue.player.death")
			_push_event(&"death", player.pos_x, player.pos_y, 0, 0)

func _step_dying() -> void:
	dying_ticks += 1
	var crumble: int = tunables.get_int("dying_crumble_ticks", 72)
	if dying_ticks >= crumble:
		state = StateEnums.State.CONTINUE_OFFER
		continue_timer_ticks = tunables.get_int("continue_timer_ticks", 600)
		_push_cue(&"cue.continue.offered")

func _step_continue_offer() -> void:
	if continue_timer_ticks > 0:
		continue_timer_ticks -= 1
		if continue_timer_ticks == 0 and continue_decision == "":
			continue_decision = "timeout"
			state = StateEnums.State.GAME_OVER
			_push_cue(&"cue.continue.expired")

func decide_continue(yes: bool) -> void:
	if state != StateEnums.State.CONTINUE_OFFER:
		return
	if yes and continue_state.has_tokens():
		continue_decision = "yes"
		_push_cue(&"cue.continue.accepted")
		continue_floor()
	elif yes and not continue_state.has_tokens():
		continue_decision = "no_tokens"
		_push_cue(&"cue.continue.refused")
		state = StateEnums.State.GAME_OVER
	else:
		continue_decision = "no"
		_push_cue(&"cue.continue.refused")
		state = StateEnums.State.GAME_OVER

# ---- floor layout generation REMOVED (G2 §7) ----
# The old seed-driven _build_floor_data/_generate_* runtime layout RNG is
# gone. Layouts are baked + solver-gated at build time (tools/floor_baker.gd
# → data/floors/base/floor_01..24.tres) and loaded by _load_floor above.
# Only per-entity defs (generator/enemy stat blocks) remain runtime-built,
# and they are pure functions of tunables — no randomness.

func _generator_def_for(enemy_type: int, t: TunablesLoader) -> GeneratorDef:
	var gd: GeneratorDef = GeneratorDef.new()
	gd.enemy_type = enemy_type
	match enemy_type:
		EnemyAIType.GHOST:
			gd.generator_type = "drowned"
			gd.display_name = "CLOCHE"
			gd.hp = t.get_int("gen_hp_drowned", 60)
			gd.spawn_cadence_ticks = t.get_int("gen_cadence_drowned", 180)
		EnemyAIType.GRUNT:
			gd.generator_type = "drowned"
			gd.display_name = "CLOCHE"
			gd.hp = t.get_int("gen_hp_drowned", 60)
			gd.spawn_cadence_ticks = t.get_int("gen_cadence_drowned", 180)
		EnemyAIType.DEMON:
			gd.generator_type = "cinder"
			gd.display_name = "HEARTH"
			gd.hp = t.get_int("gen_hp_cinder", 90)
			gd.spawn_cadence_ticks = t.get_int("gen_cadence_cinder", 150)
		EnemyAIType.LOBBER:
			gd.generator_type = "starved"
			gd.display_name = "LARDER"
			gd.hp = t.get_int("gen_hp_starved", 120)
			gd.spawn_cadence_ticks = t.get_int("gen_cadence_starved", 120)
		EnemyAIType.SORCERER:
			gd.generator_type = "throne"
			gd.display_name = "THRONE"
			gd.hp = t.get_int("gen_hp_throne", 160)
			gd.spawn_cadence_ticks = t.get_int("gen_cadence_throne_early", 108)
		_:
			gd.generator_type = "drowned"
			gd.display_name = "CLOCHE"
	return gd

func _enemy_def_for(ai_type: int, t: TunablesLoader) -> EnemyDef:
	var ed: EnemyDef = EnemyDef.new()
	ed.ai_type = ai_type
	match ai_type:
		EnemyAIType.GHOST:
			ed.display_name = "GHOST"
			ed.hp = t.get_int("enemy_hp_ghost", 14)
			ed.speed = t.get_int("enemy_speed_ghost", 100)
			ed.contact_dmg = t.get_int("contact_dmg_ghost", 10)
			ed.wall_pass = true
			ed.sprite_ref = "res://Assets/enemy-ghost.png"
		EnemyAIType.GRUNT:
			ed.display_name = "GRUNT"
			ed.hp = t.get_int("enemy_hp_grunt", 30)
			ed.speed = t.get_int("enemy_speed_grunt", 80)
			ed.contact_dmg = t.get_int("contact_dmg_grunt", 15)
			ed.wall_pass = false
			ed.sprite_ref = "res://Assets/enemy-grunt.png"
		EnemyAIType.DEMON:
			ed.display_name = "DEMON"
			ed.hp = t.get_int("enemy_hp_demon", 60)
			ed.speed = t.get_int("enemy_speed_demon", 90)
			ed.contact_dmg = t.get_int("contact_dmg_demon", 20)
			ed.wall_pass = false
			ed.sprite_ref = "res://Assets/enemy-demon.png"
		EnemyAIType.LOBBER:
			ed.display_name = "LOBBER"
			ed.hp = t.get_int("enemy_hp_lobber", 50)
			ed.speed = t.get_int("enemy_speed_lobber", 70)
			ed.contact_dmg = t.get_int("contact_dmg_lobber", 15)
			ed.wall_pass = false
			ed.sprite_ref = "res://Assets/enemy-lobber.png"
		EnemyAIType.SORCERER:
			ed.display_name = "SORCERER"
			ed.hp = t.get_int("enemy_hp_sorcerer", 80)
			ed.speed = t.get_int("enemy_speed_sorcerer", 110)
			ed.contact_dmg = t.get_int("contact_dmg_sorcerer", 20)
			ed.wall_pass = false
			ed.sprite_ref = "res://Assets/enemy-sorcerer.png"
		EnemyAIType.DEATH:
			ed.display_name = "DEATH"
			ed.hp = t.get_int("enemy_hp_death", 300)
			ed.speed = t.get_int("enemy_speed_death", 60)
			ed.contact_dmg = t.get_int("contact_dmg_death", 50)
			ed.wall_pass = true
			ed.sprite_ref = "res://Assets/enemy-death.png"
	return ed

func _enemies_to_array() -> Array:
	var out: Array = []
	for e in enemies:
		if e.alive:
			out.append(e.to_dict())
	return out

func _generators_to_array() -> Array:
	var out: Array = []
	for g in generators:
		out.append(g.to_dict())
	return out

func _projectiles_to_array() -> Array:
	var out: Array = []
	for p in projectiles:
		if p.alive:
			out.append(p.to_dict())
	return out
