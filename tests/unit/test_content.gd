extends GutTest
## Content guards: every tr("KEY") literal exists, every dialogue under content/ compiles
## and is registered for translation templates, placeholder lines are tagged (prototypes)
## or gone (vertical slice).

const CSV_FILES: PackedStringArray = [
	"res://content/locale/ui.csv",
	"res://content/locale/journal.csv",
	"res://content/locale/items.csv"
]
const SLICE_DIALOGUES := "res://content/dialogue/slice/"
## The story's dialogue folders: the slice and the acts after it (no [#ph] left in any of them).
const STORY_DIALOGUES: PackedStringArray = [
	"res://content/dialogue/slice/", "res://content/dialogue/akt1/"
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


func test_placeholder_tags_match_the_dialogue_kind() -> void:
	# Prototype dialogues carry [#ph] on every spoken line so none slips into a build.
	# Vertical-slice dialogues (content/dialogue/slice) are the playtest text: no [#ph] left
	# (docs/CONTENT_GUIDE.md).
	for path in _files("res://content/dialogue", ["dialogue"]):
		var slice := _is_story(path)
		var result := DMCompiler.compile_string(FileAccess.get_file_as_string(path), path)
		for key: String in result.lines:
			var line: Dictionary = result.lines[key]
			if line.get("type") != "dialogue":
				continue
			var tagged: bool = "ph" in line.get("tags", [])
			if slice:
				assert_false(
					tagged, "%s:%d placeholder in slice '%s'" % [path, int(key) + 1, line["text"]]
				)
			else:
				assert_true(tagged, "%s:%d untagged line '%s'" % [path, int(key) + 1, line["text"]])


func test_slice_speakers_are_known() -> void:
	# "Name: text" makes a speaker; a colon in narration would turn half a sentence into a
	# name plate. Every slice speaker must have a voice (content/dialogue/voices.json).
	var voices: Dictionary = JSON.parse_string(
		FileAccess.get_file_as_string("res://content/dialogue/voices.json")
	)
	for path in _story_files():
		var result := DMCompiler.compile_string(FileAccess.get_file_as_string(path), path)
		for key: String in result.lines:
			var line: Dictionary = result.lines[key]
			if line.get("type") != "dialogue":
				continue
			var speaker := str(line.get("character", ""))
			assert_true(
				speaker.is_empty() or voices.has(speaker),
				"%s:%d unknown speaker '%s'" % [path, int(key) + 1, speaker]
			)


func _is_story(path: String) -> bool:
	for folder in STORY_DIALOGUES:
		if path.begins_with(folder):
			return true
	return false


func _story_files() -> PackedStringArray:
	var found: PackedStringArray = []
	for folder in STORY_DIALOGUES:
		found.append_array(_files(folder.trim_suffix("/"), ["dialogue"]))
	return found


## Compiled lines of one dialogue file by static ID.
func _lines_by_id(path: String) -> Dictionary:
	var by_id := {}
	var result := DMCompiler.compile_string(FileAccess.get_file_as_string(path), path)
	for key: String in result.lines:
		var line: Dictionary = result.lines[key]
		if line.has("static_id"):
			by_id[str(line["static_id"])] = line
	return by_id


func test_the_woman_at_the_stream_is_nameless_until_she_says_her_name() -> void:
	# The name plate must not give "Mira" away before "Mira, übrigens." (tal_mira_24).
	var lines := _lines_by_id("res://content/dialogue/slice/tal.dialogue")
	var checked := 0
	for n in range(1, 24):
		if n == 20:
			continue  # "Mira wendet sich wieder ihrem Netz zu": after her introduction
		var id := "tal_mira_%d" % n
		if not lines.has(id):
			continue
		checked += 1
		var line: Dictionary = lines[id]
		assert_ne(line.get("character", ""), "Mira", "%s speaks as Mira too early" % id)
		assert_false(str(line["text"]).begins_with("Mira"), "%s names her in narration" % id)
	assert_gt(checked, 15, "the whole first meeting was checked")
	assert_eq(lines["tal_mira_24"].get("character"), "Mira", "she introduces herself here")


func test_polish_two_lines_are_in_the_dialogues() -> void:
	var elysia := _lines_by_id("res://content/dialogue/slice/elysia.dialogue")
	for id: String in [
		"el_wake_0",
		"el_wake_8",
		"el_loop_2",
		"el_stone_1",
		"el_tree_1",
		"el_tree_2",
		"el_pillar_1",
		"el_crystal_1",
		"el_splash_1"
	]:
		assert_true(elysia.has(id), "elysia.dialogue lost %s" % id)
	assert_false(elysia.has("el_wake_4"), "the joke about 'the only one' is gone")
	var haus := _lines_by_id("res://content/dialogue/slice/haus.dialogue")
	for id: String in ["haus_mira_35", "haus_mira_r12", "haus_mira_r13", "haus_mira_r14"]:
		assert_true(haus.has(id), "haus.dialogue lost %s" % id)
	var tal := _lines_by_id("res://content/dialogue/slice/tal.dialogue")
	for id: String in ["tal_end_12", "tal_antr_busy_1", "tal_antr_busy_2", "tal_antr_busy_3"]:
		assert_true(tal.has(id), "tal.dialogue lost %s" % id)


func test_every_memory_has_a_journal_entry() -> void:
	# add_memory("npc", "id") in a dialogue shows up in the journal as MEMORY_<NPC>_<ID>.
	var keys := _csv_keys()
	var regex := RegEx.create_from_string('add_memory\\(\\s*"([a-z_]+)"\\s*,\\s*"([a-z_]+)"')
	var seen := 0
	for path in _story_files():
		for found in regex.search_all(FileAccess.get_file_as_string(path)):
			seen += 1
			var key := ("MEMORY_%s_%s" % [found.get_string(1), found.get_string(2)]).to_upper()
			assert_true(
				keys.has(key),
				"%s remembers %s but %s is missing" % [path, found.get_string(2), key]
			)
	assert_gt(seen, 30, "the slice remembers a lot")


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
