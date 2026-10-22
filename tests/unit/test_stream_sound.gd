extends GutTest
## The brook of the valley is heard where it flows (MapView), positional sounds carry a
## limited distance (SoundBank).


func _emitters(view: MapView) -> Array[AudioStreamPlayer2D]:
	var found: Array[AudioStreamPlayer2D] = []
	for child in view.get_children():
		if child is AudioStreamPlayer2D:
			found.append(child)
	return found


func test_the_valley_brook_has_emitters_along_its_water() -> void:
	var view := MapView.new()
	view.map_path = "res://content/maps/tal.txt"
	add_child_autofree(view)
	var emitters := _emitters(view)
	assert_gte(emitters.size(), 3, "a few along the brook")
	assert_lte(emitters.size(), 14)
	var loudest := -99.0
	var quietest := 99.0
	for emitter in emitters:
		var cell := view.world_to_cell(emitter.global_position)
		assert_true(_near_water(view, cell, 3), "at the water: %s" % cell)
		assert_eq(emitter.bus, &"Ambience")
		assert_true(emitter.playing, "running")
		assert_lte(emitter.max_distance, 260.0)
		loudest = maxf(loudest, emitter.volume_db)
		quietest = minf(quietest, emitter.volume_db)
	assert_gt(loudest, quietest, "the falls are louder than the flat water")
	# the stepping stones are where the quest is: the brook must be loud there
	var stones: Vector2i = view.data.find_marker("spawn_stones_e")[0]["cell"]
	var nearest := 999.0
	for emitter in emitters:
		var cell := view.world_to_cell(emitter.global_position)
		nearest = minf(nearest, Vector2(cell - stones).length())
	assert_lt(nearest, 5.0, "an emitter at the stepping stones")
	for i in emitters.size():
		for j in range(i + 1, emitters.size()):
			var apart := emitters[i].position.distance_to(emitters[j].position)
			assert_gt(apart, 100.0, "not stacked on each other")


func _near_water(view: MapView, cell: Vector2i, radius: int) -> bool:
	for dy in range(-radius, radius + 1):
		for dx in range(-radius, radius + 1):
			if view.data.surface_at_cell(cell + Vector2i(dx, dy)) == &"water":
				return true
	return false


func test_other_styles_have_no_brook() -> void:
	var view := MapView.new()
	view.map_path = "res://content/maps/elysia.txt"
	add_child_autofree(view)
	assert_eq(_emitters(view).size(), 0, "Elysia has its own garden loop")


func test_positional_sounds_carry_a_limited_distance() -> void:
	var holder := Node2D.new()
	add_child_autofree(holder)
	SoundBank.play_at(holder, "frog_croak", Vector2(10, 20), -40.0)
	var player := holder.get_child(0) as AudioStreamPlayer2D
	assert_eq(player.max_distance, SoundBank.HEARING_DISTANCE)
	assert_lte(player.max_distance, 400.0)
	assert_gt(player.attenuation, 1.0)
	SoundBank.play_at(holder, "frog_croak", Vector2(10, 20), -40.0, 900.0)
	assert_eq((holder.get_child(1) as AudioStreamPlayer2D).max_distance, 900.0, "an exception")
