class_name SoundBank
extends RefCounted
## Builds randomized streams from numbered files: <dir>/<prefix>_0.wav, _1.wav, ...
## or a single <dir>/<prefix>.wav. Swapping placeholder audio means replacing files only.

const SOUND_DIR := "res://assets/placeholder/audio/"
const MAX_VARIANTS := 8

static var _cache: Dictionary = {}


static func stream(
	prefix: String, pitch_spread: float = 1.08, volume_spread_db: float = 1.5
) -> AudioStream:
	if _cache.has(prefix):
		return _cache[prefix]
	var randomizer := AudioStreamRandomizer.new()
	randomizer.random_pitch = pitch_spread
	randomizer.random_volume_offset_db = volume_spread_db
	for i in MAX_VARIANTS:
		var path := "%s%s_%d.wav" % [SOUND_DIR, prefix, i]
		if not ResourceLoader.exists(path):
			break
		randomizer.add_stream(-1, load(path))
	if randomizer.streams_count == 0:
		var single := "%s%s.wav" % [SOUND_DIR, prefix]
		if ResourceLoader.exists(single):
			randomizer.add_stream(-1, load(single))
	if randomizer.streams_count == 0:
		Log.error(Log.Category.AUDIO, "no sound files for prefix", {"prefix": prefix})
	_cache[prefix] = randomizer
	return randomizer


## One-shot positional sound that frees itself.
static func play_at(parent: Node, prefix: String, at: Vector2, volume_db: float = 0.0) -> void:
	var player := AudioStreamPlayer2D.new()
	player.stream = stream(prefix)
	player.bus = &"SFX"
	player.volume_db = volume_db
	parent.add_child(player)
	player.global_position = at
	player.finished.connect(player.queue_free)
	player.play()
