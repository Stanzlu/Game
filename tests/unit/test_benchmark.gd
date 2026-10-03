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


func test_report_lands_in_the_profile_folder() -> void:
	assert_string_starts_with(BenchmarkRunner.report_path(), "user://profiles/test/")
