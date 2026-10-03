class_name DialogueBox
extends CanvasLayer
## Dialogue presenter. Joins group "dialogue_presenter" so world objects can call present().
## Locks the actor while open and blocks saving (a save never captures half a conversation;
## autosaves requested by the dialogue are written right after it ends).
## Settings: text speed (instant shows the whole line), auto-advance, large text.
## Answers are logged with their static ID. Elysia/Real skins follow in Phase 3.

signal finished

const NORMAL_TEXT := 8
const LARGE_TEXT := 16
const NORMAL_TOP := -76.0
const LARGE_TOP := -140.0
## Auto-advance waits this long plus a little per character.
const AUTO_BASE_SECONDS := 1.4
const AUTO_SECONDS_PER_CHAR := 0.05

var resource: DialogueResource
var line: DialogueLine
var actor: Node
var cue := ""
var _waiting := false

@onready var _panel: PanelContainer = $Panel
@onready var _name: Label = %Name
@onready var _text: DialogueLabel = %Text
@onready var _responses: DialogueResponsesMenu = %Responses
@onready var _template: Button = %ResponseTemplate


func _ready() -> void:
	add_to_group(&"dialogue_presenter")
	_responses.response_selected.connect(_on_response_selected)
	_text.skip_action = &""
	Settings.changed.connect(func(_key: String) -> void: _apply_text_size())
	_apply_text_size()
	hide()


func _exit_tree() -> void:
	if visible:
		SaveSystem.unblock(&"dialogue")


func is_open() -> bool:
	return visible


func present(dialogue: DialogueResource, start_cue: String, who: Node = null) -> void:
	if visible:
		return
	resource = dialogue
	actor = who
	cue = start_cue
	if actor != null and actor.has_method(&"lock"):
		actor.call(&"lock", &"dialogue")
	SaveSystem.block(&"dialogue")
	show()
	Log.info(Log.Category.DIALOGUE, "dialogue start", {"cue": cue})
	_show_line(await DialogueManager.get_next_dialogue_line(resource, cue))


func _show_line(next_line: DialogueLine) -> void:
	if next_line == null:
		_close()
		return
	line = next_line
	_waiting = false
	_name.visible = not line.character.is_empty()
	_name.text = tr(line.character, &"dialogue")
	_responses.hide()
	_responses.responses = line.responses
	_text.dialogue_line = line
	_text.seconds_per_step = Settings.text_seconds_per_char()
	if not line.text.is_empty():
		_text.type_out()
		while _text.is_typing:
			await get_tree().process_frame
		if line != next_line:
			return
	if line.responses.size() > 0:
		_responses.show()
	else:
		_waiting = true
		if Settings.get_bool("text.auto_advance"):
			_auto_advance(next_line)


func _auto_advance(for_line: DialogueLine) -> void:
	var seconds := AUTO_BASE_SECONDS + AUTO_SECONDS_PER_CHAR * for_line.text.length()
	await get_tree().create_timer(seconds * Settings.timing_factor()).timeout
	if visible and _waiting and line == for_line:
		_advance()


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if not (event.is_action_pressed(&"interact") or event.is_action_pressed(&"ui_accept")):
		return
	get_viewport().set_input_as_handled()
	if _text.is_typing:
		_text.skip_typing()
	elif _waiting:
		_advance()


func _advance() -> void:
	_waiting = false
	_show_line(await DialogueManager.get_next_dialogue_line(resource, line.next_id))


func _on_response_selected(response: DialogueResponse) -> void:
	Log.info(Log.Category.DIALOGUE, "choice", {"cue": cue, "id": response.static_id})
	_show_line(await DialogueManager.get_next_dialogue_line(resource, response.next_id))


func _close() -> void:
	hide()
	Log.info(Log.Category.DIALOGUE, "dialogue end", {"cue": cue})
	if actor != null and is_instance_valid(actor) and actor.has_method(&"unlock"):
		actor.call(&"unlock", &"dialogue")
	actor = null
	SaveSystem.unblock(&"dialogue")
	finished.emit()


func _apply_text_size() -> void:
	var large := Settings.get_bool("text.large")
	var size := LARGE_TEXT if large else NORMAL_TEXT
	_name.add_theme_font_size_override(&"font_size", size)
	for prop: StringName in [&"normal_font_size", &"bold_font_size", &"italics_font_size"]:
		_text.add_theme_font_size_override(prop, size)
	_template.add_theme_font_size_override(&"font_size", size)
	_panel.offset_top = LARGE_TOP if large else NORMAL_TOP
