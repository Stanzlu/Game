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
