extends GutTest
## The start menu with saves of its own: rows, "Neues Spiel" after the end, the closing line
## under the Real logo, large letters, Esc, "Fortsetzen" and the pages behind "Mitwirkende".

const BootScript := preload("res://core/boot/boot.gd")
const BOOT_SCENE := preload("res://core/boot/boot.tscn")

var _saved_dir := ""


func before_each() -> void:
	# a start menu of its own: the saves of the other tests must not show up in it
	_saved_dir = SaveSystem.save_dir
	SaveSystem.save_dir = RuntimeEnv.user_dir() + "boot_test_saves"
	_clear_saves()
	BootScript._forced_title = -1


func after_each() -> void:
	_clear_saves()
	SaveSystem.save_dir = _saved_dir
	BootScript._forced_title = -1
	Settings.override("text.large", false)
	WorldState.new_game()
	get_tree().paused = false


func _clear_saves() -> void:
	for slot in SaveService.SLOTS:
		for backup: bool in [false, true]:
			var path := SaveSystem.path_for(slot, backup)
			if FileAccess.file_exists(path):
				DirAccess.remove_absolute(path)


## Writes the running state as the autosave.
func _write_autosave(finished: bool) -> void:
	WorldState.new_game()
	WorldState.set_location("elysia", Vector2.ZERO)
	if finished:
		WorldState.set_flag("slice.finished")
	assert_eq(SaveSystem.write_slot(SaveService.AUTOSAVE, SaveCodec.encode(WorldState.state)), OK)


func _boot() -> Control:
	var boot: Control = BOOT_SCENE.instantiate()
	add_child_autofree(boot)
	await wait_physics_frames(4)
	return boot


func _rows(boot: Control) -> PackedStringArray:
	var rows := PackedStringArray()
	for button: Button in boot.list.buttons():
		rows.append(button.text)
	return rows


func test_without_a_save_the_menu_has_no_load_or_continue_row() -> void:
	var boot := await _boot()
	var rows := _rows(boot)
	assert_eq(rows[0], tr("MENU_NEW_GAME"), "a fresh profile starts with a new game")
	assert_false(rows.has(tr("MENU_LOAD")), "no greyed-out Laden")
	assert_false(rows.has(tr("MENU_CONTINUE")))
	assert_true(rows.has(tr("MENU_SETTINGS")))
	assert_true(rows.has(tr("MENU_CREDITS")) or rows.has(tr("MENU_CREDITS_ELYSIA")), str(rows))


func test_with_a_save_the_menu_offers_continue_and_load() -> void:
	_write_autosave(false)
	var rows := _rows(await _boot())
	assert_eq(rows[0], tr("MENU_CONTINUE"))
	assert_true(rows.has(tr("MENU_LOAD")))


func test_new_game_asks_only_while_the_game_is_unfinished() -> void:
	_write_autosave(false)
	var boot := await _boot()
	boot._new_game_requested()
	assert_true(boot._confirm.visible, "a running game is not replaced without asking")
	assert_false(boot._name_entry.visible)
	boot._confirm.close()
	_write_autosave(true)
	boot._new_game_requested()
	assert_true(boot._name_entry.visible, "after the end the name is asked right away")
	assert_false(boot._confirm.visible)


func test_a_finished_game_says_so_under_the_real_logo() -> void:
	BootScript._forced_title = TitleBackground.Mode.REAL
	var boot := await _boot()
	assert_eq(boot._subtitle.text, "", "nothing to say before the end")
	boot.queue_free()
	await wait_physics_frames(2)
	_write_autosave(true)
	boot = await _boot()
	assert_eq(boot._subtitle.text, tr("END_OF_SLICE"))
	assert_string_contains(boot._subtitle.text, "Prototyp")


func test_the_menu_stays_clear_of_the_footer_in_large_text() -> void:
	BootScript._forced_title = TitleBackground.Mode.ELYSIA
	_write_autosave(false)
	var boot := await _boot()
	Settings.override("text.large", true)
	# the menu lays itself out two PROCESS frames later (a physics frame count can run ahead)
	await wait_process_frames(8)
	var menu_bottom: float = boot._menu_panel.position.y + boot._menu_panel.size.y
	assert_true(boot._footer.size.y > 0.0)
	assert_lte(menu_bottom + 24.0, boot._footer.position.y + 0.5, "24 px of air above the hint")
	assert_lte(boot._footer.position.y + boot._footer.size.y, 360.5, "the footer is on screen")
	assert_gte(boot._menu_panel.position.y, 0.0, "and the menu too")
	# the hint and the version line are side by side, never over each other
	var hint_end: float = boot._hint.global_position.x + boot._hint.size.x
	assert_lte(hint_end, boot._build.global_position.x + 0.5)


func test_cancel_only_jumps_to_quit() -> void:
	var boot := await _boot()
	var cancel := InputEventAction.new()
	cancel.action = &"cancel"
	cancel.pressed = true
	boot._unhandled_input(cancel)
	assert_eq(get_viewport().gui_get_focus_owner(), boot._quit_button)
	boot._unhandled_input(cancel)
	assert_true(is_instance_valid(boot), "a second Esc on Beenden does not leave the game")
	assert_eq(get_viewport().gui_get_focus_owner(), boot._quit_button)


func test_continue_pressed_twice_loads_once() -> void:
	_write_autosave(false)
	var boot := await _boot()
	boot._leaving = true
	await boot._continue_latest()
	assert_false(ScreenFade.is_fading(), "the second press does not start another fade")
	assert_false(SaveSystem.loading)


func test_the_hint_names_the_keys_or_the_pad() -> void:
	InputDevice.set_kind(InputDevice.Kind.KEYBOARD)
	var keys: String = BootScript.controls_hint()
	assert_true(keys.contains("WASD") and keys.contains("E"), keys)
	assert_false(keys.contains("Menü"), "Esc does not open a menu on this screen")
	InputDevice.set_kind(InputDevice.Kind.GAMEPAD)
	var pad: String = BootScript.controls_hint()
	InputDevice.set_kind(InputDevice.Kind.KEYBOARD)
	assert_true(pad.contains("Stick"), pad)


func test_the_hint_spells_out_playstation_buttons() -> void:
	# the footer's font has no ○ □ △: Kreuz and Quadrat instead (the pad prompts keep the glyphs)
	InputDevice.style = InputDevice.Style.PLAYSTATION
	InputDevice.set_kind(InputDevice.Kind.GAMEPAD)
	var pad: String = BootScript.controls_hint()
	InputDevice.set_kind(InputDevice.Kind.KEYBOARD)
	InputDevice.style = InputDevice.Style.XBOX
	assert_true(pad.contains("Quadrat") and pad.contains("Kreuz"), pad)
	assert_false(pad.contains("□") or pad.contains("×"), pad)


func test_the_credits_page_scrolls_with_up_and_down() -> void:
	var menu := CreditsMenu.new()
	add_child_autofree(menu)
	menu.open()
	var spacer := Control.new()
	spacer.custom_minimum_size.y = 800
	menu.list.add_custom(spacer)
	await wait_physics_frames(3)
	var scroll := menu.list.get_parent() as ScrollContainer
	assert_eq(scroll.scroll_vertical, 0, "starts at the top, not at the focused Zurück")
	var down := InputEventAction.new()
	down.action = &"ui_down"
	down.pressed = true
	menu._input(down)
	assert_eq(scroll.scroll_vertical, int(ScrollPage.SCROLL_STEP))
	var up := InputEventAction.new()
	up.action = &"ui_up"
	up.pressed = true
	menu._input(up)
	menu._input(up)
	assert_eq(scroll.scroll_vertical, 0, "and never above the top")
	assert_eq(menu.title.text, "MENU_CREDITS", "the real world calls it Mitwirkende")


func test_leaving_the_start_menu_at_once_is_clean() -> void:
	# `--start=<scene>` replaces the menu in its first frame: nothing may wait for it after that
	var boot: Control = BOOT_SCENE.instantiate()
	add_child(boot)
	boot.queue_free()
	await wait_physics_frames(4)
	assert_false(is_instance_valid(boot))


func test_the_real_menu_sits_between_the_closing_line_and_the_footer() -> void:
	BootScript._forced_title = TitleBackground.Mode.REAL
	_write_autosave(true)
	var boot := await _boot()
	Settings.override("text.large", true)
	# the menu lays itself out two PROCESS frames later (a physics frame count can run ahead)
	await wait_process_frames(8)
	var panel: Control = boot._menu_panel
	var subtitle: Control = boot._subtitle
	assert_gte(panel.position.y, subtitle.position.y + subtitle.size.y - 0.5, "below the line")
	assert_lte(panel.position.y + panel.size.y, boot._footer.position.y, "above the footer")


## The panel style a menu draws with, as its theme resolves it.
func _panel_style(menu: MenuLayer) -> StyleBox:
	return (menu.frame.get_child(0) as PanelContainer).get_theme_stylebox(&"panel")


## Every page the settings menu opens (the key layout, its question and second page, the reset
## question) is a layer of its own and wears the skin of the title, like the menu itself.
func _check_pages_wear_the_skin(mode: TitleBackground.Mode, skin: Theme) -> void:
	BootScript._forced_title = mode
	var boot := await _boot()
	var settings: SettingsMenu = boot._settings_menu
	assert_true(settings.frame.theme == skin, "the start menu's settings use the title skin")
	settings.open()
	settings._show_controls()
	settings._reset()
	var page: ControlsMenu = settings._controls
	page._open_notes()
	var pages: Array[MenuLayer] = [page, page._question(), page._notes, settings._confirm]
	for child in pages:
		assert_true(child.frame.theme == skin, "%s wears the skin" % child.name)
		assert_true(_panel_style(child) == _panel_style(settings), child.name)
	for child in pages:
		child.close()
	settings.close()


func test_the_pages_behind_settings_wear_the_elysia_skin() -> void:
	await _check_pages_wear_the_skin(TitleBackground.Mode.ELYSIA, UiSkin.ELYSIA_SKIN)


func test_the_pages_behind_settings_wear_the_real_skin() -> void:
	await _check_pages_wear_the_skin(TitleBackground.Mode.REAL, UiSkin.REAL_SKIN)
