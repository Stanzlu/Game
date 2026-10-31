class_name SceneRegistry
extends RefCounted
## Stable scene keys for the start menu, `--start=<key>` and save files. A key that may be
## stored in a save file is never removed (docs/CONTENT_GUIDE.md, IDs, ADR-052): when a scene is
## renamed, the old key moves to `aliases` and keeps working everywhere.

const SCENES := {
	"elysia": "res://world/levels/slice/elysia.tscn",
	"tal": "res://world/levels/slice/tal.tscn",
	"haus": "res://world/levels/slice/haus.tscn",
	"bachlauf": "res://world/levels/akt2/bachlauf.tscn",
	"waldweg": "res://world/levels/akt3/waldweg.tscn",
	"huette": "res://world/levels/akt3/huette.tscn",
	"flutlichtung": "res://world/levels/akt3/flutlichtung.tscn",
	"gasthaus": "res://world/levels/akt1/gasthaus.tscn",
	"markt": "res://world/levels/akt1/markt.tscn",
	"spiegelhalle": "res://world/levels/akt1/spiegelhalle.tscn",
	"weg": "res://encounters/antreiber/slice_antreiber.tscn",
	"sandbox": "res://world/levels/sandbox.tscn",
	"antreiber": "res://encounters/antreiber/antreiber_encounter.tscn",
	"look_elysia": "res://world/levels/look_elysia.tscn",
	"look_tal": "res://world/levels/look_tal.tscn",
	"look_wald": "res://world/levels/look_wald.tscn",
}

## The scenes the automatic runs visit; a new scene lists itself here and nowhere else.
## SMOKE: tools/check.sh and tools/smoke_export.sh start each one headless and expect its ready
## line (they read this list through tools/scene_keys.py). BENCHMARK: the performance test walks
## through these, in this order (BenchmarkRunner). Elysia and the forest are the look prototype.
const SMOKE: PackedStringArray = [
	"sandbox",
	"antreiber",
	"look_elysia",
	"look_tal",
	"look_wald",
	"elysia",
	"gasthaus",
	"markt",
	"spiegelhalle",
	"tal",
	"haus",
	"bachlauf",
	"waldweg",
	"huette",
	"flutlichtung",
	"weg",
]
const BENCHMARK: PackedStringArray = [
	"look_elysia",
	"tal",
	"bachlauf",
	"waldweg",
	"haus",
	"huette",
	"flutlichtung",
	"gasthaus",
	"markt",
	"spiegelhalle",
	"weg",
	"look_wald"
]

## UI mode a scene starts in when it is opened from the prototype menu (new game).
const START_MODES := {
	"look_elysia": GameState.UiMode.ELYSIA,
	"elysia": GameState.UiMode.ELYSIA,
	"gasthaus": GameState.UiMode.ELYSIA,
	"markt": GameState.UiMode.ELYSIA,
	"spiegelhalle": GameState.UiMode.ELYSIA,
}

## Renamed scenes: old key -> current key. Saves, doors, `--start=` and the start menu accept the
## old key; saves are rewritten to the new one on load. Empty until the first rename; tests fill
## it and put it back.
static var aliases := {}


## The current key for `key`: itself, or what an alias points to.
static func resolve(key: String) -> String:
	return aliases.get(key, key)


static func start_mode(key: String) -> GameState.UiMode:
	return START_MODES.get(resolve(key), GameState.UiMode.REAL)


static func has(key: String) -> bool:
	return SCENES.has(resolve(key))


static func path(key: String) -> String:
	return SCENES.get(resolve(key), "")


## Key for a scene file, or "" for scenes that are not registered.
static func key_for_path(scene_path: String) -> String:
	for key: String in SCENES:
		if SCENES[key] == scene_path:
			return key
	return ""


## Translation key of the place name shown in save slots.
static func title_key(key: String) -> String:
	return "PLACE_%s" % resolve(key).to_upper()
