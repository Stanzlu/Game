# gdlint: ignore=max-public-methods
extends GutTest
## Act III, segment W5, the scene of the night wood: a small map (class S) in the palette of the
## night, without rain, fog, music or light (Plan 7), with a path from the clearing in the north,
## a glade in the middle and a way on to the south-west. On the glade a small lantern stands on
## the ground and burns. Whoever walks up to it finds it where it stood; whoever sits down beside
## it (the sitting is the waiting, there is no clock) hears a hum, once, very quietly and from no
## direction, and it stops. The glowing trunk can be broken a piece from, the two doors are never
## locked. Nothing is needed to go on and whoever looks away or walks on loses nothing.
## What is said is tested in test_akt3_nachtwald, what is drawn over what in
## test_akt3_nachtwald_bild, the way in from the Flutlichtung in test_akt3_flutlichtung_nacht, the
## map in test_layout_akt3.py.

const NACHTWALD := preload("res://world/levels/akt3/nachtwald.tscn")
const FLUT := preload("res://world/levels/akt3/flutlichtung.tscn")
const TAL := preload("res://world/levels/slice/tal.tscn")
const DOOR_SCRIPT := preload("res://world/props/door.gd")
const DIALOGUE := "res://content/dialogue/akt3/nachtwald.dialogue"
const SCENE_SOURCE := "res://world/levels/akt3/nachtwald_scene.gd"
const SCENE_FILE := "res://world/levels/akt3/nachtwald.tscn"
const QUEST := "main_forest_way"
const WAY: Array[String] = ["leave", "brook", "wood", "night"]
const NORTH_DOOR_CELL := Vector2i(37, 1)
const ARRIVAL_CELL := Vector2i(37, 6)
const START_CELL := Vector2i(37, 7)
const SOUTH_DOOR_CELL := Vector2i(8, 32)
const HOME_WAY_CELL := Vector2i(9, 28)
const LANTERN_CELL := Vector2i(16, 21)
const POOL_CELL := Vector2i(16, 20)
const LOG_CELL := Vector2i(10, 17)
## Where the seat lies from the lantern's foot (the map's "sit" offset): its east side.
const SEAT_OFFSET := Vector2(18, 2)
## The marker the door to the valley arrives at there, and the door behind it.
const TAL_ARRIVAL_CELL := Vector2i(42, 33)
const TAL_DOOR_CELL := Vector2i(42, 37)
const NIGHT_PALETTE := Color(0.5, 0.55, 0.74, 1)
## The things on the map that have a cue, once each (the lantern has none: it is only a seat).
const SPOTS: Array[String] = ["glow_tree", "lantern_far", "foxfire", "home_way"]
const BRIGHT_LOG := "tal/wd_foxfire_log"
const DIM_LOG := "tal/wd_foxfire_log_dim"
## What the scene may not do in code (comments left out): it waits for no one, holds no one and
## moves nothing.
const FORBIDDEN_IN_THE_SCENE: Array[String] = [
	"NodeTimer",
	"create_timer",
	"Time.get_ticks",
	"timing_factor",
	"Tween",
	"Cutscene",
	"Blocker",
	".lock(",
	"physics_frame",
	"process_frame",
	"flash",
	"flicker",
	"strobe",
	"shake",
	"global_position",
	"position =",
]
## What a catalog entry may not have if its flame is to stand still.
const MOVING_KEYS: Array[String] = ["flicker", "lights", "glow", "sway", "bob", "smoke", "sparkle"]

var _listener := Callable()


func before_each() -> void:
	WorldState.new_game()
	WorldState.set_ui_mode(GameState.UiMode.REAL)
	WorldState.set_day_preset("morgen")
	Settings.set_value("text.auto_advance", false, false)
	Settings.set_value("text.speed", 3, false)


func after_each() -> void:
	if _listener.is_valid() and AudioDirector.caption_requested.is_connected(_listener):
		AudioDirector.caption_requested.disconnect(_listener)
	_listener = Callable()
	Input.action_release(&"move_up")
	Input.action_release(&"move_down")
	Input.action_release(&"move_left")
	Input.action_release(&"move_right")
	Settings.set_value("access.captions", false, false)
	Settings.set_value("text.auto_advance", false, false)
	Settings.set_value("text.speed", 1, false)
	SceneTravel.pending_spawn = ""
	SceneTravel.arrival_fade = -1.0
	SceneTravel.stay = false
	SceneTravel.last_target = ""
	WorldState.new_game()
	ScreenFade.fade_in(0.0)
	get_tree().paused = false


func _scene() -> NachtwaldScene:
	var scene: NachtwaldScene = NACHTWALD.instantiate()
	add_child_autofree(scene)
	await wait_physics_frames(3)
	return scene


func _alive(scene: GameScene, prefix: String) -> Array[Node]:
	return scene.map.entities.get_children().filter(
		func(node: Node) -> bool:
			return str(node.name).begins_with(prefix) and not node.is_queued_for_deletion()
	)


func _decor_with(scene: GameScene, sprite: String) -> Array:
	return _alive(scene, "Decor").filter(
		func(node: Node) -> bool: return (node as Decor).sprite_id == sprite
	)


## A prop with this cue (a Decor keeps it as meta), or null.
func _first(scene: GameScene, cue: String) -> Node:
	for node in scene.map.entities.get_children():
		if node.is_queued_for_deletion():
			continue
		if node.has_meta(&"cue") and node.get_meta(&"cue") == cue:
			return node
	return null


func _lantern(scene: GameScene) -> Decor:
	var found := _decor_with(scene, "tal/wd_lantern")
	assert_eq(found.size(), 1, "one lantern")
	return found[0]


func _doors(scene: GameScene, target: String) -> Array[Node]:
	return scene.map.entities.get_children().filter(
		func(node: Node) -> bool: return node.get(&"target") == target
	)


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


## What looking at a thing does: the same signal the player's key sends.
func _look(prop: Node) -> void:
	(prop.get_node("Interactable") as Interactable).interacted.emit(null)


## Sits down beside the lantern the way the key does: on its seat, from the cell next to it.
func _sit(scene: GameScene) -> void:
	var lantern := _lantern(scene)
	await _go_to(scene, LANTERN_CELL + Vector2i(2, 0))
	var seat := lantern.get_node_or_null("Interactable") as Interactable
	assert_not_null(seat, "the lantern has a seat")
	seat.interacted.emit(scene.player)
	await wait_physics_frames(3)


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


## Moves the lines of the cue on with the confirm key until the box is shut again. It has to have
## come up at all, and it may not ask anything (the cue of the lantern has no answer).
func _read_through(scene: GameScene) -> void:
	var opened := [false]
	var watch := func() -> bool:
		if scene.dialogue_box.is_open():
			opened[0] = true
			assert_false(_asked(scene), "the lantern asks no question")
			_confirm()
		return opened[0] and not scene.dialogue_box.is_open()
	var done: bool = await wait_until(watch, 60.0)
	assert_true(done, "the box opened, told its lines and closed")
	await wait_physics_frames(3)


## Looks at `prop` and takes `answers` in the real box, in order, as the groups come up, until the
## box is shut again; the lines in between are moved on with the confirm key. Returns what each
## group offered. Every answer has to be taken, and no group may come up that has no answer left.
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


## How many times the box opens in this scene from now on (once for every conversation).
func _count_openings(scene: GameScene) -> Array[int]:
	var count: Array[int] = [0]
	scene.dialogue_box.opened.connect(func() -> void: count[0] += 1)
	return count


## Every sound that is written out from now on: [key, where] (null where = from nowhere).
func _listen() -> Array:
	Settings.set_value("access.captions", true, false)
	var heard: Array = []
	_listener = func(key: String, at: Variant) -> void: heard.append([key, at])
	AudioDirector.caption_requested.connect(_listener)
	return heard


func _hums(heard: Array) -> int:
	return heard.filter(func(entry: Array) -> bool: return entry[0] == "CAPTION_HUM").size()


## Starts the hero's walk and takes it up to `stage` (the stage "leave" is the start).
func _walk_to(stage: String) -> void:
	WorldState.start_quest(QUEST)
	for step in WAY.size():
		if WAY[step] == stage:
			return
		assert_true(WorldState.advance_quest(QUEST, WAY[step + 1]), "to " + WAY[step + 1])


## The walk as it stands: stage, history and goals done.
func _walk_now() -> Array:
	var progress: GameState.QuestProgress = WorldState.state.quests.get(QUEST)
	if progress == null:
		return []
	return [progress.stage, progress.history.duplicate(), progress.objectives_done.duplicate()]


## The flags that are set now and were not in `before`, sorted.
func _added(before: Dictionary) -> Array[String]:
	var added: Array[String] = []
	for flag: String in WorldState.state.flags:
		if not before.has(flag):
			added.append(flag)
	added.sort()
	return added


## The source of a script without its comments.
func _code(path: String) -> String:
	var code: PackedStringArray = []
	for raw in FileAccess.get_file_as_string(path).split("\n"):
		if not raw.strip_edges().begins_with("#"):
			code.append(raw)
	return "\n".join(code)


# --- The place -------------------------------------------------------------------------


func test_it_is_a_small_map_in_the_night_without_rain_fog_music_or_light() -> void:
	var scene := await _scene()
	assert_true(SceneRegistry.has("nachtwald"))
	assert_lte(scene.map.data.width, 48, "class S, ADR-068")
	assert_lte(scene.map.data.height, 36)
	assert_true(Beat.reached("nachtwald_enter"))
	assert_eq(scene.map.data.meta["style"], "tal", "no style of its own to bake")
	assert_eq(scene.view.zoom, 1.25, "the zoom of the forest (ADR-045)")
	assert_eq(scene.world_tint, NIGHT_PALETTE, "the palette of the prototype look_wald")
	assert_eq(scene.weather, LookScene.Weather.CLEAR, "no rain")
	assert_null(scene.view.viewport.get_node_or_null("WeatherLayer"), "and no rain node")
	assert_eq(scene.fog_banks, 0, "no fog")
	assert_null(scene.view.world_root.get_node_or_null("Fog"))
	assert_false(scene.wind_leaves, "no wind in the leaves")
	assert_false(scene.fireflies)
	assert_eq(scene.bird_interval, 0.0, "nothing flies")
	assert_eq(scene.music, "silence", "the hum is the only sound there is")
	assert_null(scene.ambience, "and nothing else sounds")
	assert_eq(scene.find_children("*", "Light2D", true, false).size(), 0, "no light, Plan 7")
	assert_false(scene.reflect_player, "no puddles to show her in")
	assert_not_null(scene.player)


func test_the_night_is_this_scenes_own_look_and_leaves_the_time_of_day_alone() -> void:
	var scene := await _scene()
	assert_null(scene.day_light, "no DayLight: it would write the night into the stored time")
	assert_eq(scene.day_preset, "keine")
	assert_eq(WorldState.day_preset(), "morgen", "what the valley shows after it is not changed")
	assert_true(scene.view.world_root.get_node("WorldTint") is CanvasModulate)
	var tint := scene.view.world_root.get_node("WorldTint") as CanvasModulate
	assert_eq(tint.color, NIGHT_PALETTE)
	await _sit(scene)
	await _read_through(scene)
	assert_eq(WorldState.day_preset(), "morgen", "nor does the waiting")


func test_there_is_no_one_in_the_wood_but_her() -> void:
	var scene := await _scene()
	var figures := scene.map.entities.get_children().filter(
		func(node: Node) -> bool:
			return (
				node is CharacterBody2D
				and node != scene.player
				and not node.is_queued_for_deletion()
			)
	)
	assert_eq(figures.size(), 0, "no figure on the map, no child in the picture")
	assert_eq(_alive(scene, "Npc").size(), 0)


func test_a_new_game_starts_on_the_path_one_cell_below_the_arrival() -> void:
	var scene := await _scene()
	assert_eq(scene.map.data.find_marker("player_spawn")[0]["cell"], START_CELL)
	assert_eq(_cell_of(scene, scene.player), START_CELL)
	assert_eq(START_CELL.y - ARRIVAL_CELL.y, 1)


# --- The doors -------------------------------------------------------------------------


func test_the_arrival_from_the_clearing_is_outside_the_doors_zone_and_the_door_leads_back() -> void:
	SceneTravel.stay = true
	SceneTravel.pending_spawn = "flutlichtung"
	var scene := await _scene()
	assert_eq(scene.map.data.find_marker("spawn_flutlichtung")[0]["cell"], ARRIVAL_CELL)
	assert_eq(_cell_of(scene, scene.player), ARRIVAL_CELL, "she arrives where the marker is")
	var doors := _doors(scene, "flutlichtung")
	assert_eq(doors.size(), 1, "one door, and it goes back to the clearing")
	assert_eq(doors[0].get(&"spawn"), "nachtwald", "to the place the clearing made for it")
	assert_true(doors[0].get(&"auto"), "the path itself leads through it")
	assert_eq(_cell_of(scene, doors[0]), NORTH_DOOR_CELL)
	assert_gte(ARRIVAL_CELL.y - NORTH_DOOR_CELL.y, 4, "an arrival outside the door's zone")
	assert_true(SceneRegistry.has("flutlichtung"), "the door has somewhere to go")
	await wait_physics_frames(10)
	assert_eq(SceneTravel.last_target, "", "no way back in at once")


func test_walking_north_from_the_arrival_reaches_the_door_to_the_clearing() -> void:
	SceneTravel.stay = true
	SceneTravel.pending_spawn = "flutlichtung"
	await _scene()
	assert_eq(SceneTravel.last_target, "", "nothing has travelled yet")
	var gone := func() -> bool: return SceneTravel.last_target == "flutlichtung"
	assert_true(await _hold(&"move_up", gone, 240), "north from the arrival reaches the door")


func test_the_clearing_has_the_counterpart_of_the_north_door() -> void:
	SceneTravel.stay = true
	SceneTravel.pending_spawn = "nachtwald"
	_walk_to("night")
	var scene: GameScene = FLUT.instantiate()
	add_child_autofree(scene)
	await wait_physics_frames(3)
	var doors := _doors(scene, "nachtwald")
	assert_eq(doors.size(), 1, "one door, and it goes on into the night wood")
	assert_eq(doors[0].get(&"spawn"), "flutlichtung", "to the place this map made for it")
	assert_false(scene.map.data.find_marker("spawn_nachtwald").is_empty())
	assert_eq(
		_cell_of(scene, scene.player), scene.map.data.find_marker("spawn_nachtwald")[0]["cell"]
	)


func test_the_door_to_the_valley_goes_to_the_marker_at_the_brook_and_is_never_locked() -> void:
	var scene := await _scene()
	var doors := _doors(scene, "tal")
	assert_eq(doors.size(), 1, "one door home")
	assert_eq(doors[0].get(&"spawn"), "bach", "to the marker the valley made for the brook")
	assert_true(doors[0].get(&"auto"), "the path itself leads through it")
	assert_eq(_cell_of(scene, doors[0]), SOUTH_DOOR_CELL)
	assert_eq(doors[0].get_script(), DOOR_SCRIPT)
	assert_true(SceneRegistry.has("tal"))
	for node in scene.map.entities.get_children():
		var script: Script = node.get_script()
		assert_false(script != null and "blocker" in script.resource_path, "nothing holds her")
	assert_false(scene.dialogue_box.is_open(), "no one speaks to her before she goes")
	assert_false(scene.player.is_locked())


func test_walking_south_from_the_last_stretch_reaches_the_door_to_the_valley() -> void:
	SceneTravel.stay = true
	var scene := await _scene()
	await _go_to(scene, HOME_WAY_CELL)
	assert_eq(SceneTravel.last_target, "", "nothing has travelled yet")
	var gone := func() -> bool: return SceneTravel.last_target == "tal"
	assert_true(await _hold(&"move_down", gone, 360), "south from the last stretch reaches it")
	assert_gte(SOUTH_DOOR_CELL.y - HOME_WAY_CELL.y, 4, "the stretch lies outside the zone")


func test_the_valley_has_the_marker_and_she_arrives_there_outside_the_doors_zone() -> void:
	SceneTravel.stay = true
	SceneTravel.pending_spawn = "bach"
	WorldState.set_flag("house.mira_visited")  # the door below the marker is open then
	var scene: GameScene = TAL.instantiate()
	add_child_autofree(scene)
	await wait_physics_frames(3)
	assert_eq(scene.map.data.find_marker("spawn_bach")[0]["cell"], TAL_ARRIVAL_CELL)
	assert_eq(_cell_of(scene, scene.player), TAL_ARRIVAL_CELL, "she arrives at the brook")
	var doors := _doors(scene, "bachlauf")
	assert_eq(doors.size(), 1)
	assert_eq(_cell_of(scene, doors[0]), TAL_DOOR_CELL)
	assert_gte(TAL_DOOR_CELL.y - TAL_ARRIVAL_CELL.y, 4, "outside the zone of the door below")
	await wait_physics_frames(10)
	assert_eq(SceneTravel.last_target, "", "and nothing throws her back in")


# --- The lantern -----------------------------------------------------------------------


func test_a_lantern_stands_in_the_middle_of_the_glade_with_a_flame_that_does_not_move() -> void:
	var scene := await _scene()
	var lantern := _lantern(scene)
	assert_eq(_cell_of(scene, lantern), LANTERN_CELL)
	assert_not_null(lantern.get_node_or_null("Emissive"), "it burns in its picture")
	assert_false(lantern.is_processing(), "nothing in it is animated")
	assert_true(lantern.get_script().resource_path.ends_with("decor.gd"), "a plain prop, no script")
	var entry := PropCatalog.entry("tal/wd_lantern")
	for key: String in MOVING_KEYS:
		assert_false(entry.has(key), "the lantern's catalog entry has no '%s'" % key)
	var pool := _decor_with(scene, "tal/wd_lantern_pool")
	assert_eq(pool.size(), 1, "one circle of light on the ground")
	assert_eq(_cell_of(scene, pool[0]), POOL_CELL)
	assert_lt(pool[0].z_index, scene.player.z_index, "it lies under whoever sits beside it")


func test_walking_up_to_the_lantern_finds_it_where_it_stood_and_costs_nothing() -> void:
	var heard := _listen()
	var scene := await _scene()
	var lantern := _lantern(scene)
	var spot := lantern.global_position
	var flags := WorldState.state.flags.duplicate()
	var items := WorldState.state.inventory.duplicate()
	var opened := _count_openings(scene)
	await _go_to(scene, LANTERN_CELL + Vector2i(4, 0))
	var seen := [999.0, 0.0]
	var track := func() -> bool:
		seen[0] = minf(seen[0], scene.player.global_position.distance_to(spot))
		seen[1] = maxf(seen[1], lantern.global_position.distance_to(spot))
		return false
	await _hold(&"move_left", track, 150)
	assert_lt(seen[0] as float, 12.0, "she walked right up to it")
	assert_eq(seen[1], 0.0, "and it did not step back, not by a pixel")
	await wait_physics_frames(120)
	assert_eq(lantern.global_position, spot, "and it leads nowhere")
	assert_ne(scene.player.state, Player.State.SIT, "walking up to it does not sit her down")
	assert_eq(opened[0], 0, "no one speaks")
	assert_eq(WorldState.state.flags, flags, "nothing is set")
	assert_eq(WorldState.state.inventory, items, "nothing is given")
	assert_eq(heard.size(), 0, "and nothing sounds")
	assert_push_error_count(0)


func test_the_lantern_is_found_in_the_same_place_in_every_scene_that_is_built() -> void:
	var spots: Array[Vector2] = []
	for _attempt in 3:
		var scene := await _scene()
		spots.append(_lantern(scene).global_position)
		await _sit(scene)
		await _read_through(scene)
		scene.queue_free()
		await wait_physics_frames(2)
	assert_eq(spots[1], spots[0], "after a sitting it is where it was")
	assert_eq(spots[2], spots[0])
	assert_eq(spots[0], _cell_center(LANTERN_CELL))


func _cell_center(cell: Vector2i) -> Vector2:
	return Vector2(cell) * 16.0 + Vector2(8, 8)


# --- Sitting beside it -----------------------------------------------------------------


func test_the_first_sitting_tells_the_silence_hums_once_and_marks_the_wait() -> void:
	var heard := _listen()
	var scene := await _scene()
	var opened := _count_openings(scene)
	var flags := WorldState.state.flags.duplicate()
	var items := WorldState.state.inventory.duplicate()
	var counts := [Collection.fragments(), Collection.melodies(), Collection.curiosities()]
	assert_false(WorldState.has_flag("forest.waited"))
	assert_false(Beat.reached("act3_waiting"))
	await _sit(scene)
	assert_eq(scene.player.state, Player.State.SIT, "she sits down beside it")
	assert_eq(scene.player.facing, Facing.Dir.W, "looking at it")
	await _read_through(scene)
	assert_eq(opened[0], 1, "one conversation for the sitting")
	assert_true(WorldState.has_flag("forest.waited"))
	assert_true(Beat.reached("act3_waiting"))
	assert_eq(_added(flags), ["beat.act3_waiting", "forest.waited"], "and nothing else is set")
	assert_eq(_hums(heard), 1, "the hum is heard once")
	assert_eq(heard.size(), 1, "and it is the only sound that is written out")
	assert_eq(heard[0][0], AudioDirector.CAPTIONS["child_hum"])
	assert_null(heard[0][1], "from no direction")
	assert_eq(WorldState.state.inventory, items, "nothing is given")
	assert_eq(Collection.fragments(), counts[0], "no fragment")
	assert_eq(Collection.melodies(), counts[1], "and no melody: the hum is a sound")
	assert_eq(Collection.curiosities(), counts[2])
	var seat := _lantern(scene).global_position + SEAT_OFFSET
	assert_almost_eq(scene.player.global_position, seat, Vector2.ONE, "on its east side")
	assert_eq(scene.player.state, Player.State.SIT, "she sits on, free to stand up")
	assert_push_error_count(0)


func test_every_later_sitting_asks_again_in_one_calm_line_and_the_hum_does_not_come_back() -> void:
	var heard := _listen()
	var scene := await _scene()
	var opened := _count_openings(scene)
	await _sit(scene)
	await _read_through(scene)
	var flags := WorldState.state.flags.duplicate()
	for visit in 3:
		scene.player.stand_up()
		await wait_physics_frames(3)
		assert_ne(scene.player.state, Player.State.SIT, "she stood up")
		await _sit(scene)
		await _read_through(scene)
		assert_eq(opened[0], visit + 2, "one conversation for each sitting")
	assert_eq(_hums(heard), 1, "the hum was heard once, at the first sitting")
	assert_eq(heard.size(), 1)
	assert_eq(WorldState.state.flags, flags, "and nothing is set again")


func test_a_game_that_has_waited_before_sits_down_without_a_sound() -> void:
	WorldState.set_flag("forest.waited")
	var heard := _listen()
	var scene := await _scene()
	var opened := _count_openings(scene)
	var flags := WorldState.state.flags.duplicate()
	await _sit(scene)
	await _read_through(scene)
	assert_eq(opened[0], 1)
	assert_eq(heard.size(), 0, "no hum: the flag was there when she sat")
	assert_eq(WorldState.state.flags, flags, "and no beat is marked a second time")


func test_the_hum_comes_with_the_flag_and_nothing_else_makes_it() -> void:
	var heard := _listen()
	var scene := await _scene()
	WorldState.set_flag("forest.foxfire_taken")
	WorldState.set_flag("forest.flood_seen")
	await wait_physics_frames(3)
	assert_eq(heard.size(), 0, "other flags are no reason for a sound")
	assert_false(Beat.reached("act3_waiting"))
	WorldState.set_flag("forest.waited")
	await wait_physics_frames(3)
	assert_eq(_hums(heard), 1, "the flag is: one hum")
	assert_true(Beat.reached("act3_waiting"))
	WorldState.set_flag("forest.waited")
	await wait_physics_frames(3)
	assert_eq(_hums(heard), 1, "and setting it again is no change")
	assert_not_null(scene)


func test_the_sound_of_the_hum_is_in_the_game_and_has_its_text() -> void:
	assert_true(AudioDirector.CAPTIONS.has("child_hum"), "written out for whoever cannot hear")
	assert_eq(AudioDirector.CAPTIONS["child_hum"], "CAPTION_HUM")
	assert_not_null(SoundBank.stream("child_hum", 1.0, 0.0), "and there is a sound to play")


func test_she_can_get_up_at_any_moment_even_in_the_middle_of_the_lines() -> void:
	var scene := await _scene()
	var opened := _count_openings(scene)
	await _sit(scene)
	var up: bool = await wait_until(func() -> bool: return scene.dialogue_box.is_open(), 10.0)
	assert_true(up, "the lines are up")
	scene.player.stand_up()
	await wait_physics_frames(3)
	assert_ne(scene.player.state, Player.State.SIT, "she is up, whatever the box shows")
	await _read_through(scene)
	assert_false(scene.player.is_locked(), "and nothing holds her once it is over")
	assert_true(SaveSystem.blockers().is_empty(), "nothing holds the game from saving")
	await _sit(scene)
	await _read_through(scene)
	assert_eq(opened[0], 2, "the next sitting asks again")
	assert_push_error_count(0)


func test_walking_away_from_the_lantern_gets_her_up_and_nothing_is_lost() -> void:
	var scene := await _scene()
	await _sit(scene)
	await _read_through(scene)
	assert_eq(scene.player.state, Player.State.SIT)
	assert_false(scene.player.is_locked(), "she is free while she sits")
	assert_true(SaveSystem.blockers().is_empty(), "and the game can save")
	var flags := WorldState.state.flags.duplicate()
	Input.action_press(&"move_down")
	var stood: bool = await wait_until(
		func() -> bool: return scene.player.state != Player.State.SIT, 5.0
	)
	Input.action_release(&"move_down")
	assert_true(stood, "a step is enough")
	assert_eq(WorldState.state.flags, flags, "nothing is taken back and nothing is lost")


func test_waiting_is_the_sitting_and_no_clock_runs_in_it() -> void:
	var scene := await _scene()
	var opened := _count_openings(scene)
	await _sit(scene)
	var up: bool = await wait_until(func() -> bool: return scene.dialogue_box.is_open(), 10.0)
	assert_true(up, "the first line is up")
	await wait_seconds(10.0)
	assert_true(scene.dialogue_box.is_open(), "and it waits as long as she does")
	assert_false(WorldState.has_flag("forest.waited"), "ten seconds change nothing")
	await _read_through(scene)
	var flags := WorldState.state.flags.duplicate()
	await wait_seconds(10.0)
	assert_eq(scene.player.state, Player.State.SIT, "she sits on")
	assert_false(scene.dialogue_box.is_open(), "no one speaks to her again")
	assert_eq(opened[0], 1, "however long she sits, it is one conversation")
	assert_eq(WorldState.state.flags, flags, "and sitting longer sets nothing")


func test_whoever_does_not_sit_loses_nothing_and_nothing_waits_for_them() -> void:
	var scene := await _scene()
	var flags := WorldState.state.flags.duplicate()
	await _go_to(scene, HOME_WAY_CELL)
	await wait_seconds(10.0)
	assert_eq(WorldState.state.flags, flags, "the night goes on without her and takes nothing")
	assert_false(WorldState.has_flag("forest.waited"))
	assert_false(Beat.reached("act3_waiting"))
	assert_false(scene.dialogue_box.is_open())
	assert_false(scene.player.is_locked())


func test_nothing_in_the_scene_script_is_timed_held_or_moved() -> void:
	var code := _code(SCENE_SOURCE)
	assert_gt(code.length(), 200, "the script was read")
	for word: String in FORBIDDEN_IN_THE_SCENE:
		assert_false(code.contains(word), "'%s' in nachtwald_scene.gd" % word)
	assert_false(code.to_lower().contains("lantern"), "the script knows nothing of the lantern")
	var file := FileAccess.get_file_as_string(SCENE_FILE)
	assert_false(file.contains("PointLight2D"), "no light in the scene file")
	assert_false(file.contains("Light2D"))
	assert_false(file.contains("RainFx"))
	assert_false(file.contains("day_preset"), "the night is the palette, not the clock")


# --- The glowing log -------------------------------------------------------------------


func test_a_piece_of_the_glowing_log_can_be_taken_and_the_log_lies_there_dark_after() -> void:
	var scene := await _scene()
	var log := _first(scene, "foxfire")
	assert_not_null(log)
	assert_eq(_cell_of(scene, log), LOG_CELL)
	assert_eq(_decor_with(scene, BRIGHT_LOG).size(), 1, "it glows")
	assert_eq(_decor_with(scene, DIM_LOG).size(), 0)
	var flags := WorldState.state.flags.duplicate()
	var take := PackedStringArray([LineText.of("nw_fox_r1")])
	var offered := await _talk_through(scene, log, take)
	assert_eq(
		offered[0],
		PackedStringArray(
			[LineText.of("nw_fox_r1"), LineText.of("nw_fox_r2"), LineText.of("nw_fox_r3")]
		),
		"three answers, the silence last"
	)
	assert_true(WorldState.has_flag("forest.foxfire_taken"))
	assert_eq(WorldState.state.inventory.get("curiosity_foxfire", 0), 1, "one piece in her pocket")
	assert_eq(_added(flags), ["forest.foxfire_taken"], "and nothing else is set")
	var dark: bool = await wait_until(
		func() -> bool: return _decor_with(scene, BRIGHT_LOG).is_empty(), 5.0
	)
	assert_true(dark, "the glowing log is gone from the map")
	assert_eq(_decor_with(scene, DIM_LOG).size(), 1, "and the dark one lies in its place")
	assert_eq(_cell_of(scene, _decor_with(scene, DIM_LOG)[0]), LOG_CELL)
	scene.queue_free()
	await wait_physics_frames(2)
	var again := await _scene()
	assert_eq(_decor_with(again, BRIGHT_LOG).size(), 0, "in a scene that is built again as well")
	assert_eq(_decor_with(again, DIM_LOG).size(), 1)


func test_looking_at_the_dark_log_again_gives_nothing_a_second_time() -> void:
	var scene := await _scene()
	await _talk_through(
		scene, _first(scene, "foxfire"), PackedStringArray([LineText.of("nw_fox_r1")])
	)
	var dark: bool = await wait_until(
		func() -> bool: return _decor_with(scene, BRIGHT_LOG).is_empty(), 5.0
	)
	assert_true(dark)
	var flags := WorldState.state.flags.duplicate()
	var opened := _count_openings(scene)
	await _talk_through(scene, _first(scene, "foxfire"), PackedStringArray())
	assert_eq(opened[0], 1, "it is read")
	assert_eq(WorldState.state.inventory.get("curiosity_foxfire", 0), 1, "still the one piece")
	assert_eq(WorldState.state.flags, flags)
	assert_eq(Collection.curiosities(), 1)


func test_leaving_the_log_or_keeping_silent_takes_nothing_and_leaves_it_glowing() -> void:
	for answer: String in ["nw_fox_r2", "nw_fox_r3"]:
		var scene := await _scene()
		var flags := WorldState.state.flags.duplicate()
		var items := WorldState.state.inventory.duplicate()
		await _talk_through(
			scene, _first(scene, "foxfire"), PackedStringArray([LineText.of(answer)])
		)
		assert_eq(WorldState.state.flags, flags, "%s: nothing is set" % answer)
		assert_eq(WorldState.state.inventory, items, "%s: nothing is taken" % answer)
		assert_eq(_decor_with(scene, BRIGHT_LOG).size(), 1, "%s: it glows on" % answer)
		assert_eq(_decor_with(scene, DIM_LOG).size(), 0)
		scene.queue_free()
		await wait_physics_frames(2)


func test_the_trees_the_far_light_and_the_last_stretch_are_only_looked_at() -> void:
	var scene := await _scene()
	var flags := WorldState.state.flags.duplicate()
	var items := WorldState.state.inventory.duplicate()
	var opened := _count_openings(scene)
	for cue: String in ["glow_tree", "lantern_far", "home_way"]:
		var prop := _first(scene, cue)
		assert_not_null(prop, cue)
		await _talk_through(scene, prop, PackedStringArray())
	assert_eq(opened[0], 3, "each is read once")
	assert_eq(WorldState.state.flags, flags, "and sets nothing")
	assert_eq(WorldState.state.inventory, items)


# --- What the map names ----------------------------------------------------------------


func test_every_thing_with_a_cue_has_its_cue_in_the_dialogue_and_stands_once() -> void:
	var scene := await _scene()
	var cues := (load(DIALOGUE) as DialogueResource).get_cues()
	var seen: Dictionary[String, int] = {}
	for placement: Dictionary in scene.map.data.placements:
		var params: Dictionary = placement["params"]
		if not params.has("cue"):
			continue
		var cue := str(params["cue"])
		assert_true(cue in cues, "cue '%s' is in the file" % cue)
		assert_eq(params.get("dialogue"), DIALOGUE, "'%s' reads this file" % cue)
		seen[cue] = seen.get(cue, 0) + 1
	for cue: String in SPOTS:
		assert_eq(seen.get(cue, 0), 1, "'%s' stands once" % cue)
	assert_eq(seen.size(), SPOTS.size(), "and nothing else on the map speaks")


func test_every_sprite_of_the_map_is_in_the_catalog_and_every_prop_exists() -> void:
	var scene := await _scene()
	var sprites: Dictionary[String, bool] = {}
	for placement: Dictionary in scene.map.data.placements:
		assert_true(ResourceLoader.exists(placement["prop"]) or placement["prop"] == "", "prop")
		var params: Dictionary = placement["params"]
		if params.has("sprite"):
			sprites[params["sprite"]] = true
		for sprite: String in (params.get("sprite_when", {}) as Dictionary).values():
			sprites[sprite] = true
	for rule: Dictionary in scene.map.data.meta["scatter"]:
		sprites[rule["sprite"]] = true
	for named: String in [
		"tal/wd_lantern", "tal/wd_lantern_pool", BRIGHT_LOG, DIM_LOG, "tal/wd_glow_tree"
	]:
		assert_true(sprites.has(named), "the map names '%s'" % named)
	assert_gte(sprites.size(), 12)
	for sprite: String in sprites:
		assert_true(PropCatalog.has(sprite), "sprite '%s' is in the catalog" % sprite)
	for key: String in ["ground", "water"]:
		assert_true(ResourceLoader.exists(scene.map.data.meta[key]), "the baked " + key)


func test_the_things_that_glow_are_baked_into_their_pictures_and_do_not_flicker() -> void:
	for sprite: String in ["tal/wd_glow_tree", "tal/wd_lantern", "tal/wd_lantern_pool", BRIGHT_LOG]:
		var entry := PropCatalog.entry(sprite)
		assert_true(entry.has("emissive"), "'%s' glows in its picture" % sprite)
		assert_false(entry.has("lights"), "'%s' casts no light (Plan 7)" % sprite)
		assert_false(entry.get("flicker", false), "'%s' does not flicker (Bible 50)" % sprite)
		assert_false(entry.has("glow"), "'%s' has no pulsing halo" % sprite)
	assert_false(PropCatalog.entry(DIM_LOG).has("emissive"), "the dark log does not glow")


# --- The walk through the wood ---------------------------------------------------------------


func test_the_night_is_the_end_of_the_walk_and_the_night_wood_adds_no_stage_or_goal() -> void:
	_walk_to("night")
	var before := _walk_now()
	assert_true(WorldState.is_quest_done(QUEST))
	var scene := await _scene()
	await _sit(scene)
	await _read_through(scene)
	scene.player.stand_up()
	await wait_physics_frames(3)
	await _talk_through(
		scene, _first(scene, "foxfire"), PackedStringArray([LineText.of("nw_fox_r1")])
	)
	assert_eq(_walk_now(), before, "stage, history and goals as they were")
	assert_eq(WorldState.quest_stage(QUEST), "night")
	assert_eq(WorldState.quest_outcome(QUEST), "done")
	var def := ContentDB.quest(QUEST)
	assert_eq(def.stages.size(), WAY.size(), "no stage for what comes after")
	assert_true(def.stage("night").is_final(), "the night is the end")
	assert_eq(def.stage("night").objectives.size(), 0, "and has no goal")


func test_a_game_without_the_walk_gets_no_quest_and_no_error_from_the_night_wood() -> void:
	var scene := await _scene()
	await _sit(scene)
	await _read_through(scene)
	assert_false(WorldState.is_quest_started(QUEST))
	assert_eq(WorldState.quest_stage(QUEST), "")
	assert_false(WorldState.has_flag("forest.night_way"), "the night wood opens no way")
	assert_push_error_count(0)
