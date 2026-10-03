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
