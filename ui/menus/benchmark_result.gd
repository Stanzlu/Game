class_name BenchmarkResult
extends MenuLayer
## Shows the last performance test: one row per scene with average fps, the slow 5 % of
## frames, fps without VSync and a verdict in words, a hint when VSync holds the game at
## 30 fps or under the screen's refresh rate (with a button that turns VSync off), plus where
## the full report was saved.

## The screen's refresh rate, to tell "VSync holds it back" from "too slow" (a test sets it).
var refresh_hz := DisplayServer.screen_get_refresh_rate()


func _ready() -> void:
	title_key = "BENCH_TITLE"
	panel_width = 360
	layer = 50
	super()


func _build() -> void:
	var grid := GridContainer.new()
	grid.columns = 5
	grid.add_theme_constant_override(&"h_separation", 14)
	for key: String in ["BENCH_SCENE", "BENCH_FPS", "BENCH_P95", "BENCH_RAW", "BENCH_VERDICT"]:
		var head := Label.new()
		head.theme_type_variation = &"MutedLabel"
		head.text = key
		grid.add_child(head)
	var capped := false
	var held := false
	var hz := refresh_hz
	for row: Dictionary in BenchmarkRunner.last_rows:
		var s: Dictionary = row["stats"]
		var raw: Dictionary = row.get("raw", {})
		capped = capped or FrameStats.capped_at_30(s, raw)
		held = held or FrameStats.held_by_vsync(s, raw, hz)
		var values := [
			tr(SceneRegistry.title_key(str(row["scene"]))),
			"%.0f" % s["avg_fps"],
			"%.1f ms" % s["p95_ms"],
			"%.0f" % raw["avg_fps"] if not raw.is_empty() else "–",
			tr(FrameStats.verdict(s, raw, hz)),
		]
		for value: String in values:
			var cell := Label.new()
			cell.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
			cell.text = value
			grid.add_child(cell)
	list.add_custom(grid)
	# the buttons come first, OK on top: the safe answer is what the page opens on, and both
	# stay in the 240 px of the list's view (the explanation below them scrolls)
	list.add_action("OPTION_OK", close)
	if held:
		list.add_action("BENCH_VSYNC_OFF", _turn_vsync_off)
	if capped:
		list.add_info(tr("BENCH_CAPPED_HINT"))
	if held:
		list.add_info(tr("BENCH_VSYNC_HINT"))
	list.add_info(tr("BENCH_SAVED") % BenchmarkRunner.report_path(true))
	hint.text = tr("BENCH_HINT")


## The remedy the hint names, one press away: the engine paces the frames itself afterwards.
func _turn_vsync_off() -> void:
	Settings.set_value("display.vsync", false)
	close()
