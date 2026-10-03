extends GutTest
## Phase 3: UI skins follow the UI mode, Elysia's HUD and rewards, world objects (chest,
## pickup), the rift sequence, screen fade and accessible screen shake.

const SANDBOX := preload("res://world/levels/sandbox.tscn")
const CHEST := preload("res://world/props/chest.tscn")
const PICKUP := preload("res://world/props/pickup.tscn")


func before_each() -> void:
	WorldState.new_game()


func after_each() -> void:
	WorldState.new_game()
	ScreenFade.fade_in(0.0)
	get_tree().paused = false


func _scene() -> GameScene:
	var scene: GameScene = SANDBOX.instantiate()
	add_child_autofree(scene)
	await wait_physics_frames(3)
	return scene


func test_skin_follows_ui_mode_and_loaded_saves() -> void:
	var panel := PanelContainer.new()
	add_child_autofree(panel)
	UiSkin.attach(panel)
	await wait_physics_frames(1)
	assert_eq(panel.theme, UiSkin.ELYSIA_SKIN)
	WorldState.set_ui_mode(GameState.UiMode.REAL)
	assert_eq(panel.theme, UiSkin.REAL_SKIN)
	var loaded := GameState.new()
	loaded.ui_mode = GameState.UiMode.ELYSIA
	WorldState.replace_state(loaded)
	assert_eq(panel.theme, UiSkin.ELYSIA_SKIN, "a loaded save switches the skin")


func test_hud_shows_elysia_rewards_and_quiet_real_lines() -> void:
	var scene := await _scene()
	var hud := scene.hud
	assert_true(hud.elysia_root.visible)
	WorldState.add_xp(2500)
	WorldState.add_gold(4200)
	WorldState.add_item("item_compliment")
	await wait_physics_frames(2)
	assert_gt(hud._popups.get_child_count(), 0, "reward popups shown")
	await wait_seconds(1.6)
	assert_eq(hud._gold_label.text, "4.200", "gold counted up")
	assert_eq(hud._level_label.text, tr("HUD_LEVEL") % WorldState.elysia_level())
	WorldState.set_ui_mode(GameState.UiMode.REAL)
	assert_false(hud.elysia_root.visible)
	assert_true(hud.real_root.visible)
	WorldState.add_item("item_stone")
	assert_eq(hud._quiet.text, tr("ITEM_STONE_NAME"), "Real world: one quiet line")


func test_hud_elements_vanish_one_by_one() -> void:
	var scene := await _scene()
	WorldState.start_quest("side_elysia_chest")
	var order: PackedStringArray = []
	while scene.hud.vanish_next(true):
		order = scene.hud.vanished()
	assert_eq(order, Hud.VANISH_ORDER)
	assert_false(scene.hud.vanish_next(true))


func test_number_format_uses_german_separators() -> void:
	assert_eq(Hud.format_number(0), "0")
	assert_eq(Hud.format_number(4200), "4.200")
	assert_eq(Hud.format_number(12500000), "12.500.000")


func test_chest_opens_once_and_stays_open_after_loading() -> void:
	var scene := await _scene()
	var chest: Node = CHEST.instantiate()
	scene.map.entities.add_child(chest)
	var params := {
		"flag": "elysia.test_chest",
		"actions": [{"item": "item_compliment"}, {"gold": 100}, {"xp": 50}],
	}
	chest.call(&"apply_params", params)
	(chest.get_node("Interactable") as Interactable).interact(scene.player)
	(chest.get_node("Interactable") as Interactable).interact(scene.player)
	assert_eq(WorldState.item_count("item_compliment"), 1, "loot only once")
	assert_eq(WorldState.state.elysia.gold, 100)
	var again: Node = CHEST.instantiate()
	scene.map.entities.add_child(again)
	again.call(&"apply_params", params)
	assert_true(bool(again.get("is_open")), "flag restores the open chest")


func test_pickup_is_gone_once_taken() -> void:
	var scene := await _scene()
	var stone: Node = PICKUP.instantiate()
	scene.map.entities.add_child(stone)
	stone.call(&"apply_params", {"item": "item_stone", "flag": "elysia.test_stone"})
	(stone.get_node("Interactable") as Interactable).interact(scene.player)
	assert_eq(WorldState.item_count("item_stone"), 1)
	await wait_physics_frames(1)
	assert_false(is_instance_valid(stone))
	var again: Node = PICKUP.instantiate()
	scene.map.entities.add_child(again)
	again.call(&"apply_params", {"item": "item_stone", "flag": "elysia.test_stone"})
	await wait_physics_frames(1)
	assert_false(is_instance_valid(again), "taken items stay taken")


func test_world_actions_give_xp_and_gold() -> void:
	assert_eq(StateActions.validate([{"xp": 100}, {"gold": 5}]), PackedStringArray())
	assert_eq(StateActions.validate([{"xp": -1}]).size(), 1)
	StateActions.run([{"xp": 100}, {"gold": 5}], "test")
	assert_eq(WorldState.state.elysia.xp, 100)
	assert_eq(WorldState.state.elysia.gold, 5)


func test_rift_sequence_strips_elysia_and_keeps_stone_and_seed() -> void:
	var scene := await _scene()
	WorldState.add_item("item_compliment")
	AudioDirector.play_music("elysia", 0.0)
	var sequence := RiftSequence.play(scene, "look_tal", false)
	sequence.time_scale = 0.02
	sequence.travel = false
	sequence.run()
	assert_true(scene.player.is_locked(), "player is held during the sequence")
	assert_has(SaveSystem.blockers(), "cutscene")
	await wait_for_signal(sequence.finished, 5.0)
	assert_eq(WorldState.ui_mode(), GameState.UiMode.REAL)
	assert_eq(WorldState.state.inventory.keys(), ["item_stone", "item_seed"])
	assert_true(WorldState.has_flag("elysia.rift_crossed"))
	assert_eq(AudioDirector.current, "", "music stopped")
	assert_true(ScreenFade.is_covered(), "ends in black, the next scene fades in")
	assert_false(SaveSystem.blockers().has("cutscene"))


func test_screen_shake_respects_the_setting() -> void:
	var scene := await _scene()
	Settings.override("display.screen_shake", false)
	scene.view.shake(3.0, 1.0)
	assert_eq(scene.view._shake_time, 0.0)
	Settings.override("display.screen_shake", true)
	scene.view.shake(3.0, 1.0)
	assert_eq(scene.view._shake_time, 1.0)


func test_prototype_scenes_start_in_their_world() -> void:
	assert_eq(SceneRegistry.start_mode("look_elysia"), GameState.UiMode.ELYSIA)
	assert_eq(SceneRegistry.start_mode("look_tal"), GameState.UiMode.REAL)


func test_rift_sequence_blocks_menus_and_frees_saving_when_left_early() -> void:
	var scene := await _scene()
	var sequence := RiftSequence.play(scene, "look_tal", false)
	sequence.time_scale = 0.5
	sequence.travel = false
	sequence.run()
	assert_true(MenuLayer.any_open(get_tree()), "pause menu and journal stay closed")
	assert_has(SaveSystem.blockers(), "cutscene")
	sequence.queue_free()
	await wait_physics_frames(2)
	assert_false(MenuLayer.any_open(get_tree()))
	assert_false(SaveSystem.blockers().has("cutscene"), "leaving mid-sequence unblocks saving")
	await wait_seconds(1.0)
	assert_eq(WorldState.ui_mode(), GameState.UiMode.ELYSIA, "a freed sequence never resumes")
	AudioDirector.stop_music(0.0)


func test_node_timer_dies_with_its_owner() -> void:
	var owner := Node.new()
	add_child(owner)
	var fired := [false]
	NodeTimer.after(owner, 0.05).connect(func() -> void: fired[0] = true)
	owner.free()
	await wait_seconds(0.2)
	assert_false(fired[0], "no callback after the owner is gone")
