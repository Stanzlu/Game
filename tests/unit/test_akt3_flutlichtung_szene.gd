# gdlint: ignore=max-public-methods
extends GutTest
## Act III, segment W4, the scene of the Flutlichtung: a big map (class M) at the zoom of the
## forest, a gap in the wood where the brook runs past, and on it the water's trace as things (a
## trail going north, a bleached trunk with a band of silt over her head, a camp the silt took).
## The Antreiber stands at the trunk and measures (not there for whoever left him at the fire in
## the house, sitting once he has had tea), the goal "flood" of the hero's walk is done at the
## trunk and nowhere else, side quest B (a nest and a forked branch), the driftwood, the stones
## across the brook, the door back to the forest path and the way on to the south that is shut
## until the walk has reached the night (W5: the blocker leaves, a door behind it leads on; that is
## tested in test_akt3_flutlichtung_nacht). What is said is tested in test_akt3_flutlichtung, the
## map in test_layout_akt3.py.

const FLUT := preload("res://world/levels/akt3/flutlichtung.tscn")
const WALDWEG := preload("res://world/levels/akt3/waldweg.tscn")
const TAL := preload("res://world/levels/slice/tal.tscn")
const BLOCKER_SCRIPT := preload("res://world/props/blocker.gd")
const DOOR_SCRIPT := preload("res://world/props/door.gd")
const DIALOGUE := "res://content/dialogue/akt3/flutlichtung.dialogue"
const QUEST := "main_forest_way"
const NEST_QUEST := "side_forest_nest"
const DOOR_CELL := Vector2i(50, 1)
const ARRIVAL_CELL := Vector2i(50, 6)
const START_CELL := Vector2i(50, 7)
const BLOCKER_CELL := Vector2i(34, 50)
const NIGHT_DOOR_CELL := Vector2i(34, 52)
## The cells of the ford: wet silt, the three cells of stones, the dry grass of the far bank.
const FORD_WEST := Vector2i(58, 42)
const FORD_EAST := Vector2i(63, 42)
const ABOVE_FORD := Vector2i(58, 41)
## The way through the wood, as far as a stage name goes.
const WAY: Array[String] = ["leave", "brook", "wood", "night", "home", "done"]
## Spots of the clearing: the cue of each (the blocker has no cue of its own on the Decor).
const SPOTS: Array[String] = [
	"flood_trail",
	"flood_mark",
	"flood_camp",
	"nest",
	"fork",
	"driftwood",
	"stones",
	"antreiber_flood",
]
## Every cue of the file that no placement on the map names: reached by `=>` from another cue.
const INNER_CUES: Array[String] = ["antreiber_flood_ask", "antreiber_flood_again", "fork_nest"]
## What the clearing may not do in code: it waits for no one and holds no one.
const FORBIDDEN_IN_THE_SCENE: Array[String] = [
	"NodeTimer",
	"create_timer",
	"Time.get_ticks",
	"timing_factor",
	"Cutscene",
	"Blocker",
	".lock(",
	"create_tween",
	"flash",
	"flicker",
	"strobe",
	"shake",
]


func before_each() -> void:
	WorldState.new_game()
	WorldState.set_ui_mode(GameState.UiMode.REAL)
	WorldState.set_day_preset("morgen")
	Settings.set_value("text.auto_advance", false, false)
	Settings.set_value("text.speed", 3, false)


func after_each() -> void:
	Input.action_release(&"move_up")
	Input.action_release(&"move_down")
	Input.action_release(&"move_left")
	Input.action_release(&"move_right")
	Settings.set_value("text.auto_advance", false, false)
	Settings.set_value("text.speed", 1, false)
	SceneTravel.pending_spawn = ""
	SceneTravel.arrival_fade = -1.0
	SceneTravel.stay = false
	SceneTravel.last_target = ""
	WorldState.new_game()
	ScreenFade.fade_in(0.0)
	get_tree().paused = false


func _scene() -> FlutlichtungScene:
	var scene: FlutlichtungScene = FLUT.instantiate()
	add_child_autofree(scene)
	await wait_physics_frames(3)
	return scene


func _alive(scene: GameScene, prefix: String) -> Array[Node]:
	return scene.map.entities.get_children().filter(
		func(node: Node) -> bool:
			return str(node.name).begins_with(prefix) and not node.is_queued_for_deletion()
	)


## A prop with this cue (a Decor keeps it as meta, a walker as property), or null.
func _first(scene: GameScene, cue: String) -> Node:
	for node in scene.map.entities.get_children():
		if node.is_queued_for_deletion():
			continue
		if node.has_meta(&"cue") and node.get_meta(&"cue") == cue:
			return node
		if node is NpcWalker and (node as NpcWalker).cue == cue:
			return node
	return null


func _decor_with(scene: GameScene, sprite: String) -> Array:
	return _alive(scene, "Decor").filter(
		func(node: Node) -> bool: return (node as Decor).sprite_id == sprite
	)


## Every figure that walks or stands on the map (the Antreiber is the only one there is).
func _figures(scene: GameScene) -> Array[Node]:
	return scene.map.entities.get_children().filter(
		func(node: Node) -> bool: return node is NpcWalker and not node.is_queued_for_deletion()
	)


func _walkers(scene: GameScene, cue: String) -> Array[Node]:
	return _figures(scene).filter(func(node: Node) -> bool: return (node as NpcWalker).cue == cue)


func _antreiber(scene: GameScene) -> Array[Node]:
	return _walkers(scene, "antreiber_flood")


func _doors(scene: GameScene, target: String) -> Array[Node]:
	return scene.map.entities.get_children().filter(
		func(node: Node) -> bool: return node.get(&"target") == target
	)


func _at(scene: GameScene, cell: Vector2i, script: Script) -> Node:
	var spot := scene.map.cell_to_world(cell)
	for node in scene.map.entities.get_children():
		if (
			not node.is_queued_for_deletion()
			and node.get_script() == script
			and node.global_position.distance_to(spot) < 2.0
		):
			return node
	return null


func _cell_of(scene: GameScene, node: Node2D) -> Vector2i:
	return scene.map.world_to_cell(node.global_position)


## Holds `action` until `done` holds or `frames` physics frames have passed; true if it held.
func _hold(action: StringName, done: Callable, frames: int) -> bool:
	Input.action_press(action)
	var left := frames
	while left > 0 and not done.call():
		await wait_physics_frames(1)
		left -= 1
	Input.action_release(action)
	return done.call()


func _go_to(scene: GameScene, cell: Vector2i) -> void:
	scene.player.global_position = scene.map.cell_to_world(cell)
	scene.player.velocity = Vector2.ZERO
	await wait_physics_frames(2)


## What looking at, or talking to, a thing does: the same signal the player's key sends.
func _look(prop: Node) -> void:
	(prop.get_node("Interactable") as Interactable).interacted.emit(null)


## A group of answers is up in the real box.
func _asked(scene: GameScene) -> bool:
	var box := scene.dialogue_box
	return box.is_open() and box.line != null and box._responses.visible


## The answers that can be picked in the group that is up.
func _offered(scene: GameScene) -> PackedStringArray:
	var texts: PackedStringArray = []
	for response: DialogueResponse in scene.dialogue_box.line.responses:
		if response.is_allowed:
			texts.append(response.text)
	return texts


## The key a player presses to move the text on, as the real input path takes it (the box does not
## move on by itself here: the wait of an automatic advance is real time, and a test is not slow).
func _confirm() -> void:
	for pressed: bool in [true, false]:
		var event := InputEventAction.new()
		event.action = &"interact"
		event.pressed = pressed
		Input.parse_input_event(event)


## Looks at `prop` and takes `answers` in the real box, in order, as the groups come up, until the
## box is shut again; the lines in between are moved on with the confirm key. Returns what each
## group offered. Every answer has to be taken, and no group may come up that has no answer left
## (the box would wait for ever and the test fail).
func _talk_through(
	scene: GameScene, prop: Node, answers: PackedStringArray
) -> Array[PackedStringArray]:
	var offered: Array[PackedStringArray] = []
	var next := [0]
	var opened := [false]
	var watch := func() -> bool:
		if scene.dialogue_box.is_open():
			opened[0] = true
			if _asked(scene):
				if next[0] < answers.size():
					var shown := _offered(scene)
					if BoxAnswers.pick(scene.dialogue_box, answers[next[0]]):
						offered.append(shown)
						next[0] += 1
			else:
				_confirm()
		return opened[0] and not scene.dialogue_box.is_open() and next[0] == answers.size()
	_look(prop)
	var done: bool = await wait_until(watch, 60.0)
	assert_true(done, "the box opened, the answers %s were taken and it closed" % [answers])
	assert_eq(next[0], answers.size(), "every answer was taken")
	await wait_physics_frames(3)
	return offered


## The same, for a thing with no answers: the box opens, tells its lines and closes.
func _read(scene: GameScene, prop: Node) -> void:
	await _talk_through(scene, prop, PackedStringArray())


## Starts the hero's walk and takes it up to `stage` (the stage "leave" is the start).
func _walk_to(stage: String) -> void:
	WorldState.start_quest(QUEST)
	for step in WAY.size():
		if WAY[step] == stage:
			return
		assert_true(WorldState.advance_quest(QUEST, WAY[step + 1]), "to " + WAY[step + 1])


## How many figures with this cue a scene shows, counted in a scene that is then freed again.
func _count_in(packed: PackedScene, cue: String) -> int:
	var scene: GameScene = packed.instantiate()
	add_child_autofree(scene)
	await wait_physics_frames(3)
	var count := _walkers(scene, cue).size()
	scene.queue_free()
	await wait_physics_frames(2)
	return count


# --- The map and the way in ------------------------------------------------------------


func test_it_is_a_big_map_in_the_morning_light_at_the_zoom_of_the_forest() -> void:
	var scene := await _scene()
	assert_true(SceneRegistry.has("flutlichtung"))
	assert_lte(scene.map.data.width, 90, "class M, ADR-068, and the size of the brief")
	assert_lte(scene.map.data.height, 56)
	assert_gt(scene.map.data.width * scene.map.data.height, 4000, "bigger than the valley")
	assert_true(Beat.reached("flut_enter"))
	assert_eq(scene.day_preset, "morgen", "the morning goes on in the clearing")
	assert_eq(scene.view.zoom, 1.25, "the zoom of the forest (ADR-045)")
	assert_true(scene.reflect_player, "the puddles show her")
	assert_eq(scene.find_children("*", "PointLight2D", true, false).size(), 0, "ADR-070 O3")
	assert_not_null(scene.player)
	assert_not_null(scene.map.data.find_marker("player_spawn"))


func test_a_new_game_starts_on_the_path_one_cell_below_the_arrival() -> void:
	var scene := await _scene()
	assert_eq(scene.map.data.find_marker("player_spawn")[0]["cell"], START_CELL)
	assert_eq(scene.map.world_to_cell(scene.player.global_position), START_CELL)
	assert_eq(START_CELL.y - ARRIVAL_CELL.y, 1)


func test_the_arrival_from_the_forest_path_is_outside_the_doors_zone() -> void:
	SceneTravel.stay = true
	SceneTravel.pending_spawn = "waldweg"
	var scene := await _scene()
	assert_eq(scene.map.data.find_marker("spawn_waldweg")[0]["cell"], ARRIVAL_CELL)
	assert_eq(scene.map.world_to_cell(scene.player.global_position), ARRIVAL_CELL)
	var doors := _doors(scene, "waldweg")
	assert_eq(doors.size(), 1, "one door, and it goes back to the forest path")
	assert_eq(doors[0].get(&"spawn"), "flutlichtung", "to the place the forest path made for it")
	assert_true(doors[0].get(&"auto"), "the path itself leads through it")
	assert_eq(_cell_of(scene, doors[0]), DOOR_CELL)
	assert_gte(ARRIVAL_CELL.y - DOOR_CELL.y, 4, "an arrival outside the door's zone")
	assert_true(SceneRegistry.has("waldweg"), "the door has somewhere to go")
	await wait_physics_frames(10)
	assert_eq(SceneTravel.last_target, "", "no way back in at once")


func test_the_door_out_is_reached_going_north_from_the_arrival() -> void:
	SceneTravel.stay = true
	SceneTravel.pending_spawn = "waldweg"
	await _scene()
	assert_eq(SceneTravel.last_target, "", "nothing has travelled yet")
	var gone := func() -> bool: return SceneTravel.last_target == "waldweg"
	assert_true(await _hold(&"move_up", gone, 240), "north from the arrival reaches the door")


func test_the_forest_path_has_the_counterpart_of_the_door() -> void:
	SceneTravel.stay = true
	SceneTravel.pending_spawn = "flutlichtung"
	WorldState.set_flag("house.antreiber_by_fire")  # no one stands on the way
	var scene: GameScene = WALDWEG.instantiate()
	add_child_autofree(scene)
	await wait_physics_frames(3)
	var doors := _doors(scene, "flutlichtung")
	assert_eq(doors.size(), 1, "one door, and it goes on to the clearing")
	assert_eq(doors[0].get(&"spawn"), "waldweg", "to the place this map made for it")
	assert_false(scene.map.data.find_marker("spawn_flutlichtung").is_empty())


func test_the_places_lie_from_north_to_south_in_the_order_she_meets_them() -> void:
	var scene := await _scene()
	var rows: Dictionary[String, int] = {}
	var columns: Dictionary[String, int] = {}
	for cue in SPOTS:
		var matching := scene.map.entities.get_children().filter(
			func(node: Node) -> bool:
				return (
					not node.is_queued_for_deletion()
					and (
						(node.has_meta(&"cue") and node.get_meta(&"cue") == cue)
						or (node is NpcWalker and (node as NpcWalker).cue == cue)
					)
				)
		)
		assert_eq(matching.size(), 1, "'%s' stands once" % cue)
		var cell := _cell_of(scene, matching[0])
		rows[cue] = cell.y
		columns[cue] = cell.x
	assert_lt(ARRIVAL_CELL.y, rows["flood_trail"], "the trail first")
	assert_lt(rows["flood_trail"], rows["flood_mark"], "then the trunk")
	assert_lt(rows["flood_mark"], rows["flood_camp"], "then the camp")
	assert_lt(rows["flood_camp"], rows["driftwood"], "then the bank")
	assert_lt(rows["driftwood"], rows["stones"])
	assert_lt(rows["stones"], BLOCKER_CELL.y, "and the way on after all of them")
	assert_lt(columns["nest"], START_CELL.x - 15, "the nest lies off to the west, in the grass")
	assert_gt(columns["fork"], columns["flood_mark"] + 10, "the fork stands at the water")
	assert_gt(columns["driftwood"], columns["flood_camp"] + 10, "the bank is east of the camp")
	var mark_distance := Vector2(ARRIVAL_CELL).distance_to(
		Vector2(columns["flood_mark"], rows["flood_mark"])
	)
	assert_lt(mark_distance, 25.0, "the trunk is a landmark from the corridor's edge")
	assert_gte(rows["flood_trail"] - ARRIVAL_CELL.y, 6, "the trail starts well below the door")


func test_the_trail_lies_in_the_corridor_and_the_things_are_what_the_map_says() -> void:
	var scene := await _scene()
	var trail := _first(scene, "flood_trail")
	var mark := _first(scene, "flood_mark")
	assert_eq(_cell_of(scene, trail).x, START_CELL.x, "in the corridor she comes down")
	assert_true(mark is Decor)
	assert_eq((mark as Decor).sprite_id, "tal/wd_flood_mark")
	assert_eq((trail as Decor).sprite_id, "tal/wd_flood_prints")
	assert_eq((_first(scene, "flood_camp") as Decor).sprite_id, "tal/wd_flood_ring")
	assert_eq(_decor_with(scene, "tal/wd_flood_blanket").size(), 1, "one blanket")
	assert_false(_decor_with(scene, "tal/wd_flood_blanket")[0].has_meta(&"cue"), "it has no voice")
	assert_gte(_decor_with(scene, "tal/wd_flood_beech").size(), 15, "the beeches carry the line")


func test_every_cue_of_the_map_is_in_the_file_and_every_cue_of_the_file_is_reached() -> void:
	var scene := await _scene()
	var cues: Array = (load(DIALOGUE) as DialogueResource).get_cues()
	var named: Array[String] = []
	for placement: Dictionary in scene.map.data.placements:
		var params: Dictionary = placement["params"]
		if not params.has("cue"):
			continue
		var cue: String = params["cue"]
		assert_true(cue in cues, "cue '%s' of the map is in the file" % cue)
		assert_eq(params.get("dialogue"), DIALOGUE, "'%s' reads this file" % cue)
		if not cue in named:
			named.append(cue)
	for cue: String in cues:
		assert_true(
			cue in named or cue in INNER_CUES, "cue '%s' is reached from the map or by a jump" % cue
		)
	assert_gte(named.size(), 9, "the things, the Antreiber, the finds and the blocker")


func test_nothing_in_the_scene_is_timed_counted_or_locked() -> void:
	var source := FileAccess.get_file_as_string("res://world/levels/akt3/flutlichtung_scene.gd")
	var code: PackedStringArray = []
	for raw in source.split("\n"):
		if not raw.strip_edges().begins_with("#"):
			code.append(raw)
	var text := "\n".join(code)
	assert_gt(code.size(), 15, "the scene was read")
	for word: String in FORBIDDEN_IN_THE_SCENE:
		assert_false(text.contains(word), "'%s' in flutlichtung_scene.gd" % word)
	var scene := await _scene()
	assert_false(scene.player.is_locked(), "she arrives free")
	await wait_physics_frames(30)
	assert_false(scene.player.is_locked(), "and nothing takes her")
	assert_false(scene.dialogue_box.is_open(), "no one speaks to her before she looks")
	assert_true(SaveSystem.blockers().is_empty(), "nothing holds the game from saving")


# --- The Antreiber ---------------------------------------------------------------------


func test_he_stands_at_the_trunk_for_whoever_did_not_leave_him_at_the_fire() -> void:
	var scene := await _scene()
	var him := _antreiber(scene)
	assert_eq(him.size(), 1, "one Antreiber")
	assert_eq(_figures(scene).size(), 1, "and no one else on the map")
	assert_false((him[0] as NpcWalker).seated, "standing")
	var mark := _first(scene, "flood_mark") as Node2D
	assert_lte(him[0].global_position.distance_to(mark.global_position), 32.0, "at the trunk")
	var spot: Vector2 = him[0].global_position
	await wait_physics_frames(30)
	assert_eq(him[0].global_position, spot, "he measures on the spot and goes nowhere")
	assert_true(WorldState.has_flag("forest.antreiber_ahead"), "he went on ahead of her")
	assert_false(WorldState.has_flag("forest.flood_sat"))
	assert_false(WorldState.has_flag("forest.flood_seen"), "the clearing alone decides nothing")


func test_he_is_not_here_for_whoever_left_him_by_the_fire_in_the_house() -> void:
	WorldState.set_flag("house.antreiber_by_fire")
	var scene := await _scene()
	assert_eq(_antreiber(scene).size(), 0, "the cat lies on him")
	assert_eq(_figures(scene).size(), 0)
	assert_false(WorldState.has_flag("forest.antreiber_ahead"), "he did not go on ahead")
	for cue: String in ["flood_trail", "flood_mark", "flood_camp"]:
		assert_not_null(_first(scene, cue), "the thing '%s' stands without him" % cue)
	WorldState.set_flag("forest.flood_sat")
	await wait_physics_frames(3)
	assert_eq(_figures(scene).size(), 0, "and no tea seats him")


func test_the_clearing_looks_the_same_to_him_in_every_state_he_can_have_come_in() -> void:
	var states: Array[Array] = [
		[],
		["house.antreiber_left"],
		["house.antreiber_left", "house.antreiber_postponed"],
		["valley.antreiber_rests"],
		["forest.antreiber_met"],
		["forest.antreiber_met", "forest.antreiber_sat"],
	]
	for flags: Array in states:
		WorldState.new_game()
		for flag: String in flags:
			WorldState.set_flag(flag)
		var scene := await _scene()
		assert_eq(_antreiber(scene).size(), 1, "one of him with %s" % [flags])
		assert_eq(_figures(scene).size(), 1)
		assert_false((_antreiber(scene)[0] as NpcWalker).seated, "standing with %s" % [flags])
		assert_true(WorldState.has_flag("forest.antreiber_ahead"), "ahead with %s" % [flags])
		scene.queue_free()
		await wait_physics_frames(2)


func test_after_tea_he_sits_instead_of_standing_and_never_two_of_him() -> void:
	WorldState.set_flag("forest.flood_sat")
	var scene := await _scene()
	var him := _antreiber(scene)
	assert_eq(him.size(), 1, "one of him")
	assert_eq(_figures(scene).size(), 1)
	assert_true((him[0] as NpcWalker).seated, "sitting")
	assert_eq(him[0].get(&"cue"), "antreiber_flood", "he is the same man, with the same cue")
	var mark := _first(scene, "flood_mark") as Node2D
	assert_lte(him[0].global_position.distance_to(mark.global_position), 48.0, "beside the trunk")


func test_tea_swaps_the_one_who_stands_for_the_one_who_sits_on_the_same_spot() -> void:
	var scene := await _scene()
	var standing := _antreiber(scene)[0] as NpcWalker
	var from := standing.global_position
	assert_false(Beat.reached("flut_tea"))
	WorldState.set_flag("forest.flood_sat")
	await wait_physics_frames(3)
	var now := _antreiber(scene)
	assert_eq(now.size(), 1, "never two of him")
	assert_eq(_figures(scene).size(), 1)
	assert_true((now[0] as NpcWalker).seated)
	assert_lte(now[0].global_position.distance_to(from), 20.0, "he sits down where he stood")
	assert_true(Beat.reached("flut_tea"))


func test_the_beat_of_the_tea_comes_with_the_tea_and_not_with_the_clearing() -> void:
	await _scene()
	assert_true(Beat.reached("flut_enter"))
	assert_false(Beat.reached("flut_tea"))
	assert_false(Beat.reached("flut_mark"))
	WorldState.set_flag("forest.flood_seen")
	await wait_physics_frames(2)
	assert_false(Beat.reached("flut_tea"), "seeing the trunk is no tea")


func test_the_path_and_the_valley_keep_no_second_one_of_him_once_he_has_been_here() -> void:
	# the baselines: with these flags and without the visit, he is there
	WorldState.set_flag("valley.antreiber_rests")
	assert_eq(await _count_in(TAL, "antreiber_west"), 1, "resting on the bench in the valley")
	WorldState.new_game()
	WorldState.set_flag("house.antreiber_left")
	assert_eq(await _count_in(TAL, "antreiber_busy"), 1, "busy at the woodpile")
	WorldState.new_game()
	assert_eq(await _count_in(WALDWEG, "antreiber_end"), 1, "at the empty board")
	# the visit: the clearing sets the flag, and the other maps read it
	WorldState.new_game()
	var scene := await _scene()
	assert_true(WorldState.has_flag("forest.antreiber_ahead"))
	scene.queue_free()
	await wait_physics_frames(2)
	assert_eq(await _count_in(WALDWEG, "antreiber_end"), 0, "gone from the board")
	WorldState.set_flag("forest.antreiber_sat")
	assert_eq(await _count_in(WALDWEG, "antreiber_end"), 0, "and not sitting by it either")
	WorldState.set_flag("valley.antreiber_rests")
	assert_eq(await _count_in(TAL, "antreiber_west"), 0, "not on the bench in the valley")
	WorldState.set_flag("house.antreiber_left")
	assert_eq(await _count_in(TAL, "antreiber_busy"), 0, "and not at the woodpile")


# --- The goal "flood" of the hero's walk ---------------------------------------------------


func test_the_trunk_ends_one_goal_of_the_wood_and_not_the_wood_without_the_hut() -> void:
	_walk_to("wood")
	await _scene()
	assert_false(WorldState.is_objective_done(QUEST, "flood"), "entering is not seeing")
	assert_eq(WorldState.quest_stage(QUEST), "wood", "entering moves no quest")
	assert_false(Beat.reached("flut_mark"))
	WorldState.set_flag("forest.flood_seen")
	await wait_physics_frames(2)
	assert_true(WorldState.is_objective_done(QUEST, "flood"))
	assert_false(WorldState.is_objective_done(QUEST, "hermit"), "the hut was not asked")
	assert_eq(WorldState.quest_stage(QUEST), "wood", "the way goes on")
	assert_true(WorldState.is_quest_active(QUEST), "the clearing is not the end of the way")
	assert_true(Beat.reached("flut_mark"))
	assert_false(WorldState.has_flag("forest.night_way"), "the way on to the south stays shut")


func test_with_the_hut_seen_first_the_trunk_ends_the_wood() -> void:
	_walk_to("wood")
	WorldState.complete_objective(QUEST, "hermit")
	await _scene()
	assert_eq(WorldState.quest_stage(QUEST), "wood", "the hut alone is not the night")
	WorldState.set_flag("forest.flood_seen")
	await wait_physics_frames(2)
	assert_eq(WorldState.quest_stage(QUEST), "night")
	assert_true(WorldState.is_quest_active(QUEST), "the night is not the end of the way (W6)")
	assert_eq(WorldState.quest_outcome(QUEST), "")
	assert_true(Beat.reached("flut_mark"))
	assert_true(WorldState.has_flag("forest.night_way"), "and with the night the way on opens")


func test_a_game_without_the_walk_gets_no_quest_and_no_error_from_the_trunk() -> void:
	await _scene()
	WorldState.set_flag("forest.flood_seen")
	await wait_physics_frames(2)
	assert_eq(WorldState.quest_stage(QUEST), "", "the quest only moves, never starts here")
	assert_false(WorldState.is_quest_started(QUEST))
	assert_true(Beat.reached("flut_mark"), "the visit is still marked")
	assert_push_error_count(0, "no unknown objective, no refused stage")


func test_in_any_other_stage_the_trunk_changes_nothing_and_logs_no_error() -> void:
	for stage: String in ["leave", "brook", "night", "home", "done"]:
		WorldState.new_game()
		_walk_to(stage)
		var before := WorldState.state.quests[QUEST].objectives_done.duplicate()
		var scene := await _scene()
		WorldState.set_flag("forest.flood_seen")
		await wait_physics_frames(2)
		assert_eq(WorldState.quest_stage(QUEST), stage, "stage %s stays" % stage)
		assert_eq(WorldState.state.quests[QUEST].objectives_done, before, "no goal in " + stage)
		scene.queue_free()
		await wait_physics_frames(2)
	assert_push_error_count(0, "no unknown objective in a stage that has none")


func test_a_second_visit_moves_nothing_again() -> void:
	_walk_to("wood")
	WorldState.complete_objective(QUEST, "hermit")
	var first := await _scene()
	WorldState.set_flag("forest.flood_seen")
	await wait_physics_frames(2)
	assert_eq(WorldState.quest_stage(QUEST), "night")
	first.queue_free()
	await wait_physics_frames(2)
	var moves: Array[String] = []
	var on_stage := func(quest_id: String, stage: String) -> void: moves.append(quest_id + stage)
	var on_goal := func(quest_id: String, goal: String) -> void: moves.append(quest_id + goal)
	WorldState.quest_changed.connect(on_stage)
	WorldState.objective_changed.connect(on_goal)
	var again := await _scene()
	await _read(again, _first(again, "flood_mark"))
	await wait_physics_frames(3)
	WorldState.quest_changed.disconnect(on_stage)
	WorldState.objective_changed.disconnect(on_goal)
	assert_eq(moves, [] as Array[String], "no stage and no goal moved a second time")
	assert_eq(WorldState.quest_stage(QUEST), "night")
	assert_push_error_count(0)


func test_seeing_the_trunk_twice_in_one_visit_moves_the_quest_once() -> void:
	_walk_to("wood")
	WorldState.complete_objective(QUEST, "hermit")
	var scene := await _scene()
	var moves: Array[String] = []
	var on_stage := func(quest_id: String, stage: String) -> void: moves.append(quest_id + stage)
	WorldState.quest_changed.connect(on_stage)
	var mark := _first(scene, "flood_mark")
	await _read(scene, mark)
	await _read(scene, mark)
	WorldState.quest_changed.disconnect(on_stage)
	assert_eq(moves, [QUEST + "night"] as Array[String], "one step to the night")
	assert_push_error_count(0)


func test_looking_at_the_trunk_in_the_box_sets_the_flag_last_and_the_scene_does_the_rest() -> void:
	_walk_to("wood")
	WorldState.complete_objective(QUEST, "hermit")
	var scene := await _scene()
	var mark := _first(scene, "flood_mark")
	var order: Array[String] = []
	var on_flag := func(id: String, value: bool) -> void:
		if value and id == "forest.flood_seen":
			order.append("flag")
			order.append("box open" if scene.dialogue_box.is_open() else "box shut")
	WorldState.flag_changed.connect(on_flag)
	await _read(scene, mark)
	WorldState.flag_changed.disconnect(on_flag)
	assert_eq(order, ["flag", "box open"] as Array[String], "set at the end of the lines")
	assert_eq(WorldState.quest_stage(QUEST), "night")
	assert_true(Beat.reached("flut_mark"))
	var flags_before := WorldState.state.flags.duplicate()
	await _read(scene, mark)
	assert_eq(WorldState.state.flags, flags_before, "the second look sets nothing")


# --- Tea at the trunk (the real box) -----------------------------------------------------


func test_tea_is_offered_only_with_care_and_the_answers_change_in_the_real_box() -> void:
	var scene := await _scene()
	var him := _antreiber(scene)[0]
	var plain := await _talk_through(scene, him, PackedStringArray([LineText.of("fl_ask_r2")]))
	assert_eq(plain.size(), 1, "one group of answers")
	assert_eq(
		plain[0],
		PackedStringArray([LineText.of("fl_ask_r2"), LineText.of("fl_ask_r3")]),
		"without care: staying and the silence, no tea"
	)
	assert_true(WorldState.has_flag("forest.antreiber_met"), "he was spoken to")
	assert_false(WorldState.has_flag("forest.flood_sat"))
	assert_false(Beat.reached("flut_tea"))
	assert_eq(_antreiber(scene).size(), 1)
	assert_false((_antreiber(scene)[0] as NpcWalker).seated, "he stands on")
	WorldState.set_facet("care")
	var offered := await _talk_through(
		scene, _antreiber(scene)[0], PackedStringArray([LineText.of("fl_ask_r1")])
	)
	assert_eq(
		offered[0],
		PackedStringArray(
			[LineText.of("fl_ask_r1"), LineText.of("fl_ask_r2"), LineText.of("fl_ask_r3")]
		),
		"with care: the tea is the first answer"
	)
	assert_true(WorldState.has_flag("forest.flood_sat"))
	assert_true(Beat.reached("flut_tea"))
	var now := _antreiber(scene)
	assert_eq(now.size(), 1, "never two of him")
	assert_true((now[0] as NpcWalker).seated, "and he sits")


func test_tea_sets_the_sitting_and_the_beat_and_nothing_else() -> void:
	WorldState.set_facet("care")
	WorldState.start_quest(NEST_QUEST)
	var scene := await _scene()
	var flags := WorldState.state.flags.duplicate()
	var items := WorldState.state.inventory.duplicate()
	var quests := WorldState.state.quests.size()
	await _talk_through(scene, _antreiber(scene)[0], PackedStringArray([LineText.of("fl_ask_r1")]))
	var added: Array[String] = []
	for flag: String in WorldState.state.flags:
		if not flags.has(flag):
			added.append(flag)
	added.sort()
	assert_eq(
		added,
		["beat.flut_tea", "forest.antreiber_met", "forest.flood_sat"] as Array[String],
		"met, sat, and the beat that marks it"
	)
	assert_eq(WorldState.state.inventory, items, "he gives nothing and takes nothing")
	assert_eq(WorldState.state.quests.size(), quests, "no quest started")
	assert_true(WorldState.has_facet("care"), "the facet stays")
	assert_eq(WorldState.quest_stage(NEST_QUEST), "find", "the nest is none of his business")


func test_staying_and_the_silence_do_not_seat_him_even_with_care() -> void:
	WorldState.set_facet("care")
	var scene := await _scene()
	for pick: String in ["fl_ask_r2", "fl_ask_r3"]:
		await _talk_through(scene, _antreiber(scene)[0], PackedStringArray([LineText.of(pick)]))
		assert_false(WorldState.has_flag("forest.flood_sat"), pick)
		assert_false((_antreiber(scene)[0] as NpcWalker).seated, "still standing after " + pick)
		assert_false(Beat.reached("flut_tea"))
	assert_eq(_antreiber(scene).size(), 1)


func test_once_he_sits_he_is_spoken_to_with_the_short_cue_and_keeps_sitting() -> void:
	WorldState.set_facet("care")
	var scene := await _scene()
	await _talk_through(scene, _antreiber(scene)[0], PackedStringArray([LineText.of("fl_ask_r1")]))
	var flags := WorldState.state.flags.duplicate()
	var offered := await _talk_through(
		scene, _antreiber(scene)[0], PackedStringArray([LineText.of("fl_again_r1")])
	)
	assert_eq(
		offered[0],
		PackedStringArray([LineText.of("fl_again_r1"), LineText.of("fl_again_r2")]),
		"one answer and the silence, and no tea again"
	)
	assert_eq(WorldState.state.flags, flags, "nothing new")
	var now := _antreiber(scene)
	assert_eq(now.size(), 1)
	assert_true((now[0] as NpcWalker).seated, "he stays where he sits")


# --- Side quest B: the nest and the fork ---------------------------------------------------


func test_the_nest_is_taken_once_and_is_gone_from_the_grass_after_it() -> void:
	var scene := await _scene()
	assert_eq(_decor_with(scene, "tal/wd_nest").size(), 1, "one nest in the grass")
	assert_false(WorldState.is_quest_started(NEST_QUEST))
	var offered := await _talk_through(
		scene, _first(scene, "nest"), PackedStringArray([LineText.of("fl_nest_r1")])
	)
	assert_eq(
		offered[0],
		PackedStringArray(
			[LineText.of("fl_nest_r1"), LineText.of("fl_nest_r2"), LineText.of("fl_nest_r3")]
		),
		"take it, leave it, the silence"
	)
	assert_true(WorldState.has_flag("forest.nest_taken"))
	assert_eq(WorldState.quest_stage(NEST_QUEST), "fork")
	assert_null(_first(scene, "nest"), "gone from the grass")
	assert_eq(_decor_with(scene, "tal/wd_nest").size(), 0)
	scene.queue_free()
	await wait_physics_frames(2)
	var again := await _scene()
	assert_null(_first(again, "nest"), "and not back in a second visit")
	assert_eq(_decor_with(again, "tal/wd_nest").size(), 0)


func test_leaving_the_nest_changes_nothing_and_it_can_be_looked_at_again() -> void:
	var scene := await _scene()
	await _talk_through(
		scene, _first(scene, "nest"), PackedStringArray([LineText.of("fl_nest_r2")])
	)
	assert_false(WorldState.has_flag("forest.nest_taken"))
	assert_eq(WorldState.quest_stage(NEST_QUEST), "find", "seen, not taken")
	assert_not_null(_first(scene, "nest"), "it lies in the grass")
	await _talk_through(
		scene, _first(scene, "nest"), PackedStringArray([LineText.of("fl_nest_r3")])
	)
	assert_eq(WorldState.quest_stage(NEST_QUEST), "find", "seeing it twice starts nothing twice")
	await _talk_through(
		scene, _first(scene, "nest"), PackedStringArray([LineText.of("fl_nest_r1")])
	)
	assert_eq(WorldState.quest_stage(NEST_QUEST), "fork", "and it can be taken later")
	assert_push_error_count(0)


func test_the_fork_shows_the_nest_in_it_once_it_is_placed_and_is_one_prop_all_along() -> void:
	var scene := await _scene()
	assert_eq((_first(scene, "fork") as Decor).sprite_id, "tal/wd_fork")
	assert_eq(_decor_with(scene, "tal/wd_fork").size(), 1)
	assert_eq(_decor_with(scene, "tal/wd_fork_nest").size(), 0)
	WorldState.set_flag("forest.nest_placed")
	await wait_physics_frames(3)
	assert_eq((_first(scene, "fork") as Decor).sprite_id, "tal/wd_fork_nest", "with the nest in it")
	assert_eq(_decor_with(scene, "tal/wd_fork_nest").size(), 1, "one fork, not two")
	assert_eq(_decor_with(scene, "tal/wd_fork").size(), 0)
	scene.queue_free()
	await wait_physics_frames(2)
	var again := await _scene()
	assert_eq((_first(again, "fork") as Decor).sprite_id, "tal/wd_fork_nest", "and in a new visit")


func test_the_fork_asks_nothing_without_the_nest() -> void:
	var scene := await _scene()
	var flags := WorldState.state.flags.duplicate()
	var offered := await _talk_through(scene, _first(scene, "fork"), PackedStringArray())
	assert_eq(offered.size(), 0, "an observation, no answer")
	assert_eq(WorldState.state.flags, flags, "nothing is set")
	assert_false(WorldState.is_quest_started(NEST_QUEST))


func test_the_nest_goes_into_the_fork_in_three_stages_and_the_quest_ends_there() -> void:
	var scene := await _scene()
	var stages: Array[String] = []
	var on_stage := func(quest_id: String, stage: String) -> void:
		if quest_id == NEST_QUEST:
			stages.append(stage)
	WorldState.quest_changed.connect(on_stage)
	await _talk_through(
		scene, _first(scene, "nest"), PackedStringArray([LineText.of("fl_nest_r1")])
	)
	var waiting := await _talk_through(
		scene, _first(scene, "fork"), PackedStringArray([LineText.of("fl_fork_r2")])
	)
	assert_eq(
		waiting[0],
		PackedStringArray(
			[LineText.of("fl_fork_r1"), LineText.of("fl_fork_r2"), LineText.of("fl_fork_r3")]
		),
		"with the nest in her hands: put it in, not yet, the silence"
	)
	assert_eq(WorldState.quest_stage(NEST_QUEST), "fork", "not yet is not done")
	assert_false(WorldState.has_flag("forest.nest_placed"))
	assert_eq((_first(scene, "fork") as Decor).sprite_id, "tal/wd_fork")
	await _talk_through(
		scene, _first(scene, "fork"), PackedStringArray([LineText.of("fl_fork_r1")])
	)
	WorldState.quest_changed.disconnect(on_stage)
	assert_eq(stages, ["find", "fork", "done"] as Array[String], "in this order, each once")
	assert_true(WorldState.is_quest_done(NEST_QUEST))
	assert_true(WorldState.has_flag("forest.nest_placed"))
	await wait_physics_frames(3)
	assert_eq((_first(scene, "fork") as Decor).sprite_id, "tal/wd_fork_nest", "she sees it lie")
	var after := await _talk_through(scene, _first(scene, "fork"), PackedStringArray())
	assert_eq(after.size(), 0, "afterwards one line and no answer")
	assert_eq(WorldState.quest_stage(QUEST), "", "the hero's walk is none of its business")
	assert_push_error_count(0)


# --- The driftwood, the stones, the way on ---------------------------------------------------


func test_the_driftwood_is_taken_once_and_leaves_the_bank() -> void:
	var scene := await _scene()
	assert_eq(_decor_with(scene, "tal/wd_driftwood").size(), 1)
	await _talk_through(
		scene, _first(scene, "driftwood"), PackedStringArray([LineText.of("fl_drift_r2")])
	)
	assert_false(WorldState.has_item("curiosity_driftwood"), "left on the bank")
	assert_eq(_decor_with(scene, "tal/wd_driftwood").size(), 1, "and still there")
	var offered := await _talk_through(
		scene, _first(scene, "driftwood"), PackedStringArray([LineText.of("fl_drift_r1")])
	)
	assert_eq(offered[0].size(), 3, "take it, leave it, the silence")
	assert_eq(WorldState.item_count("curiosity_driftwood"), 1)
	assert_true(WorldState.has_flag("forest.driftwood_taken"))
	await wait_physics_frames(3)
	assert_eq(_decor_with(scene, "tal/wd_driftwood").size(), 0, "gone from the bank")
	assert_null(_first(scene, "driftwood"))
	assert_eq(Collection.curiosities(), 1)
	scene.queue_free()
	await wait_physics_frames(2)
	var again := await _scene()
	assert_eq(_decor_with(again, "tal/wd_driftwood").size(), 0, "and not back in a second visit")


func test_the_stones_are_a_fragment_once_and_a_short_line_afterwards() -> void:
	var scene := await _scene()
	assert_eq(Collection.fragments(), 0)
	await _read(scene, _first(scene, "stones"))
	assert_true(WorldState.has_flag("fragment.stepping_stones"))
	assert_eq(Collection.fragments(), 1)
	var flags := WorldState.state.flags.duplicate()
	await _read(scene, _first(scene, "stones"))
	assert_eq(Collection.fragments(), 1, "not counted twice")
	assert_eq(WorldState.state.flags, flags, "the second look sets nothing")
	assert_eq(_decor_with(scene, "tal/wd_stones").size(), 1, "the stones stay in the brook")
	assert_false(WorldState.has_flag("forest.flood_seen"), "they are not the trunk")


func test_the_stones_carry_her_across_the_brook_and_the_water_beside_them_does_not() -> void:
	var scene := await _scene()
	await _go_to(scene, ABOVE_FORD)
	var held := func() -> bool: return false
	await _hold(&"move_right", held, 120)
	assert_lt(_cell_of(scene, scene.player).x, FORD_WEST.x + 2, "the water holds her back")
	await _go_to(scene, FORD_WEST)
	var across := func() -> bool: return _cell_of(scene, scene.player).x >= FORD_EAST.x
	assert_true(await _hold(&"move_right", across, 240), "over the stones to the far bank")
	assert_eq(_cell_of(scene, scene.player).y, FORD_EAST.y, "straight over, not around")


func test_the_way_on_to_the_south_is_shut_and_holds_you_back_before_the_night() -> void:
	# behind the blocker lies the door to the night wood: if it ever gives way, no real scene change
	SceneTravel.stay = true
	var scene := await _scene()
	var blocker := _at(scene, BLOCKER_CELL, BLOCKER_SCRIPT)
	assert_not_null(blocker, "a blocker across the path")
	assert_not_null(
		_at(scene, NIGHT_DOOR_CELL, DOOR_SCRIPT), "the door to the night wood lies behind it"
	)
	assert_false(WorldState.has_flag("forest.night_way"), "the way is not open")
	await _go_to(scene, Vector2i(BLOCKER_CELL.x, BLOCKER_CELL.y - 4))
	var stopped := func() -> bool: return false
	await _hold(&"move_down", stopped, 240)
	assert_lt(_cell_of(scene, scene.player).y, BLOCKER_CELL.y, "she stands before it")
	assert_eq(SceneTravel.last_target, "", "no way through to the south")
	var flags := WorldState.state.flags.duplicate()
	await _read(scene, blocker)
	assert_eq(WorldState.state.flags, flags, "trying it sets nothing")
	var doors := scene.map.entities.get_children().filter(
		func(node: Node) -> bool: return node.get_script() == DOOR_SCRIPT
	)
	assert_eq(
		doors.size(), 2, "two doors on the map: the way back and the way on behind the blocker"
	)
	assert_eq(_doors(scene, "waldweg").size(), 1)
	assert_eq(_doors(scene, "nachtwald").size(), 1)
