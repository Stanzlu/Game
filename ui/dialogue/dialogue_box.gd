class_name DialogueBox
extends CanvasLayer
## Dialogue presenter. Joins group "dialogue_presenter" so world objects can call present().
## Locks the actor while open and blocks saving (a save never captures half a conversation;
## autosaves requested by the dialogue are written right after it ends).
## Settings: text speed (instant shows the whole line), auto-advance, large text.
## Answers are logged with their static ID. The box follows the Elysia/Real skins: a name
## plate over the corner, a voice per speaker while the text types
## (content/dialogue/voices.json), a bobbing marker when the line waits, a cursor on answers.

signal finished

const VOICES_PATH := "res://content/dialogue/voices.json"
const LARGE_FONT := preload("res://assets/fonts/jersey15/Jersey15-Regular.ttf")
const NORMAL_TEXT := 19
const LARGE_TEXT := 27
const NORMAL_TOP := -80.0
const LARGE_TOP := -108.0
## Auto-advance waits this long plus a little per character.
const AUTO_BASE_SECONDS := 1.4
const AUTO_SECONDS_PER_CHAR := 0.05
## A voice syllable every n spoken letters (spaces and punctuation do not count).
const VOICE_EVERY := 2
const SILENT_LETTERS := ".,;:!?…–-„“\"'()"
const OPEN_SECONDS := 0.14
const CLOSE_SECONDS := 0.1
## After the answers appear, presses are ignored this long: the press that finished the
## line and a quick second one must not pick the first answer by accident.
const ANSWER_GUARD_SECONDS := 0.3
## The typewriter breathes at punctuation: seconds at the default text speed.
const PAUSE_AT := ".?!…,;:–"
const PAUSES := {"…": 0.45, ",": 0.12, ";": 0.12, ":": 0.15, "–": 0.15}
const PAUSE_DEFAULT := 0.3
const DEFAULT_SECONDS_PER_CHAR := 0.025

static var _voices: Dictionary = {}

var resource: DialogueResource
var line: DialogueLine
var actor: Node
var cue := ""
var _waiting := false
var _voice := ""
var _quiet_focus := false
var _tween: Tween
var _open := false
var _voiced_letters := 0
var _answer_guard_until := 0

@onready var _root: Control = $Root
@onready var _panel: PanelContainer = $Root/Panel
@onready var _plate: PanelContainer = %NamePlate
@onready var _name: Label = %Name
@onready var _text: DialogueLabel = %Text
@onready var _responses: DialogueResponsesMenu = %Responses
@onready var _template: Button = %ResponseTemplate
@onready var _continue: ContinueMarker = %Continue
@onready var _cursor: MenuCursor = %Cursor


func _ready() -> void:
	add_to_group(&"dialogue_presenter")
	_responses.response_selected.connect(_on_response_selected)
	_responses.response_focused.connect(_on_response_focused)
	_text.skip_action = &""
	_text.pause_at_characters = PAUSE_AT
	_text.spoke.connect(_on_spoke)
	UiSkin.attach(_root)
	Settings.changed.connect(func(_key: String) -> void: _apply_text_size())
	_panel.resized.connect(_place_decorations)
	_apply_text_size()
	hide()


func _exit_tree() -> void:
	if _open:
		SaveSystem.unblock(&"dialogue")
		AudioDirector.duck(false)


func is_open() -> bool:
	return _open


func present(dialogue: DialogueResource, start_cue: String, who: Node = null) -> void:
	if _open:
		return
	_open = true
	resource = dialogue
	actor = who
	cue = start_cue
	if actor != null and actor.has_method(&"lock"):
		actor.call(&"lock", &"dialogue")
	SaveSystem.block(&"dialogue")
	AudioDirector.duck(true)
	_continue.hide()
	_plate.hide()
	show()
	_animate_open()
	Log.info(Log.Category.DIALOGUE, "dialogue start", {"cue": cue})
	_show_line(await DialogueManager.get_next_dialogue_line(resource, cue))


func _show_line(next_line: DialogueLine) -> void:
	if next_line == null:
		_close()
		return
	line = next_line
	_waiting = false
	_continue.hide()
	_cursor.target = null
	_plate.visible = not line.character.is_empty()
	_name.text = tr(line.character, &"dialogue")
	_voice = voice_for(line.character)
	_place_decorations.call_deferred()
	_responses.hide()
	_quiet_focus = true
	_responses.responses = line.responses
	_quiet_focus = false
	_text.dialogue_line = line
	_text.seconds_per_step = Settings.text_seconds_per_char()
	_voiced_letters = 0
	if not line.text.is_empty():
		_text.type_out()
		while _text.is_typing:
			await get_tree().process_frame
		if line != next_line:
			return
	if line.responses.size() > 0:
		_quiet_focus = true
		_answer_guard_until = Time.get_ticks_msec() + int(ANSWER_GUARD_SECONDS * 1000.0)
		_responses.show()
		var items := _responses.get_menu_items()
		if not items.is_empty():
			(items[0] as Control).grab_focus()
		_quiet_focus = false
	else:
		_waiting = true
		_continue.show()
		if Settings.get_bool("text.auto_advance"):
			_auto_advance(next_line)


## Voice kind for a speaker as written in the dialogue file; "" for none (signs, narration).
static func voice_for(character: String) -> String:
	if character.is_empty():
		return ""
	if _voices.is_empty():
		var file := FileAccess.open(VOICES_PATH, FileAccess.READ)
		var parsed: Variant = JSON.parse_string(file.get_as_text()) if file != null else null
		if parsed is Dictionary:
			_voices = parsed
		else:
			Log.error(Log.Category.DIALOGUE, "voice table unreadable", {"path": VOICES_PATH})
			_voices = {"_default": "neutral"}
	return str(_voices.get(character, _voices.get("_default", "neutral")))


func _on_spoke(letter: String, _letter_index: int, _speed: float) -> void:
	# the pause after this letter (if it is one to pause at) follows the text speed
	var speed_factor := Settings.text_seconds_per_char() / DEFAULT_SECONDS_PER_CHAR
	_text.seconds_per_pause_step = float(PAUSES.get(letter, PAUSE_DEFAULT)) * speed_factor
	if letter.strip_edges().is_empty() or SILENT_LETTERS.contains(letter):
		return
	_voiced_letters += 1
	if _voice.is_empty() or (_voiced_letters - 1) % VOICE_EVERY != 0:
		return
	# The Real world is quieter than Elysia.
	var real := WorldState.ui_mode() == GameState.UiMode.REAL
	AudioDirector.voice(_voice, -5.0 if real else 0.0)


func _auto_advance(for_line: DialogueLine) -> void:
	var seconds := AUTO_BASE_SECONDS + AUTO_SECONDS_PER_CHAR * for_line.text.length()
	await NodeTimer.after(self, seconds * Settings.timing_factor())
	if _open and _waiting and line == for_line:
		_advance()


## Swallows presses right after the answers appeared (before the answer list sees them).
func _input(event: InputEvent) -> void:
	if not _open or not _responses.visible or Time.get_ticks_msec() >= _answer_guard_until:
		return
	if event.is_action_pressed(&"interact") or event.is_action_pressed(&"ui_accept"):
		get_viewport().set_input_as_handled()


func _unhandled_input(event: InputEvent) -> void:
	if not _open:
		return
	# back (B, Backspace) also moves the text on, but never picks an answer; Esc stays the
	# pause menu's
	var back := event.is_action_pressed(&"cancel") and not event.is_action_pressed(&"menu")
	if back and _responses.visible:
		return
	var accept := event.is_action_pressed(&"interact") or event.is_action_pressed(&"ui_accept")
	if not (accept or back):
		return
	get_viewport().set_input_as_handled()
	if _text.is_typing:
		_text.skip_typing()
	elif _waiting:
		AudioDirector.ui("tick")
		_advance()


func _advance() -> void:
	_waiting = false
	_continue.hide()
	_show_line(await DialogueManager.get_next_dialogue_line(resource, line.next_id))


func _on_response_focused(item: Variant) -> void:
	if item is Control:
		_cursor.target = item
		if _quiet_focus:
			_cursor.snap()
		else:
			AudioDirector.ui("move")


func _on_response_selected(response: DialogueResponse) -> void:
	# a second confirm while the next line loads would run the answer twice
	if not _responses.visible:
		return
	_responses.hide()
	Log.info(Log.Category.DIALOGUE, "choice", {"cue": cue, "id": response.static_id})
	AudioDirector.ui("confirm")
	_cursor.target = null
	_show_line(await DialogueManager.get_next_dialogue_line(resource, response.next_id))


func _close() -> void:
	_open = false
	_animate_close()
	_cursor.target = null
	Log.info(Log.Category.DIALOGUE, "dialogue end", {"cue": cue})
	if actor != null and is_instance_valid(actor) and actor.has_method(&"unlock"):
		actor.call(&"unlock", &"dialogue")
	actor = null
	SaveSystem.unblock(&"dialogue")
	AudioDirector.duck(false)
	finished.emit()


## The box sinks a little and fades out; a new conversation can start right away.
func _animate_close() -> void:
	_waiting = false
	_continue.hide()
	_responses.hide()
	if _tween != null and _tween.is_valid():
		_tween.kill()
	_tween = create_tween().set_parallel()
	_tween.tween_property(_root, ^"modulate:a", 0.0, CLOSE_SECONDS)
	_tween.tween_property(self, ^"offset:y", 4.0, CLOSE_SECONDS)
	_tween.chain().tween_callback(hide)


## The box rises a few pixels and fades in.
func _animate_open() -> void:
	if _tween != null and _tween.is_valid():
		_tween.kill()
	_root.modulate.a = 0.0
	offset.y = 6.0
	_tween = create_tween().set_parallel()
	_tween.tween_property(_root, ^"modulate:a", 1.0, OPEN_SECONDS)
	(
		_tween
		. tween_property(self, ^"offset:y", 0.0, OPEN_SECONDS)
		. set_trans(Tween.TRANS_QUAD)
		. set_ease(Tween.EASE_OUT)
	)


## Name plate over the top-left corner, the marker in the bottom-right corner.
func _place_decorations() -> void:
	var rect := Rect2(_panel.position, _panel.size)
	_plate.reset_size()
	_plate.position = (rect.position + Vector2(10, -_plate.size.y + 3)).round()
	_continue.position = (rect.end - Vector2(14, 10)).round()


func _apply_text_size() -> void:
	var large := Settings.get_bool("text.large")
	var size := LARGE_TEXT if large else NORMAL_TEXT
	for control: Control in [_name, _template]:
		control.add_theme_font_size_override(&"font_size", size)
		if large:
			control.add_theme_font_override(&"font", LARGE_FONT)
		else:
			control.remove_theme_font_override(&"font")
	for prop: StringName in [&"normal_font_size", &"bold_font_size", &"italics_font_size"]:
		_text.add_theme_font_size_override(prop, size)
	for prop: StringName in [&"normal_font", &"bold_font", &"italics_font"]:
		if large:
			_text.add_theme_font_override(prop, LARGE_FONT)
		else:
			_text.remove_theme_font_override(prop)
	_panel.offset_top = LARGE_TOP if large else NORMAL_TOP
	_place_decorations.call_deferred()
