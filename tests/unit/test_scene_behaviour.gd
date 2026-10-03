extends GutTest
## Pause menu, sprint toggle and NPC attention in real scenes.

const SANDBOX := preload("res://world/levels/sandbox.tscn")
const PLAYER_SCENE := preload("res://entities/player/player.tscn")
const NPC_SCENE := preload("res://entities/npc/npc_walker.tscn")


func _send(action: StringName, pressed: bool) -> void:
	var event := InputEventAction.new()
	event.action = action
	event.pressed = pressed
	Input.parse_input_event(event)


func _tap(action: StringName) -> void:
	_send(action, true)
	await wait_physics_frames(2)
	_send(action, false)
	await wait_physics_frames(2)


func after_each() -> void:
	for action: StringName in [&"move_right", &"sprint"]:
		Input.action_release(action)
	get_tree().paused = false
	SessionOptions.tuning_index = 0
	SessionOptions.sprint_toggle = false


func test_menu_action_pauses_and_options_apply() -> void:
	var scene: GameScene = SANDBOX.instantiate()
	add_child_autofree(scene)
	await wait_physics_frames(3)
	await _tap(&"menu")
	assert_true(scene.pause_menu.is_open(), "menu opened")
	assert_true(get_tree().paused, "game paused")
	SessionOptions.tuning_index = 2
	scene.pause_menu.options_changed.emit()
	assert_eq(scene.player.tuning.display_key, "TUNING_SCHWER", "preset applied to player")
	await _tap(&"menu")
	assert_false(scene.pause_menu.is_open(), "menu closed")
	assert_false(get_tree().paused, "game resumed")


func test_sprint_toggle_latches_until_stopping() -> void:
	var map := MapView.new()
	add_child_autofree(map)
	map.build_from_text("##########\n#@.......#\n##########", "toggle")
	var player: Player = PLAYER_SCENE.instantiate()
	map.entities.add_child(player)
	player.teleport(map.cell_to_world(Vector2i(1, 1)))
	player.sprint_toggle = true
	await wait_physics_frames(2)
	Input.action_press(&"move_right")
	await _tap(&"sprint")
	await wait_seconds(0.4)
	assert_eq(player.state, Player.State.RUN, "toggle keeps running without holding")
	Input.action_release(&"move_right")
	await wait_seconds(0.3)
	Input.action_press(&"move_right")
	await wait_seconds(0.3)
	assert_eq(player.state, Player.State.WALK, "latch released after stopping")


func test_npc_stops_and_looks_at_a_nearby_player() -> void:
	var map := MapView.new()
	add_child_autofree(map)
	map.build_from_text("##########\n#........#\n#........#\n##########", "npc")
	var npc: NpcWalker = NPC_SCENE.instantiate()
	map.entities.add_child(npc)
	npc.position = map.cell_to_world(Vector2i(2, 1))
	npc.apply_params({"route": [[0, 0], [5, 0]]})
	var player: Player = PLAYER_SCENE.instantiate()
	map.entities.add_child(player)
	player.teleport(map.cell_to_world(Vector2i(8, 2)))
	await wait_seconds(0.5)
	assert_false(npc.attending, "walks while the player is far")
	player.teleport(npc.global_position + Vector2(18, 4))
	await wait_physics_frames(3)
	assert_true(npc.attending, "notices the player")
	assert_eq(npc.facing, Facing.from_vector(player.global_position - npc.global_position))
	assert_eq(npc.velocity, Vector2.ZERO)
