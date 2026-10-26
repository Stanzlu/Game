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
const REAL_AMBIENCE := preload("res://content/audio/tal_abend.tres")
const LOGO_ELYSIA := preload("res://assets/generated/title/logo_elysia.png")
const LOGO_REAL := preload("res://assets/generated/title/logo_real.png")
const FADE_SECONDS := 0.4
const SCREEN := Vector2(640, 360)
## Elysia's menu sits centered under the island's plateau (below the trunk, so the basin and
## the pillars stay free when the menu is short); REAL's on the left.
const ELYSIA_MENU_Y := 232.0
const REAL_MENU_AT := Vector2(34, 112)
## Free space between the menu and the footer line.
const MENU_GAP := 24.0

static var _start_arg_consumed := false
## Content check and autopilot belong to the first start menu of a run, not every return.
static var _first_boot_done := false
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
var _credits: CreditsMenu
var _name_entry: NameEntry
var _confirm: ConfirmMenu
## Hero name chosen for the next new game (applied after WorldState.new_game()).
var _new_name := ""
var _leaving := false

@onready var _background: TitleBackground = $Background
@onready var _logo: TextureRect = %Logo
@onready var _subtitle: Label = %Subtitle
@onready var _menu_panel: PanelContainer = %MenuPanel
@onready var _footer: PanelContainer = %Footer
@onready var _hint: Label = %Hint
@onready var _build: Label = %Build


func _ready() -> void:
	_hint.text = controls_hint()
	InputDevice.device_changed.connect(func(_kind: int) -> void: _hint.text = controls_hint())
	# the footer names the keys: rebinding them (Einstellungen > Tastenbelegung) changes it
	InputDevice.labels_changed.connect(func() -> void: _hint.text = controls_hint())
	title_mode = choose_title_mode(OS.get_cmdline_user_args())
	_background.build(title_mode)
	_apply_title_mode()
	_build_menus()
	# larger letters make the footer and the menu taller: the menu moves up with them
	Settings.changed.connect(
		func(key: String) -> void:
			if key == "text.large":
				_layout_soon()
	)
	var info := read_build_info()
	_build.text = format_build_line(info)
	_layout_soon()
	_play_intro()
	list.focus_first()
	# record: a tester's log names the build it came from
	Log.record(Log.Category.BOOT, "boot screen ready", info)
	if not _first_boot_done:
		_first_boot_done = true
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
	if not _new_name.is_empty():
		WorldState.set_player_name(_new_name)
		_new_name = ""
	get_tree().change_scene_to_file(SceneRegistry.path(key))


## The vertical slice from the beginning: Elysia, with the name the player chose.
func _start_new_game(hero_name: String) -> void:
	_new_name = hero_name
	open_scene("elysia")


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


## Logo, tagline, skin, music and ambience of the chosen title. The window title keeps the
## disguise too: "Elysia" until a save reached the real world, then the true title.
func _apply_title_mode() -> void:
	theme = UiSkin.ELYSIA_SKIN if _is_elysia() else UiSkin.REAL_SKIN
	if DisplayServer.get_name() != "headless":
		get_window().title = tr("TITLE_ELYSIA" if _is_elysia() else "GAME_TITLE")
	_logo.texture = LOGO_ELYSIA if _is_elysia() else LOGO_REAL
	_logo.size = _logo.texture.get_size()
	if _is_elysia():
		_logo.position = Vector2(roundf((SCREEN.x - _logo.size.x) * 0.5), 2.0)
		# the tagline sits right under the logo in the gold of its title, readable at any size
		_menu_panel.theme_type_variation = &"MenuPanel"
		# the frame is a little see-through: the basin behind it would ghost through the rows
		var backing := ColorRect.new()
		backing.color = Color(0.11, 0.08, 0.2)
		backing.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_menu_panel.add_child(backing)
		_subtitle.text = tr("TITLE_ELYSIA_TAGLINE")
		_subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_subtitle.position = Vector2(0.0, 68.0)
		_subtitle.size = Vector2(SCREEN.x, 28.0)
		AudioDirector.play_music("elysia", 2.0)
		AudioDirector.set_ambience(AMBIENCE, -16.0, 2.0)
	else:
		_logo.position = Vector2(30.0, 22.0)
		# a finished game (the newest save has reached Chapter.LAST) says so quietly under the logo
		# (it left the end card, Game Bible §56)
		_subtitle.text = tr("END_OF_SLICE") if SaveSystem.slice_finished() else ""
		_subtitle.theme_type_variation = &"MutedLabel"
		_subtitle.add_theme_color_override(&"font_color", Color(0.96, 0.93, 0.87))
		_subtitle.add_theme_color_override(&"font_outline_color", Color(0.16, 0.12, 0.13))
		_subtitle.add_theme_constant_override(&"outline_size", 4)
		# a quiet line, also with large letters: it must not push the menu out of the picture
		_subtitle.add_theme_font_size_override(&"font_size", 19)
		_subtitle.position = Vector2(36.0, 90.0)
		_subtitle.size = Vector2(400.0, 24.0)
		AudioDirector.play_music("valley", 3.0)
		AudioDirector.set_ambience(REAL_AMBIENCE, -8.0, 3.0)


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
	_credits = CreditsMenu.new()
	_credits.name = "CreditsMenu"
	_credits.elysia = _is_elysia()
	_credits.follow_mode = false
	_credits.sound_set = _sound_set()
	add_child(_credits)
	_name_entry = NameEntry.new()
	_name_entry.name = "NameEntry"
	_name_entry.follow_mode = false
	_name_entry.sound_set = _sound_set()
	_name_entry.chosen.connect(_start_new_game)
	add_child(_name_entry)
	_confirm = ConfirmMenu.new()
	_confirm.name = "ConfirmNewGame"
	_confirm.follow_mode = false
	_confirm.sound_set = _sound_set()
	add_child(_confirm)
	_confirm.answered.connect(
		func(yes: bool) -> void:
			if yes:
				_name_entry.open()
	)
	for menu: MenuLayer in [
		_save_menu, _settings_menu, _prototypes, _credits, _name_entry, _confirm
	]:
		menu.frame.theme = theme
	list = OptionList.new()
	list.sound_skin = _sound_set()
	list.add_theme_constant_override(&"separation", 0)
	list.custom_minimum_size = Vector2(132, 0)
	_menu_panel.add_child(list)
	_rebuild_list()
	for menu: MenuLayer in [_save_menu, _settings_menu, _prototypes, _credits, _name_entry]:
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
	list.add_action("MENU_NEW_GAME", _new_game_requested)
	# no saved game, no row: a greyed-out "Laden" was hardly readable and said nothing
	if _any_save_to_load():
		list.add_action("MENU_LOAD", func() -> void: _save_menu.open_mode(SaveMenu.Mode.LOAD))
	if OS.is_debug_build():
		list.add_action("MENU_PROTOTYPES", _prototypes.open)
	else:
		# testers only get the benchmark: the prototype scenes would replace their autosave
		list.add_action("MENU_BENCHMARK", func() -> void: BenchmarkRunner.start(get_tree()))
	list.add_action("MENU_SETTINGS", _settings_menu.open)
	list.add_action("MENU_CREDITS_ELYSIA" if _is_elysia() else "MENU_CREDITS", _credits.open)
	_quit_button = list.add_action("MENU_QUIT", _quit)
	list.refresh()
	_layout()
	_layout_soon()


## Menu above the footer: under the plateau in Elysia, on the left in REAL; higher when the
## footer or the rows grow (large text). Labels measure themselves a frame late, hence twice.
func _layout() -> void:
	_menu_panel.reset_size()
	# full width, as tall as the hint needs (a smaller size is lifted to the minimum)
	_footer.size = Vector2(SCREEN.x, 0.0)
	_footer.position = Vector2(0.0, SCREEN.y - _footer.size.y)
	var room := _footer.position.y - _menu_panel.size.y - MENU_GAP
	if _is_elysia():
		_menu_panel.position = Vector2(
			roundf((SCREEN.x - _menu_panel.size.x) * 0.5), minf(ELYSIA_MENU_Y, room)
		)
	else:
		# below the line under the logo if there is one, but never into the footer
		var below_logo := _subtitle.position.y + _subtitle.size.y if _subtitle.text != "" else 0.0
		var y := maxf(minf(REAL_MENU_AT.y, room), below_logo)
		y = minf(y, _footer.position.y - _menu_panel.size.y - 4.0)
		_menu_panel.position = Vector2(REAL_MENU_AT.x, y)


func _layout_soon() -> void:
	# the menu may be gone before the labels have measured themselves (--start jumps away)
	for _frame in 2:
		if not is_inside_tree():
			return
		await get_tree().process_frame
	if is_inside_tree():
		_layout()


func _on_submenu_closed() -> void:
	_menu_panel.show()
	# the gem still marks the row that opened the submenu (focus returns only after this)
	var index := list.buttons().find(list.cursor.target)
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
	for node: CanvasItem in [_subtitle, _menu_panel, _footer]:
		node.modulate.a = 0.0
		tween.tween_property(node, ^"modulate:a", 1.0, 0.5).set_delay(0.7)


func _any_save_to_load() -> bool:
	for slot in SaveService.SLOTS:
		if SaveSystem.summary(slot)["status"] != "empty":
			return true
	return false


## A new game replaces the autosave: with a running game in it, ask first (slots stay). A
## finished game (Chapter.LAST reached) has nothing left to lose: the name is asked at once.
func _new_game_requested() -> void:
	var autosave := SaveSystem.summary(SaveService.AUTOSAVE)
	if autosave["status"] == "ok" and not autosave["finished"]:
		_confirm.ask("CONFIRM_NEW_GAME", "CONFIRM_NEW_GAME_YES", "MENU_BACK")
	else:
		_name_entry.open()


## The controls in one line, for the device in hand (keys or a pad's buttons). The footer is
## set in the body font, which has no PlayStation glyphs (○ □ △): the buttons are words here.
static func controls_hint() -> String:
	return (
		TranslationServer.translate("TITLE_CONTROLS_HINT")
		% [
			InputDevice.move_label(InputDevice.kind),
			InputDevice.label_for(&"sprint", true),
			InputDevice.label_for(&"interact", true),
		]
	)


## Loads the newest readable save ("Fortsetzen", `--continue`). Pressed twice, the second
## press changes nothing: the first one is already on its way.
func _continue_latest() -> void:
	var slot := SaveSystem.latest_slot()
	if slot.is_empty():
		Log.warn(Log.Category.SAVE, "nothing to continue")
		return
	if _leaving:
		return
	_leaving = true
	await ScreenFade.fade_out(0.3)
	var err := SaveSystem.load_slot(slot)
	if err != OK:
		_leaving = false
		# busy: another load is on its way and owns the fade
		if err != ERR_BUSY:
			ScreenFade.fade_in(0.3)


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


## Cancel jumps to "Beenden"; leaving needs a confirm there (no accidental quit).
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("cancel"):
		get_viewport().set_input_as_handled()
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
