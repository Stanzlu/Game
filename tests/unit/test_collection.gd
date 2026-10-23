extends GutTest
## Collection: fragments and melodies as flags, curiosities as items, counted by prefix.


func before_each() -> void:
	WorldState.new_game()


func after_all() -> void:
	WorldState.new_game()


func test_a_fragment_is_collected_once() -> void:
	assert_false(Collection.has_fragment("hallway"))
	assert_true(Collection.collect_fragment("hallway"))
	assert_false(Collection.collect_fragment("hallway"), "the second time is not new")
	assert_true(Collection.has_fragment("hallway"))
	assert_eq(Collection.fragments(), 1)
	assert_true(WorldState.has_flag("fragment.hallway"))


func test_melodies_and_fragments_are_counted_apart() -> void:
	Collection.collect_fragment("door")
	Collection.collect_fragment("room")
	Collection.collect_melody("humming")
	assert_eq(Collection.fragments(), 2)
	assert_eq(Collection.melodies(), 1)


func test_an_invalid_id_is_refused_and_logged() -> void:
	assert_false(Collection.collect_fragment("Not An ID"))
	assert_push_error("invalid collectible id")
	assert_eq(Collection.fragments(), 0)


func test_curiosities_count_in_the_pack_and_on_the_shelf() -> void:
	WorldState.add_item("curiosity_tiny_spoon")
	assert_eq(Collection.curiosities(), 1)
	WorldState.place_curiosity("shelf_1", "curiosity_tiny_spoon")
	assert_eq(Collection.curiosities(), 1, "moving it to the shelf does not count it twice")
	WorldState.add_item("item_stone")
	assert_eq(Collection.curiosities(), 1, "a stone is no curiosity")


func test_the_bible_totals() -> void:
	assert_eq(Collection.FRAGMENTS_TOTAL, 24)
	assert_eq(Collection.MELODIES_TOTAL, 12)


func test_collected_ids_survive_a_save() -> void:
	Collection.collect_fragment("closed_door")
	Collection.collect_melody("tal_theme")
	var back := SaveCodec.decode(SaveCodec.encode(WorldState.state))
	assert_true(back.ok, back.error)
	assert_true(back.state.flags.has("fragment.closed_door"))
	assert_true(back.state.flags.has("melody.tal_theme"))
