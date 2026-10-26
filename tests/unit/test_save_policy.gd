extends GutTest
## Save policy (ADR-052): a save written by a released build of Full Production loads in every
## later build. Every schema version keeps a frozen example file; renamed scenes keep working
## through the alias table; chapters are marked with flags of their own.

const FIXTURES := "res://tests/fixtures/saves/"

var dir_path := RuntimeEnv.user_dir() + "saves_policy"
var saves: SaveService


func before_each() -> void:
	SceneRegistry.aliases = {}
	_clear_dir()
	DirAccess.make_dir_recursive_absolute(dir_path)
	saves = SaveService.new()
	saves.save_dir = dir_path
	add_child_autofree(saves)


func after_each() -> void:
	SceneRegistry.aliases = {}


func after_all() -> void:
	_clear_dir()


func _clear_dir() -> void:
	var dir := DirAccess.open(dir_path)
	if dir == null:
		return
	for file_name in dir.get_files():
		dir.remove(file_name)


func _fixture(file_name: String) -> String:
	return FileAccess.get_file_as_string(FIXTURES + file_name)


## File names of the frozen examples ("v<schema>_<what>.json"), hostile ones apart.
func _frozen() -> PackedStringArray:
	var found: PackedStringArray = []
	var pattern := RegEx.create_from_string("^v(\\d+)_.+\\.json$")
	for file_name in DirAccess.get_files_at(FIXTURES):
		if pattern.search(file_name) != null and not file_name.contains("hostile"):
			found.append(file_name)
	return found


# --- frozen examples -------------------------------------------------------------------


func test_every_schema_version_keeps_a_frozen_example() -> void:
	var versions := {}
	for file_name in _frozen():
		var number := file_name.get_slice("_", 0).trim_prefix("v").to_int()
		versions[number] = file_name
	for version in range(1, SaveCodec.SCHEMA_VERSION + 1):
		assert_true(
			versions.has(version),
			"schema %d needs tests/fixtures/saves/v%d_*.json (ADR-052)" % [version, version]
		)


func test_every_frozen_example_still_loads_without_repairs() -> void:
	assert_gt(_frozen().size(), 1, "the examples are there")
	for file_name in _frozen():
		var result := SaveCodec.decode(_fixture(file_name))
		assert_true(result.ok, "%s: %s" % [file_name, result.error])
		for warning in result.warnings:
			assert_true(warning.begins_with("migrated"), "%s: repaired: %s" % [file_name, warning])


func test_the_frozen_v2_end_of_act_one_keeps_its_story() -> void:
	# a real run of tools/autopilot/akt1_full.json, frozen at the arrival in the valley (ADR-067)
	var result := SaveCodec.decode(_fixture("v2_akt1_end.json"))
	assert_true(result.ok, result.error)
	assert_eq(result.schema_version, 2)
	assert_eq(result.warnings, PackedStringArray(), "a v2 file needs no migration")
	var s := result.state
	assert_eq(s.player.map, "tal")
	assert_eq(s.ui_mode, GameState.UiMode.REAL)
	assert_true(Chapter.in_flags(s.flags, "act1"), "Act I is marked as reached")
	assert_false(Chapter.in_flags(s.flags, "slice"), "and the slice is not finished by it")
	assert_true(s.flags["elysia.rift_crossed"])
	assert_gte(s.elysia.xp, GameState.xp_for_level(48), "level 48 is certain by the feast")
	assert_eq(s.inventory.keys(), ["item_seed", "item_stone"], "only the stone and the seed cross")
	assert_true(s.facets.has("perception"))
	assert_eq(s.quests["main_elysia_hero"].stage, "repeat")
	assert_eq(s.quests["main_elysia_trail"].stage, "rift")
	for quest_id: String in s.quests:
		assert_not_null(ContentDB.quest(quest_id).stage(s.quests[quest_id].stage), quest_id)


func test_the_frozen_v2_end_of_act_two_keeps_its_story() -> void:
	# a real run of tools/autopilot/akt2_full.json from v2_akt1_end.json, frozen where it ends:
	# Act II is over, the title has been shown, and Continue starts the morning after (ADR-070)
	var result := SaveCodec.decode(_fixture("v2_akt2_end.json"))
	assert_true(result.ok, result.error)
	assert_eq(result.schema_version, 2)
	assert_eq(result.warnings, PackedStringArray(), "a v2 file needs no migration")
	var s := result.state
	assert_eq(s.player.map, "tal")
	assert_eq(s.ui_mode, GameState.UiMode.REAL)
	assert_eq(s.day_preset, "abend")
	for chapter: String in ["act1", "act2", "slice"]:
		assert_true(Chapter.in_flags(s.flags, chapter), "%s is marked as reached" % chapter)
	assert_false(Chapter.in_flags(s.flags, "act3"), "and Act III has not begun")
	assert_true(s.flags["valley.ending"], "the evening ended on Mira's answer")
	assert_true(s.facets.has("perception") and s.facets.has("boundaries"))
	assert_false(s.facets.has("care"), "the facet of Act III is still to come")
	assert_true(s.flags["value.freedom"], "the first answer at the fire is the autopilot's")
	assert_true(s.flags["melody.house_hum"])
	for quest_id: String in ["main_valley_shelter", "side_valley_goat", "side_valley_trap"]:
		assert_true(ContentDB.quest(quest_id).stage(s.quests[quest_id].stage).is_final(), quest_id)
	for quest_id: String in s.quests:
		assert_not_null(ContentDB.quest(quest_id).stage(s.quests[quest_id].stage), quest_id)
	assert_eq(s.relationships["mira"].state, GameState.Relationship.State.FAMILIAR)
	assert_eq(s.inventory.keys().size(), 4, "the seed and the three things from the brook")
	assert_gt(s.playtime_seconds, 300.0)


func test_the_frozen_v2_end_of_the_slice_keeps_its_story() -> void:
	var result := SaveCodec.decode(_fixture("v2_slice_end.json"))
	assert_true(result.ok, result.error)
	assert_eq(result.schema_version, 2)
	assert_eq(result.game_version, "0.8.4")
	assert_eq(result.warnings, PackedStringArray(), "a v2 file needs no migration")
	var s := result.state
	assert_eq(s.player.map, "tal")
	assert_eq(s.player.name, "Kai")
	assert_eq(s.ui_mode, GameState.UiMode.REAL)
	assert_eq(s.day_preset, "abend")
	assert_eq(s.elysia.xp, 24600)
	assert_eq(s.house.curiosity_slots["shelf_1"], "curiosity_tiny_spoon")
	assert_eq(s.quests.size(), 5)
	for quest_id: String in s.quests:
		var stage := ContentDB.quest(quest_id).stage(s.quests[quest_id].stage)
		assert_not_null(stage, "%s: the saved stage still exists" % quest_id)
		if quest_id == "main_elysia_hero":
			# Act I goes on after the chest (ADR-058): the old end is now the stage before the inn
			assert_eq(stage.id, "celebrated")
			assert_false(stage.is_final(), "the slice save reopens the hero's quest, the inn waits")
		else:
			assert_true(stage.is_final(), quest_id)
	assert_eq(s.relationships["mira"].state, GameState.Relationship.State.FAMILIAR)
	assert_eq(s.relationships["mira"].memories.size(), 12)
	assert_eq(s.inventory.size(), 2)
	assert_true(s.flags.has("beat.ending"))
	assert_true(Chapter.in_flags(s.flags, "slice"), "the slice counts as finished (legacy flag)")


func test_the_frozen_v2_file_survives_a_round_trip() -> void:
	var first := SaveCodec.decode(_fixture("v2_slice_end.json"))
	var again := SaveCodec.decode(SaveCodec.encode(first.state))
	assert_true(again.ok, again.error)
	assert_eq(again.warnings, PackedStringArray())
	assert_eq(JSON.stringify(again.state.to_dict()), JSON.stringify(first.state.to_dict()))


# --- renamed scenes --------------------------------------------------------------------


func test_a_save_in_a_renamed_scene_moves_to_the_new_key() -> void:
	SceneRegistry.aliases = {"daheim": "tal"}
	var text := _fixture("v2_slice_end.json").replace('"map": "tal"', '"map": "daheim"')
	var result := SaveCodec.decode(text)
	assert_true(result.ok, result.error)
	assert_eq(result.state.player.map, "tal")


func test_the_save_service_accepts_an_old_key_and_stores_the_new_one() -> void:
	SceneRegistry.aliases = {"daheim": "tal"}
	var path := saves.path_for("slot_1")
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(_fixture("v2_slice_end.json").replace('"map": "tal"', '"map": "daheim"'))
	file.close()
	var result := saves.read_slot("slot_1")
	assert_true(result.ok, "not unknown_map: %s" % result.error)
	assert_eq(saves.summary("slot_1")["map"], "tal")


func test_without_the_alias_the_old_key_is_still_refused() -> void:
	var file := FileAccess.open(saves.path_for("slot_1"), FileAccess.WRITE)
	file.store_string(_fixture("v2_slice_end.json").replace('"map": "tal"', '"map": "daheim"'))
	file.close()
	assert_eq(saves.read_slot("slot_1").error, "unknown_map")


func test_old_keys_work_for_doors_titles_and_start() -> void:
	SceneRegistry.aliases = {"daheim": "haus"}
	assert_true(SceneRegistry.has("daheim"))
	assert_eq(SceneRegistry.path("daheim"), SceneRegistry.path("haus"))
	assert_eq(SceneRegistry.title_key("daheim"), SceneRegistry.title_key("haus"))
	assert_eq(SceneRegistry.start_mode("daheim"), SceneRegistry.start_mode("haus"))
	assert_eq(SceneRegistry.resolve("tal"), "tal", "current keys stay")


func test_every_registered_scene_is_still_there_for_saves_to_find() -> void:
	# A key a save may hold is never removed: when this list loses a name, the name moves to
	# SceneRegistry.aliases instead (ADR-052). Add new scenes here as they ship.
	var keys := ["elysia", "tal", "haus", "weg", "gasthaus", "markt", "spiegelhalle", "bachlauf"]
	for key: String in keys:
		assert_true(SceneRegistry.has(key), "scene '%s' went missing" % key)
		assert_true(ResourceLoader.exists(SceneRegistry.path(key)), key)
