class_name SoundBank
extends RefCounted
## Builds randomized streams from numbered files: <dir>/<prefix>_0.wav, _1.wav, ...
## or a single <dir>/<prefix>.wav. Swapping placeholder audio means replacing files only.
## Generated sounds (tools/audio/make_sfx.py) are looked up first, then the placeholders.

const SOUND_DIR := "res://assets/placeholder/audio/"
const GENERATED_DIR := "res://assets/generated/sfx/"
const MAX_VARIANTS := 8
## Reach of a positional sound in pixels (the valley is ~1000 px wide, the view 512): what is
## further off than this is not heard, so a frog that "comes closer" (ADR-042) also sounds closer.
const HEARING_DISTANCE := 360.0
const HEARING_ATTENUATION := 1.5

static var _cache: Dictionary = {}


## Drops the cached randomizers, at exit (AudioDirector): they hold the loaded streams.
static func clear_cache() -> void:
	_cache.clear()


static func stream(
	prefix: String, pitch_spread: float = 1.08, volume_spread_db: float = 1.5
) -> AudioStream:
	var key := "%s|%s|%s" % [prefix, pitch_spread, volume_spread_db]
	if _cache.has(key):
		return _cache[key]
	var randomizer := AudioStreamRandomizer.new()
	randomizer.random_pitch = pitch_spread
	randomizer.random_volume_offset_db = volume_spread_db
	for dir: String in [GENERATED_DIR, SOUND_DIR]:
		for i in MAX_VARIANTS:
			var path := "%s%s_%d.wav" % [dir, prefix, i]
			if not ResourceLoader.exists(path):
				break
			randomizer.add_stream(-1, load(path))
		if randomizer.streams_count == 0:
			var single := "%s%s.wav" % [dir, prefix]
			if ResourceLoader.exists(single):
				randomizer.add_stream(-1, load(single))
		if randomizer.streams_count > 0:
			break
	if randomizer.streams_count == 0:
		Log.error(Log.Category.AUDIO, "no sound files for prefix", {"prefix": prefix})
	_cache[key] = randomizer
	return randomizer


## One-shot positional sound that frees itself. `max_distance` is how far it carries, for
## sounds that must be heard from further (or less far) than HEARING_DISTANCE.
static func play_at(
	parent: Node,
	prefix: String,
	at: Vector2,
	volume_db: float = 0.0,
	max_distance: float = HEARING_DISTANCE
) -> void:
	AudioDirector.caption(prefix, at)
	var player := AudioStreamPlayer2D.new()
	player.stream = stream(prefix)
	player.bus = &"SFX"
	player.volume_db = volume_db
	player.max_distance = max_distance
	player.attenuation = HEARING_ATTENUATION
	player.panning_strength = 1.0
	parent.add_child(player)
	player.global_position = at
	player.finished.connect(player.queue_free)
	player.play()
