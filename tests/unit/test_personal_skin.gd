extends GutTest
## The third skin, "personal" (Game Bible §34 "Später": handwriting, notes, colours; ADR-071 O17,
## S10): from the end of Act IV on the Real world's interface is written in Patrick Hand in a
## hand's palette. It is worn, not saved (the mode stays REAL, the chapter mark decides), the small
## and the title fonts stay the pixel fonts, every character of the game's text has a glyph, and
## large text still fits the dialogue box.

const BOX := preload("res://ui/dialogue/dialogue_box.tscn")
const HAND := "res://assets/fonts/patrickhand/PatrickHand-Regular.ttf"
const DIALOGUE_DIR := "res://content/dialogue"
const SMALL_TYPES: Array[StringName] = [
	&"SmallLabel", &"PromptLabel", &"PromptKeyLabel", &"PromptText"
]


func before_each() -> void:
	WorldState.new_game()
	WorldState.set_ui_mode(GameState.UiMode.REAL)
	Settings.set_value("text.large", false, false)
	Settings.set_value("text.speed", 3, false)


func after_each() -> void:
	Settings.set_value("text.large", false, false)
	Settings.set_value("text.speed", 1, false)
	TextSize.apply(false)
	WorldState.new_game()


func _files(dir: String) -> PackedStringArray:
	var found: PackedStringArray = []
	for name in DirAccess.get_files_at(dir):
		if name.ends_with(".dialogue"):
			found.append(dir.path_join(name))
	for sub in DirAccess.get_directories_at(dir):
		found.append_array(_files(dir.path_join(sub)))
	return found


## The text of every spoken or told line (the part before its ID), for all stories.
func _lines() -> PackedStringArray:
	var lines: PackedStringArray = []
	for path in _files(DIALOGUE_DIR):
		for line in FileAccess.get_file_as_string(path).split("\n"):
			var at := line.find("[ID:")
			if at > -1 and not line.strip_edges().begins_with("#"):
				lines.append(line.substr(0, at).strip_edges())
	return lines


# --- Which skin ----------------------------------------------------------------------------------


func test_the_hand_is_worn_from_the_end_of_act_four_on_and_only_in_the_real_world() -> void:
	assert_eq(UiSkin.theme_for(GameState.UiMode.REAL), UiSkin.REAL_SKIN, "before the end of Act IV")
	assert_false(UiSkin.personal())
	Chapter.mark("act3")
	assert_eq(UiSkin.theme_for(GameState.UiMode.REAL), UiSkin.REAL_SKIN, "the way west is not it")
	Chapter.mark("act4")
	assert_eq(UiSkin.theme_for(GameState.UiMode.REAL), UiSkin.PERSONAL_SKIN)
	assert_true(UiSkin.personal())
	assert_eq(
		UiSkin.theme_for(GameState.UiMode.ELYSIA), UiSkin.ELYSIA_SKIN, "Elysia keeps its gold"
	)
	WorldState.set_ui_mode(GameState.UiMode.ELYSIA)
	assert_false(UiSkin.personal())


func test_a_worn_skin_follows_the_chapter_mark_and_a_loaded_save() -> void:
	var panel := PanelContainer.new()
	add_child_autofree(panel)
	UiSkin.attach(panel)
	await wait_physics_frames(1)
	assert_eq(panel.theme, UiSkin.REAL_SKIN)
	Chapter.mark("act4")
	assert_eq(panel.theme, UiSkin.PERSONAL_SKIN, "the mark that ends the act changes the hand")
	var loaded := GameState.new()
	loaded.ui_mode = GameState.UiMode.REAL
	WorldState.replace_state(loaded)
	assert_eq(panel.theme, UiSkin.REAL_SKIN, "a save from before it has the quiet one")
	loaded.flags[Chapter.flag_for("act4")] = true
	WorldState.replace_state(loaded)
	assert_eq(panel.theme, UiSkin.PERSONAL_SKIN, "and one from after it the hand")


func test_the_skin_changes_no_save_the_mode_stays_real() -> void:
	Chapter.mark("act4")
	var result := SaveCodec.decode(SaveCodec.encode(WorldState.state))
	assert_true(result.ok, result.error)
	assert_eq(result.state.ui_mode, GameState.UiMode.REAL)
	assert_eq(result.schema_version, 2, "no new schema")


# --- The fonts -------------------------------------------------------------------------------


func test_the_body_is_patrick_hand_with_the_pixel_font_behind_it() -> void:
	var font := UiSkin.PERSONAL_SKIN.default_font as FontVariation
	assert_not_null(font)
	assert_eq(font.base_font.resource_path, HAND)
	assert_eq(font.fallbacks.size(), 1, "a letter the hand lacks falls back to the pixel body font")
	assert_true(font.fallbacks[0].resource_path.contains("jersey10"))
	# the arrows of the hints (journal, controls) are in no body font: they stay Tiny5, a small label
	var arrow := "↑".unicode_at(0)
	assert_false(UiSkin.PERSONAL_FONT.has_char(arrow), "the hand has no arrows")
	var small := UiSkin.PERSONAL_SKIN.get_font(&"font", &"SmallLabel")
	assert_true(small.has_char(arrow), "the small font has")


func test_every_character_of_the_story_has_a_glyph_in_the_hand_or_its_fallback() -> void:
	var font := UiSkin.PERSONAL_SKIN.default_font
	var seen := {}
	var missing: PackedStringArray = []
	for line in _lines():
		for i in line.length():
			var c := line.unicode_at(i)
			if c > 32 and not seen.has(c):
				seen[c] = true
				if not font.has_char(c):
					missing.append(char(c))
	assert_gt(seen.size(), 60, "all the text was read")
	assert_eq(missing, PackedStringArray(), "no box where a letter should be")
	for c: String in "ÄÖÜäöüß„“…—":
		assert_true(font.has_char(c.unicode_at(0)), c)


func test_small_text_and_titles_stay_the_pixel_fonts_in_the_hand() -> void:
	var skin := UiSkin.PERSONAL_SKIN
	for type in SMALL_TYPES:
		assert_eq(skin.get_font_size(&"font_size", type), 8, str(type))
		assert_true(skin.get_font(&"font", type).resource_path.contains("tiny5"), str(type))
	for type: StringName in [&"TitleLabel", &"SubtitleLabel"]:
		assert_eq(skin.get_font_size(&"font_size", type), 27, str(type))
		assert_true(skin.get_font(&"font", type).resource_path.contains("jersey15"), str(type))
	# as the controls see it: a prompt under the skin is small, not written in the hand
	var label := Label.new()
	label.theme_type_variation = &"PromptText"
	label.theme = UiSkin.PERSONAL_SKIN
	add_child_autofree(label)
	assert_eq(label.get_theme_font_size(&"font_size"), 8)
	assert_true(label.get_theme_font(&"font").resource_path.contains("tiny5"))


func test_large_text_grows_the_hand_with_the_other_fonts() -> void:
	var skin := UiSkin.PERSONAL_SKIN
	TextSize.apply(true)
	assert_eq(skin.default_font_size, UiSkin.PERSONAL_SIZE[true])
	for type in SMALL_TYPES:
		assert_eq(skin.get_font_size(&"font_size", type), 16, "%s doubles" % type)
	TextSize.apply(false)
	assert_eq(skin.default_font_size, UiSkin.PERSONAL_SIZE[false])
	for type in SMALL_TYPES:
		assert_eq(skin.get_font_size(&"font_size", type), 8, "%s is small again" % type)


func test_the_cursor_of_the_skin_is_its_own_stroke() -> void:
	var skin := UiSkin.PERSONAL_SKIN
	assert_eq(skin.get_constant(&"style", &"MenuCursor"), MenuCursor.Style.SCRIBBLE)
	assert_ne(
		skin.get_color(&"color", &"MenuCursor"), UiSkin.REAL_SKIN.get_color(&"color", &"MenuCursor")
	)
	assert_ne(
		skin.get_color(&"font_color", &"Label"), Color.BLACK, "the text is light on the dark note"
	)


# --- The dialogue box ------------------------------------------------------------------------


func _longest_line() -> String:
	var longest := ""
	for line in _lines():
		# narration or speech: strip a speaker, skip anything with markup
		var text := line
		var colon := text.find(": ")
		if colon > -1 and colon < 14:
			text = text.substr(colon + 2)
		if text.length() > longest.length() and not text.contains("[") and not text.contains("{"):
			longest = text
	return longest


## The height the text needs against the height the panel gives it (the game's longest line).
func _fit(large: bool) -> Vector2:
	Settings.set_value("text.large", large, false)
	TextSize.apply(large)
	var box: DialogueBox = BOX.instantiate()
	add_child_autofree(box)
	var resource := DialogueManager.create_resource_from_text(
		"~ long\nMira: %s\n=> END\n" % _longest_line()
	)
	box.present(resource, "long")
	await wait_until(func() -> bool: return box.is_open(), 5.0)
	await wait_physics_frames(6)
	var text: RichTextLabel = box.get_node("%Text")
	var panel: Control = box.get_node("Root/Panel")
	return Vector2(text.position.y + text.get_content_height(), panel.size.y)


func test_the_longest_line_of_the_story_fits_the_box_in_every_skin_and_size() -> void:
	assert_gt(_longest_line().length(), 120, "the longest line was found")
	for personal: bool in [false, true]:
		if personal:
			Chapter.mark("act4")
		for large: bool in [false, true]:
			var fit: Vector2 = await _fit(large)
			assert_lte(
				fit.x,
				fit.y,
				(
					"personal %s, large %s: the text %d px, the panel %d px"
					% [personal, large, fit.x, fit.y]
				)
			)
