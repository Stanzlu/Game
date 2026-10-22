class_name ScreenFadeService
extends CanvasLayer
## Autoload "ScreenFade": a black cover over everything that survives scene changes, so a
## sequence can fade out in one scene and the next scene fades in from the same black.
## Game scenes fade in on their own when they start covered.
## Await the returned signal: it also fires when a newer fade replaces this one, so a
## waiting sequence never hangs. Each fade has its own signal, so the end of one never
## releases whoever waits for the next.


## Fires once for the fade that created it.
class Ticket:
	extends RefCounted
	signal done


var _cover: ColorRect
var _tween: Tween
var _ticket: Ticket
## Alpha the running fade heads for.
var _target_alpha := 0.0


func _ready() -> void:
	layer = 90
	process_mode = Node.PROCESS_MODE_ALWAYS
	_cover = ColorRect.new()
	_cover.color = Color(0, 0, 0, 0)
	_cover.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_cover.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_cover)


func is_covered() -> bool:
	return _cover.color.a > 0.5


func fade_out(seconds := 1.0, color := Color.BLACK) -> Signal:
	return _fade(Color(color, 1.0), seconds)


func fade_in(seconds := 1.0) -> Signal:
	return _fade(Color(_cover.color, 0.0), seconds)


func _fade(target: Color, seconds: float) -> Signal:
	if _tween != null and _tween.is_valid():
		_tween.kill()
	_release()
	var ticket := Ticket.new()
	_ticket = ticket
	_target_alpha = target.a
	if seconds <= 0.0:
		# at once, so is_covered() is true right away; the signal still comes after the
		# caller started waiting for it
		_cover.color = target
		_release.call_deferred(ticket)
		return ticket.done
	_tween = create_tween()
	# into black it gathers pace, out of black it settles: softer than a linear ramp
	var ease := Tween.EASE_IN if target.a > _cover.color.a else Tween.EASE_OUT
	_tween.tween_property(_cover, ^"color", target, seconds).set_trans(Tween.TRANS_SINE).set_ease(
		ease
	)
	_tween.tween_callback(_release.bind(ticket))
	return ticket.done


## Lets the waiters of `ticket` (default: the running fade) go on, once.
func _release(ticket: Ticket = null) -> void:
	if ticket == null:
		ticket = _ticket
	if ticket == null:
		return
	if ticket == _ticket:
		_ticket = null
	ticket.done.emit()


## True while a fade is running (menus stay closed until the picture is back).
func is_fading() -> bool:
	return _tween != null and _tween.is_valid() and _tween.is_running()


## True while the picture comes back (a fade towards clear). Menus may open then: the player
## pressing Esc in the first seconds of a scene is not waiting for a black screen.
func is_fading_in() -> bool:
	return is_fading() and _target_alpha <= 0.0
