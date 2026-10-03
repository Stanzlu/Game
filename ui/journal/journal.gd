class_name Journal
extends MenuLayer
## Quest journal (journal action: J, Back/Select; also from the pause menu). Running quests
## first (newest on top), then finished ones. The focused quest shows its entries in order
## and the objectives of its current stage. No markers, no numbers.

const JOURNAL_GROUP := &"journal"

var _detail: Label


func _ready() -> void:
	title_key = "JOURNAL_TITLE"
	panel_width = 180
	layer = 42
	super()
	add_to_group(JOURNAL_GROUP)
	_detail = Label.new()
	_detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_detail.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	_detail.custom_minimum_size = Vector2(240, 120)
	_detail.size_flags_vertical = Control.SIZE_FILL
	body.add_child(_detail)


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
	hint.text = tr("JOURNAL_HINT")


func _add_section(header: String, ids: Array[String]) -> void:
	if ids.is_empty():
		return
	list.add_header(header)
	for quest_id in ids:
		var button := list.add_action(
			"", func() -> void: pass, true, tr(ContentDB.quest(quest_id).title_key())
		)
		button.focus_entered.connect(func() -> void: _detail.text = entry_text(quest_id))


## Stage texts in the order they happened, then the open and done objectives.
static func entry_text(quest_id: String) -> String:
	var def := ContentDB.quest(quest_id)
	if def == null:
		return ""
	var parts: PackedStringArray = []
	for stage in WorldState.quest_history(quest_id):
		parts.append(TranslationServer.translate(def.stage_key(stage)))
	var current := def.stage(WorldState.quest_stage(quest_id))
	var objectives: PackedStringArray = []
	for o in current.objectives if current != null else PackedStringArray():
		var mark := "[x] " if WorldState.is_objective_done(quest_id, o) else "[ ] "
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
	get_tree().paused = false


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		if event.is_action_pressed(&"journal") and not MenuLayer.any_open(get_tree()):
			get_viewport().set_input_as_handled()
			open()
		return
	if event.is_action_pressed(&"journal"):
		get_viewport().set_input_as_handled()
		close()
		return
	super(event)
