extends GutTest
## Game Bible §9 and §12: the real world is less kept than Elysia (crooked trees, broken
## fences, gusty wind) and its water shows the protagonist, Elysia's does not.

const TAL := preload("res://world/levels/look_tal.tscn")
const ELYSIA := preload("res://world/levels/look_elysia.tscn")
const WALD := preload("res://world/levels/look_wald.tscn")


func before_each() -> void:
	WorldState.new_game()


func after_each() -> void:
	AudioDirector.play_music("silence", 0.0)
	WorldState.new_game()


func test_valley_is_weathered_and_windy() -> void:
	var scene: LookScene = TAL.instantiate()
	add_child_autofree(scene)
	await wait_physics_frames(2)
	var sprites := {}
	for placement: Dictionary in scene.map.data.placements:
		sprites[str(placement["params"].get("sprite", ""))] = true
	assert_true(sprites.has("tal/tree_crooked"), "crooked trees")
	assert_true(sprites.has("tal/fence_broken"), "broken fence segments")
	var leaves := scene.view.world_root.get_node_or_null("Leaves") as AmbientParticles
	assert_not_null(leaves, "leaves blow through the valley")
	if leaves != null:
		assert_true(leaves.gusty)
		var speeds: Array[float] = []
		for i in 6:
			leaves._process(1.7)
			speeds.append(leaves.speed_scale)
		assert_gt(speeds.max() - speeds.min(), 0.2, "the wind comes in gusts")


func test_only_the_real_world_reflects_the_protagonist() -> void:
	var tal: LookScene = TAL.instantiate()
	add_child_autofree(tal)
	await wait_physics_frames(2)
	var mirror := tal.player.get_node_or_null("Reflection") as AnimatedSprite2D
	assert_not_null(mirror, "the valley's water shows the protagonist")
	if mirror != null:
		assert_true(bool((mirror.material as ShaderMaterial).get_shader_parameter("puddles")))
	tal.queue_free()
	await wait_physics_frames(1)
	var elysia: LookScene = ELYSIA.instantiate()
	add_child_autofree(elysia)
	await wait_physics_frames(2)
	assert_null(elysia.player.get_node_or_null("Reflection"), "Elysia reflects everything but him")
	elysia.queue_free()
	await wait_physics_frames(1)
	var wald: LookScene = WALD.instantiate()
	add_child_autofree(wald)
	await wait_physics_frames(2)
	assert_not_null(wald.player.get_node_or_null("Reflection"), "the night forest is real too")


func test_standing_still_ends_in_a_glance_around() -> void:
	var scene: LookScene = TAL.instantiate()
	add_child_autofree(scene)
	await wait_physics_frames(2)
	var player := scene.player
	player._next_glance = 0.2
	await wait_seconds(0.4)
	assert_true(str(player.sprite.animation).begins_with("look"), "blinks and glances around")
	await wait_seconds(1.3)
	assert_true(str(player.sprite.animation).begins_with("idle"), "then stands again")
	assert_gt(player._next_glance, 3.9, "the next glance waits a while")
	var mira: NpcWalker = null
	for node in scene.map.entities.get_children():
		if node is NpcWalker:
			mira = node
	assert_true(mira != null and mira.glances, "Mira glances around too")
