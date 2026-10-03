class_name BenchmarkResult
extends MenuLayer
## Shows the last performance test: one row per scene with average fps, the slow 5 % of
## frames and a verdict in words, plus where the full report was saved.


func _ready() -> void:
	title_key = "BENCH_TITLE"
	panel_width = 360
	layer = 50
	super()


func _build() -> void:
	var grid := GridContainer.new()
	grid.columns = 5
	grid.add_theme_constant_override(&"h_separation", 14)
	for key: String in ["BENCH_SCENE", "BENCH_FPS", "BENCH_P95", "BENCH_SLOW", "BENCH_VERDICT"]:
		var head := Label.new()
		head.theme_type_variation = &"MutedLabel"
		head.text = key
		grid.add_child(head)
	for row: Dictionary in BenchmarkRunner.last_rows:
		var s: Dictionary = row["stats"]
		var values := [
			tr(SceneRegistry.title_key(str(row["scene"]))),
			"%.0f" % s["avg_fps"],
			"%.1f ms" % s["p95_ms"],
			"%.0f %%" % s["slow_60"],
			tr(FrameStats.verdict(s)),
		]
		for value: String in values:
			var cell := Label.new()
			cell.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
			cell.text = value
			grid.add_child(cell)
	list.add_custom(grid)
	list.add_info(tr("BENCH_SAVED") % BenchmarkRunner.report_path(true))
	list.add_action("OPTION_OK", close)
	hint.text = tr("BENCH_HINT")
