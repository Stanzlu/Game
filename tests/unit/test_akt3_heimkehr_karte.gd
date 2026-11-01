# gdlint: ignore=max-public-methods
extends GutTest
## Act III, W6, the map of the house (content/maps/haus.txt): once the walk is over and the
## workbench stands in the corner (house.workbench), the Antreiber sits at it in every state he can
## have come home in (the places of the fire, a, z and k, are empty then), the cat lies on his lap
## when she is fed (and sits in the window when she is not), the plan hangs in the wall between
## the shelf and the window, and the chair of a guest stands under whoever sat in it
## (house.guest_hermit). Everything on the map reads flags; nothing here walks the story. Every
## cell where a player stands to look at one of them can be reached on foot from the door, round
## the shapes of the furniture, and looks at the right thing from there.

const HAUS := preload("res://world/levels/slice/haus.tscn")
const TAL := preload("res://world/levels/slice/tal.tscn")
const HEIMKEHR := "res://content/dialogue/akt3/heimkehr.dialogue"
const ARRIVAL := Vector2i(19, 14)
const BENCH_CELL := Vector2i(24, 14)
const HIM_CELL := Vector2i(22, 14)
const CAT_CELL := Vector2i(22, 15)
const CHAIR_CELL := Vector2i(22, 12)
const PLAN_CELL := Vector2i(21, 8)
## The valley: the piece of fence he mends (B) and the gap the goat uses (I).
const FENCE_CELL := Vector2i(31, 16)
const GAP_CELL := Vector2i(21, 16)
## The room, the part of it the grid of the flood fill covers (px).
const ROOM := Rect2(192.0, 80.0, 256.0, 192.0)
const GRID := 2.0
## A cold house has a cat's place at the window too; "the fire" here means the state after Act II.
const AFTER_THE_FIRE: Array[String] = ["house.fire_lit", "house.mira_visited"]


func before_each() -> void:
	WorldState.new_game()
	WorldState.set_ui_mode(GameState.UiMode.REAL)
	WorldState.set_day_preset("morgen")


func after_each() -> void:
	for action: StringName in [&"move_up", &"move_down", &"move_left", &"move_right"]:
		Input.action_release(action)
	SceneTravel.pending_spawn = ""
	SceneTravel.arrival_fade = -1.0
	SceneTravel.stay = false
	SceneTravel.last_target = ""
	WorldState.new_game()
	ScreenFade.fade_in(0.0)
	get_tree().paused = false


## The house with these flags set first (the map reads them while it is built), the way the door
## brings the player in, and a Mira who does not come (the fire burns and she has been).
func _scene(flags: Array[String]) -> HausScene:
	for flag: String in AFTER_THE_FIRE:
		WorldState.set_flag(flag)
	for flag: String in flags:
		WorldState.set_flag(flag)
	SceneTravel.pending_spawn = "door"
	var scene: HausScene = HAUS.instantiate()
	scene.mira_after = 120.0
	add_child_autofree(scene)
	await wait_physics_frames(3)
	return scene


func _gone(scene: Node) -> void:
	scene.queue_free()
	await wait_physics_frames(2)


func _decor(scene: GameScene, sprite: String) -> Array[Node]:
	return scene.map.entities.get_children().filter(
		func(node: Node) -> bool:
			return (
				node is Decor
				and not node.is_queued_for_deletion()
				and (node as Decor).sprite_id == sprite
			)
	)


func _walkers(scene: GameScene, cue := "") -> Array[Node]:
	return scene.map.entities.get_children().filter(
		func(node: Node) -> bool:
			return (
				node is NpcWalker
				and not node.is_queued_for_deletion()
				and (cue.is_empty() or (node as NpcWalker).cue == cue)
			)
	)


func _cell(scene: GameScene, node: Node) -> Vector2i:
	return scene.map.world_to_cell((node as Node2D).global_position)


func _cue_of(node: Node) -> String:
	if node is NpcWalker:
		return (node as NpcWalker).cue
	return str(node.get_meta(&"cue", ""))


# --- What stands in the room ------------------------------------------------------------------


func test_the_room_before_the_homecoming_is_the_room_of_act_two() -> void:
	var scene := await _scene(["house.antreiber_by_fire", "house.cat_fed"])
	assert_eq(_walkers(scene).size(), 1, "one man in the room")
	assert_eq(_walkers(scene, "antreiber_rest").size(), 1, "by the fire")
	assert_eq(_decor(scene, "haus/cat_sleep").size(), 1, "the cat lies on him")
	for sprite: String in ["haus/workbench", "haus/plan_board", "haus/guest_chair"]:
		assert_eq(_decor(scene, sprite).size(), 0, "no %s yet" % sprite)


func test_the_workbench_the_plan_and_him_stand_where_the_map_puts_them() -> void:
	var scene := await _scene(["house.antreiber_by_fire", "house.cat_fed", "house.workbench"])
	var bench := _decor(scene, "haus/workbench")
	assert_eq(bench.size(), 1)
	assert_eq(_cell(scene, bench[0]), BENCH_CELL)
	assert_eq(_cue_of(bench[0]), "workbench")
	var plan := _decor(scene, "haus/plan_board")
	assert_eq(plan.size(), 1)
	assert_eq(_cell(scene, plan[0]), PLAN_CELL, "between the shelf and the window")
	assert_eq(_cue_of(plan[0]), "plan_board")
	var him := _walkers(scene, "antreiber_bench")
	assert_eq(him.size(), 1)
	assert_eq(_cell(scene, him[0]), HIM_CELL)
	assert_true((him[0] as NpcWalker).seated, "he sits at it")
	assert_eq(_decor(scene, "haus/guest_chair").size(), 0, "nobody has been to sit yet")


func test_he_is_at_the_bench_and_nowhere_else_in_every_state_he_can_have_come_home_in() -> void:
	var states: Array[Array] = [
		["house.antreiber_by_fire"],
		["house.antreiber_by_fire", "house.antreiber_refused"],
		["house.antreiber_left"],
		["house.antreiber_left", "house.antreiber_postponed"],
		["forest.antreiber_ahead"],
		["forest.antreiber_met", "forest.antreiber_sat"],
		[],
	]
	for fed: bool in [false, true]:
		for state: Array in states:
			WorldState.new_game()
			var flags: Array[String] = ["house.workbench"]
			for flag: String in state:
				flags.append(flag)
			if fed:
				flags.append("house.cat_fed")
			var scene := await _scene(flags)
			var label := "%s, fed %s" % [state, fed]
			assert_eq(_walkers(scene).size(), 1, "one man, and no one else (%s)" % label)
			assert_eq(_walkers(scene, "antreiber_bench").size(), 1, "at the bench (%s)" % label)
			assert_eq(_walkers(scene, "antreiber_rest").size(), 0, "not by the fire (%s)" % label)
			assert_eq(_decor(scene, "haus/cat_sleep").size(), 1 if fed else 0, label)
			assert_eq(_decor(scene, "haus/cat_window").size(), 0 if fed else 1, label)
			await _gone(scene)


func test_the_cat_lies_on_his_lap_one_cell_south_of_him_and_in_front_of_him() -> void:
	var scene := await _scene(["house.antreiber_by_fire", "house.cat_fed", "house.workbench"])
	var cats := _decor(scene, "haus/cat_sleep")
	var him := _walkers(scene, "antreiber_bench")
	assert_eq(cats.size(), 1, "one cat, not one at the fire and one on him")
	assert_eq(_cell(scene, cats[0]), CAT_CELL)
	assert_eq(_cue_of(cats[0]), "cat_bench", "she can be looked at, and given a name")
	assert_gt(
		(cats[0] as Node2D).global_position.y,
		(him[0] as Node2D).global_position.y,
		"sorted in front"
	)
	var sprite := (cats[0] as Decor).sprite
	assert_lt(sprite.offset.y, -20.0, "lifted: she lies on his lap, not on the floor")


func test_without_the_cat_fed_she_stays_at_the_window_and_does_not_lie_on_him() -> void:
	var scene := await _scene(["house.antreiber_by_fire", "house.workbench"])
	assert_eq(_decor(scene, "haus/cat_sleep").size(), 0)
	assert_eq(_decor(scene, "haus/cat_window").size(), 1, "she sits outside")
	assert_eq(_walkers(scene, "antreiber_bench").size(), 1, "and he sits at his bench alone")


func test_the_cat_that_slept_by_the_fire_alone_moves_to_him_too() -> void:
	# fed, and he was never at the fire (he went ahead): she slept on the floor by the hearth ("k")
	var scene := await _scene(["house.cat_fed"])
	assert_eq(_decor(scene, "haus/cat_sleep").size(), 1, "on the floor by the hearth")
	assert_eq(_cell(scene, _decor(scene, "haus/cat_sleep")[0]), Vector2i(19, 10))
	WorldState.set_flag("house.workbench")
	await wait_physics_frames(3)
	var cats := _decor(scene, "haus/cat_sleep")
	assert_eq(cats.size(), 1, "one cat")
	assert_eq(_cell(scene, cats[0]), CAT_CELL, "she lies on him now")


func test_the_chair_is_there_for_the_guest_only_and_lies_flat_under_him() -> void:
	var scene := await _scene(["house.workbench"])
	assert_eq(_decor(scene, "haus/guest_chair").size(), 0, "no chair before he came")
	WorldState.set_flag("house.guest_hermit")
	await wait_physics_frames(3)
	var chair := _decor(scene, "haus/guest_chair")
	assert_eq(chair.size(), 1)
	assert_eq(_cell(scene, chair[0]), CHAIR_CELL, "at the end of the table")
	assert_eq(chair[0].z_index, -5, "flat: whoever sits in it is drawn over it")
	assert_null(chair[0].get_node_or_null("Interactable"), "a chair, not something to read")


func test_the_chair_stays_for_the_rest_of_the_game_and_needs_no_bench() -> void:
	# the flag is the guest's: the map does not tie the chair to anything else
	var scene := await _scene(["house.guest_hermit"])
	assert_eq(_decor(scene, "haus/guest_chair").size(), 1)
	assert_eq(_decor(scene, "haus/workbench").size(), 0)


func test_the_room_changes_in_one_picture_when_the_flag_comes() -> void:
	var scene := await _scene(["house.antreiber_by_fire", "house.cat_fed"])
	assert_eq(_walkers(scene, "antreiber_rest").size(), 1)
	WorldState.set_flag("house.workbench")
	for _step in 4:
		await wait_physics_frames(1)
		assert_lte(_walkers(scene).size(), 2, "at most the moment of the swap")
	assert_eq(_walkers(scene).size(), 1, "one man")
	assert_eq(_walkers(scene, "antreiber_bench").size(), 1)
	assert_eq(_decor(scene, "haus/cat_sleep").size(), 1, "one cat")
	assert_eq(_decor(scene, "haus/workbench").size(), 1)


func test_the_workbench_has_a_shape_and_nothing_new_carries_a_baked_shadow() -> void:
	var catalog := PropCatalog.entry("haus/workbench")
	assert_true(catalog.has("shape"), "she does not walk through it")
	assert_false(catalog.get("flat", false), "it stands, it is not painted on the floor")
	for sprite: String in ["haus/workbench", "haus/guest_chair", "haus/plan_board"]:
		assert_false(
			PropCatalog.entry(sprite).has("shadow"), "%s: the baked floor keeps its stamp" % sprite
		)


# --- Where a player stands ---------------------------------------------------------------------


## A way to a cell of the floor and what to look at from there: the cell, the way she faces, the
## cue that must come up, the cells of the way to it from the door, one after the other.
func _spots() -> Array[Dictionary]:
	return [
		{
			"name": "the bench from the east",
			"stand": Vector2i(26, 14),
			"face": Facing.Dir.W,
			"cue": "workbench",
			"via": [Vector2i(19, 15), Vector2i(26, 15)],
		},
		{
			"name": "the bench from the south",
			"stand": Vector2i(24, 15),
			"face": Facing.Dir.N,
			"cue": "workbench",
			"via": [Vector2i(19, 15)],
		},
		{
			"name": "the bench from the north",
			"stand": Vector2i(24, 13),
			"face": Facing.Dir.S,
			"cue": "workbench",
			"via": [Vector2i(19, 13)],
		},
		{
			"name": "him from the west",
			"stand": Vector2i(21, 14),
			"face": Facing.Dir.E,
			"cue": "antreiber_bench",
			"via": [],
		},
		{
			"name": "him from the north",
			"stand": Vector2i(22, 13),
			"face": Facing.Dir.S,
			"cue": "antreiber_bench",
			"via": [Vector2i(18, 13)],
		},
		{
			"name": "the cat from the west",
			"stand": Vector2i(21, 15),
			"face": Facing.Dir.E,
			"cue": "cat_bench",
			"via": [Vector2i(19, 15)],
		},
		{
			"name": "the cat from the east",
			"stand": Vector2i(23, 15),
			"face": Facing.Dir.W,
			"cue": "cat_bench",
			"via": [Vector2i(19, 15)],
		},
		{
			"name": "the plan",
			"stand": Vector2i(21, 9),
			"face": Facing.Dir.N,
			"cue": "plan_board",
			"via": [Vector2i(18, 13), Vector2i(18, 9)],
		},
	]


## Whether the player's own shape (the one of the scene, with its offset) fits at `at` without
## touching a wall, a piece of furniture or a man.
func _fits(scene: GameScene, at: Vector2) -> bool:
	var body := scene.player.get_node("Collision") as CollisionShape2D
	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = body.shape
	query.transform = Transform2D(0.0, at + body.position)
	query.collision_mask = scene.player.collision_mask
	return scene.player.get_world_2d().direct_space_state.intersect_shape(query, 1).is_empty()


## Every point of the grid the player can stand on and get to from `from` in steps of the grid.
func _reachable(scene: GameScene, from: Vector2) -> Dictionary:
	var seen := {}
	var queue: Array[Vector2] = [from]
	seen[Vector2i((from / GRID).round())] = true
	var steps := [Vector2(GRID, 0.0), Vector2(-GRID, 0.0), Vector2(0.0, GRID), Vector2(0.0, -GRID)]
	var head := 0
	while head < queue.size():
		var here := queue[head]
		head += 1
		for step: Vector2 in steps:
			var next := here + step
			var key := Vector2i((next / GRID).round())
			if seen.has(key) or not ROOM.has_point(next) or not _fits(scene, next):
				continue
			seen[key] = true
			queue.append(next)
	return seen


func _reaches(seen: Dictionary, at: Vector2) -> bool:
	return seen.has(Vector2i((at / GRID).round()))


## Walks the real player to the middle of `cell`: the keys, the physics of the body, the furniture
## in the way. True when she stands within a few pixels of it in the end.
func _walk_to(scene: GameScene, cell: Vector2i) -> bool:
	var goal := scene.map.cell_to_world(cell)
	var frames := 0
	while frames < 600:
		var error := goal - scene.player.global_position
		if absf(error.x) < 1.0 and absf(error.y) < 1.0:
			break
		_press(&"move_right", &"move_left", error.x)
		_press(&"move_down", &"move_up", error.y)
		await wait_physics_frames(1)
		frames += 1
	for action: StringName in [&"move_up", &"move_down", &"move_left", &"move_right"]:
		Input.action_release(action)
	await wait_physics_frames(6)
	return scene.player.global_position.distance_to(goal) <= 4.0


func _press(plus: StringName, minus: StringName, error: float) -> void:
	for action: StringName in [plus, minus]:
		Input.action_release(action)
	if error > 1.0:
		Input.action_press(plus)
	elif error < -1.0:
		Input.action_press(minus)


func test_she_arrives_by_the_door_and_the_old_places_stay_free() -> void:
	var scene := await _scene(["house.antreiber_by_fire", "house.cat_fed", "house.workbench"])
	assert_eq(scene.map.world_to_cell(scene.player.global_position), ARRIVAL)
	var seen := _reachable(scene, scene.player.global_position)
	# the door and the way from it, and the cells the autopilot runs of Act II and the slice use (the
	# bucket's own cell, (14, 14), is not one to stand on: the autopilot only looks at it from there)
	for cell: Vector2i in [
		Vector2i(19, 15),
		Vector2i(19, 13),
		Vector2i(16, 10),
		Vector2i(17, 12),
		Vector2i(22, 11),
		Vector2i(25, 9),
		Vector2i(19, 9),
		Vector2i(20, 13),
		Vector2i(17, 10),
		Vector2i(12, 12),
	]:
		var spot := scene.map.cell_to_world(cell)
		if scene.map.data.is_solid(cell):
			continue  # a wall of the room (12, 12) is not a place to stand on
		assert_true(_reaches(seen, spot), "%s can be walked to" % cell)


func test_every_cell_to_look_at_the_new_things_from_can_be_reached_on_foot() -> void:
	var scene := await _scene(["house.antreiber_by_fire", "house.cat_fed", "house.workbench"])
	var seen := _reachable(scene, scene.player.global_position)
	assert_gt(seen.size(), 2000, "the flood fill covers the floor (it was read)")
	for spot: Dictionary in _spots():
		var stand: Vector2i = spot["stand"]
		assert_true(
			_reaches(seen, scene.map.cell_to_world(stand)),
			"%s: %s is reachable" % [spot["name"], stand]
		)


func test_the_cell_between_him_and_the_bench_is_shut_and_nobody_needs_it() -> void:
	# the end of the bench begins in the next cell, three pixels from him: a body is ten wide
	var scene := await _scene(["house.antreiber_by_fire", "house.cat_fed", "house.workbench"])
	var seen := _reachable(scene, scene.player.global_position)
	for cell: Vector2i in [Vector2i(23, 14), BENCH_CELL, Vector2i(25, 14)]:
		var spot := scene.map.cell_to_world(cell)
		assert_false(_fits(scene, spot), "%s is no place to stand: bench or him" % cell)
		assert_false(_reaches(seen, spot))
	for cell: Vector2i in [
		Vector2i(26, 14), Vector2i(24, 15), Vector2i(24, 13), Vector2i(21, 14), Vector2i(22, 13)
	]:
		assert_true(_fits(scene, scene.map.cell_to_world(cell)), "%s is free to stand on" % cell)


func test_the_player_walks_to_each_spot_and_looks_at_the_right_thing() -> void:
	var scene := await _scene(["house.antreiber_by_fire", "house.cat_fed", "house.workbench"])
	for spot: Dictionary in _spots():
		scene.player.teleport(scene.map.cell_to_world(ARRIVAL))
		await wait_physics_frames(2)
		var way: Array = spot["via"] + [spot["stand"]]
		for cell: Vector2i in way:
			assert_true(await _walk_to(scene, cell), "%s: she gets to %s" % [spot["name"], cell])
		scene.player.facing = spot["face"]
		await wait_physics_frames(3)
		var looked := scene.player.sensor.current
		assert_not_null(looked, "%s: there is something to look at" % spot["name"])
		if looked != null:
			assert_eq(
				_cue_of(looked.get_parent()), spot["cue"], "%s: the right thing" % spot["name"]
			)


func test_the_walk_is_not_blind_the_bench_and_he_stop_her() -> void:
	# the proof that the walks above mean something: the same walk into the bench or through him
	# does not get there
	var scene := await _scene(["house.antreiber_by_fire", "house.cat_fed", "house.workbench"])
	scene.player.teleport(scene.map.cell_to_world(Vector2i(21, 14)))
	await wait_physics_frames(2)
	assert_false(await _walk_to(scene, BENCH_CELL), "not through him and into the bench")
	assert_lt(scene.player.global_position.x, scene.map.cell_to_world(HIM_CELL).x, "stopped at him")
	scene.player.teleport(scene.map.cell_to_world(Vector2i(26, 14)))
	await wait_physics_frames(2)
	assert_false(await _walk_to(scene, BENCH_CELL), "nor from the other side")
	assert_gt(
		scene.player.global_position.x, scene.map.cell_to_world(BENCH_CELL).x, "stopped at it"
	)


func test_standing_in_the_cats_own_cell_looks_at_the_cat() -> void:
	var scene := await _scene(["house.antreiber_by_fire", "house.cat_fed", "house.workbench"])
	scene.player.teleport(scene.map.cell_to_world(CAT_CELL))
	scene.player.facing = Facing.Dir.N
	await wait_physics_frames(3)
	assert_not_null(scene.player.sensor.current)
	assert_eq(_cue_of(scene.player.sensor.current.get_parent()), "cat_bench")


func test_without_the_cat_the_cell_south_of_him_looks_at_him() -> void:
	var scene := await _scene(["house.antreiber_by_fire", "house.workbench"])
	scene.player.teleport(scene.map.cell_to_world(CAT_CELL))
	scene.player.facing = Facing.Dir.N
	await wait_physics_frames(3)
	assert_not_null(scene.player.sensor.current)
	assert_eq(_cue_of(scene.player.sensor.current.get_parent()), "antreiber_bench")


func test_the_cues_of_the_map_exist_in_the_dialogue_of_the_segment() -> void:
	var resource := load(HEIMKEHR) as DialogueResource
	assert_not_null(resource)
	for cue: String in ["workbench", "plan_board", "antreiber_bench", "cat_bench"]:
		assert_true(cue in resource.get_cues(), "cue '%s' of the map" % cue)


# --- The fence in the valley ------------------------------------------------------------------


func _fence_at(scene: GameScene, cell: Vector2i) -> Decor:
	var spot := scene.map.cell_to_world(cell)
	for node in scene.map.entities.get_children():
		if (
			node is Decor
			and not node.is_queued_for_deletion()
			and node.global_position.distance_to(spot) < 2.0
		):
			return node
	return null


func test_the_piece_of_fence_by_the_house_is_mended_when_he_sits_at_the_bench() -> void:
	var scene: GameScene = TAL.instantiate()
	add_child_autofree(scene)
	await wait_physics_frames(3)
	assert_eq(_fence_at(scene, FENCE_CELL).sprite_id, "tal/fence_broken", "broken before")
	assert_eq(_fence_at(scene, GAP_CELL).sprite_id, "tal/fence_broken", "the goat's gap")
	WorldState.set_flag("house.workbench")
	await wait_physics_frames(3)
	assert_eq(_fence_at(scene, FENCE_CELL).sprite_id, "tal/fence", "mended: he fixed it")
	assert_eq(_fence_at(scene, GAP_CELL).sprite_id, "tal/fence_broken", "the gap stays a gap")
	assert_eq(_cue_of(_fence_at(scene, GAP_CELL)), "fence_gap", "and can still be looked at")
	assert_false(_fence_at(scene, FENCE_CELL).has_meta(&"cue"), "the mended piece says nothing")


func test_a_valley_that_is_loaded_with_the_flag_shows_the_mended_fence_at_once() -> void:
	WorldState.set_flag("house.workbench")
	var scene: GameScene = TAL.instantiate()
	add_child_autofree(scene)
	await wait_physics_frames(3)
	assert_eq(_fence_at(scene, FENCE_CELL).sprite_id, "tal/fence")


func test_the_mended_piece_stops_her_as_the_broken_one_did() -> void:
	var broken := PropCatalog.entry("tal/fence_broken")
	var mended := PropCatalog.entry("tal/fence")
	assert_eq(mended.get("shape"), broken.get("shape"), "the same shape: nothing to walk through")
	assert_eq(mended.get("anchor"), broken.get("anchor"), "the same place in the cell")
	assert_false(mended.has("shadow"), "nothing baked changes")
