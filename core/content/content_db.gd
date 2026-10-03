class_name ContentDB
extends RefCounted
## Read-only access to typed content (quests, items), loaded once from content/.
## Uses ResourceLoader.list_directory(), which also works in exported builds.
## Tests may swap in their own definitions with use_definitions() and restore with reload().

const QUEST_DIR := "res://content/quests"
const ITEM_DIR := "res://content/items"

static var _quests: Dictionary[String, QuestDef] = {}
static var _items: Dictionary[String, ItemDef] = {}
static var _loaded := false


static func quest(id: String) -> QuestDef:
	_ensure_loaded()
	return _quests.get(id)


static func item(id: String) -> ItemDef:
	_ensure_loaded()
	return _items.get(id)


static func has_quest(id: String) -> bool:
	_ensure_loaded()
	return _quests.has(id)


static func has_item(id: String) -> bool:
	_ensure_loaded()
	return _items.has(id)


static func quest_ids() -> PackedStringArray:
	_ensure_loaded()
	return PackedStringArray(_quests.keys())


static func item_ids() -> PackedStringArray:
	_ensure_loaded()
	return PackedStringArray(_items.keys())


static func quests() -> Array[QuestDef]:
	_ensure_loaded()
	return _quests.values()


static func items() -> Array[ItemDef]:
	_ensure_loaded()
	return _items.values()


## Replaces the loaded content (tests).
static func use_definitions(quest_defs: Array[QuestDef], item_defs: Array[ItemDef]) -> void:
	_quests.clear()
	_items.clear()
	for q in quest_defs:
		_quests[q.id] = q
	for i in item_defs:
		_items[i.id] = i
	_loaded = true


## Loads content/ again (also restores real content after use_definitions()).
static func reload() -> void:
	_loaded = false
	_ensure_loaded()


## Paths of all .tres files in a content folder, sorted.
static func resource_paths(dir_path: String) -> PackedStringArray:
	var found: PackedStringArray = []
	for entry in ResourceLoader.list_directory(dir_path):
		if entry.get_extension() == "tres":
			found.append(dir_path.path_join(entry))
	found.sort()
	return found


static func _ensure_loaded() -> void:
	if _loaded:
		return
	_loaded = true
	_quests.clear()
	_items.clear()
	for path in resource_paths(QUEST_DIR):
		var q := load(path) as QuestDef
		if q == null or q.id.is_empty() or _quests.has(q.id):
			Log.error(Log.Category.CONTENT, "invalid or duplicate quest", {"path": path})
			continue
		_quests[q.id] = q
	for path in resource_paths(ITEM_DIR):
		var i := load(path) as ItemDef
		if i == null or i.id.is_empty() or _items.has(i.id):
			Log.error(Log.Category.CONTENT, "invalid or duplicate item", {"path": path})
			continue
		_items[i.id] = i
	Log.debug(
		Log.Category.CONTENT, "content loaded", {"quests": _quests.size(), "items": _items.size()}
	)
