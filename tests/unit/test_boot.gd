extends GutTest

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


func test_build_info_defaults_to_dev_without_build_file() -> void:
	if FileAccess.file_exists(BootScript.BUILD_INFO_PATH):
		pending("build_info.cfg present (exported or stamped checkout)")
		return
	var info: Dictionary = BootScript.read_build_info()
	assert_eq(info["commit"], "dev")
	assert_eq(info["version"], ProjectSettings.get_setting("application/config/version"))


func test_build_line_leaves_out_empty_date() -> void:
	var boot: Control = autofree(BootScript.new())
	var line: String = boot.format_build_line({"version": "0.0.1", "commit": "dev", "date": ""})
	assert_eq(line, "Version 0.0.1 · dev")


func test_build_line_includes_date_when_known() -> void:
	var boot: Control = autofree(BootScript.new())
	var info := {"version": "0.0.1", "commit": "abc1234", "date": "2026-10-02"}
	assert_eq(boot.format_build_line(info), "Version 0.0.1 · abc1234 · 2026-10-02")


func test_title_mode_follows_arguments_first() -> void:
	assert_eq(BootScript.choose_title_mode(["--title=real"]), TitleBackground.Mode.REAL)
	assert_eq(BootScript.choose_title_mode(["--title=elysia"]), TitleBackground.Mode.ELYSIA)


func test_elysia_title_is_symmetric_and_beats_exactly() -> void:
	var bg := TitleBackground.new()
	add_child_autofree(bg)
	bg.build(TitleBackground.Mode.ELYSIA)
	bg._process(0.016)
	var island_center := bg._island.position.x + bg._island.texture.get_width() * 0.5
	assert_eq(island_center, 320.0, "the island sits on the middle axis")
	var right := bg._falls[0].position.x + bg._falls[0].texture.get_width() * 0.5
	var left := bg._falls[1].position.x + bg._falls[1].texture.get_width() * 0.5
	assert_eq(left + right, 640.0, "twin waterfalls mirror each other")
	bg._next_flock = 0.0
	bg._update_birds(0.0)
	assert_eq(bg._birds.size(), 5, "always the same five birds")
	assert_almost_eq(bg._next_flock, TitleBackground.FLOCK_BEAT, 0.001, "on an exact beat")


func test_title_card_fades_in_and_finishes() -> void:
	var card := TitleCard.play(self)
	watch_signals(card)
	assert_eq(card.logo.modulate.a, 0.0, "starts black")
	await wait_seconds(4.2)
	assert_gt(card.logo.modulate.a, 0.9, "REAL is shown")
	var skip := InputEventAction.new()
	skip.action = "ui_accept"
	skip.pressed = true
	card._unhandled_input(skip)
	assert_signal_emitted(card, "finished")


func test_the_last_profile_argument_wins() -> void:
	# tools/capture.sh puts its own profile before the caller's arguments
	assert_eq(RuntimeEnv.profile_from_args(["--profile=capture_1", "--profile=mine"]), "mine")
	assert_eq(RuntimeEnv.profile_from_args(["--profile=a", "--profile=../x"]), "a")
	assert_eq(RuntimeEnv.profile_from_args(["--title=real"]), "")


func test_title_card_without_a_line_has_no_label() -> void:
	var card := TitleCard.play(self, "")
	assert_null(card.note, "black, then the title: nothing under it")
	assert_eq(card.find_children("*", "Label", true, false).size(), 0)
	card._finish()
	var with_line := TitleCard.play(self, "END_OF_SLICE")
	assert_not_null(with_line.note, "a line still works for other callers")
	with_line._finish()


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
	await wait_physics_frames(6)
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
