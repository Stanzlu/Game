class_name ScrollPage
extends MenuLayer
## A menu page that is mostly text (Mitwirkende, Steuerung): the only row that can take the
## focus is "Zurück" at the end, so the focus must not drag the page down, and up/down and
## the right stick scroll it instead. Matters with large letters, when the page outgrows
## the screen.

const SCROLL_STEP := 40.0

var _scroll: ScrollContainer


func _ready() -> void:
	super()
	_scroll = list.get_parent() as ScrollContainer
	_scroll.follow_focus = false


## Back to the top whenever the rows are built again.
func scroll_to_top() -> void:
	_scroll.scroll_vertical = 0


func _input(event: InputEvent) -> void:
	if not visible:
		return
	var step := 0.0
	if event.is_action_pressed(&"ui_down") or event.is_action_pressed(&"scroll_down"):
		step = SCROLL_STEP
	elif event.is_action_pressed(&"ui_up") or event.is_action_pressed(&"scroll_up"):
		step = -SCROLL_STEP
	if step == 0.0:
		return
	get_viewport().set_input_as_handled()
	_scroll.scroll_vertical = maxi(0, _scroll.scroll_vertical + int(step))
