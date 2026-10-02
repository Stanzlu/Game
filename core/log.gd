extends Node
## Structured development logging (autoload "Log").
##
## Usage: Log.info(Log.Category.SAVE, "slot written", {"slot": 1})
## Debug builds log everything from DEBUG upwards; release builds only WARN and ERROR.
## ERROR goes through push_error() so it is never silent and fails tools/check.sh smoke runs.

enum Level { DEBUG, INFO, WARN, ERROR }
enum Category { BOOT, SAVE, QUEST, DIALOGUE, WORLD_STATE, INTERACTION, AUDIO, INPUT, UI, CONTENT }

var min_level: Level = Level.DEBUG if OS.is_debug_build() else Level.WARN
var muted_categories: Array[Category] = []


func debug(category: Category, message: String, data: Dictionary = {}) -> void:
	_write(Level.DEBUG, category, message, data)


func info(category: Category, message: String, data: Dictionary = {}) -> void:
	_write(Level.INFO, category, message, data)


func warn(category: Category, message: String, data: Dictionary = {}) -> void:
	_write(Level.WARN, category, message, data)


func error(category: Category, message: String, data: Dictionary = {}) -> void:
	_write(Level.ERROR, category, message, data)


## Formats a log line without printing it. Exposed for tests.
func format_line(
	level: Level, category: Category, message: String, data: Dictionary = {}
) -> String:
	var seconds := Time.get_ticks_msec() / 1000.0
	var line := (
		"[%8.3fs] %-5s %s: %s" % [seconds, Level.keys()[level], Category.keys()[category], message]
	)
	if not data.is_empty():
		line += " " + JSON.stringify(data)
	return line


func _write(level: Level, category: Category, message: String, data: Dictionary) -> void:
	if level < min_level or category in muted_categories:
		return
	var line := format_line(level, category, message, data)
	match level:
		Level.ERROR:
			push_error(line)
		Level.WARN:
			push_warning(line)
		_:
			print(line)
