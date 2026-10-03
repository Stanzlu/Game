extends Control
## Start menu of the prototype: continue, load, settings, then the prototype scenes
## (each starts a new game state). User argument `--start=<key>` (SceneRegistry) jumps
## straight into a scene (smoke tests, captures). The real title flow comes with the slice.
## Debug builds validate all content here, so broken content shows up in every smoke run.

const BUILD_INFO_PATH := "res://core/build_info.cfg"

static var _start_arg_consumed := false

var _continue: Button
var _load: Button
var _settings_button: Button
var _save_menu: SaveMenu
var _settings_menu: SettingsMenu

@onready var _title: Label = %Title
@onready var _subtitle: Label = %Subtitle
@onready var _hint: Label = %Hint
@onready var _build: Label = %Build
@onready var _sandbox: Button = %Sandbox
@onready var _antreiber: Button = %Antreiber
@onready var _look_elysia: Button = %LookElysia
@onready var _look_tal: Button = %LookTal
@onready var _look_wald: Button = %LookWald
@onready var _quit: Button = %Quit
@onready var _menu: VBoxContainer = %Sandbox.get_parent()


func _ready() -> void:
	_title.text = tr("BOOT_TITLE")
	_subtitle.text = tr("BOOT_SUBTITLE")
	_hint.text = tr("MENU_CONTROLS_HINT")
	_sandbox.text = tr("MENU_SANDBOX")
	_antreiber.text = tr("MENU_ANTREIBER")
	_look_elysia.text = tr("MENU_LOOK_ELYSIA")
	_look_tal.text = tr("MENU_LOOK_TAL")
	_look_wald.text = tr("MENU_LOOK_WALD")
	_quit.text = tr("MENU_QUIT")
	_sandbox.pressed.connect(func() -> void: open_scene("sandbox"))
	_antreiber.pressed.connect(func() -> void: open_scene("antreiber"))
	_look_elysia.pressed.connect(func() -> void: open_scene("look_elysia"))
	_look_tal.pressed.connect(func() -> void: open_scene("look_tal"))
	_look_wald.pressed.connect(func() -> void: open_scene("look_wald"))
	_quit.pressed.connect(func() -> void: get_tree().quit())
	_add_save_entries()
	var info := read_build_info()
	_build.text = format_build_line(info)
	(_continue if _continue.visible else _sandbox).grab_focus()
	Log.info(Log.Category.BOOT, "boot screen ready", info)
	if not _start_arg_consumed:
		Log.info(
			Log.Category.CONTENT,
			"content available",
			{"quests": ContentDB.quest_ids().size(), "items": ContentDB.item_ids().size()}
		)
		if OS.is_debug_build():
			_validate_content()
			load("res://tools/autopilot/autopilot.gd").call(&"start_if_requested", get_tree())
	var args := OS.get_cmdline_user_args()
	var start := start_argument(args)
	if not _start_arg_consumed and "--continue" in args:
		_start_arg_consumed = true
		_continue_latest.call_deferred()
	elif not start.is_empty() and not _start_arg_consumed:
		_start_arg_consumed = true
		open_scene.call_deferred(start)


## Starts a prototype scene with a fresh game state.
func open_scene(key: String) -> void:
	if not SceneRegistry.has(key):
		Log.error(Log.Category.BOOT, "unknown start scene", {"key": key})
		return
	Log.info(Log.Category.BOOT, "open scene", {"key": key})
	WorldState.new_game()
	get_tree().change_scene_to_file(SceneRegistry.path(key))


func _add_save_entries() -> void:
	_save_menu = SaveMenu.new()
	_save_menu.name = "SaveMenu"
	add_child(_save_menu)
	_settings_menu = SettingsMenu.new()
	_settings_menu.name = "SettingsMenu"
	add_child(_settings_menu)
	_continue = _entry("MENU_CONTINUE", 0)
	_continue.pressed.connect(_continue_latest)
	_continue.visible = not SaveSystem.latest_slot().is_empty()
	_load = _entry("MENU_LOAD", 1)
	_load.pressed.connect(func() -> void: _save_menu.open_mode(SaveMenu.Mode.LOAD))
	_settings_button = _entry("MENU_SETTINGS", 2)
	_settings_button.pressed.connect(_settings_menu.open)
	_save_menu.closed.connect(
		func() -> void: _continue.visible = not SaveSystem.latest_slot().is_empty()
	)


## Loads the newest readable save ("Fortsetzen", `--continue`).
func _continue_latest() -> void:
	var slot := SaveSystem.latest_slot()
	if slot.is_empty():
		Log.warn(Log.Category.SAVE, "nothing to continue")
		return
	SaveSystem.load_slot(slot)


func _entry(key: String, index: int) -> Button:
	var button := Button.new()
	button.theme_type_variation = &"MenuEntry"
	button.text = tr(key)
	_menu.add_child(button)
	_menu.move_child(button, index)
	return button


func _validate_content() -> void:
	var problems := ContentValidator.validate_all()
	for problem in problems:
		Log.error(Log.Category.CONTENT, problem)
	Log.info(
		Log.Category.CONTENT,
		"content checked",
		{"problems": problems.size(), "drafts": ContentValidator.drafts().size()}
	)


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
