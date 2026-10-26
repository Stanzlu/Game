extends SceneTree
## Plays the soundscapes one after the other, each at the ambience level of its scene, for
## measuring them with tools/audio/measure.sh (the soundscape check in check_levels.py is
## fitted to this). Run as a script: godot -s tools/audio/bed_probe.gd
## Segment i plays SEGMENT_SECONDS of CASES[i]; the frame budget is CASES.size() * 36 * 30.

const SEGMENT_SECONDS := 36
const FPS := 30
const CASES: Array[Array] = [
	["res://content/audio/tal_regentag.tres", -5.5],
	["res://content/audio/tal_abend.tres", -8.0],
	["res://content/audio/tal_nacht.tres", -4.0],
	["res://content/audio/haus_kalt.tres", -5.0],
	["res://content/audio/haus_feuer.tres", -5.0],
	["res://content/audio/wald_nacht.tres", -5.0],
	["res://content/audio/tal_morgen.tres", -7.0],
	["res://content/audio/haus_morgen.tres", -5.0],
]

var _frame := 0


func _process(_delta: float) -> bool:
	var director := root.get_node_or_null("AudioDirector")
	if director == null:
		return false
	var segment := _frame / (SEGMENT_SECONDS * FPS)
	if segment >= CASES.size():
		quit()
		return true
	if _frame % (SEGMENT_SECONDS * FPS) == 0:
		var entry := CASES[segment]
		print("SEGMENT ", segment, " ", entry[0])
		director.call("set_ambience", load(str(entry[0])), float(entry[1]), 0.0)
	_frame += 1
	return false
