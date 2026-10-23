extends GutTest
## Chapter marks (ADR-052): flags "chapter.<id>", with the slice's old flag still readable.


func before_each() -> void:
	WorldState.new_game()


func after_all() -> void:
	WorldState.new_game()


func test_a_chapter_is_marked_once_and_stays() -> void:
	assert_false(Chapter.reached("act1"))
	Chapter.mark("act1")
	assert_true(Chapter.reached("act1"))
	assert_true(WorldState.has_flag("chapter.act1"))
	assert_false(Chapter.reached("act2"), "other chapters are untouched")


func test_the_flag_of_a_chapter_has_its_own_namespace() -> void:
	assert_eq(Chapter.flag_for("slice"), "chapter.slice")
	assert_true(GameState.is_flag_id(Chapter.flag_for("act1")))


func test_the_slice_flag_of_older_builds_still_counts() -> void:
	var old_flags := {"slice.finished": true}
	assert_true(Chapter.in_flags(old_flags, "slice"))
	assert_false(Chapter.in_flags(old_flags, "act1"), "the legacy flag belongs to the slice only")
	assert_true(Chapter.in_flags({"chapter.slice": true}, "slice"))
	assert_false(Chapter.in_flags({}, "slice"))


func test_a_chapter_survives_a_save() -> void:
	Chapter.mark("slice")
	var back := SaveCodec.decode(SaveCodec.encode(WorldState.state))
	assert_true(back.ok, back.error)
	assert_true(Chapter.in_flags(back.state.flags, "slice"))
