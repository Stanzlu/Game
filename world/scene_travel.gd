class_name SceneTravel
extends RefCounted
## Going from one place to another (doors, map exits): fade out, change scene and put the
## player on the target's spawn marker "spawn_<name>". The arrival is applied before the
## scene autosaves, so a save made on entering already stands at the door.

const FADE_SECONDS := 0.45

## Marker name the next scene puts the player on ("" = the map's player_spawn).
static var pending_spawn := ""
## Seconds the next scene takes to fade in (< 0 = its default). The rift arrives slowly.
static var arrival_fade := -1.0
static var _travelling := false
## Tests: travel only records where it would go and stays in the scene.
static var stay := false
static var last_target := ""


static func is_travelling() -> bool:
	return _travelling


## Leaves `from` for scene `target` (SceneRegistry key), arriving at marker `spawn`.
static func go(from: Node, target: String, spawn := "", sound := "") -> void:
	if _travelling:
		return
	if not SceneRegistry.has(target):
		Log.error(Log.Category.CONTENT, "travel target unknown", {"target": target})
		return
	last_target = target
	if stay:
		Log.info(Log.Category.WORLD_STATE, "travel (stay)", {"target": target, "spawn": spawn})
		return
	_travelling = true
	# untyped: the pause menu asks is_travelling(), and GameScene preloads the pause menu
	var scene := from.get_tree().get_first_node_in_group(SaveService.CONTEXT_GROUP)
	var player: Node = scene.get(&"player") if scene != null else null
	if player != null:
		player.call(&"lock", &"travel")
	if not sound.is_empty():
		AudioDirector.sfx(sound)
	Log.info(Log.Category.WORLD_STATE, "travel", {"target": target, "spawn": spawn})
	ScreenFade.fade_out(FADE_SECONDS)
	await NodeTimer.after(from, FADE_SECONDS)
	pending_spawn = spawn
	_travelling = false
	from.get_tree().change_scene_to_file(SceneRegistry.path(target))


## Fade-in time for a scene that just opened: a requested one, else short after a door and
## long for a fresh start. Clears the request; any travel is over once a scene opens.
static func take_fade() -> float:
	_travelling = false
	var seconds := arrival_fade
	arrival_fade = -1.0
	if seconds >= 0.0:
		return seconds
	return 2.0 if pending_spawn.is_empty() else 0.5


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
