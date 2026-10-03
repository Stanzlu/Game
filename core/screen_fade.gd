class_name ScreenFadeService
extends CanvasLayer
## Autoload "ScreenFade": a black cover over everything that survives scene changes, so a
## sequence can fade out in one scene and the next scene fades in from the same black.
## Game scenes fade in on their own when they start covered.
## Await the returned signal: it also fires when a newer fade replaces this one, so a
## waiting sequence never hangs.

signal faded

var _cover: ColorRect
var _tween: Tween


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
		faded.emit()
	if seconds <= 0.0:
		# at once, so is_covered() is true right away
		_cover.color = target
		faded.emit.call_deferred()
		return faded
	_tween = create_tween()
	_tween.tween_property(_cover, ^"color", target, seconds)
	_tween.tween_callback(faded.emit)
	return faded
