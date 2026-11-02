# gdlint: ignore=max-public-methods
extends GutTest
## Act IV, segment S2: the city and the town hall, told in their dialogue. A gate with a keeper who
## has a bad day, Mira at the fountain, the Gefällige at his board of slips, Lio in his corner, the
## rim of the fountain (a trace of the world), three stations of a perfect day that went another
## way, two shops that are shut, a goat on a roof; and in the town hall the clerk, the lost
## property office and the plan for the mayor's visit. The scenes (maps, walkers, beats) are
## tested in test_akt4_stadt_szene and test_akt4_rathaus_szene.

const STADT := "res://content/dialogue/akt4/stadt.dialogue"
const RATHAUS := "res://content/dialogue/akt4/rathaus.dialogue"
const RATHAUS_CUES: PackedStringArray = [
	"clerk",
	"clerk_again",
	"clerk_ask",
	"clerk_lost",
	"clerk_lost_pick",
	"clerk_lost_glove",
	"clerk_lost_key",
	"clerk_lost_buttons",
	"clerk_lost_cup",
	"clerk_lost_given",
	"clerk_day",
	"clerk_day_end",
]
const STADT_CUES: PackedStringArray = [
	"gate",
	"mira_square",
	"list_board",
	"gef_square",
	"gef_ask",
	"gef_again",
	"citizen_1",
	"lio_street",
	"lio_again",
	"fountain_rim",
	"day_wreath",
	"day_lectern",
	"day_table",
	"goat_roof",
]
const THINGS: PackedStringArray = [
	"curiosity_lost_glove",
	"curiosity_brass_key",
	"curiosity_button_tin",
	"curiosity_cracked_cup",
]


func before_each() -> void:
	WorldState.new_game()
	WorldState.set_ui_mode(GameState.UiMode.REAL)


func after_each() -> void:
	WorldState.new_game()


func _ids(path: String, prefix: String) -> PackedStringArray:
	var found: PackedStringArray = []
	var source := FileAccess.get_file_as_string(path)
	for hit in RegEx.create_from_string("\\[ID:(%s_[a-z0-9_]+)\\]" % prefix).search_all(source):
		found.append(hit.get_string(1))
	return found


func _cues(path: String) -> PackedStringArray:
	var names: PackedStringArray = []
	var source := FileAccess.get_file_as_string(path)
	for hit in RegEx.create_from_string("(?m)^~ ([a-z0-9_]+)$").search_all(source):
		names.append(hit.get_string(1))
	return names


func _has(seen: PackedStringArray, id: String) -> bool:
	return LineText.of(id) in seen


# --- The files -------------------------------------------------------------------------------


func test_the_two_files_tell_their_cues_in_draft_with_unique_ids() -> void:
	assert_eq(_cues(STADT), STADT_CUES, "the cues of the contract, in this order")
	assert_eq(_cues(RATHAUS), RATHAUS_CUES, "the clerk's twelve cues, in this order")
	for pair: Array in [[STADT, "stadt"], [RATHAUS, "rath"]]:
		var path: String = pair[0]
		var ids := _ids(path, pair[1])
		var unique := {}
		for id in ids:
			unique[id] = true
		assert_gt(ids.size(), 30, path)
		assert_eq(unique.size(), ids.size(), "no ID twice in " + path)
		var source := FileAccess.get_file_as_string(path)
		assert_eq(source.count("[#draft]"), ids.size(), "every line is a draft: " + path)
		assert_false(source.contains("[#ph]"), "no placeholder in a story file")


func test_the_voices_of_the_new_speakers_are_set() -> void:
	var voices: Dictionary = JSON.parse_string(
		FileAccess.get_file_as_string("res://content/dialogue/voices.json")
	)
	for who: String in ["Torwächterin", "Gefälliger", "Lio", "Beamtin", "Bürgerin", "Ziege"]:
		assert_true(voices.has(who), who)
		assert_true(voices[who] in ["elysia", "warm", "low", "neutral"], who)


# --- The city ------------------------------------------------------------------------------


func test_the_keeper_has_a_bad_day_and_lets_everyone_in() -> void:
	var before := WorldState.state.flags.duplicate()
	var answers := await DialogueWalk.answers(STADT, "gate")
	assert_eq(answers.size(), 2)
	assert_eq(answers[answers.size() - 1], "…", "the silence is the last answer")
	var about_goats := await DialogueWalk.play(STADT, "gate", PackedStringArray(["Ziegen"]))
	assert_gte(about_goats.size(), 6, "the keeper tells what does not go today and the goat")
	var silent := await DialogueWalk.play(STADT, "gate", PackedStringArray(["…"]))
	assert_gte(silent.size(), 3, "the silence is let in too")
	assert_eq(WorldState.state.flags, before, "the gate sets nothing: nobody is turned away")


func test_mira_waits_for_nothing_and_the_talk_changes_no_one() -> void:
	var before := WorldState.state.flags.duplicate()
	var groups := await DialogueWalk.groups(STADT, "mira_square")
	assert_eq(groups.size(), 1)
	assert_eq(groups[0].size(), 4)
	assert_eq(groups[0][3], "…", "the silence is the last answer")
	for pick: String in ["gewartet", "Stadt", "Ziege", "…"]:
		var seen := await DialogueWalk.play(STADT, "mira_square", PackedStringArray([pick]))
		assert_gte(seen.size(), 3, pick)
	assert_eq(WorldState.state.flags, before, "sets no flag")
	assert_true(
		WorldState.state.relationships.is_empty(), "no memory yet: the last variants are S7's"
	)


func test_the_board_is_the_gefaelliges_list_and_says_how_many_are_open() -> void:
	var seen := await DialogueWalk.play(STADT, "list_board")
	assert_eq(seen.size(), 4)
	var joined := " ".join(seen).to_lower()
	assert_true(joined.contains("sechzehn"), "sixteen are open, written out")
	assert_eq(await DialogueWalk.play(STADT, "list_board"), seen, "a board says the same twice")


func test_the_gefaellige_is_met_once_in_full_and_then_in_one_line() -> void:
	var first := await DialogueWalk.play(STADT, "gef_square")
	assert_gte(first.size(), 6)
	assert_true(WorldState.has_flag("city.gef_met"))
	var again := await DialogueWalk.play(STADT, "gef_square")
	assert_eq(again, PackedStringArray([LineText.of("stadt_gef_9")]), "one short line")
	var asks := await DialogueWalk.answers(STADT, "gef_ask")
	assert_eq(asks.size(), 2)
	assert_eq(asks[1], "…")


func test_the_gefaellige_gives_her_no_task_yet() -> void:
	# the list is S5's: here he only says he does not want to ask
	WorldState.set_ui_mode(GameState.UiMode.REAL)
	await DialogueWalk.play(STADT, "gef_square", PackedStringArray(["helfen"]))
	assert_eq(WorldState.state.quests.size(), 0, "no quest started")
	assert_eq(WorldState.state.inventory.size(), 0, "nothing given")


func test_lio_announces_and_plays_and_the_tune_is_a_melody_of_the_house() -> void:
	assert_false(WorldState.has_flag("melody.lio_street"))
	var first := await DialogueWalk.play(STADT, "lio_street")
	assert_true(_has(first, "stadt_lio_1"))
	assert_true(WorldState.has_flag("melody.lio_street"))
	assert_eq(Collection.melodies(), 1)
	var again := await DialogueWalk.play(STADT, "lio_street")
	assert_eq(again.size(), 1, "the second time one short line")
	assert_eq(Collection.melodies(), 1, "nothing counted twice")


func test_the_rim_of_the_fountain_is_a_trace_of_the_world() -> void:
	var first := await DialogueWalk.play(STADT, "fountain_rim")
	assert_eq(first.size(), 3)
	assert_true(WorldState.has_flag("fragment.fountain_rim"))
	assert_eq(Collection.fragments(), 1)
	assert_eq(
		await DialogueWalk.play(STADT, "fountain_rim"),
		PackedStringArray([LineText.of("stadt_rim_4")])
	)
	var joined := " ".join(first)
	for word: String in ["Kind", "Mutter", "Vater", "weil", "damals", "Grund"]:
		assert_false(joined.contains(word), "the rim gives no reason: " + word)


func test_each_station_of_the_perfect_day_is_read_again_and_sets_its_own_flag() -> void:
	var stations := {
		"day_wreath": "city.day_wreath",
		"day_lectern": "city.day_lectern",
		"day_table": "city.day_table",
	}
	for cue: String in stations:
		var first := await DialogueWalk.play(STADT, cue)
		assert_eq(first.size(), 2, cue)
		assert_true(WorldState.has_flag(stations[cue]), cue)
		assert_eq(await DialogueWalk.play(STADT, cue), first, "%s: the same twice" % cue)
	assert_false(WorldState.has_flag("melody.lio_street"), "the lute is Lio's alone")
	var allowed: Array = stations.values()
	for id: String in WorldState.state.flags:
		assert_true(id in allowed, "nothing is set but the three stations: " + id)


func test_the_goat_on_the_roof_says_nothing_anyone_can_use() -> void:
	var seen := await DialogueWalk.play(STADT, "goat_roof")
	assert_eq(seen.size(), 3)
	assert_true(" ".join(seen).contains("Mäh"))
	assert_eq(WorldState.state.flags.size(), 0, "no demand is explained, no flag set")


# --- The town hall ---------------------------------------------------------------------------


func test_the_clerk_hands_out_the_lost_things_one_by_one_and_ends_the_quest_with_the_last() -> void:
	var picks := PackedStringArray(
		["Ich suche etwas", "Handschuh", "Schlüssel", "Knöpfen", "Tasse"]
	)
	var seen := await DialogueWalk.play(RATHAUS, "clerk", picks)
	assert_true(_has(seen, "rath_clerk_1"), "the first time she is met in full")
	for id: String in THINGS:
		assert_true(WorldState.has_item(id), id)
	for flag: String in ["glove", "key", "buttons", "cup"]:
		assert_true(WorldState.has_flag("city.lost_" + flag), flag)
	assert_true(WorldState.is_quest_done("side_city_lost"), "the fourth thing ends the quest")
	assert_eq(Collection.curiosities(), 4)


func test_a_thing_that_is_taken_leaves_the_menu_and_leaving_costs_nothing() -> void:
	var picks := PackedStringArray(["Ich suche etwas", "Handschuh", "…"])
	await DialogueWalk.play(RATHAUS, "clerk", picks)
	assert_true(WorldState.has_item("curiosity_lost_glove"))
	assert_eq(WorldState.quest_stage("side_city_lost"), "ask", "one thing is not the quest")
	assert_false(WorldState.has_item("curiosity_brass_key"))
	# the next time the menu has three things and the silence
	var groups := await DialogueWalk.groups(
		RATHAUS, "clerk", PackedStringArray(["Ich suche etwas"])
	)
	var lost: PackedStringArray = groups[1]
	assert_eq(lost.size(), 4, "key, buttons, cup and the silence")
	assert_eq(lost[lost.size() - 1], "…")


func test_the_perfect_day_is_planned_by_the_clerk_and_ends_when_the_three_stations_are_seen(
) -> void:
	await DialogueWalk.play(RATHAUS, "clerk", PackedStringArray(["etwas zu tun"]))
	assert_eq(WorldState.quest_stage("side_city_day"), "plan")
	await DialogueWalk.play(STADT, "day_wreath")
	await DialogueWalk.play(STADT, "day_lectern")
	assert_eq(WorldState.quest_stage("side_city_day"), "plan", "two of three are not enough")
	await DialogueWalk.play(STADT, "day_table")
	assert_eq(WorldState.quest_stage("side_city_day"), "plan", "the stations do not end it")
	var seen := await DialogueWalk.play(RATHAUS, "clerk")
	assert_true(_has(seen, "rath_day_4"), "she sees the three and ends the day")
	assert_true(WorldState.is_quest_done("side_city_day"))


func test_whoever_sees_the_stations_before_the_plan_still_gets_the_end() -> void:
	for cue: String in ["day_wreath", "day_lectern", "day_table"]:
		await DialogueWalk.play(STADT, cue)
	await DialogueWalk.play(RATHAUS, "clerk")
	assert_true(WorldState.is_quest_done("side_city_day"), "the end starts the quest itself")


func test_the_clerk_uses_the_formal_you_and_never_a_familiar_form() -> void:
	var spoken := ""
	for line in FileAccess.get_file_as_string(RATHAUS).split("\n"):
		if line.contains("Beamtin:") and line.contains("[ID:rath_"):
			spoken += line + "\n"
	assert_true(spoken.contains("Sie "))
	var familiar := RegEx.create_from_string("(?i)\\b(du|dir|dich|dein\\w*)\\b")
	assert_null(familiar.search(spoken), "she says Sie to everyone")


# --- Quests, journal and things ---------------------------------------------------------


func test_the_quests_have_their_stages_and_their_journal() -> void:
	var lost := ContentDB.quest("side_city_lost")
	assert_eq(lost.first_stage().id, "ask")
	assert_true(lost.can_advance("ask", "done"))
	var day := ContentDB.quest("side_city_day")
	assert_eq(day.first_stage().id, "plan")
	assert_true(day.can_advance("plan", "done"))
	for key: String in [
		"QUEST_SIDE_CITY_LOST_TITLE",
		"QUEST_SIDE_CITY_LOST_ASK",
		"QUEST_SIDE_CITY_LOST_DONE",
		"QUEST_SIDE_CITY_DAY_TITLE",
		"QUEST_SIDE_CITY_DAY_PLAN",
		"QUEST_SIDE_CITY_DAY_DONE",
		"QUEST_MAIN_CITY_WAY_TOWN",
	]:
		assert_ne(tr(key), key, key)


func test_the_four_things_are_curiosities_with_a_picture_and_a_sentence() -> void:
	for id: String in THINGS:
		var item := ContentDB.item(id)
		assert_not_null(item, id)
		assert_eq(item.kind, ItemDef.Kind.CURIOSITY, id)
		assert_ne(tr(id.to_upper() + "_NAME"), id.to_upper() + "_NAME", id)
		assert_ne(tr(id.to_upper() + "_DESC"), id.to_upper() + "_DESC", id)
		assert_true(FileAccess.file_exists("res://assets/generated/items/%s.png" % id), id)
	assert_true(
		FileAccess.file_exists("res://assets/generated/fragments/fragment_fountain_rim.png")
	)
