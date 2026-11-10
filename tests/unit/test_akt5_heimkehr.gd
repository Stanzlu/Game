extends GutTest
## Act V, segment G9: what the way down and the homecoming tell (docs/akt5/REGIONSBRIEFE.md, O9,
## O12, O13, O18; docs/writing/stimmen/waechter.md). The look on the way down (descent_pass), the
## house as she left it (home_in), the keeper at the hearth who checks it, not quite, and keeps a
## reservation (waechter_in, only with the facet trust: the scene reads it), the quiet end that is
## true with him and without him (home_close), the keeper standing there afterwards
## (waechter_home) and the shoot in the bed (garden_bed in the valley's dialogue). Nothing is
## explained, nobody is thanked, nothing is said of what happened above. The scene (the stages,
## the flag, the mark of the chapter) is tested in test_akt5_heimkehr_szene.

const FILE := "res://content/dialogue/akt5/heimkehr.dialogue"
const TAL := "res://content/dialogue/slice/tal.dialogue"
const CUES: PackedStringArray = [
	"descent_pass",
	"home_in",
	"waechter_in",
	"home_close",
	"waechter_home",
]
## What the text never says: what happened above, the cause, the lesson, his fear, the thanks he
## does not get ("Dank" is the keeper's joke: he expects none).
const NEVER: PackedStringArray = [
	"Kind",
	"Kreide",
	"Ring",
	"Mama",
	"Papa",
	"Mutter",
	"Vater",
	"damals",
	"früher",
	"Angst",
	"einsam",
	"verlassen",
	"wertlos",
	"loslassen",
	"Vertrauen",
	"Mut",
	"heilen",
	"Trauma",
	"Danke",
	"danke",
	"Gipfel",
	"Plateau",
	"Hebel",
	"Lampe",
	"Kartoffel",
	"Maschine",
	"endlich",
	"geschafft",
	"stolz",
]
## What the quiet house never names (it is true in every state of the house).
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
	"Wächter",
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
	for hit in RegEx.create_from_string("\\[ID:(hk5_[a-z0-9_]+)\\]").search_all(_source()):
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


## The lines of a cue as written (speaker and all), comments and code left out.
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
	# the segment plans 25 lines (plus or minus eight), the garden bed's are in the valley's file
	assert_gte(ids.size(), 17)
	assert_lte(ids.size(), 33)
	assert_null(RegEx.create_from_string("=> (?!END)").search(_source()), "no jumps")
	assert_false(_source().contains("set_facet"), "the text only reads: nothing")
	assert_false(_source().contains("\ndo "), "and sets nothing: the scene does")
	assert_false(_source().contains("[if "), "no condition either: the scene reads the facet")
	assert_false(_spoken().contains("\n- "), "no answers: nobody is asked anything")
	for cue in CUES:
		var before := WorldState.state.flags.duplicate()
		var seen := await DialogueWalk.play(FILE, cue)
		assert_gte(seen.size(), 3, "%s has its lines" % cue)
		assert_eq(WorldState.state.flags, before, "%s sets no flag" % cue)
		assert_false(WorldState.has_facet("trust"), "%s sets no facet" % cue)


func test_nothing_is_a_digit_a_shout_a_question_or_a_word_of_what_happened_above() -> void:
	var spoken := _spoken()
	for digit: String in "0123456789":
		assert_false(spoken.contains(digit), "numbers are written out: " + digit)
	for line in spoken.split("\n", false):
		var text := line.strip_edges()
		assert_false(text.contains("!"), "no shout: " + text)
		assert_false(text.contains("?"), "no question: " + text)
		if not text.begins_with("Wächter: "):
			assert_false(text.contains(":"), "narration has no colon: " + text)
	for word in NEVER:
		assert_false(spoken.contains(word), "the text never says %s" % word)
	assert_null(RegEx.create_from_string("\\bweil\\b").search(spoken), "no reason is given")


# --- The parts ----------------------------------------------------------------------------------


func test_the_way_down_is_light_and_says_nothing_of_what_was_above() -> void:
	var seen := await DialogueWalk.play(FILE, "descent_pass")
	var told := "\n".join(seen)
	assert_eq(seen.size(), 3)
	assert_true(told.contains("Steinmännchen") and told.contains("Bach"))
	assert_true(told.contains("Abwärts"))
	for word: String in ["Haus", "Fläche", "Tür", "Mädchen", "Junge", "oben"]:
		assert_false(told.contains(word), "nothing of the plateau, the house or the child: " + word)


func test_the_house_is_quiet_and_both_cues_are_true_in_every_state_of_it() -> void:
	for cue: String in ["home_in", "home_close"]:
		var seen := await DialogueWalk.play(FILE, cue)
		var told := "\n".join(seen)
		assert_eq(seen.size(), 3, cue)
		for word in STATES:
			assert_false(
				told.contains(word), "%s says nothing of the state of the house: %s" % [cue, word]
			)
		assert_false(told.contains("Kreide"))
	var close := await _told("home_close")
	for word: String in ["Ende", "Abschied", "Akt", "Titel", "geschafft", "zurück", "nach Hause"]:
		assert_false(close.contains(word), "no farewell, no summary: " + word)


func test_the_keeper_checks_the_hearth_not_quite_and_the_last_word_is_a_reservation() -> void:
	var seen := await DialogueWalk.play(FILE, "waechter_in")
	assert_eq(seen.size(), 9, "two lines of narration and seven of his")
	var told := "\n".join(seen)
	assert_true(
		told.contains("Herd") and told.contains("Kamin"), "a fireplace that he files as a hearth"
	)
	assert_true(told.contains("Nicht ganz geprüft"), "the rubric he makes for it")
	assert_true(
		told.contains("Ab hier prüfe ich nicht"), "he checks a part and enters what he does not"
	)
	var written := _written("waechter_in")
	assert_eq(written.size(), 9)
	assert_true(
		written[8].begins_with("Wächter: Ich behalte mir vor"), "the last word is his reservation"
	)
	assert_true(told.contains("Dank erwarte ich keinen"), "he expects no thanks and gives none")
	var his := 0
	for line in written:
		if line.begins_with("Wächter: "):
			his += 1
			assert_lte(line.trim_prefix("Wächter: ").split(" ", false).size(), 14, "short: " + line)
	assert_eq(his, 7, "seven of his, two of the narration")
	for word: String in ["Du hast", "Danke", "gut gemacht", "Vertrauen", "Angst", "Hebel", "Lampe"]:
		assert_false(told.contains(word), "no thanks, no lesson, nothing of the console: " + word)


func test_the_keeper_afterwards_is_one_visit_like_the_other_and_counts_himself_as_two() -> void:
	var first := await DialogueWalk.play(FILE, "waechter_home")
	var again := await DialogueWalk.play(FILE, "waechter_home")
	assert_eq(first, again, "no states: a visit like the other")
	assert_eq(first.size(), 4)
	assert_false(
		_written("waechter_home")[0].begins_with("Wächter: "), "the first line is narration"
	)
	assert_true("\n".join(first).contains("Ich bin Zwei"))
	assert_true("\n".join(first).contains("Nicht ganz geprüft"), "the rubric he made")
	for word: String in ["Einladung", "Setz dich", "Bleib", "Komm", "Tee"]:
		assert_false("\n".join(first).contains(word), "no invitation: " + word)


# --- The shoot in the bed -----------------------------------------------------------------------


func test_the_bed_in_the_valley_says_more_once_a_shoot_stands_in_it_and_nothing_else() -> void:
	var plain := await DialogueWalk.play(TAL, "garden_bed")
	assert_eq(plain.size(), 1, "the old word until then")
	assert_eq(plain[0], LineText.of("tal_bed_1"))
	WorldState.set_flag("house.garden_sprout")
	var seen := await DialogueWalk.play(TAL, "garden_bed")
	var told := "\n".join(seen)
	assert_eq(seen.size(), 3)
	assert_true(told.contains("Trieb") and told.contains("zwei Blättern"))
	assert_true(told.contains("nicht da, als du gegangen bist"))
	for word: String in [
		"Samen", "pflanz", "gieß", "Pflege", "Hoffnung", "Kind", "Zukunft", "Sinn"
	]:
		assert_false(told.contains(word), "nothing is planted, nothing is hoped: " + word)
	for digit: String in "0123456789":
		assert_false(told.contains(digit), "numbers are written out: " + digit)
