class_name SaveService
extends Node
## Autoload "SaveSystem": slots, autosave, atomic writes with backup, loading.
##
## Writing: JSON goes to <slot>.json.tmp, the previous file becomes <slot>.json.bak (only if
## it was readable, so a broken file never replaces a good backup), then the temp file is
## renamed. Saving is refused while something blocks it (dialogue, loading) or while the
## current scene is not saveable (encounters). An autosave requested in such a moment is
## kept and written as soon as saving is possible again.
##
## The current scene provides location and saveability through the group "save_context"
## (methods is_saveable() and save_location() -> {"map": String, "position": Vector2}).

signal saved(slot: String)
signal save_failed(slot: String, error: String)
signal loaded(slot: String)

const AUTOSAVE := "autosave"
const SLOTS: PackedStringArray = ["autosave", "slot_1", "slot_2", "slot_3"]
const MANUAL_SLOTS: PackedStringArray = ["slot_1", "slot_2", "slot_3"]
const CONTEXT_GROUP := &"save_context"

var save_dir := ""
## True from load_slot() until the loaded scene has placed the player.
var loading := false
var _blockers: Dictionary[StringName, bool] = {}
var _pending_autosave := ""
var _arrival: Dictionary = {}


func _ready() -> void:
	if save_dir.is_empty():
		save_dir = RuntimeEnv.user_dir() + "saves"
	WorldState.quest_changed.connect(
		func(quest_id: String, _stage: String) -> void: request_autosave("quest:" + quest_id)
	)
	WorldState.state_replaced.connect(func() -> void: _pending_autosave = "")


## Counts play time while a game scene is running and the tree is not paused.
func _process(delta: float) -> void:
	if _context() != null:
		WorldState.add_playtime(delta)


func path_for(slot: String, backup := false) -> String:
	return save_dir.path_join(slot + (".json.bak" if backup else ".json"))


# --- Blocking --------------------------------------------------------------------------


func block(reason: StringName) -> void:
	_blockers[reason] = true


func unblock(reason: StringName) -> void:
	if _blockers.erase(reason):
		_flush_pending()


func blockers() -> PackedStringArray:
	var names: PackedStringArray = []
	for reason in _blockers:
		names.append(str(reason))
	return names


func can_save() -> bool:
	if not _blockers.is_empty() or loading:
		return false
	var context := _context()
	return context != null and bool(context.call(&"is_saveable"))


func has_pending_autosave() -> bool:
	return not _pending_autosave.is_empty()


func _context() -> Node:
	if not is_inside_tree():
		return null
	var node := get_tree().get_first_node_in_group(CONTEXT_GROUP)
	if node == null or not node.has_method(&"is_saveable") or not node.has_method(&"save_location"):
		return null
	return node


# --- Saving ----------------------------------------------------------------------------


## Writes a slot from the current game. Returns ERR_BUSY while saving is not possible.
func save_slot(slot: String) -> Error:
	if not slot in SLOTS:
		Log.error(Log.Category.SAVE, "unknown slot", {"slot": slot})
		return ERR_INVALID_PARAMETER
	if not can_save():
		Log.info(Log.Category.SAVE, "save refused", {"slot": slot, "blockers": blockers()})
		return ERR_BUSY
	var location: Dictionary = _context().call(&"save_location")
	WorldState.set_location(str(location.get("map", "")), location.get("position", Vector2.ZERO))
	var started := Time.get_ticks_usec()
	var err := write_slot(slot, SaveCodec.encode(WorldState.state))
	if err != OK:
		Log.error(Log.Category.SAVE, "save failed", {"slot": slot, "error": error_string(err)})
		save_failed.emit(slot, error_string(err))
		return err
	if slot == AUTOSAVE:
		_pending_autosave = ""
	Log.info(
		Log.Category.SAVE,
		"saved",
		{
			"slot": slot,
			"map": WorldState.state.player.map,
			"ms": (Time.get_ticks_usec() - started) / 1000.0
		}
	)
	saved.emit(slot)
	return OK


## Autosave at story beats and when entering areas. Deferred while saving is blocked.
func request_autosave(reason: String) -> void:
	if can_save():
		save_slot(AUTOSAVE)
	else:
		_pending_autosave = reason
		Log.debug(
			Log.Category.SAVE, "autosave deferred", {"reason": reason, "blockers": blockers()}
		)


func _flush_pending() -> void:
	if has_pending_autosave() and can_save():
		Log.debug(Log.Category.SAVE, "autosave catch-up", {"reason": _pending_autosave})
		save_slot(AUTOSAVE)


## Atomic write with backup rotation. Creates the save folder if needed.
func write_slot(slot: String, text: String) -> Error:
	var err := DirAccess.make_dir_recursive_absolute(save_dir)
	if err != OK:
		return err
	var path := path_for(slot)
	var tmp := path + ".tmp"
	var file := FileAccess.open(tmp, FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	file.store_string(text)
	file.flush()
	err = file.get_error()
	file.close()
	if err != OK:
		DirAccess.remove_absolute(tmp)
		return err
	if FileAccess.file_exists(path) and _is_readable(path):
		var bak := path_for(slot, true)
		if FileAccess.file_exists(bak):
			DirAccess.remove_absolute(bak)
		err = DirAccess.rename_absolute(path, bak)
		if err != OK:
			return err
	elif FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)
	return DirAccess.rename_absolute(tmp, path)


func _is_readable(path: String) -> bool:
	return _read_file(path).ok


# --- Reading ---------------------------------------------------------------------------


func read_slot(slot: String, backup := false) -> SaveCodec.LoadResult:
	return _read_file(path_for(slot, backup))


func has_backup(slot: String) -> bool:
	return FileAccess.file_exists(path_for(slot, true))


func _read_file(path: String) -> SaveCodec.LoadResult:
	var result := SaveCodec.LoadResult.new()
	if not FileAccess.file_exists(path):
		return result.fail("missing")
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return result.fail("io", error_string(FileAccess.get_open_error()))
	if file.get_length() > SaveCodec.MAX_BYTES:
		return result.fail("too_large")
	result = SaveCodec.decode(file.get_as_text())
	if result.ok and not SceneRegistry.has(result.state.player.map):
		result.fail("unknown_map", result.state.player.map)
	for warning in result.warnings:
		Log.warn(Log.Category.SAVE, "save data repaired", {"path": path, "detail": warning})
	return result


## Short description for slot lists: {"status": "empty"|"ok"|"broken", "saved_at",
## "playtime", "map", "error", "backup"}.
func summary(slot: String) -> Dictionary:
	var info := {
		"status": "empty",
		"saved_at": "",
		"playtime": 0.0,
		"map": "",
		"error": "",
		"backup": has_backup(slot),
	}
	if not FileAccess.file_exists(path_for(slot)):
		return info
	var result := read_slot(slot)
	if not result.ok:
		info["status"] = "broken"
		info["error"] = result.error
		return info
	info["status"] = "ok"
	info["saved_at"] = result.saved_at
	info["playtime"] = result.state.playtime_seconds
	info["map"] = result.state.player.map
	return info


## The most recently written readable slot, or "".
func latest_slot() -> String:
	var best := ""
	var best_time := ""
	for slot in SLOTS:
		var info := summary(slot)
		if info["status"] == "ok" and str(info["saved_at"]) > best_time:
			best = slot
			best_time = info["saved_at"]
	return best


# --- Loading ---------------------------------------------------------------------------


## Replaces the world state and changes to the saved scene. On failure nothing changes.
func load_slot(slot: String, backup := false) -> Error:
	if loading:
		return ERR_BUSY
	var result := read_slot(slot, backup)
	if not result.ok:
		Log.warn(
			Log.Category.SAVE,
			"load failed",
			{"slot": slot, "backup": backup, "error": result.error, "detail": result.detail}
		)
		return ERR_FILE_NOT_FOUND if result.error == "missing" else ERR_FILE_CORRUPT
	loading = true
	WorldState.replace_state(result.state)
	_arrival = {"map": result.state.player.map, "position": result.state.player.position}
	get_tree().paused = false
	var err := get_tree().change_scene_to_file(SceneRegistry.path(result.state.player.map))
	if err != OK:
		loading = false
		_arrival = {}
		Log.error(Log.Category.SAVE, "scene change failed", {"slot": slot})
		return err
	Log.info(Log.Category.SAVE, "loaded", {"slot": slot, "backup": backup})
	loaded.emit(slot)
	return OK


## Called by a scene once it is built. Returns the saved position if the scene was entered
## by loading a save (then no autosave happens); otherwise autosaves for entering the area.
func scene_entered(map: String) -> Dictionary:
	var arrival := _arrival
	_arrival = {}
	loading = false
	if not arrival.is_empty() and arrival.get("map") == map:
		_flush_pending()
		return arrival
	request_autosave("enter:" + map)
	return {}
