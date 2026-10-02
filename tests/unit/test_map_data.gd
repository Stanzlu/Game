extends GutTest

const LEGEND := {
	"tile_size": 16,
	"symbols":
	{
		".": {"atlas": [0, 0], "surface": "grass"},
		",": {"atlas": [2, 0], "surface": "dirt"},
		"#": {"atlas": [4, 0], "surface": "stone", "solid": true},
		"@": {"ground": ".", "marker": "player_spawn"},
		"o": {"ground": ",", "prop": "res://world/props/puddle.tscn"},
	},
}


func test_parses_size_tiles_and_spawn() -> void:
	var data := MapData.parse("#####\n#.@,#\n#####", LEGEND, "t")
	assert_true(data.is_valid(), str(data.errors))
	assert_eq([data.width, data.height], [5, 3])
	assert_eq(data.tile_symbol_at(Vector2i(2, 1)), ".", "marker cell keeps its ground tile")
	assert_eq(data.surface_at_cell(Vector2i(3, 1)), &"dirt")
	assert_true(data.is_solid(Vector2i(0, 0)))
	assert_false(data.is_solid(Vector2i(1, 1)))
	var spawns := data.find_marker("player_spawn")
	assert_eq(spawns.size(), 1)
	assert_eq(spawns[0]["cell"], Vector2i(2, 1))


func test_outside_cells_are_solid_and_without_surface() -> void:
	var data := MapData.parse("...", LEGEND)
	assert_true(data.is_solid(Vector2i(-1, 0)))
	assert_eq(data.surface_at_cell(Vector2i(5, 5)), &"")


func test_local_legend_overrides_and_params() -> void:
	var text := (
		"[legend]\n"
		+ '1 = {"ground": ",", "prop": "res://world/props/sign.tscn", "params": {"cue": "hi"}}\n'
		+ "[map]\n.1o\n"
	)
	var data := MapData.parse(text, LEGEND)
	assert_true(data.is_valid(), str(data.errors))
	assert_eq(data.placements.size(), 2)
	assert_eq(data.placements[0]["params"], {"cue": "hi"})
	assert_eq(data.placements[1]["prop"], "res://world/props/puddle.tscn")


func test_unknown_symbol_is_reported_with_position() -> void:
	var data := MapData.parse("..\n.?", LEGEND, "bad.txt")
	assert_false(data.is_valid())
	assert_string_contains(data.errors[0], "bad.txt")
	assert_string_contains(data.errors[0], "row 2 col 2")
	assert_string_contains(data.errors[0], "'?'")


func test_ragged_rows_are_reported() -> void:
	var data := MapData.parse("...\n..", LEGEND)
	assert_false(data.is_valid())
	assert_string_contains(data.errors[0], "row 2 has length 2, expected 3")


func test_invalid_local_symbol_definitions_are_reported() -> void:
	var data := MapData.parse("[legend]\nab = {}\nc = not json\n[map]\n..", LEGEND)
	assert_eq(data.errors.size(), 2, str(data.errors))


func test_placement_needs_known_ground_and_kind() -> void:
	var data := MapData.parse('[legend]\nz = {"ground": "?"}\n[map]\n.z', LEGEND)
	assert_false(data.is_valid())
	assert_eq(data.errors.size(), 2, str(data.errors))


func test_empty_map_is_invalid() -> void:
	assert_false(MapData.parse("", LEGEND).is_valid())


func test_shipped_legend_and_maps_are_valid() -> void:
	var legend := MapView.load_legend(MapView.DEFAULT_LEGEND)
	assert_false(legend.is_empty(), "legend.json must load")
	var dir := DirAccess.open("res://content/maps")
	assert_not_null(dir)
	if dir == null:
		return
	var checked := 0
	for file_name: String in dir.get_files():
		if file_name.get_extension() != "txt":
			continue
		var path := "res://content/maps/" + file_name
		var data := MapData.parse(FileAccess.get_file_as_string(path), legend, path)
		assert_true(data.is_valid(), "%s: %s" % [path, data.errors])
		for p: Dictionary in data.placements:
			if not str(p["prop"]).is_empty():
				assert_true(
					ResourceLoader.exists(p["prop"]), "%s: missing prop %s" % [path, p["prop"]]
				)
		checked += 1
	assert_gt(checked, 0, "no maps found")


func test_comments_before_the_map_block_are_ignored() -> void:
	var data := MapData.parse("; a comment\n[legend]\n; another\n[map]\n..", LEGEND)
	assert_true(data.is_valid(), str(data.errors))
	assert_eq(data.height, 1)
