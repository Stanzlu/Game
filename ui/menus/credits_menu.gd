class_name CreditsMenu
extends ScrollPage
## "Mitwirkende": who made the game and which licences it carries (the fonts' OFL asks for
## the notice to travel with the game). The text is CREDITS_TEXT, one line per row. Elysia's
## title calls the page "Die Helden hinter dem Helden". No end credits in the game itself:
## the slice ends on black and the title (Game Bible §56).

## Set before adding the menu to the tree.
var elysia := false


func _ready() -> void:
	title_key = "MENU_CREDITS_ELYSIA" if elysia else "MENU_CREDITS"
	panel_width = 380
	layer = 50
	super()


func _build() -> void:
	for line in tr("CREDITS_TEXT").split("\n"):
		if line.strip_edges().is_empty():
			var gap := Control.new()
			gap.custom_minimum_size.y = 8
			list.add_custom(gap)
		else:
			list.add_info(line)
	list.add_action("MENU_BACK", close)
	scroll_to_top()
