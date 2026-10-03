extends GutTest
## SaveSystem on disk (test profile only): atomic writes, backups, refusing and deferring
## saves while blocked, reading broken files without crashing.

const DIR := "user://profiles/test/saves_unit"

var saves: SaveService
var context: FakeContext


class FakeContext:
	extends Node
	var saveable := true
	var map := "sandbox"

	func is_saveable() -> bool:
		return saveable

	func save_location() -> Dictionary:
		return {"map": map, "position": Vector2(40, 24)}


func before_each() -> void:
	_clear_dir()
	WorldState.new_game()
	saves = SaveService.new()
	saves.save_dir = DIR
	add_child_autofree(saves)
	context = FakeContext.new()
	context.add_to_group(SaveService.CONTEXT_GROUP)
	add_child_autofree(context)


func after_all() -> void:
	_clear_dir()
	WorldState.new_game()


func _clear_dir() -> void:
	var dir := DirAccess.open(DIR)
	if dir == null:
		return
	for file_name in dir.get_files():
		dir.remove(file_name)


func _write_raw(slot: String, text: String, backup := false) -> void:
	DirAccess.make_dir_recursive_absolute(DIR)
	var file := FileAccess.open(saves.path_for(slot, backup), FileAccess.WRITE)
	file.store_string(text)
	file.close()


func test_save_writes_a_readable_slot_with_location() -> void:
	WorldState.set_flag("valley.saved_once")
	assert_eq(saves.save_slot("slot_1"), OK)
	assert_true(FileAccess.file_exists(DIR + "/slot_1.json"))
	assert_false(FileAccess.file_exists(DIR + "/slot_1.json.tmp"), "temp file is renamed")
	var result := saves.read_slot("slot_1")
	assert_true(result.ok, result.error)
	assert_true(result.state.flags.has("valley.saved_once"))
	assert_eq(result.state.player.map, "sandbox")
	assert_eq(result.state.player.position, Vector2(40, 24))
	var info := saves.summary("slot_1")
	assert_eq(info["status"], "ok")
	assert_eq(info["map"], "sandbox")
	assert_eq(saves.summary("slot_2")["status"], "empty")


func test_second_save_keeps_the_previous_one_as_backup() -> void:
	WorldState.set_flag("valley.first")
	saves.save_slot("slot_1")
	WorldState.set_flag("valley.second")
	saves.save_slot("slot_1")
	assert_true(saves.has_backup("slot_1"))
	var backup := saves.read_slot("slot_1", true)
	assert_true(backup.state.flags.has("valley.first"))
	assert_false(backup.state.flags.has("valley.second"))
	assert_true(saves.read_slot("slot_1").state.flags.has("valley.second"))


func test_broken_file_never_replaces_a_good_backup() -> void:
	WorldState.set_flag("valley.good")
	saves.save_slot("slot_2")
	saves.save_slot("slot_2")
	_write_raw("slot_2", "{ not json")
	assert_eq(saves.summary("slot_2")["status"], "broken")
	assert_eq(saves.read_slot("slot_2").error, "parse")
	saves.save_slot("slot_2")
	assert_true(saves.read_slot("slot_2", true).ok, "backup is still the good file")


func test_saving_is_refused_while_blocked_and_autosave_waits() -> void:
	saves.block(&"dialogue")
	assert_false(saves.can_save())
	assert_eq(saves.save_slot("slot_1"), ERR_BUSY)
	saves.request_autosave("quest:test")
	assert_true(saves.has_pending_autosave())
	assert_false(FileAccess.file_exists(saves.path_for("autosave")))
	saves.unblock(&"dialogue")
	assert_true(FileAccess.file_exists(saves.path_for("autosave")), "written after unblock")
	assert_false(saves.has_pending_autosave())


func test_unsaveable_scene_defers_autosave_until_next_area() -> void:
	context.saveable = false
	saves.request_autosave("quest:test")
	assert_true(saves.has_pending_autosave())
	assert_eq(saves.save_slot("slot_3"), ERR_BUSY)
	context.saveable = true
	saves.scene_entered("sandbox")
	assert_true(saves.read_slot("autosave").ok)


func test_scene_entered_after_load_returns_saved_position() -> void:
	saves._arrival = {"map": "sandbox", "position": Vector2(7, 9)}
	saves.loading = true
	var arrival := saves.scene_entered("sandbox")
	assert_eq(arrival.get("position"), Vector2(7, 9))
	assert_false(saves.loading)
	assert_false(FileAccess.file_exists(saves.path_for("autosave")), "no autosave on load")


func test_reading_missing_broken_and_foreign_files() -> void:
	assert_eq(saves.read_slot("slot_3").error, "missing")
	_write_raw("slot_3", "")
	assert_eq(saves.read_slot("slot_3").error, "parse")
	var state := GameState.new()
	state.player.map = "atlantis"
	_write_raw("slot_3", SaveCodec.encode(state))
	assert_eq(saves.read_slot("slot_3").error, "unknown_map")
	assert_eq(saves.load_slot("slot_3"), ERR_FILE_CORRUPT, "load refuses and changes nothing")
	assert_push_warning("load failed")
	assert_eq(saves.save_slot("slot_9"), ERR_INVALID_PARAMETER)
	assert_push_error("unknown slot")


func test_debug_slot_is_separate_from_player_slots() -> void:
	assert_eq(saves.save_slot(SaveService.DEBUG_SLOT), OK)
	assert_true(saves.read_slot(SaveService.DEBUG_SLOT).ok)
	assert_eq(saves.latest_slot(), "", "continue never picks the debug slot")


func test_latest_slot_is_the_newest_readable_one() -> void:
	var older := GameState.new()
	older.player.map = "sandbox"
	_write_raw("slot_1", SaveCodec.encode(older, "2026-10-01T10:00:00Z"))
	_write_raw("slot_2", SaveCodec.encode(older, "2026-10-02T10:00:00Z"))
	_write_raw("slot_3", "broken")
	assert_eq(saves.latest_slot(), "slot_2")
