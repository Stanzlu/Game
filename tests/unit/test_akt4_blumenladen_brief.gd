extends GutTest
## Act IV, segment S3: the letter and the things in the florist's shop. After the duck Orin shows
## her a bunch of dried peonies over his table and a letter without an address; she listens,
## holds the bunch or goes, and after it nothing is funny. The first half of the shop (the
## request, the duck, the report) is tested in test_akt4_blumenladen, the scene in
## test_akt4_blumenladen_szene.

const FILE := "res://content/dialogue/akt4/blumenladen.dialogue"
const DUCK := "side_city_duck"
const LETTER := "side_city_letter"
const FEATHER := "curiosity_duck_feather"


func before_each() -> void:
	WorldState.new_game()
	WorldState.set_ui_mode(GameState.UiMode.REAL)


func after_each() -> void:
	WorldState.new_game()


func _has(seen: PackedStringArray, id: String) -> bool:
	return LineText.of(id) in seen


## The duck is settled (the pots are out when `passed`, inside when not).
func _duck_done(passed: bool) -> void:
	WorldState.start_quest(DUCK)
	WorldState.set_flag("city.orin_met")
	WorldState.set_flag("city.duck_seen")
	WorldState.advance_quest(DUCK, "done")
	WorldState.set_flag("city.duck_passed" if passed else "city.duck_stayed")


# --- The letter -------------------------------------------------------------------------------


func test_listening_ends_the_quest_and_leaves_the_letter_closed() -> void:
	_duck_done(true)
	var seen := await DialogueWalk.play(FILE, "orin", PackedStringArray(["Strauß", "Ich höre zu"]))
	for id in ["flo_let_7", "flo_let_8", "flo_let_9", "flo_let_11"]:
		assert_true(_has(seen, id), id)
	assert_true(WorldState.has_flag("city.letter_told"))
	assert_false(WorldState.has_flag("city.letter_held"))
	assert_eq(WorldState.quest_stage(LETTER), "done")
	assert_true(WorldState.has_memory("orin", "letter"))
	assert_eq(WorldState.relationship_state("orin"), "familiar")


func test_holding_the_bunch_ends_it_too_and_remembers_that_she_held() -> void:
	_duck_done(false)
	var seen := await DialogueWalk.play(FILE, "orin", PackedStringArray(["Strauß", "Gib ihn mir"]))
	assert_true(_has(seen, "flo_let_13"), "lighter than it looks")
	assert_true(WorldState.has_flag("city.letter_told"))
	assert_true(WorldState.has_flag("city.letter_held"))
	assert_eq(WorldState.quest_stage(LETTER), "done")
	assert_true(WorldState.has_memory("orin", "letter"))


func test_going_leaves_the_letter_open_and_nothing_is_set() -> void:
	_duck_done(true)
	var seen := await DialogueWalk.play(FILE, "orin", PackedStringArray(["Strauß", "…"]))
	assert_true(_has(seen, "flo_let_17"))
	assert_true(WorldState.is_quest_started(LETTER), "he has shown her the bunch")
	assert_eq(WorldState.quest_stage(LETTER), "listen", "no ending is promised")
	assert_false(WorldState.has_flag("city.letter_told"))
	assert_false(WorldState.has_memory("orin", "letter"))
	var again := await DialogueWalk.play(FILE, "orin", PackedStringArray(["Strauß", "Ich höre zu"]))
	assert_true(_has(again, "flo_let_1"), "the second time he is short")
	assert_false(_has(again, "flo_let_7"), "the letter is not described twice")
	assert_eq(WorldState.quest_stage(LETTER), "done", "and she can still listen")


func test_orin_says_things_and_never_a_reason_or_a_name() -> void:
	var told := ""
	for pick: String in ["Ich höre zu", "Gib ihn mir"]:
		WorldState.new_game()
		_duck_done(true)
		for line in await DialogueWalk.play(FILE, "orin", PackedStringArray(["Strauß", pick])):
			told += line + "\n"
	for word: String in [
		"gestorben",
		"Tod",
		"verloren",
		"Verlust",
		"Trauer",
		"Schmerz",
		"Schuld",
		"verzeih",
		"du musst",
		"Heilung",
		"Mira",
	]:
		assert_false(told.contains(word), "the letter gives no reason: " + word)


func test_after_the_letter_nothing_is_funny_not_orin_and_not_the_things() -> void:
	WorldState.start_quest(LETTER)
	WorldState.advance_quest(LETTER, "done")
	WorldState.set_flag("city.letter_told")
	var quiet := ""
	for cue: String in ["orin", "dried", "table", "shelf"]:
		for line in await DialogueWalk.play(FILE, cue):
			quiet += line + "\n"
	for word: String in ["Ente", "Quak", "Drachen", "Läuse", "nervös", "Kompromiss", "darf"]:
		assert_false(quiet.contains(word), "no joke after the letter: " + word)
	assert_true(_has(await DialogueWalk.play(FILE, "dried"), "flo_dried_3"))
	assert_true(_has(await DialogueWalk.play(FILE, "table"), "flo_table_3"))
	assert_true(_has(await DialogueWalk.play(FILE, "shelf"), "flo_shelf_4"))


func test_after_the_letter_he_has_two_quiet_lines_and_one_more_for_whoever_held_it() -> void:
	WorldState.start_quest(LETTER)
	WorldState.advance_quest(LETTER, "done")
	WorldState.set_flag("city.letter_told")
	var told := await DialogueWalk.play(FILE, "orin")
	assert_eq(told.size(), 2)
	WorldState.set_flag("city.letter_held")
	var held := await DialogueWalk.play(FILE, "orin")
	assert_eq(held.size(), 3)
	assert_true(_has(held, "flo_afl_3"))


# --- The things in the shop -------------------------------------------------------------------


func test_the_table_the_shelf_and_the_bunch_are_read_again_and_set_nothing() -> void:
	for cue: String in ["dried", "table", "shelf"]:
		var before := WorldState.state.flags.duplicate()
		var first := await DialogueWalk.play(FILE, cue)
		assert_gte(first.size(), 2, cue)
		assert_eq(await DialogueWalk.play(FILE, cue), first, "%s: the same twice" % cue)
		assert_eq(WorldState.state.flags, before, "%s sets nothing" % cue)


# --- Quests, journal and the feather ----------------------------------------------------------


func test_the_two_quests_and_the_help_stage_have_their_stages_and_texts() -> void:
	var duck := ContentDB.quest(DUCK)
	assert_not_null(duck)
	assert_eq(duck.first_stage().id, "look")
	assert_true(duck.can_advance("look", "done"))
	var letter := ContentDB.quest(LETTER)
	assert_not_null(letter)
	assert_eq(letter.first_stage().id, "listen")
	assert_true(letter.can_advance("listen", "done"))
	var way := ContentDB.quest("main_city_way")
	assert_true(way.can_advance("town", "help"))
	assert_false(way.stage("town").is_final(), "the town leads on")
	assert_true(way.stage("help").is_final(), "and this is as far as S3 goes")
	for key: String in [
		"QUEST_SIDE_CITY_DUCK_TITLE",
		"QUEST_SIDE_CITY_DUCK_LOOK",
		"QUEST_SIDE_CITY_DUCK_DONE",
		"QUEST_SIDE_CITY_LETTER_TITLE",
		"QUEST_SIDE_CITY_LETTER_LISTEN",
		"QUEST_SIDE_CITY_LETTER_DONE",
		"QUEST_MAIN_CITY_WAY_HELP",
		"MEMORY_ORIN_DUCK",
		"MEMORY_ORIN_LETTER",
	]:
		assert_ne(tr(key), key, key)


func test_the_feather_is_a_curiosity_with_a_picture_and_a_sentence() -> void:
	var item := ContentDB.item(FEATHER)
	assert_not_null(item)
	assert_eq(item.kind, ItemDef.Kind.CURIOSITY)
	assert_ne(tr("CURIOSITY_DUCK_FEATHER_NAME"), "CURIOSITY_DUCK_FEATHER_NAME")
	assert_ne(tr("CURIOSITY_DUCK_FEATHER_DESC"), "CURIOSITY_DUCK_FEATHER_DESC")
	assert_true(
		FileAccess.file_exists("res://assets/generated/items/curiosity_duck_feather.png"),
		"its picture"
	)
	assert_false(tr("CURIOSITY_DUCK_FEATHER_DESC").contains("Orin"), "the feather is the duck's")
