extends GutTest
## Content guards: every tr("KEY") literal exists, every dialogue under content/ compiles
## and is registered for translation templates, placeholder lines are tagged.

const CSV_FILES: PackedStringArray = [
	"res://content/locale/ui.csv",
	"res://content/locale/journal.csv",
	"res://content/locale/items.csv"
]
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
	for csv in CSV_FILES:
		var file := FileAccess.open(csv, FileAccess.READ)
		file.get_csv_line()
		while not file.eof_reached():
			var row := file.get_csv_line()
			if row.size() > 0 and not row[0].is_empty():
				keys[row[0]] = true
	return keys


func test_every_translation_key_in_code_exists() -> void:
	var keys := _csv_keys()
	var pattern := RegEx.create_from_string('tr\\(\\s*"([A-Z0-9_]+)"')
	var key_props := RegEx.create_from_string(
		'(?:prompt_key|display_key|title_key)\\s*=\\s*"([A-Z0-9_]+)"'
	)
	# Menu rows and settings take translation keys as plain string arguments.
	var menu_keys := RegEx.create_from_string(
		'(?:add_\\w+\\(|\\[|, |\\n\\s*)"([A-Z][A-Z0-9]*_[A-Z0-9_]+)"'
	)
	var checked := 0
	for dir_path in CODE_DIRS:
		for path in _files(dir_path, ["gd", "tscn", "tres"]):
			var text := FileAccess.get_file_as_string(path)
			var found := pattern.search_all(text) + key_props.search_all(text)
			for m in found + menu_keys.search_all(text):
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
	# No final text yet: every spoken line must carry [#ph] so none slips into a build.
	for path in _files("res://content/dialogue", ["dialogue"]):
		var result := DMCompiler.compile_string(FileAccess.get_file_as_string(path), path)
		for key: String in result.lines:
			var line: Dictionary = result.lines[key]
			if line.get("type") != "dialogue":
				continue
			var tags: Array = line.get("tags", [])
			assert_true(
				"ph" in tags, "%s:%d untagged line '%s'" % [path, int(key) + 1, line["text"]]
			)


func test_world_actions_in_maps_are_valid() -> void:
	var legend := MapView.load_legend(MapView.DEFAULT_LEGEND)
	var checked := 0
	for path in _files("res://content/maps", ["txt"]):
		var data := MapData.parse(FileAccess.get_file_as_string(path), legend, path)
		for p: Dictionary in data.placements:
			var params: Dictionary = p["params"]
			if params.has("actions"):
				checked += 1
				assert_eq(StateActions.validate(params["actions"]), PackedStringArray(), path)
			if params.has("flag"):
				assert_true(GameState.is_flag_id(str(params["flag"])), "%s: flag" % path)
	assert_gt(checked, 0, "sandbox uses world actions")
