extends GutTest
## Game Bible §12 / ADR-034: the real world's soundscape is layered, wide and never repeats;
## Elysia keeps its single perfect loop.

const DEFS: PackedStringArray = [
	"res://content/audio/tal_regentag.tres",
	"res://content/audio/tal_abend.tres",
	"res://content/audio/tal_nacht.tres",
	"res://content/audio/wald_nacht.tres",
]

var audio: AudioDirectorService


func before_each() -> void:
	audio = AudioDirectorService.new()
	add_child_autofree(audio)


func test_definitions_point_at_existing_sounds() -> void:
	for path in DEFS:
		var def := load(path) as SoundscapeDef
		assert_not_null(def, path)
		if def == null:
			continue
		assert_eq(def.problems(), PackedStringArray(), path)
		assert_gt(def.beds.size(), 1, "%s: layered beds" % path)
		assert_gt(def.events.size(), 3, "%s: things happen" % path)


func test_pan_buses_send_into_ambience() -> void:
	SoundscapePlayer.ensure_buses()
	for entry: Array in SoundscapePlayer.PAN_BUSES:
		var index := AudioServer.get_bus_index(entry[0])
		assert_ne(index, -1, str(entry[0]))
		assert_eq(AudioServer.get_bus_send(index), &"Ambience", "volume setting applies")
		var panner := AudioServer.get_bus_effect(index, 0) as AudioEffectPanner
		assert_almost_eq(panner.pan, float(entry[1]), 0.001)
	assert_eq(SoundscapePlayer.bus_for_pan(-1.0), &"NatureL2")
	assert_eq(SoundscapePlayer.bus_for_pan(0.1), &"Ambience")
	assert_eq(SoundscapePlayer.bus_for_pan(0.5), &"NatureR1")


func test_beds_play_wide_and_events_come_at_random() -> void:
	var def := load(DEFS[0]) as SoundscapeDef
	audio.set_ambience(def, -6.0, 0.0)
	assert_eq(audio.ambience_stream, def)
	var scape := audio._soundscape
	assert_eq(scape._beds.size(), def.beds.size())
	for bed in scape._beds:
		var players: Array = bed["players"]
		assert_eq(players.size(), 2, "left and right")
		assert_ne((players[0] as AudioStreamPlayer).bus, (players[1] as AudioStreamPlayer).bus)
	# a minute of soundscape: events fire, at irregular intervals, and the wind gusts
	var fired := {}
	var gusts: Array[float] = []
	var gaps: Array[float] = []
	for i in 600:
		var before: Array[float] = []
		for entry in scape._events:
			before.append(float(entry["next"]))
		scape._process(0.1)
		for k in scape._events.size():
			var after := float(scape._events[k]["next"])
			if after != before[k]:
				fired[scape._events[k]["event"]["sound"]] = true
				gaps.append(after - scape._time)
		gusts.append(scape.gust)
	assert_gt(fired.size(), 2, "several kinds of things happened")
	assert_gt(gaps.max() - gaps.min(), 1.0, "never on a beat")
	assert_gt(gusts.max() - gusts.min(), 0.2, "the wind comes in gusts")
	assert_true(audio.wind_gust() >= 0.0, "the leaves can follow the wind")


func test_switching_back_to_a_loop_ends_the_soundscape() -> void:
	audio.set_ambience(load(DEFS[1]), -8.0, 0.0)
	await wait_physics_frames(1)
	audio.set_ambience(load("res://assets/generated/audio/garden_loop.wav"), -6.0, 0.0)
	await wait_physics_frames(2)
	assert_null(audio._soundscape.def)
	assert_eq(audio._soundscape._beds.size(), 0)
	assert_eq(audio.wind_gust(), -1.0, "Elysia's wind is no gusty wind")
