class_name CreditsMenu
extends MenuLayer
## "Mitwirkende": who made the game and which licences it carries (the fonts' OFL asks for
## the notice to travel with the game). The text is CREDITS_TEXT, one line per row. Elysia's
## title calls the page "Die Helden hinter dem Helden". No end credits in the game itself:
## the slice ends on black and the title (Game Bible §56).

const SCROLL_STEP := 40.0

## Set before adding the menu to the tree.
var elysia := false
var _scroll: ScrollContainer


func _ready() -> void:
	title_key = "MENU_CREDITS_ELYSIA" if elysia else "MENU_CREDITS"
	panel_width = 380
	layer = 50
	super()
	# the only row that can be focused is "Zurück" at the end: it must not drag the page down
	_scroll = list.get_parent() as ScrollContainer
	_scroll.follow_focus = false


func _build() -> void:
	for line in tr("CREDITS_TEXT").split("\n"):
		if line.strip_edges().is_empty():
			var gap := Control.new()
			gap.custom_minimum_size.y = 8
			list.add_custom(gap)
		else:
			list.add_info(line)
	list.add_action("MENU_BACK", close)
	_scroll.scroll_vertical = 0


## Long text (large letters) scrolls with up/down and the right stick; nothing else on the
## page can take the keys.
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
