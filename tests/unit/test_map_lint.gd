extends GutTest
## MapLint (docs/PRODUKTIONSPLAN.md, T4): each rule has a map that must turn red, a map that
## must stay green, and the shipped maps must pass.

const NPC := "res://entities/npc/npc_walker.tscn"
const LEGEND := """
[legend]
# = {"atlas": [0, 0], "surface": "stone", "solid": true}
. = {"atlas": [1, 0], "surface": "grass"}
~ = {"atlas": [2, 0], "surface": "water", "solid": true}
@ = {"ground": ".", "marker": "player_spawn"}
d = {"ground": ".", "marker": "spawn_door"}
N = {"ground": ".", "prop": "res://entities/npc/npc_walker.tscn", "params": {"cue": "hi"}}
W = {"ground": "#", "prop": "res://entities/npc/npc_walker.tscn", "params": {"cue": "hi"}}
w = {"ground": "#", "prop": "res://world/props/decor.tscn", "params": {"cue": "window"}}
T = {"ground": "~", "prop": "res://world/props/stepping_stone.tscn"}
"""


func _map(rows: PackedStringArray, meta := "") -> MapData:
	var text := (
		(meta + LEGEND + "[map]\n" + "\n".join(rows))
		if meta.is_empty()
		else (meta + LEGEND + "[map]\n" + "\n".join(rows))
	)
	var data := MapData.parse(text, {"tile_size": 16, "symbols": {}}, "fixture")
	assert_true(data.is_valid(), str(data.errors))
	return data


func test_a_small_walkable_map_is_fine() -> void:
	var data := _map(["#######", "#@..N.#", "#######"])
	assert_eq(MapLint.validate(data, "fixture"), PackedStringArray())


func test_a_map_without_its_spawn_is_found() -> void:
	var data := _map(["#####", "#..N#", "#####"])
	var problems := MapLint.spawn_problems(data, "fixture")
	assert_eq(problems.size(), 1)
	assert_string_contains(problems[0], "no 'player_spawn' marker")


func test_a_spawn_in_a_wall_is_found() -> void:
	var data := _map(["#####", "#.@.#", "#####"])
	data.placements.append(
		{"symbol": "d", "cell": Vector2i(0, 0), "prop": "", "marker": "spawn_door", "params": {}}
	)
	var problems := MapLint.spawn_problems(data, "fixture")
	assert_eq(problems.size(), 1)
	assert_string_contains(problems[0], "stands in a wall")


func test_something_behind_a_wall_cannot_be_reached() -> void:
	var data := _map(["#########", "#@.#...N#", "#########"])
	var problems := MapLint.reach_problems(data, "fixture")
	assert_eq(problems.size(), 1)
	assert_string_contains(problems[0], "npc_walker.tscn cannot be reached")


func test_stepping_stones_make_a_way_across_water() -> void:
	var rows: PackedStringArray = ["#########", "#@.TTT.N#", "#########"]
	assert_eq(MapLint.reach_problems(_map(rows), "fixture"), PackedStringArray())
	var broken: PackedStringArray = ["#########", "#@.~~~.N#", "#########"]
	assert_eq(MapLint.reach_problems(_map(broken), "fixture").size(), 1)


func test_a_door_arrival_in_a_closed_off_room_is_found() -> void:
	var data := _map(["#########", "#@.#.d..#", "#########"])
	var problems := MapLint.reach_problems(data, "fixture")
	assert_eq(problems.size(), 1)
	assert_string_contains(problems[0], "spawn_door cannot be reached")


func test_furniture_in_a_wall_is_used_from_the_floor_in_front_of_it() -> void:
	var data := _map(["#####", "#.w.#", "#.@.#", "#####"])
	assert_eq(MapLint.reach_problems(data, "fixture"), PackedStringArray())


func test_a_person_in_a_wall_is_found() -> void:
	var data := _map(["#####", "#@W.#", "#####"])
	var problems := MapLint.floor_problems(data, "fixture")
	assert_eq(problems.size(), 1)
	assert_string_contains(problems[0], "stands in a wall or in water")


func test_a_symmetric_map_is_fine_and_a_crooked_one_is_found() -> void:
	var meta := "[meta]\nsymmetry = 3\n"
	var fine := _map(["#######", "#N.@.N#", "#######"], meta)
	assert_eq(MapLint.symmetry_problems(fine, "fixture"), PackedStringArray())
	var crooked := _map(["#######", "#N.@..#", "#######"], meta)
	var problems := MapLint.symmetry_problems(crooked, "fixture")
	assert_eq(problems.size(), 1)
	assert_string_contains(problems[0], "has no twin")


func test_crooked_ground_is_found() -> void:
	var meta := "[meta]\nsymmetry = 3\n"
	var data := _map(["#######", "#..@.~#", "#######"], meta)
	var problems := MapLint.symmetry_problems(data, "fixture")
	assert_eq(problems.size(), 1, "one cell of the left half has another twin")


func test_the_axis_must_be_the_middle_column() -> void:
	var data := _map(["######", "#.@..#", "######"], "[meta]\nsymmetry = 2\n")
	assert_string_contains(MapLint.symmetry_problems(data, "fixture")[0], "not the middle")


func test_the_stone_and_the_rift_may_stand_alone() -> void:
	# a pickup (the stone) has no twin in Elysia, and neither has the rift
	var meta := "[meta]\nsymmetry = 3\n"
	var data := _map(["#######", "#..@..#", "#######"], meta)
	data.placements.append(
		{
			"symbol": "j",
			"cell": Vector2i(1, 1),
			"prop": "res://world/props/pickup.tscn",
			"marker": "",
			"params": {}
		}
	)
	assert_eq(MapLint.symmetry_problems(data, "fixture"), PackedStringArray())


func test_the_shipped_maps_pass() -> void:
	assert_eq(MapLint.validate_project(), PackedStringArray())


func test_the_valley_is_one_walkable_land_over_the_stones() -> void:
	var legend := MapView.load_legend(MapView.DEFAULT_LEGEND)
	var text := FileAccess.get_file_as_string("res://content/maps/tal.txt")
	var data := MapData.parse(text, legend, "tal")
	var starts: Array[Vector2i] = []
	for placement: Dictionary in data.find_marker(MapLint.SPAWN_MARKER):
		starts.append(placement["cell"])
	var seen := MapLint.reachable(data, starts)
	var walkable := MapLint.walkable_cells(data)
	assert_gt(starts.size(), 0, "the valley has a spawn")
	assert_gt(float(seen.size()) / float(walkable.size()), 0.8, "both banks are one land")
