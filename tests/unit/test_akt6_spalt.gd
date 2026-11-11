extends GutTest
## Act VI, segment R2: what the gap and the arrival tell (docs/akt6/REGIONSBRIEFE.md, O3, O4, O5,
## O8; docs/writing/STIL.md). The look at the gap of light in the valley (it asks for nothing), the
## step into it, and the arrival in Elysia: the garden exactly as she left it, the corner of the
## picture that builds itself up, the one line that names the place, the things that are ready
## for her. Nobody speaks, nothing is explained, nothing is lamented. The scenes (the gap on the
## map, the question, the crossing, the arrival, the stages) are tested in test_akt6_spalt_szene.

const FILE := "res://content/dialogue/akt6/spalt.dialogue"
const CUES: PackedStringArray = ["gap_look", "gap_enter", "arrival"]
## What the text never says: what happened in the mountains, the child, the name of the feeling,
## the comfort, the diagnosis, the verdict on Elysia.
const NEVER: PackedStringArray = [
	"Kind",
	"Kreide",
	"Gebirge",
	"Berg",
	"Wächter",
	"Maschine",
	"Mira",
	"Leere",
	"Gefühl",
	"Trost",
	"trösten",
	"Flucht",
	"Sucht",
	"Betäuber",
	"Wirt",
	"heilen",
	"Heilung",
	"loslassen",
	"zurück",
	"Zuhause",
	"Heimat",
	"falsch",
	"gefährlich",
	"Falle",
	"Lüge",
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
	for hit in RegEx.create_from_string("\\[ID:(gap_[a-z0-9_]+)\\]").search_all(_source()):
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


## The lines of a cue as written, comments and code left out.
func _written(cue: String) -> PackedStringArray:
	var lines := PackedStringArray()
	var inside := false
	for line in _source().split("\n"):
		if line.begins_with("~ "):
			inside = line.substr(2).strip_edges() == cue
		elif inside and line.find("[ID:") > -1 and not line.begins_with("#"):
			lines.append(line.substr(0, line.find("[ID:")).strip_edges())
	return lines


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
	# the segment plans 18 lines (plus or minus five)
	assert_gte(ids.size(), 13)
	assert_lte(ids.size(), 23)
	assert_null(RegEx.create_from_string("=> (?!END)").search(_source()), "no jumps")
	assert_null(RegEx.create_from_string("(?m)^\\s*do\\s").search(_source()), "sets nothing")
	assert_false(_source().contains("set_facet"))
	assert_false(_spoken().contains("\n- "), "no answers: nobody speaks, nobody is asked")
	for cue in CUES:
		var kept := JSON.stringify(WorldState.state.to_dict())
		var seen := await DialogueWalk.play(FILE, cue)
		assert_gte(seen.size(), 3, "%s has its lines" % cue)
		assert_eq(JSON.stringify(WorldState.state.to_dict()), kept, "%s changes nothing" % cue)


func test_nothing_is_a_digit_a_shout_a_question_a_voice_or_a_verdict() -> void:
	var spoken := _spoken()
	for digit: String in "0123456789":
		assert_false(spoken.contains(digit), "numbers are written out: " + digit)
	for line in spoken.split("\n", false):
		var text := line.strip_edges()
		assert_false(text.contains("!"), "no shout: " + text)
		assert_false(text.contains("?"), "no question: " + text)
		assert_false(text.contains(":"), "narration only, nobody speaks: " + text)
	for word in NEVER:
		assert_false(spoken.contains(word), "the text never says %s" % word)
	assert_null(RegEx.create_from_string("\\bweil\\b").search(spoken), "no reason is given")


func test_the_place_is_named_once_and_only_after_the_arrival() -> void:
	for cue: String in ["gap_look", "gap_enter"]:
		assert_false("\n".join(_written(cue)).contains("Elysia"), "%s does not name it" % cue)
	var arrival := "\n".join(_written("arrival"))
	assert_eq(arrival.count("Elysia"), 1, "once, as an information")


func test_the_gap_asks_for_nothing_and_the_step_is_one_step() -> void:
	var look := _written("gap_look")
	assert_eq(look.size(), 5)
	assert_true("\n".join(look).contains("Licht") and "\n".join(look).contains("Summen"))
	var last := look[4]
	assert_true(last.contains("hindurchgehen") and last.contains("vorbei"), "go through or pass by")
	assert_false(last.contains("musst"), "and it asks for nothing")
	for word: String in ["musst", "sollst", "Komm", "Los"]:
		assert_false("\n".join(look).contains(word), "no order, no coaxing: " + word)
	var enter := await DialogueWalk.play(FILE, "gap_enter")
	assert_eq(enter.size(), 3)
	assert_true(enter[0].contains("einen einzigen"), "one step")
	for word: String in ["Abschied", "wiederkomm", "Entschluss", "entschieden", "bereit"]:
		assert_false("\n".join(enter).contains(word), "no farewell, no decision in words: " + word)


func test_the_arrival_is_the_garden_as_it_was_and_the_things_that_are_ready_for_her() -> void:
	var seen := await DialogueWalk.play(FILE, "arrival")
	var told := "\n".join(seen)
	assert_eq(seen.size(), 10)
	assert_true(
		told.contains("genau wie du ihn verlassen hast"), "nothing decayed, nothing changed"
	)
	assert_true(told.contains("Zählwerk") or told.contains("Zahl"), "the corner of the picture")
	assert_true(told.contains("Fanfare") and told.contains("Lob"), "the old systems stand ready")
	assert_true(told.contains("nichts im Bild hat es eilig"), "and nothing is asked of her")
	for word: String in ["verändert", "schlimmer", "kälter", "leer", "tot", "grau", "verfallen"]:
		assert_false(told.contains(word), "Elysia does not decay or darken: " + word)
	assert_false(told.contains("Level"), "the level is not named, it is the number in the corner")
