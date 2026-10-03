extends GutTest
## AudioDirector: music states, crossfade players, ducking, tape stop, ambience.

var audio: AudioDirectorService


func before_each() -> void:
	audio = AudioDirectorService.new()
	add_child_autofree(audio)


func test_every_track_file_exists() -> void:
	for track in AudioDirectorService.TRACKS:
		assert_true(ResourceLoader.exists(AudioDirectorService.track_path(track)), track)
		var stream := load(AudioDirectorService.track_path(track)) as AudioStreamWAV
		assert_eq(stream.loop_mode, AudioStreamWAV.LOOP_FORWARD, "%s loops" % track)


func test_play_switches_and_same_track_keeps_playing() -> void:
	watch_signals(audio)
	audio.play_music("elysia", 0.0)
	assert_eq(audio.current, "elysia")
	audio.play_music("elysia", 0.0)
	assert_signal_emit_count(audio, "music_changed", 1, "same track does not restart")
	audio.play_music("forest", 0.0)
	assert_eq(audio.current, "forest")
	audio.play_music("silence", 0.0)
	assert_eq(audio.current, "")


func test_unknown_track_is_refused() -> void:
	audio.play_music("elysia", 0.0)
	audio.play_music("techno", 0.0)
	assert_push_error("unknown music track")
	assert_eq(audio.current, "elysia")


func test_duck_lowers_the_music_level() -> void:
	audio.play_music("valley", 0.0)
	var normal := audio._music_db()
	audio.duck(true)
	assert_true(audio.is_ducked())
	assert_almost_eq(audio._music_db(), normal + AudioDirectorService.DUCK_DB, 0.01)
	audio.duck(false)
	assert_almost_eq(audio._music_db(), normal, 0.01)


func test_tape_stop_slows_down_and_ends_silent() -> void:
	audio.play_music("elysia", 0.0)
	await wait_physics_frames(2)
	await audio.tape_stop(0.3)
	assert_eq(audio.current, "")
	for player: AudioStreamPlayer in audio._music:
		assert_false(player.playing)


func test_ambience_crossfades_and_fades_out() -> void:
	var rain: AudioStream = load("res://assets/generated/audio/rain_loop.wav")
	audio.set_ambience(rain, -4.0, 0.0)
	assert_eq(audio.ambience_stream, rain)
	audio.set_ambience(null, -4.0, 0.0)
	assert_null(audio.ambience_stream)
