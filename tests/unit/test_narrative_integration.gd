extends GutTest
## Phase 2 in real scenes: dialogue conditions and mutations, saving during dialogue,
## restoring a save into a scene, the sandbox quest, NPC talk, journal and menu navigation.

const SANDBOX := preload("res://world/levels/sandbox.tscn")
const ENCOUNTER := preload("res://encounters/antreiber/antreiber_encounter.tscn")
const MIRA := "res://content/dialogue/valley/mira_prototype.dialogue"
const SANDBOX_DIALOGUE := "res://content/dialogue/sandbox/sandbox.dialogue"


func before_each() -> void:
	WorldState.new_game()
	Settings.override("text.speed", 3)
	for slot in SaveService.SLOTS:
		for backup: bool in [false, true]:
			if FileAccess.file_exists(SaveSystem.path_for(slot, backup)):
				DirAccess.remove_absolute(SaveSystem.path_for(slot, backup))


func after_each() -> void:
	get_tree().paused = false
	Settings.override("text.speed", 1)
	WorldState.new_game()
	for action: StringName in [&"interact", &"journal", &"menu", &"ui_down", &"ui_up"]:
		Input.action_release(action)


func _tap(action: StringName) -> void:
	for pressed: bool in [true, false]:
		var event := InputEventAction.new()
		event.action = action
		event.pressed = pressed
		Input.parse_input_event(event)
		await wait_physics_frames(2)


func _scene() -> GameScene:
	var scene: GameScene = SANDBOX.instantiate()
	add_child_autofree(scene)
	await wait_physics_frames(3)
	return scene


func _find(root: Node, script_path: String) -> Node:
	for node in root.find_children("*", "", true, false):
		var script := node.get_script() as Script
		if script != null and script.resource_path == script_path:
			return node
	return null


func _next(resource: DialogueResource, id: String) -> DialogueLine:
	return await DialogueManager.get_next_dialogue_line(resource, id)


func test_mira_dialogue_follows_relationship_and_memories() -> void:
	var res: DialogueResource = load(MIRA)
	var line := await _next(res, "mira_door")
	assert_eq(line.static_id, "mira_door_first_1")
	assert_eq(line.text, "Du tropfst mir die Stufen voll.", "source text, not the ID")
	assert_eq(line.responses.size(), 3)
	assert_eq(line.responses[0].text, "…", "silence is a full answer")
	line = await _next(res, line.responses[2].next_id)
	assert_eq(line.text, "Nein.")
	while line != null:
		line = await _next(res, line.next_id)
	assert_eq(WorldState.relationship_state("mira"), "cautious")
	assert_true(WorldState.has_memory("mira", "door_asked_in"))
	assert_true(WorldState.has_flag("valley.mira_met"))
	line = await _next(res, "mira_door")
	assert_eq(line.static_id, "mira_door_again_1", "remembers the first answer")


## Plays `cue` of a slice dialogue; `picks` are the answer texts to choose where a choice
## comes up (the first answer otherwise). Returns the spoken lines as "Speaker: text".
func _walk(path: String, cue: String, picks: Array[String] = []) -> Array[String]:
	var res: DialogueResource = load(path)
	var seen: Array[String] = []
	var line := await _next(res, cue)
	while line != null:
		seen.append("%s: %s" % [line.character, line.text])
		if line.responses.is_empty():
			line = await _next(res, line.next_id)
			continue
		var pick: DialogueResponse = line.responses[0]
		for response: DialogueResponse in line.responses:
			if response.text in picks:
				pick = response
		line = await _next(res, pick.next_id)
	return seen


func test_mira_asks_for_the_name_in_the_house_and_says_it_by_the_fire() -> void:
	WorldState.set_player_name("Aren")
	var seen := await _walk("res://content/dialogue/slice/haus.dialogue", "mira_visit", ["Aren."])
	assert_true("Mira: " + LineText.of("haus_mira_35") in seen)
	assert_true("Mira: Aren. Hm." in seen, "she repeats the name she was given")
	assert_true(WorldState.has_memory("mira", "said_name"))
	assert_string_contains(Journal.person_text("mira"), "Sie hat nach meinem Namen gefragt")
	var evening := await _walk("res://content/dialogue/slice/tal.dialogue", "ending")
	assert_true("Mira: Aren." in evening, "the first time the name is said in the real world")
	assert_true(
		evening.find("Mira: Aren.") < evening.find("Mira: " + LineText.of("tal_end_2")),
		"before she says she is leaving"
	)


func test_a_title_is_not_a_name_and_silence_keeps_it() -> void:
	var res := "res://content/dialogue/slice/haus.dialogue"
	var title := await _walk(res, "mira_visit", [LineText.of("haus_mira_r13")])
	assert_true("Mira: " + LineText.of("haus_mira_37") in title)
	assert_true(WorldState.has_memory("mira", "said_title"))
	WorldState.new_game()
	var silent := await _walk(res, "mira_visit", ["…"])
	assert_true("Mira: " + LineText.of("haus_mira_38") in silent)
	assert_true(WorldState.has_memory("mira", "kept_name"))
	var evening := await _walk("res://content/dialogue/slice/tal.dialogue", "ending")
	assert_false("Mira: Held." in evening, "without a name she has none to say")


func test_whoever_said_the_hero_line_is_not_offered_it_twice() -> void:
	WorldState.add_memory("mira", "said_hero")
	var res: DialogueResource = load("res://content/dialogue/slice/haus.dialogue")
	var line := await _next(res, "mira_visit")
	var asked_name := false
	while line != null:
		if line.static_id == "haus_mira_35":
			asked_name = true
			var texts: Array[String] = []
			for response: DialogueResponse in line.responses:
				if response.is_allowed:
					texts.append(response.text)
			assert_false(LineText.of("haus_mira_r13") in texts)
			assert_eq(texts.size(), 2)
		line = await _next(
			res, line.responses[0].next_id if line.responses.size() > 0 else line.next_id
		)
	assert_true(asked_name)


func test_the_evening_remembers_waiting_and_the_tree() -> void:
	var tal := "res://content/dialogue/slice/tal.dialogue"
	WorldState.add_memory("mira", "wanted_to_wait")
	var waited := await _walk(tal, "evening_first")
	assert_true("Mira: " + LineText.of("tal_eve_wait_1") in waited)
	WorldState.new_game()
	WorldState.add_memory("mira", "chose_tree")
	var tree := await _walk(tal, "evening_first")
	assert_true("Mira: " + LineText.of("tal_eve_tree_1") in tree)
	WorldState.new_game()
	assert_eq((await _walk(tal, "evening_first")).size(), 0, "nobody remembers nothing")


func test_the_first_meeting_keeps_her_name_back() -> void:
	var seen := await _walk("res://content/dialogue/slice/tal.dialogue", "mira_first")
	var introduced := seen.find("Mira: " + LineText.of("tal_mira_24"))
	assert_gt(introduced, 0)
	for line: String in seen.slice(0, introduced):
		assert_false(line.begins_with("Mira"), "named too early: %s" % line)


func test_saving_waits_for_the_dialogue_to_end() -> void:
	var scene := await _scene()
	var box := scene.dialogue_box
	box.present(load(SANDBOX_DIALOGUE), "sign_garden", scene.player)
	await wait_physics_frames(3)
	assert_true(box.is_open())
	assert_has(SaveSystem.blockers(), "dialogue")
	assert_eq(SaveSystem.save_slot("slot_1"), ERR_BUSY, "manual save refused in dialogue")
	await _tap(&"interact")
	await wait_physics_frames(3)
	assert_false(box.is_open())
	assert_true(WorldState.is_quest_active("side_sandbox_gate"), "dialogue started the quest")
	assert_true(SaveSystem.can_save())
	var autosave := SaveSystem.read_slot("autosave")
	assert_true(autosave.ok, "autosave written after the dialogue")
	assert_true(autosave.state.quests.has("side_sandbox_gate"))


func test_sandbox_quest_runs_through_lever_and_garden() -> void:
	var scene := await _scene()
	var lever := _find(scene, "res://world/props/lever.gd")
	var zone := _find(scene, "res://world/props/trigger_zone.gd") as Area2D
	(lever.get_node("Interactable") as Interactable).interact(scene.player)
	await wait_physics_frames(2)
	assert_eq(WorldState.quest_stage("side_sandbox_gate"), "through_gate")
	assert_true(WorldState.has_flag("sandbox.garden_gate_open"))
	var gate := _find(scene, "res://world/props/gate.gd")
	assert_true(bool(gate.get("is_open")), "lever opened the gate")
	scene.player.teleport(zone.global_position)
	await wait_physics_frames(4)
	assert_true(WorldState.is_quest_done("side_sandbox_gate"))
	assert_eq(WorldState.quest_outcome("side_sandbox_gate"), "done")
	assert_true(WorldState.is_discovered("sandbox_garden"))
	assert_eq(
		WorldState.quest_history("side_sandbox_gate"),
		PackedStringArray(["find_lever", "through_gate", "done"])
	)


func test_loaded_state_restores_position_and_world_objects() -> void:
	WorldState.set_flag("sandbox.garden_gate_open")
	SaveSystem._arrival = {"map": "sandbox", "position": Vector2(200, 120)}
	SaveSystem.loading = true
	var scene := await _scene()
	assert_false(SaveSystem.loading)
	assert_almost_eq(scene.player.global_position, Vector2(200, 120), Vector2(1, 1))
	var gate := _find(scene, "res://world/props/gate.gd")
	assert_true(bool(gate.get("is_open")), "gate state comes back from the flag")
	assert_false(FileAccess.file_exists(SaveSystem.path_for("autosave")), "no autosave on load")


func test_npc_talks_and_stays_put_until_the_end() -> void:
	var scene := await _scene()
	var npc: NpcWalker = load("res://entities/npc/npc_walker.tscn").instantiate()
	scene.map.entities.add_child(npc)
	npc.global_position = scene.player.global_position + Vector2(16, 0)
	npc.apply_params(
		{
			"sheet": "res://entities/character/sheet_mira_look.tres",
			"dialogue": MIRA,
			"cue": "mira_door"
		}
	)
	(npc.get_node("Interactable") as Interactable).interact(scene.player)
	await wait_physics_frames(3)
	assert_true(npc.talking)
	assert_true(scene.dialogue_box.is_open())
	await _tap(&"ui_down")
	await _tap(&"interact")
	for i in 4:
		await _tap(&"interact")
	assert_false(scene.dialogue_box.is_open())
	assert_false(npc.talking)
	assert_true(WorldState.has_memory("mira", "door_sorry"), "second answer chosen by pad/keys")


func test_journal_opens_lists_and_closes() -> void:
	var scene := await _scene()
	WorldState.start_quest("side_sandbox_gate")
	await _tap(&"journal")
	assert_true(scene.journal.is_open())
	assert_true(get_tree().paused)
	var buttons := scene.journal.list.buttons()
	assert_eq(buttons.size(), 1)
	assert_eq(buttons[0].text, tr("QUEST_SIDE_SANDBOX_GATE_TITLE"))
	assert_true(buttons[0].has_focus())
	var text := Journal.entry_text("side_sandbox_gate")
	assert_eq(text, tr("QUEST_SIDE_SANDBOX_GATE_FIND_LEVER"))
	await _tap(&"journal")
	assert_false(scene.journal.is_open())
	assert_false(get_tree().paused)


func test_a_long_journal_entry_stays_on_screen() -> void:
	var scene := await _scene()
	WorldState.set_ui_mode(GameState.UiMode.REAL)
	WorldState.start_quest("main_valley_shelter")
	for stage: String in ["house", "wood", "fire", "done"]:
		WorldState.advance_quest("main_valley_shelter", stage)
	for memory: String in [
		"said_hello",
		"asked_where",
		"said_hero",
		"first_silence",
		"asked_shelter",
		"asked_sleep",
		"said_cold",
		"stones_warned",
		"chose_tree",
		"invited_in",
		"teased_back",
		"said_elsewhere",
		"asked_boot",
		"told_goat_story",
		"said_welcome"
	]:
		WorldState.add_memory("mira", memory)
	await _tap(&"journal")
	await wait_physics_frames(4)
	var screen := scene.journal.get_viewport().get_visible_rect()
	var panel := scene.journal.frame.find_children("*", "PanelContainer", true, false)[0] as Control
	assert_true(screen.encloses(panel.get_global_rect()), "the quest's entry fits on the screen")
	# the last row is Mira under "Menschen": all her memories
	var rows := scene.journal.list.buttons()
	rows[-1].grab_focus()
	await wait_physics_frames(4)
	screen = scene.journal.get_viewport().get_visible_rect()
	panel = scene.journal.frame.find_children("*", "PanelContainer", true, false)[0] as Control
	assert_true(screen.encloses(panel.get_global_rect()), "fifteen memories fit on the screen")
	await _tap(&"journal")


func test_the_journal_from_the_pause_menu_returns_to_it() -> void:
	var scene := await _scene()
	WorldState.start_quest("side_sandbox_gate")
	await _tap(&"menu")
	assert_true(scene.pause_menu.is_open())
	scene.pause_menu._open_journal()
	await wait_physics_frames(2)
	assert_true(scene.journal.is_open())
	await _tap(&"journal")
	assert_true(scene.pause_menu.is_open(), "back in the pause menu")
	assert_true(get_tree().paused, "still paused")
	await _tap(&"menu")
	assert_false(get_tree().paused)


func test_pause_menu_is_navigable_and_wraps() -> void:
	var scene := await _scene()
	await _tap(&"menu")
	var buttons := scene.pause_menu.list.buttons()
	assert_true(buttons[0].has_focus())
	await _tap(&"ui_down")
	assert_true(buttons[1].has_focus(), "down moves to the next row")
	await _tap(&"ui_up")
	await _tap(&"ui_up")
	assert_true(buttons[-1].has_focus(), "up from the top wraps to the bottom")
	await _tap(&"menu")
	assert_false(scene.pause_menu.is_open())


func test_saving_is_disabled_in_the_encounter() -> void:
	var scene: GameScene = ENCOUNTER.instantiate()
	add_child_autofree(scene)
	await wait_physics_frames(3)
	assert_false(SaveSystem.can_save())
	scene.pause_menu.open()
	var save_row: Button = null
	for row in scene.pause_menu.list.get_children():
		if row is Button and (row as Button).text == tr("PAUSE_SAVE"):
			save_row = row
	assert_not_null(save_row)
	assert_true(save_row.disabled)
	assert_eq(scene.pause_menu.hint.text, tr("SAVE_NOT_HERE"))
	scene.pause_menu.close()
	assert_false(FileAccess.file_exists(SaveSystem.path_for("autosave")))


func test_settings_menu_changes_values_with_left_right() -> void:
	var scene := await _scene()
	var menu := scene.pause_menu.settings_menu
	menu.open()
	await wait_physics_frames(2)
	var before := Settings.get_int("audio.master")
	assert_true(menu.list.buttons()[0].has_focus(), "first volume row focused")
	await _tap(&"ui_left")
	assert_eq(Settings.get_int("audio.master"), before - 1)
	await _tap(&"ui_right")
	assert_eq(Settings.get_int("audio.master"), before)
	menu.close()


func test_debug_panel_over_pause_menu_keeps_the_game_paused() -> void:
	var scene := await _scene()
	await _tap(&"menu")
	var panel := scene.get_node("DebugPanel") as DebugPanel
	await _tap(&"debug_panel")
	assert_true(panel.is_open())
	await _tap(&"debug_panel")
	assert_false(panel.is_open())
	assert_true(get_tree().paused, "pause menu is still open")
	assert_true(scene.pause_menu.is_open())
	await _tap(&"menu")
	assert_false(get_tree().paused)


func test_focus_returns_to_the_row_that_opened_a_submenu() -> void:
	var scene := await _scene()
	await _tap(&"menu")
	var rows := scene.pause_menu.list.buttons()
	var settings_row := rows[4]
	assert_eq(settings_row.text, tr("PAUSE_SETTINGS"))
	for i in 4:
		await _tap(&"ui_down")
	assert_true(settings_row.has_focus())
	await _tap(&"interact")
	assert_true(scene.pause_menu.settings_menu.is_open(), "E opens the row like Enter")
	assert_false(scene.pause_menu.frame.visible, "pause panel hidden behind the submenu")
	await _tap(&"cancel")
	assert_false(scene.pause_menu.settings_menu.is_open())
	assert_true(scene.pause_menu.frame.visible)
	assert_true(settings_row.has_focus(), "focus is back on Einstellungen")
	assert_true(scene.pause_menu.is_open(), "cancel closed only the submenu")
	await _tap(&"menu")
