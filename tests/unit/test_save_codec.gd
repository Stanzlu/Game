extends GutTest
## Save format: roundtrip, frozen fixtures, hostile and broken files, migration steps.

const FIXTURES := "res://tests/fixtures/saves/"


func _fixture(file_name: String) -> String:
	return FileAccess.get_file_as_string(FIXTURES + file_name)


func test_roundtrip_keeps_every_part_of_the_state() -> void:
	var ws := WorldStateService.new()
	ws.set_flag("valley.mira_met")
	ws.start_quest("side_sandbox_gate")
	ws.advance_quest("side_sandbox_gate", "through_gate")
	ws.set_relationship("mira", "familiar")
	ws.add_memory("mira", "door_silence")
	ws.set_facet("trust")
	ws.add_item("item_stone")
	ws.add_item("curiosity_tiny_spoon")
	ws.place_curiosity("shelf_1", "curiosity_tiny_spoon")
	ws.set_fire_lit(true)
	ws.discover("sandbox_garden")
	ws.set_ui_mode(GameState.UiMode.REAL)
	ws.add_xp(500)
	ws.add_gold(7)
	ws.set_location("sandbox", Vector2(10.5, -4))
	ws.add_playtime(61.25)
	var text := SaveCodec.encode(ws.state, "2026-10-03T12:00:00Z")
	var result := SaveCodec.decode(text)
	assert_true(result.ok, result.error)
	assert_eq(result.warnings, PackedStringArray())
	assert_eq(result.saved_at, "2026-10-03T12:00:00Z")
	assert_eq(JSON.stringify(result.state.to_dict()), JSON.stringify(ws.state.to_dict()))
	ws.free()


func test_frozen_v1_file_still_loads() -> void:
	var result := SaveCodec.decode(_fixture("v1_full.json"))
	assert_true(result.ok, result.error)
	assert_eq(result.warnings, PackedStringArray(), "a valid v1 file loads without repairs")
	var s := result.state
	assert_true(s.flags.has("valley.mira_met"))
	assert_eq(s.quests["side_sandbox_gate"].stage, "through_gate")
	assert_eq(s.relationships["mira"].state, GameState.Relationship.State.CAUTIOUS)
	assert_eq(s.house.curiosity_slots["shelf_1"], "curiosity_tiny_spoon")
	assert_eq(s.inventory["item_seed"], 1)
	assert_eq(s.ui_mode, GameState.UiMode.REAL)
	assert_eq(s.elysia.level(), 29)
	assert_eq(s.player.map, "sandbox")
	assert_eq(s.player.position, Vector2(120.5, 64))
	assert_almost_eq(s.playtime_seconds, 1234.5, 0.001)


func test_hostile_values_are_dropped_and_reported() -> void:
	var result := SaveCodec.decode(_fixture("v1_hostile.json"))
	assert_true(result.ok, "repairable files still load")
	var s := result.state
	assert_eq(s.flags.keys(), ["valley.ok"])
	assert_true(s.quests.is_empty())
	assert_eq(s.relationships.keys(), ["mira"])
	assert_eq(s.relationships["mira"].state, GameState.Relationship.State.STRANGER)
	assert_eq(s.relationships["mira"].memories, PackedStringArray(["ok_memory"]))
	assert_true(s.facets.is_empty())
	assert_false(s.house.fire_lit)
	assert_true(s.house.curiosity_slots.is_empty())
	assert_eq(s.inventory, {"curiosity_tiny_spoon": 1} as Dictionary[String, int])
	assert_eq(s.discovered, PackedStringArray(["ok_place"]))
	assert_eq(s.ui_mode, GameState.UiMode.ELYSIA)
	assert_eq(s.elysia.xp, 0)
	assert_eq(s.player.name.length(), GameState.MAX_NAME_LENGTH)
	assert_eq(s.player.preset, 0)
	assert_eq(s.player.map, "")
	assert_eq(s.player.position, Vector2(0, 5))
	assert_eq(s.playtime_seconds, 0.0)
	assert_eq(result.saved_at, "")
	assert_gt(result.warnings.size(), 15, "every repair is reported")


func test_broken_files_fail_with_a_reason() -> void:
	var broken := SaveCodec.decode(_fixture("broken.json"))
	assert_false(broken.ok)
	assert_eq(broken.error, "parse")
	assert_string_contains(broken.detail, "line")
	assert_eq(SaveCodec.decode(_fixture("future.json")).error, "newer_version")
	assert_eq(SaveCodec.decode(_fixture("not_object.json")).error, "not_object")
	assert_eq(SaveCodec.decode('{"world_state": {}}').error, "no_version")
	assert_eq(SaveCodec.decode('{"schema_version": 1.5, "world_state": {}}').error, "no_version")
	assert_eq(SaveCodec.decode('{"schema_version": 1}').error, "invalid")
	assert_eq(SaveCodec.decode("").error, "parse")


func test_oversized_files_are_refused() -> void:
	var huge := (
		'{"schema_version": 1, "world_state": {}, "pad": "%s"}' % "x".repeat(SaveCodec.MAX_BYTES)
	)
	assert_eq(SaveCodec.decode(huge).error, "too_large")


func test_migrations_run_step_by_step() -> void:
	var steps: Array[Callable] = [
		func(data: Dictionary) -> Dictionary:
			data["world_state"]["flags"] = {"valley.from_v1": true}
			return data,
		func(data: Dictionary) -> Dictionary:
			data["world_state"]["flags"]["valley.from_v2"] = true
			return data,
	]
	var result := SaveCodec.decode(_fixture("v1_full.json"), steps, 3)
	assert_true(result.ok, result.error)
	assert_eq(result.schema_version, 1)
	assert_true(result.state.flags.has("valley.from_v1"))
	assert_true(result.state.flags.has("valley.from_v2"))
	assert_true("migrated to schema 3" in result.warnings)


func test_missing_or_failing_migration_is_an_error() -> void:
	assert_eq(SaveCodec.decode(_fixture("v1_full.json"), [], 2).error, "migration")
	var failing: Array[Callable] = [func(_data: Dictionary) -> Dictionary: return {}]
	assert_eq(SaveCodec.decode(_fixture("v1_full.json"), failing, 2).error, "migration")
