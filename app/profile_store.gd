class_name ProfileStore
extends Node
## Profile domain store (G6 §2 app/profile_store.gd): classes_cleared +
## ng_plus_unlocked. Owns the domain semantics; file I/O goes through the
## SaveStore, shapes through the pure SaveCodec. Child of Main in main.tscn.

var save_store: SaveStore = null

func set_save_store(s: SaveStore) -> void:
	save_store = s

func read_profile() -> Dictionary:
	return _store().read_profile()

func write_profile(data: Dictionary) -> bool:
	return _store().write_profile(data)

## why: G6 §3.1 campaign-clear record — the clearing class joins the ledger
## exactly once; a failed write is surfaced so the SSM can log it.
func record_campaign_clear(hero_class_key: String) -> bool:
	var profile: Dictionary = _store().read_profile()
	var cleared: Array = profile.get("classes_cleared", [])
	if not cleared.has(hero_class_key):
		cleared.append(hero_class_key)
	return _store().write_profile({
		"classes_cleared": cleared,
		"ng_plus_unlocked": bool(profile.get("ng_plus_unlocked", false))
	})

func classes_cleared() -> Array:
	return read_profile().get("classes_cleared", [])

func ng_plus_unlocked() -> bool:
	return bool(read_profile().get("ng_plus_unlocked", false))

func _store() -> SaveStore:
	if save_store == null:
		# why: standalone tests instantiate ProfileStore without a composition
		# root; a private SaveStore keeps the I/O in app/ either way
		save_store = SaveStore.new()
	return save_store
