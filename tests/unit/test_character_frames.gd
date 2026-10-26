extends GutTest
## The generated character sheets (tools/art/make_character.py): the side-view walk and run
## cycles have four different frames, the crown never leaves the frame at the top, and only
## Mira's sheet carries the work rows after the look rows.

const DIR := "res://assets/generated/characters/"
const SHEETS := ["player", "mira", "elysian", "antreiber", "einsiedler", "child", "host"]
const FRAME := Vector2i(24, 32)
const ROW_IDLE := 0
const ROW_WALK := 8
const ROW_RUN := 16
const ROW_WORK := 40


func _image(sheet: String) -> Image:
	var image := Image.load_from_file(ProjectSettings.globalize_path(DIR + sheet + ".png"))
	assert_not_null(image, "%s loads" % sheet)
	image.convert(Image.FORMAT_RGBA8)
	return image


func _frame(image: Image, row: int, frame: int) -> Image:
	return image.get_region(Rect2i(Vector2i(frame * FRAME.x, row * FRAME.y), FRAME))


## Pixels that differ in colour or opacity.
func _diff(a: Image, b: Image) -> int:
	var count := 0
	for y in FRAME.y:
		for x in FRAME.x:
			if a.get_pixel(x, y) != b.get_pixel(x, y):
				count += 1
	return count


## Pixels opaque in one image and not in the other: the silhouette.
func _silhouette_diff(a: Image, b: Image) -> int:
	var count := 0
	for y in FRAME.y:
		for x in FRAME.x:
			if (a.get_pixel(x, y).a > 0.0) != (b.get_pixel(x, y).a > 0.0):
				count += 1
	return count


func _top_row(frame: Image) -> int:
	var count := 0
	for x in FRAME.x:
		if frame.get_pixel(x, 0).a > 0.0:
			count += 1
	return count


func test_the_side_walk_and_run_have_four_different_frames() -> void:
	for sheet: String in SHEETS:
		var image := _image(sheet)
		for row: int in [ROW_WALK, ROW_RUN]:
			var cycle: Array[Image] = []
			for f in 4:
				cycle.append(_frame(image, row, f))
			var label := "%s row %d" % [sheet, row]
			assert_gt(
				_silhouette_diff(cycle[0], cycle[2]), 5, "%s: 0 and 2 differ in outline" % label
			)
			assert_gt(
				_silhouette_diff(cycle[1], cycle[3]), 5, "%s: 1 and 3 differ in outline" % label
			)
			assert_gt(_diff(cycle[0], cycle[1]), 10, "%s: contact and passing differ" % label)


func test_no_cycle_frame_has_the_crown_cut_off() -> void:
	for sheet: String in SHEETS:
		var image := _image(sheet)
		for row_start: int in [ROW_WALK, ROW_RUN]:
			for facing in 8:
				var idle_top := _top_row(_frame(image, ROW_IDLE + facing, 0))
				for f in 4:
					var top := _top_row(_frame(image, row_start + facing, f))
					assert_lte(
						top,
						idle_top,
						(
							"%s row %d frame %d: crown stays in the frame"
							% [sheet, row_start + facing, f]
						)
					)


func test_only_miras_sheet_has_the_work_rows() -> void:
	for sheet: String in SHEETS:
		var rows := _image(sheet).get_height() / FRAME.y
		assert_eq(rows, 48 if sheet == "mira" else 40, sheet)
	var mira := _image("mira")
	for facing in 8:
		assert_gt(
			_diff(_frame(mira, ROW_WORK + facing, 0), _frame(mira, ROW_WORK + facing, 1)),
			0,
			"work, facing %d: the two frames differ" % facing
		)


func test_a_sheet_without_work_rows_still_loads_all_its_other_states() -> void:
	var sheet := load("res://entities/character/sheet_player_look.tres") as CharacterSheet
	var frames := sheet.build_frames()
	assert_true(CharacterSheet.has_look(frames))
	assert_false(CharacterSheet.has_work(frames))
	var mira := (
		(load("res://entities/character/sheet_mira_look.tres") as CharacterSheet).build_frames()
	)
	assert_true(CharacterSheet.has_work(mira))
	for dir in Facing.COUNT:
		assert_eq(mira.get_frame_count(CharacterSheet.animation_name("work", dir as Facing.Dir)), 2)
