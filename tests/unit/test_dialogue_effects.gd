extends GutTest
## Text emphasis (Polish round 2): BBCode effects reach the dialogue label in both UI skins,
## and the pauses of "[wait=...]" end up as inline mutations of the line, not as text.

const BOX := preload("res://ui/dialogue/dialogue_box.tscn")
const SANDBOX := preload("res://content/dialogue/sandbox/sandbox.dialogue")
const TAL := preload("res://content/dialogue/slice/tal.dialogue")
const ELYSIA := preload("res://content/dialogue/slice/elysia.dialogue")


func before_each() -> void:
	WorldState.new_game()
	Settings.override("text.speed", 3)


func after_each() -> void:
	Settings.override("text.speed", 1)
	WorldState.new_game()


func _show(mode: GameState.UiMode, resource: DialogueResource, cue: String) -> DialogueBox:
	WorldState.set_ui_mode(mode)
	var box: DialogueBox = BOX.instantiate()
	add_child_autofree(box)
	box.present(resource, cue)
	await wait_physics_frames(4)
	return box


func test_effects_are_rendered_not_printed_in_both_skins() -> void:
	for mode: GameState.UiMode in [GameState.UiMode.ELYSIA, GameState.UiMode.REAL]:
		var box := await _show(mode, SANDBOX, "sign_effects")
		var label: RichTextLabel = box._text
		assert_true(label.bbcode_enabled, "BBCode is on")
		assert_eq(label.get_parsed_text(), "Ein Held! Und strahlend.", "no tags on screen")
		assert_true("[wave" in label.text, "the effect tags are still in the label text")
		box.queue_free()
		await wait_physics_frames(2)


func test_the_first_no_has_a_beat_before_it() -> void:
	var line := await DialogueManager.get_next_dialogue_line(TAL, "mira_first")
	# first answer ("Hallo."), then on to "Brauchst du was?" and its first answer
	line = await DialogueManager.get_next_dialogue_line(TAL, line.responses[0].next_id)
	for i in 6:
		if line.static_id == "tal_mira_21":
			break
		line = await DialogueManager.get_next_dialogue_line(TAL, line.next_id)
	assert_eq(line.static_id, "tal_mira_21")
	assert_eq(line.character, "Die Frau", "she has not said her name yet")
	var no := await DialogueManager.get_next_dialogue_line(TAL, line.responses[0].next_id)
	assert_eq(no.static_id, "tal_mira_7")
	assert_eq(no.text, "Nein.", "the pause is not text")
	assert_eq(no.inline_mutations.size(), 1)
	assert_eq(no.inline_mutations[0][0], 0, "before the first letter")


func test_zum_meer_waits_before_it_is_said() -> void:
	WorldState.add_memory("mira", "asked_where_to")
	var line := await DialogueManager.get_next_dialogue_line(TAL, "ending_sea")
	assert_eq(line.character, "Mira")
	assert_eq(line.text, "Zum Meer.", "the pause is not text")
	assert_eq(line.inline_mutations.size(), 1)
	assert_eq(line.inline_mutations[0][0], 0, "before the first letter")
	WorldState.add_memory("mira", "guessed_sea")
	line = await DialogueManager.get_next_dialogue_line(TAL, "ending_sea")
	assert_eq(line.text, "… Ja. Zum Meer.")
	assert_eq(line.inline_mutations.size(), 1)


func test_elysia_stresses_hero_and_legendary() -> void:
	var seen: Array[String] = []
	for i in 40:
		var line := await DialogueManager.get_next_dialogue_line(ELYSIA, "elysian")
		seen.append(line.text)
	var stressed := seen.filter(func(t: String) -> bool: return "[wave" in t)
	assert_gt(stressed.size(), 0, "the random pick finds the stressed line within 40 tries")


func test_the_sprint_hint_names_the_key_of_the_current_device() -> void:
	var line := await DialogueManager.get_next_dialogue_line(ELYSIA, "wake")
	var hint := ""
	for i in 8:
		if line == null:
			break
		if line.static_id == "el_wake_8":
			hint = line.text
		line = await DialogueManager.get_next_dialogue_line(
			ELYSIA, line.responses[0].next_id if line.responses.size() > 0 else line.next_id
		)
	assert_ne(hint, "", "the wake cue ends with the sprint hint")
	assert_false("{{" in hint, "the expression was evaluated")
	assert_true(InputDevice.label_for(&"sprint") in hint)


func test_the_box_really_holds_the_pause_before_zum_meer() -> void:
	Settings.override("text.speed", 1)
	WorldState.add_memory("mira", "asked_where_to")
	var box := await _show(GameState.UiMode.REAL, TAL, "ending_sea")
	var label: RichTextLabel = box._text
	await wait_seconds(0.5)
	assert_eq(label.visible_characters, 0, "still waiting after 0.5 s: nothing typed yet")
	await wait_seconds(1.3)
	assert_eq(label.get_parsed_text(), "Zum Meer.")
	assert_gt(label.visible_characters, 0, "typed once the pause is over")
