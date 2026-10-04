extends Control
## Start menu: animated backdrop (TitleBackground), logo and the main entries: continue,
## new game (Elysia), load, prototypes (each scene of the slice in progress and the
## performance test), settings, quit. User argument `--start=<key>` (SceneRegistry) jumps
## straight into a scene (smoke tests, captures).
##
## Two titles (ADR-030, Game Bible §10 and §56): until a save has crossed into the real
## world, the game pretends to be the classic fantasy RPG "Elysia" (symmetric, gold, the
## Elysia theme). Afterwards it shows REAL over an evening valley, quiet and plain.
## `--title=elysia|real` forces one (captures).
## Debug builds validate all content here, so broken content shows up in every smoke run.

const BUILD_INFO_PATH := "res://core/build_info.cfg"
const AMBIENCE := preload("res://assets/generated/audio/garden_loop.wav")
const REAL_AMBIENCE := preload("res://assets/generated/audio/evening_loop.wav")
const LOGO_ELYSIA := preload("res://assets/generated/title/logo_elysia.png")
const LOGO_REAL := preload("res://assets/generated/title/logo_real.png")
const FADE_SECONDS := 0.4
const SCREEN := Vector2(640, 360)
## Elysia's menu sits centered under the island's plateau; REAL's on the left.
const ELYSIA_MENU_Y := 190.0
const REAL_MENU_AT := Vector2(34, 112)

static var _start_arg_consumed := false
static var _intro_played := false
## Set by "Startbild wechseln" in the prototype menu; -1 = decide from the saves.
static var _forced_title := -1

var list: OptionList
var title_mode := TitleBackground.Mode.ELYSIA
var _continue: Button
var _quit_button: Button
var _save_menu: SaveMenu
var _settings_menu: SettingsMenu
var _prototypes: PrototypeMenu
var _leaving := false

@onready var _background: TitleBackground = $Background
@onready var _logo: TextureRect = %Logo
@onready var _subtitle: Label = %Subtitle
@onready var _menu_panel: PanelContainer = %MenuPanel
@onready var _hint: Label = %Hint
@onready var _build: Label = %Build


func _ready() -> void:
	_hint.text = tr("MENU_CONTROLS_HINT")
	title_mode = choose_title_mode(OS.get_cmdline_user_args())
	_background.build(title_mode)
	_apply_title_mode()
	_build_menus()
	var info := read_build_info()
	_build.text = format_build_line(info)
	_play_intro()
	list.focus_first()
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
	var bench_arg := ""
	for arg in args:
		if arg == "--benchmark" or arg.begins_with("--benchmark="):
			bench_arg = arg
	if not _start_arg_consumed and not bench_arg.is_empty():
		_start_arg_consumed = true
		BenchmarkRunner.start.call_deferred(get_tree(), bench_arg == "--benchmark=quick")
	elif not _start_arg_consumed and "--continue" in args:
		_start_arg_consumed = true
		_continue_latest.call_deferred()
	elif not start.is_empty() and not _start_arg_consumed:
		_start_arg_consumed = true
		open_scene.call_deferred(start, false)


## Starts a scene with a fresh game state (fades out first unless `fade` is off).
func open_scene(key: String, fade := true) -> void:
	if not SceneRegistry.has(key):
		Log.error(Log.Category.BOOT, "unknown start scene", {"key": key})
		return
	if _leaving:
		return
	_leaving = true
	Log.info(Log.Category.BOOT, "open scene", {"key": key})
	if fade:
		ScreenFade.fade_out(FADE_SECONDS)
		await NodeTimer.after(self, FADE_SECONDS)
	WorldState.new_game()
	WorldState.set_ui_mode(SceneRegistry.start_mode(key))
	get_tree().change_scene_to_file(SceneRegistry.path(key))


## Elysia's fake title until any save has reached the real world (or `--title=`).
static func choose_title_mode(args: PackedStringArray) -> TitleBackground.Mode:
	if _forced_title >= 0:
		return _forced_title as TitleBackground.Mode
	for arg in args:
		if arg == "--title=real":
			return TitleBackground.Mode.REAL
		if arg == "--title=elysia":
			return TitleBackground.Mode.ELYSIA
	return (
		TitleBackground.Mode.REAL if SaveSystem.reached_reality() else TitleBackground.Mode.ELYSIA
	)


func _play_title_card() -> void:
	_prototypes.close()
	var card := TitleCard.play(self)
	card.finished.connect(
		func() -> void:
			AudioDirector.play_music("elysia" if _is_elysia() else "valley", 2.0)
			AudioDirector.set_ambience(AMBIENCE if _is_elysia() else REAL_AMBIENCE, -14.0, 2.0)
	)


func _switch_title() -> void:
	_forced_title = (TitleBackground.Mode.REAL if _is_elysia() else TitleBackground.Mode.ELYSIA)
	get_tree().reload_current_scene()


func _is_elysia() -> bool:
	return title_mode == TitleBackground.Mode.ELYSIA


func _sound_set() -> AudioDirectorService.SoundSet:
	return (
		AudioDirectorService.SoundSet.ELYSIA if _is_elysia() else AudioDirectorService.SoundSet.REAL
	)


## Logo, tagline, skin, music and ambience of the chosen title.
func _apply_title_mode() -> void:
	theme = UiSkin.ELYSIA_SKIN if _is_elysia() else UiSkin.REAL_SKIN
	_logo.texture = LOGO_ELYSIA if _is_elysia() else LOGO_REAL
	_logo.size = _logo.texture.get_size()
	if _is_elysia():
		_logo.position = Vector2(roundf((SCREEN.x - _logo.size.x) * 0.5), 2.0)
		_subtitle.text = tr("TITLE_ELYSIA_TAGLINE")
		_subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_subtitle.position = Vector2(0.0, 79.0)
		_subtitle.size = Vector2(SCREEN.x, 10.0)
		AudioDirector.play_music("elysia", 2.0)
		AudioDirector.set_ambience(AMBIENCE, -16.0, 2.0)
	else:
		_logo.position = Vector2(30.0, 22.0)
		_subtitle.text = ""
		AudioDirector.play_music("valley", 3.0)
		AudioDirector.set_ambience(REAL_AMBIENCE, -12.0, 3.0)


func _build_menus() -> void:
	_save_menu = SaveMenu.new()
	_save_menu.name = "SaveMenu"
	_save_menu.follow_mode = false
	_save_menu.sound_set = _sound_set()
	add_child(_save_menu)
	_settings_menu = SettingsMenu.new()
	_settings_menu.name = "SettingsMenu"
	_settings_menu.follow_mode = false
	_settings_menu.sound_set = _sound_set()
	add_child(_settings_menu)
	_prototypes = PrototypeMenu.new()
	_prototypes.name = "PrototypeMenu"
	_prototypes.on_scene = open_scene
	_prototypes.on_benchmark = func() -> void: BenchmarkRunner.start(get_tree())
	_prototypes.on_title_card = _play_title_card
	_prototypes.on_switch_title = _switch_title
	add_child(_prototypes)
	for menu: MenuLayer in [_save_menu, _settings_menu, _prototypes]:
		menu.frame.theme = theme
	list = OptionList.new()
	list.sound_skin = _sound_set()
	list.add_theme_constant_override(&"separation", 0)
	list.custom_minimum_size = Vector2(132, 0)
	_menu_panel.add_child(list)
	_rebuild_list()
	for menu: MenuLayer in [_save_menu, _settings_menu, _prototypes]:
		menu.opened.connect(func() -> void: _menu_panel.hide())
		menu.closed.connect(_on_submenu_closed)
	if BenchmarkRunner.result_pending and not BenchmarkRunner.last_rows.is_empty():
		BenchmarkRunner.result_pending = false
		var result := BenchmarkResult.new()
		result.name = "BenchmarkResult"
		result.follow_mode = false
		add_child(result)
		result.opened.connect(func() -> void: _menu_panel.hide())
		result.closed.connect(_on_submenu_closed)
		result.open.call_deferred()


func _rebuild_list() -> void:
	list.clear_rows()
	_continue = null
	if not SaveSystem.latest_slot().is_empty():
		_continue = list.add_action("MENU_CONTINUE", _continue_latest)
	list.add_action("MENU_NEW_GAME", func() -> void: open_scene("look_elysia"))
	list.add_action("MENU_LOAD", func() -> void: _save_menu.open_mode(SaveMenu.Mode.LOAD))
	list.add_action("MENU_PROTOTYPES", _prototypes.open)
	list.add_action("MENU_SETTINGS", _settings_menu.open)
	_quit_button = list.add_action("MENU_QUIT", _quit)
	list.refresh()
	_menu_panel.reset_size()
	if _is_elysia():
		_menu_panel.position = Vector2(roundf((SCREEN.x - _menu_panel.size.x) * 0.5), ELYSIA_MENU_Y)
	else:
		_menu_panel.position = REAL_MENU_AT


func _on_submenu_closed() -> void:
	_menu_panel.show()
	var index := list.buttons().find(get_viewport().gui_get_focus_owner())
	_rebuild_list()
	list.focus_index(maxi(index, 0))


## Logo drops in (Elysia: with a bounce), the menu fades in; the very first start comes
## out of black.
func _play_intro() -> void:
	var first := not _intro_played
	_intro_played = true
	if first and not ScreenFade.is_covered():
		ScreenFade.fade_out(0.0)
	if ScreenFade.is_covered():
		ScreenFade.fade_in(1.2 if first else 0.6)
	var tween := create_tween().set_parallel()
	_logo.modulate.a = 0.0
	_logo.position.y -= 8.0
	tween.tween_property(_logo, ^"modulate:a", 1.0, 0.6).set_delay(0.3)
	(
		tween
		. tween_property(_logo, ^"position:y", _logo.position.y + 8.0, 0.8)
		. set_delay(0.3)
		. set_trans(Tween.TRANS_BACK if _is_elysia() else Tween.TRANS_SINE)
		. set_ease(Tween.EASE_OUT)
	)
	for node: CanvasItem in [_subtitle, _menu_panel, _hint, _build]:
		node.modulate.a = 0.0
		tween.tween_property(node, ^"modulate:a", 1.0, 0.5).set_delay(0.7)


## Loads the newest readable save ("Fortsetzen", `--continue`).
func _continue_latest() -> void:
	var slot := SaveSystem.latest_slot()
	if slot.is_empty():
		Log.warn(Log.Category.SAVE, "nothing to continue")
		return
	SaveSystem.load_slot(slot)


func _quit() -> void:
	Log.info(Log.Category.BOOT, "quit requested")
	get_tree().quit()


func _validate_content() -> void:
	var problems := ContentValidator.validate_all()
	for problem in problems:
		Log.error(Log.Category.CONTENT, problem)
	Log.info(
		Log.Category.CONTENT,
		"content checked",
		{"problems": problems.size(), "drafts": ContentValidator.drafts().size()}
	)


## Cancel first jumps to "Beenden"; cancel on it quits (no accidental quit).
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("cancel"):
		get_viewport().set_input_as_handled()
		if get_viewport().gui_get_focus_owner() == _quit_button:
			_quit()
		else:
			_quit_button.grab_focus()


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
