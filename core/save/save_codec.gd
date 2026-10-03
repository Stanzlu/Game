class_name SaveCodec
extends RefCounted
## The save file format (docs/SAVE_FORMAT.md): JSON text <-> GameState. Pure and testable.
## Decoding never trusts the file: size limit, JSON parse with line number, schema version,
## stepwise migration, then GameState.from_dict() drops and reports anything invalid.
## No str_to_var, no resources, no code from save files (ADR-008).

const SCHEMA_VERSION := 2
const MAX_BYTES := 1 << 20


class LoadResult:
	extends RefCounted
	var ok := false
	## "", "missing", "too_large", "parse", "not_object", "no_version", "newer_version",
	## "migration", "invalid", "unknown_map" or "io".
	var error := ""
	var detail := ""
	var state: GameState
	var schema_version := 0
	var saved_at := ""
	var game_version := ""
	var warnings: PackedStringArray = []

	func fail(code: String, text := "") -> LoadResult:
		ok = false
		error = code
		detail = text
		return self


static func game_version() -> String:
	return str(ProjectSettings.get_setting("application/config/version", "0.0.0"))


## UTC timestamp, e.g. "2026-10-03T14:05:00Z". ISO strings sort chronologically.
static func timestamp() -> String:
	return Time.get_datetime_string_from_system(true) + "Z"


static func encode(state: GameState, saved_at := timestamp()) -> String:
	var data := {
		"schema_version": SCHEMA_VERSION,
		"game_version": game_version(),
		"saved_at": saved_at,
		"world_state": state.to_dict(),
	}
	return JSON.stringify(data, "\t")


## Migration steps: entry i turns schema version i + 1 into i + 2 and returns the new data
## (or an empty Dictionary if it cannot). Frozen example files in tests/fixtures/saves/.
static func migrations() -> Array[Callable]:
	return [migrate_1_to_2]


## Schema 2 (Phase 3): saves of schema 1 always said ELYSIA, because nothing set the mode
## before the rift existed. The UI mode now follows the scene the save was made in.
## "day_preset" is new and optional.
static func migrate_1_to_2(data: Dictionary) -> Dictionary:
	var world: Variant = data.get("world_state")
	if not world is Dictionary:
		return data
	var player: Variant = (world as Dictionary).get("player")
	var map: Variant = (player as Dictionary).get("map") if player is Dictionary else null
	if map is String and SceneRegistry.has(map):
		world["ui_mode"] = str(GameState.UiMode.keys()[SceneRegistry.start_mode(map)])
	return data


static func decode(
	text: String, steps: Array[Callable] = migrations(), target := SCHEMA_VERSION
) -> LoadResult:
	var result := LoadResult.new()
	if text.to_utf8_buffer().size() > MAX_BYTES:
		return result.fail("too_large")
	var json := JSON.new()
	if json.parse(text) != OK:
		return result.fail(
			"parse", "line %d: %s" % [json.get_error_line(), json.get_error_message()]
		)
	if not json.data is Dictionary:
		return result.fail("not_object")
	var data: Dictionary = json.data
	var version_value: Variant = data.get("schema_version")
	if not (version_value is float or version_value is int):
		return result.fail("no_version")
	var version := int(version_value)
	if version < 1 or float(version) != float(version_value):
		return result.fail("no_version", str(version_value))
	if version > target:
		return result.fail("newer_version", str(version))
	result.schema_version = version
	while version < target:
		if version - 1 >= steps.size():
			return result.fail("migration", "no step from version %d" % version)
		data = steps[version - 1].call(data)
		if data.is_empty():
			return result.fail("migration", "step from version %d failed" % version)
		version += 1
		data["schema_version"] = version
		result.warnings.append("migrated to schema %d" % version)
	if not data.get("world_state") is Dictionary:
		return result.fail("invalid", "world_state missing")
	var saved_at: Variant = data.get("saved_at")
	var made_with: Variant = data.get("game_version")
	result.saved_at = saved_at if saved_at is String else ""
	result.game_version = made_with if made_with is String else ""
	result.state = GameState.from_dict(data["world_state"], result.warnings)
	result.ok = true
	return result
