extends Node
## Large-map spike (T6, docs/PERFORMANCE.md): builds one text map in a MapView and prints what it
## costs as one line, "SPIKE {json}". Run by tools/perf/map_spike.py:
##   tools/godot.sh --headless res://tools/perf/map_spike.tscn -- --map=res://spike_tmp/tal_2x2.txt
## A scene and not a -s script: the autoloads the map needs are not there when a script compiles.
## A measuring tool: it reads the wall clock, as the game and its tests never do.

## Frames measured after WARMUP frames in which the scene settles (textures, first draws).
const WARMUP := 40
const FRAMES := 160

var _map := ""


func _ready() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--map="):
			_map = arg.trim_prefix("--map=")
	_run.call_deferred()


func _run() -> void:
	if _map.is_empty():
		push_error("map_spike: --map=<res:// path> missing")
		get_tree().quit(1)
		return
	var text := FileAccess.get_file_as_string(_map)
	var legend := MapView.load_legend(MapView.DEFAULT_LEGEND)
	var started := Time.get_ticks_usec()
	var parsed := MapData.parse(text, legend, _map)
	var parse_us := Time.get_ticks_usec() - started
	var nodes_before := int(Performance.get_monitor(Performance.OBJECT_NODE_COUNT))
	var memory_before := Performance.get_monitor(Performance.MEMORY_STATIC)
	var view := MapView.new()
	add_child(view)
	started = Time.get_ticks_usec()
	var ok := view.build_from_text(text, _map)
	var build_us := Time.get_ticks_usec() - started
	var nodes := int(Performance.get_monitor(Performance.OBJECT_NODE_COUNT)) - nodes_before
	var memory := (Performance.get_monitor(Performance.MEMORY_STATIC) - memory_before) / 1048576.0
	# the engine's own time of the frame's process and physics steps; a wall clock around the loop
	# would measure the pause headless mode puts between frames (about 7 ms), not the scene
	var samples: Array[float] = []
	for i in WARMUP + FRAMES:
		await get_tree().process_frame
		if i >= WARMUP:
			samples.append(
				(
					Performance.get_monitor(Performance.TIME_PROCESS)
					+ Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS)
				)
			)
	samples.sort()
	var result := {
		"map": _map,
		"ok": ok,
		"cells": [parsed.width, parsed.height],
		"placements": parsed.placements.size(),
		"symbols": parsed.tiles.size(),
		"parse_ms": snappedf(parse_us / 1000.0, 0.1),
		"build_ms": snappedf(build_us / 1000.0, 0.1),
		"nodes": nodes,
		"static_mb": snappedf(memory, 0.1),
		"process_us": int(samples[samples.size() / 2] * 1000000.0),
		"process_p95_us": int(samples[int(samples.size() * 0.95)] * 1000000.0),
	}
	print("SPIKE ", JSON.stringify(result))
	get_tree().quit(0 if ok else 1)
