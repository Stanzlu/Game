extends GutTest


func test_format_line_contains_level_category_and_message() -> void:
	var line: String = Log.format_line(Log.Level.INFO, Log.Category.SAVE, "slot written")
	assert_string_contains(line, "INFO")
	assert_string_contains(line, "SAVE: slot written")


func test_format_line_appends_data_as_json() -> void:
	var line: String = Log.format_line(Log.Level.WARN, Log.Category.QUEST, "stage", {"id": "q1"})
	assert_string_contains(line, '{"id":"q1"}')


func test_debug_builds_log_from_debug_level() -> void:
	if OS.is_debug_build():
		assert_eq(Log.min_level, Log.Level.DEBUG)
	else:
		assert_eq(Log.min_level, Log.Level.WARN)


## The playtest measures the minutes of every beat from the log of a release build, which
## otherwise only writes warnings and errors.
func test_record_lines_are_written_in_release_builds_too() -> void:
	var before: Log.Level = Log.min_level
	Log.min_level = Log.Level.WARN
	assert_false(Log.passes(Log.Level.INFO, Log.Category.WORLD_STATE), "info is filtered")
	assert_true(Log.passes(Log.Level.INFO, Log.Category.WORLD_STATE, true), "record is not")
	Log.min_level = before


func test_muted_categories_mute_records_too() -> void:
	Log.muted_categories.append(Log.Category.AUDIO)
	assert_false(Log.passes(Log.Level.INFO, Log.Category.AUDIO, true))
	Log.muted_categories.erase(Log.Category.AUDIO)
