class_name SoundscapePlayer
extends Node
## Plays a SoundscapeDef (ADR-034): each bed loops twice, panned left and right half a loop
## apart (wide and never in phase with itself), and one-shots fire at random intervals
## from random directions. Wind gusts come from slow noise, so they never repeat either;
## beds that follow the wind swell with them and the blown leaves use the same signal
## (AudioDirector.wind_gust()). Lives inside AudioDirector and keeps playing in menus.

const BED_DIR := "res://assets/generated/audio/"
const SILENT_DB := -60.0
## Pan buses for direction; the centre is the Ambience bus itself. All of them send into
## Ambience, so the player's ambience volume applies.
const PAN_BUSES: Array = [
	[&"NatureL2", -0.85], [&"NatureL1", -0.45], [&"NatureR1", 0.45], [&"NatureR2", 0.85]
]
const POOL_SIZE := 8

var def: SoundscapeDef
## Wind gust strength right now, 0 (calm) .. 1 (strong push).
var gust := 0.0

var _volume_db := -6.0
## Fade level on top of the volume, tweened in and out.
var _fade_db := SILENT_DB
## {"players": Array[AudioStreamPlayer], "db": float, "gust": float}
var _beds: Array[Dictionary] = []
## {"event": Dictionary, "next": float}
var _events: Array[Dictionary] = []
var _pool: Array[AudioStreamPlayer] = []
var _next_in_pool := 0
var _time := 0.0
var _noise := FastNoiseLite.new()
var _rng := RandomNumberGenerator.new()
var _tween: Tween


static func bed_path(sound: String) -> String:
	return BED_DIR + "nature_%s_bed.wav" % sound


## Creates the pan buses once (they are not in the bus layout file).
static func ensure_buses() -> void:
	for entry: Array in PAN_BUSES:
		if AudioServer.get_bus_index(entry[0]) != -1:
			continue
		AudioServer.add_bus()
		var index := AudioServer.bus_count - 1
		AudioServer.set_bus_name(index, entry[0])
		AudioServer.set_bus_send(index, &"Ambience")
		var panner := AudioEffectPanner.new()
		panner.pan = entry[1]
		AudioServer.add_bus_effect(index, panner)


## The bus closest to a pan position (-1 left .. 1 right).
static func bus_for_pan(pan: float) -> StringName:
	var best: StringName = &"Ambience"
	var best_distance := absf(pan)
	for entry: Array in PAN_BUSES:
		var distance := absf(pan - float(entry[1]))
		if distance < best_distance:
			best_distance = distance
			best = entry[0]
	return best


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	ensure_buses()
	_rng.randomize()
	_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	_noise.seed = _rng.randi()
	_noise.frequency = 1.0
	for i in POOL_SIZE:
		var player := AudioStreamPlayer.new()
		player.name = "Event%d" % i
		player.bus = &"Ambience"
		add_child(player)
		_pool.append(player)


## Starts `new_def` (null fades out). The same definition only changes the level.
func play(new_def: SoundscapeDef, volume_db := -6.0, fade := 2.0) -> void:
	_volume_db = volume_db
	if new_def == def:
		if def != null:
			_fade_to(0.0, fade)
		return
	_release_beds(fade)
	_events.clear()
	def = new_def
	if def == null:
		Log.info(Log.Category.AUDIO, "soundscape off")
		return
	for bed: Dictionary in def.beds:
		_add_bed(bed)
	for event: Dictionary in def.events:
		var every: Array = event["every"]
		# the first call comes soon, the place should not start silent
		var first := _rng.randf_range(float(every[0]) * 0.2, float(every[1]) * 0.5)
		_events.append({"event": event, "next": _time + first})
	_fade_db = SILENT_DB
	_fade_to(0.0, fade)
	Log.info(
		Log.Category.AUDIO,
		"soundscape",
		{"def": def.resource_path.get_file(), "beds": def.beds.size(), "events": def.events.size()}
	)


func stop(fade := 2.0) -> void:
	play(null, _volume_db, fade)


func _process(delta: float) -> void:
	_time += delta
	if def == null:
		gust = 0.0
		return
	gust = gust_at(_time)
	for bed in _beds:
		var db := float(bed["db"]) + _volume_db + _fade_db + _gust_db(float(bed["gust"]))
		for player: AudioStreamPlayer in bed["players"]:
			player.volume_db = db
	for entry in _events:
		if _time >= float(entry["next"]):
			var event: Dictionary = entry["event"]
			_fire(event)
			entry["next"] = _time + _interval(event)


## Gust strength at time `t`: slow noise, squared so calm stretches alternate with pushes,
## scaled by how windy the definition is.
func gust_at(t: float) -> float:
	var n := _noise.get_noise_1d(t * 0.09) + 0.5 * _noise.get_noise_1d(t * 0.31 + 100.0)
	var g := clampf(0.5 + 0.8 * n, 0.0, 1.0)
	return clampf(g * g * (def.wind * 2.0 if def != null else 0.0), 0.0, 1.0)


func _gust_db(follow: float) -> float:
	if follow <= 0.0:
		return 0.0
	return linear_to_db(lerpf(1.0, 0.18 + 1.1 * gust, follow))


func _interval(event: Dictionary) -> float:
	var every: Array = event["every"]
	var seconds := _rng.randf_range(float(every[0]), float(every[1]))
	if event.get("gust", false):
		seconds *= lerpf(1.6, 0.35, gust)
	return seconds


func _fire(event: Dictionary) -> void:
	var player := _pool[_next_in_pool]
	_next_in_pool = (_next_in_pool + 1) % _pool.size()
	var pan := float(event.get("pan", 0.8))
	player.bus = bus_for_pan(_rng.randf_range(-pan, pan))
	player.stream = SoundBank.stream(
		"nature_" + str(event["sound"]), float(event.get("pitch", 1.04)), 0.0
	)
	player.volume_db = (
		float(event.get("db", -12.0)) + _volume_db + _fade_db + _rng.randf_range(-5.0, 1.0)
	)
	player.play()


func _add_bed(bed: Dictionary) -> void:
	var stream := load(bed_path(str(bed["sound"]))) as AudioStream
	if stream == null:
		Log.error(Log.Category.AUDIO, "soundscape bed missing", {"sound": bed["sound"]})
		return
	var players: Array[AudioStreamPlayer] = []
	var half := stream.get_length() * 0.5
	for side: Array in [PAN_BUSES[0], PAN_BUSES[3]]:
		var player := AudioStreamPlayer.new()
		player.name = "Bed_%s_%s" % [bed["sound"], side[0]]
		player.stream = stream
		player.bus = side[0]
		player.volume_db = SILENT_DB
		add_child(player)
		player.play(half if players.size() == 1 else 0.0)
		players.append(player)
	_beds.append(
		{"players": players, "db": float(bed.get("db", -8.0)), "gust": float(bed.get("gust", 0.0))}
	)


## Fades the current beds out and frees them; new beds fade in on their own.
func _release_beds(fade: float) -> void:
	for bed in _beds:
		for player: AudioStreamPlayer in bed["players"]:
			if fade <= 0.0:
				player.queue_free()
				continue
			var tween := player.create_tween()
			tween.tween_property(player, ^"volume_db", SILENT_DB, fade)
			tween.tween_callback(player.queue_free)
	_beds.clear()


func _fade_to(target_db: float, seconds: float) -> void:
	if _tween != null:
		_tween.kill()
	if seconds <= 0.0:
		_fade_db = target_db
		return
	_tween = create_tween()
	_tween.tween_property(self, ^"_fade_db", target_db, seconds)
