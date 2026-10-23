class_name AudioDirectorService
extends Node
## Autoload "AudioDirector": music states with crossfades, ambience beds, ducking during
## dialogue and the "tape stop" that ends Elysia's music at the rift (Game Bible §35).
## Scenes name a track ("elysia", "valley", "forest", "antreiber") or "silence"; the same
## track keeps playing across scene changes instead of restarting.
## Music and ambience keep playing while the game is paused (menus).
## Also plays the non-positional sounds: menu sounds in the skin of the current world
## (ui()), rewards and other game sounds (sfx()) and dialogue voices (voice()).
## default_bus_layout.tres ends the Master bus in a hard limiter (-1 dB) so stacked rewards
## never clip, and trims SFX by -2 dB with an effect: the bus volumes belong to Settings.

signal music_changed(track: String)
## A sound that carries the story was played (setting access.captions): the HUD writes it
## out. `at` is its world position, or null for sounds without a place.
signal caption_requested(key: String, at: Variant)
## Fires when a tape stop ends, or is cut short by new music (await tape_stop()).
signal tape_stopped

## Which menu sound set to use: the current world's, or a fixed one (the start menu is Real).
enum SoundSet { FOLLOW, ELYSIA, REAL }

const MUSIC_DIR := "res://assets/generated/music/"
const TRACKS: PackedStringArray = ["elysia", "valley", "forest", "antreiber"]
## Mix level per track (the loops are not loudness-matched by design).
const TRACK_DB := {"elysia": -10.0, "valley": -7.0, "forest": -6.5, "antreiber": -9.5}
const SILENT_DB := -60.0
## SILENT_DB as amplitude: the floor of linear fades.
const MIN_AMPLITUDE := 0.001
const DUCK_DB := -7.0
## Dialogue also takes a little off the ambience, so voices and words sit over the bed.
const AMBIENCE_DUCK_DB := -3.0
const AMBIENCE_DUCK_SECONDS := 0.4
## Rewards that stack up in Elysia take the music down for a moment, so they do not hit the
## limiter together with it: sfx() ducks the music for REWARD_DUCK_SECONDS by REWARD_DUCK_DB
## when the sound's name starts with one of these.
const REWARD_SOUNDS: PackedStringArray = ["coin", "xp", "loot", "level_up", "chest_open", "praise"]
const REWARD_DUCK_DB := -3.0
const REWARD_DUCK_SECONDS := 1.2
## Elysia's loop shrinks the longer the player stays and the further they get (Game Bible
## §35 "Loops werden zunehmend wahrnehmbar"): the same music cut to 8, 4 and 2 bars.
## A stage starts after `after` seconds of play or once `flag` is set; the switch waits for
## the end of the loop, so it lands on the downbeat. The flags are the real trigger: the times
## only catch someone who dawdles (5 and 10 minutes), the loops are 19, 10 and 5 seconds.
const ELYSIA_STAGES: Array[Dictionary] = [
	{"file": "elysia_loop.wav", "after": 0.0, "flag": ""},
	{"file": "elysia_half_loop.wav", "after": 300.0, "flag": "elysia.chest_tree_opened"},
	{"file": "elysia_quarter_loop.wav", "after": 600.0, "flag": "elysia.stone_taken"},
]
## Tracks that rest between rounds, so a short loop does not repeat for an hour: after
## `loops` (min, max) loops the music fades out over the last `fade_out` seconds of a loop,
## stays away for `rest` (min, max) seconds under the ambience and comes back from the top
## (`fade_in`). Elysia never rests: its loop shrinks instead (ELYSIA_STAGES). Rests only
## happen inside a GameScene (the start menu keeps its music), and a scene that asks for the
## resting track again wakes it (play_music).
const TRACK_REST := {
	"valley": {"loops": [2, 3], "rest": [25.0, 50.0], "fade_out": 4.0, "fade_in": 3.0},
}
const UI_SOUNDS: PackedStringArray = ["move", "confirm", "back", "open", "close", "tick"]
## Sounds that tell something (Game Bible §50: hints must not depend on hearing alone).
const CAPTIONS := {
	"frog_croak": "CAPTION_FROGS",
	"goat_bleat": "CAPTION_GOAT",
	"goat_munch": "CAPTION_GOAT_MUNCH",
	"child_hum": "CAPTION_HUM",
	"rift_hum": "CAPTION_RIFT",
	"stone_wobble": "CAPTION_WOBBLE",
	"bird": "CAPTION_BIRD",
	"fire_light": "CAPTION_FIRE",
	"cat_meow": "CAPTION_CAT",
	"purr": "CAPTION_PURR",
}
const POOL_SIZE := 6

var current := ""
## Which ELYSIA_STAGES entry is playing (while the track is "elysia").
var elysia_stage := 0
## TRACK_REST of this director (tests swap in short timings).
var rest_rules: Dictionary = TRACK_REST.duplicate(true)
## What set_ambience() last got: an AudioStream bed or a SoundscapeDef (real world).
var ambience_stream: Resource
var _soundscape: SoundscapePlayer
var _music: Array[AudioStreamPlayer] = []
var _ambience: Array[AudioStreamPlayer] = []
var _active_music := 0
var _active_ambience := 0
var _ducked := false
## Rewards playing right now that duck the music (REWARD_SOUNDS).
var _reward_ducks := 0
## The level the ambience bed (an AudioStream) was asked for, before dialogue ducking.
var _ambience_db := SILENT_DB
var _tweens: Dictionary[Node, Tween] = {}
var _tape_tween: Tween
var _pools: Dictionary[StringName, Array] = {}
var _next_in_pool: Dictionary[StringName, int] = {}
var _last_position := 0.0
## Loops the current track still plays before it rests (TRACK_REST).
var _loops_left := 0
## Seconds until a resting track comes back; negative while it plays.
var _rest_left := -1.0
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_rng.randomize()
	for i in 2:
		_music.append(_make_player("Music%d" % i, &"Music"))
		_ambience.append(_make_player("Ambience%d" % i, &"Ambience"))
	_soundscape = SoundscapePlayer.new()
	_soundscape.name = "Soundscape"
	add_child(_soundscape)
	for bus: StringName in [&"UI", &"SFX", &"Voice"]:
		var pool: Array[AudioStreamPlayer] = []
		for i in POOL_SIZE:
			var player := _make_player("%s%d" % [bus, i], bus)
			player.volume_db = 0.0
			pool.append(player)
		_pools[bus] = pool
		_next_in_pool[bus] = 0


func _exit_tree() -> void:
	# Players that still hold streams and playbacks at exit show up as leaked objects (the
	# soundscape player lets go of its own in its _exit_tree).
	for tween: Tween in _tweens.values():
		if tween.is_valid():
			tween.kill()
	_tweens.clear()
	var players: Array[AudioStreamPlayer] = []
	players.append_array(_music)
	players.append_array(_ambience)
	for pool: Array in _pools.values():
		players.append_array(pool)
	for player in players:
		player.stop()
		player.stream = null
	SoundBank.clear_cache()


func _make_player(player_name: String, bus: StringName) -> AudioStreamPlayer:
	var player := AudioStreamPlayer.new()
	player.name = player_name
	player.bus = bus
	player.volume_db = SILENT_DB
	add_child(player)
	return player


static func track_path(track: String) -> String:
	return MUSIC_DIR + track + "_loop.wav"


## The Elysia stage the game has earned: by play time or by the flags of the stages.
static func elysia_stage_for(playtime: float, has_flag: Callable) -> int:
	var stage := 0
	for i in ELYSIA_STAGES.size():
		var entry := ELYSIA_STAGES[i]
		var flag := str(entry["flag"])
		# the stage flag of the ElysiaDirector (elysia.loops_<n>) is the same fact, set once
		if (
			playtime >= float(entry["after"])
			or (not flag.is_empty() and has_flag.call(flag))
			or (i > 0 and bool(has_flag.call(ElysiaDirector.stage_flag(i))))
		):
			stage = i
	return stage


func wanted_elysia_stage() -> int:
	return elysia_stage_for(WorldState.state.playtime_seconds, WorldState.has_flag)


func _process(delta: float) -> void:
	if current == "elysia":
		_update_elysia_stage(_music[_active_music].get_playback_position())
	elif rest_rules.has(current) and get_tree().current_scene is GameScene:
		_update_rest(delta, _music[_active_music].get_playback_position())


## Swaps to the wanted Elysia stage when the loop has just wrapped around (`position`
## jumped back), so the music never stumbles mid-bar.
func _update_elysia_stage(position: float) -> void:
	var wrapped := position < _last_position
	_last_position = position
	var want := wanted_elysia_stage()
	if want == elysia_stage or not wrapped:
		return
	elysia_stage = want
	var player := _music[_active_music]
	player.stream = load(MUSIC_DIR + str(ELYSIA_STAGES[want]["file"]))
	# All stages begin with the same bars: carry on where the wrapped loop already is (a
	# frame past the downbeat) instead of playing that frame twice.
	position = fmod(position, player.stream.get_length())
	player.play(position)
	_last_position = position
	Log.info(Log.Category.AUDIO, "elysia loop shrinks", {"stage": want})


## Counts the loops of a track with a TRACK_REST rule. The last one fades out into its
## end; after the rest the track comes back from the top with new rounds.
func _update_rest(delta: float, position: float) -> void:
	var rule: Dictionary = rest_rules[current]
	var player := _music[_active_music]
	if is_resting():
		_rest_left -= delta
		if _rest_left <= 0.0:
			_wake(float(rule["fade_in"]))
		return
	if position < _last_position:
		_loops_left -= 1
	_last_position = position
	var left := player.stream.get_length() - position if player.stream != null else 0.0
	if _loops_left > 1 or left > float(rule["fade_out"]):
		return
	var rest: Array = rule["rest"]
	var seconds := _rng.randf_range(float(rest[0]), float(rest[1]))
	_rest_left = left + seconds
	_fade(player, SILENT_DB, left, true)
	Log.info(Log.Category.AUDIO, "music rests", {"track": current, "seconds": roundf(seconds)})


## Ends the rest: the track comes back from the top (or, while it is still fading out into
## the rest, from where it is) and plays new rounds.
func _wake(fade_in: float) -> void:
	_start_rounds()
	var player := _music[_active_music]
	if not player.playing:
		player.volume_db = SILENT_DB
		player.play()
	_fade(player, _music_db(), fade_in, false)
	Log.info(Log.Category.AUDIO, "music returns", {"track": current})


## Whether the current track is resting between its rounds (TRACK_REST).
func is_resting() -> bool:
	return _rest_left >= 0.0


func _start_rounds() -> void:
	_rest_left = -1.0
	_last_position = 0.0
	var rule: Dictionary = rest_rules.get(current, {})
	var loops: Array = rule.get("loops", [0, 0])
	_loops_left = _rng.randi_range(int(loops[0]), int(loops[1]))


static func is_track(track: String) -> bool:
	return track in TRACKS


## Crossfades to `track`, or fades out for "silence"/"". The same track keeps playing.
func play_music(track: String, fade := 2.0) -> void:
	if track == "silence":
		track = ""
	if track == current:
		# A scene that asks for the track it already has also ends its rest: the valley
		# music must be there again for the evening and the ending.
		if is_resting():
			_wake(fade)
		return
	if not track.is_empty() and not is_track(track):
		Log.error(Log.Category.AUDIO, "unknown music track", {"track": track})
		return
	var old := _music[_active_music]
	_fade(old, SILENT_DB, fade, true)
	current = track
	_start_rounds()
	if not track.is_empty():
		_active_music = 1 - _active_music
		var player := _music[_active_music]
		var path := track_path(track)
		if track == "elysia":
			elysia_stage = wanted_elysia_stage()
			path = MUSIC_DIR + str(ELYSIA_STAGES[elysia_stage]["file"])
		player.stream = load(path)
		player.pitch_scale = 1.0
		player.volume_db = SILENT_DB
		player.play()
		_fade(player, _music_db(), fade, false)
	Log.info(Log.Category.AUDIO, "music", {"track": track if not track.is_empty() else "silence"})
	music_changed.emit(current)


func stop_music(fade := 2.0) -> void:
	play_music("", fade)


## Slows the current music down like a tape running out, then stops it. Await the
## returned signal to continue once it is silent (it also fires if new music cuts it short).
func tape_stop(seconds := 2.5) -> Signal:
	var player := _music[_active_music]
	current = ""
	music_changed.emit(current)
	_kill(player)
	var tween := create_tween().set_parallel()
	tween.tween_property(player, ^"pitch_scale", 0.3, seconds).set_ease(Tween.EASE_IN)
	tween.tween_property(player, ^"volume_db", SILENT_DB, seconds).set_ease(Tween.EASE_IN)
	tween.chain().tween_callback(player.stop)
	tween.tween_callback(_release_tape_waiters)
	_tweens[player] = tween
	_tape_tween = tween
	Log.info(Log.Category.AUDIO, "tape stop", {"seconds": seconds})
	return tape_stopped


## Crossfades the ambience: an AudioStream bed (Elysia's perfect loop) or a SoundscapeDef
## (the real world: layered beds and random one-shots, ADR-034). null fades it out.
func set_ambience(stream: Resource, volume_db := -6.0, fade := 2.0) -> void:
	var soundscape := stream as SoundscapeDef
	if stream == ambience_stream:
		# Same ambience: only the level changes. Silence twice stays silence (no revival).
		if soundscape != null:
			_soundscape.play(soundscape, volume_db, fade)
		elif stream != null:
			_ambience_db = volume_db
			_fade(_ambience[_active_ambience], _ambience_target_db(), fade, false)
		return
	var bed := stream as AudioStream
	if stream != null and soundscape == null and bed == null:
		Log.error(Log.Category.AUDIO, "not an ambience", {"resource": stream.resource_path})
		return
	_soundscape.play(soundscape, volume_db, fade)
	_fade(_ambience[_active_ambience], SILENT_DB, fade, true)
	ambience_stream = stream
	if bed == null:
		return
	_active_ambience = 1 - _active_ambience
	var player := _ambience[_active_ambience]
	player.stream = bed
	player.volume_db = SILENT_DB
	player.play()
	_ambience_db = volume_db
	_fade(player, _ambience_target_db(), fade, false)


## Strength of the real world's wind right now (0..1), or -1 without a soundscape. The
## blown leaves follow it, so what you see and hear gusts together.
func wind_gust() -> float:
	return _soundscape.gust if _soundscape.def != null else -1.0


## Lowers the music (and a little of the ambience) while a dialogue is open.
func duck(on: bool) -> void:
	if on == _ducked:
		return
	_ducked = on
	_apply_music_level()
	_soundscape.duck_to(AMBIENCE_DUCK_DB if on else 0.0, AMBIENCE_DUCK_SECONDS)
	if ambience_stream is AudioStream:
		_fade(_ambience[_active_ambience], _ambience_target_db(), AMBIENCE_DUCK_SECONDS, false)


func is_ducked() -> bool:
	return _ducked


## Menu sound ("move", "confirm", "back", "open", "close", "tick"). Elysia's set is glass in
## one major key and never varies (perfectly quantized); the Real set is wood and paper
## and varies a little.
func ui(sound: String, skin := SoundSet.FOLLOW) -> void:
	if not sound in UI_SOUNDS:
		Log.error(Log.Category.AUDIO, "unknown ui sound", {"sound": sound})
		return
	var elysia := (
		WorldState.ui_mode() == GameState.UiMode.ELYSIA
		if skin == SoundSet.FOLLOW
		else skin == SoundSet.ELYSIA
	)
	var prefix := "ui_%s_%s" % ["elysia" if elysia else "real", sound]
	_play(&"UI", SoundBank.stream(prefix, 1.0 if elysia else 1.05, 0.0 if elysia else 1.0), -4.0)


## Asks the HUD to write out a sound, if captions are on and the sound has one.
func caption(prefix: String, at: Variant = null) -> void:
	if CAPTIONS.has(prefix) and Settings.get_bool("access.captions"):
		caption_requested.emit(CAPTIONS[prefix], at)


## A non-positional game sound (rewards, the rift) on the SFX bus. Rewards (REWARD_SOUNDS)
## take the music down for a moment so stacked ones do not hit the limiter with it.
func sfx(prefix: String, volume_db := 0.0, pitch_spread := 1.0) -> void:
	caption(prefix)
	_play(&"SFX", SoundBank.stream(prefix, pitch_spread, 0.0), volume_db)
	for reward in REWARD_SOUNDS:
		if prefix.begins_with(reward):
			_duck_for_reward()
			return


## One syllable of a dialogue voice ("elysia", "warm", "low", "neutral"). Elysia is in
## tune and never varies, like her menu sounds (ui()); the Real voices vary a little.
func voice(kind: String, volume_db := 0.0) -> void:
	var elysia := kind == "elysia"
	_play(
		&"Voice",
		SoundBank.stream("voice_" + kind, 1.0 if elysia else 1.03, 0.0 if elysia else 1.0),
		volume_db
	)


func _play(bus: StringName, stream: AudioStream, volume_db: float) -> void:
	var pool: Array = _pools[bus]
	var index: int = _next_in_pool[bus]
	_next_in_pool[bus] = (index + 1) % pool.size()
	var player: AudioStreamPlayer = pool[index]
	player.stream = stream
	player.volume_db = volume_db
	player.play()


## Deferred, so whoever waits resumes outside the tween callback (and may free us).
func _release_tape_waiters() -> void:
	tape_stopped.emit.call_deferred()


func _duck_for_reward() -> void:
	_reward_ducks += 1
	_apply_music_level()
	await NodeTimer.after(self, REWARD_DUCK_SECONDS)
	_reward_ducks -= 1
	_apply_music_level()


## Moves the music to its current level (dialogue and reward ducks). A resting track comes
## back at the right level by itself.
func _apply_music_level() -> void:
	if not current.is_empty() and not is_resting():
		_fade(_music[_active_music], _music_db(), 0.4, false)


func _music_db() -> float:
	var db := float(TRACK_DB.get(current, -8.0))
	if _ducked:
		db += DUCK_DB
	if _reward_ducks > 0:
		db += REWARD_DUCK_DB
	return db


func _ambience_target_db() -> float:
	return _ambience_db + (AMBIENCE_DUCK_DB if _ducked else 0.0)


func _fade(player: AudioStreamPlayer, target_db: float, seconds: float, stop_after: bool) -> void:
	_kill(player)
	if seconds <= 0.0:
		player.volume_db = target_db
		if stop_after:
			player.stop()
		return
	var tween := create_tween()
	tween_volume(tween, player, target_db, seconds)
	if stop_after:
		tween.tween_callback(player.stop)
	_tweens[player] = tween


## Fades a player's volume in linear amplitude along a sine curve. Two players crossfading
## this way keep their summed level; a fade in dB leaves a hole of about 9 dB mid-fade.
static func tween_volume(
	tween: Tween, player: AudioStreamPlayer, target_db: float, seconds: float
) -> void:
	var set_amplitude := func(amplitude: float) -> void:
		player.volume_db = linear_to_db(maxf(amplitude, MIN_AMPLITUDE))
	var from := db_to_linear(player.volume_db)
	var to := db_to_linear(target_db)
	tween.tween_method(set_amplitude, from, to, seconds).set_trans(Tween.TRANS_SINE)


func _kill(player: AudioStreamPlayer) -> void:
	var old: Tween = _tweens.get(player)
	if old != null and old.is_valid():
		old.kill()
		if old == _tape_tween:
			_release_tape_waiters()
	_tweens.erase(player)
