class_name SettingsStore
extends Node
## Settings domain store (G6 §2 app/settings_store.gd): the one flat settings
## record (LAR-4). Default-fill and shape come from the pure SaveCodec; file
## I/O goes through the SaveStore. Child of Main in main.tscn.

var save_store: SaveStore = null

func set_save_store(s: SaveStore) -> void:
	save_store = s

func read_settings() -> Dictionary:
	return _store().read_settings()

func write_settings(data: Dictionary) -> bool:
	return _store().write_settings(data)

## why: settings-only reset (reset_warn modal) — campaign/profile/scores keep
func reset_to_defaults() -> bool:
	return _store().write_settings(SaveCodec.default_settings())

func _store() -> SaveStore:
	if save_store == null:
		save_store = SaveStore.new()
	return save_store
