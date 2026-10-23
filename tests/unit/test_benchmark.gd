extends GutTest
## Frame statistics of the performance test and its verdicts.


func _stats(frames: Array) -> FrameStats:
	var stats := FrameStats.new()
	for f: float in frames:
		stats.add(f, 100)
	return stats


func test_summary_of_a_steady_60_fps_run() -> void:
	var stats := _stats([16.6, 16.7, 16.6, 16.7, 16.6, 16.7, 16.6, 16.7, 16.6, 16.7])
	var s := stats.summary()
	assert_almost_eq(float(s["avg_fps"]), 60.0, 0.5)
	assert_eq(s["slow_60"], 0.0)
	assert_eq(s["draw_calls"], 100.0)
	assert_eq(FrameStats.verdict(s), "BENCH_SMOOTH")


func test_percentiles_find_the_slow_frames() -> void:
	var frames: Array = []
	for i in 95:
		frames.append(16.6)
	for i in 5:
		frames.append(40.0)
	var stats := _stats(frames)
	assert_almost_eq(stats.percentile(95.0), 16.6, 0.01)
	assert_almost_eq(stats.percentile(99.0), 40.0, 0.01)
	var s := stats.summary()
	assert_eq(s["max_ms"], 40.0)
	assert_almost_eq(float(s["slow_60"]), 5.0, 0.01)
	assert_almost_eq(float(s["slow_30"]), 5.0, 0.01)


func test_verdicts() -> void:
	assert_eq(FrameStats.verdict({"p95_ms": 22.0}), "BENCH_MOSTLY")
	assert_eq(FrameStats.verdict({"p95_ms": 40.0}), "BENCH_STUTTER")
	assert_eq(FrameStats.new().percentile(95.0), 0.0, "empty run")


## Playtest 05.10.: a Mac held every scene at exactly 30 fps. Without VSync the same scene
## shows whether the machine is slow or only capped (macOS Low Power Mode, fullscreen).
func test_a_steady_30_with_headroom_reads_as_capped_not_stutter() -> void:
	var played := {"avg_fps": 30.0, "p95_ms": 34.4}
	assert_eq(FrameStats.verdict(played), "BENCH_STUTTER", "without the raw run")
	assert_eq(FrameStats.verdict(played, {"avg_fps": 240.0}), "BENCH_CAPPED")
	assert_true(FrameStats.capped_at_30(played, {"avg_fps": 240.0}))
	assert_false(FrameStats.capped_at_30(played, {"avg_fps": 41.0}), "really too slow")
	assert_false(FrameStats.capped_at_30({"avg_fps": 60.0}, {"avg_fps": 240.0}))


## Playtest 23.10., MacBook with a 120 Hz screen: VSync on gave 58 to 108 fps, off 145 to 474.
func test_vsync_that_costs_frames_reads_as_vsync_not_stutter() -> void:
	var elysia := {"avg_fps": 60.0, "p95_ms": 18.6}
	var tal := {"avg_fps": 58.0, "p95_ms": 33.3}
	var wald := {"avg_fps": 108.0, "p95_ms": 17.3}
	assert_true(FrameStats.held_by_vsync(elysia, {"avg_fps": 205.0}, 120.0))
	assert_true(FrameStats.held_by_vsync(tal, {"avg_fps": 474.0}, 120.0))
	assert_eq(FrameStats.verdict(tal, {"avg_fps": 474.0}, 120.0), "BENCH_VSYNC")
	assert_false(FrameStats.held_by_vsync(wald, {"avg_fps": 145.0}, 120.0), "near the refresh rate")
	assert_eq(FrameStats.verdict(wald, {"avg_fps": 145.0}, 120.0), "BENCH_SMOOTH")


func test_vsync_is_not_blamed_without_headroom_or_a_known_screen() -> void:
	var sixty := {"avg_fps": 60.0, "p95_ms": 17.0}
	assert_false(FrameStats.held_by_vsync(sixty, {"avg_fps": 300.0}, 60.0), "60 on a 60 Hz screen")
	var slow := {"avg_fps": 40.0, "p95_ms": 30.0}
	assert_false(FrameStats.held_by_vsync(slow, {"avg_fps": 70.0}, 120.0), "really too slow")
	assert_false(FrameStats.held_by_vsync(slow, {"avg_fps": 474.0}, -1.0), "refresh rate unknown")
	assert_false(FrameStats.held_by_vsync(slow, {}, 120.0), "no raw run")
	var thirty := {"avg_fps": 30.0, "p95_ms": 34.4}
	assert_eq(
		FrameStats.verdict(thirty, {"avg_fps": 240.0}, 60.0), "BENCH_CAPPED", "30 keeps its own"
	)


func test_timing_is_averaged_and_marked_missing_without_samples() -> void:
	var stats := FrameStats.new()
	assert_eq(stats.summary()["gpu_ms"], -1.0)
	stats.add(16.7)
	stats.add_timing(4.0, 2.0)
	stats.add_timing(6.0, 4.0)
	assert_almost_eq(float(stats.summary()["cpu_ms"]), 5.0, 0.001)
	assert_almost_eq(float(stats.summary()["gpu_ms"]), 3.0, 0.001)


func test_report_lands_in_the_profile_folder() -> void:
	assert_string_starts_with(BenchmarkRunner.report_path(), RuntimeEnv.user_dir())


func test_the_result_page_offers_to_turn_vsync_off_when_it_holds_the_game_back() -> void:
	var held := {"avg_fps": 58.0, "p95_ms": 33.3}
	BenchmarkRunner.last_rows = [{"scene": "tal", "stats": held, "raw": {"avg_fps": 474.0}}]
	var page := BenchmarkResult.new()
	page.refresh_hz = 120.0
	add_child_autofree(page)
	page.open()
	await wait_process_frames(3)
	var off: Button = null
	for button: Button in page.find_children("*", "Button", true, false):
		if button.text == TranslationServer.translate("BENCH_VSYNC_OFF"):
			off = button
	assert_not_null(off, "the remedy is one press away")
	var focused := page.get_viewport().gui_get_focus_owner() as Button
	assert_eq(
		focused.text, TranslationServer.translate("OPTION_OK"), "the page opens on the safe answer"
	)
	assert_true(Settings.get_bool("display.vsync"))
	off.pressed.emit()
	assert_false(Settings.get_bool("display.vsync"))
	Settings.set_value("display.vsync", true)
	BenchmarkRunner.last_rows = []


func test_the_result_page_has_no_such_button_when_the_machine_is_just_slow() -> void:
	var slow := {"avg_fps": 40.0, "p95_ms": 30.0}
	BenchmarkRunner.last_rows = [{"scene": "tal", "stats": slow, "raw": {"avg_fps": 70.0}}]
	var page := BenchmarkResult.new()
	page.refresh_hz = 120.0
	add_child_autofree(page)
	page.open()
	await wait_process_frames(3)
	for button: Button in page.find_children("*", "Button", true, false):
		assert_ne(button.text, TranslationServer.translate("BENCH_VSYNC_OFF"))
	BenchmarkRunner.last_rows = []
