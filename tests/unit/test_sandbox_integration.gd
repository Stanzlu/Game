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


func test_sitting_glides_onto_the_seat_and_back() -> void:
	await _setup("######\n#....#\n#.@..#\n######")
	var start := player.global_position
	var seat := start + Vector2(0, -10)
	player.sit_on(seat, Facing.Dir.S)
	await wait_physics_frames(2)
	assert_lt(player.global_position.y, start.y, "on the way")
	assert_gt(player.global_position.y, seat.y, "not there yet")
	await wait_seconds(0.2)
	assert_eq(player.global_position, seat)
	assert_false(player.is_locked(), "free once seated")
	player.stand_up()
	var elsewhere := start + Vector2(16, 0)
	player.teleport(elsewhere)
	await wait_seconds(0.2)
	assert_eq(player.global_position, elsewhere, "a teleport ends the glide")
	assert_false(player.is_locked())


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


func test_releasing_a_diagonal_keeps_the_diagonal_facing() -> void:
	await _setup("########\n#......#\n#......#\n#..@...#\n#......#\n########")
	Input.action_press(&"move_up")
	Input.action_press(&"move_right")
	await wait_physics_frames(10)
	assert_eq(player.facing, Facing.Dir.NE)
	# the two keys lift one tick apart, as they do under real fingers
	Input.action_release(&"move_up")
	await wait_physics_frames(1)
	Input.action_release(&"move_right")
	await wait_physics_frames(3)
	assert_eq(player.facing, Facing.Dir.NE, "no flick to a straight direction on release")


func test_a_held_straight_key_after_a_diagonal_turns() -> void:
	await _setup("########\n#......#\n#......#\n#..@...#\n#......#\n########")
	Input.action_press(&"move_up")
	Input.action_press(&"move_right")
	await wait_physics_frames(10)
	Input.action_release(&"move_up")
	await wait_seconds(0.2)
	assert_eq(player.facing, Facing.Dir.E, "a deliberate change still turns")


func test_a_stick_near_a_boundary_does_not_flicker() -> void:
	await _setup("##########\n#........#\n#..@.....#\n#........#\n##########")
	var seen: Dictionary = {}
	for i in 30:
		var angle := deg_to_rad(21.0 if i % 2 == 0 else 24.0)
		Input.action_press(&"move_right", cos(angle))
		Input.action_press(&"move_down", sin(angle))
		await wait_physics_frames(1)
		if i > 4:
			seen[player.facing] = true
	assert_eq(seen.size(), 1, "one facing for a stick that wobbles across 22.5°")


func test_footsteps_follow_the_walk_cycle() -> void:
	await _setup("############\n#@,,,,,,,,,#\n############")
	watch_signals(player)
	Input.action_press(&"move_right")
	await wait_seconds(1.0)
	Input.action_release(&"move_right")
	await wait_physics_frames(2)
	var steps: int = get_signal_emit_count(player, "footstep")
	# walk cycle at 10 fps with feet down on frames 0 and 2: five steps a second
	assert_between(steps, 4, 7, "steps match the feet, not the distance")
