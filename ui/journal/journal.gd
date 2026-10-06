class_name Journal
extends MenuLayer
## Quest journal (journal action: J, Back/Select; also from the pause menu). Running quests
## first (newest on top), then finished ones. The focused quest shows its entries in order
## and the objectives of its current stage. No markers, no numbers.
## In the Real world it reads like a diary (ADR-042): open objectives without check boxes,
## and under "Menschen" what happened with each person, sentence by sentence, from the
## shared memories (Game Bible §23: relationships show as memories, never as values).

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
	if WorldState.is_real():
		_add_people()
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
			"", func() -> void: pass, true, tr("JOURNAL_PERSON_%s" % npc.to_upper())
		)
		button.focus_entered.connect(func() -> void: _detail.text = person_text(npc))


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
