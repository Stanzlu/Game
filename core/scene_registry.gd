class_name SceneRegistry
extends RefCounted
## Stable scene keys for the start menu, `--start=<key>` and save files. A key that may be
## stored in a save file is never renamed (docs/CONTENT_GUIDE.md, IDs).

const SCENES := {
	"elysia": "res://world/levels/slice/elysia.tscn",
	"tal": "res://world/levels/slice/tal.tscn",
	"haus": "res://world/levels/slice/haus.tscn",
	"weg": "res://encounters/antreiber/slice_antreiber.tscn",
	"sandbox": "res://world/levels/sandbox.tscn",
	"antreiber": "res://encounters/antreiber/antreiber_encounter.tscn",
	"look_elysia": "res://world/levels/look_elysia.tscn",
	"look_tal": "res://world/levels/look_tal.tscn",
	"look_wald": "res://world/levels/look_wald.tscn",
}

## UI mode a scene starts in when it is opened from the prototype menu (new game).
const START_MODES := {"look_elysia": GameState.UiMode.ELYSIA, "elysia": GameState.UiMode.ELYSIA}


static func start_mode(key: String) -> GameState.UiMode:
	return START_MODES.get(key, GameState.UiMode.REAL)


static func has(key: String) -> bool:
	return SCENES.has(key)


static func path(key: String) -> String:
	return SCENES.get(key, "")


## Key for a scene file, or "" for scenes that are not registered.
static func key_for_path(scene_path: String) -> String:
	for key: String in SCENES:
		if SCENES[key] == scene_path:
			return key
	return ""


## Translation key of the place name shown in save slots.
static func title_key(key: String) -> String:
	return "PLACE_%s" % key.to_upper()
