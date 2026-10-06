class_name SoundscapeDef
extends Resource
## A real-world soundscape (Game Bible §12, ADR-034): looping beds plus one-shots at random
## times from random directions, so the real world never repeats the way Elysia's single
## loop does. Played by SoundscapePlayer (inside AudioDirector); scenes and DayLight hand a
## .tres from content/audio/ to AudioDirector.set_ambience() like any ambience stream.
##
## beds: {"sound": "rain", "db": -8.0, "gust": 0.0..1.0}. Plays
##   assets/generated/audio/nature_<sound>_bed.wav twice, panned left and right half a loop
##   apart. "gust" is how far its volume follows the wind gusts (0 = steady).
## events: {"sound": "blackbird", "every": [min, max] seconds, "db": -14.0, "pan": 0..1,
##   "pitch": 1.04, "gust": bool}. Plays a SoundBank variant of nature_<sound>; "pan" is how
##   far to the sides it may come from, "gust" makes it more frequent in strong gusts.

## How stormy the wind is (0 calm .. 1 stormy); scales the gust signal.
@export_range(0.0, 1.0) var wind := 0.5
@export var beds: Array[Dictionary] = []
@export var events: Array[Dictionary] = []


## Problems with this definition (missing keys or files), for tests and the validator.
func problems() -> PackedStringArray:
	var out: PackedStringArray = []
	for bed in beds:
		if not bed.has("sound"):
			out.append("bed without sound")
			continue
		if not ResourceLoader.exists(SoundscapePlayer.bed_path(str(bed["sound"]))):
			out.append("missing bed file: %s" % bed["sound"])
	for event in events:
		if not event.has("sound") or not event.has("every"):
			out.append("event without sound or every")
			continue
		var every: Array = event["every"]
		if every.size() != 2 or float(every[0]) <= 0.0 or float(every[1]) < float(every[0]):
			out.append("bad interval: %s" % event["sound"])
		var first := "%snature_%s_0.wav" % [SoundBank.GENERATED_DIR, event["sound"]]
		if not ResourceLoader.exists(first):
			out.append("missing event sound: %s" % event["sound"])
	return out
