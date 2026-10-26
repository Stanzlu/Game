extends GutTest
## Act III, segment W3: the map of the hermit's hut (content/maps/huette.txt, written by hand). A
## small room, 14 by 10 cells, in a larger field of black: everything that can be looked at has a
## cue, the one door out has no condition and no blocker stands anywhere, and the room fits the
## picture at its tightest zoom. The scene is tested in test_akt3_huette_szene.

const PATH := "res://content/maps/huette.txt"
const DIALOGUE := "res://content/dialogue/akt3/huette.dialogue"
const ROOM := Rect2i(9, 5, 14, 10)
const ONCE := "SKTEpbufwnvDd@1"


func _legend_and_rows() -> Array:
	var legend := {}
	var rows: PackedStringArray = []
	var in_map := false
	for raw in FileAccess.get_file_as_string(PATH).split("\n"):
		if raw == "[map]":
			in_map = true
		elif in_map:
			if not raw.is_empty():
				rows.append(raw)
		elif raw.length() > 4 and raw.substr(1, 3) == " = " and not raw.begins_with(";"):
			legend[raw[0]] = JSON.parse_string(raw.substr(4))
	return [legend, rows]


func test_it_is_thirty_two_by_twenty_with_every_spot_once() -> void:
	var parsed := _legend_and_rows()
	var legend: Dictionary = parsed[0]
	var rows: PackedStringArray = parsed[1]
	assert_eq(rows.size(), 20)
	for row: String in rows:
		assert_eq(row.length(), 32)
	var text := "".join(rows)
	for glyph in ONCE:
		assert_eq(text.count(glyph), 1, glyph)
		assert_true(legend.has(glyph), "%s is in the legend" % glyph)


func test_the_room_is_walled_and_the_rest_is_black() -> void:
	var rows: PackedStringArray = _legend_and_rows()[1]
	for y in range(rows.size()):
		for x in range(rows[y].length()):
			var inside := ROOM.has_point(Vector2i(x, y))
			var glyph := rows[y][x]
			if not inside and not (x == 12 and y == 15):
				assert_true(
					glyph in "#S", "(%d,%d) outside the room is black, got %s" % [x, y, glyph]
				)
	# the walls are one cell thick on every side
	for x in range(ROOM.position.x, ROOM.end.x):
		assert_false(rows[ROOM.position.y][x] in "_@1", "the back wall is a wall")
		assert_false(rows[ROOM.end.y - 1][x] in "_@1", "the front wall is a wall")


func test_no_blocker_stands_anywhere_and_the_door_out_has_no_condition() -> void:
	var legend: Dictionary = _legend_and_rows()[0]
	for glyph: String in legend:
		var entry: Dictionary = legend[glyph]
		assert_false("blocker" in str(entry.get("prop", "")), "%s: nothing holds her in" % glyph)
		if glyph != "d":
			var params: Dictionary = entry.get("params", {})
			assert_false(
				params.has("if") or params.has("unless"), "%s: nothing is conditional" % glyph
			)
	var door: Dictionary = legend["D"]["params"]
	assert_eq(door["target"], "waldweg")
	assert_eq(door["spawn"], "huette")
	assert_true(door["auto"])
	assert_eq(
		legend["d"]["params"]["if"],
		"forest.hut_stay_3",
		"the door stands open after the third step"
	)


func test_the_arrival_is_two_cells_from_the_door_and_the_player_starts_beside_it() -> void:
	var rows: PackedStringArray = _legend_and_rows()[1]
	var spots := {}
	for y in range(rows.size()):
		for x in range(rows[y].length()):
			if rows[y][x] in "D1@":
				spots[rows[y][x]] = Vector2i(x, y)
	assert_eq(
		spots["D"].y - spots["1"].y, 2, "an auto door's zone is one cell: two rows are enough"
	)
	assert_eq(spots["D"].x, spots["1"].x, "straight in front of it")
	assert_eq(spots["@"].y, spots["1"].y)


func test_every_thing_to_look_at_has_a_cue_in_the_huts_own_dialogue() -> void:
	var legend: Dictionary = _legend_and_rows()[0]
	var cues: PackedStringArray = []
	for glyph: String in legend:
		var params: Dictionary = legend[glyph].get("params", {})
		if params.has("cue"):
			cues.append(params["cue"])
			assert_eq(params.get("dialogue"), DIALOGUE, "%s reads the hut's own file" % glyph)
	for cue: String in ["hermit", "flute_shelf", "window", "cup_nail", "bolt"]:
		assert_true(cue in cues, cue)
	var resource := load(DIALOGUE) as DialogueResource
	for cue: String in cues:
		assert_true(resource.get_cues().has(cue), "cue '%s' exists" % cue)


func test_the_sprites_and_the_figure_of_the_room_exist() -> void:
	var legend: Dictionary = _legend_and_rows()[0]
	for glyph: String in legend:
		var params: Dictionary = legend[glyph].get("params", {})
		if params.has("sprite"):
			assert_false(PropCatalog.entry(params["sprite"]).is_empty(), str(params["sprite"]))
		if params.has("sheet"):
			assert_true(ResourceLoader.exists(params["sheet"]), str(params["sheet"]))
	assert_true(ResourceLoader.exists("res://assets/generated/maps/huette_ground.png"))


func test_the_scene_has_the_rooms_zoom() -> void:
	var source := FileAccess.get_file_as_string("res://world/levels/akt3/huette.tscn")
	assert_true(
		source.contains("view_zoom = 1.5"), "the room's own picture, like the house (ADR-045)"
	)
	assert_true(source.contains('map_path = "res://content/maps/huette.txt"'))
	assert_false(source.contains("day_preset"), "no weather of the valley in here")
