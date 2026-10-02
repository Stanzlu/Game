extends GutTest


func test_cardinal_and_diagonal_directions() -> void:
	assert_eq(Facing.from_vector(Vector2.RIGHT), Facing.Dir.E)
	assert_eq(Facing.from_vector(Vector2.DOWN), Facing.Dir.S)
	assert_eq(Facing.from_vector(Vector2.LEFT), Facing.Dir.W)
	assert_eq(Facing.from_vector(Vector2.UP), Facing.Dir.N)
	assert_eq(Facing.from_vector(Vector2(1, 1)), Facing.Dir.SE)
	assert_eq(Facing.from_vector(Vector2(-1, -1)), Facing.Dir.NW)


func test_round_trip() -> void:
	for d in Facing.COUNT:
		assert_eq(Facing.from_vector(Facing.to_vector(d as Facing.Dir)), d)


func test_stable_facing_ignores_small_wobble() -> void:
	var near_boundary := Vector2.from_angle(Facing.STEP * 0.5 + 0.05)
	assert_eq(Facing.from_vector_stable(Facing.Dir.E, near_boundary), Facing.Dir.E)
	assert_eq(Facing.from_vector_stable(Facing.Dir.E, Vector2.DOWN), Facing.Dir.S)
	assert_eq(Facing.from_vector_stable(Facing.Dir.W, Vector2.ZERO), Facing.Dir.W)


func test_character_sheet_builds_all_animations() -> void:
	var sheet := load("res://entities/character/sheet_player.tres") as CharacterSheet
	assert_not_null(sheet)
	if sheet == null:
		return
	var frames := sheet.build_frames()
	assert_eq(frames.get_animation_names().size(), CharacterSheet.STATES.size() * Facing.COUNT)
	assert_eq(frames.get_frame_count(CharacterSheet.animation_name("walk", Facing.Dir.N)), 4)
	assert_eq(frames.get_frame_count(CharacterSheet.animation_name("sit", Facing.Dir.S)), 1)
	assert_same(sheet.build_frames(), frames, "frames are cached per texture")
