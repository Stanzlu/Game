extends GutTest
## The cursor of a menu list glides over the whole screen, not inside the list: it must not
## stay behind outside the panel when its row scrolled out of the list's view.


func test_the_cursor_goes_with_a_row_that_scrolls_out_of_view() -> void:
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(100, 50)
	var box := VBoxContainer.new()
	scroll.add_child(box)
	var rows: Array[Button] = []
	for i in 10:
		var row := Button.new()
		row.text = "row %d" % i
		row.custom_minimum_size = Vector2(80, 30)
		box.add_child(row)
		rows.append(row)
	add_child_autofree(scroll)
	var cursor := MenuCursor.new()
	add_child_autofree(cursor)
	await wait_process_frames(4)
	cursor.target = rows[0]
	await wait_process_frames(3)
	assert_true(cursor.visible, "the first row is in view")
	cursor.target = rows[9]
	await wait_process_frames(3)
	assert_false(cursor.visible, "a row below the fold takes no cursor out of the panel")
	scroll.scroll_vertical = 1000
	await wait_process_frames(4)
	assert_true(cursor.visible, "scrolled to, it is back")
	cursor.target = rows[0]
	await wait_process_frames(3)
	assert_false(cursor.visible, "and a row above the view has none either")


func test_a_row_outside_a_scroll_area_keeps_its_cursor() -> void:
	var row := Button.new()
	row.custom_minimum_size = Vector2(80, 30)
	add_child_autofree(row)
	var cursor := MenuCursor.new()
	add_child_autofree(cursor)
	await wait_process_frames(4)
	cursor.target = row
	await wait_process_frames(3)
	assert_true(cursor.visible)
