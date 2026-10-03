extends Control
## Start menu of the prototype: choose the movement sandbox or the Antreiber prototype.
## User argument `--start=sandbox|antreiber` jumps straight into a scene (smoke tests,
## captures). The real title flow comes with the vertical slice.

const BUILD_INFO_PATH := "res://core/build_info.cfg"
const SCENES := {
	"sandbox": "res://world/levels/sandbox.tscn",
	"antreiber": "res://encounters/antreiber/antreiber_encounter.tscn",
}

static var _start_arg_consumed := false

@onready var _title: Label = %Title
@onready var _subtitle: Label = %Subtitle
@onready var _hint: Label = %Hint
@onready var _build: Label = %Build
@onready var _sandbox: Button = %Sandbox
@onready var _antreiber: Button = %Antreiber
@onready var _quit: Button = %Quit


func _ready() -> void:
	_title.text = tr("BOOT_TITLE")
	_subtitle.text = tr("BOOT_SUBTITLE")
	_hint.text = tr("MENU_CONTROLS_HINT")
	_sandbox.text = tr("MENU_SANDBOX")
	_antreiber.text = tr("MENU_ANTREIBER")
	_quit.text = tr("MENU_QUIT")
	_sandbox.pressed.connect(func() -> void: open_scene("sandbox"))
	_antreiber.pressed.connect(func() -> void: open_scene("antreiber"))
	_quit.pressed.connect(func() -> void: get_tree().quit())
	var info := read_build_info()
	_build.text = format_build_line(info)
	_sandbox.grab_focus()
	Log.info(Log.Category.BOOT, "boot screen ready", info)
	if not _start_arg_consumed:
		SessionOptions.apply_args(OS.get_cmdline_user_args())
		if OS.is_debug_build():
			load("res://tools/autopilot/autopilot.gd").call(&"start_if_requested", get_tree())
	var start := start_argument(OS.get_cmdline_user_args())
	if not start.is_empty() and not _start_arg_consumed:
		_start_arg_consumed = true
		open_scene.call_deferred(start)


func open_scene(key: String) -> void:
	if not SCENES.has(key):
		Log.error(Log.Category.BOOT, "unknown start scene", {"key": key})
		return
	Log.info(Log.Category.BOOT, "open scene", {"key": key})
	get_tree().change_scene_to_file(SCENES[key])


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("cancel"):
		get_viewport().set_input_as_handled()
		Log.info(Log.Category.BOOT, "quit requested")
		get_tree().quit()


## Returns the value of `--start=<key>` or an empty string.
static func start_argument(args: PackedStringArray) -> String:
	for arg in args:
		if arg.begins_with("--start="):
			return arg.trim_prefix("--start=")
	return ""


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
