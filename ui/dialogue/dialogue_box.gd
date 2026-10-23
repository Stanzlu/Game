class_name DialogueBox
extends CanvasLayer
## Dialogue presenter. Joins group "dialogue_presenter" so world objects can call present().
## Locks the actor while open and blocks saving (a save never captures half a conversation;
## autosaves requested by the dialogue are written right after it ends).
## Settings: text speed (instant shows the whole line), auto-advance, large text.
## Answers are logged with their static ID. The box follows the Elysia/Real skins: a name
## plate over the corner, a voice per speaker while the text types
## (content/dialogue/voices.json), a bobbing marker when the line waits, a cursor on answers.

signal opened
signal finished
## A voice blip was played for a spoken (not narrated) line: the speaker's name as written in
## the dialogue file. Lets a speaker's sprite move its mouth in time with the voice.
signal syllable(character: String)

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
## Holding interact this long skips: lines finish and move on every HOLD_STEP seconds. It
## stops at answers, so holding never picks one.
const HOLD_TO_SKIP := 0.5
const HOLD_STEP := 0.15
## Voice level at the call, after the files were normalised by loudness (check_levels.py).
## The Real world is quieter than Elysia.
const VOICE_DB_REAL := -2.0
const VOICE_DB_ELYSIA := -1.0
## Text effects that move or flash the letters; "Weniger Flackern" removes them. [wait]
## stays: a pause is no flicker.
const MOTION_TAGS := "wave|rainbow|shake|tornado|pulse|fade"

static var _voices: Dictionary = {}
static var _motion_regex: RegEx

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
## Game time, not the wall clock: fast runs (autopilot, --fixed-fps) keep the same rhythm.
var _answer_guard_left := 0.0
var _held := 0.0
var _hold_step := 0.0

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
	# A click moves the text on like confirm. The label would swallow it, so it lets it pass
	# to the panel.
	_text.mouse_filter = Control.MOUSE_FILTER_PASS
	_panel.gui_input.connect(_on_panel_input)
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
	opened.emit()
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
	if Settings.get_bool("display.reduce_flashing"):
		line.text = without_motion_tags(line.text)
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
		_answer_guard_left = ANSWER_GUARD_SECONDS
		_responses.show()
		var items := _responses.get_menu_items()
		if not items.is_empty():
			(items[0] as Control).grab_focus()
			# The addon reports focus changes only; the first answer is focused already
			# (a visible list grabs it), so the cursor is told by hand.
			_on_response_focused(items[0])
		_quiet_focus = false
	else:
		_waiting = true
		_continue.show()
		if Settings.get_bool("text.auto_advance"):
			_auto_advance(next_line)


## The text without the effect tags that move or flash letters ([wave], [rainbow], [shake]
## ...), for the setting "Weniger Flackern". Inline pauses stay: they are no tags of letters.
static func without_motion_tags(text: String) -> String:
	if _motion_regex == null:
		_motion_regex = RegEx.create_from_string("\\[/?(?:%s)(?:[ =][^\\]]*)?\\]" % MOTION_TAGS)
	return _motion_regex.sub(text, "", true)


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
	var real := WorldState.ui_mode() == GameState.UiMode.REAL
	AudioDirector.voice(_voice, VOICE_DB_REAL if real else VOICE_DB_ELYSIA)
	if not line.character.is_empty():
		syllable.emit(line.character)


func _auto_advance(for_line: DialogueLine) -> void:
	var seconds := AUTO_BASE_SECONDS + AUTO_SECONDS_PER_CHAR * for_line.text.length()
	await NodeTimer.after(self, seconds * Settings.timing_factor())
	if _open and _waiting and line == for_line:
		_advance()


func _process(delta: float) -> void:
	_answer_guard_left = maxf(_answer_guard_left - delta, 0.0)
	if not _open or not Input.is_action_pressed(&"interact"):
		_held = 0.0
		_hold_step = 0.0
		return
	_held += delta
	if _held < HOLD_TO_SKIP or _responses.visible:
		return
	_hold_step -= delta
	if _hold_step > 0.0:
		return
	_hold_step = HOLD_STEP
	if _text.is_typing:
		_text.skip_typing()
	elif _waiting:
		_advance()


## Swallows presses right after the answers appeared (before the answer list sees them). Later
## the answer list confirms with `interact` alone (its next_action), so a press that is only
## ui_accept (Enter, or Space once interact has moved to other keys) picks the focused answer here.
func _input(event: InputEvent) -> void:
	if not _open or not _responses.visible:
		return
	var accepted := event.is_action_pressed(&"ui_accept")
	if not (accepted or event.is_action_pressed(&"interact")):
		return
	if _answer_guard_left > 0.0:
		get_viewport().set_input_as_handled()
	elif accepted and not event.is_action_pressed(&"interact"):
		_pick_focused_answer()
		get_viewport().set_input_as_handled()


func _pick_focused_answer() -> void:
	var focused := get_viewport().gui_get_focus_owner()
	if focused == null or not focused.has_meta(&"response") or focused.is_queued_for_deletion():
		return
	if not _responses.get_menu_items().has(focused):
		return
	_on_response_selected(focused.get_meta(&"response") as DialogueResponse)


func _unhandled_input(event: InputEvent) -> void:
	if not _open:
		return
	# back (B, Backspace by default) also moves the text on, but never picks an answer; Esc stays the
	# pause menu's
	var back := event.is_action_pressed(&"cancel") and not event.is_action_pressed(&"menu")
	if back and _responses.visible:
		return
	var accept := event.is_action_pressed(&"interact") or event.is_action_pressed(&"ui_accept")
	if not (accept or back):
		return
	get_viewport().set_input_as_handled()
	_confirm_text()


## A left click on the box moves the text on like confirm (never while answers are shown:
## those take their own clicks).
func _on_panel_input(event: InputEvent) -> void:
	if not _open or _responses.visible:
		return
	var click := event as InputEventMouseButton
	if click == null or not click.pressed or click.button_index != MOUSE_BUTTON_LEFT:
		return
	_panel.accept_event()
	_confirm_text()


func _confirm_text() -> void:
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
