class_name NameEntry
extends MenuLayer
## "Neues Spiel": Elysia's character creation asks for the hero's name (Game Bible §6: the
## player chooses the name). Typing works with the keyboard; with a controller one of the
## suggested names is picked. Emits `chosen` with the cleaned name.
## The house uses it to name the cat (Game Bible §28): set `title_key` and `suggestions`
## before adding it to the tree.

signal chosen(hero_name: String)

## Suggested names (locale keys, so they can be changed with the other texts).
const SUGGESTIONS: PackedStringArray = [
	"NAME_SUGGESTION_1", "NAME_SUGGESTION_2", "NAME_SUGGESTION_3", "NAME_SUGGESTION_4"
]
const ALLOWED := "abcdefghijklmnopqrstuvwxyzäöüßéèáàâêîôûçñ -'"

var field: LineEdit
var suggestions: PackedStringArray = SUGGESTIONS


func _ready() -> void:
	if title_key.is_empty():
		title_key = "NAME_TITLE"
	panel_width = 220
	super()


func _build() -> void:
	field = LineEdit.new()
	field.max_length = GameState.MAX_NAME_LENGTH
	field.placeholder_text = tr(suggestions[0])
	field.alignment = HORIZONTAL_ALIGNMENT_CENTER
	field.custom_minimum_size = Vector2(160, 0)
	field.context_menu_enabled = false
	field.text_submitted.connect(func(_text: String) -> void: _confirm())
	list.add_custom(field)
	list.add_header("NAME_SUGGESTIONS")
	for key in suggestions:
		var suggestion := tr(key)
		list.add_action("", func() -> void: field.text = suggestion, true, suggestion)
	list.add_action("NAME_CONFIRM", _confirm)
	list.add_action("MENU_BACK", close)
	hint.text = tr("NAME_HINT")


func open() -> void:
	super()
	field.grab_focus.call_deferred()
	var buttons := list.buttons()
	if not buttons.is_empty():
		field.focus_neighbor_bottom = field.get_path_to(buttons[0])
		buttons[0].focus_neighbor_top = buttons[0].get_path_to(field)


## Letters, spaces, hyphen and apostrophe; trimmed and at most MAX_NAME_LENGTH long.
static func clean(raw: String) -> String:
	var out := ""
	for ch in raw.strip_edges():
		if ALLOWED.contains(ch.to_lower()):
			out += ch
	return out.strip_edges().left(GameState.MAX_NAME_LENGTH)


func _confirm() -> void:
	var hero_name := clean(field.text)
	if hero_name.is_empty():
		hero_name = tr(suggestions[0])
	close()
	chosen.emit(hero_name)
