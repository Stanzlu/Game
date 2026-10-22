class_name Journal
extends MenuLayer
## Quest journal (journal action: J, Back/Select; also from the pause menu). Running quests
## first (newest on top), then finished ones. The focused quest shows its entries in order
## and the objectives of its current stage. No markers, no numbers.
## In the Real world it reads like a diary (ADR-042): open objectives only, and under
## "Menschen" what happened with each person, sentence by sentence, from the shared memories
## (Game Bible §23: relationships show as memories, never as values). Under "Dinge" stands
## what the hero carries, each with its own line. Elysia marks open objectives with a gem and
## mutes the done ones.

const JOURNAL_GROUP := &"journal"
## Pixels per second the entry text scrolls (scroll_up/scroll_down: page keys, right stick).
const SCROLL_SPEED := 160.0

## Gap between the paragraphs of an entry.
const PARAGRAPH_GAP := 6
const DETAIL_WIDTH := 240.0
const DETAIL_WIDTH_LARGE := 320.0

var _detail_box: VBoxContainer
var _detail_scroll: ScrollContainer
var _base_hint := ""


func _ready() -> void:
	title_key = "JOURNAL_TITLE"
	panel_width = 180
	layer = 42
	super()
	add_to_group(JOURNAL_GROUP)
	# long entries scroll instead of growing past the screen (by the end of the slice a
	# quest has many stages and Mira many memories)
	_detail_scroll = ScrollContainer.new()
	_detail_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	body.add_child(_detail_scroll)
	_detail_scroll.get_v_scroll_bar().custom_minimum_size.x = SCROLLBAR_WIDTH
	keep_upright(_detail_scroll)
	# one label per paragraph: done objectives are muted, open ones carry the gem
	_detail_box = VBoxContainer.new()
	_detail_box.add_theme_constant_override(&"separation", PARAGRAPH_GAP)
	_detail_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_detail_scroll.add_child(_detail_box)


func _build() -> void:
	var running: Array[String] = []
	var finished: Array[String] = []
	for quest_id: String in WorldState.state.quests:
		if not ContentDB.has_quest(quest_id):
			continue
		if WorldState.is_quest_done(quest_id):
			finished.push_front(quest_id)
		else:
			running.push_front(quest_id)
	_clear_detail()
	_add_section("JOURNAL_RUNNING", running)
	_add_section("JOURNAL_FINISHED", finished)
	if WorldState.is_real():
		_add_people()
	_add_things()
	var empty := list.buttons().is_empty()
	if empty:
		list.add_info(tr("JOURNAL_EMPTY"))
	# nothing to read, so no empty column beside the line
	_detail_scroll.visible = not empty
	_base_hint = (
		tr("JOURNAL_HINT")
		% [
			InputDevice.label_for(&"interact"),
			InputDevice.label_for(&"journal"),
			InputDevice.label_for(&"cancel")
		]
	)
	hint.text = _base_hint


func _add_section(header: String, ids: Array[String]) -> void:
	if ids.is_empty():
		return
	list.add_header(header)
	for quest_id in ids:
		var button := list.add_action(
			"", _page_detail, true, tr(ContentDB.quest(quest_id).title_key())
		)
		button.focus_entered.connect(func() -> void: _show_detail(entry_parts(quest_id)))


func _add_people() -> void:
	var people: Array[String] = []
	for npc in GameState.NPCS:
		if not person_text(npc).is_empty():
			people.append(npc)
	if people.is_empty():
		return
	list.add_header("JOURNAL_PEOPLE")
	for npc in people:
		var button := list.add_action(
			"", _page_detail, true, tr("JOURNAL_PERSON_%s" % npc.to_upper())
		)
		button.focus_entered.connect(func() -> void: _show_detail(_plain(person_text(npc))))


## What the player carries: the name, and on the page the item's own line (the spoon, the
## seed). Elysia adds the rarity; the Real world has no such thing.
func _add_things() -> void:
	var ids: Array[String] = []
	for item_id: String in WorldState.state.inventory:
		if WorldState.item_count(item_id) > 0 and ContentDB.has_item(item_id):
			ids.append(item_id)
	if ids.is_empty():
		return
	list.add_header("JOURNAL_THINGS")
	for item_id in ids:
		var def := ContentDB.item(item_id)
		var count := WorldState.item_count(item_id)
		var shown := tr(def.name_key())
		if count > 1:
			shown += " ×%d" % count
		var button := list.add_action("", _page_detail, true, shown)
		button.focus_entered.connect(func() -> void: _show_detail(thing_parts(item_id)))


## Confirming a row turns the entry's page (from the end back to the start): controllers
## without a second stick can read long entries too.
func _page_detail() -> void:
	var bar := _detail_scroll.get_v_scroll_bar()
	if bar.max_value <= bar.page:
		return
	var at_end := _detail_scroll.scroll_vertical >= int(bar.max_value - bar.page) - 1
	_detail_scroll.scroll_vertical = (
		0 if at_end else _detail_scroll.scroll_vertical + int(bar.page * 0.8)
	)


func _clear_detail() -> void:
	for child in _detail_box.get_children():
		_detail_box.remove_child(child)
		child.queue_free()


## One paragraph that needs no marks.
static func _plain(text: String) -> Array[Dictionary]:
	return [{"text": text, "kind": "text"}]


## Shows an entry (see entry_parts); the newest lines are at the end, so the view starts there.
func _show_detail(parts: Array[Dictionary]) -> void:
	_clear_detail()
	var elysia := not WorldState.is_real()
	for part in parts:
		var label := Label.new()
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		label.text = str(part["text"])
		match part["kind"]:
			"done", "note":
				label.theme_type_variation = &"MutedLabel"
		if part["kind"] == "open" and elysia:
			var row := HBoxContainer.new()
			row.add_theme_constant_override(&"separation", 5)
			row.add_child(JournalMark.new())
			row.add_child(label)
			_detail_box.add_child(row)
		else:
			_detail_box.add_child(label)
	_fit_detail.call_deferred()


func _fit_detail() -> void:
	var width := DETAIL_WIDTH_LARGE if TextSize.large else DETAIL_WIDTH
	# the page is the width of the scroll view without its bar, or the text ends under the bar
	_detail_box.custom_minimum_size.x = width - SCROLLBAR_WIDTH
	_detail_scroll.custom_minimum_size.x = width
	# wrapped lines have their height one layout pass after the width is known
	await get_tree().process_frame
	await get_tree().process_frame
	var viewport_height := get_viewport().get_visible_rect().size.y
	_detail_scroll.custom_minimum_size.y = clampf(
		_detail_box.get_combined_minimum_size().y, 120.0, viewport_height - SCREEN_MARGIN
	)
	await get_tree().process_frame
	var bar := _detail_scroll.get_v_scroll_bar()
	_detail_scroll.scroll_vertical = int(bar.max_value)
	# a long entry says how to read on
	var overflows := bar.max_value > bar.page + 1.0
	hint.text = _base_hint + ("\n" + tr("JOURNAL_SCROLL_HINT") if overflows else "")


func _process(delta: float) -> void:
	if not visible:
		return
	var direction := Input.get_axis(&"scroll_up", &"scroll_down")
	if absf(direction) > 0.1:
		_detail_scroll.scroll_vertical += roundi(direction * SCROLL_SPEED * delta)


## What happened with a person: one sentence per shared memory, in the order they happened.
static func person_text(npc_id: String) -> String:
	var r: GameState.Relationship = WorldState.state.relationships.get(npc_id)
	if r == null:
		return ""
	var parts: PackedStringArray = []
	for memory in r.memories:
		var key := "MEMORY_%s_%s" % [npc_id.to_upper(), memory.to_upper()]
		if ContentValidator.has_translation(key):
			parts.append(TranslationServer.translate(key))
	return "\n".join(parts)


## Stage texts in the order they happened, then the open and done objectives, as paragraphs
## {"text", "kind"}: kind is "text" (a stage), "open" or "done". The Real world lists only the
## open objectives: a diary has no check boxes.
static func entry_parts(quest_id: String) -> Array[Dictionary]:
	var parts: Array[Dictionary] = []
	var def := ContentDB.quest(quest_id)
	if def == null:
		return parts
	for stage in WorldState.quest_history(quest_id):
		parts.append({"text": TranslationServer.translate(def.stage_key(stage)), "kind": "text"})
	var current := def.stage(WorldState.quest_stage(quest_id))
	var real := WorldState.is_real()
	for o in current.objectives if current != null else PackedStringArray():
		var done := WorldState.is_objective_done(quest_id, o)
		if real and done:
			continue
		(
			parts
			. append(
				{
					"text": TranslationServer.translate(def.objective_key(o)),
					"kind": "done" if done else "open",
				}
			)
		)
	return parts


## The thing's own line, and in Elysia its rarity.
static func thing_parts(item_id: String) -> Array[Dictionary]:
	var parts: Array[Dictionary] = []
	var def := ContentDB.item(item_id)
	if def == null:
		return parts
	parts.append({"text": TranslationServer.translate(def.desc_key()), "kind": "text"})
	if not WorldState.is_real():
		var rarity := TranslationServer.translate(def.rarity_key())
		parts.append({"text": TranslationServer.translate("HUD_RARITY") % rarity, "kind": "note"})
	return parts


## The entry as plain text (for logs and tests; the page draws its own marks): stages, then the
## objectives, in Elysia with "[ ]"/"[x]" in front.
static func entry_text(quest_id: String) -> String:
	var texts: PackedStringArray = []
	var objectives: PackedStringArray = []
	for part in entry_parts(quest_id):
		match part["kind"]:
			"text":
				texts.append(str(part["text"]))
			"open", "done":
				var mark := ""
				if not WorldState.is_real():
					mark = "[x] " if part["kind"] == "done" else "[ ] "
				objectives.append(mark + str(part["text"]))
	if not objectives.is_empty():
		texts.append("\n".join(objectives))
	return "\n\n".join(texts)


func open() -> void:
	super()
	get_tree().paused = true


func close() -> void:
	if not visible:
		return
	super()
	# opened from the pause menu: back to it, the game stays paused
	for node in get_tree().get_nodes_in_group(GROUP):
		if node != self and (node as MenuLayer).visible:
			return
	get_tree().paused = false


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		if event.is_action_pressed(&"journal") and MenuLayer.can_open(get_tree()):
			get_viewport().set_input_as_handled()
			open()
		return
	if event.is_action_pressed(&"journal"):
		get_viewport().set_input_as_handled()
		close()
		return
	super(event)
