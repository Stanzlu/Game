extends GutTest
## Act III, segment W6, the way home outside the house (ADR-070): walking into the valley out of
## the night wood or along the brook is the homecoming (the stage "night" goes on to "home", the
## valley is still the morning and she looks north, the fence by the house is mended once the bench
## stands), the Antreiber sits once at the bench and in no other place, the old places take the
## later stages without an error, and the sources keep the rules that a run cannot show (one block
## at the end, nothing timed, every cue and sprite there). The house itself is tested in
## test_akt3_heimkehr_szene, the lines in test_akt3_heimkehr, the pictures in
## test_akt3_heimkehr_bild.

const HAUS := preload("res://world/levels/slice/haus.tscn")
const TAL := preload("res://world/levels/slice/tal.tscn")
const WALDWEG := preload("res://world/levels/akt3/waldweg.tscn")
const FLUTLICHTUNG := preload("res://world/levels/akt3/flutlichtung.tscn")
const HUETTE := preload("res://world/levels/akt3/huette.tscn")
const NACHTWALD := preload("res://world/levels/akt3/nachtwald.tscn")
const BACHLAUF := preload("res://world/levels/akt2/bachlauf.tscn")
const FIXTURE := "res://tests/fixtures/saves/v2_akt2_end.json"
const HEIMKEHR := "res://content/dialogue/akt3/heimkehr.dialogue"
const HAUS_SOURCE := "res://world/levels/slice/haus_scene.gd"
const ANTREIBER_SHEET := "res://entities/character/sheet_antreiber_look.tres"
const QUEST := "main_forest_way"
const WAY: Array[String] = ["leave", "brook", "wood", "night", "home", "done"]
## The fence the bench has mended in the valley, and the goat's gap beside the house.
const FENCE_CELL := Vector2i(31, 16)
const GAP_CELL := Vector2i(21, 16)
## Words that a scene which plays by itself must not use in its homecoming (it counts play time in
## its physics step, and a walk is a GuestWalker's).
const FORBIDDEN_IN_THE_HOMECOMING: Array[String] = [
	"NodeTimer",
	"create_timer",
	"Time.get_ticks",
	"create_tween",
	"timing_factor",
	"process_frame",
	"physics_frame",
	".wait(",
]

var _saved_dir := ""


func before_each() -> void:
	# no scene of these tests leaves its room for another: the doors only note where they lead
	SceneTravel.stay = true
	WorldState.new_game()
	WorldState.set_ui_mode(GameState.UiMode.REAL)
	Settings.set_value("text.auto_advance", false, false)
	Settings.set_value("text.speed", 3, false)
	# saves of their own: the entry into a scene writes the autosave
	_saved_dir = SaveSystem.save_dir
	SaveSystem.save_dir = RuntimeEnv.user_dir() + "heimkehr_weg_saves"
	_clear_saves()


func after_each() -> void:
	Settings.set_value("text.auto_advance", false, false)
	Settings.set_value("text.speed", 1, false)
	SceneTravel.pending_spawn = ""
	SceneTravel.arrival_fade = -1.0
	SceneTravel.stay = false
	SceneTravel.last_target = ""
	WorldState.new_game()
	ScreenFade.fade_in(0.0)
	get_tree().paused = false
	_clear_saves()
	SaveSystem.save_dir = _saved_dir


func _clear_saves() -> void:
	for slot in SaveService.SLOTS:
		for backup: bool in [false, true]:
			var path := SaveSystem.path_for(slot, backup)
			if FileAccess.file_exists(path):
				DirAccess.remove_absolute(path)


## The state "Weiter" loads at the end of Act II, with the morning after told (the valley is as the
## morning left it).
func _end_of_act_two() -> void:
	var result := SaveCodec.decode(FileAccess.get_file_as_string(FIXTURE))
	assert_true(result.ok, result.error)
	WorldState.replace_state(result.state)
	WorldState.set_flag("beat.act3_morning")
	WorldState.set_flag("valley.mira_gone")
	WorldState.set_day_preset("morgen")


## Starts the hero's walk and takes it up to `stage` (the stage "leave" is the start).
func _walk_to(stage: String) -> void:
	WorldState.start_quest(QUEST)
	for step in WAY.size():
		if WAY[step] == stage:
			return
		assert_true(WorldState.advance_quest(QUEST, WAY[step + 1]), "to " + WAY[step + 1])


## The house with Mira long behind her (the fire burns and she has been): only the homecoming plays.
func _house() -> HausScene:
	var scene: HausScene = HAUS.instantiate()
	scene.mira_after = 120.0
	add_child_autofree(scene)
	await wait_physics_frames(3)
	return scene


func _valley(spawn := "bach") -> TalScene:
	SceneTravel.stay = true
	SceneTravel.pending_spawn = spawn
	var scene: TalScene = TAL.instantiate()
	add_child_autofree(scene)
	await wait_physics_frames(3)
	return scene


func _gone(scene: Node) -> void:
	scene.queue_free()
	await wait_physics_frames(2)


func _alive(scene: GameScene) -> Array[Node]:
	return scene.map.entities.get_children().filter(
		func(node: Node) -> bool: return not node.is_queued_for_deletion()
	)


func _decor_at(scene: GameScene, cell: Vector2i) -> Decor:
	var spot := scene.map.cell_to_world(cell)
	for node in _alive(scene):
		if node is Decor and node.global_position.distance_to(spot) < 2.0:
			return node
	return null


## Every cat the room shows (the one at the window, the one asleep).
func _cats(scene: GameScene) -> Array[Node]:
	return _alive(scene).filter(
		func(node: Node) -> bool: return node is Decor and node.sprite_id.begins_with("haus/cat")
	)


## Every man with the Antreiber's sheet.
func _antreibers(scene: GameScene) -> Array[Node]:
	return _alive(scene).filter(
		func(node: Node) -> bool:
			return node is NpcWalker and node.sheet.resource_path == ANTREIBER_SHEET
	)


## The Decor or the walker with this cue (a Decor keeps it as meta), or null.
func _first(scene: GameScene, cue: String) -> Node:
	for node in _alive(scene):
		if node.has_meta(&"cue") and node.get_meta(&"cue") == cue:
			return node
		if node is NpcWalker and (node as NpcWalker).cue == cue:
			return node
	return null


# --- The valley: the way home ----------------------------------------------------------


## Both ways back into the valley land on the same marker: the door at the end of the night wood and
## the door at the end of the brook.
func _doors_to_the_valley(packed: PackedScene) -> Array[Dictionary]:
	var scene: GameScene = packed.instantiate()
	add_child_autofree(scene)
	await wait_physics_frames(3)
	var found: Array[Dictionary] = []
	for node in _alive(scene):
		if node.get(&"target") == "tal":
			found.append({"spawn": str(node.get(&"spawn"))})
	await _gone(scene)
	return found


func test_the_night_moves_on_to_home_whichever_way_back_she_comes() -> void:
	for packed: PackedScene in [NACHTWALD, BACHLAUF]:
		WorldState.new_game()
		_end_of_act_two()
		_walk_to("night")
		var doors := await _doors_to_the_valley(packed)
		assert_eq(doors.size(), 1, "one door back into the valley")
		assert_eq(doors[0]["spawn"], "bach", "and it lands at the marker of the brook")
		var scene := await _valley(doors[0]["spawn"])
		assert_eq(WorldState.quest_stage(QUEST), "home")
		assert_eq(WorldState.quest_history(QUEST), PackedStringArray(WAY.slice(0, 5)))
		assert_eq(scene.player.facing, Facing.Dir.N, "the house lies north: she looks at it")
		assert_true(Beat.reached("bachlauf_back"), "the arrival of the brook is marked as before")
		await _gone(scene)
	assert_push_error_count(0)


func test_the_valley_is_still_the_morning_and_nobody_waits_in_it() -> void:
	_end_of_act_two()
	_walk_to("night")
	var scene := await _valley()
	assert_eq(WorldState.day_preset(), "morgen", "no evening, no fifth time of day")
	assert_eq(scene.day_light.preset, "morgen")
	assert_true(WorldState.has_flag("valley.mira_gone"))
	assert_true(_first(scene, "mira") == null, "her seat across the fire is empty")
	assert_eq(_antreibers(scene).size(), 0, "and he is in the house, not on the path")
	assert_false(scene.dialogue_box.is_open(), "no lines on the arrival")
	assert_eq(get_tree().get_nodes_in_group(&"cutscene").size(), 0, "no scene on the arrival")
	assert_push_error_count(0)


func test_the_valley_moves_only_the_night_and_only_once() -> void:
	for stage: String in ["", "leave", "brook", "wood", "home", "done", "night"]:
		WorldState.new_game()
		_end_of_act_two()
		if not stage.is_empty():
			_walk_to(stage)
		var history := WorldState.quest_history(QUEST)
		var scene := await _valley()
		var expected := "home" if stage == "night" else stage
		assert_eq(WorldState.quest_stage(QUEST), expected, "stage '%s'" % stage)
		if stage == "night":
			assert_eq(WorldState.quest_history(QUEST).size(), history.size() + 1, "one step")
		else:
			assert_eq(WorldState.quest_history(QUEST), history, "'%s': nothing moved" % stage)
		var north := scene.player.facing == Facing.Dir.N
		assert_eq(north, stage in ["night", "home"], "facing north in '%s'" % stage)
		await _gone(scene)
		# a second visit moves nothing again
		var again := await _valley()
		assert_eq(WorldState.quest_stage(QUEST), expected, "second visit '%s'" % stage)
		await _gone(again)
	assert_push_error_count(0)


func test_a_game_never_started_gets_no_walk_from_the_valley() -> void:
	_end_of_act_two()
	var scene := await _valley()
	assert_false(WorldState.is_quest_started(QUEST), "no walk, no home")
	assert_false(WorldState.has_flag("house.workbench"))
	await _gone(scene)
	assert_push_error_count(0)


func test_a_save_in_the_night_comes_home_in_the_valley_and_keeps_it() -> void:
	_end_of_act_two()
	_walk_to("night")
	var back := SaveCodec.decode(SaveCodec.encode(WorldState.state))
	assert_true(back.ok, back.error)
	assert_eq(back.warnings, PackedStringArray(), "the stage is known")
	WorldState.new_game()
	WorldState.replace_state(back.state)
	# "Weiter" brings her to the valley with no door behind her
	var scene := await _valley("")
	assert_eq(WorldState.quest_stage(QUEST), "home")
	assert_eq(scene.player.facing, Facing.Dir.N)
	var again := SaveCodec.decode(SaveCodec.encode(WorldState.state))
	assert_true(again.ok, again.error)
	assert_eq(again.warnings, PackedStringArray(), "and home is known too")
	assert_eq(again.state.quests[QUEST].stage, "home")
	assert_eq(again.state.quests[QUEST].history, PackedStringArray(WAY.slice(0, 5)))
	await _gone(scene)
	assert_push_error_count(0)


func test_the_fence_by_the_house_is_mended_with_the_bench_and_the_gap_is_not() -> void:
	_end_of_act_two()
	_walk_to("home")
	var scene := await _valley()
	assert_eq(_decor_at(scene, FENCE_CELL).sprite_id, "tal/fence_broken", "broken until the bench")
	assert_eq(_decor_at(scene, GAP_CELL).sprite_id, "tal/fence_broken")
	WorldState.set_flag("house.workbench")
	await wait_physics_frames(3)
	assert_eq(_decor_at(scene, FENCE_CELL).sprite_id, "tal/fence", "the Antreiber has mended it")
	assert_eq(_decor_at(scene, GAP_CELL).sprite_id, "tal/fence_broken", "the goat's gap stays")
	assert_not_null(_first(scene, "fence_gap"), "and can be looked at")
	await _gone(scene)
	# a valley built after the visit has it mended from the first picture
	var later := await _valley()
	assert_eq(_decor_at(later, FENCE_CELL).sprite_id, "tal/fence")
	assert_push_error_count(0)


func test_he_sits_once_at_the_bench_in_the_house_and_in_no_other_place() -> void:
	var states: Array[Array] = [
		["house.antreiber_by_fire"],
		["house.antreiber_left", "valley.antreiber_rests"],
		["valley.antreiber_rests"],
		["forest.antreiber_met", "forest.antreiber_sat", "valley.antreiber_rests"],
		["forest.flood_sat", "valley.antreiber_rests"],
	]
	var rooms: Array[PackedScene] = [FLUTLICHTUNG, WALDWEG, TAL]
	for state: Array in states:
		WorldState.new_game()
		_end_of_act_two()
		WorldState.clear_flag("house.antreiber_by_fire")
		WorldState.clear_flag("house.antreiber_refused")
		for flag: String in state:
			WorldState.set_flag(flag)
		_walk_to("home")
		# on the way back the walk went through the clearing (whoever is not at the fire has gone
		# ahead: the clearing sets it), then the path, the valley and the house
		var scene: GameScene = FLUTLICHTUNG.instantiate()
		add_child_autofree(scene)
		await wait_physics_frames(3)
		await _gone(scene)
		for packed: PackedScene in [WALDWEG, TAL]:
			scene = packed.instantiate()
			add_child_autofree(scene)
			await wait_physics_frames(3)
			assert_eq(
				_antreibers(scene).size(), 0, "not on the way %s %s" % [packed.resource_path, state]
			)
			assert_eq(_cats(scene).size(), 0)
			await _gone(scene)
		var house := await _house()
		assert_eq(_antreibers(house).size(), 1, "at the bench %s" % [state])
		assert_true(WorldState.has_flag("house.workbench"))
		await _gone(house)
		# and from then on the rooms he left stay empty, the clearing too
		for packed: PackedScene in rooms:
			scene = packed.instantiate()
			add_child_autofree(scene)
			await wait_physics_frames(3)
			assert_eq(_antreibers(scene).size(), 0, "not %s %s" % [packed.resource_path, state])
			assert_eq(_cats(scene).size(), 0, "no cat outside the house")
			await _gone(scene)
	assert_push_error_count(0)


# --- The old places ------------------------------------------------------------------------


func test_the_hut_entered_again_after_the_visit_has_the_hermit_in_it_and_no_error() -> void:
	WorldState.set_flag("house.guest_hermit")
	for stage: String in ["night", "home", "done"]:
		WorldState.new_game()
		WorldState.set_flag("house.guest_hermit")
		_walk_to(stage)
		var history := WorldState.quest_history(QUEST)
		var scene: HuetteScene = HUETTE.instantiate()
		add_child_autofree(scene)
		await wait_physics_frames(3)
		assert_eq(WorldState.quest_stage(QUEST), stage, "%s: the stage stays" % stage)
		assert_eq(WorldState.quest_history(QUEST), history, stage)
		var hermit := _first(scene, "hermit")
		assert_not_null(hermit, "%s: he lives in the hut" % stage)
		assert_true((hermit as NpcWalker).seated)
		await _gone(scene)
	assert_push_error_count(0)


func test_the_way_on_to_the_night_wood_stays_open_at_home_and_when_it_is_over() -> void:
	for stage: String in ["night", "home", "done"]:
		WorldState.new_game()
		_walk_to(stage)
		WorldState.set_flag("forest.night_way")
		var scene: GameScene = FLUTLICHTUNG.instantiate()
		add_child_autofree(scene)
		await wait_physics_frames(3)
		assert_null(_first(scene, "south_wait"), "%s: nothing holds her in the gap" % stage)
		assert_eq(WorldState.quest_stage(QUEST), stage)
		await _gone(scene)
	assert_push_error_count(0)


# --- The sources ---------------------------------------------------------------------------


## The text of `source` from the head of `from` to the line `until` (included).
func _between(source: String, from: String, until: String) -> String:
	var start := source.find(from)
	var end := source.find(until, start)
	assert_true(start > 0 and end > start, "'%s' to '%s' found" % [from, until])
	return source.substr(start, end - start + until.length())


func test_the_end_is_one_block_without_a_wait() -> void:
	# nothing waits between the marks and the save, so no save holds the one without the other
	var source := FileAccess.get_file_as_string(HAUS_SOURCE)
	var block := _between(source, "func _home_finishes()", "_home_cut.end()")
	var done := block.find('WorldState.advance_quest("main_forest_way", "done")')
	var chapter := block.find('Chapter.mark("act3")')
	var beat := block.find('Beat.mark("act3_home")')
	var end := block.find("_home_cut.end()")
	assert_true(
		done > 0 and chapter > done and beat > chapter and end > beat, "done, chapter, beat, save"
	)
	assert_false(block.contains("await"), "no waiting between them")
	assert_eq(source.count('Chapter.mark("act3")'), 1, "one site")
	assert_eq(source.count('Beat.mark("act3_home")'), 1, "one site")
	assert_eq(source.count('advance_quest("main_forest_way", "done")'), 1, "one site")
	assert_false(source.contains('Chapter.reached("act3")'), "nothing reads the mark yet")


func _gd_files(folder: String) -> Array[String]:
	var found: Array[String] = []
	for name in DirAccess.get_directories_at(folder):
		found.append_array(_gd_files(folder.path_join(name)))
	for name in DirAccess.get_files_at(folder):
		if name.ends_with(".gd"):
			found.append(folder.path_join(name))
	return found


func test_no_other_place_marks_the_end_or_asks_for_it() -> void:
	var marks := 0
	var asks := 0
	for folder: String in [
		"res://world", "res://core", "res://entities", "res://encounters", "res://ui"
	]:
		for path in _gd_files(folder):
			var text := FileAccess.get_file_as_string(path)
			marks += text.count('Chapter.mark("act3")')
			asks += text.count('Chapter.reached("act3")')
	assert_eq(marks, 1, "the mark of Act III is set in one place")
	assert_eq(asks, 0, "and nothing reads it before Act IV does")


func test_nothing_in_the_homecoming_is_timed() -> void:
	var source := FileAccess.get_file_as_string(HAUS_SOURCE)
	var homecoming := _between(source, "func _home_step(", "_home_cut.end()")
	for word: String in FORBIDDEN_IN_THE_HOMECOMING:
		assert_false(homecoming.contains(word), "'%s' in the homecoming" % word)
	assert_true(homecoming.contains("_home_clock += delta"), "it counts play time")
	assert_true(source.contains("func _physics_process"), "in the physics step")


func test_every_cue_the_legend_and_the_scene_name_is_in_the_dialogue() -> void:
	var resource := load(HEIMKEHR) as DialogueResource
	var cues: Array[String] = []
	var regex := RegEx.create_from_string('"cue": "(\\w+)"')
	for map: String in ["haus", "tal", "flutlichtung"]:
		for line in FileAccess.get_file_as_string("res://content/maps/%s.txt" % map).split("\n"):
			if line.begins_with(";") or not line.contains("heimkehr.dialogue"):
				continue
			var found := regex.search(line)
			assert_not_null(found, "a cue in: " + line.left(60))
			cues.append(found.get_string(1))
	var scene := RegEx.create_from_string('cut\\.say\\(HEIMKEHR_DIALOGUE, "(\\w+)"\\)')
	for found in scene.search_all(FileAccess.get_file_as_string(HAUS_SOURCE)):
		cues.append(found.get_string(1))
	for cue: String in ["workbench", "antreiber_bench", "cat_bench", "plan_board"]:
		assert_true(cue in cues, "the legend names '%s'" % cue)
	for cue: String in ["home_in", "guest_enter", "act3_close"]:
		assert_true(cue in cues, "the scene says '%s'" % cue)
	for cue in cues:
		assert_true(cue in resource.get_cues(), "'%s' is a cue of the dialogue" % cue)


## Every sprite a map names, in a placement or in a "sprite_when" switch.
func _sprites_named_in(map: String) -> Array[String]:
	var found: Array[String] = []
	var plain := RegEx.create_from_string('"sprite": "([a-z_]+/[a-z_0-9]+)"')
	var switch := RegEx.create_from_string('"sprite_when": \\{([^}]*)\\}')
	var target := RegEx.create_from_string('": "([a-z_]+/[a-z_0-9]+)"')
	for line in FileAccess.get_file_as_string("res://content/maps/%s.txt" % map).split("\n"):
		if line.begins_with(";"):
			continue
		for hit in plain.search_all(line):
			found.append(hit.get_string(1))
		for block in switch.search_all(line):
			for hit in target.search_all(block.get_string(1)):
				found.append(hit.get_string(1))
	return found


func test_every_sprite_the_maps_name_is_in_the_catalog_and_the_new_ones_cast_no_baked_shadow(
) -> void:
	for map: String in ["haus", "tal"]:
		var named := _sprites_named_in(map)
		assert_gt(named.size(), 10, "the sprites of %s were found" % map)
		for sprite in named:
			assert_false(PropCatalog.entry(sprite).is_empty(), "'%s' is in the catalog" % sprite)
	var house := _sprites_named_in("haus")
	for sprite: String in ["haus/workbench", "haus/guest_chair", "haus/plan_board"]:
		assert_true(sprite in house, "the house names '%s'" % sprite)
		var entry := PropCatalog.entry(sprite)
		# a shadow in the catalog would change the stamp of the baked floor of the house
		assert_false(entry.has("shadow"), "'%s' has no catalog shadow" % sprite)
		assert_true(FileAccess.file_exists(str(entry["textures"][0])), sprite)
	assert_true("tal/fence" in _sprites_named_in("tal"), "the mended fence")
	assert_true(PropCatalog.entry("haus/workbench").has("shape"), "she does not walk through it")
	assert_true(PropCatalog.entry("haus/guest_chair").get("flat", false))
	assert_true(PropCatalog.entry("haus/plan_board").get("flat", false))


func test_the_journal_follows_the_way_to_its_end() -> void:
	_end_of_act_two()
	var texts: Dictionary = {}
	_walk_to("night")
	texts["night"] = Journal.entry_text(QUEST)
	WorldState.advance_quest(QUEST, "home")
	texts["home"] = Journal.entry_text(QUEST)
	WorldState.advance_quest(QUEST, "done")
	texts["done"] = Journal.entry_text(QUEST)
	assert_string_contains(texts["home"], tr("QUEST_MAIN_FOREST_WAY_HOME"))
	assert_string_contains(texts["done"], tr("QUEST_MAIN_FOREST_WAY_DONE"))
	assert_string_contains(
		texts["done"], tr("QUEST_MAIN_FOREST_WAY_HOME"), "the diary keeps the way"
	)
	assert_false(tr("QUEST_MAIN_FOREST_WAY_HOME") in texts["night"], "not before")
	assert_true(WorldState.is_quest_done(QUEST))
	assert_eq(WorldState.quest_outcome(QUEST), "done")
