extends GutTest
## Act VI, segment R1: what the day after the mountains tells (docs/akt6/REGIONSBRIEFE.md, O1,
## O10, O12; docs/writing/stimmen/mira.md). The morning in the house and in the valley (nothing is
## asked, the things go on), Mira at her old camp who says that she goes (never where) in the tone
## of how the quarrel at the gate ended, the empty place and the quiet house with its light that is
## not from here. Nothing is explained, nothing is named, nobody is comforted. The scenes (the
## morning, the walk away, the quiet, the flags and the stages) are tested in test_akt6_leere_szene.

const FILE := "res://content/dialogue/akt6/leere.dialogue"
const CUES: PackedStringArray = [
	"morning_house",
	"morning_valley",
	"mira_leaves",
	"camp_empty",
	"house_empty",
]
const OUTCOMES: PackedStringArray = [
	"city.mira_parted_boundary",
	"city.mira_parted_joined",
	"city.mira_parted_silent",
]
## What the text never says: the name of the feeling, of her goal and of everything that happened
## above, the comfort, the lesson, the farewell.
const NEVER: PackedStringArray = [
	"Elysia",
	"Meer",
	"Gebirge",
	"Berg",
	"Kind",
	"Kreide",
	"Wächter",
	"Maschine",
	"Leere",
	"Gefühl",
	"einsam",
	"vermiss",
	"traurig",
	"Trost",
	"trösten",
	"Abschied",
	"verarbeit",
	"heilen",
	"loslassen",
	"Sinn",
	"danke",
	"Danke",
	"zurück",
	"heimkehr",
	"Heimkehr",
]
## What the cues true in every state of the house or the valley never name.
const STATES: PackedStringArray = [
	"Feuer",
	"Katze",
	"Antreiber",
	"Einsiedler",
	"Stuhl",
	"Werkbank",
	"Regal",
	"Brot",
	"Mira",
	"Tess",
	"Beet",
	"Trieb",
]


func before_each() -> void:
	WorldState.new_game()
	WorldState.set_ui_mode(GameState.UiMode.REAL)


func after_each() -> void:
	WorldState.new_game()


func _source() -> String:
	return FileAccess.get_file_as_string(FILE)


func _ids() -> PackedStringArray:
	var found: PackedStringArray = []
	for hit in RegEx.create_from_string("\\[ID:(lee_[a-z0-9_]+)\\]").search_all(_source()):
		found.append(hit.get_string(1))
	return found


## The text of every line (before its ID), comments and code left out.
func _spoken() -> String:
	var spoken := ""
	for line in _source().split("\n"):
		var at := line.find("[ID:")
		if at > -1 and not line.strip_edges().begins_with("#"):
			spoken += line.substr(0, at) + "\n"
	return spoken


## The lines of a cue as written (speaker and all, tabs of a condition cut off), in the order of the
## file; comments and code left out.
func _written(cue: String) -> PackedStringArray:
	var lines := PackedStringArray()
	var inside := false
	for line in _source().split("\n"):
		if line.begins_with("~ "):
			inside = line.substr(2).strip_edges() == cue
		elif inside and line.find("[ID:") > -1 and not line.begins_with("#"):
			lines.append(line.substr(0, line.find("[ID:")).strip_edges())
	return lines


func _told(cue: String) -> String:
	return "\n".join(await DialogueWalk.play(FILE, cue))


## The cue played with exactly one outcome of the quarrel set (or none).
func _played(outcome: String) -> PackedStringArray:
	WorldState.new_game()
	WorldState.set_ui_mode(GameState.UiMode.REAL)
	if outcome != "":
		WorldState.set_flag(outcome)
	return await DialogueWalk.play(FILE, "mira_leaves")


# --- The file -----------------------------------------------------------------------------------


func test_the_file_tells_the_cues_in_draft_with_unique_ids_and_sets_nothing() -> void:
	var names: PackedStringArray = []
	for hit in RegEx.create_from_string("(?m)^~ ([a-z0-9_]+)$").search_all(_source()):
		names.append(hit.get_string(1))
	assert_eq(names, CUES, "the cues of the contract, in this order")
	var ids := _ids()
	var unique := {}
	for id in ids:
		unique[id] = true
	assert_eq(unique.size(), ids.size(), "no ID twice")
	assert_eq(_source().count("[#draft]"), ids.size(), "every line is a draft")
	assert_false(_source().contains("[#ph]"))
	# the segment plans 28 lines (plus or minus six)
	assert_gte(ids.size(), 22)
	assert_lte(ids.size(), 34)
	assert_null(RegEx.create_from_string("=> (?!END)").search(_source()), "no jumps")
	assert_false(_source().contains("set_facet"), "the text only reads: nothing")
	assert_null(RegEx.create_from_string("(?m)^\\s*do\\s").search(_source()), "and sets nothing")
	for call: String in ["add_memory", "set_relationship", "add_item", "add_xp", "start_quest"]:
		assert_false(_source().contains(call), "no %s: the scene does what is to be done" % call)
	assert_false(_spoken().contains("\n- "), "no answers: she says nothing, nobody is asked")
	for cue in CUES:
		for outcome: String in [""] + Array(OUTCOMES):
			WorldState.new_game()
			WorldState.set_ui_mode(GameState.UiMode.REAL)
			if outcome != "":
				WorldState.set_flag(outcome)
			var before := WorldState.state.flags.duplicate()
			var kept := JSON.stringify(WorldState.state.to_dict())
			var seen := await DialogueWalk.play(FILE, cue)
			assert_gte(seen.size(), 3, "%s has its lines" % cue)
			assert_eq(WorldState.state.flags, before, "%s sets no flag" % cue)
			assert_eq(JSON.stringify(WorldState.state.to_dict()), kept, "%s changes nothing" % cue)
			assert_eq(WorldState.state.facets.size(), 0, "%s sets no facet" % cue)


func test_nothing_is_a_digit_a_shout_a_question_or_the_name_of_what_it_is() -> void:
	var spoken := _spoken()
	for digit: String in "0123456789":
		assert_false(spoken.contains(digit), "numbers are written out: " + digit)
	for line in spoken.split("\n", false):
		var text := line.strip_edges()
		assert_false(text.contains("!"), "no shout: " + text)
		assert_false(text.contains("?"), "no question: " + text)
		if not text.begins_with("Mira: "):
			assert_false(text.contains(":"), "narration has no colon: " + text)
	for word in NEVER:
		assert_false(spoken.contains(word), "the text never says %s" % word)
	assert_null(
		RegEx.create_from_string("\\bleer(e|en|er)?\\b").search(spoken), "no empty, no void"
	)
	assert_null(RegEx.create_from_string("\\bweil\\b").search(spoken), "no reason is given")


func test_only_mira_speaks_and_only_in_the_cue_that_is_hers() -> void:
	for cue in CUES:
		for line in _written(cue):
			var hers := line.begins_with("Mira: ")
			assert_eq(hers, cue == "mira_leaves" and hers, "%s: %s" % [cue, line])
			assert_false(line.contains(": ") and not hers, "narration has no colon: " + line)


# --- The morning, the place and the quiet house -----------------------------------------------


func test_the_morning_in_the_house_is_grey_and_asks_nothing_and_is_true_in_every_state() -> void:
	var seen := await DialogueWalk.play(FILE, "morning_house")
	var told := "\n".join(seen)
	assert_eq(seen.size(), 5)
	assert_true(told.contains("grau") and told.contains("Tee"))
	assert_true(told.contains("regnet nicht"), "no rain, as the day after says")
	for word in STATES:
		assert_false(told.contains(word), "nothing of the state of the house: " + word)
	for word: String in ["gestern Abend", "Berg", "Weg", "Tür öffnet", "Mira"]:
		assert_false(told.contains(word), "no word of the way or of her: " + word)


func test_the_morning_in_the_valley_is_true_with_and_without_the_shoot_in_the_bed() -> void:
	var plain := await DialogueWalk.play(FILE, "morning_valley")
	WorldState.set_flag("house.garden_sprout")
	var with_shoot := await DialogueWalk.play(FILE, "morning_valley")
	assert_eq(plain, with_shoot, "the cue does not read the shoot")
	assert_eq(plain.size(), 3)
	var told := "\n".join(plain)
	assert_true(told.contains("Tau") and told.contains("Bach"))
	for word in STATES:
		assert_false(told.contains(word), "nothing of the bed or the house: " + word)


func test_the_empty_place_shows_what_is_there_and_says_nothing_of_her() -> void:
	var seen := await DialogueWalk.play(FILE, "camp_empty")
	var told := "\n".join(seen)
	assert_eq(seen.size(), 3)
	assert_true(told.contains("Plane") and told.contains("Gras"), "the tarp still hangs")
	assert_true(told.contains("Rauch"))
	for word: String in ["Mira", "Plane hing", "weg", "fort", "gegangen", "fehlt"]:
		assert_false(told.contains(word), "no word for the missing: " + word)
	var again := await DialogueWalk.play(FILE, "camp_empty")
	assert_eq(seen, again, "a look like the other")


func test_the_quiet_house_shows_a_light_that_is_not_from_here_and_pulls_nobody() -> void:
	var seen := await DialogueWalk.play(FILE, "house_empty")
	var told := "\n".join(seen)
	assert_eq(seen.size(), 4)
	assert_true(told.contains("Licht") and told.contains("wärmer") and told.contains("Gekochtem"))
	assert_true(told.contains("Dann ist beides weg"), "it is gone again, and nothing remains of it")
	for word in STATES:
		assert_false(told.contains(word), "true in every state of the house: " + word)
	for word: String in ["Garten", "Suppe", "Wirt", "Gasthaus", "Schmetterling", "Riss", "Spalt"]:
		assert_false(told.contains(word), "nothing of the place it reminds of: " + word)
	var last := _written("house_empty")[3]
	assert_true(last.contains("Du könntest"), "the last line asks for nothing and leaves it open")
	assert_false(last.contains("musst") or last.contains("sollst"), "no order")


# --- Mira goes ----------------------------------------------------------------------------------


func test_she_says_that_she_goes_and_never_where_in_every_outcome() -> void:
	for outcome: String in [""] + Array(OUTCOMES):
		var told := "\n".join(await _played(outcome))
		assert_true(told.contains("Ich geh heute weiter"), "that she goes: " + outcome)
		assert_true(told.contains("Die Plane bleibt"), "she takes what she carries: " + outcome)
		for word: String in [
			"Meer", "Stadt", "Gebirge", "Straße", "Wald", "Norden", "Süden", "Westen", "Osten"
		]:
			assert_false(told.contains(word), "never where (%s): %s" % [outcome, word])
		for word: String in [
			"Komm", "komm mit", "Bleib", "warte auf", "vermiss", "Pass auf", "Mach's gut"
		]:
			assert_false(told.contains(word), "no invitation, no request, no farewell: " + word)


func test_exactly_one_group_is_played_and_the_four_common_lines_are_the_same_in_all_of_them(
) -> void:
	var none := await _played("")
	assert_eq(none.size(), 4, "without an outcome only the common lines")
	var boundary := await _played(OUTCOMES[0])
	var joined := await _played(OUTCOMES[1])
	var silent := await _played(OUTCOMES[2])
	for seen: PackedStringArray in [boundary, joined, silent]:
		assert_eq(seen.size(), 7, "four common lines and one group of three")
		assert_eq(seen[0], none[0], "the common beginning")
		assert_eq(seen[1], none[1])
		assert_eq(seen[seen.size() - 2], none[2], "the common end")
		assert_eq(seen[seen.size() - 1], none[3])
	assert_ne(boundary.slice(2, 5), joined.slice(2, 5))
	assert_ne(joined.slice(2, 5), silent.slice(2, 5))
	assert_ne(boundary.slice(2, 5), silent.slice(2, 5))
	var set_all := PackedStringArray()
	for outcome in OUTCOMES:
		WorldState.set_flag(outcome)
	set_all = await DialogueWalk.play(FILE, "mira_leaves")
	assert_eq(set_all.size(), 7, "never two groups: the first that holds")


func test_the_tone_follows_the_outcome_and_judges_nothing() -> void:
	var boundary := "\n".join(await _played(OUTCOMES[0]))
	assert_true(boundary.contains("Das geht allein"), "factual, a nod, she asks for nothing")
	assert_true(boundary.contains("nickt"), "a nod, as at the gate")
	var joined := "\n".join(await _played(OUTCOMES[1]))
	assert_true(joined.contains("Ich warte nicht"), "her word from the quarrel still holds")
	assert_true(joined.contains("Bescheid"), "and she does not go without saying that she does")
	var silent := "\n".join(await _played(OUTCOMES[2]))
	assert_eq(silent.count("Eine Weile sagt keiner etwas"), 1, "the silence is written down, once")
	assert_true(silent.contains("leise"), "a door that is not slammed")
	for told: String in [boundary, joined, silent]:
		for word: String in [
			"richtig",
			"falsch",
			"recht",
			"Fehler",
			"schade",
			"leid",
			"Schweigen",
			"Grenze",
			"schuld"
		]:
			assert_false(told.contains(word), "not a word of what the player did: " + word)


func test_her_lines_are_short_dry_and_never_a_question_or_a_comfort() -> void:
	var mine := 0
	for line in _written("mira_leaves"):
		if line.begins_with("Mira: "):
			mine += 1
			var text := line.trim_prefix("Mira: ")
			assert_lte(text.split(" ", false).size(), 12, "short: " + line)
			assert_false(text.contains("?") or text.contains("!"), "no question, no shout: " + line)
	assert_gte(mine, 5)
	var last := _written("mira_leaves")[_written("mira_leaves").size() - 1]
	assert_false(last.begins_with("Mira"), "the last word is the place's, not hers")
	assert_true(last.contains("Plane"), "the tarp in the wind, the place")
