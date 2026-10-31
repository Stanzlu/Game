# gdlint: ignore=max-public-methods
extends GutTest
## Act III, segment W5: a night in the wood. A small lantern stands on the ground and burns; whoever
## walks up to it finds it where it stood, and whoever sits down beside it hears a hum, once, very
## quietly and from no direction. That is the whole picture: no child in it and no word of one, no
## explanation, no counter, no fragment, nothing on a clock (the sitting is the waiting). The trees
## and a rotten log glow matt green, a curiosity can be taken from the log, and the way back lies
## open without ever being called home. The scene (doors, sound, beats) is tested in
## test_akt3_nachtwald_szene, the map elsewhere.

const NW := "res://content/dialogue/akt3/nachtwald.dialogue"
const HUM_LINE := "nw_wait_4"
const WAIT_IDS: Array[String] = ["nw_wait_1", "nw_wait_2", "nw_wait_3", "nw_wait_4", "nw_wait_5"]
const CUES: Array[String] = [
	"wait",
	"wait_again",
	"lantern_far",
	"glow_tree",
	"foxfire",
	"home_way",
]
## Words that would make the picture one of the other images of the child, name a person, give a
## reason or an explanation, or tell what the player feels. None of them may stand in a line.
const FORBIDDEN: Array[String] = [
	"Kind",
	"Mädchen",
	"Junge",
	"Mutter",
	"Vater",
	"Familie",
	"Mama",
	"Papa",
	"Name",
	"Lied",
	"Hand",
	"Tür",
	"Flur",
	"Zimmer",
	"Haus",
	"versteck",
	"Angst",
	"Schuld",
	"schuld",
	"Therap",
	"Diagnos",
	"Trauma",
	"Melodie",
	"Stimme",
	"jemand",
	"Person",
	"Erinnerung",
	"erinner",
	"vermiss",
	"Abschied",
	"Trost",
	"tröst",
	"Heim",
	"Zuhause",
	"unheimlich",
	"Geist",
	"Gespenst",
	"einsam",
	"traurig",
	"Gefahr",
	"sicher",
	"Schutz",
	"Punkte",
	"Prozent",
	"Level",
	"Ursache",
	"Täter",
]
## Phrases the earlier segments have used up; a line of this file must not say them again.
const USED_UP: Array[String] = [
	"Atemzug",
	"nur kurz",
	"wohin mit",
	"gleich dort",
	"leichter, als es aussieht",
	"als wäre es immer",
	"Etappen",
	"spart Zeit",
	"Fast da",
	"Daumen",
	"Becher",
]


func before_each() -> void:
	WorldState.new_game()
	WorldState.set_ui_mode(GameState.UiMode.REAL)


func after_each() -> void:
	WorldState.new_game()


func _has(seen: PackedStringArray, id: String) -> bool:
	return LineText.of(id) in seen


func _say(ids: Array[String]) -> String:
	var found: PackedStringArray = []
	for id: String in ids:
		found.append(LineText.of(id))
	return " ".join(found)


## A typed list of names (typed and untyped arrays do not compare equal in an assert).
func _names(names: Array) -> Array[String]:
	var found: Array[String] = []
	for name: String in names:
		found.append(name)
	return found


## Every flag that is set now, sorted.
func _flag_names() -> Array[String]:
	var found: Array[String] = []
	for flag: String in WorldState.state.flags:
		found.append(flag)
	found.sort()
	return found


## The flags that are there now and were not in `before`, sorted.
func _added(before: Dictionary) -> Array[String]:
	var added: Array[String] = []
	for flag: String in WorldState.state.flags:
		if not before.has(flag):
			added.append(flag)
	added.sort()
	return added


## The lines of one cue as written (tabs kept), without blank lines and comments.
func _cue_raw(cue: String) -> PackedStringArray:
	var found: PackedStringArray = []
	var inside := false
	for raw in FileAccess.get_file_as_string(NW).split("\n"):
		if raw.begins_with("~ "):
			inside = raw.strip_edges() == "~ " + cue
			continue
		if inside and not raw.strip_edges().is_empty() and not raw.begins_with("#"):
			found.append(raw)
	return found


## The statements of a cue (stripped), the closing "=> END" left out.
func _statements(cue: String) -> PackedStringArray:
	var found: PackedStringArray = []
	for raw in _cue_raw(cue):
		found.append(raw.strip_edges())
	if not found.is_empty() and found[found.size() - 1] == "=> END":
		found.remove_at(found.size() - 1)
	return found


## Every line of the file that carries an ID: {id, text, answer}. The text is what the player sees
## (no tags, no condition). Nobody speaks in this file, so there is no speaker.
func _story_lines() -> Array[Dictionary]:
	var found: Array[Dictionary] = []
	for raw in FileAccess.get_file_as_string(NW).split("\n"):
		var line := raw.strip_edges()
		if not line.contains("[ID:"):
			continue
		var id_at := line.find("[ID:")
		var text := line.substr(0, id_at).strip_edges()
		var id := line.substr(id_at + 4, line.find("]", id_at) - id_at - 4)
		var answer := text.begins_with("- ")
		if answer:
			text = text.substr(2).strip_edges()
		found.append({"id": id, "text": text, "answer": answer})
	return found


## The visible text of every ID of the file (answers included) plus the curiosity's name and
## description.
func _all_texts() -> PackedStringArray:
	var found: PackedStringArray = []
	for hit in RegEx.create_from_string("\\[ID:(nw_[a-z0-9_]+)\\]").search_all(
		FileAccess.get_file_as_string(NW)
	):
		found.append(LineText.of(hit.get_string(1)))
	found.append(tr("CURIOSITY_FOXFIRE_NAME"))
	found.append(tr("CURIOSITY_FOXFIRE_DESC"))
	return found


## The lines of a cue one by one as the box asks for them, each with whether `forest.waited` was
## set when the line came up (an effect in front of a line runs when that line is fetched).
func _stepped(cue: String) -> Array[Dictionary]:
	var resource := load(NW) as DialogueResource
	var found: Array[Dictionary] = []
	var line: DialogueLine = await DialogueManager.get_next_dialogue_line(resource, cue)
	while line != null:
		found.append({"text": line.text, "waited": WorldState.has_flag("forest.waited")})
		line = await DialogueManager.get_next_dialogue_line(resource, line.next_id)
	return found


# --- The file and what it sets ---------------------------------------------------------------


func test_the_file_has_every_cue_the_map_and_the_scene_name() -> void:
	var cues := (load(NW) as DialogueResource).get_cues()
	for cue: String in CUES:
		assert_true(cue in cues, "cue %s" % cue)


func test_the_file_stays_inside_its_line_budget_of_the_contract() -> void:
	var narrated := 0
	for line: Dictionary in _story_lines():
		if not line["answer"]:
			narrated += 1
	assert_between(narrated, 14, 20, "about fourteen lines were planned, twenty is the limit")


func test_nothing_but_the_contract_is_set_started_advanced_or_given() -> void:
	# a static scan of every effect in the file, whatever a walk would need to reach it
	var found: Array[String] = []
	var regex := RegEx.create_from_string("^\\s*do WorldState\\.(\\w+)\\((.*)\\)\\s*$")
	for raw in FileAccess.get_file_as_string(NW).split("\n"):
		var hit := regex.search(raw)
		if hit != null:
			found.append("%s(%s)" % [hit.get_string(1), hit.get_string(2)])
	found.sort()
	var expected: Array[String] = [
		'add_item("curiosity_foxfire")',
		'set_flag("forest.foxfire_taken")',
		'set_flag("forest.waited")',
	]
	assert_eq(found, expected, "no quest, no care, no relationship, no fragment, no melody")


func test_the_cues_leave_sound_beats_and_pictures_to_the_scene() -> void:
	var source := FileAccess.get_file_as_string(NW)
	for needle: String in ["AudioDirector", "sfx", "child_hum", "Beat.", "fragment.", "melody."]:
		for raw in source.split("\n"):
			if raw.begins_with("#"):
				continue
			assert_false(raw.contains(needle), "'%s' in a statement: %s" % [needle, raw])


func test_each_cue_sets_only_what_the_contract_gives_it() -> void:
	# whatever answer is taken
	var table := [
		{"cue": "wait", "picks": [""], "allowed": ["forest.waited"]},
		{"cue": "wait_again", "picks": [""], "allowed": []},
		{"cue": "lantern_far", "picks": [""], "allowed": []},
		{"cue": "glow_tree", "picks": [""], "allowed": []},
		{
			"cue": "foxfire",
			"picks": ["Einstecken", "Liegen lassen", "…"],
			"allowed": ["forest.foxfire_taken"],
		},
		{"cue": "home_way", "picks": [""], "allowed": []},
	]
	var walked := 0
	for entry: Dictionary in table:
		var cue: String = entry["cue"]
		for pick: String in entry["picks"]:
			WorldState.new_game()
			var before := WorldState.state.flags.duplicate()
			var items := WorldState.state.inventory.duplicate()
			await DialogueWalk.play(NW, cue, PackedStringArray([pick]))
			walked += 1
			for flag: String in _added(before):
				assert_true(flag in entry["allowed"], "%s (pick '%s') sets %s" % [cue, pick, flag])
			if not (cue == "foxfire" and pick == "Einstecken"):
				assert_eq(
					WorldState.state.inventory, items, "%s (pick '%s') gives no item" % [cue, pick]
				)
			assert_true(WorldState.state.quests.is_empty(), "%s starts no quest" % cue)
			assert_true(WorldState.state.facets.is_empty(), "%s gives no facet" % cue)
			assert_eq(Collection.fragments(), 0, "%s: no fragment" % cue)
			assert_eq(Collection.melodies(), 0, "%s: no melody is learnt" % cue)
	assert_eq(walked, 8, "every answer of every cue was walked")


# --- Sitting beside the lantern ----------------------------------------------------------------


func test_the_first_sitting_is_five_lines_and_the_flag_comes_in_the_middle() -> void:
	var steps := await _stepped("wait")
	assert_eq(steps.size(), 5)
	for index in 5:
		assert_eq(steps[index]["text"], LineText.of(WAIT_IDS[index]), WAIT_IDS[index])
	for index in 3:
		assert_false(steps[index]["waited"], "the flag is not there before the hum's line")
	for index: int in [3, 4]:
		assert_true(steps[index]["waited"], "the flag is there when the hum's line comes up")
	assert_eq(_flag_names(), _names(["forest.waited"]), "and nothing else")


func test_the_flag_stands_between_the_silence_and_the_hum_in_the_file() -> void:
	var statements := _statements("wait")
	var at := statements.find('do WorldState.set_flag("forest.waited")')
	assert_gt(at, 0, "the cue sets the flag")
	var before := 0
	for index in at:
		if statements[index].contains("[ID:"):
			before += 1
	var after := 0
	for index in range(at + 1, statements.size()):
		if statements[index].contains("[ID:"):
			after += 1
	assert_eq(before, 3, "three lines come first: she sits, the lantern stays, nothing moves")
	assert_eq(after, 2, "the hum and the flame afterwards")
	assert_true(statements[at + 1].contains("[ID:" + HUM_LINE + "]"), "the hum's line follows it")
	assert_true(statements[at - 1].contains("[ID:nw_wait_3]"), "and the silence stands before it")
	var setters := 0
	for raw in FileAccess.get_file_as_string(NW).split("\n"):
		if raw.contains('set_flag("forest.waited")'):
			setters += 1
	assert_eq(setters, 1, "one setter")


func test_the_first_sitting_shows_the_lantern_the_flame_the_silence_and_a_hum() -> void:
	var text := _say(WAIT_IDS)
	for word: String in ["Laterne", "Flamme", "raschelt", "Ast", "summt", "Töne", "leise", "woher"]:
		assert_string_contains(text, word)
	assert_eq(text.count("Laterne"), 1, "the lantern is named once, the other lines say 'sie'")
	assert_eq(text.count("Flamme"), 2, "the flame stands, and stands as before")
	assert_lt(text.find("raschelt"), text.find("summt"), "the silence comes before the hum")
	assert_string_contains(LineText.of("nw_wait_2"), "von Weitem", "it stays where it stood")
	assert_string_contains(LineText.of("nw_wait_2"), "biegt sich nicht", "the flame is calm")
	assert_string_contains(LineText.of("nw_wait_5"), "Flamme", "the lantern burns on")
	for word: String in ["hört auf", "verstummt", "still", "vorbei", "Ende"]:
		assert_false(
			LineText.of("nw_wait_5").contains(word),
			"no line states the end of the sound: %s" % word
		)
	assert_false(LineText.of("nw_wait_1").contains("Flamme"), "she sits before she looks")


func test_the_hum_is_told_once_and_nothing_says_what_it_is() -> void:
	var humming: Array[String] = []
	for line: Dictionary in _story_lines():
		if line["text"].to_lower().contains("summ"):
			humming.append(line["id"])
	assert_eq(humming, _names([HUM_LINE]), "one line hums")
	var hum := LineText.of(HUM_LINE)
	for word: String in [
		"Kind",
		"Lied",
		"Melodie",
		"Stimme",
		"jemand",
		"Person",
		"kennst",
		"erkenn",
		"vertraut",
		"bekannt",
		"antwort",
		"dein",
		"Mädchen",
		"Name",
		"Richtung",
	]:
		assert_false(hum.contains(word), "'%s' interprets the hum: %s" % [word, hum])
	assert_lt(hum.split(" ", false).size(), 17, "short")
	assert_null(RegEx.create_from_string("[!?:…]").search(hum), "no mark in it")


func test_the_second_sitting_is_one_calm_line_and_nothing_sets_the_flag_again() -> void:
	var changes: Array[int] = [0]
	var on_flag := func(id: String, value: bool) -> void:
		if id == "forest.waited" and value:
			changes[0] += 1
	WorldState.flag_changed.connect(on_flag)
	var first := await DialogueWalk.play(NW, "wait")
	var second := await DialogueWalk.play(NW, "wait")
	var third := await DialogueWalk.play(NW, "wait")
	WorldState.flag_changed.disconnect(on_flag)
	assert_eq(first.size(), 5)
	assert_eq(second, PackedStringArray([LineText.of("nw_again_1")]), "one line the second time")
	assert_eq(third, second, "and the same every time after")
	assert_eq(changes[0], 1, "the flag changes once, so the sound plays once")
	assert_eq(_flag_names(), _names(["forest.waited"]))
	var again := LineText.of("nw_again_1")
	assert_lt(again.split(" ", false).size(), 17, "short")
	assert_false(again.contains("summ"), "no hum, and no wish for one")
	assert_string_contains(again, "Flamme")


func test_a_loaded_game_with_the_flag_sits_down_without_a_sound_or_a_second_setting() -> void:
	WorldState.set_flag("forest.waited")
	var changes: Array[int] = [0]
	var on_flag := func(id: String, _value: bool) -> void:
		if id == "forest.waited":
			changes[0] += 1
	WorldState.flag_changed.connect(on_flag)
	var seen := await DialogueWalk.play(NW, "wait")
	WorldState.flag_changed.disconnect(on_flag)
	assert_eq(seen, PackedStringArray([LineText.of("nw_again_1")]))
	assert_eq(changes[0], 0, "nothing touches the flag")


func test_the_again_cue_is_reached_only_through_the_flag() -> void:
	var statements := _statements("wait")
	assert_eq(statements[0], 'if WorldState.has_flag("forest.waited")', "first thing it asks")
	assert_eq(statements[1], "=> wait_again")
	var jumps := 0
	for raw in FileAccess.get_file_as_string(NW).split("\n"):
		if raw.contains("=> wait_again"):
			jumps += 1
	assert_eq(jumps, 1, "no other way in")
	assert_eq((await DialogueWalk.groups(NW, "wait")).size(), 0, "no answer: nobody has to choose")
	assert_eq((await DialogueWalk.groups(NW, "wait_again")).size(), 0)


func test_sitting_is_never_a_clock_and_nobody_counts() -> void:
	var clock := (
		RegEx
		. create_from_string(
			(
				"(?i)\\b(minuten?|stunden?|sekunden?|uhr|weile|lange|bald|schließlich|endlich|irgendwann"
				+ "|inzwischen|mittlerweile|einmal|zweimal|nochmal|erneut|wieder)\\b"
			)
		)
	)
	for text: String in _all_texts():
		assert_null(clock.search(text), "a clock or a count in: %s" % text)
		assert_false(text.to_lower().contains("wart"), "it is never called waiting: %s" % text)


# --- The things: far light, glowing tree, home --------------------------------------------------


func test_the_lantern_far_off_is_a_light_that_does_not_move() -> void:
	var seen := await DialogueWalk.play(NW, "lantern_far")
	assert_eq(seen.size(), 2)
	assert_true(_has(seen, "nw_far_1") and _has(seen, "nw_far_2"))
	var text := _say(["nw_far_1", "nw_far_2"])
	for word: String in ["Boden", "Licht", "orange", "zuckt nicht", "wandert nicht", "glimmt grün"]:
		assert_string_contains(text, word)
	assert_false(text.contains("Laterne"), "from afar it is not yet a lantern")
	assert_eq((await DialogueWalk.groups(NW, "lantern_far")).size(), 0, "it is only looked at")
	assert_eq(_flag_names(), _names([]))


func test_a_glowing_tree_is_looked_at_and_the_glow_stays_on_it() -> void:
	var seen := await DialogueWalk.play(NW, "glow_tree")
	assert_eq(seen.size(), 2)
	var text := _say(["nw_glow_1", "nw_glow_2"])
	for word: String in ["Rinde", "Streifen", "glimmt", "matt grün", "Pilze", "Boden"]:
		assert_string_contains(text, word)
	assert_string_contains(LineText.of("nw_glow_2"), "Auf dem Boden darunter liegt es nicht")
	assert_eq((await DialogueWalk.groups(NW, "glow_tree")).size(), 0)
	assert_eq(_flag_names(), _names([]))


func test_the_way_home_is_shown_and_never_named() -> void:
	var seen := await DialogueWalk.play(NW, "home_way")
	assert_eq(seen.size(), 2)
	var text := _say(["nw_home_1", "nw_home_2"])
	for word: String in ["Stamm", "Pfad", "gerade", "Bach", "kennst"]:
		assert_string_contains(text, word)
	for word: String in [
		"Hause", "daheim", "Heimat", "zurück", "Ziel", "angekommen", "endlich", "Ende", "geschafft"
	]:
		assert_false(text.contains(word), "'%s' would say where this leads" % word)
	assert_eq((await DialogueWalk.groups(NW, "home_way")).size(), 0)
	assert_eq(_flag_names(), _names([]))


# --- The curiosity: the glowing log -------------------------------------------------------------


func test_the_log_has_three_answers_and_the_first_one_takes_a_piece() -> void:
	var groups := await DialogueWalk.groups(NW, "foxfire", PackedStringArray(["Liegen lassen"]))
	assert_eq(groups.size(), 1)
	assert_eq(groups[0].size(), 3, "take it, leave it, silence")
	assert_string_contains(groups[0][0], "Einstecken")
	assert_string_contains(groups[0][1], "Liegen lassen")
	assert_eq(groups[0][2], "…", "the silence is last")
	await DialogueWalk.play(NW, "foxfire")
	assert_true(WorldState.has_item("curiosity_foxfire"), "the first answer takes it")


func test_leaving_the_log_or_keeping_silent_changes_nothing() -> void:
	var left := await DialogueWalk.play(NW, "foxfire", PackedStringArray(["Liegen lassen"]))
	assert_true(_has(left, "nw_fox_1") and _has(left, "nw_fox_2") and _has(left, "nw_fox_4"))
	assert_false(WorldState.has_item("curiosity_foxfire"))
	assert_false(WorldState.has_flag("forest.foxfire_taken"))
	var silent := await DialogueWalk.play(NW, "foxfire", PackedStringArray(["…"]))
	assert_true(_has(silent, "nw_fox_5"))
	assert_eq(_flag_names(), _names([]))
	assert_eq(WorldState.state.inventory.size(), 0)
	assert_eq(Collection.curiosities(), 0)


func test_taking_a_piece_gives_the_curiosity_and_the_flag_and_nothing_else() -> void:
	var taken := await DialogueWalk.play(NW, "foxfire", PackedStringArray(["Einstecken"]))
	assert_true(_has(taken, "nw_fox_3"))
	assert_true(WorldState.has_item("curiosity_foxfire"))
	assert_eq(WorldState.item_count("curiosity_foxfire"), 1)
	assert_true(WorldState.has_flag("forest.foxfire_taken"))
	assert_eq(_flag_names(), _names(["forest.foxfire_taken"]), "no other flag")
	assert_eq(WorldState.state.inventory.size(), 1, "no other item")
	assert_eq(Collection.curiosities(), 1)
	assert_eq(Collection.fragments(), 0, "a curiosity is no fragment")
	var statements := _statements("foxfire")
	var item_at := statements.find('do WorldState.add_item("curiosity_foxfire")')
	var flag_at := statements.find('do WorldState.set_flag("forest.foxfire_taken")')
	assert_gt(item_at, -1)
	assert_eq(flag_at, item_at + 1, "the flag follows the item and comes last")


func test_once_a_piece_is_taken_the_log_is_one_line_without_an_answer() -> void:
	await DialogueWalk.play(NW, "foxfire", PackedStringArray(["Einstecken"]))
	var seen := await DialogueWalk.play(NW, "foxfire")
	assert_eq(seen, PackedStringArray([LineText.of("nw_fox_6")]))
	assert_eq((await DialogueWalk.groups(NW, "foxfire")).size(), 0, "nothing to take twice")
	assert_eq(WorldState.item_count("curiosity_foxfire"), 1, "and nothing given twice")
	assert_lt(LineText.of("nw_fox_6").split(" ", false).size(), 17, "short")
	assert_false(LineText.of("nw_fox_6").contains("glimmt"), "the log no longer glows")


func test_the_log_says_what_the_picture_shows_and_the_glow_is_not_explained() -> void:
	var text := _say(["nw_fox_1", "nw_fox_2"])
	for word: String in [
		"morsch",
		"Stamm",
		"Gras",
		"Moos",
		"durchtrennt",
		"abgebrochen",
		"Rissen",
		"glimmt",
		"matt grün"
	]:
		assert_string_contains(text, word)
	assert_eq(text.count("Stamm"), 1, "one log")
	for word: String in ["Pilz", "Licht", "leuchtet", "Magie", "Zauber", "Funke"]:
		assert_false(text.contains(word), "'%s' would explain the glow" % word)
	assert_string_contains(LineText.of("nw_fox_3"), "heraus", "a piece is broken out of the log")
	assert_string_contains(LineText.of("nw_fox_3"), "Durch den Stoff glimmt es weiter")


func test_the_curiosity_is_in_the_game_and_counts() -> void:
	var id := "curiosity_foxfire"
	assert_true(ContentDB.has_item(id))
	assert_eq(ContentDB.item(id).kind, ItemDef.Kind.CURIOSITY)
	assert_eq(ContentDB.item(id).max_stack, 1)
	assert_eq(tr("CURIOSITY_FOXFIRE_NAME"), "Ein Stück Leuchtholz", "named like the others")
	assert_ne(tr("CURIOSITY_FOXFIRE_DESC"), "CURIOSITY_FOXFIRE_DESC")
	assert_string_contains(tr("CURIOSITY_FOXFIRE_DESC"), "glimmt")
	assert_null(RegEx.create_from_string("[0-9]").search(tr("CURIOSITY_FOXFIRE_DESC")), "no digit")
	assert_true(ResourceLoader.exists("res://assets/generated/items/%s.png" % id), "the picture")
	WorldState.add_item(id, 1, false)
	assert_eq(Collection.curiosities(), 1)


# --- The hero's journal -------------------------------------------------------------------------


func test_the_journal_points_south_and_says_nothing_of_the_time_or_the_night() -> void:
	var key := "QUEST_MAIN_FOREST_WAY_NIGHT"
	var text := tr(key)
	assert_ne(text, key, "the row is there")
	for word: String in ["Südlich", "Lichtung", "Pfad", "nach Hause", "Ich gehe"]:
		assert_string_contains(text, word)
	assert_null(RegEx.create_from_string("[0-9]").search(text), "no digit")
	assert_null(RegEx.create_from_string("[!?…]").search(text), "no cry, question or ellipsis")
	for word: String in [
		"Abend",
		"Nacht",
		"Morgen",
		"Dämmer",
		"Mittag",
		"Tag",
		"Uhr",
		"Stunde",
		"Flut",
		"Laterne",
		"summ",
		"Kind",
		"Zuhause",
		"Heim",
	]:
		assert_false(text.contains(word), "'%s' in the journal row: %s" % [word, text])
	assert_false(
		tr("QUEST_MAIN_FOREST_WAY_WOOD").contains("Flut"), "the hero's journal keeps its secret"
	)
	assert_false(text.contains("Es wird Abend"), "the placeholder of W3 is gone")


# --- What it never says --------------------------------------------------------------------------


func test_narration_has_no_colon_question_cry_or_ellipsis_and_no_digit() -> void:
	var checked := 0
	for line: Dictionary in _story_lines():
		if line["answer"]:
			continue
		var text: String = line["text"]
		checked += 1
		for mark: String in [":", "?", "!", "…"]:
			assert_false(text.contains(mark), "%s in narration: %s" % [mark, text])
		assert_null(RegEx.create_from_string("[0-9]").search(text), "a digit in: %s" % text)
	assert_gt(checked, 16, "every line of narration was read, 18 at the time of writing")


func test_nobody_speaks_in_the_wood() -> void:
	var speaker := RegEx.create_from_string("^([A-ZÄÖÜ][a-zäöüß]{1,20}):\\s")
	for raw in FileAccess.get_file_as_string(NW).split("\n"):
		assert_null(speaker.search(raw.strip_edges()), "a speaker in: %s" % raw)
	# the same through the dialogue manager: every cue, every answer
	var resource := load(NW) as DialogueResource
	var reached := 0
	for title: String in resource.get_cues():
		WorldState.new_game()
		var open: Array[String] = [title]
		var visited := {}
		var guard := 0
		while not open.is_empty() and guard < 60:
			guard += 1
			var next_id: String = open.pop_back()
			if visited.has(next_id):
				continue
			visited[next_id] = true
			var line: DialogueLine = await DialogueManager.get_next_dialogue_line(resource, next_id)
			if line == null:
				continue
			reached += 1
			assert_eq(line.character, "", "no voice: %s" % line.text)
			if line.responses.is_empty():
				open.append(line.next_id)
			for response: DialogueResponse in line.responses:
				if response.is_allowed:
					open.append(response.next_id)
	assert_gt(reached, 15, "the lines were reached")


func test_every_group_has_an_unconditional_answer_and_the_silence_last() -> void:
	# a static scan: every group of the file (ContentValidator checks that no choice is a fake one)
	var groups := 0
	for cue: String in (load(NW) as DialogueResource).get_cues():
		var answers: Array[String] = []
		for raw in _cue_raw(cue):
			if raw.begins_with("- "):
				answers.append(raw)
		if answers.is_empty():
			continue
		groups += 1
		assert_true(answers[answers.size() - 1].begins_with("- … [ID:"), "%s: silence last" % cue)
		var plain := 0
		for answer in answers:
			if not answer.contains("[if ") and not answer.begins_with("- … [ID:"):
				plain += 1
		assert_gte(plain, 1, "%s: an answer that is always there besides the silence" % cue)
		for answer in answers:
			assert_false(
				answer.contains("[if "), "%s: no answer can be missing: %s" % [cue, answer]
			)
	assert_eq(groups, 1, "the log is the only group")
	var found := await DialogueWalk.groups(NW, "foxfire")
	assert_eq(found[0][found[0].size() - 1], "…", "and as the player meets it: silence last")


func test_the_answers_are_plain_and_never_cry_or_ask() -> void:
	var answers := 0
	for line: Dictionary in _story_lines():
		if not line["answer"]:
			continue
		answers += 1
		for mark: String in ["!", "?"]:
			assert_false(line["text"].contains(mark), "%s in an answer: %s" % [mark, line["text"]])
		assert_lt(line["text"].split(" ", false).size(), 5, "an answer is short: %s" % line["text"])
	assert_eq(answers, 3)


func test_every_effect_stands_after_the_lines_of_its_branch() -> void:
	# what is set stands at the end of the lines; only the flag of the first sitting stands in the
	# middle of its cue on purpose (checked in test_the_flag_stands_between_the_silence_and_the_hum)
	var effects := 0
	var raws := FileAccess.get_file_as_string(NW).split("\n")
	for index in raws.size():
		var raw := raws[index]
		var statement := raw.strip_edges()
		if not statement.begins_with("do WorldState.") or statement.contains("forest.waited"):
			continue
		effects += 1
		var depth := raw.length() - raw.lstrip("\t").length()
		var at := index + 1
		while at < raws.size() and (raws[at].strip_edges().is_empty() or raws[at].begins_with("#")):
			at += 1
		assert_lt(at, raws.size(), "an effect is never the last line of the file")
		var next := raws[at]
		var next_depth := next.length() - next.lstrip("\t").length()
		var is_story := next.contains("[ID:") and not next.strip_edges().begins_with("- ")
		assert_false(is_story and next_depth >= depth, "a line follows the effect: %s" % statement)
	assert_eq(effects, 2, "both effects of the log were checked")


func test_nothing_explains_and_nothing_names_a_child_a_cause_or_another_image() -> void:
	var reasons := RegEx.create_from_string(
		"(?i)\\b(weil|deshalb|seitdem|damals|darum|deswegen|daher|denn|tot|tote|tod)\\b"
	)
	var texts := _all_texts()
	assert_gt(texts.size(), 20, "every line, answer and item text was collected")
	for text: String in texts:
		for word: String in FORBIDDEN:
			assert_false(text.contains(word), "'%s' in: %s" % [word, text])
		assert_null(reasons.search(text), "a reason is given in: %s" % text)


func test_no_line_says_a_phrase_the_earlier_segments_have_used_up() -> void:
	var texts := _all_texts()
	assert_gt(texts.size(), 20)
	for text: String in texts:
		for phrase: String in USED_UP:
			assert_false(text.contains(phrase), "'%s' is used up, in: %s" % [phrase, text])


func test_the_second_telling_of_a_thing_is_one_short_line() -> void:
	for id: String in ["nw_again_1", "nw_fox_6"]:
		assert_lte(LineText.of(id).split(" ", false).size(), 16, id)
