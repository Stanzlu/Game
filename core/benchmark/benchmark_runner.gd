class_name BenchmarkRunner
extends Node
## Performance test (start menu "Leistungstest", or `--benchmark` / `--benchmark=quick`):
## walks through the look scenes while measuring frame times, then writes a report to
## user://benchmark.txt and shows it in the start menu. Saving is blocked the whole time,
## so the test never touches the player's saves; the game state is reset afterwards.
## While it runs, pause menu and journal stay closed (group "cutscene"), so nothing can
## pause the measured scenes. `--quit-after-benchmark` ends the program after the report
## (tools/check.sh).

const SCENES: PackedStringArray = ["look_elysia", "look_tal", "look_wald"]
const REPORT_NAME := "benchmark.txt"
## Movement pattern (action, seconds), repeated: scrolls the camera across the scene.
const PATTERN := [[&"move_right", 1.6], [&"move_down", 1.0], [&"move_left", 1.6], [&"move_up", 1.0]]

static var last_report := ""
## Per scene: {"scene", "stats" (FrameStats.summary())}, for the result screen.
static var last_rows: Array[Dictionary] = []
static var running := false
## Set when a run finished; the start menu shows the result once and clears it.
static var result_pending := false

var settle_seconds := 1.5
var measure_seconds := 12.0
var _stats: Dictionary[String, FrameStats] = {}
var _measuring: FrameStats
var _last_usec := 0
var _quit_when_done := false


static func start(tree: SceneTree, quick := false) -> void:
	if running:
		return
	var runner := BenchmarkRunner.new()
	runner.name = "BenchmarkRunner"
	if quick:
		runner.settle_seconds = 0.5
		runner.measure_seconds = 2.0
	runner._quit_when_done = "--quit-after-benchmark" in OS.get_cmdline_user_args()
	tree.root.add_child(runner)
	runner.run.call_deferred()


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	process_priority = -100
	add_to_group(&"cutscene")


## Keeps menus closed while measuring (MenuLayer.any_open).
func is_open() -> bool:
	return running


func run() -> void:
	running = true
	SaveSystem.block(&"benchmark")
	Log.info(Log.Category.BOOT, "benchmark start", {"seconds": measure_seconds})
	for key in SCENES:
		WorldState.new_game()
		WorldState.set_ui_mode(SceneRegistry.start_mode(key))
		get_tree().paused = false
		get_tree().change_scene_to_file(SceneRegistry.path(key))
		await _wait(settle_seconds)
		_measuring = FrameStats.new()
		_last_usec = Time.get_ticks_usec()
		_stats[key] = _measuring
		await _walk(measure_seconds)
		_measuring = null
		Log.info(
			Log.Category.BOOT, "benchmark scene", {"scene": key, "stats": _stats[key].summary()}
		)
	_release_all()
	WorldState.new_game()
	SaveSystem.unblock(&"benchmark")
	last_report = report()
	last_rows.clear()
	for key in SCENES:
		if _stats.has(key):
			last_rows.append({"scene": key, "stats": _stats[key].summary()})
	_write(last_report)
	Log.info(Log.Category.BOOT, "benchmark done", {"file": report_path(true)})
	running = false
	result_pending = true
	get_tree().paused = false
	if _quit_when_done:
		get_tree().quit()
		return
	get_tree().change_scene_to_file("res://core/boot/boot.tscn")
	queue_free()


func _process(_delta: float) -> void:
	if _measuring == null:
		return
	var now := Time.get_ticks_usec()
	var draw_calls := int(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME))
	_measuring.add((now - _last_usec) / 1000.0, draw_calls)
	_last_usec = now


func _walk(seconds: float) -> void:
	var elapsed := 0.0
	var step := 0
	Input.action_press(&"sprint")
	while elapsed < seconds:
		var move: Array = PATTERN[step % PATTERN.size()]
		var hold := minf(float(move[1]), seconds - elapsed)
		Input.action_press(move[0])
		await _wait(hold)
		Input.action_release(move[0])
		elapsed += hold
		step += 1
	Input.action_release(&"sprint")


func _release_all() -> void:
	for move: Array in PATTERN:
		Input.action_release(move[0])
	Input.action_release(&"sprint")


func _wait(seconds: float) -> Signal:
	return get_tree().create_timer(seconds, true, false, true).timeout


## Plain-text report (German, for the player to send back).
func report() -> String:
	var info := Engine.get_version_info()
	var lines: PackedStringArray = []
	lines.append("REAL – %s" % TranslationServer.translate("BENCH_TITLE"))
	lines.append(
		(
			"%s · Godot %s · %s"
			% [Time.get_datetime_string_from_system(), info["string"], OS.get_name()]
		)
	)
	lines.append("CPU: %s (%d)" % [OS.get_processor_name(), OS.get_processor_count()])
	lines.append(
		(
			"GPU: %s %s"
			% [RenderingServer.get_video_adapter_vendor(), RenderingServer.get_video_adapter_name()]
		)
	)
	var screen := DisplayServer.screen_get_size()
	(
		lines
		. append(
			(
				"Bildschirm: %dx%d @ %d Hz · Fenster %dx%d · VSync %s"
				% [
					screen.x,
					screen.y,
					roundi(DisplayServer.screen_get_refresh_rate()),
					get_window().size.x,
					get_window().size.y,
					(
						"an"
						if DisplayServer.window_get_vsync_mode() != DisplayServer.VSYNC_DISABLED
						else "aus"
					),
				]
			)
		)
	)
	lines.append("")
	lines.append("Szene        Ø fps   Ø ms   95%   99%    max   >16,7ms  Drawcalls  Urteil")
	for key in SCENES:
		if not _stats.has(key):
			continue
		var s := _stats[key].summary()
		(
			lines
			. append(
				(
					"%-11s %6.0f %6.1f %5.1f %5.1f %6.1f %7.1f %% %9.0f  %s"
					% [
						key.trim_prefix("look_"),
						s["avg_fps"],
						s["avg_ms"],
						s["p95_ms"],
						s["p99_ms"],
						s["max_ms"],
						s["slow_60"],
						s["draw_calls"],
						TranslationServer.translate(FrameStats.verdict(s)),
					]
				)
			)
		)
	return "\n".join(lines)


## Where the report is written; `absolute` for showing it to the player.
static func report_path(absolute := false) -> String:
	var path := RuntimeEnv.user_dir() + REPORT_NAME
	return ProjectSettings.globalize_path(path) if absolute else path


func _write(text: String) -> void:
	DirAccess.make_dir_recursive_absolute(RuntimeEnv.user_dir())
	var file := FileAccess.open(report_path(), FileAccess.WRITE)
	if file == null:
		Log.error(Log.Category.BOOT, "benchmark report not written", {"path": report_path()})
		return
	file.store_string(text + "\n")
