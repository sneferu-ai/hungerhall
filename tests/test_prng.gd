extends RefCounted
## test_prng — PrngSeeder determinism + range mapping.

func test_deterministic_same_seed() -> Dictionary:
	var a: PrngSeeder = PrngSeeder.new(42)
	var b: PrngSeeder = PrngSeeder.new(42)
	for i in range(100):
		if a.next_int() != b.next_int():
			return {"ok": false, "msg": "sequence diverged at step %d" % i}
	return {"ok": true}

func test_zero_seed_nonzero_state() -> Dictionary:
	var p: PrngSeeder = PrngSeeder.new(0)
	if p.next_int() == 0:
		return {"ok": false, "msg": "zero seed produced zero output"}
	return {"ok": true}

func test_range_within_bounds() -> Dictionary:
	var p: PrngSeeder = PrngSeeder.new(123)
	for i in range(1000):
		var v: int = p.next_range(10)
		if v < 0 or v >= 10:
			return {"ok": false, "msg": "next_range(10) returned %d" % v}
	return {"ok": true}

func test_float_in_unit() -> Dictionary:
	var p: PrngSeeder = PrngSeeder.new(999)
	for i in range(1000):
		var f: float = p.next_float()
		if f < 0.0 or f >= 1.0:
			return {"ok": false, "msg": "next_float returned %f" % f}
	return {"ok": true}

func test_different_seeds_different_sequences() -> Dictionary:
	var a: PrngSeeder = PrngSeeder.new(1)
	var b: PrngSeeder = PrngSeeder.new(2)
	var same: int = 0
	for i in range(100):
		if a.next_int() == b.next_int():
			same += 1
	if same > 5:
		return {"ok": false, "msg": "different seeds produced %d/100 identical values" % same}
	return {"ok": true}
