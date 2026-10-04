class_name TitleCard
extends CanvasLayer
## The last beat of the vertical slice (Game Bible §56): "Schwarz. Titel." The screen goes
## black, the music stops, REAL fades in, stays and fades out; then `finished`. Accept or
## cancel skips once the title is visible.

signal finished

const LOGO := preload("res://assets/generated/title/logo_real.png")
const SCREEN := Vector2(640, 360)

var logo: TextureRect
var _tween: Tween
var _done := false


## Adds a title card on top of everything below `parent` and starts it.
static func play(parent: Node) -> TitleCard:
	var card := TitleCard.new()
	card.name = "TitleCard"
	parent.add_child(card)
	return card


func _ready() -> void:
	layer = 120
	process_mode = Node.PROCESS_MODE_ALWAYS
	var black := ColorRect.new()
	black.color = Color.BLACK
	black.set_anchors_preset(Control.PRESET_FULL_RECT)
	black.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(black)
	logo = TextureRect.new()
	logo.texture = LOGO
	logo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	logo.position = ((SCREEN - LOGO.get_size()) * 0.5).round()
	logo.modulate.a = 0.0
	add_child(logo)
	AudioDirector.play_music("silence", 1.5)
	AudioDirector.set_ambience(null, -80.0, 1.5)
	_tween = create_tween()
	_tween.tween_interval(1.5)
	_tween.tween_property(logo, ^"modulate:a", 1.0, 2.5)
	_tween.tween_interval(4.0)
	_tween.tween_property(logo, ^"modulate:a", 0.0, 2.0)
	_tween.tween_interval(0.8)
	_tween.finished.connect(_finish)
	Log.info(Log.Category.BOOT, "title card")


func _unhandled_input(event: InputEvent) -> void:
	if logo.modulate.a < 0.5:
		return
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("cancel"):
		get_viewport().set_input_as_handled()
		_finish()


func _finish() -> void:
	if _done:
		return
	_done = true
	if _tween != null:
		_tween.kill()
	finished.emit()
	queue_free()
