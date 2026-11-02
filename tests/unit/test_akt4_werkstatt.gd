extends GutTest
## Act IV, segment S4: the workshop. Tess is an older craftswoman, direct and warm in what she
## does, no oracle: she measures, whistles, shows it once and then it is the visitor's turn. At
## the bench the player asks for help of her own will for the first time (the facet
## "connection"): Tess holds the board, or the player holds it herself, and the board comes out
## crooked either way. Afterwards Tess sits on her crate before the workshop and says one thing,
## "Setz dich" ("Nichts", Bible §44). The scenes (the room, the bench, the sitting) are tested in
## test_akt4_werkstatt_szene and test_akt4_stadt_szene.

const FILE := "res://content/dialogue/akt4/werkstatt.dialogue"
const CUES: PackedStringArray = [
	"tess",
	"tess_offer",
	"tess_offer_again",
	"tess_quiet",
	"tess_saw",
	"tess_done",
	"tess_again",
	"bench",
	"tess_after",
	"nothing",
	"nothing_again",
	"saws",
	"ladder",
	"dust",
	"board",
]
const BOARD := "curiosity_crooked_board"


func before_each() -> void:
	WorldState.new_game()
	WorldState.set_ui_mode(GameState.UiMode.REAL)


func after_each() -> void:
	WorldState.new_game()


func _ids() -> PackedStringArray:
	var found: PackedStringArray = []
	var source := FileAccess.get_file_as_string(FILE)
	for hit in RegEx.create_from_string("\\[ID:(wer_[a-z0-9_]+)\\]").search_all(source):
		found.append(hit.get_string(1))
	return found


func _has(seen: PackedStringArray, id: String) -> bool:
	return LineText.of(id) in seen


## The speech of one speaker in the file (the lines that start with `who:`), for word checks.
func _said_by(who: String) -> String:
	var spoken := ""
	for hit in RegEx.create_from_string("(?m)^\\s*%s: (.*)\\[ID:" % who).search_all(
		FileAccess.get_file_as_string(FILE)
	):
		spoken += hit.get_string(1) + "\n"
	return spoken


## Everything the file says in its lines and answers (not its comments), for word checks.
func _all_text() -> String:
	var spoken := ""
	for hit in (
		RegEx
		. create_from_string("(?m)^[ \\t]*(?:- )?([^#\\n][^\\n]*?)[ \\t]*\\[ID:wer_")
		. search_all(FileAccess.get_file_as_string(FILE))
	):
		spoken += hit.get_string(1) + "\n"
	return spoken


## She has met Tess (the introduction is over).
func _met() -> void:
	WorldState.set_flag("city.tess_met")


# --- The file ---------------------------------------------------------------------------------


func test_the_file_tells_fifteen_cues_in_draft_with_unique_ids() -> void:
	var source := FileAccess.get_file_as_string(FILE)
	var names: PackedStringArray = []
	for hit in RegEx.create_from_string("(?m)^~ ([a-z0-9_]+)$").search_all(source):
		names.append(hit.get_string(1))
	assert_eq(names, CUES, "the cues of the contract, in this order")
	var ids := _ids()
	assert_eq(ids.size(), 68, "fifty-six lines and twelve answers")
	var unique := {}
	for id in ids:
		unique[id] = true
	assert_eq(unique.size(), ids.size(), "no ID twice")
	assert_eq(source.count("[#draft]"), ids.size(), "every line is a draft")
	assert_false(source.contains("[#ph]"), "no placeholder in a story file")


func test_tess_speaks_short_and_never_an_oracle_or_a_feeling() -> void:
	var source := FileAccess.get_file_as_string(FILE)
	var speakers := RegEx.create_from_string("(?m)^\\s*([A-ZÄÖÜ][a-zäöüß]+): ").search_all(source)
	assert_gt(speakers.size(), 15, "Tess speaks in many lines")
	for hit in speakers:
		assert_eq(hit.get_string(1), "Tess", "only one person speaks in this file")
	var tess := _said_by("Tess")
	assert_gt(tess.length(), 600, "all of her speech is read")
	for word: String in [
		"Gefühl",
		"Leben",
		"Weisheit",
		"stärker",
		"Mut",
		"Wachstum",
		"du schaffst",
		"Ich mach das schon",
		"wunderbar",
	]:
		assert_false(tess.contains(word), "she is no oracle and no cheerleader: " + word)
	for line in tess.split("\n", false):
		assert_lt(line.split(" ", false).size(), 30, "kurz: " + line)


func test_nothing_in_the_sitting_teaches_a_lesson_about_rest() -> void:
	var all := _all_text()
	assert_gt(all.length(), 4000, "the whole text of the workshop is read")
	var sitting := ""
	for cue: String in ["bench", "tess_after", "nothing", "nothing_again"]:
		for line in await DialogueWalk.play(FILE, cue):
			sitting += line + "\n"
	for word: String in [
		"Ruhe", "Pause", "Frieden", "Stille", "Gefühl", "Kraft", "Erholung", "tut gut"
	]:
		assert_false(sitting.contains(word), "the sitting is only a sitting: " + word)


# --- The introduction and the offer -----------------------------------------------------------


func test_the_first_meeting_has_her_measure_whistle_and_offer_a_board() -> void:
	var seen := await DialogueWalk.play(FILE, "tess", PackedStringArray(["…"]))
	for id: String in [
		"wer_tess_1", "wer_tess_3", "wer_tess_6", "wer_tess_10", "wer_offer_1", "wer_quiet_1"
	]:
		assert_true(_has(seen, id), id)
	assert_true(WorldState.has_flag("city.tess_met"))
	assert_true(WorldState.has_flag("melody.tess_whistle"), "she whistles: the scene plays it")
	assert_eq(WorldState.relationship_state("tess"), "cautious")
	assert_false(WorldState.has_flag("city.board_done"), "the silence takes no board")
	assert_false(
		_said_by("Tess").contains("Tess"), "her name is on the folding rule, not in her mouth"
	)


func test_why_a_board_gets_material_and_the_offer_stands_again() -> void:
	var seen := await DialogueWalk.play(FILE, "tess", PackedStringArray(["Warum", "…"]))
	assert_true(_has(seen, "wer_offer_2"), "wood, not meaning")
	assert_true(_has(seen, "wer_offer_3"), "and the offer again")
	assert_false(WorldState.has_flag("city.board_done"))


func test_back_without_having_sawn_she_offers_it_again_shorter() -> void:
	_met()
	var seen := await DialogueWalk.play(FILE, "tess", PackedStringArray(["…"]))
	assert_false(_has(seen, "wer_tess_1"), "no second introduction")
	assert_true(_has(seen, "wer_offer_3"))
	assert_true(_has(seen, "wer_quiet_1"))


# --- The sawing: asking for help --------------------------------------------------------------


func test_asking_her_to_hold_the_board_sets_the_facet_and_the_flag_and_gives_the_board() -> void:
	_met()
	assert_false(WorldState.has_facet("connection"))
	var seen := await DialogueWalk.play(
		FILE, "tess", PackedStringArray(["Zeig's mir", "Hältst du das Brett"])
	)
	assert_true(_has(seen, "wer_saw_5"), "she holds it, without a word")
	assert_true(_has(seen, "wer_done_2"), "That is crooked. It stands, though. Take it.")
	assert_true(WorldState.has_facet("connection"))
	assert_true(WorldState.has_flag("city.asked_help"))
	assert_true(WorldState.has_flag("city.board_done"))
	assert_true(WorldState.has_item(BOARD))
	assert_true(WorldState.has_memory("tess", "board"))
	assert_eq(WorldState.relationship_state("tess"), "familiar")


func test_holding_it_herself_gives_the_same_board_and_the_same_line_without_the_facet() -> void:
	_met()
	var seen := await DialogueWalk.play(
		FILE, "tess", PackedStringArray(["Zeig's mir", "Ich halte es selbst"])
	)
	assert_true(_has(seen, "wer_saw_9"), "a handgrip, not a verdict")
	assert_true(_has(seen, "wer_done_2"), "the same line for the same board")
	assert_false(WorldState.has_facet("connection"))
	assert_false(WorldState.has_flag("city.asked_help"))
	assert_true(WorldState.has_flag("city.board_done"), "one way is as good as the other")
	assert_true(WorldState.has_item(BOARD))
	assert_true(WorldState.has_memory("tess", "board"))
	var all := _said_by("Tess")
	for word: String in ["gut gemacht", "Respekt", "richtig so", "besser", "falsch"]:
		assert_false(all.contains(word), "neither way is graded: " + word)


func test_the_silence_at_the_saw_leaves_the_board_unsawn_and_sets_nothing() -> void:
	_met()
	var before := WorldState.state.flags.duplicate()
	var seen := await DialogueWalk.play(FILE, "tess", PackedStringArray(["Zeig's mir", "…"]))
	assert_true(_has(seen, "wer_saw_10"))
	assert_eq(WorldState.state.flags, before)
	assert_false(WorldState.has_item(BOARD))
	assert_false(WorldState.has_facet("connection"))


func test_the_help_is_asked_of_her_own_will_and_nobody_offers_it() -> void:
	_met()
	var groups := await DialogueWalk.groups(FILE, "tess", PackedStringArray(["Zeig's mir", "…"]))
	assert_eq(groups.size(), 2, "the offer and the sawing")
	assert_eq(groups[1].size(), 3, "hold it, I hold it, silence")
	assert_eq(groups[1][2], "…", "the silence is the last answer")
	var all := _said_by("Tess")
	for word: String in ["Brauchst du Hilfe", "Frag mich", "Du kannst mich fragen", "Hilfe"]:
		assert_false(all.contains(word), "she does not offer it: " + word)
