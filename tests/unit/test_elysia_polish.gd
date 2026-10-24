extends GutTest
## Polish round 2, Elysia: the waking, the banner, loot lines, the rift's step, swell and
## stutter, and the cutscene's dialogue flag.

const SANDBOX := preload("res://world/levels/sandbox.tscn")
const RIFT := preload("res://world/props/rift.tscn")
const SLICE_ELYSIA := preload("res://world/levels/slice/elysia.tscn")
## Read from the script: the prop has no class name.
const RIFT_STEP_SECONDS := 0.45
const RIFT_STEP_PIXELS := 8.0
const RIFT_SWELL_SECONDS := 3.2


func before_each() -> void:
	WorldState.new_game()


func after_each() -> void:
	WorldState.new_game()
	ScreenFade.fade_in(0.0)
	Settings.override("display.reduce_flashing", false)
	Settings.override("access.captions", false)
	get_tree().paused = false


func _scene() -> GameScene:
	var scene: GameScene = SANDBOX.instantiate()
	add_child_autofree(scene)
	await wait_physics_frames(3)
	return scene


func test_sound_captions_are_debounced_in_game_time() -> void:
	var scene := await _scene()
	var hud := scene.hud
	hud._on_caption("CAPTION_RIFT", null)
	assert_eq(hud._caption.text, tr("CAPTION_RIFT"))
	hud._caption.text = ""
	hud._on_caption("CAPTION_RIFT", null)
	assert_eq(hud._caption.text, "", "the same sound is not written twice in a row")
	hud._time += Hud.CAPTION_REPEAT + 0.1
	hud._on_caption("CAPTION_RIFT", null)
	assert_eq(hud._caption.text, tr("CAPTION_RIFT"), "game time passing lets it through again")


func test_elysias_banner_stays_while_people_talk() -> void:
	var scene := await _scene()
	var hud := scene.hud
	hud._area.modulate.a = 1.0
	hud.hide_area()
	await wait_seconds(0.3)
	assert_eq(hud._area.modulate.a, 1.0, "the golden banner sits above the box")
	WorldState.set_ui_mode(GameState.UiMode.REAL)
	hud.hide_area()
	await wait_seconds(0.3)
	assert_eq(hud._area.modulate.a, 0.0, "the quiet line of the real world gives way")


func test_no_saved_mark_at_the_start_or_during_a_cutscene() -> void:
	var scene := await _scene()
	var hud := scene.hud
	WorldState.state.playtime_seconds = 1.0
	hud._show_saved()
	assert_eq(hud._saved.modulate.a, 0.0, "the arrival save of a new game is silent")
	WorldState.state.playtime_seconds = 600.0
	var cut := Cutscene.begin(scene)
	hud._show_saved()
	assert_eq(hud._saved.modulate.a, 0.0, "nor one that lands during a cutscene")
	cut.end()
	hud._show_saved()
	await wait_seconds(0.4)
	assert_gt(hud._saved.modulate.a, 0.0, "a save the player can notice shows")


func test_loot_cards_carry_the_items_line_of_text() -> void:
	var scene := await _scene()
	var hud := scene.hud
	hud._loot_card(ContentDB.item("item_compliment"), 1)
	var texts: PackedStringArray = []
	for label in hud._popups.find_children("*", "Label", true, false):
		texts.append((label as Label).text)
	assert_has(texts, tr("ITEM_COMPLIMENT_DESC"))


func test_the_rift_opening_alone_is_noticed() -> void:
	WorldState.set_flag("elysia.woke")
	WorldState.set_flag("elysia.loops")
	WorldState.state.playtime_seconds = (
		ElysiaDirector.LOOPS_AFTER + ElysiaDirector.RIFT_AFTER_LOOPS + 1.0
	)
	Settings.override("access.captions", false)
	var scene: ElysiaScene = SLICE_ELYSIA.instantiate()
	add_child_autofree(scene)
	await wait_process_frames(3)
	assert_true(WorldState.has_flag("elysia.rift_open"))
	assert_gt(scene.view._shake_time, 0.0, "the ground shakes a little")
	assert_eq(scene.hud._caption.text.trim_prefix("‹ ").trim_suffix(" ›"), tr("CAPTION_RIFT"))
	assert_not_null(scene._rift_position(), "the caption points to the rift")


func test_the_touch_steps_into_the_rift_and_swells_it() -> void:
	var scene := await _scene()
	var rift: Node2D = RIFT.instantiate()
	scene.map.entities.add_child(rift)
	rift.global_position = scene.player.global_position + Vector2(10, 0)
	await wait_physics_frames(1)
	var start := scene.player.global_position
	(rift.get_node("Interactable") as Interactable).interact(scene.player)
	scene.player.lock(&"test")
	await wait_seconds(RIFT_STEP_SECONDS + 0.2)
	assert_almost_eq(scene.player.global_position.x - start.x, RIFT_STEP_PIXELS, 0.6)
	assert_eq(scene.player.facing, Facing.Dir.E, "facing the crack")
	await wait_seconds(RIFT_SWELL_SECONDS)
	assert_almost_eq(float(rift.get("_swell")), 1.0, 0.01)
	assert_gt((rift.get_node("Glow") as PointLight2D).energy, 2.0, "the glow grows")
	assert_gt((rift.get_node("Sprite") as Sprite2D).scale.x, 1.4)
	AudioDirector.stop_music(0.0)


func test_the_world_stutters_while_the_hud_falls_apart() -> void:
	var scene := await _scene()
	var sequence := RiftSequence.play(scene, "look_tal", false)
	sequence.travel = false
	var viewport := scene.view.viewport
	var modes: Array[int] = []
	sequence.run()
	for i in 60:
		modes.append(viewport.render_target_update_mode)
		await wait_physics_frames(1)
	assert_has(modes, SubViewport.UPDATE_DISABLED, "the picture of the world holds still")
	await wait_seconds(RiftSequence.STUTTER_SECONDS + 0.2)
	sequence.queue_free()
	await wait_physics_frames(2)
	assert_ne(viewport.render_target_update_mode, SubViewport.UPDATE_DISABLED, "never left frozen")
	AudioDirector.stop_music(0.0)


func test_calm_players_get_no_stutter() -> void:
	Settings.override("display.reduce_flashing", true)
	var scene := await _scene()
	var sequence := RiftSequence.play(scene, "look_tal", false)
	sequence.travel = false
	sequence.run()
	for i in 80:
		assert_ne(scene.view.viewport.render_target_update_mode, SubViewport.UPDATE_DISABLED)
		await wait_physics_frames(1)
	sequence.queue_free()
	Settings.override("display.reduce_flashing", false)
	AudioDirector.stop_music(0.0)


func test_the_cutscene_knows_when_a_dialogue_is_open() -> void:
	var scene := await _scene()
	var cut := Cutscene.begin(scene)
	assert_false(cut.in_dialogue, "timed phases stay locked for the pause menu")
	var done := [false]
	(
		(func() -> void:
			await cut.say(ElysiaScene.DIALOGUE, "wake")
			done[0] = true)
		. call()
	)
	await wait_physics_frames(2)
	assert_true(cut.in_dialogue, "a conversation can be paused")
	var presenter := get_tree().get_first_node_in_group(&"dialogue_presenter")
	presenter.call(&"_close")
	await wait_until(func() -> bool: return done[0], 2.0)
	assert_false(cut.in_dialogue)
	cut.end()
