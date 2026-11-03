extends GutTest
## Act IV, segment S8: the homecoming (docs/akt4/REGIONSBRIEFE.md, O9, O14, O15, O18). The act
## ends in the house, quietly: Tess comes as a guest with a purpose, hangs shelves, says one
## sentence about the bench, brings the loaf of the one with the slips, sits and goes; the chair
## stays. These tests read the lines, the flags that hang on the cues and the quest stages; the
## scene is tested in test_akt4_heimkehr_szene, the four places in test_akt4_regal.

const FILE := "res://content/dialogue/akt4/heimkehr.dialogue"
const STRASSE := "res://content/dialogue/akt4/strasse.dialogue"
const QUEST_FILE := "res://content/quests/main_city_way.tres"
const CUES: PackedStringArray = [
	"home_in",
	"tess_in",
	"build",
	"bench",
	"bread",
	"home_close",
	"slot_nothing",
	"slot_placed",
]
## What a cue sets (the rest of the homecoming belongs to the scene).
const SETS := {"build": "house.shelves", "bread": "house.bread"}


func before_each() -> void:
	WorldState.new_game()
	WorldState.set_ui_mode(GameState.UiMode.REAL)


func after_each() -> void:
	WorldState.new_game()


func _source() -> String:
	return FileAccess.get_file_as_string(FILE)


func _said_by(who: String) -> String:
	var spoken := ""
	for hit in RegEx.create_from_string("(?m)^\\s*%s: (.*)\\[ID:" % who).search_all(_source()):
		spoken += hit.get_string(1) + "\n"
	return spoken


func _told(cue: String) -> String:
	var told := ""
	for line in await DialogueWalk.play(FILE, cue):
		told += line + "\n"
	return told


func _has(seen: PackedStringArray, id: String) -> bool:
	return LineText.of(id) in seen


# --- The file ---------------------------------------------------------------------------------


func test_the_file_tells_its_cues_in_draft_with_unique_ids_within_the_budget() -> void:
	var names: PackedStringArray = []
	for hit in RegEx.create_from_string("(?m)^~ ([a-z0-9_]+)$").search_all(_source()):
		names.append(hit.get_string(1))
	assert_eq(names, CUES)
	var ids: PackedStringArray = []
	for hit in RegEx.create_from_string("\\[ID:(hk4_[a-z0-9_]+)\\]").search_all(_source()):
		ids.append(hit.get_string(1))
	var unique := {}
	for id in ids:
		unique[id] = true
	assert_eq(unique.size(), ids.size(), "no ID twice")
	assert_eq(_source().count("[#draft]"), ids.size(), "every line is a draft")
	assert_false(_source().contains("[#ph]"), "no placeholder in a story file")
	# the segment plans 24 lines; the act as a whole stays within its 400
	assert_lte(ids.size(), 24, "the lines of the segment")


func test_the_quest_has_the_way_home_and_ends_at_done() -> void:
	var quest := load(QUEST_FILE) as QuestDef
	var stages: PackedStringArray = []
	for stage in quest.stages:
		stages.append(stage.id)
	assert_eq(stages.slice(stages.size() - 3), PackedStringArray(["night", "home", "done"]))
	assert_true(quest.stage("done").is_final(), "done is the end")
	assert_false(quest.stage("home").is_final(), "home is not")
	assert_false(quest.stage("night").is_final(), "and the night is no longer the end")
	assert_true(quest.can_advance("night", "home") and quest.can_advance("home", "done"))
	for key: String in [
		"QUEST_MAIN_CITY_WAY_HOME", "QUEST_MAIN_CITY_WAY_DONE", "MEMORY_TESS_GUEST"
	]:
		assert_ne(tr(key), key, "the journal has " + key)


# --- Tess ------------------------------------------------------------------------------------


func test_tess_is_short_concrete_and_warm_in_what_she_does_never_in_what_she_says() -> void:
	var said := _said_by("Tess")
	assert_gt(said.length(), 120, "all of her speech is read")
	for word: String in [
		"Gefühl",
		"fühl",
		"Nacht",
		"Stadt",
		"Mira",
		"stolz",
		"gut gemacht",
		"toll",
		"schön",
		"super",
		"Lebe",
		"Leben",
		"Angst",
		"heil",
		"Danke",
		"Freund",
		"!",
	]:
		assert_false(said.contains(word), "no %s from Tess" % word)
	for line in said.split("\n", false):
		assert_lte(line.split(" ", false).size(), 14, "she is short: " + line)
	for digit: String in "0123456789":
		assert_false(_spoken().contains(digit), "no digit in the text")


func test_the_bench_gets_a_verdict_that_it_holds_and_no_praise() -> void:
	var told := await _told("bench")
	assert_true(told.contains("Schief. Aber dicht."), "the sentence of the brief (O9)")
	assert_false(told.contains("gut"), "no praise")
	assert_eq((await DialogueWalk.play(FILE, "bench")).size(), 2, "and nothing after it")
	assert_false(_said_by("Tess").contains("Antreiber"), "she does not speak about him")


func test_the_loaf_is_the_one_from_the_list_and_no_new_thing() -> void:
	var told := await _told("bread")
	assert_true(told.contains("Brot"))
	assert_true(told.contains("Zetteln"), "the one with the slips, a picture, no name")
	assert_false(told.contains("Gefällige"), "no name, no verdict")
	assert_false(_source().contains("add_item"), "item_loaf is the one from S5, nothing new")


# --- Who she is for whom -----------------------------------------------------------------------


func test_whoever_never_met_her_reads_her_name_on_the_folding_rule() -> void:
	var stranger := await DialogueWalk.play(FILE, "tess_in")
	assert_true(_has(stranger, "hk4_tess_2"), "the name on the rule")
	WorldState.set_flag("city.tess_met")
	var known := await DialogueWalk.play(FILE, "tess_in")
	assert_false(_has(known, "hk4_tess_2"), "whoever knows her reads no name")
	for seen: PackedStringArray in [stranger, known]:
		assert_true(
			_has(seen, "hk4_tess_3") and _has(seen, "hk4_tess_6"), "she comes with a purpose"
		)
	assert_true(_has(known, "hk4_tess_5"), "once, then it is the player's turn (wer_offer_1)")


# --- What the cues set ---------------------------------------------------------------------------


func test_the_flag_stands_before_the_line_that_speaks_of_it() -> void:
	var blocks := _blocks()
	for cue: String in SETS:
		var text: String = blocks[cue]
		var flag_at := text.find('set_flag("%s")' % SETS[cue])
		assert_gt(flag_at, -1, "%s sets %s" % [cue, SETS[cue]])
		assert_lt(flag_at, text.find("[ID:"), "before the first line: " + cue)


func test_the_cues_set_only_their_own_flag_and_the_scene_the_rest() -> void:
	for cue: String in SETS:
		WorldState.new_game()
		await DialogueWalk.play(FILE, cue)
		assert_true(WorldState.has_flag(SETS[cue]), cue)
		for other: String in SETS:
			if other != cue:
				assert_false(WorldState.has_flag(SETS[other]), "only its own: " + cue)
		assert_false(WorldState.has_flag("house.guest_tess"), "the scene sets the chair")
	for name: String in ["advance_quest", "Chapter", "Beat", "guest_tess"]:
		assert_false(_code().contains(name), "no %s in a cue: the scene does that" % name)


func test_the_close_is_the_memory_and_the_bond_and_the_house_has_the_last_word() -> void:
	var seen := await DialogueWalk.play(FILE, "home_close")
	assert_true(WorldState.has_memory("tess", "guest"))
	assert_eq(WorldState.relationship_state("tess"), "close")
	var last := seen[seen.size() - 1]
	assert_false(last.contains(":"), "narration")
	assert_eq(last, LineText.of("hk4_close_3"))
	assert_true(last.contains("Stuhl"), "what stays is a chair")
	assert_true(last.contains("kalt"), "the tea is still cold")


func test_the_house_in_every_state_knows_nothing_of_what_may_not_be_there() -> void:
	for word: String in ["Katze", "Einsiedler", "Blatt", "Mira"]:
		assert_false(_spoken().contains(word), "no %s: the text holds in every state" % word)


func test_the_places_say_nothing_to_judge_and_the_empty_one_does_not_send_her_searching() -> void:
	var empty := await _told("slot_nothing")
	var placed := await _told("slot_placed")
	for told: String in [empty, placed]:
		for word: String in ["schön", "gut", "noch nicht", "fehlt", "suche", "!"]:
			assert_false(told.contains(word), "no %s at a place" % word)
	assert_true(empty.contains("leer"))


# --- The morning on the road ----------------------------------------------------------------------


func test_the_dawn_on_the_road_is_two_lines_of_narration() -> void:
	var seen := await DialogueWalk.play(STRASSE, "dawn")
	assert_eq(seen.size(), 2)
	assert_true(_has(seen, "str_dawn_1") and _has(seen, "str_dawn_2"))
	for line in seen:
		assert_false(line.contains(":"), "narration")
	assert_eq(WorldState.quest_stage("main_city_way"), "", "the scene moves the stage, not the cue")


func _blocks() -> Dictionary:
	var blocks := {}
	var name := ""
	for line in _source().split("\n"):
		if line.begins_with("~ "):
			name = line.substr(2).strip_edges()
			blocks[name] = ""
		elif not name.is_empty():
			blocks[name] += line + "\n"
	return blocks


## The text of all lines (before their ID), comments and code left out.
func _spoken() -> String:
	var spoken := ""
	for line in _source().split("\n"):
		var at := line.find("[ID:")
		if at > -1:
			spoken += line.substr(0, at) + "\n"
	return spoken


## The code lines of the file (mutations), comments left out.
func _code() -> String:
	var code := ""
	for line in _source().split("\n"):
		if line.strip_edges().begins_with("do "):
			code += line + "\n"
	return code
