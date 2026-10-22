extends GutTest
## The Antreiber as a figure: he steps when the player steps (never gliding in the idle pose),
## his cycle follows his real pace, his barks are heard, and he bobs while he speaks.

const ENCOUNTER := preload("res://encounters/antreiber/antreiber_encounter.tscn")
const ACTOR := preload("res://encounters/antreiber/antreiber_actor.tscn")


class StubPresenter:
	extends Node
	signal syllable(character: String)


func after_each() -> void:
	for action: StringName in [&"move_right", &"move_left", &"sprint"]:
		Input.action_release(action)
	get_tree().paused = false


## Walks (not runs) for `seconds` and returns the animations of his sprite, one per physics frame,
## after he had `settle` seconds to catch up with the player.
func _animations_while_walking(action: StringName, settle: float, seconds: float) -> Array[String]:
	var encounter: AntreiberEncounter = ENCOUNTER.instantiate()
	add_child_autofree(encounter)
	await wait_physics_frames(3)
	Input.action_press(action)
	await wait_seconds(settle)
	var seen: Array[String] = []
	for i in int(seconds * 60.0):
		await wait_physics_frames(1)
		seen.append(String(encounter.antreiber.sprite.animation))
	assert_lt(
		encounter.player.velocity.length(),
		encounter.player.tuning.run_speed * 0.9,
		"walking, not running"
	)
	return seen


func test_he_walks_with_the_player_walking_right() -> void:
	var seen := await _animations_while_walking(&"move_right", 1.0, 2.0)
	assert_false(seen.is_empty())
	for anim in seen:
		assert_true(
			anim.begins_with("walk_") or anim.begins_with("run_"), "moving, so not %s" % anim
		)
		assert_false(anim.begins_with("idle_"), "no gliding in the idle pose")


func test_he_faces_the_way_he_walks_going_west_too() -> void:
	var seen := await _animations_while_walking(&"move_left", 1.5, 1.5)
	var west := String(CharacterSheet.animation_name("walk", Facing.Dir.W))
	var run_west := String(CharacterSheet.animation_name("run", Facing.Dir.W))
	for anim in seen:
		assert_true(
			(
				anim == west
				or anim == run_west
				or anim.ends_with("_%d" % Facing.Dir.SW)
				or anim.ends_with("_%d" % Facing.Dir.NW)
			),
			"walks west, not backwards: %s" % anim
		)


func test_his_steps_follow_his_pace_instead_of_paddling() -> void:
	var actor: AntreiberActor = ACTOR.instantiate()
	add_child_autofree(actor)
	actor._play("walk", AntreiberActor.TRAIL_SPEED)
	assert_almost_eq(actor.sprite.speed_scale, 0.5, 0.001, "slow walk behind the player, clamped")
	actor._play("walk", AntreiberActor.WALK_CYCLE_SPEED)
	assert_almost_eq(actor.sprite.speed_scale, 1.0, 0.001)
	actor._play("run", AntreiberActor.RUN_CYCLE_SPEED * 2.0)
	assert_almost_eq(actor.sprite.speed_scale, 1.4, 0.001, "never faster than the cycle allows")
	actor._play("idle")
	assert_eq(actor.sprite.speed_scale, 1.0)


func test_trailing_and_walking_to_a_place_use_their_own_pace() -> void:
	var actor: AntreiberActor = ACTOR.instantiate()
	add_child_autofree(actor)
	var far := Node2D.new()
	add_child_autofree(far)
	far.global_position = Vector2(200, 0)
	actor.trail(far, 0.016)
	assert_almost_eq(actor.sprite.speed_scale, AntreiberActor.TRAIL_SPEED / 88.0, 0.2, "trail")
	assert_lt(actor.sprite.speed_scale, 0.6)
	actor.walk_to(Vector2(80, 0), 30.0)
	assert_lt(actor.sprite.speed_scale, 0.5 + 0.001, "walk_to at 30 px/s")


func test_he_has_footsteps_and_barks_that_are_heard() -> void:
	var actor: AntreiberActor = ACTOR.instantiate()
	add_child_autofree(actor)
	assert_not_null(actor.get_node_or_null("Steps"), "footsteps")
	await actor.say(AntreiberModel.Mood.URGING)
	var barks: Array[AudioStreamPlayer2D] = []
	for child in actor.get_children():
		if child is AudioStreamPlayer2D and child.name != &"Steps":
			barks.append(child)
	assert_eq(barks.size(), 1, "one bark sound")
	assert_eq(barks[0].volume_db, -1.0, "level from the audio table")


func test_he_bobs_on_a_bark() -> void:
	var actor: AntreiberActor = ACTOR.instantiate()
	add_child_autofree(actor)
	var rest := actor.sheet.feet_offset
	await actor.say(AntreiberModel.Mood.CHEERING)
	assert_eq(actor.sprite.offset, rest + Vector2(0, -AntreiberActor.BOB_PIXELS))
	await wait_seconds(AntreiberActor.BOB_SECONDS + 0.05)
	assert_eq(actor.sprite.offset, rest)


func test_he_bobs_with_the_syllables_while_a_scene_lets_him_talk() -> void:
	var presenter := StubPresenter.new()
	presenter.add_to_group(&"dialogue_presenter")
	add_child_autofree(presenter)
	var actor: AntreiberActor = ACTOR.instantiate()
	add_child_autofree(actor)
	var rest := actor.sheet.feet_offset
	presenter.syllable.emit("a")
	assert_eq(actor.sprite.offset, rest, "not talking: still")
	actor.talking = true
	presenter.syllable.emit("a")
	assert_ne(actor.sprite.offset, rest, "talking: bob")
	await wait_seconds(AntreiberActor.BOB_GAP + 0.05)
	actor.talking = false
	presenter.syllable.emit("b")
	assert_eq(actor.sprite.offset, rest, "silent again")
