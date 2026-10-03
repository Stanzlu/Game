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
const UI_SOUNDS: PackedStringArray = ["move", "confirm", "back", "open", "close", "tick"]
const POOL_SIZE := 6

var current := ""
var ambience_stream: AudioStream
var _music: Array[AudioStreamPlayer] = []
var _ambience: Array[AudioStreamPlayer] = []
var _active_music := 0
var _active_ambience := 0
var _ducked := false
var _tweens: Dictionary[Node, Tween] = {}
var _tape_tween: Tween
var _pools: Dictionary[StringName, Array] = {}
var _next_in_pool: Dictionary[StringName, int] = {}


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for i in 2:
		_music.append(_make_player("Music%d" % i, &"Music"))
		_ambience.append(_make_player("Ambience%d" % i, &"Ambience"))
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
		player.stream = load(track_path(track))
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


## Crossfades the ambience bed (rain, birds, wind). null fades it out.
func set_ambience(stream: AudioStream, volume_db := -6.0, fade := 2.0) -> void:
	if stream == ambience_stream:
		# Same bed: only the level changes. Silence twice stays silence (no revival).
		if stream != null:
			_fade(_ambience[_active_ambience], volume_db, fade, false)
		return
	_fade(_ambience[_active_ambience], SILENT_DB, fade, true)
	ambience_stream = stream
	if stream == null:
		return
	_active_ambience = 1 - _active_ambience
	var player := _ambience[_active_ambience]
	player.stream = stream
	player.volume_db = SILENT_DB
	player.play()
	_fade(player, volume_db, fade, false)


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
