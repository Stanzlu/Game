class_name Journal
extends MenuLayer
## Quest journal (journal action: J, Back/Select; also from the pause menu). Running quests
## first (newest on top), then finished ones. The focused quest shows its entries in order
## and the objectives of its current stage. No markers, no numbers.
## In the Real world it reads like a diary (ADR-042): open objectives without check boxes,
## and under "Menschen" what happened with each person, sentence by sentence, from the
## shared memories (Game Bible §23: relationships show as memories, never as values).

const JOURNAL_GROUP := &"journal"
## Pixels per second the entry text scrolls (scroll_up/scroll_down: page keys, right stick).
const SCROLL_SPEED := 160.0

var _detail: Label
var _detail_scroll: ScrollContainer


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
	_detail = Label.new()
	_detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_detail.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	_detail.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_detail_scroll.add_child(_detail)


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
	_detail.text = ""
	if running.is_empty() and finished.is_empty():
		list.add_info(tr("JOURNAL_EMPTY"))
	_add_section("JOURNAL_RUNNING", running)
	_add_section("JOURNAL_FINISHED", finished)
	if WorldState.is_real():
		_add_people()
	hint.text = (
		tr("JOURNAL_HINT") % [InputDevice.label_for(&"journal"), InputDevice.label_for(&"cancel")]
	)


func _add_section(header: String, ids: Array[String]) -> void:
	if ids.is_empty():
		return
	list.add_header(header)
	for quest_id in ids:
		var button := list.add_action(
			"", _page_detail, true, tr(ContentDB.quest(quest_id).title_key())
		)
		button.focus_entered.connect(func() -> void: _show_detail(entry_text(quest_id)))


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
		button.focus_entered.connect(func() -> void: _show_detail(person_text(npc)))


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


## Shows an entry; the newest lines are at the end, so the view starts there.
func _show_detail(text: String) -> void:
	_detail.text = text
	_fit_detail.call_deferred()


func _fit_detail() -> void:
	var width := 320.0 if TextSize.large else 240.0
	_detail.custom_minimum_size.x = width
	_detail_scroll.custom_minimum_size.x = width
	var lines := _detail.get_line_count()
	var line_height := _detail.get_line_height() + _detail.get_theme_constant(&"line_spacing")
	var viewport_height := get_viewport().get_visible_rect().size.y
	_detail_scroll.custom_minimum_size.y = clampf(
		lines * line_height, 120.0, viewport_height - 120.0
	)
	await get_tree().process_frame
	_detail_scroll.scroll_vertical = int(_detail_scroll.get_v_scroll_bar().max_value)


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


## Stage texts in the order they happened, then the open and done objectives. In the Real
## world only the open ones, as plain sentences: a diary has no check boxes.
static func entry_text(quest_id: String) -> String:
	var def := ContentDB.quest(quest_id)
	if def == null:
		return ""
	var parts: PackedStringArray = []
	for stage in WorldState.quest_history(quest_id):
		parts.append(TranslationServer.translate(def.stage_key(stage)))
	var current := def.stage(WorldState.quest_stage(quest_id))
	var objectives: PackedStringArray = []
	var real := WorldState.is_real()
	for o in current.objectives if current != null else PackedStringArray():
		var done := WorldState.is_objective_done(quest_id, o)
		if real:
			if not done:
				objectives.append(TranslationServer.translate(def.objective_key(o)))
			continue
		var mark := "[x] " if done else "[ ] "
		objectives.append(mark + TranslationServer.translate(def.objective_key(o)))
	if not objectives.is_empty():
		parts.append("\n".join(objectives))
	return "\n\n".join(parts)


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
