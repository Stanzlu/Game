extends GutTest
## Act IV, segment S3: the florist. Orin looks like a warrior and keeps flowers; he fears a duck
## that behaves perfectly normally, and nothing explains why. He asks her to look, she tells
## him, and he either carries his peonies out into the light or leaves them inside (both end
## the quest, neither is better). Afterwards he shows her a bunch of dried peonies over his
## table and a letter without an address; she listens, holds the bunch or goes, and after it
## nothing is funny (the letter and the things in the shop: test_akt4_blumenladen_brief). The scene
## (map, walker, beats) is tested in test_akt4_blumenladen_szene,
## the door and the duck in the city in test_akt4_stadt_szene.

const FILE := "res://content/dialogue/akt4/blumenladen.dialogue"
const CUES: PackedStringArray = [
	"orin",
	"orin_ask",
	"orin_ask_again",
	"orin_take",
	"orin_decline",
	"orin_wait",
	"duck",
	"duck_again",
	"duck_feather",
	"orin_report",
	"orin_after",
	"orin_letter",
	"orin_after_letter",
	"dried",
	"table",
	"shelf",
]
const DUCK := "side_city_duck"
const FEATHER := "curiosity_duck_feather"


func before_each() -> void:
	WorldState.new_game()
	WorldState.set_ui_mode(GameState.UiMode.REAL)


func after_each() -> void:
	WorldState.new_game()


func _ids() -> PackedStringArray:
	var found: PackedStringArray = []
	var source := FileAccess.get_file_as_string(FILE)
	for hit in RegEx.create_from_string("\\[ID:(flo_[a-z0-9_]+)\\]").search_all(source):
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


## She has been sent and has seen the duck: the state in which Orin hears the report.
func _sent_and_seen() -> void:
	WorldState.start_quest(DUCK)
	WorldState.set_flag("city.orin_met")
	WorldState.set_flag("city.duck_seen")


## The duck is settled (the pots are out when `passed`, inside when not).
func _duck_done(passed: bool) -> void:
	_sent_and_seen()
	WorldState.advance_quest(DUCK, "done")
	WorldState.set_flag("city.duck_passed" if passed else "city.duck_stayed")


# --- The file ---------------------------------------------------------------------------------


func test_the_file_tells_sixteen_cues_in_draft_with_unique_ids() -> void:
	var source := FileAccess.get_file_as_string(FILE)
	var names: PackedStringArray = []
	for hit in RegEx.create_from_string("(?m)^~ ([a-z0-9_]+)$").search_all(source):
		names.append(hit.get_string(1))
	assert_eq(names, CUES, "the cues of the contract, in this order")
	var ids := _ids()
	assert_eq(ids.size(), 78, "sixty-three lines and fifteen answers")
	var unique := {}
	for id in ids:
		unique[id] = true
	assert_eq(unique.size(), ids.size(), "no ID twice")
	assert_eq(source.count("[#draft]"), ids.size(), "every line is a draft")
	assert_false(source.contains("[#ph]"), "no placeholder in a story file")


func test_the_speakers_are_orin_and_the_narrator() -> void:
	var source := FileAccess.get_file_as_string(FILE)
	for hit in RegEx.create_from_string("(?m)^\\s*([A-ZÄÖÜ][a-zäöüß]+): ").search_all(source):
		assert_eq(hit.get_string(1), "Orin", "only one person speaks in this file")


# --- The request ------------------------------------------------------------------------------


func test_the_first_meeting_introduces_him_asks_and_moves_the_walk_on() -> void:
	WorldState.start_quest("main_city_way")
	WorldState.advance_quest("main_city_way", "town")
	var seen := await DialogueWalk.play(FILE, "orin", PackedStringArray(["Ich sehe nach"]))
	for id in ["flo_orin_1", "flo_orin_3", "flo_orin_6", "flo_orin_9"]:
		assert_true(_has(seen, id), id)
	assert_true(WorldState.has_flag("city.orin_met"))
	assert_eq(WorldState.relationship_state("orin"), "cautious")
	assert_eq(WorldState.quest_stage("main_city_way"), "help", "the city begins to offer things")
	assert_true(WorldState.is_quest_started(DUCK))
	assert_eq(WorldState.quest_stage(DUCK), "look")


func test_the_walk_moves_on_only_from_the_town() -> void:
	# a game that skipped the town's stage (a saved state, a debug start) is not pushed back
	WorldState.start_quest("main_city_way")
	await DialogueWalk.play(FILE, "orin", PackedStringArray(["Ich sehe nach"]))
	assert_eq(WorldState.quest_stage("main_city_way"), "west", "the stage was not 'town'")


func test_why_is_not_answered_and_the_request_stands_again() -> void:
	var answers := await DialogueWalk.answers(FILE, "orin")
	assert_eq(answers.size(), 3, "I look, why, silence")
	assert_eq(answers[answers.size() - 1], "…", "the silence is the last answer")
	var seen := await DialogueWalk.play(FILE, "orin", PackedStringArray(["Warum", "Ich sehe nach"]))
	assert_true(_has(seen, "flo_orin_7"), "he says there is no good answer")
	assert_true(_has(seen, "flo_orin_8"), "and asks again, without the question")
	assert_true(WorldState.is_quest_started(DUCK), "the second answer took it")
	var orin := _said_by("Orin")
	for word: String in ["Trauma", "damals", "als Kind", "gebissen", "Erlebnis", "Angst"]:
		assert_false(orin.contains(word), "nothing explains the duck: " + word)


func test_silence_takes_nothing_and_he_asks_again_at_the_next_visit() -> void:
	var seen := await DialogueWalk.play(FILE, "orin", PackedStringArray(["…"]))
	assert_true(_has(seen, "flo_orin_11"))
	assert_false(WorldState.is_quest_started(DUCK))
	assert_true(WorldState.has_flag("city.orin_met"), "they know each other now")
	var again := await DialogueWalk.play(FILE, "orin", PackedStringArray(["Ich sehe nach"]))
	assert_true(_has(again, "flo_orin_8"), "the request, without the introduction")
	assert_false(_has(again, "flo_orin_1"))
	assert_true(WorldState.is_quest_started(DUCK))


func test_while_she_has_not_seen_the_duck_he_reminds_her_in_one_line() -> void:
	WorldState.start_quest(DUCK)
	WorldState.set_flag("city.orin_met")
	var seen := await DialogueWalk.play(FILE, "orin")
	assert_eq(seen, PackedStringArray([LineText.of("flo_orin_12")]))


# --- The duck ---------------------------------------------------------------------------------


func test_the_duck_is_seen_once_in_full_and_sets_the_flag_orin_reads() -> void:
	var first := await DialogueWalk.play(FILE, "duck", PackedStringArray(["Liegen lassen"]))
	assert_true(_has(first, "flo_duck_1") and _has(first, "flo_duck_3"))
	assert_true(WorldState.has_flag("city.duck_seen"))
	var again := await DialogueWalk.play(FILE, "duck", PackedStringArray(["Liegen lassen"]))
	assert_true(_has(again, "flo_duck_4"), "a short line")
	assert_false(_has(again, "flo_duck_1"))


func test_the_feather_can_be_taken_once_or_left() -> void:
	assert_eq((await DialogueWalk.answers(FILE, "duck")).size(), 2, "take it or leave it")
	await DialogueWalk.play(FILE, "duck", PackedStringArray(["Liegen lassen"]))
	assert_false(WorldState.has_item(FEATHER))
	assert_false(WorldState.has_flag("city.feather_taken"))
	var taken := await DialogueWalk.play(FILE, "duck", PackedStringArray(["Aufheben"]))
	assert_true(_has(taken, "flo_duck_6"))
	assert_true(WorldState.has_item(FEATHER))
	assert_true(WorldState.has_flag("city.feather_taken"))
	var later := await DialogueWalk.play(FILE, "duck")
	assert_false(_has(later, "flo_duck_5"), "the feather is gone from the stones")
	assert_eq(
		(await DialogueWalk.answers(FILE, "duck")).size(), 0, "nothing to pick up a second time"
	)


func test_the_duck_is_never_a_character_and_makes_no_joke() -> void:
	var duck := ""
	for cue: String in ["duck", "duck_again"]:
		for line in await DialogueWalk.play(FILE, cue, PackedStringArray(["Liegen lassen"])):
			duck += line + "\n"
	for word: String in ["Quak", "quak", "Orin", "Angst", "Feind", "Erzfeind", "lach"]:
		assert_false(duck.contains(word), "the duck is just a duck: " + word)


# --- The report -------------------------------------------------------------------------------


func test_the_report_ends_the_quest_with_the_pots_out_when_she_stands_beside_him() -> void:
	_sent_and_seen()
	var answers := await DialogueWalk.answers(FILE, "orin")
	assert_eq(answers.size(), 3, "beside him, inside, silence")
	assert_eq(answers[2], "…", "the silence is the last answer")
	var seen := await DialogueWalk.play(FILE, "orin", PackedStringArray(["Ich stehe neben dir"]))
	assert_true(_has(seen, "flo_rep_3"), "the one line he had already")
	assert_true(_has(seen, "flo_rep_7"))
	assert_true(WorldState.has_flag("city.duck_passed"))
	assert_false(WorldState.has_flag("city.duck_stayed"))
	assert_eq(WorldState.quest_stage(DUCK), "done")
	assert_true(WorldState.has_memory("orin", "duck"))


func test_the_report_ends_the_quest_just_as_well_when_the_pots_stay_inside() -> void:
	_sent_and_seen()
	var seen := await DialogueWalk.play(FILE, "orin", PackedStringArray(["Lass sie drinnen"]))
	assert_true(_has(seen, "flo_rep_9"))
	assert_true(WorldState.has_flag("city.duck_stayed"))
	assert_false(WorldState.has_flag("city.duck_passed"))
	assert_eq(WorldState.quest_stage(DUCK), "done", "an ending as well as the other")
	assert_true(WorldState.has_memory("orin", "duck"))
	var orin := _said_by("Orin")
	for word: String in ["mutig", "feige", "stolz", "schwach", "besser"]:
		assert_false(orin.contains(word), "neither ending is graded: " + word)


func test_silence_after_the_report_is_a_postponement_and_sets_nothing() -> void:
	_sent_and_seen()
	var flags_before := WorldState.state.flags.duplicate()
	var seen := await DialogueWalk.play(FILE, "orin", PackedStringArray(["…"]))
	assert_true(_has(seen, "flo_rep_11"))
	assert_eq(WorldState.quest_stage(DUCK), "look")
	assert_eq(WorldState.state.flags, flags_before)
	assert_false(WorldState.has_memory("orin", "duck"))


# --- After the duck ---------------------------------------------------------------------------


func test_afterwards_he_says_one_light_line_for_each_ending() -> void:
	_duck_done(true)
	var passed := await DialogueWalk.play(FILE, "orin", PackedStringArray(["…"]))
	assert_true(_has(passed, "flo_aft_1"))
	assert_false(_has(passed, "flo_aft_2"))
	WorldState.new_game()
	_duck_done(false)
	var stayed := await DialogueWalk.play(FILE, "orin", PackedStringArray(["…"]))
	assert_true(_has(stayed, "flo_aft_2"))
	assert_false(_has(stayed, "flo_aft_1"))


func test_the_bunch_over_the_table_is_offered_beside_the_silence() -> void:
	_duck_done(true)
	var answers := await DialogueWalk.answers(FILE, "orin")
	assert_eq(answers.size(), 2)
	assert_eq(answers[answers.size() - 1], "…", "the silence is the last answer")
