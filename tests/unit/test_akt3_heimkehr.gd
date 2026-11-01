# gdlint: ignore=max-public-methods
extends GutTest
## Act III, segment W6: the way home. The house has changed and nobody says why: a workbench stands
## in the corner where nothing stood, the Antreiber sits at it and mends, a sheet on the wall plans
## his leisure with times, and the cat lies on him. Whoever invited the hermit gets his visit: he
## brings a chair, sits, drinks and goes. The act ends quietly with a look. Light and funny, nothing
## heavy, nothing about the wood or about reasons, nothing counted but the minutes of a tea. The
## text holds in every state (the Antreiber sits here whether he stayed at the fire or went ahead;
## the cat lies on him only when she is fed; tea has its length only for whoever sat him down in the
## wood) and without the guest. The scene (stages, chapter, autosave, the walk of the guest) is
## tested in test_akt3_heimkehr_szene, the pictures in test_akt3_heimkehr_bild, the map elsewhere.

const HK := "res://content/dialogue/akt3/heimkehr.dialogue"
const CUES: Array[String] = [
	"home_in",
	"guest_enter",
	"act3_close",
	"workbench",
	"plan_board",
	"antreiber_bench",
	"antreiber_bench_ask",
	"cat_bench",
]
## What the cues may read: nothing about how the Antreiber came into the house.
const READS: Array[String] = [
	"forest.antreiber_sat",
	"forest.flood_sat",
	"house.cat_fed",
	"house.guest_hermit",
]
## The five rows of the sheet on the wall, in the order the lines tell them.
const ROWS: Array[String] = ["Tee", "Aussicht", "Pausen", "Katze", "Besuch"]
const JOURNAL_KEYS: Array[String] = ["HOME", "DONE"]
## Words that would explain the Antreiber, name the wood or its water, give a reason or a cause,
## judge being alone, say what the player feels or call the house by a feeling. None of them may
## stand in a line, an answer or a journal row of this segment. One word per `|`; a line break
## inside the string is only for reading.
const FORBIDDEN_TEXT := """
Flut|Wasser|Schlick|Marke|Läufer|Kind|Mutter|Vater|Familie|Mama|Papa|Lied|
Summen|Laterne|Zuhause|Heim|einsam|allein|endlich|angekommen|geschafft|Ursache|Täter|
Schuld|schuld|Angst|Unfall|Regen|Sturm|Gewitter|Meer|Erinnerung|erinner|Abschied|vermiss|
Gefahr|sicher|Schutz|gesund|Fürsorge|achtsam|Punkte|Prozent|Level|Therap|Diagnos|Trauma|
optimal|Optimier|Leerlauf|Nichtstun|Entspann|Erholung|schöner|besser"""
## Phrases the earlier segments have used up; a line of this file must not say them again.
## ("Becher" is allowed here, in at most two lines: this segment redeems the cup of the hut.)
const USED_UP_TEXT := """
Atemzug|nur kurz|wohin mit|Etappen|dunkel wird|spart Zeit|Fast da|holt nichts|
klappt|pünktlich|Zahlen auf|Der Tee ist gut|Daumen|Zollstock|Dampf|Füße|auf der Stelle|
Ich sitz|ein Termin|müsste eigentlich|Zaun gezählt|als wäre es immer|wagt nicht|
leichter, als es aussieht"""
## Flags that say how the Antreiber came into the house (or where the wood stands): not read here.
const NOT_READ_TEXT := """house.antreiber_by_fire|house.antreiber_left|house.antreiber_refused|
house.antreiber_postponed|forest.antreiber_ahead|forest.antreiber_met|
forest.hermit_invited|house.workbench|valley.mira_gone"""


func _forbidden() -> PackedStringArray:
	return FORBIDDEN_TEXT.replace("\n", "").split("|", false)


func _used_up() -> PackedStringArray:
	return USED_UP_TEXT.replace("\n", "").split("|", false)


func _not_read() -> PackedStringArray:
	return NOT_READ_TEXT.replace("\n", "").split("|", false)


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


func _words(text: String) -> int:
	return text.split(" ", false).size()


## One state of the house: the cat fed or not, the tea that was made in the wood (none, at the
## board, at the mark, both), the hermit's visit done or not, the facet care, the cat named.
func _state(cat: bool, tea: String, guest: bool, care: bool, named: bool) -> void:
	WorldState.new_game()
	if cat:
		WorldState.set_flag("house.cat_fed")
	if tea == "board" or tea == "both":
		WorldState.set_flag("forest.antreiber_sat")
	if tea == "mark" or tea == "both":
		WorldState.set_flag("forest.flood_sat")
	if guest:
		WorldState.set_flag("house.guest_hermit")
	if care:
		WorldState.set_facet("care")
	if named:
		WorldState.set_cat_name("Pfeffer")


## The lines of one cue as written (tabs kept), without blank lines and comments.
func _cue_raw(cue: String) -> PackedStringArray:
	var found: PackedStringArray = []
	var inside := false
	for raw in FileAccess.get_file_as_string(HK).split("\n"):
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


## Every line of the file that carries an ID: {id, text, speaker, answer, cue}. The text is what
## the player sees (no tags, no condition); the speaker is "" for narration.
func _story_lines() -> Array[Dictionary]:
	var found: Array[Dictionary] = []
	var cue := ""
	var speaker_regex := RegEx.create_from_string("^([A-ZÄÖÜ][a-zäöüß]{1,20}):\\s+")
	for raw in FileAccess.get_file_as_string(HK).split("\n"):
		var line := raw.strip_edges()
		if line.begins_with("~ "):
			cue = line.substr(2)
			continue
		if not line.contains("[ID:"):
			continue
		var id_at := line.find("[ID:")
		var text := line.substr(0, id_at).strip_edges()
		var id := line.substr(id_at + 4, line.find("]", id_at) - id_at - 4)
		var answer := text.begins_with("- ")
		if answer:
			text = text.substr(2).strip_edges()
		if text.contains(" [if "):
			text = text.substr(0, text.find(" [if ")).strip_edges()
		var speaker := ""
		var hit := speaker_regex.search(text)
		if hit != null:
			speaker = hit.get_string(1)
			text = text.substr(hit.get_end()).strip_edges()
		found.append({"id": id, "text": text, "speaker": speaker, "answer": answer, "cue": cue})
	return found


## What one speaker says in this file, as lines (answers never).
func _spoken(speaker: String) -> Array[Dictionary]:
	var found: Array[Dictionary] = []
	for line: Dictionary in _story_lines():
		if line["speaker"] == speaker:
			found.append(line)
	return found


## The visible text of every ID of the file (answers included) plus the journal's two rows.
func _all_texts() -> PackedStringArray:
	var found: PackedStringArray = []
	for hit in RegEx.create_from_string("\\[ID:(hk_[a-z0-9_]+)\\]").search_all(
		FileAccess.get_file_as_string(HK)
	):
		found.append(LineText.of(hit.get_string(1)))
	for key: String in JOURNAL_KEYS:
		found.append(tr("QUEST_MAIN_FOREST_WAY_" + key))
	return found


## The texts the box would show for a whole walk of `cue` in the state now set (every answer that
## is allowed is tried in turn, the first one first).
func _walk_all(cue: String) -> PackedStringArray:
	var found: PackedStringArray = []
	var groups := await DialogueWalk.groups(HK, cue)
	var picks: Array[PackedStringArray] = [PackedStringArray([""])]
	if not groups.is_empty():
		picks = []
		for answer: String in groups[0]:
			picks.append(PackedStringArray([answer]))
	for pick: PackedStringArray in picks:
		for text: String in await DialogueWalk.play(HK, cue, pick):
			if not text.is_empty():  # the line that carries a group of answers has no text
				found.append(text)
	return found


# --- The file and what it sets -----------------------------------------------------------------


func test_the_file_has_every_cue_the_map_and_the_scene_name() -> void:
	var cues := (load(HK) as DialogueResource).get_cues()
	for cue: String in CUES:
		assert_true(cue in cues, "cue %s" % cue)


func test_the_file_stays_inside_its_line_budget_of_the_contract() -> void:
	var narrated := 0
	for line: Dictionary in _story_lines():
		if not line["answer"]:
			narrated += 1
	assert_between(
		narrated, 26, 34, "about twenty-eight lines were planned, thirty-four is the limit"
	)


func test_every_id_is_a_draft_of_this_file_and_is_there_once() -> void:
	var seen := {}
	var found := 0
	for line: Dictionary in _story_lines():
		var id: String = line["id"]
		assert_true(id.begins_with("hk_"), "prefix of %s" % id)
		assert_false(seen.has(id), "%s is there once" % id)
		seen[id] = true
		found += 1
	assert_eq(found, 37, "thirty-two lines and five answers")
	for raw in FileAccess.get_file_as_string(HK).split("\n"):
		if raw.contains("[ID:"):
			assert_true(raw.contains("[#draft]"), "a draft: %s" % raw)
			assert_false(raw.contains("[#ph]"), "no placeholder: %s" % raw)


func test_no_two_lines_say_the_same_words() -> void:
	var seen := {}
	for line: Dictionary in _story_lines():
		if line["answer"]:
			continue
		var text: String = line["text"]
		assert_false(seen.has(text), "said twice: %s" % text)
		seen[text] = true


func test_nothing_but_the_name_of_the_cat_is_set_started_advanced_or_given() -> void:
	# a static scan of every effect in the file, whatever a walk would need to reach it
	var found: Array[String] = []
	var regex := RegEx.create_from_string("^\\s*do WorldState\\.(\\w+)\\((.*)\\)\\s*$")
	for raw in FileAccess.get_file_as_string(HK).split("\n"):
		var hit := regex.search(raw)
		if hit != null:
			found.append("%s(%s)" % [hit.get_string(1), hit.get_string(2)])
	assert_eq(found, _names(['set_flag("house.cat_naming")']), "one effect: the cat is to be named")
	var effect_lines := 0
	for raw in FileAccess.get_file_as_string(HK).split("\n"):
		if raw.strip_edges().begins_with("do "):
			effect_lines += 1
	assert_eq(effect_lines, 1, "and no other kind of effect")


func test_the_cues_leave_stages_beats_chapter_sound_and_pictures_to_the_scene() -> void:
	var source := FileAccess.get_file_as_string(HK)
	var needles: Array[String] = [
		"AudioDirector",
		"sfx",
		"Beat.",
		"Chapter.",
		"advance_quest",
		"start_quest",
		"complete_objective",
		"set_facet",
		"add_item",
		"fragment.",
		"melody.",
		"house.workbench",
		'set_flag("house.guest_hermit',
	]
	for needle: String in needles:
		for raw in source.split("\n"):
			if raw.begins_with("#"):
				continue
			assert_false(raw.contains(needle), "'%s' in a statement: %s" % [needle, raw])


func test_the_cues_read_only_what_every_state_shares() -> void:
	var read := {}
	var regex := RegEx.create_from_string('has_flag\\("([a-z_.0-9]+)"\\)')
	var facets := {}
	var facet_regex := RegEx.create_from_string('has_facet\\("([a-z_]+)"\\)')
	for raw in FileAccess.get_file_as_string(HK).split("\n"):
		if raw.begins_with("#"):
			continue
		for hit in regex.search_all(raw):
			read[hit.get_string(1)] = true
		for hit in facet_regex.search_all(raw):
			facets[hit.get_string(1)] = true
	var found := _names(read.keys())
	found.sort()
	assert_eq(found, READS, "the flags the file reads")
	for flag: String in _not_read():
		assert_false(read.has(flag), "'%s' is not read: the text holds in every state" % flag)
	assert_eq(facets.keys(), ["care"], "the facet care is the only one read")


func test_the_reader_of_each_flag_is_where_the_picture_needs_it() -> void:
	var cat := 0
	var tea := 0
	var guest := 0
	for raw in FileAccess.get_file_as_string(HK).split("\n"):
		if raw.begins_with("#"):
			continue
		if raw.contains('has_flag("house.cat_fed")'):
			cat += 1
		if raw.contains("forest.antreiber_sat") and raw.contains("forest.flood_sat"):
			tea += 1
		if raw.contains('has_flag("house.guest_hermit")'):
			guest += 1
	assert_eq(cat, 3, "the cat: the arrival, the visit and the bench's talk")
	assert_eq(tea, 1, "tea is told in one place, with both of its flags")
	assert_eq(guest, 2, "the visit shows in the sheet and in the last line, nowhere else")


func test_every_cue_can_be_walked_in_every_state_and_says_something() -> void:
	var walked := 0
	for cat: bool in [false, true]:
		for tea: String in ["none", "board", "mark", "both"]:
			for guest: bool in [false, true]:
				for named: bool in [false, true]:
					_state(cat, tea, guest, true, named)
					for cue: String in CUES:
						if cue == "antreiber_bench_ask":
							continue
						var seen := await _walk_all(cue)
						walked += 1
						assert_gt(seen.size(), 0, "%s says something" % cue)
						for text: String in seen:
							assert_false(
								text.contains("{{"), "%s: a token left in: %s" % [cue, text]
							)
							assert_false(
								text.contains("WorldState"), "%s: code in: %s" % [cue, text]
							)
	assert_eq(walked, 224, "seven cues in thirty-two states")


func test_without_the_guest_no_line_needs_him() -> void:
	# no care, no invitation, no visit: the way home is whole without the hermit
	var cues: Array[String] = [
		"home_in", "act3_close", "workbench", "plan_board", "antreiber_bench", "cat_bench"
	]
	for cat: bool in [false, true]:
		for tea: String in ["none", "board", "mark", "both"]:
			for care: bool in [false, true]:
				_state(cat, tea, false, care, false)
				for cue: String in cues:
					for text: String in await _walk_all(cue):
						for word: String in ["Einsiedler", "Stuhl", "Gast"]:
							assert_false(text.contains(word), "%s needs a guest: %s" % [cue, text])
	_state(false, "none", false, false, false)
	var closing := await DialogueWalk.play(HK, "act3_close")
	assert_eq(closing, PackedStringArray([LineText.of("hk_close_2")]), "one line, a look")


# --- Arriving ----------------------------------------------------------------------------------


func test_the_arrival_shows_the_bench_the_man_and_his_denial() -> void:
	_state(false, "none", false, false, false)
	var seen := await DialogueWalk.play(HK, "home_in")
	assert_eq(seen, PackedStringArray([LineText.of("hk_in_1"), LineText.of("hk_in_3")]))
	var text := _say(["hk_in_1", "hk_in_3"])
	for word: String in ["Ecke", "Werkbank", "Schraubstock", "Antreiber", "nicht gewartet", "Bank"]:
		assert_string_contains(text, word)
	assert_string_contains(LineText.of("hk_in_1"), "nichts stand", "the corner was empty")
	assert_string_contains(LineText.of("hk_in_3"), "Ich hab nicht gewartet", "he denies it")
	assert_string_contains(
		LineText.of("hk_in_3"), "Die Bank hat gedauert", "and talks of the bench"
	)


func test_the_cat_is_on_him_only_when_she_is_fed() -> void:
	_state(true, "none", false, false, false)
	var fed := await DialogueWalk.play(HK, "home_in")
	assert_eq(fed.size(), 3)
	assert_eq(fed[1], LineText.of("hk_in_2"))
	assert_string_contains(LineText.of("hk_in_2"), "Katze")
	assert_string_contains(LineText.of("hk_in_2"), "Knien")
	assert_string_contains(LineText.of("hk_in_2"), "volles Glas", "he sits as if he carried one")
	_state(false, "none", false, false, false)
	var unfed := await DialogueWalk.play(HK, "home_in")
	assert_false(_has(unfed, "hk_in_2"), "the cat sits at the window")
	for text: String in unfed:
		assert_false(text.contains("Katze"), "no cat in the corner: %s" % text)


func test_the_arrival_names_neither_tea_nor_the_way_he_came() -> void:
	for tea: String in ["none", "board", "mark", "both"]:
		_state(true, tea, false, true, false)
		var seen := await DialogueWalk.play(HK, "home_in")
		assert_eq(seen.size(), 3, "the same three lines in every state of the wood")
		for text: String in seen:
			assert_false(text.contains("Tee"), "tea is for the bench: %s" % text)
			assert_false(text.contains("Feuer"), "he is not at the fire any more: %s" % text)


# --- The visit ---------------------------------------------------------------------------------


func test_the_hermit_brings_a_chair_the_antreiber_measures_it_and_it_fits() -> void:
	_state(true, "none", true, true, false)
	var seen := await DialogueWalk.play(HK, "guest_enter")
	assert_eq(seen.size(), 5)
	for index in 3:
		assert_eq(seen[index], LineText.of("hk_guest_%d" % (index + 1)))
	assert_string_contains(LineText.of("hk_guest_1"), "Stuhl hab ich mitgebracht")
	assert_string_contains(LineText.of("hk_guest_2"), "Zwei Finger zu hoch")
	assert_string_contains(LineText.of("hk_guest_3"), "Er passt mir")
	assert_eq(_spoken("Einsiedler").size(), 3, "three lines of his in the file")
	var order: Array[String] = []
	for line: Dictionary in _story_lines():
		if line["cue"] == "guest_enter" and line["speaker"] != "":
			order.append(line["speaker"])
	assert_eq(order, _names(["Einsiedler", "Antreiber", "Einsiedler"]), "he, the measurer, he")


func test_he_wipes_a_cup_that_was_clean_and_the_player_fills_it() -> void:
	var cup := LineText.of("hk_guest_4")
	for word: String in ["Becher", "Ärmel", "einmal rund herum", "schon sauber", "Flasche"]:
		assert_string_contains(cup, word)
	var cups := 0
	for line: Dictionary in _story_lines():
		if line["text"].contains("Becher"):
			cups += 1
	assert_lte(cups, 2, "the cup is redeemed in at most two lines")
	assert_eq(cups, 1)


func test_the_second_feeding_is_a_gesture_and_the_cat_stays_where_she_lies() -> void:
	_state(true, "none", true, true, false)
	var fed := await DialogueWalk.play(HK, "guest_enter")
	assert_true(_has(fed, "hk_guest_5") and not _has(fed, "hk_guest_6"))
	var text := LineText.of("hk_guest_5")
	for word: String in [
		"Katze",
		"Räucherfisch",
		"wirft",
		"frisst",
		"ohne die Augen zu öffnen",
		"bleibt, wo sie liegt"
	]:
		assert_string_contains(text, word)
	_state(false, "none", true, true, false)
	var unfed := await DialogueWalk.play(HK, "guest_enter")
	assert_true(_has(unfed, "hk_guest_6") and not _has(unfed, "hk_guest_5"))
	for word: String in ["Fensterbrett", "Scheibe", "bleibt, wo sie sitzt"]:
		assert_string_contains(LineText.of("hk_guest_6"), word)
	assert_false(LineText.of("hk_guest_6").contains("frisst"), "she is not fed through a window")


func test_the_chair_stays_and_he_does_not_move_in() -> void:
	_state(false, "none", true, false, false)
	var seen := await DialogueWalk.play(HK, "act3_close")
	assert_eq(seen.size(), 2)
	assert_eq(seen[0], LineText.of("hk_close_1"))
	assert_string_contains(LineText.of("hk_close_1"), "Der Stuhl bleibt")
	assert_string_contains(LineText.of("hk_close_1"), "Tee ist ein Grund", "the reason is tea")
	for word: String in ["ziehe", "zieh ein", "bleibe jetzt", "für immer", "immer wieder", "jeden"]:
		assert_false(_say(["hk_close_1"]).contains(word), "he does not move in: %s" % word)
	assert_eq(_spoken("Einsiedler")[2]["id"], "hk_close_1")


func test_the_act_ends_on_a_look_and_not_on_a_sentence() -> void:
	var last := LineText.of("hk_close_2")
	for word: String in ["Werkbank", "Fenster", "Blatt an der Wand", "Dann nirgends hin"]:
		assert_string_contains(last, word)
	var statements := _statements("act3_close")
	assert_true(statements[statements.size() - 1].contains("[ID:hk_close_2]"), "last in the file")
	for line: Dictionary in _story_lines():
		if line["id"] == "hk_close_2":
			assert_eq(line["speaker"], "", "narration, nobody says it")
	_state(true, "both", true, true, true)
	var seen := await DialogueWalk.play(HK, "act3_close")
	assert_eq(seen[seen.size() - 1], last, "it is the last line in every state")
	for word: String in ["Plan", "Wert", "Tag", "Lehre", "gelernt", "Ruhe", "Frieden"]:
		assert_false(last.contains(word), "it explains nothing: %s" % word)


# --- The bench and the sheet -------------------------------------------------------------------


func test_the_bench_says_what_the_picture_shows_and_nothing_else() -> void:
	_state(true, "both", true, true, true)
	var seen := await DialogueWalk.play(HK, "workbench")
	assert_eq(seen.size(), 4)
	var text := _say(["hk_bench_1", "hk_bench_2", "hk_bench_3", "hk_bench_4"])
	for word: String in [
		"Schraubstock",
		"Brett",
		"Lineal",
		"Hammer",
		"Glas Nägel",
		"Stapel Schindeln",
		"Latte",
		"Zwei Nägel",
		"dritte liegt vor dem Stapel",
		"roter Kreidestrich",
		"Vorderkante",
		"Späne",
	]:
		assert_string_contains(text, word)
	assert_eq(text.count("Lineal"), 2, "the ruler is named and then is what drew the line")
	assert_eq((await DialogueWalk.groups(HK, "workbench")).size(), 0, "it is only looked at")
	for word: String in ["Antreiber", "sein", "Plan", "Zeit", "Katze"]:
		assert_false(text.contains(word), "the bench says nothing about him: %s" % word)
	var before := WorldState.state.flags.duplicate()
	await DialogueWalk.play(HK, "workbench")
	assert_eq(_added(before), _names([]), "looking at a bench sets nothing")


func test_the_sheet_has_five_rows_and_each_is_told_once() -> void:
	_state(false, "none", false, false, false)
	var seen := await DialogueWalk.play(HK, "plan_board")
	assert_eq(seen.size(), 4, "without the visit four lines tell five rows")
	var text := _say(["hk_plan_2", "hk_plan_3", "hk_plan_4"])
	for row: String in ROWS:
		assert_eq(text.count("»" + row), 1, "row %s is on the sheet once" % row)
	var sheet := LineText.of("hk_plan_1")
	for word: String in ["Regal", "Fenster", "Blatt", "rotem Streifen", "Uhrzeiten", "Posten"]:
		assert_string_contains(sheet, word)
	assert_string_contains(LineText.of("hk_plan_3"), "Am Ende jeder Zeile steht ein Strich")


func test_the_sheet_plans_tea_and_a_view_with_times_and_the_pauses_stay_on_it() -> void:
	var plan := LineText.of("hk_plan_2")
	assert_string_contains(plan, "Viertel nach drei")
	assert_string_contains(plan, "Viertel vor vier")
	assert_string_contains(plan, "Tee, sieben Minuten")
	assert_string_contains(plan, "nur bei Sicht", "the view is planned only if there is one")
	assert_string_contains(LineText.of("hk_plan_3"), "»Pausen«")
	assert_string_contains(
		LineText.of("hk_plan_3"),
		"nicht ausgewischt",
		"the wiped stroke of the board in the wood is back"
	)
	var quoted := RegEx.create_from_string("»([^«]*)«")
	var found := 0
	for id: String in ["hk_plan_2", "hk_plan_3", "hk_plan_4", "hk_plan_5"]:
		for hit in quoted.search_all(LineText.of(id)):
			found += 1
			var item := hit.get_string(1)
			assert_false(item.contains(":"), "no colon on the sheet: %s" % item)
			assert_null(RegEx.create_from_string("[0-9]").search(item), "no digit: %s" % item)
			assert_false(item.begins_with("Nichts"), "no row for doing nothing: %s" % item)
	assert_gte(found, 8, "the quoted rows and times were read")


func test_the_cat_and_the_guest_cannot_be_planned_and_the_sheet_says_so() -> void:
	var line := LineText.of("hk_plan_4")
	assert_string_contains(line, "»Katze«")
	assert_string_contains(line, "»wann sie will«")
	assert_string_contains(line, "»Besuch«")
	assert_string_contains(line, "»unangemeldet«")
	assert_eq(LineText.of("hk_plan_2").count("Minuten"), 2, "only the minutes of a tea are counted")
	var counted := RegEx.create_from_string("(?i)\\b(jeden tag|täglich|jede woche|besuche|tage)\\b")
	for text: String in _all_texts():
		assert_null(counted.search(text), "visits and days are not counted: %s" % text)


func test_the_visit_is_written_on_the_sheet_only_after_it() -> void:
	_state(false, "none", false, false, false)
	var before := await DialogueWalk.play(HK, "plan_board")
	_state(false, "none", true, false, false)
	var after := await DialogueWalk.play(HK, "plan_board")
	assert_eq(before.size(), 4)
	assert_eq(after.size(), 5)
	assert_false(_has(before, "hk_plan_5"))
	assert_eq(after[4], LineText.of("hk_plan_5"))
	for word: String in ["Einsiedler", "»Besuch«", "Dauer", "»offen«"]:
		assert_string_contains(LineText.of("hk_plan_5"), word)
	for text: String in before:
		assert_false(text.contains("Einsiedler"), "nobody is named before he came: %s" % text)
	assert_eq((await DialogueWalk.groups(HK, "plan_board")).size(), 0, "it is only looked at")


# --- The Antreiber at the bench ----------------------------------------------------------------


func test_tea_has_its_length_only_for_whoever_sat_him_down_in_the_wood() -> void:
	for tea: String in ["none", "board", "mark", "both"]:
		_state(false, tea, false, false, false)
		var seen := await DialogueWalk.play(HK, "antreiber_bench")
		var sat := tea != "none"
		assert_eq(_has(seen, "hk_antr_1"), sat, "the length of the tea after '%s'" % tea)
		assert_eq(
			_has(seen, "hk_antr_2"), not sat, "the tea that waits for somebody after '%s'" % tea
		)
		assert_true(_has(seen, "hk_antr_3"), "the work is told in every state")
	assert_string_contains(LineText.of("hk_antr_1"), "Sieben Minuten, zu zweit zehn")
	assert_string_contains(LineText.of("hk_antr_2"), "Wenn jemand welchen macht")
	for id: String in ["hk_antr_1", "hk_antr_2"]:
		assert_string_contains(LineText.of(id), "Tee steht drauf", "both are on his sheet")
	assert_false(
		LineText.of("hk_antr_2").contains("Minuten"), "no length without the tea in the wood"
	)


func test_neither_tea_line_rewards_or_punishes() -> void:
	var judging := RegEx.create_from_string(
		"(?i)\\b(danke|dank|gut|schön|leider|schade|strafe|verdient|du|dir|dich)\\b"
	)
	for id: String in ["hk_antr_1", "hk_antr_2"]:
		var text := LineText.of(id)
		assert_null(judging.search(text), "it rewards or punishes in: %s" % text)


func test_the_bench_talk_in_every_state_has_the_work_and_the_cat_only_when_she_lies_on_him(
) -> void:
	for cat: bool in [false, true]:
		_state(cat, "none", false, false, false)
		var seen := await DialogueWalk.play(HK, "antreiber_bench")
		assert_eq(_has(seen, "hk_antr_4"), cat, "the cat line with the cat: %s" % cat)
		assert_true(_has(seen, "hk_antr_3"))
	assert_string_contains(LineText.of("hk_antr_3"), "Zaun erledigt")
	assert_string_contains(LineText.of("hk_antr_3"), "Lücke", "the goat's gap stays")
	assert_string_contains(
		LineText.of("hk_antr_9"), "Am Dach ist eine Reihe vorgesehen", "the roof is not done"
	)
	assert_string_contains(LineText.of("hk_antr_4"), "Aufstehen")
	assert_string_contains(LineText.of("hk_antr_4"), "Verschoben")
	assert_false(LineText.of("hk_antr_4").contains("Katze"), "he does not explain her")


func test_helping_the_silence_and_tea_each_have_their_own_answer_of_his() -> void:
	_state(true, "none", false, true, false)
	var helped := await DialogueWalk.play(HK, "antreiber_bench", PackedStringArray(["Helfen"]))
	assert_true(_has(helped, "hk_antr_5"))
	assert_false(_has(helped, "hk_antr_6") or _has(helped, "hk_antr_8"))
	for word: String in ["Brett", "Schraubstock", "lässt dich"]:
		assert_string_contains(LineText.of("hk_antr_5"), word)
	var tea := await DialogueWalk.play(HK, "antreiber_bench", PackedStringArray(["Tee machen"]))
	assert_true(_has(tea, "hk_antr_6") and _has(tea, "hk_antr_7"))
	assert_false(_has(tea, "hk_antr_5") or _has(tea, "hk_antr_8"))
	assert_string_contains(LineText.of("hk_antr_6"), "Blatt an der Wand")
	assert_string_contains(LineText.of("hk_antr_7"), "Zu früh")
	assert_string_contains(LineText.of("hk_antr_7"), "Ich lass es gelten")
	var silent := await DialogueWalk.play(HK, "antreiber_bench", PackedStringArray(["…"]))
	assert_true(_has(silent, "hk_antr_8"))
	assert_false(_has(silent, "hk_antr_5") or _has(silent, "hk_antr_6"))
	assert_string_contains(LineText.of("hk_antr_8"), "Vierteldrehung")
	assert_eq(_flag_names(), _names(["house.cat_fed"]), "talking to him sets nothing")
	assert_true(WorldState.has_facet("care"), "and takes nothing")


func test_tea_is_an_answer_only_for_whoever_has_the_facet() -> void:
	_state(false, "none", false, false, false)
	var without := await DialogueWalk.groups(HK, "antreiber_bench")
	assert_eq(without.size(), 1)
	assert_eq(without[0], PackedStringArray(["Helfen.", "…"]), "helping and the silence")
	_state(false, "none", false, true, false)
	var with := await DialogueWalk.groups(HK, "antreiber_bench")
	assert_eq(with[0], PackedStringArray(["Helfen.", "Tee machen.", "…"]), "tea between them")
	assert_eq(with[0][with[0].size() - 1], "…", "the silence stays the last answer")
	_state(false, "both", false, true, false)
	var sat := await DialogueWalk.groups(HK, "antreiber_bench")
	assert_eq(sat[0].size(), 3, "tea is offered again, as often as she likes")
	var conditional: Array[String] = []
	for raw in FileAccess.get_file_as_string(HK).split("\n"):
		if raw.begins_with("- ") and raw.contains("[if "):
			conditional.append(raw)
	assert_eq(conditional.size(), 1, "tea is the only answer that can be missing")
	assert_true(conditional[0].contains('has_facet("care")'))


func test_the_antreiber_is_one_of_two_voices_and_never_cries_asks_or_speaks_long() -> void:
	var spoken := _spoken("Antreiber")
	assert_eq(spoken.size(), 8, "eight lines of his")
	var words := 0
	for line: Dictionary in spoken:
		var text: String = line["text"]
		words += _words(text)
		assert_false(text.contains("!"), "he only cries while he drives: %s" % text)
		assert_false(text.contains("?"), "he asks nothing here: %s" % text)
		assert_false(text.contains(":"), "no colon in a spoken line: %s" % text)
		assert_lte(_words(text), 10, "short: %s" % text)
	assert_lt(float(words) / spoken.size(), 7.0, "fewer than seven words a line on average")
	var speakers := {}
	for line: Dictionary in _story_lines():
		if line["speaker"] != "":
			speakers[line["speaker"]] = true
	var found := _names(speakers.keys())
	found.sort()
	assert_eq(found, _names(["Antreiber", "Einsiedler"]), "no other voice, and none for the cat")


func test_his_lines_have_times_prices_or_a_contradiction_and_no_meaning() -> void:
	var tell := RegEx.create_from_string(
		(
			"(?i)\\b(Minuten|Viertel|vier|drei|Finger|hoch|Plan|Posten|Dauer|vorgesehen"
			+ "|verschoben|steht drauf|gewartet|gedauert|gelten|zu früh|erledigt)\\b"
		)
	)
	for line: Dictionary in _spoken("Antreiber"):
		var text: String = line["text"]
		assert_not_null(tell.search(text), "a clerk's word in: %s" % text)
		for word: String in [
			"bedeutet", "fühl", "Gefühl", "Grund", "warum", "Wald", "gelernt", "Lehre", "wichtig"
		]:
			assert_false(text.contains(word), "he does not say what it means: %s" % text)
	assert_string_contains(LineText.of("hk_in_3"), "nicht", "the one contradiction is a denial")


# --- The Einsiedler's voice --------------------------------------------------------------------


func test_the_hermit_offers_and_never_asks_cries_or_judges() -> void:
	var spoken := _spoken("Einsiedler")
	assert_eq(spoken.size(), 3)
	for line: Dictionary in spoken:
		var text: String = line["text"]
		assert_false(text.contains("?") or text.contains("!"), "no question, no cry: %s" % text)
		assert_lte(_words(text), 7, "seven words at most: %s" % text)
		for word: String in [
			"Hütte", "schöner", "besser", "allein", "Alleinsein", "ruhig", "Ruhe", "Welt", "draußen"
		]:
			assert_false(text.contains(word), "he does not compare or judge: %s" % text)
	assert_eq(_words(LineText.of("hk_guest_3")), 3)


# --- The cat -----------------------------------------------------------------------------------


func test_the_cat_sleeps_on_him_and_is_named_only_in_a_pair() -> void:
	_state(true, "none", false, false, false)
	var unnamed := await DialogueWalk.play(HK, "cat_bench", PackedStringArray(["…"]))
	assert_true(_has(unnamed, "hk_cat_2") and _has(unnamed, "hk_cat_3"))
	for word: String in ["Katze", "schläft auf dem Antreiber", "Werkbank", "freie Hand"]:
		assert_string_contains(LineText.of("hk_cat_2"), word)
	_state(true, "none", false, false, true)
	var named := await DialogueWalk.play(HK, "cat_bench")
	assert_eq(named.size(), 1)
	assert_true(named[0].begins_with("Pfeffer schläft auf dem Antreiber"), named[0])
	assert_false(named[0].contains("Katze"), "the name replaces 'die Katze', it does not join it")
	assert_eq(
		(await DialogueWalk.groups(HK, "cat_bench")).size(), 0, "a named cat is only looked at"
	)
	var tokens := 0
	for raw in FileAccess.get_file_as_string(HK).split("\n"):
		if raw.begins_with("#"):
			continue
		if raw.contains("cat_name()"):
			tokens += 1
	assert_eq(tokens, 2, "one pair: the check and the line, no more")


func test_the_cat_can_be_named_here_and_nothing_else_happens() -> void:
	_state(true, "none", false, false, false)
	var before := WorldState.state.flags.duplicate()
	var seen := await DialogueWalk.play(HK, "cat_bench", PackedStringArray(["Namen"]))
	assert_eq(
		seen, PackedStringArray([LineText.of("hk_cat_2")]), "only her description comes first"
	)
	assert_eq(_added(before), _names(["house.cat_naming"]), "the scene opens the entry")
	assert_eq(WorldState.cat_name(), "", "the cue gives no name, the player does")
	assert_eq(WorldState.state.inventory.size(), 0)


func test_the_silence_strokes_her_and_the_man_does_not_move() -> void:
	_state(true, "none", false, false, false)
	var groups := await DialogueWalk.groups(HK, "cat_bench")
	assert_eq(groups.size(), 1)
	assert_eq(groups[0], PackedStringArray(["Ihr einen Namen geben.", "…"]))
	assert_eq(groups[0][groups[0].size() - 1], "…", "the silence is last")
	var before := WorldState.state.flags.duplicate()
	await DialogueWalk.play(HK, "cat_bench", PackedStringArray(["…"]))
	assert_eq(_added(before), _names([]), "stroking a cat sets nothing")
	for word: String in ["streichst", "Rücken", "mitgemeint"]:
		assert_string_contains(LineText.of("hk_cat_3"), word)


func test_the_cat_has_no_voice_and_no_thought() -> void:
	var thinks := RegEx.create_from_string(
		"(?i)\\b(denkt|weiß|will|fragt sich|findet|möchte|glaubt|wundert)\\b"
	)
	for line: Dictionary in _story_lines():
		assert_ne(line["speaker"], "Katze", "she does not speak")
		var text: String = line["text"]
		if line["cue"] in ["guest_enter", "cat_bench", "home_in"] and line["speaker"] == "":
			assert_null(thinks.search(text), "a thought of the cat in: %s" % text)
	var voices := FileAccess.get_file_as_string("res://content/dialogue/voices.json")
	assert_false(voices.contains("Katze"), "no voice for her")


# --- The journal -------------------------------------------------------------------------------


func test_the_journal_closes_the_hero_quest_with_two_plain_rows() -> void:
	for key: String in JOURNAL_KEYS:
		var full := "QUEST_MAIN_FOREST_WAY_" + key
		var text := tr(full)
		assert_ne(text, full, "the row %s is there" % key)
		assert_null(RegEx.create_from_string("[0-9]").search(text), "no digit in %s" % key)
		assert_null(
			RegEx.create_from_string("[!?…:]").search(text), "no cry, question or colon in %s" % key
		)
		assert_true(text.begins_with("Die Hecke") or text.begins_with("Im Haus"), text)
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
			"endlich",
			"angekommen",
			"Fürsorge",
		]:
			assert_false(text.contains(word), "'%s' in the journal row %s: %s" % [word, key, text])
	assert_string_contains(tr("QUEST_MAIN_FOREST_WAY_HOME"), "Ich gehe")
	assert_string_contains(tr("QUEST_MAIN_FOREST_WAY_HOME"), "Hecke")
	assert_string_contains(tr("QUEST_MAIN_FOREST_WAY_HOME"), "Haus")
	assert_string_contains(tr("QUEST_MAIN_FOREST_WAY_DONE"), "Wald")
	assert_ne(tr("QUEST_MAIN_FOREST_WAY_HOME"), tr("QUEST_MAIN_FOREST_WAY_NIGHT"))


func test_the_journal_holds_for_both_ways_back_and_every_state_of_the_house() -> void:
	# the way back is a gap in the hedge whichever door she took; the closing row names nothing that
	# only some players have (the hermit, the cat, the tea, a chair) and no way of how she got in
	var home := tr("QUEST_MAIN_FOREST_WAY_HOME")
	for word: String in [
		"Nachtwald", "Bachlauf", "Lichtung", "Waldweg", "Süden", "Bach", "Pfad", "Wald"
	]:
		assert_false(home.contains(word), "'%s' ties the row to one way: %s" % [word, home])
	var done := tr("QUEST_MAIN_FOREST_WAY_DONE")
	for word: String in ["Einsiedler", "Katze", "Tee", "Stuhl", "Besuch", "Antreiber", "Gast"]:
		assert_false(done.contains(word), "'%s' is not true for everybody: %s" % [word, done])
	assert_false(
		tr("QUEST_MAIN_FOREST_WAY_WOOD").contains("Flut"), "the hero's journal keeps its secret"
	)


# --- What it never says ------------------------------------------------------------------------


func test_narration_has_no_colon_question_cry_or_ellipsis_and_no_digit() -> void:
	var checked := 0
	for line: Dictionary in _story_lines():
		if line["answer"] or line["speaker"] != "":
			continue
		var text: String = line["text"]
		checked += 1
		for mark: String in [":", "?", "!", "…"]:
			assert_false(text.contains(mark), "%s in narration: %s" % [mark, text])
		assert_null(RegEx.create_from_string("[0-9]").search(text), "a digit in: %s" % text)
	assert_gt(checked, 20, "every line of narration was read, 24 at the time of writing")


func test_every_group_has_an_unconditional_answer_and_the_silence_last() -> void:
	# a static scan: every group of the file (ContentValidator checks that no choice is a fake one)
	var groups := 0
	for cue: String in (load(HK) as DialogueResource).get_cues():
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
	assert_eq(groups, 2, "the bench's talk and the cat are the two groups")


func test_the_answers_are_plain_short_and_never_cry_or_ask() -> void:
	var answers := 0
	for line: Dictionary in _story_lines():
		if not line["answer"]:
			continue
		answers += 1
		for mark: String in ["!", "?", ":"]:
			assert_false(line["text"].contains(mark), "%s in an answer: %s" % [mark, line["text"]])
		assert_lt(_words(line["text"]), 5, "an answer is short: %s" % line["text"])
	assert_eq(answers, 5)
	for answer: String in ["Helfen.", "Tee machen.", "Ihr einen Namen geben."]:
		assert_true(FileAccess.get_file_as_string(HK).contains("- " + answer), answer)


func test_every_effect_stands_after_the_lines_of_its_branch() -> void:
	# what is set stands at the end of its branch; the only effect is the answer that names the cat
	var effects := 0
	var raws := FileAccess.get_file_as_string(HK).split("\n")
	for index in raws.size():
		var raw := raws[index]
		var statement := raw.strip_edges()
		if not statement.begins_with("do WorldState."):
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
	assert_eq(effects, 1)


func test_nothing_explains_and_nothing_names_a_child_a_cause_the_wood_or_a_feeling() -> void:
	var reasons := RegEx.create_from_string(
		"(?i)\\b(weil|deshalb|seitdem|damals|darum|deswegen|daher|denn|tot|tote|totes|tod)\\b"
	)
	var texts := _all_texts()
	assert_gt(texts.size(), 36, "every line, answer and journal row was collected")
	for text: String in texts:
		for word: String in _forbidden():
			assert_false(text.contains(word), "'%s' in: %s" % [word, text])
		assert_null(reasons.search(text), "a reason is given in: %s" % text)


func test_no_line_says_a_phrase_the_earlier_segments_have_used_up() -> void:
	var texts := _all_texts()
	assert_gt(texts.size(), 36)
	for text: String in texts:
		for phrase: String in _used_up():
			assert_false(text.contains(phrase), "'%s' is used up, in: %s" % [phrase, text])


func test_the_gag_stands_in_the_house_and_the_wood_stays_unnamed() -> void:
	# after the heavy thing in the clearing no joke followed (Bible §45); here, in the house, the
	# Antreiber's gag comes back without one word of where it came from
	for text: String in _all_texts():
		for word: String in ["Wald", "Lichtung", "Bach", "Pfad", "Hütte", "Nachtwald"]:
			if text.begins_with("Die Hecke") or text.begins_with("Im Haus riecht"):
				continue
			assert_false(
				text.contains(word), "'%s' brings the wood into the house: %s" % [word, text]
			)
	var gag := _say(["hk_plan_2", "hk_plan_3", "hk_plan_4", "hk_antr_1", "hk_antr_4", "hk_antr_7"])
	for word: String in ["Tee", "Aussicht", "Pausen", "Aufstehen", "Viertel"]:
		assert_string_contains(gag, word)
