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
