extends GutTest

const BootScript := preload("res://core/boot/boot.gd")


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
