extends GutTest
## Act III, segment W4: once the Antreiber has gone ahead to the Flutlichtung, the house must not
## send him in through its door (the visit of Act II is still pending for a player who lit the
## fire and did not sit long enough to see it): he would stand in two places at once.

const HAUS := preload("res://world/levels/slice/haus.tscn")


func before_each() -> void:
	WorldState.new_game()
	WorldState.set_ui_mode(GameState.UiMode.REAL)


func after_each() -> void:
	WorldState.new_game()
	ScreenFade.fade_in(0.0)
	get_tree().paused = false


func _scene() -> HausScene:
	var scene: HausScene = HAUS.instantiate()
	add_child_autofree(scene)
	await wait_physics_frames(3)
	return scene


func test_the_visit_is_expected_until_he_has_gone_ahead() -> void:
	WorldState.set_flag("valley.wood_taken")
	var scene := await _scene()
	assert_true(scene._antreiber_pending(), "wood taken, not at the fire, not gone: he is expected")
	WorldState.set_flag("forest.antreiber_ahead")
	assert_false(scene._antreiber_pending(), "he is in the clearing: he does not come in")


func test_the_other_states_still_end_the_visit() -> void:
	WorldState.set_flag("valley.wood_taken")
	WorldState.set_flag("house.antreiber_left")
	var scene := await _scene()
	assert_false(scene._antreiber_pending(), "he has left")
	WorldState.new_game()
	WorldState.set_flag("valley.wood_taken")
	WorldState.set_flag("house.antreiber_by_fire")
	assert_false(scene._antreiber_pending(), "he sits by the fire already")
	WorldState.new_game()
	assert_false(scene._antreiber_pending(), "no wood taken: nobody is expected yet")
