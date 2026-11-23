class_name VoiceLine
extends Label
## A voice without a body (Act VI, R4, docs/akt6/REGIONSBRIEFE.md, O9): one line typed over the
## picture, in the HUD layer, and not in a dialogue box. Nothing stops for it: she may walk on, and
## when she has gone `cut_distance` pixels away from where she stood as it began, the line breaks
## off in the middle of a word ("she is faster than he is"). Whoever stands still reads it to the
## end. A line with no `cut_distance` is read out and fades.
##
## Typed in play time (a physics step each), never the wall clock, and always at a voice's own pace:
## the text speed of the dialogue box (also "instant") does not apply, because the pace is what
## the break-off is made of. "More time" (access.timing) types it faster, so more of it is read
## before she is out of range; nothing here is a window she can miss something in that matters.

## Emitted when the line is over: `cut` is true when it broke off.
signal finished(cut: bool)

## Seconds per typed character at the normal pace: slower than the dialogue box, a voice speaks.
const CHAR_SECONDS := 0.035
const CUT_MARK := " –"
const HOLD_SECONDS := 2.4
const CUT_HOLD_SECONDS := 1.4
const FADE_SECONDS := 0.6
const WIDTH := 440.0
const TOP := 44.0

var cut_distance := 0.0
var _who: Node2D
var _origin := Vector2.ZERO
var _speaker := ""
var _text := ""
var _typed := 0.0
var _clock := 0.0
var _cut := false
var _done := false


## Speaks `text` as `speaker` over the HUD of `scene`; `who` is the one who may walk away from it.
static func speak(
	scene: GameScene, who: Node2D, speaker: String, text: String, distance := 0.0
) -> VoiceLine:
	var line := VoiceLine.new()
	line.name = "VoiceLine"
	line._who = who
	line._origin = who.global_position
	line.cut_distance = distance
	line._speaker = speaker
	line._text = text
	scene.hud.add_child(line)
	return line


func is_done() -> bool:
	return _done


## True when the line broke off because she had gone too far from where she stood.
func was_cut() -> bool:
	return _cut


## How much of the text is shown so far (the speaker's name not counted).
func typed_characters() -> int:
	return mini(int(_typed), _text.length())


func _ready() -> void:
	horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	offset_left = -WIDTH / 2.0
	offset_right = WIDTH / 2.0
	offset_top = TOP
	grow_vertical = Control.GROW_DIRECTION_END
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_theme_color_override(&"font_color", Color(0.9, 0.88, 0.84))
	add_theme_color_override(&"font_outline_color", Color(0.05, 0.04, 0.03, 0.7))
	add_theme_constant_override(&"outline_size", 2)
	_show()


func _physics_process(delta: float) -> void:
	_clock += delta
	if _done:
		_fade()
		return
	if not _cut and cut_distance > 0.0 and _is_away():
		_cut = true
		_clock = 0.0
		_done = true
		_show()
		finished.emit(true)
		return
	_typed += delta / (CHAR_SECONDS / Settings.timing_factor())
	_show()
	if typed_characters() >= _text.length():
		_clock = 0.0
		_done = true
		finished.emit(false)


func _is_away() -> bool:
	return is_instance_valid(_who) and _who.global_position.distance_to(_origin) > cut_distance


func _show() -> void:
	var shown := _text.substr(0, typed_characters())
	if _cut:
		shown = shown.strip_edges(false, true) + CUT_MARK
	text = tr(_speaker, &"dialogue") + "\n" + shown if _speaker != "" else shown


## Holds for a while, then lets go and frees itself.
func _fade() -> void:
	var hold := CUT_HOLD_SECONDS if _cut else HOLD_SECONDS
	if _clock > hold:
		modulate.a = clampf(1.0 - (_clock - hold) / FADE_SECONDS, 0.0, 1.0)
	if _clock > hold + FADE_SECONDS:
		queue_free()
