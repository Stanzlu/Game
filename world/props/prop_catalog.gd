class_name PropCatalog
extends RefCounted
## Sprite catalog written by tools/art/make_sprites.py (ADR-017). Per sprite id
## ("<style>/<name>"): texture variants, anchor, collision shape, wind sway, lights, effects.

const PATH := "res://assets/generated/props/catalog.json"

static var _entries: Dictionary = {}
static var _loaded := false


static func entry(id: String) -> Dictionary:
	_ensure_loaded()
	if not _entries.has(id):
		Log.error(Log.Category.CONTENT, "unknown prop sprite", {"sprite": id})
		return {}
	return _entries[id]


static func has(id: String) -> bool:
	_ensure_loaded()
	return _entries.has(id)


static func ids() -> Array:
	_ensure_loaded()
	return _entries.keys()


## Picks a texture variant deterministically from a position, so maps look the same each run.
static func texture_for(data: Dictionary, seed_position: Vector2) -> Texture2D:
	var textures: Array = data.get("textures", [])
	if textures.is_empty():
		return null
	var cell := Vector2i((seed_position / 16.0).floor())
	var index := posmod(cell.x * 7 + cell.y * 13, textures.size())
	return load(str(textures[index])) as Texture2D


static func _ensure_loaded() -> void:
	if _loaded:
		return
	_loaded = true
	var json := JSON.new()
	if json.parse(FileAccess.get_file_as_string(PATH)) != OK or not json.data is Dictionary:
		Log.error(
			Log.Category.CONTENT,
			"prop catalog missing or invalid",
			{"path": PATH, "error": json.get_error_message()}
		)
		return
	_entries = json.data
