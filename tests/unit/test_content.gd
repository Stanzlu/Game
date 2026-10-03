extends GutTest
## Content guards: every tr("KEY") literal exists, every dialogue under content/ compiles
## and is registered for translation templates, placeholder lines are tagged.

const UI_CSV := "res://content/locale/ui.csv"
const CODE_DIRS: PackedStringArray = [
	"res://core", "res://entities", "res://world", "res://ui", "res://encounters"
]


func _files(dir_path: String, extensions: PackedStringArray) -> PackedStringArray:
	var found: PackedStringArray = []
	var dir := DirAccess.open(dir_path)
	if dir == null:
		return found
	for file_name in dir.get_files():
		if file_name.get_extension() in extensions:
			found.append(dir_path.path_join(file_name))
	for sub in dir.get_directories():
		found.append_array(_files(dir_path.path_join(sub), extensions))
	return found


func _csv_keys() -> Dictionary:
	var keys := {}
	var file := FileAccess.open(UI_CSV, FileAccess.READ)
	file.get_csv_line()
	while not file.eof_reached():
		var row := file.get_csv_line()
		if row.size() > 0 and not row[0].is_empty():
			keys[row[0]] = true
	return keys


func test_every_translation_key_in_code_exists() -> void:
	var keys := _csv_keys()
	var pattern := RegEx.create_from_string('tr\\(\\s*"([A-Z0-9_]+)"')
	var key_props := RegEx.create_from_string('(?:prompt_key|display_key)\\s*=\\s*"([A-Z0-9_]+)"')
	var checked := 0
	for dir_path in CODE_DIRS:
		for path in _files(dir_path, ["gd", "tscn", "tres"]):
			var text := FileAccess.get_file_as_string(path)
			for m in pattern.search_all(text) + key_props.search_all(text):
				checked += 1
				assert_true(
					keys.has(m.get_string(1)), "%s uses missing key %s" % [path, m.get_string(1)]
				)
	assert_gt(checked, 10, "scan found keys")


func test_every_content_dialogue_compiles_and_is_registered() -> void:
	var pot: PackedStringArray = ProjectSettings.get_setting(
		"internationalization/locale/translations_pot_files", PackedStringArray()
	)
	var dialogues := _files("res://content", ["dialogue"])
	assert_gt(dialogues.size(), 0)
	for path in dialogues:
		var resource := load(path) as DialogueResource
		assert_not_null(resource, "%s did not import" % path)
		assert_true(path in pot, "%s missing from translation templates" % path)


func test_every_cue_used_by_maps_exists() -> void:
	var legend := MapView.load_legend(MapView.DEFAULT_LEGEND)
	for path in _files("res://content/maps", ["txt"]):
		var data := MapData.parse(FileAccess.get_file_as_string(path), legend, path)
		for p: Dictionary in data.placements:
			var params: Dictionary = p["params"]
			if not params.has("cue"):
				continue
			var dialogue_path: String = params.get(
				"dialogue", "res://content/dialogue/sandbox/sandbox.dialogue"
			)
			var resource := load(dialogue_path) as DialogueResource
			assert_true(
				resource.cues.has(params["cue"]), "%s: cue %s missing" % [path, params["cue"]]
			)


func test_draft_lines_are_tagged_as_placeholders() -> void:
	# Phase 1 has no final text yet: every spoken line must carry [#ph] so none slips into a build.
	for path in _files("res://content/dialogue", ["dialogue"]):
		for line in FileAccess.get_file_as_string(path).split("\n"):
			var t := line.strip_edges()
			if t.is_empty() or t.begins_with("~") or t.begins_with("=>") or t.begins_with("#"):
				continue
			if t.begins_with("- "):
				continue
			assert_true(t.contains("[#ph]"), "%s: untagged line '%s'" % [path, t])
