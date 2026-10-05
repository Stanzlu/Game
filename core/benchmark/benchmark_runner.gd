class_name BenchmarkRunner
extends Node
## Performance test (start menu "Leistungstest", or `--benchmark` / `--benchmark=quick`):
## walks through the look scenes while measuring frame times, then once more for a few
## seconds without VSync (what the machine could do: tells a VSync cap such as macOS Low
## Power Mode's 30 fps apart from a slow GPU), with CPU and GPU time per frame. Writes a
## report to user://benchmark.txt and shows it in the start menu. Saving is blocked the whole time,
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
var raw_seconds := 4.0
var _stats: Dictionary[String, FrameStats] = {}
var _raw_stats: Dictionary[String, FrameStats] = {}
## Viewports whose CPU and GPU render time is measured (window and world).
var _measured: Array[RID] = []
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
		runner.raw_seconds = 1.0
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
		_measure_viewports()
		_stats[key] = await _measure(measure_seconds)
		# the same scene without VSync and frame cap: what the machine could do
		_set_uncapped(true)
		await _wait(0.4)
		_raw_stats[key] = await _measure(raw_seconds)
		_set_uncapped(false)
		Log.info(
			Log.Category.BOOT,
			"benchmark scene",
			{"scene": key, "stats": _stats[key].summary(), "raw": _raw_stats[key].summary()}
		)
	_release_all()
	WorldState.new_game()
	SaveSystem.unblock(&"benchmark")
	last_report = report()
	last_rows.clear()
	for key in SCENES:
		if _stats.has(key):
			last_rows.append(
				{"scene": key, "stats": _stats[key].summary(), "raw": _raw_stats[key].summary()}
			)
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
	var cpu := Performance.get_monitor(Performance.TIME_PROCESS) * 1000.0
	cpu += RenderingServer.get_frame_setup_time_cpu()
	var gpu := 0.0
	for rid in _measured:
		cpu += RenderingServer.viewport_get_measured_render_time_cpu(rid)
		gpu += RenderingServer.viewport_get_measured_render_time_gpu(rid)
	_measuring.add_timing(cpu, gpu)


func _measure(seconds: float) -> FrameStats:
	var stats := FrameStats.new()
	_last_usec = Time.get_ticks_usec()
	_measuring = stats
	await _walk(seconds)
	_measuring = null
	return stats


## Turns on render time measurement for the window and the scene's world viewport.
func _measure_viewports() -> void:
	_measured.clear()
	var viewports: Array[Viewport] = [get_tree().root]
	var view: Variant = get_tree().current_scene.get(&"view") if get_tree().current_scene else null
	if view is GameView:
		viewports.append((view as GameView).viewport)
	for viewport in viewports:
		RenderingServer.viewport_set_measure_render_time(viewport.get_viewport_rid(), true)
		_measured.append(viewport.get_viewport_rid())


## Off with VSync and the frame cap for the raw measurement, then back to the settings.
func _set_uncapped(on: bool) -> void:
	if not on:
		SettingsService.apply_vsync(Settings.get_bool("display.vsync"))
		return
	if DisplayServer.get_name() != "headless":
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	Engine.max_fps = 0


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
	var hz := DisplayServer.screen_get_refresh_rate()
	(
		lines
		. append(
			(
				"Bildschirm: %dx%d @ %s Hz · Fenster %dx%d · Vollbild %s · VSync %s"
				% [
					screen.x,
					screen.y,
					str(roundi(hz)) if hz > 0.0 else "?",
					get_window().size.x,
					get_window().size.y,
					"ja" if get_window().mode >= Window.MODE_FULLSCREEN else "nein",
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
	lines.append(
		(
			"Szene        Ø fps   Ø ms   95%   99%    max   >16,7ms  Drawcalls"
			+ "  ohneVSync  CPU ms  GPU ms  Urteil"
		)
	)
	var capped := false
	for key in SCENES:
		if not _stats.has(key):
			continue
		var s := _stats[key].summary()
		var raw := _raw_stats[key].summary()
		capped = capped or FrameStats.capped_at_30(s, raw)
		(
			lines
			. append(
				(
					"%-11s %6.0f %6.1f %5.1f %5.1f %6.1f %7.1f %% %9.0f  %9.0f  %6.2f  %6.2f  %s"
					% [
						key.trim_prefix("look_"),
						s["avg_fps"],
						s["avg_ms"],
						s["p95_ms"],
						s["p99_ms"],
						s["max_ms"],
						s["slow_60"],
						s["draw_calls"],
						raw["avg_fps"],
						raw["cpu_ms"],
						raw["gpu_ms"],
						TranslationServer.translate(FrameStats.verdict(s, raw)),
					]
				)
			)
		)
	if capped:
		lines.append("")
		lines.append(TranslationServer.translate("BENCH_CAPPED_HINT"))
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
