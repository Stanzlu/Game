class_name AudioDirectorService
extends Node
## Autoload "AudioDirector": music states with crossfades, ambience beds, ducking during
## dialogue and the "tape stop" that ends Elysia's music at the rift (Game Bible §35).
## Scenes name a track ("elysia", "valley", "forest", "antreiber") or "silence"; the same
## track keeps playing across scene changes instead of restarting.
## Music and ambience keep playing while the game is paused (menus).
## Also plays the non-positional sounds: menu sounds in the skin of the current world
## (ui()), rewards and other game sounds (sfx()) and dialogue voices (voice()).

signal music_changed(track: String)
## Fires when a tape stop ends, or is cut short by new music (await tape_stop()).
signal tape_stopped

## Which menu sound set to use: the current world's, or a fixed one (the start menu is Real).
enum SoundSet { FOLLOW, ELYSIA, REAL }

const MUSIC_DIR := "res://assets/generated/music/"
const TRACKS: PackedStringArray = ["elysia", "valley", "forest", "antreiber"]
## Mix level per track (the loops are not loudness-matched by design).
const TRACK_DB := {"elysia": -9.0, "valley": -6.0, "forest": -8.0, "antreiber": -10.0}
const SILENT_DB := -60.0
const DUCK_DB := -7.0
## Elysia's loop shrinks the longer the player stays and the further they get (Game Bible
## §35 "Loops werden zunehmend wahrnehmbar"): the same music cut to 8, 4 and 2 bars.
## A stage starts after `after` seconds of play or once `flag` is set; the switch waits for
## the end of the loop, so it lands on the downbeat.
const ELYSIA_STAGES: Array[Dictionary] = [
	{"file": "elysia_loop.wav", "after": 0.0, "flag": ""},
	{"file": "elysia_half_loop.wav", "after": 150.0, "flag": "elysia.chest_tree_opened"},
	{"file": "elysia_quarter_loop.wav", "after": 300.0, "flag": "elysia.stone_taken"},
]
const UI_SOUNDS: PackedStringArray = ["move", "confirm", "back", "open", "close", "tick"]
const POOL_SIZE := 6

var current := ""
## Which ELYSIA_STAGES entry is playing (while the track is "elysia").
var elysia_stage := 0
## What set_ambience() last got: an AudioStream bed or a SoundscapeDef (real world).
var ambience_stream: Resource
var _soundscape: SoundscapePlayer
var _music: Array[AudioStreamPlayer] = []
var _ambience: Array[AudioStreamPlayer] = []
var _active_music := 0
var _active_ambience := 0
var _ducked := false
var _tweens: Dictionary[Node, Tween] = {}
var _tape_tween: Tween
var _pools: Dictionary[StringName, Array] = {}
var _next_in_pool: Dictionary[StringName, int] = {}
var _last_position := 0.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
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
		if playtime >= float(entry["after"]) or (not flag.is_empty() and has_flag.call(flag)):
			stage = i
	return stage


func wanted_elysia_stage() -> int:
	return elysia_stage_for(WorldState.state.playtime_seconds, WorldState.has_flag)


func _process(_delta: float) -> void:
	if current == "elysia":
		_update_elysia_stage(_music[_active_music].get_playback_position())


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
	player.play()
	_last_position = 0.0
	Log.info(Log.Category.AUDIO, "elysia loop shrinks", {"stage": want})


static func is_track(track: String) -> bool:
	return track in TRACKS


## Crossfades to `track`, or fades out for "silence"/"". The same track keeps playing.
func play_music(track: String, fade := 2.0) -> void:
	if track == "silence":
		track = ""
	if track == current:
		return
	if not track.is_empty() and not is_track(track):
		Log.error(Log.Category.AUDIO, "unknown music track", {"track": track})
		return
	var old := _music[_active_music]
	_fade(old, SILENT_DB, fade, true)
	current = track
	if not track.is_empty():
		_active_music = 1 - _active_music
		var player := _music[_active_music]
		var path := track_path(track)
		if track == "elysia":
			elysia_stage = wanted_elysia_stage()
			path = MUSIC_DIR + str(ELYSIA_STAGES[elysia_stage]["file"])
		_last_position = 0.0
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
			_fade(_ambience[_active_ambience], volume_db, fade, false)
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
	_fade(player, volume_db, fade, false)


## Strength of the real world's wind right now (0..1), or -1 without a soundscape. The
## blown leaves follow it, so what you see and hear gusts together.
func wind_gust() -> float:
	return _soundscape.gust if _soundscape.def != null else -1.0


## Lowers the music while a dialogue is open.
func duck(on: bool) -> void:
	if on == _ducked:
		return
	_ducked = on
	if not current.is_empty():
		_fade(_music[_active_music], _music_db(), 0.4, false)


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


## A non-positional game sound (rewards, the rift) on the SFX bus.
func sfx(prefix: String, volume_db := 0.0, pitch_spread := 1.0) -> void:
	_play(&"SFX", SoundBank.stream(prefix, pitch_spread, 0.0), volume_db)


## One syllable of a dialogue voice ("elysia", "warm", "low", "neutral").
func voice(kind: String, volume_db := 0.0) -> void:
	_play(&"Voice", SoundBank.stream("voice_" + kind, 1.03, 1.0), volume_db)


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


func _music_db() -> float:
	return float(TRACK_DB.get(current, -8.0)) + (DUCK_DB if _ducked else 0.0)


func _fade(player: AudioStreamPlayer, target_db: float, seconds: float, stop_after: bool) -> void:
	_kill(player)
	if seconds <= 0.0:
		player.volume_db = target_db
		if stop_after:
			player.stop()
		return
	var tween := create_tween()
	tween.tween_property(player, ^"volume_db", target_db, seconds)
	if stop_after:
		tween.tween_callback(player.stop)
	_tweens[player] = tween


func _kill(player: AudioStreamPlayer) -> void:
	var old: Tween = _tweens.get(player)
	if old != null and old.is_valid():
		old.kill()
		if old == _tape_tween:
			_release_tape_waiters()
	_tweens.erase(player)
