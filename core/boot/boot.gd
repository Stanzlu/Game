extends Control
## Phase-0 boot screen: proves rendering, font, localization, input and build stamping.
## Replaced by the real title flow in a later phase.

const BUILD_INFO_PATH := "res://core/build_info.cfg"

@onready var _title: Label = %Title
@onready var _subtitle: Label = %Subtitle
@onready var _hint: Label = %Hint
@onready var _build: Label = %Build


func _ready() -> void:
	_title.text = tr("BOOT_TITLE")
	_subtitle.text = tr("BOOT_SUBTITLE")
	_hint.text = tr("BOOT_HINT_QUIT")
	var info := read_build_info()
	_build.text = format_build_line(info)
	Log.info(Log.Category.BOOT, "boot screen ready", info)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("cancel"):
		get_viewport().set_input_as_handled()
		Log.info(Log.Category.BOOT, "quit requested")
		get_tree().quit()


## "Version 0.0.1 · abc1234 · 2026-10-02"; empty parts are left out.
func format_build_line(info: Dictionary) -> String:
	var parts: PackedStringArray = [tr("BOOT_VERSION") % info["version"], str(info["commit"])]
	if not str(info["date"]).is_empty():
		parts.append(str(info["date"]))
	return " · ".join(parts)


## Returns version, commit and date. Exported builds carry build_info.cfg (see tools/export.sh).
static func read_build_info() -> Dictionary:
	var info := {
		"version": str(ProjectSettings.get_setting("application/config/version", "0.0.0")),
		"commit": "dev",
		"date": "",
	}
	var cfg := ConfigFile.new()
	if cfg.load(BUILD_INFO_PATH) == OK:
		info["commit"] = str(cfg.get_value("build", "commit", "unknown"))
		info["date"] = str(cfg.get_value("build", "date", ""))
	return info
