# gdlint: ignore=max-public-methods
extends GutTest
## Act IV, segment S6: Lio's worst concert in the world (docs/akt4/REGIONSBRIEFE.md, O10). The
## invitation is in the city's file, the evening in `konzert.dialogue`: nine parts that the scene
## plays in turn (the string breaks, the lamp tilts, the entry goes to people who are not there,
## the goat, the wind, the tune) and the lines of the people and things afterwards. The jokes aim
## at the process and never at a person; the text says neither that it was good nor that it was
## bad, it shows that nobody goes. The scene (the evening look, the lights, the crowd, the order of
## the parts) is tested in test_akt4_konzert_szene.

const FILE := "res://content/dialogue/akt4/konzert.dialogue"
const CITY := "res://content/dialogue/akt4/stadt.dialogue"
const CUES: PackedStringArray = [
	"arrive",
	"intro",
	"snap",
	"hold",
	"goat",
	"entry",
	"wind",
	"song",
	"finale",
	"con_lio",
	"con_lio_gift",
	"con_lio_again",
	"con_goat",
	"con_orin",
	"con_gef",
	"con_mira",
	"con_scratch",
	"con_poster",
	"con_poster_pick",
	"con_poster_again",
]
const STRING := "curiosity_snapped_string"
const POSTER := "curiosity_concert_poster"


func before_each() -> void:
	WorldState.new_game()
	WorldState.set_ui_mode(GameState.UiMode.REAL)


func after_each() -> void:
	WorldState.new_game()


func _has(seen: PackedStringArray, id: String) -> bool:
	return LineText.of(id) in seen


func _source() -> String:
	return FileAccess.get_file_as_string(FILE)


## The cue blocks of the file: name -> text.
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


## Everything the file says in its lines and answers (not its comments), for word checks.
func _all_text() -> String:
	var spoken := ""
	for hit in (
		RegEx
		. create_from_string("(?m)^[ \\t]*(?:- )?([^#\\n][^\\n]*?)[ \\t]*\\[ID:kon_")
		. search_all(_source())
	):
		spoken += hit.get_string(1) + "\n"
	return spoken


## What one speaker says in the file.
func _said_by(who: String) -> String:
	var spoken := ""
	for hit in RegEx.create_from_string("(?m)^\\s*%s: (.*)\\[ID:" % who).search_all(_source()):
		spoken += hit.get_string(1) + "\n"
	return spoken


# --- The file ---------------------------------------------------------------------------------


func test_the_file_tells_its_cues_in_draft_with_unique_ids_within_the_budget() -> void:
	var names: PackedStringArray = []
	for hit in RegEx.create_from_string("(?m)^~ ([a-z0-9_]+)$").search_all(_source()):
		names.append(hit.get_string(1))
	assert_eq(names, CUES, "the cues of the contract, in this order")
	var ids: PackedStringArray = []
	var lines := 0
	for hit in RegEx.create_from_string("\\[ID:(kon_[a-z0-9_]+)\\]").search_all(_source()):
		ids.append(hit.get_string(1))
		if not RegEx.create_from_string("_r\\d+$").search(hit.get_string(1)):
			lines += 1
	var unique := {}
	for id in ids:
		unique[id] = true
	assert_eq(unique.size(), ids.size(), "no ID twice")
	assert_eq(_source().count("[#draft]"), ids.size(), "every line is a draft")
	assert_false(_source().contains("[#ph]"), "no placeholder in a story file")
	# the budget of the segment: 55 planned, 65 at the most (with the five lines of the invitation)
	assert_lte(lines + 5, 65, "the lines of the segment")
	assert_gte(lines, 50, "and the evening has its lines")


func test_the_jokes_aim_at_the_process_and_nobody_is_praised_or_belittled() -> void:
	var all := _all_text()
	assert_gt(all.length(), 4000, "the whole text is read")
	for word: String in [
		"Bravo",
		"Held",
		"Zauberin",
		"heilt",
		"Heilung",
		"Therapie",
		"Gefühl",
		"Versager",
		"unfähig",
		"peinlich",
		"dumm",
		"Verbindung",
		"Nähe",
		"Freiheit",
		"Ruhe",
	]:
		assert_false(all.contains(word), "no %s in the concert" % word)
	var lio := _said_by("Lio")
	assert_gt(lio.length(), 500, "all of his speech is read")
	for line in lio.split("\n", false):
		assert_lt(line.split(" ", false).size(), 40, "kurz: " + line)
	assert_false(_said_by("Mira").contains("Liste"), "Mira says nothing of the list")


func test_nothing_tells_whether_it_was_good_or_bad() -> void:
	var told := ""
	for cue: String in ["song", "finale"]:
		for line in await DialogueWalk.play(FILE, cue):
			told += line + "\n"
	for word: String in [
		"gut gespielt", "schön", "schlecht gespielt", "wunderbar", "grandios", "furchtbar"
	]:
		assert_false(told.contains(word), "the song is shown, not judged: " + word)


func test_a_choice_and_its_reader_are_never_in_the_same_cue() -> void:
	var setter := RegEx.create_from_string('set_flag\\("([a-z_.]+)"')
	var reader := RegEx.create_from_string('has_flag\\("([a-z_.]+)"')
	var blocks := _blocks()
	for cue: String in blocks:
		var text: String = blocks[cue]
		var sets := {}
		for hit in setter.search_all(text):
			sets[hit.get_string(1)] = true
		for hit in reader.search_all(text):
			var flag := hit.get_string(1)
			# the fragment guards itself, like the fountain's rim in the city's file
			if flag == "fragment.stage_scratch":
				continue
			assert_false(sets.has(flag), "%s sets and reads %s" % [cue, flag])


# --- The parts of the evening ---------------------------------------------------------------


func test_the_stage_is_told_honestly_by_what_she_did_on_the_list() -> void:
	var built := false
	for done: bool in [false, true]:
		WorldState.new_game()
		if done:
			WorldState.set_flag("list.done_stage")
		var seen := await DialogueWalk.play(FILE, "arrive")
		assert_true(_has(seen, "kon_arr_1"), "the square, the lanterns, the bread")
		assert_eq(_has(seen, "kon_arr_2"), done, "her nails only if she drove them")
		assert_eq(_has(seen, "kon_arr_3"), not done, "else: somebody saved on nails")
		built = built or done
	assert_true(built)


func test_the_string_breaks_on_the_line_that_tells_it_and_lio_plays_on() -> void:
	var seen := await DialogueWalk.play(FILE, "snap")
	assert_eq(seen.size(), 4)
	assert_true(WorldState.has_flag("city.string_snapped"), "the scene plays the sound with it")
	var block: String = _blocks()["snap"]
	# a mutation runs when its line is asked for: the flag stands before the line that tells it
	assert_lt(block.find("kon_snap_1"), block.find("city.string_snapped"), "after the first line")
	assert_lt(
		block.find("city.string_snapped"),
		block.find("kon_snap_2"),
		"and with the line of the break"
	)


func test_the_lamp_is_held_by_her_by_lio_or_by_orin_if_she_asks_him() -> void:
	WorldState.set_flag("city.orin_met")
	var plain := await DialogueWalk.answers(FILE, "hold")
	assert_eq(plain.size(), 2, "the facet is not there: hold it, or say nothing")
	assert_eq(plain[1], "…", "the silence is the last answer")
	# the facet alone is not enough: whoever has never met him calls no stranger by his name
	WorldState.new_game()
	WorldState.set_facet("connection")
	assert_eq((await DialogueWalk.answers(FILE, "hold")).size(), 2)
	WorldState.set_flag("city.orin_met")
	var asked := await DialogueWalk.answers(FILE, "hold")
	assert_eq(asked.size(), 3, "hold it, ask him, say nothing")
	assert_true(asked[1].contains("Orin"))
	assert_eq(asked[2], "…")


func test_asking_orin_sets_the_flag_the_map_reads_and_the_other_ways_set_nothing() -> void:
	WorldState.set_facet("connection")
	WorldState.set_flag("city.orin_met")
	var asked := await DialogueWalk.play(FILE, "hold", PackedStringArray(["Orin"]))
	assert_true(_has(asked, "kon_hold_4") and _has(asked, "kon_hold_5"))
	assert_true(WorldState.has_flag("city.stage_orin"), "he stands at the post afterwards")
	var all := _said_by("Orin")
	for word: String in ["Hilfe", "danke", "Freund", "zusammen"]:
		assert_false(all.contains(word), "he holds, he does not say what it means: " + word)
	for pick: String in ["Ich halte", "…"]:
		WorldState.new_game()
		WorldState.set_facet("connection")
		WorldState.set_flag("city.orin_met")
		var before := WorldState.state.flags.duplicate()
		var seen := await DialogueWalk.play(FILE, "hold", PackedStringArray([pick]))
		assert_false(WorldState.has_flag("city.stage_orin"), pick)
		assert_eq(WorldState.state.flags, before, "%s sets nothing" % pick)
		assert_true(_has(seen, "kon_hold_3") or _has(seen, "kon_hold_6"), "the lamp stands")


func test_the_song_sets_the_melody_the_memory_and_the_bond_and_tess_is_there_only_with_the_board(
) -> void:
	var seen := await DialogueWalk.play(FILE, "song")
	assert_true(WorldState.has_flag("melody.lio_concert"), "the scene plays the tune with it")
	assert_true(Collection.has_melody("lio_concert"))
	assert_true(WorldState.has_memory("lio", "concert"))
	assert_eq(WorldState.relationship_state("lio"), "familiar")
	assert_false(_has(seen, "kon_song_4"), "Tess is not there: the board was not sawn")
	for id: String in ["kon_song_1", "kon_song_2", "kon_song_3", "kon_song_5", "kon_song_6"]:
		assert_true(_has(seen, id), id)
	WorldState.new_game()
	WorldState.set_flag("city.board_done")
	assert_true(
		_has(await DialogueWalk.play(FILE, "song"), "kon_song_4"), "she claps beside the beat"
	)


func test_the_goat_the_entry_the_wind_and_the_finale_set_nothing() -> void:
	for cue: String in ["intro", "goat", "entry", "wind", "finale"]:
		var before := WorldState.state.flags.duplicate()
		var seen := await DialogueWalk.play(FILE, cue)
		assert_gte(seen.size(), 2, cue)
		assert_eq(WorldState.state.flags, before, "%s sets nothing" % cue)
	assert_false(_said_by("Ziege").contains("Ziege"), "the goat says its own sounds, no more")


# --- Afterwards: the people and things of the evening -------------------------------------------


func test_lio_gives_her_the_string_and_either_answer_is_as_good_as_the_other() -> void:
	var answers := await DialogueWalk.answers(FILE, "con_lio")
	assert_eq(answers.size(), 2, "keep it, or leave it")
	var kept := await DialogueWalk.play(FILE, "con_lio", PackedStringArray(["Einstecken"]))
	assert_true(_has(kept, "kon_lio_3"))
	assert_true(WorldState.has_item(STRING))
	assert_true(WorldState.has_flag("city.string_taken"))
	assert_true(
		_has(await DialogueWalk.play(FILE, "con_lio"), "kon_lioa_1"), "he asks nothing again"
	)
	WorldState.new_game()
	var left := await DialogueWalk.play(FILE, "con_lio", PackedStringArray(["Lass nur"]))
	assert_true(_has(left, "kon_lio_4"))
	assert_false(WorldState.has_item(STRING))
	assert_true(WorldState.has_flag("city.string_left"))
	assert_true(_has(await DialogueWalk.play(FILE, "con_lio"), "kon_lioa_2"))


func test_the_poster_can_be_taken_or_left_and_is_the_same_either_way() -> void:
	assert_eq((await DialogueWalk.answers(FILE, "con_poster")).size(), 2)
	var taken := await DialogueWalk.play(FILE, "con_poster", PackedStringArray(["Abnehmen"]))
	assert_true(_has(taken, "kon_post_3"))
	assert_true(WorldState.has_item(POSTER))
	assert_true(_has(await DialogueWalk.play(FILE, "con_poster"), "kon_posta_1"))
	WorldState.new_game()
	var left := await DialogueWalk.play(FILE, "con_poster", PackedStringArray(["Hängen lassen"]))
	assert_true(_has(left, "kon_post_4"))
	assert_false(WorldState.has_item(POSTER))
	assert_true(_has(await DialogueWalk.play(FILE, "con_poster"), "kon_posta_2"))
	var poster := RegEx.create_from_string("\\[[^\\]]*\\]").sub(
		_blocks()["con_poster_pick"] as String, "", true
	)
	var digits := RegEx.create_from_string("\\d").search(poster)
	assert_null(digits, "no digit on the poster")


func test_the_old_board_is_a_trace_of_the_world_once_and_a_short_line_after() -> void:
	var first := await DialogueWalk.play(FILE, "con_scratch")
	assert_eq(first.size(), 3)
	assert_true(WorldState.has_flag("fragment.stage_scratch"))
	assert_eq(Collection.fragments(), 1)
	assert_eq(
		await DialogueWalk.play(FILE, "con_scratch"), PackedStringArray([LineText.of("kon_scr_4")])
	)
	assert_eq(Collection.fragments(), 1, "nothing counted twice")
	var told := ""
	for line in first:
		told += line
	for word: String in ["Kind", "Mutter", "Vater", "weil", "damals", "Grund"]:
		assert_false(told.contains(word), "the board gives no reason: " + word)


func test_orin_tells_something_concrete_and_nothing_funny_after_the_letter() -> void:
	var held := await DialogueWalk.play(FILE, "con_orin")
	assert_false(_has(held, "kon_orin_1"), "in the crowd, the lamp is not his")
	assert_true(_has(held, "kon_orin_4"), "the duck was not invited")
	WorldState.set_flag("city.stage_orin")
	var post := await DialogueWalk.play(FILE, "con_orin")
	assert_true(_has(post, "kon_orin_1") and _has(post, "kon_orin_2"))
	WorldState.new_game()
	WorldState.set_flag("city.letter_told")
	var quiet := await DialogueWalk.play(FILE, "con_orin")
	assert_true(_has(quiet, "kon_orin_5"))
	assert_false(_has(quiet, "kon_orin_4"), "after the letter no joke about the duck")
	for line in quiet:
		assert_false(line.contains("Ente"), line)


func test_the_goat_and_the_gefaellige_set_nothing() -> void:
	for cue: String in ["con_goat", "con_gef"]:
		var before := WorldState.state.flags.duplicate()
		var seen := await DialogueWalk.play(FILE, cue)
		assert_gte(seen.size(), 2, cue)
		assert_eq(WorldState.state.flags, before, "%s sets nothing" % cue)
		assert_eq(await DialogueWalk.play(FILE, cue), seen, "%s: the same twice" % cue)
	assert_false(_blocks()["con_gef"].contains("Entschuldigung"), "he does not apologise")


func test_mira_says_she_goes_to_the_gate_and_that_is_all_she_sets() -> void:
	WorldState.start_quest("main_city_way")
	for stage: String in ["town", "help", "list", "evening"]:
		WorldState.advance_quest("main_city_way", stage)
	var before := WorldState.state.flags.duplicate()
	var seen := await DialogueWalk.play(FILE, "con_mira")
	assert_eq(seen.size(), 3)
	assert_true(_has(seen, "kon_mira_3"), "from the gate one sees when it gets light")
	before["city.mira_gate"] = true
	assert_eq(WorldState.state.flags, before, "only the flag the map reads: she stands at the gate")
	assert_eq(WorldState.quest_stage("main_city_way"), "night")
	assert_eq(WorldState.relationship_state("mira"), "stranger", "no new memory here (S7 has one)")
	assert_false(_blocks()["con_mira"].contains("add_memory"), "the memory is the quarrel's")
	assert_eq((await DialogueWalk.play(FILE, "con_mira")).size(), 3, "and the same twice")
	assert_eq(WorldState.quest_stage("main_city_way"), "night")


# --- The invitation ------------------------------------------------------------------------------


func test_lio_invites_her_once_the_list_is_closed_and_she_can_say_later() -> void:
	WorldState.start_quest("main_city_way")
	for stage: String in ["town", "help", "list"]:
		WorldState.advance_quest("main_city_way", stage)
	WorldState.set_flag("list.closed")
	assert_eq((await DialogueWalk.answers(CITY, "lio_invite")).size(), 2)
	var later := await DialogueWalk.play(CITY, "lio_invite", PackedStringArray(["Später"]))
	assert_true(_has(later, "stadt_inv_5"))
	assert_false(WorldState.has_flag("city.concert_invited"), "the day stays")
	assert_eq(WorldState.quest_stage("main_city_way"), "list")
	var yes := await DialogueWalk.play(CITY, "lio_invite", PackedStringArray(["Ich komme"]))
	assert_true(_has(yes, "stadt_inv_4"))
	assert_true(WorldState.has_flag("city.concert_invited"), "the scene goes over into the evening")
	assert_eq(WorldState.quest_stage("main_city_way"), "evening")


func test_before_the_list_is_closed_lio_does_not_invite() -> void:
	for cue: String in ["lio_street", "lio_again"]:
		WorldState.new_game()
		var seen := await DialogueWalk.play(CITY, cue)
		assert_false(_has(seen, "stadt_inv_1"), "%s: no invitation yet" % cue)
		WorldState.set_flag("list.closed")
		assert_true(_has(await DialogueWalk.play(CITY, cue), "stadt_inv_1"), "%s: now" % cue)
		WorldState.set_flag("city.concert_invited")
		assert_false(_has(await DialogueWalk.play(CITY, cue), "stadt_inv_1"), "%s: once" % cue)


# --- Quest, journal, things -------------------------------------------------------------------


func test_the_quest_goes_from_the_list_to_the_evening() -> void:
	var quest := ContentDB.quest("main_city_way")
	assert_true(quest.can_advance("list", "evening"))
	assert_false(quest.stage("list").is_final(), "the evening follows the list")
	assert_false(quest.stage("evening").is_final(), "the night follows the concert (S7)")
	assert_true(quest.can_advance("evening", "night"))
	assert_true(quest.stage("night").is_final(), "until the way home (S8)")
	for key: String in ["QUEST_MAIN_CITY_WAY_EVENING", "MEMORY_LIO_CONCERT"]:
		assert_ne(tr(key), key, key)
	assert_false(tr("QUEST_MAIN_CITY_WAY_EVENING").contains("Verbindung"))


func test_the_string_and_the_poster_are_curiosities_with_a_picture_and_a_sentence() -> void:
	for id: String in [STRING, POSTER]:
		var item := ContentDB.item(id)
		assert_not_null(item, id)
		assert_eq(item.kind, ItemDef.Kind.CURIOSITY)
		var key := id.to_upper().trim_prefix("CURIOSITY_")
		assert_ne(tr("CURIOSITY_%s_NAME" % key), "CURIOSITY_%s_NAME" % key, id)
		assert_ne(tr("CURIOSITY_%s_DESC" % key), "CURIOSITY_%s_DESC" % key, id)
		assert_true(FileAccess.file_exists("res://assets/generated/items/%s.png" % id), id)
	assert_true(
		FileAccess.file_exists("res://assets/generated/fragments/fragment_stage_scratch.png"),
		"and the board's picture"
	)
