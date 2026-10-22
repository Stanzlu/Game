extends GutTest
## Polish round 2: resting music wakes up, rewards and dialogue duck, cat sounds, clean exit.

const RAIN := preload("res://assets/generated/audio/garden_loop.wav")

var audio: AudioDirectorService


func before_each() -> void:
	audio = AudioDirectorService.new()
	add_child_autofree(audio)


func test_asking_for_the_resting_track_brings_the_music_back() -> void:
	# The evening and the ending ask for "valley" again; a rest must not swallow that.
	audio.rest_rules = {
		"valley": {"loops": [1, 1], "rest": [60.0, 60.0], "fade_out": 1.0, "fade_in": 0.5},
	}
	audio.play_music("valley", 0.0)
	var player := audio._music[audio._active_music]
	audio._update_rest(0.1, player.stream.get_length() - 0.5)
	assert_true(audio.is_resting())
	audio._fade(player, AudioDirectorService.SILENT_DB, 0.0, true)
	assert_false(player.playing, "the music is gone")
	audio.play_music("valley", 3.0)
	assert_false(audio.is_resting(), "asked for again: the rest is over")
	assert_true(player.playing, "playing from the top")
	assert_lt(player.volume_db, -30.0, "fading in, not jumping in")
	assert_true(audio._tweens.has(player), "there is a fade running")
	assert_gt(audio._loops_left, 0, "new rounds")


func test_asking_for_the_track_while_it_fades_into_the_rest_keeps_it_playing() -> void:
	audio.rest_rules = {
		"valley": {"loops": [1, 1], "rest": [60.0, 60.0], "fade_out": 4.0, "fade_in": 0.5},
	}
	audio.play_music("valley", 0.0)
	var player := audio._music[audio._active_music]
	audio._update_rest(0.1, player.stream.get_length() - 3.0)
	assert_true(audio.is_resting())
	assert_true(player.playing, "still fading out")
	audio.play_music("valley", 1.0)
	assert_false(audio.is_resting())
	assert_true(player.playing)


func test_rests_only_happen_in_a_game_scene() -> void:
	# The start menu is no GameScene (GUT's current scene is none either): its music never rests.
	audio.rest_rules = {
		"valley": {"loops": [1, 1], "rest": [60.0, 60.0], "fade_out": 1.0, "fade_in": 0.5},
	}
	audio.play_music("valley", 0.0)
	var player := audio._music[audio._active_music]
	player.seek(player.stream.get_length() - 0.5)
	audio._process(0.1)
	assert_false(audio.is_resting(), "no rest outside a game scene")


func test_valley_rest_is_short_enough_for_a_scene() -> void:
	var rest: Array = AudioDirectorService.TRACK_REST["valley"]["rest"]
	assert_lte(float(rest[1]), 50.0, "the rest is shorter than a minute")
	assert_gte(float(rest[0]), 20.0)


func test_rewards_duck_the_music_for_a_moment() -> void:
	audio.play_music("elysia", 0.0)
	var normal := audio._music_db()
	audio.sfx("coin", -40.0)
	assert_almost_eq(audio._music_db(), normal + AudioDirectorService.REWARD_DUCK_DB, 0.01)
	audio.sfx("loot_rare", -40.0)
	audio.sfx("move_not_a_reward", -40.0)
	assert_push_error("no sound files")
	assert_almost_eq(
		audio._music_db(), normal + AudioDirectorService.REWARD_DUCK_DB, 0.01, "no stacking"
	)
	await wait_seconds(AudioDirectorService.REWARD_DUCK_SECONDS + 0.3)
	assert_almost_eq(audio._music_db(), normal, 0.01, "the music comes back")


func test_dialogue_ducks_the_ambience_too() -> void:
	var bed: AudioStream = RAIN
	audio.set_ambience(bed, -6.0, 0.0)
	var player := audio._ambience[audio._active_ambience]
	assert_almost_eq(player.volume_db, -6.0, 0.01)
	audio.duck(true)
	await wait_seconds(AudioDirectorService.AMBIENCE_DUCK_SECONDS + 0.2)
	assert_almost_eq(player.volume_db, -6.0 + AudioDirectorService.AMBIENCE_DUCK_DB, 0.3)
	audio.duck(false)
	await wait_seconds(AudioDirectorService.AMBIENCE_DUCK_SECONDS + 0.2)
	assert_almost_eq(player.volume_db, -6.0, 0.3, "back to the asked level")


func test_dialogue_ducks_the_soundscape() -> void:
	var def := load("res://content/audio/tal_regentag.tres") as SoundscapeDef
	audio.set_ambience(def, -8.0, 0.0)
	audio.duck(true)
	await wait_seconds(AudioDirectorService.AMBIENCE_DUCK_SECONDS + 0.2)
	assert_almost_eq(audio._soundscape._duck_db, AudioDirectorService.AMBIENCE_DUCK_DB, 0.3)
	audio.duck(false)
	await wait_seconds(AudioDirectorService.AMBIENCE_DUCK_SECONDS + 0.2)
	assert_almost_eq(audio._soundscape._duck_db, 0.0, 0.3)


func test_elysia_speaks_in_tune_and_the_real_voices_vary() -> void:
	audio.voice("elysia", -40.0)
	var elysia := audio._pools[&"Voice"][0].stream as AudioStreamRandomizer
	assert_eq(elysia.random_pitch, 1.0, "Elysia is never out of tune")
	assert_eq(elysia.random_volume_offset_db, 0.0)
	audio.voice("warm", -40.0)
	var warm := audio._pools[&"Voice"][1].stream as AudioStreamRandomizer
	assert_gt(warm.random_pitch, 1.0, "Real voices vary a little")


func test_cat_sounds_are_written_out() -> void:
	assert_eq(AudioDirectorService.CAPTIONS["cat_meow"], "CAPTION_CAT")
	assert_eq(AudioDirectorService.CAPTIONS["purr"], "CAPTION_PURR")
	for sound: String in [
		"cat_meow", "cat_meow_muffled", "purr", "stand", "sit", "bird", "bark", "wood_drop"
	]:
		var stream := SoundBank.stream(sound) as AudioStreamRandomizer
		assert_gt(stream.streams_count, 0, sound)


func test_leaving_the_tree_lets_go_of_streams() -> void:
	audio.play_music("valley", 0.0)
	audio.sfx("coin", -40.0)
	audio.set_ambience(RAIN, -6.0, 0.0)
	audio._exit_tree()
	for player: AudioStreamPlayer in audio._music + audio._ambience:
		assert_false(player.playing)
		assert_null(player.stream)
	for player: AudioStreamPlayer in audio._pools[&"SFX"]:
		assert_null(player.stream)


func test_footstep_levels_stay_close_and_tall_grass_does_not_jump() -> void:
	var levels := FootstepPlayer.SURFACE_DB
	for column: int in [0, 1]:
		var low := 99.0
		var high := -99.0
		for surface: StringName in [&"grass", &"dirt", &"stone", &"wood", &"puddle", &"water"]:
			var db: float = levels[surface][column]
			low = minf(low, db)
			high = maxf(high, db)
		assert_lte(high - low, 6.0, "ground levels within 6 dB (%s)" % ["walk", "run"][column])
		assert_lte(
			absf(float(levels[&"tall_grass"][column]) - float(levels[&"grass"][column])),
			3.0,
			"grass to tall grass: no jump"
		)
