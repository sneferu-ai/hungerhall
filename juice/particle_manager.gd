class_name ParticleManager
extends Node
## G10 — ParticleManager (G9 JuiceDirector partition). Owns the particle
## budget ledger: per-type instance caps + the global 160-particle cap,
## enforced DETERMINISTICALLY per fixed tick — caps are code, not hope
## (G9 §3 "every count is a hard cap"; reviewer-B point 4). The projection
## (WorldView.particles) renders whatever survives this gate; in headless
## trees the ledger still enforces the budget so tests can pin it.
##
## Rules (G9 §3 exact):
##  - global cap: juice.particles.global_cap (160) total LIVE PARTICLES;
##  - critical particles (PT-06/07/09) are never killed by global eviction;
##  - per-type instance caps still apply to critical particles — overflow
##    within a type snap-completes the OLDEST instance of that type
##    (critical vs critical: new wins);
##  - global overflow evicts whole emitters in JuiceContracts.eviction_order
##    (non-critical only), first-killed first;
##  - one-shot emitters die when their lifetime ticks expire (tick()).

var global_cap: int = 160

var _live: Array = []  # Array[{ptype, count, critical, ticks_left}]

func configure(tun: TunablesLoader) -> void:
	if tun == null:
		return
	global_cap = tun.get_int("juice.particles.global_cap", 160)

## Request one emitter instance. Returns true when admitted.
func request(ptype: String, count: int, life_ticks: int, critical: bool, max_inst: int) -> bool:
	if count <= 0:
		return false
	# ---- per-type instance cap FIRST (applies to critical too; new wins) ----
	if max_inst > 0:
		var live_of_type: Array = instances_of(ptype)
		while live_of_type.size() >= max_inst:
			_remove(live_of_type[0])
			live_of_type = instances_of(ptype)
	# ---- global cap on LIVE PARTICLES (whole-emitter eviction, non-critical) ----
	while particle_units() + count > global_cap:
		var victim: Dictionary = _eviction_candidate(ptype)
		if victim.is_empty():
			return false  # only critical emitters remain — never kill them
		_remove(victim)
	_live.append({"ptype": ptype, "count": count, "critical": critical, "ticks_left": maxi(1, life_ticks)})
	return true

## Advance lifetimes by one fixed 60Hz tick; expired emitters die.
func tick() -> void:
	var i: int = _live.size() - 1
	while i >= 0:
		_live[i].ticks_left -= 1
		if int(_live[i].ticks_left) <= 0:
			_live.remove_at(i)
		i -= 1

func instances_of(ptype: String) -> Array:
	var out: Array = []
	for inst in _live:
		if str(inst.ptype) == ptype:
			out.append(inst)
	return out

func instance_count() -> int:
	return _live.size()

func particle_units() -> int:
	var total: int = 0
	for inst in _live:
		total += int(inst.count)
	return total

func critical_units() -> int:
	var total: int = 0
	for inst in _live:
		if bool(inst.critical):
			total += int(inst.count)
	return total

func clear() -> void:
	_live.clear()

func _remove(inst: Dictionary) -> void:
	var idx: int = _live.find(inst)
	if idx >= 0:
		_live.remove_at(idx)

## First-killable emitter in G9 eviction order (whole emitters, first-killed
## first); never a critical emitter; never the request itself.
func _eviction_candidate(incoming_ptype: String) -> Dictionary:
	for candidate: String in JuiceContracts.eviction_order():
		if candidate == incoming_ptype:
			continue
		for inst in _live:
			if str(inst.ptype) == candidate and not bool(inst.critical):
				return inst
	# why: types outside the eviction table (defensive) evict oldest non-critical
	for inst in _live:
		if not bool(inst.critical):
			return inst
	return {}
