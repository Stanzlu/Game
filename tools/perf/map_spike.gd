extends SceneTree
## Large-map spike (T6, docs/PERFORMANCE.md): builds one text map in a MapView and prints what it
## costs as one line, "SPIKE {json}". Run by tools/perf/map_spike.py:
##   tools/godot.sh --headless -s tools/perf/map_spike.gd -- --map=res://build/spike/tal_2x2.txt
## A measuring tool: it reads the wall clock, as the game and its tests never do.

const FRAMES := 120

var _map := ""


func _initialize() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--map="):
			_map = arg.trim_prefix("--map=")
	_run.call_deferred()


func _run() -> void:
	if _map.is_empty():
		push_error("map_spike: --map=<res:// path> missing")
		quit(1)
		return
	var text := FileAccess.get_file_as_string(_map)
	var legend := MapView.load_legend(MapView.DEFAULT_LEGEND)
	var started := Time.get_ticks_usec()
	var parsed := MapData.parse(text, legend, _map)
	var parse_us := Time.get_ticks_usec() - started
	var nodes_before := int(Performance.get_monitor(Performance.OBJECT_NODE_COUNT))
	var memory_before := Performance.get_monitor(Performance.MEMORY_STATIC)
	var view := MapView.new()
	root.add_child(view)
	started = Time.get_ticks_usec()
	var ok := view.build_from_text(text, _map)
	var build_us := Time.get_ticks_usec() - started
	var nodes := int(Performance.get_monitor(Performance.OBJECT_NODE_COUNT)) - nodes_before
	var memory := (Performance.get_monitor(Performance.MEMORY_STATIC) - memory_before) / 1048576.0
	started = Time.get_ticks_usec()
	for i in FRAMES:
		await process_frame
	var frame_us := float(Time.get_ticks_usec() - started) / float(FRAMES)
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
		"frame_us": int(frame_us),
	}
	print("SPIKE ", JSON.stringify(result))
	quit(0 if ok else 1)
