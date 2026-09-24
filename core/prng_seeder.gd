class_name PrngSeeder
extends RefCounted
## Deterministic integer-seeded PRNG (xorshift64*). Pure GDScript, no engine
## RNG dependency: identical sequences on every platform and run for a given
## seed. Zero is mapped to a nonzero state.

var _state: int = 0

func _init(seed_value: int = 1) -> void:
	reseed(seed_value)

func reseed(seed_value: int) -> void:
	# why: xorshift64* requires nonzero state; fold negatives into 63 bits.
	var s: int = (seed_value & 0x7FFFFFFFFFFFFFFF)
	if s == 0:
		s = 2654435761  # why: Knuth's 32-bit golden ratio fractional, fits in 63 bits
	_state = s

func next_int() -> int:
	_state ^= (_state << 7) & 0x7FFFFFFFFFFFFFFF
	_state ^= _state >> 9
	_state = _state & 0x7FFFFFFFFFFFFFFF
	if _state == 0:
		_state = 2654435761  # why: Knuth's golden ratio constant
	# why: multiply-xorshift finalizer spreads low bits for range mapping.
	var z: int = (_state * 25214903917) & 0x7FFFFFFFFFFFFFFF
	return z

func next_range(n: int) -> int:
	if n <= 1:
		return 0
	return next_int() % n

func next_float() -> float:
	return float(next_int() % 1000000) / 1000000.0

func next_range_f(min_v: float, max_v: float) -> float:
	return min_v + next_float() * (max_v - min_v)
