extends GutTest
## Saving and loading at every stop of the vertical slice: the state survives the save file
## unchanged, and the scene built from the loaded state shows the story where it was (the
## child, the rift, the gates at the stream, the fire, the evening, the goat, the end).

const ELYSIA := preload("res://world/levels/slice/elysia.tscn")
const TAL := preload("res://world/levels/slice/tal.tscn")
const HAUS := preload("res://world/levels/slice/haus.tscn")
const WEG := preload("res://encounters/antreiber/slice_antreiber.tscn")
const SAVED_AT := "2026-10-06T12:00:00"


func before_each() -> void:
	WorldState.new_game()


func after_each() -> void:
	WorldState.new_game()
	ScreenFade.fade_in(0.0)
	get_tree().paused = false


## Saves the current state to text, loads it back and checks nothing got lost.
func _save_and_load() -> void:
	var text := SaveCodec.encode(WorldState.state, SAVED_AT)
	var result := SaveCodec.decode(text)
	assert_true(result.ok, "loads: %s %s" % [result.error, result.detail])
	assert_eq(result.warnings, PackedStringArray(), "nothing repaired")
	assert_eq(SaveCodec.encode(result.state, SAVED_AT), text, "the same state after loading")
	WorldState.new_game()
	WorldState.replace_state(result.state)


func _build(scene_res: PackedScene) -> GameScene:
	var scene: GameScene = scene_res.instantiate()
	if scene is HausScene:
		(scene as HausScene).mira_after = 0.2
	add_child_autofree(scene)
	await wait_physics_frames(3)
	return scene


func _alive(scene: GameScene, prefix: String) -> Array[Node]:
	return scene.map.entities.get_children().filter(
		func(node: Node) -> bool:
			return str(node.name).begins_with(prefix) and not node.is_queued_for_deletion()
	)


func _sprite_alive(scene: GameScene, sprite_prefix: String) -> String:
	for node in _alive(scene, "Decor"):
		var decor := node as Decor
		if decor.sprite_id.begins_with(sprite_prefix):
			return decor.sprite_id
	return ""


# --- The story up to each stop, with the same calls the dialogues and scenes make ---------


func _elysia_loops() -> void:
	WorldState.set_player_name("Kai")
	WorldState.add_item("item_seed", 1, false)
	WorldState.set_flag("elysia.woke")
	WorldState.start_quest("main_elysia_hero")
	WorldState.start_quest("side_elysia_butterflies")
	for objective: String in ["first", "second", "third"]:
		WorldState.complete_objective("side_elysia_butterflies", objective)
	WorldState.add_xp(2600)
	WorldState.set_flag("elysia.chest_tree_opened")
	WorldState.set_flag("elysia.loops")
	WorldState.set_flag("elysia.child_met")


func _valley_first_no() -> void:
	_elysia_loops()
	WorldState.set_flag("elysia.child_vanished")
	WorldState.set_flag("elysia.rift_open")
	WorldState.reduce_inventory_to(["item_seed"])
	WorldState.set_ui_mode(GameState.UiMode.REAL)
	WorldState.set_flag("valley.arrived")
	WorldState.set_day_preset("regentag")
	WorldState.add_memory("mira", "said_hello")
	WorldState.add_memory("mira", "stones_warned")
	WorldState.set_relationship("mira", "cautious")
	WorldState.set_flag("valley.mira_met")
	WorldState.start_quest("main_valley_shelter")


func _house_needs_wood() -> void:
	_valley_first_no()
	WorldState.set_flag("valley.fell_in")
	WorldState.set_flag("valley.crossed")
	WorldState.advance_quest("main_valley_shelter", "house")
	WorldState.add_item("curiosity_tiny_spoon")
	WorldState.set_flag("house.spoon_found")
	WorldState.set_flag("valley.wood_needed")
	WorldState.advance_quest("main_valley_shelter", "wood")


func _fire_before_mira() -> void:
	_house_needs_wood()
	WorldState.add_item("item_dry_wood")
	WorldState.set_flag("valley.wood_taken")
	WorldState.advance_quest("main_valley_shelter", "fire")
	WorldState.place_curiosity("shelf_1", "curiosity_tiny_spoon")
	WorldState.set_flag("house.shelf_filled")
	WorldState.remove_item("item_dry_wood")
	WorldState.set_fire_lit(true)
	WorldState.set_flag("house.fire_lit")
	WorldState.advance_quest("main_valley_shelter", "done")


func _evening() -> void:
	_fire_before_mira()
	WorldState.set_flag("house.mira_knocked")
	WorldState.add_memory("mira", "invited_in")
	WorldState.start_quest("side_valley_goat")
	WorldState.set_flag("valley.goat_loose")
	WorldState.add_item("item_fish")
	WorldState.set_flag("valley.bridge_fixed")
	WorldState.set_relationship("mira", "familiar")
	WorldState.set_flag("house.mira_visited")
	WorldState.set_flag("house.mira_left")


func _the_end() -> void:
	_evening()
	WorldState.remove_item("item_fish")
	WorldState.set_flag("house.cat_fed")
	WorldState.set_flag("valley.goat_met")
	WorldState.complete_objective("side_valley_goat", "goat")
	WorldState.add_item("item_potato")
	WorldState.set_flag("valley.potato_taken")
	WorldState.complete_objective("side_valley_goat", "potato")
	WorldState.advance_quest("side_valley_goat", "trade")
	WorldState.remove_item("item_potato")
	WorldState.add_item("item_boot")
	WorldState.set_flag("valley.goat_traded")
	WorldState.advance_quest("side_valley_goat", "return")
	WorldState.remove_item("item_boot")
	WorldState.advance_quest("side_valley_goat", "done")
	WorldState.set_flag("valley.ending")
	WorldState.set_flag("slice.finished")


# --- Tests ------------------------------------------------------------------------------


func test_elysia_while_following_the_child() -> void:
	_elysia_loops()
	_save_and_load()
	await _build(ELYSIA)
	var children := get_tree().get_nodes_in_group(&"child_guide")
	assert_eq(children.size(), 1, "the child is there again")
	assert_eq((children[0] as ChildGuide).step, ChildGuide.Step.LEAD, "and leads on")
	assert_false(WorldState.has_flag("elysia.rift_open"), "the rift waits for the child")
	assert_eq(WorldState.player_name(), "Kai")


func test_elysia_with_the_rift_open() -> void:
	_elysia_loops()
	WorldState.set_flag("elysia.child_vanished")
	WorldState.set_flag("elysia.rift_open")
	_save_and_load()
	var scene := await _build(ELYSIA)
	assert_eq(get_tree().get_nodes_in_group(&"child_guide").size(), 0, "the child stays gone")
	assert_eq(_alive(scene, "Rift").size(), 1, "the rift is still open")


func test_valley_after_miras_no() -> void:
	_valley_first_no()
	_save_and_load()
	var scene := await _build(TAL)
	assert_eq(_alive(scene, "Blocker_44_").size(), 0, "the stream is open after her no")
	assert_eq(_sprite_alive(scene, "tal/house"), "tal/house_dark", "the house is dark")
	assert_eq(WorldState.day_preset(), "regentag")
	assert_true(WorldState.has_memory("mira", "stones_warned"), "Mira remembers")
	assert_eq(WorldState.quest_stage("main_valley_shelter"), "cross")


func test_house_waiting_for_wood() -> void:
	_house_needs_wood()
	_save_and_load()
	var scene := await _build(HAUS)
	assert_false(WorldState.is_fire_lit())
	assert_eq(_alive(scene, "Blocker").size(), 0, "free to fetch the wood")
	assert_eq(_sprite_alive(scene, "haus/shelf"), "haus/shelf", "the spoon is still in the bag")
	assert_true(WorldState.has_item("curiosity_tiny_spoon"))


func test_way_to_the_shed() -> void:
	_house_needs_wood()
	_save_and_load()
	var scene := await _build(WEG)
	assert_not_null(scene.player, "the way builds from a save")
	assert_false(WorldState.has_flag("valley.wood_taken"))


func test_house_between_fire_and_mira() -> void:
	_fire_before_mira()
	_save_and_load()
	var scene := await _build(HAUS)
	assert_true(WorldState.is_fire_lit(), "the fire still burns")
	assert_eq(_sprite_alive(scene, "haus/shelf"), "haus/shelf_spoon", "the spoon on the shelf")
	assert_eq(_alive(scene, "Blocker").size(), 1, "the door waits for Mira")
	await wait_physics_frames(2)
	assert_not_null(get_tree().get_first_node_in_group(&"cutscene"), "Mira knocks after loading")


func test_valley_in_the_evening() -> void:
	_evening()
	_save_and_load()
	var scene := await _build(TAL)
	assert_eq(WorldState.day_preset(), "abend", "it is evening")
	assert_eq(_sprite_alive(scene, "tal/house"), "tal/house", "the house is lit")
	assert_eq(_sprite_alive(scene, "tal/planks"), "tal/planks_new", "Mira's plank on the bridge")
	assert_eq(_alive(scene, "Goat").size(), 1, "the goat with the boot")
	assert_eq(_alive(scene, "Door_0_").size(), 0, "no second walk for wood")
	assert_true(WorldState.has_item("item_fish"), "fish for the cat")


func test_valley_after_the_end() -> void:
	_the_end()
	_save_and_load()
	var scene := await _build(TAL)
	await wait_physics_frames(2)
	assert_null(get_tree().get_first_node_in_group(&"cutscene"), "the ending does not replay")
	assert_eq(_alive(scene, "Goat").size(), 1)
	assert_true(WorldState.is_quest_done("side_valley_goat"))
	assert_true(WorldState.has_flag("slice.finished"))
	assert_eq(WorldState.relationship_state("mira"), "familiar")
