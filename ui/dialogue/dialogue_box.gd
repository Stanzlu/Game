class_name DialogueBox
extends CanvasLayer
## Minimal dialogue presenter (Phase 1). Joins group "dialogue_presenter" so world objects
## can call present(). Locks the actor while open. Phase 2 adds text speed, auto-advance
## and the Elysia/Real skins.

signal finished

var resource: DialogueResource
var line: DialogueLine
var actor: Node
var _waiting := false

@onready var _name: Label = %Name
@onready var _text: DialogueLabel = %Text
@onready var _responses: DialogueResponsesMenu = %Responses


func _ready() -> void:
	add_to_group(&"dialogue_presenter")
	_responses.response_selected.connect(_on_response_selected)
	_text.skip_action = &""
	hide()


func is_open() -> bool:
	return visible


func present(dialogue: DialogueResource, cue: String, who: Node = null) -> void:
	if visible:
		return
	resource = dialogue
	actor = who
	if actor != null and actor.has_method(&"lock"):
		actor.call(&"lock", &"dialogue")
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
	if not line.text.is_empty():
		_text.type_out()
		await _text.finished_typing
	if line.responses.size() > 0:
		_responses.show()
	else:
		_waiting = true


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if not (event.is_action_pressed(&"interact") or event.is_action_pressed(&"ui_accept")):
		return
	get_viewport().set_input_as_handled()
	if _text.is_typing:
		_text.skip_typing()
	elif _waiting:
		_waiting = false
		_show_line(await DialogueManager.get_next_dialogue_line(resource, line.next_id))


func _on_response_selected(response: DialogueResponse) -> void:
	_show_line(await DialogueManager.get_next_dialogue_line(resource, response.next_id))


func _close() -> void:
	hide()
	Log.info(Log.Category.DIALOGUE, "dialogue end")
	if actor != null and is_instance_valid(actor) and actor.has_method(&"unlock"):
		actor.call(&"unlock", &"dialogue")
	actor = null
	finished.emit()
