extends GutTest
## Act III, segment W1: the morning after (ADR-070). The cue `morning` says the empty place across
## the fire and the stream that goes on, and nothing else: no Mira, no memory, no meaning. The quest
## `main_forest_way` begins with it and moves one step when the stream is entered. The scene that
## plays the cue is tested in test_akt3_aufbruch_szene.

const MORNING := "res://content/dialogue/akt3/aufbruch.dialogue"
const IDS: Array[String] = ["auf_morn_1", "auf_morn_2", "auf_morn_3", "auf_morn_4", "auf_morn_5"]
const BACHLAUF := preload("res://world/levels/akt2/bachlauf.tscn")
## Words that would explain her, the player or what it means: the morning shows things.
const FORBIDDEN: PackedStringArray = [
	"traurig",
	"allein",
	"einsam",
	"vermiss",
	"erinner",
	"verlass",
	"zurück",
	"Abschied",
	"Heim",
	"Kind",
]


func before_each() -> void:
	WorldState.new_game()


func after_each() -> void:
	WorldState.new_game()


func test_the_morning_says_five_things_in_order() -> void:
	var expected := PackedStringArray()
	for id: String in IDS:
		expected.append(LineText.of(id))
	assert_eq(await DialogueWalk.play(MORNING, "morning"), expected)


func test_the_morning_is_narration_without_a_voice_and_without_a_verdict() -> void:
	for id: String in IDS:
		var line := LineText.of(id)
		assert_ne(line, "", id)
		for mark: String in [":", "!", "?", "…"]:
			assert_false(line.contains(mark), "%s: no %s in narration" % [id, mark])
		for word: String in FORBIDDEN:
			assert_false(
				line.contains(word),
				"%s: '%s' would explain what the morning only shows" % [id, word]
			)
		for digit: String in "0123456789":
			assert_false(line.contains(digit), "%s: numbers are written out" % id)


func test_nobody_speaks_in_the_morning() -> void:
	# a line with a speaker reads "Name: text" in the file; narration has none
	var speaker := RegEx.create_from_string("^[^\\t#~=\\[]*\\w: ")
	var seen := 0
	for line in FileAccess.get_file_as_string(MORNING).split("\n"):
		if line.contains("[ID:auf_morn_"):
			seen += 1
			assert_null(speaker.search(line), "narration has no speaker: %s" % line)
	assert_eq(seen, IDS.size())


func test_her_absence_is_shown_by_things() -> void:
	assert_string_contains(LineText.of("auf_morn_2"), "Miras Platz")
	assert_string_contains(LineText.of("auf_morn_3"), "dunkle Stelle")
	assert_string_contains(LineText.of("auf_morn_5"), "Bach")


func test_the_cue_sets_nothing_and_asks_nothing() -> void:
	var before := JSON.stringify(WorldState.state.to_dict())
	await DialogueWalk.play(MORNING, "morning")
	assert_eq(
		JSON.stringify(WorldState.state.to_dict()),
		before,
		"the scene marks the morning, the cue only tells it"
	)
	assert_eq(await DialogueWalk.answers(MORNING, "morning"), PackedStringArray(), "no choice")


# --- the quest -------------------------------------------------------------------------


func test_the_way_through_the_wood_begins_with_leaving_and_goes_along_the_stream() -> void:
	var quest := ContentDB.quest("main_forest_way")
	assert_not_null(quest)
	assert_eq(quest.first_stage().id, "leave")
	assert_true(quest.can_advance("leave", "brook"))
	assert_true(quest.can_advance("brook", "wood"), "W2 leads the stream into the wood")
	assert_eq(quest.stage("wood").outcome, "", "the hut no longer ends the quest")
	assert_true(quest.can_advance("wood", "night"), "W3 leads the wood into the night")
	assert_eq(quest.stage("night").outcome, "done", "the last stage built so far ends it")
	assert_eq(quest.stage("wood").objectives, PackedStringArray(["hermit", "flood"]))
	assert_eq(quest.stage("brook").outcome, "", "the stream no longer ends the quest")


func test_the_journal_has_a_title_and_a_hint_for_each_stage() -> void:
	for key: String in [
		"QUEST_MAIN_FOREST_WAY_TITLE",
		"QUEST_MAIN_FOREST_WAY_LEAVE",
		"QUEST_MAIN_FOREST_WAY_BROOK",
		"QUEST_MAIN_FOREST_WAY_WOOD",
		"QUEST_MAIN_FOREST_WAY_OBJ_HERMIT",
		"QUEST_MAIN_FOREST_WAY_OBJ_FLOOD",
		"QUEST_MAIN_FOREST_WAY_NIGHT"
	]:
		assert_ne(tr(key), key, key)
	var leave := tr("QUEST_MAIN_FOREST_WAY_LEAVE")
	assert_string_contains(leave, "Mira")
	assert_string_contains(leave, "Süden")
	assert_string_contains(tr("QUEST_MAIN_FOREST_WAY_BROOK"), "Wasser")
	for key: String in ["QUEST_MAIN_FOREST_WAY_LEAVE", "QUEST_MAIN_FOREST_WAY_BROOK"]:
		var text := tr(key)
		for mark: String in ["!", "?", "…"]:
			assert_false(text.contains(mark), "%s: %s" % [key, mark])
		for digit: String in "0123456789":
			assert_false(text.contains(digit), key)


func test_entering_the_stream_moves_the_quest_one_step() -> void:
	WorldState.set_ui_mode(GameState.UiMode.REAL)
	assert_true(WorldState.start_quest("main_forest_way"))
	assert_eq(WorldState.quest_stage("main_forest_way"), "leave")
	var scene: LookScene = BACHLAUF.instantiate()
	add_child_autofree(scene)
	await wait_physics_frames(3)
	assert_eq(WorldState.quest_stage("main_forest_way"), "brook")


func test_whoever_never_had_the_morning_enters_the_stream_without_a_quest() -> void:
	WorldState.set_ui_mode(GameState.UiMode.REAL)
	var scene: LookScene = BACHLAUF.instantiate()
	add_child_autofree(scene)
	await wait_physics_frames(3)
	assert_eq(WorldState.quest_stage("main_forest_way"), "", "Act II's evening walk starts nothing")
	assert_false(WorldState.is_quest_active("main_forest_way"))
