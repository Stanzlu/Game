class_name SceneRegistry
extends RefCounted
## Stable scene keys for the start menu, `--start=<key>` and save files. A key that may be
## stored in a save file is never renamed (docs/CONTENT_GUIDE.md, IDs).

const SCENES := {
	"sandbox": "res://world/levels/sandbox.tscn",
	"antreiber": "res://encounters/antreiber/antreiber_encounter.tscn",
	"look_elysia": "res://world/levels/look_elysia.tscn",
	"look_tal": "res://world/levels/look_tal.tscn",
	"look_wald": "res://world/levels/look_wald.tscn",
}


static func has(key: String) -> bool:
	return SCENES.has(key)


static func path(key: String) -> String:
	return SCENES.get(key, "")


## Translation key of the place name shown in save slots.
static func title_key(key: String) -> String:
	return "PLACE_%s" % key.to_upper()
