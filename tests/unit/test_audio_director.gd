extends GutTest
## AudioDirector: music states, crossfade players, ducking, tape stop, ambience.

const RAIN := preload("res://assets/generated/audio/garden_loop.wav")

var audio: AudioDirectorService


func before_each() -> void:
	audio = AudioDirectorService.new()
	add_child_autofree(audio)


func test_every_track_file_exists() -> void:
	for track in AudioDirectorService.TRACKS:
		assert_true(ResourceLoader.exists(AudioDirectorService.track_path(track)), track)
		var stream := load(AudioDirectorService.track_path(track)) as AudioStreamOggVorbis
		assert_true(stream.loop, "%s loops" % track)


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
	# leave the signal's call stack before the test frees the director
	await wait_physics_frames(1)
	assert_eq(audio.current, "")
	for player: AudioStreamPlayer in audio._music:
		assert_false(player.playing)


func test_ambience_crossfades_and_fades_out() -> void:
	var rain: AudioStream = RAIN
	audio.set_ambience(rain, -4.0, 0.0)
	assert_eq(audio.ambience_stream, rain)
	audio.set_ambience(null, -4.0, 0.0)
	assert_null(audio.ambience_stream)


func test_silence_twice_does_not_revive_a_fading_bed() -> void:
	var rain: AudioStream = RAIN
	audio.set_ambience(rain, -6.0, 0.0)
	audio.set_ambience(null, -6.0, 0.3)
	await wait_seconds(0.1)
	audio.set_ambience(null)
	await wait_seconds(0.5)
	for player: AudioStreamPlayer in audio._ambience:
		assert_false(player.playing, "the old bed faded out and stopped")


func test_tape_stop_wait_ends_when_new_music_cuts_in() -> void:
	audio.play_music("elysia", 0.0)
	await wait_physics_frames(2)
	var done := [false]
	audio.tape_stopped.connect(func() -> void: done[0] = true, CONNECT_ONE_SHOT)
	audio.tape_stop(2.0)
	audio.play_music("valley", 0.0)
	await wait_physics_frames(1)
	assert_true(done[0], "whoever waits on the tape stop is released")


func test_ui_sounds_exist_in_both_skins() -> void:
	for skin: String in ["elysia", "real"]:
		for sound in AudioDirectorService.UI_SOUNDS:
			var stream := SoundBank.stream("ui_%s_%s" % [skin, sound]) as AudioStreamRandomizer
			assert_gt(stream.streams_count, 0, "%s %s" % [skin, sound])
	audio.ui("move")
	audio.ui("whistle")
	assert_push_error("unknown ui sound")


func test_elysia_loop_shrinks_on_the_downbeat() -> void:
	var never := func(_flag: String) -> bool: return false
	var stone := func(flag: String) -> bool: return flag == "elysia.stone_taken"
	assert_eq(AudioDirectorService.elysia_stage_for(0.0, never), 0)
	assert_eq(AudioDirectorService.elysia_stage_for(160.0, never), 0, "not yet after 160 s")
	assert_eq(AudioDirectorService.elysia_stage_for(310.0, never), 1, "by play time: 5 min")
	assert_eq(AudioDirectorService.elysia_stage_for(610.0, never), 2, "by play time: 10 min")
	assert_eq(AudioDirectorService.elysia_stage_for(10.0, stone), 2, "by progress")
	for entry: Dictionary in AudioDirectorService.ELYSIA_STAGES:
		var stream := (
			load(AudioDirectorService.MUSIC_DIR + str(entry["file"])) as AudioStreamOggVorbis
		)
		assert_true(stream.loop, "%s loops" % entry["file"])
	WorldState.new_game()
	audio.play_music("elysia", 0.0)
	assert_eq(audio.elysia_stage, 0)
	WorldState.set_flag("elysia.chest_tree_opened")
	audio._update_elysia_stage(5.0)
	assert_eq(audio.elysia_stage, 0, "waits for the end of the loop")
	audio._update_elysia_stage(0.03)
	assert_eq(audio.elysia_stage, 1, "switches on the downbeat")
	assert_almost_eq(audio._last_position, 0.03, 0.001, "goes on where the loop is, no repeat")
	var playing := audio._music[audio._active_music].stream.resource_path
	assert_true(playing.ends_with("elysia_half_loop.ogg"), playing)
	WorldState.new_game()


func test_story_sounds_are_written_out_when_captions_are_on() -> void:
	var heard: Array[String] = []
	var record := func(key: String, _at: Variant) -> void: heard.append(key)
	AudioDirector.caption_requested.connect(record)
	Settings.set_value("access.captions", false, false)
	AudioDirector.sfx("stone_wobble", -40.0)
	assert_eq(heard, [] as Array[String], "off by default")
	Settings.set_value("access.captions", true, false)
	AudioDirector.sfx("stone_wobble", -40.0)
	AudioDirector.sfx("coin", -40.0)
	AudioDirector.caption_requested.disconnect(record)
	Settings.set_value("access.captions", false, false)
	assert_eq(heard, ["CAPTION_WOBBLE"] as Array[String], "story sounds only, not rewards")
	for key: String in AudioDirectorService.CAPTIONS.values():
		assert_true(ContentValidator.has_translation(key), key)


func test_crossfade_keeps_its_level_at_the_midpoint() -> void:
	# A fade in dB puts both players near -33 dB halfway (a hole of ~9 dB and more);
	# in amplitude the fading halves add up to about the level they fade between.
	audio.play_music("valley", 0.0)
	var start := db_to_linear(float(AudioDirectorService.TRACK_DB["valley"]))
	audio.play_music("forest", 2.0)
	assert_gt(_midpoint_sum(audio._music), 0.7 * start, "music crossfade without a hole")
	var garden: AudioStream = RAIN
	var rain := load(SoundscapePlayer.bed_path("rain")) as AudioStream
	audio.set_ambience(garden, -6.0, 0.0)
	audio.set_ambience(rain, -6.0, 2.0)
	assert_gt(_midpoint_sum(audio._ambience), 0.7 * db_to_linear(-6.0), "ambience crossfade too")


## Steps every fade of `players` to its middle (1 of 2 s) and sums their amplitudes.
func _midpoint_sum(players: Array[AudioStreamPlayer]) -> float:
	var total := 0.0
	for player in players:
		var tween: Tween = audio._tweens.get(player)
		if tween != null and tween.is_valid():
			tween.custom_step(1.0)
		total += db_to_linear(player.volume_db)
	return total


func test_master_is_limited_and_sfx_sits_lower() -> void:
	# stacked Elysia rewards must not clip; the SFX trim is an effect because the player's
	# volume setting owns the bus volume
	var limiter := AudioServer.get_bus_effect(0, 0) as AudioEffectHardLimiter
	assert_not_null(limiter, "limiter on Master")
	if limiter != null:
		assert_almost_eq(limiter.ceiling_db, -1.0, 0.01)
		assert_almost_eq(limiter.release, 0.1, 0.001)
	var trim := (
		AudioServer.get_bus_effect(AudioServer.get_bus_index(&"SFX"), 0) as AudioEffectAmplify
	)
	assert_not_null(trim, "trim on SFX")
	if trim != null:
		assert_almost_eq(trim.volume_db, -2.0, 0.01)


func test_valley_rests_between_rounds() -> void:
	assert_false(AudioDirectorService.TRACK_REST.has("elysia"), "Elysia shrinks, never rests")
	audio.rest_rules = {
		"valley": {"loops": [2, 2], "rest": [5.0, 5.0], "fade_out": 1.0, "fade_in": 0.5},
	}
	audio.play_music("valley", 0.0)
	var player := audio._music[audio._active_music]
	var length := player.stream.get_length()
	audio._update_rest(0.1, 1.0)
	audio._update_rest(0.1, length - 0.5)
	assert_false(audio.is_resting(), "the first round plays to its end")
	audio._update_rest(0.1, 0.2)
	audio._update_rest(0.1, length - 3.0)
	assert_false(audio.is_resting(), "the second round")
	audio._update_rest(0.1, length - 0.5)
	assert_true(audio.is_resting(), "fades out into the end of the last round")
	audio.duck(true)
	audio._update_rest(5.0, 0.0)
	assert_true(audio.is_resting(), "a dialogue does not wake it, the rest goes on")
	audio._update_rest(0.6, 0.0)
	assert_false(audio.is_resting(), "comes back")
	assert_true(player.playing)
	assert_eq(audio.current, "valley", "the track itself never changed")
	audio.duck(false)
	audio.play_music("forest", 0.0)
	audio._process(0.1)
	assert_false(audio.is_resting(), "other tracks have no rest")
