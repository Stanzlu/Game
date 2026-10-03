extends GutTest
## Integration tests with real physics and simulated input on small text maps.

const PLAYER_SCENE := preload("res://entities/player/player.tscn")
const DIALOGUE_BOX_SCENE := preload("res://ui/dialogue/dialogue_box.tscn")

var map: MapView
var player: Player


func _setup(text: String) -> void:
	map = MapView.new()
	add_child_autofree(map)
	assert_true(map.build_from_text(text, "test"), "test map must build")
	player = PLAYER_SCENE.instantiate()
	map.entities.add_child(player)
	var spawn: Dictionary = map.data.find_marker("player_spawn")[0]
	player.teleport(map.cell_to_world(spawn["cell"]))
	player.surface_provider = map.surface_at
	await wait_physics_frames(2)


func _hold(action: StringName, seconds: float) -> void:
	Input.action_press(action)
	await wait_seconds(seconds)
	Input.action_release(action)
	await wait_physics_frames(2)


## Sends real InputEventActions so both polling (player) and event handlers (UI) see them.
func _tap(action: StringName) -> void:
	_send(action, true)
	await wait_physics_frames(2)
	_send(action, false)
	await wait_physics_frames(2)


func _send(action: StringName, pressed: bool) -> void:
	var event := InputEventAction.new()
	event.action = action
	event.pressed = pressed
	Input.parse_input_event(event)


func after_each() -> void:
	for action: StringName in [
		&"move_left", &"move_right", &"move_up", &"move_down", &"sprint", &"interact"
	]:
		Input.action_release(action)


func test_walking_into_a_wall_stops_the_player() -> void:
	await _setup("######\n#@...#\n######")
	var start := player.global_position.x
	await _hold(&"move_right", 1.0)
	assert_gt(player.global_position.x, start + 20.0, "player moved")
	# Interior ends at x = 5 * 16; feet collider is 10 px wide.
	assert_lt(player.global_position.x, 5.0 * 16.0 - 4.0, "wall stopped the player")


func test_footsteps_report_the_tile_surface() -> void:
	await _setup("#######\n#@,,,,#\n#######")
	watch_signals(player)
	await _hold(&"move_right", 0.6)
	assert_signal_emitted(player, "footstep")
	assert_eq(player.last_surface, &"dirt")


func test_puddles_override_the_surface() -> void:
	await _setup("#####\n#@o.#\n#####")
	var puddle_at := map.cell_to_world(Vector2i(2, 1))
	await wait_physics_frames(2)
	assert_eq(map.surface_at(puddle_at), &"puddle")
	assert_eq(map.surface_at(map.cell_to_world(Vector2i(3, 1))), &"grass")


func test_corner_nudge_slips_through_a_doorway() -> void:
	# Door gap at x = 2; the player starts 4 px left of its center and walks up.
	await _setup("#####\n##.##\n#...#\n#.@.#\n#####")
	player.teleport(player.global_position + Vector2(-4, 0))
	await _hold(&"move_up", 1.2)
	assert_lt(
		player.global_position.y, map.cell_to_world(Vector2i(2, 2)).y - 4.0, "passed the door"
	)


func test_without_nudge_the_doorway_blocks() -> void:
	await _setup("#####\n##.##\n#...#\n#.@.#\n#####")
	player.tuning = player.tuning.duplicate()
	player.tuning.corner_nudge_px = 0
	player.teleport(player.global_position + Vector2(-6, 0))
	await _hold(&"move_up", 1.0)
	assert_gt(
		player.global_position.y, map.cell_to_world(Vector2i(2, 2)).y - 4.0, "stuck at the edge"
	)


func test_sign_opens_dialogue_locks_and_releases_the_player() -> void:
	var text := (
		"[legend]\n"
		+ '1 = {"ground": ".", "prop": "res://world/props/sign.tscn", "params": {"cue": "sign_pond"}}\n'
		+ "[map]\n#####\n#.1.#\n#.@.#\n#####"
	)
	await _setup(text)
	var box: DialogueBox = DIALOGUE_BOX_SCENE.instantiate()
	add_child_autofree(box)
	player.facing = Facing.Dir.N
	await wait_physics_frames(3)
	assert_not_null(player.sensor.current, "sign is the interaction target")
	await _tap(&"interact")
	await wait_seconds(0.1)
	assert_true(box.is_open(), "dialogue box opened")
	assert_true(player.is_locked(), "player locked during dialogue")
	for i in 4:
		await _tap(&"interact")
		await wait_seconds(0.15)
		if not box.is_open():
			break
	assert_false(box.is_open(), "dialogue closed")
	assert_false(player.is_locked(), "player released")


func test_bench_sit_and_stand_up() -> void:
	await _setup("######\n#.B,.#\n#.@..#\n######")
	player.facing = Facing.Dir.N
	await wait_physics_frames(3)
	await _tap(&"interact")
	assert_eq(player.state, Player.State.SIT)
	var seat := player.global_position
	await _hold(&"move_down", 0.3)
	assert_ne(player.state, Player.State.SIT)
	assert_ne(player.global_position, seat)


func test_lever_opens_the_gate() -> void:
	var text := (
		"[legend]\n"
		+ 'L = {"ground": ".", "prop": "res://world/props/lever.tscn", "params": {"target": "g"}}\n'
		+ 'G = {"ground": ".", "prop": "res://world/props/gate.tscn", "params": {"id": "g"}}\n'
		+ "[map]\n#####\n#L.G#\n#@..#\n#####"
	)
	await _setup(text)
	var gate := map.entities.get_node("Gate_3_1")
	assert_not_null(gate)
	assert_false(gate.get("is_open"))
	player.facing = Facing.Dir.N
	await wait_physics_frames(3)
	await _tap(&"interact")
	assert_true(gate.get("is_open"), "lever opened the gate")
