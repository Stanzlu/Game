class_name SceneTravel
extends RefCounted
## Going from one place to another (doors, map exits): fade out, change scene and put the
## player on the target's spawn marker "spawn_<name>". The arrival is applied before the
## scene autosaves, so a save made on entering already stands at the door.

const FADE_SECONDS := 0.45

## Marker name the next scene puts the player on ("" = the map's player_spawn).
static var pending_spawn := ""
static var _travelling := false


static func is_travelling() -> bool:
	return _travelling


## Leaves `from` for scene `target` (SceneRegistry key), arriving at marker `spawn`.
static func go(from: Node, target: String, spawn := "", sound := "") -> void:
	if _travelling:
		return
	if not SceneRegistry.has(target):
		Log.error(Log.Category.CONTENT, "travel target unknown", {"target": target})
		return
	_travelling = true
	var scene := from.get_tree().get_first_node_in_group(SaveService.CONTEXT_GROUP) as GameScene
	if scene != null and scene.player != null:
		scene.player.lock(&"travel")
	if not sound.is_empty():
		AudioDirector.sfx(sound)
	Log.info(Log.Category.WORLD_STATE, "travel", {"target": target, "spawn": spawn})
	ScreenFade.fade_out(FADE_SECONDS)
	await NodeTimer.after(from, FADE_SECONDS)
	pending_spawn = spawn
	_travelling = false
	from.get_tree().change_scene_to_file(SceneRegistry.path(target))


## The marker cell for the pending spawn in `map`, or null. Clears the pending spawn.
static func take_spawn(map: MapView) -> Variant:
	var name := pending_spawn
	pending_spawn = ""
	if name.is_empty() or map == null or map.data == null:
		return null
	var found := map.data.find_marker("spawn_" + name)
	if found.is_empty():
		Log.error(Log.Category.CONTENT, "spawn marker missing", {"marker": "spawn_" + name})
		return null
	return map.cell_to_world(found[0]["cell"])
