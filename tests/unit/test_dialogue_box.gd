extends GutTest
## The dialogue box: a stray press never picks an answer, a quick double confirm never runs
## an answer twice, back moves the text on, and a cue asked for while another conversation
## is open waits for it.

const BOX := preload("res://ui/dialogue/dialogue_box.tscn")
const TEXT := (
	"~ ask\n"
	+ "Mira: Bleibst du noch?\n"
	+ "- Ja\n"
	+ "\tdo WorldState.add_gold(100)\n"
	+ "\tMira: Gut.\n"
	+ "- Nein\n"
	+ "\tMira: Schade.\n"
	+ "=> END\n"
	+ "~ first\n"
	+ "Mira: Eins.\n"
	+ "=> END\n"
	+ "~ second\n"
	+ "Mira: Zwei.\n"
	+ "=> END\n"
)

const SANDBOX := "res://content/dialogue/sandbox/sandbox.dialogue"

var box: DialogueBox
var resource: DialogueResource
var gold_before := 0


func before_each() -> void:
	WorldState.new_game()
	Settings.set_value("text.speed", 1, false)
	resource = DialogueManager.create_resource_from_text(TEXT)
	box = BOX.instantiate()
	add_child_autofree(box)
	gold_before = _gold()


func _gold() -> int:
	return WorldState.state.elysia.gold - gold_before


func after_each() -> void:
	Settings.override("display.reduce_flashing", false)
	WorldState.new_game()


func _send(action: StringName) -> void:
	for pressed: bool in [true, false]:
		var event := InputEventAction.new()
		event.action = action
		event.pressed = pressed
		Input.parse_input_event(event)
		await wait_physics_frames(1)


func test_mashing_does_not_pick_the_first_answer() -> void:
	box.present(resource, "ask")
	await wait_seconds(0.1)
	await _send(&"interact")  # finishes typing, the answers appear
	await _send(&"interact")  # a quick second press
	await _send(&"interact")
	await wait_physics_frames(2)
	assert_true(box.is_open())
	assert_eq(_gold(), 0, "no answer was picked")
	await wait_seconds(0.4)
	await _send(&"interact")
	await wait_seconds(0.3)
	assert_eq(_gold(), 100, "a deliberate press picks the focused answer")


func test_a_double_confirm_runs_an_answer_once() -> void:
	box.present(resource, "ask")
	await wait_seconds(0.1)
	await _send(&"interact")
	await wait_seconds(0.5)
	var yes: DialogueResponse = box.line.responses[0]
	box._responses.response_selected.emit(yes)
	box._responses.response_selected.emit(yes)
	await wait_seconds(0.3)
	assert_eq(_gold(), 100, "the second confirm while the next line loads does nothing")


func test_back_moves_the_text_on() -> void:
	box.present(resource, "first")
	await wait_seconds(0.1)
	await _send(&"cancel")  # skips typing (Backspace or B; Esc is the pause menu's)
	await _send(&"cancel")
	await wait_seconds(0.3)
	assert_false(box.is_open(), "back closed the last line")


func test_a_cue_asked_for_while_another_is_open_waits() -> void:
	var holder := Node.new()
	add_child_autofree(holder)
	box.present(load(SANDBOX), "sign_pond")
	await wait_seconds(0.1)
	var shown: Array[String] = []
	box.finished.connect(func() -> void: shown.append(box.cue))
	Talk.present(holder, SANDBOX, "sign_meadow")
	await wait_seconds(0.1)
	assert_eq(box.cue, "sign_pond", "the open conversation goes on")
	for i in 10:
		await _send(&"interact")
		await wait_seconds(0.2)
		if shown.size() == 2:
			break
	assert_eq(shown, ["sign_pond", "sign_meadow"] as Array[String], "the waiting cue followed")


func test_holding_skips_but_stops_at_answers() -> void:
	box.present(resource, "ask")
	await wait_seconds(0.1)
	Input.action_press(&"interact")
	await wait_seconds(1.2)
	assert_true(box._responses.visible, "the line ran through to the answers")
	assert_eq(_gold(), 0, "holding never picks an answer")
	Input.action_release(&"interact")
	await wait_physics_frames(2)
	assert_true(box.is_open())


## Every answer button on screen, grey ones included (get_menu_items skips those).
func _on_screen() -> Array[Button]:
	var found: Array[Button] = []
	for child in box._responses.get_children():
		if child is Button and (child as Button).visible:
			found.append(child)
	return found


func _answers_shown(cue: String, source: DialogueResource = null) -> Array:
	box.present(source if source != null else resource, cue)
	await wait_seconds(0.1)
	await _send(&"interact")  # finishes typing, the answers appear
	await wait_physics_frames(3)
	return box._responses.get_menu_items()


func test_answers_that_do_not_apply_are_not_shown() -> void:
	resource = DialogueManager.create_resource_from_text(
		(
			"~ mixed\n"
			+ "Mira: Was nun?\n"
			+ "- Eins\n"
			+ "\tMira: A.\n"
			+ "- Zwei [if false /]\n"
			+ "\tMira: B.\n"
			+ "- Drei\n"
			+ "\tMira: C.\n"
			+ "=> END\n"
		)
	)
	var items := await _answers_shown("mixed")
	assert_eq(items.size(), 2, "the answer that does not apply is not in the list")
	assert_eq(_on_screen().size(), 2, "and not in grey on the screen either")
	for item: Button in items:
		assert_false(item.disabled, "no grey, unselectable answer")
	assert_eq((items[0] as Button).text, "Eins")
	assert_eq((items[1] as Button).text, "Drei")
	assert_eq(
		items[1].get_node(items[1].focus_neighbor_top), items[0], "focus walks the shown ones"
	)


func test_only_what_the_player_has_is_offered() -> void:
	# a shelf with only the stone in the pocket offers the stone, not the spoon in grey
	var haus := load("res://content/dialogue/slice/haus.dialogue") as DialogueResource
	WorldState.add_item("item_stone")
	box.present(haus, "shelf")
	for i in 12:
		if box._responses.visible:
			break
		await wait_seconds(0.2)
		await _send(&"interact")
	await wait_physics_frames(3)
	var texts: Array[String] = []
	for item: Button in box._responses.get_menu_items():
		texts.append(item.text)
	assert_eq(texts, ["Den Stein hineinlegen", "Nichts hineinlegen"] as Array[String])
	assert_eq(_on_screen().size(), 2, "the spoon is not there in grey")


func test_the_evening_story_offers_only_what_happened() -> void:
	var tal := load("res://content/dialogue/slice/tal.dialogue") as DialogueResource
	var items := await _answers_shown("evening_day", tal)
	assert_eq(items.size(), 1, "nothing to tell: only the silence")
	assert_eq(_on_screen().size(), 1)
	assert_eq((items[0] as Button).text, "…")
	box.queue_free()
	await wait_physics_frames(2)
	box = BOX.instantiate()
	add_child_autofree(box)
	WorldState.set_flag("valley.berries_eaten")
	items = await _answers_shown("evening_day", tal)
	assert_eq(items.size(), 2)
	assert_eq((items[0] as Button).text, "Die erste Brombeere war sauer.")


func test_the_cursor_stands_on_the_first_answer() -> void:
	var items := await _answers_shown("ask")
	assert_eq(box._cursor.target, items[0], "the gem marks the preselected answer")
	assert_true(items[0].has_focus())
	assert_true(box._cursor.visible)


func test_every_group_of_answers_has_one_that_always_applies() -> void:
	# hidden answers must never leave an empty list (or a lone silent exit by accident)
	var checked := 0
	for path in _dialogue_files("res://content/dialogue"):
		var result := DMCompiler.compile_string(FileAccess.get_file_as_string(path), path)
		for key: Variant in result.lines:
			var line: Dictionary = result.lines[key]
			if line.get("type") != "response" or not line.has("responses"):
				continue
			var unconditional := 0
			for id: Variant in line["responses"]:
				if not (result.lines[str(id)] as Dictionary).has("condition"):
					unconditional += 1
			checked += 1
			assert_gt(
				unconditional, 0, "%s: answers at line %s all depend on a condition" % [path, key]
			)
	assert_gt(checked, 10, "the scan found the answer groups")


func _dialogue_files(dir: String) -> PackedStringArray:
	var found := PackedStringArray()
	for file in DirAccess.get_files_at(dir):
		if file.ends_with(".dialogue"):
			found.append(dir.path_join(file))
	for sub in DirAccess.get_directories_at(dir):
		found.append_array(_dialogue_files(dir.path_join(sub)))
	return found


func _click() -> void:
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = true
	box._panel.gui_input.emit(event)
	await wait_physics_frames(2)


func test_a_click_moves_the_text_on() -> void:
	resource = DialogueManager.create_resource_from_text(
		(
			"~ long\nMira: "
			+ "Das ist eine lange Zeile, die noch eine Weile tippt. ".repeat(3)
			+ "\n=> END\n"
		)
	)
	box.present(resource, "long")
	await wait_seconds(0.1)
	assert_true(box._text.is_typing)
	await _click()
	assert_false(box._text.is_typing, "the first click finishes the line")
	await _click()
	await wait_seconds(0.3)
	assert_false(box.is_open(), "the second click moves on and closes the last line")


func test_a_click_does_not_pick_an_answer() -> void:
	var items := await _answers_shown("ask")
	await _click()
	await wait_seconds(0.2)
	assert_eq(_gold(), 0, "the panel ignores clicks while answers are shown")
	assert_true(box._responses.visible)
	assert_eq(items.size(), 2)


func test_a_voice_blip_names_the_speaker() -> void:
	var heard: Array[String] = []
	box.syllable.connect(func(who: String) -> void: heard.append(who))
	box.present(resource, "first")
	await wait_seconds(0.4)
	assert_gt(heard.size(), 0, "typing a spoken line announces its syllables")
	assert_eq(heard[0], "Mira")
	await _send(&"interact")
	await _send(&"interact")
	var narration := DialogueManager.create_resource_from_text("~ n\nEin Stein.\n=> END\n")
	heard.clear()
	box.present(narration, "n")
	await wait_seconds(0.4)
	assert_eq(heard.size(), 0, "narration has no speaker, so no syllables")


func test_calm_text_drops_moving_effects_but_keeps_pauses() -> void:
	var text := "Ein [wave amp=14 freq=5]Held[/wave]! "
	text += "[rainbow freq=0.6 sat=0.5]Legendär[/rainbow] [b]so[/b]."
	assert_eq(DialogueBox.without_motion_tags(text), "Ein Held! Legendär [b]so[/b].")
	assert_eq(DialogueBox.without_motion_tags("[shake]x[/shake]"), "x")
	assert_eq(DialogueBox.without_motion_tags("Nichts."), "Nichts.")
	Settings.override("display.reduce_flashing", true)
	box.present(load(SANDBOX), "sign_effects")
	await wait_physics_frames(4)
	assert_false("[wave" in box._text.text, "no effect tag reaches the label")
	assert_eq(box._text.get_parsed_text(), "Ein Held! Und strahlend.")
	Settings.override("display.reduce_flashing", false)


func test_confirming_skips_a_pause_that_is_still_ahead() -> void:
	resource = DialogueManager.create_resource_from_text(
		"~ w\nMira: " + "Erst das und noch mehr davon. ".repeat(3) + "[wait=5]Dann das.\n=> END\n"
	)
	box.present(resource, "w")
	await wait_seconds(0.1)
	assert_true(box._text.is_typing)
	await _send(&"interact")
	assert_false(box._text.is_typing, "the press finishes the line")
	assert_eq(box._text.visible_characters, box._text.get_total_character_count())
	await _send(&"interact")
	await wait_seconds(0.3)
	assert_false(box.is_open(), "the five seconds of [wait] did not hold the line back")
