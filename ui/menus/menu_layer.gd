class_name MenuLayer
extends CanvasLayer
## Base for full-screen menus over the game: dimmed background, centred panel with title,
## a scrolling OptionList and a hint line. Works while the tree is paused. `cancel` closes
## the menu (and returns focus to whoever opened it). Subclasses fill the list in _build().

signal opened
signal closed

const GROUP := &"menu_layer"

@export var title_key := ""
@export var panel_width := 240

var list: OptionList
var body: HBoxContainer
var title: Label
var hint: Label
var frame: Control
var _return_focus: Control


## True while any menu or dialogue is open (then pause menu and journal stay closed).
static func any_open(tree: SceneTree) -> bool:
	for group: StringName in [GROUP, &"dialogue_presenter"]:
		for node in tree.get_nodes_in_group(group):
			if node.has_method(&"is_open") and bool(node.call(&"is_open")):
				return true
	return false


func _ready() -> void:
	add_to_group(GROUP)
	process_mode = Node.PROCESS_MODE_ALWAYS
	if layer == 1:
		layer = 45
	_build_frame()
	hide()


func _build_frame() -> void:
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.6)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(dim)
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	frame = center
	var panel := PanelContainer.new()
	panel.theme_type_variation = &"MenuPanel"
	panel.custom_minimum_size = Vector2(panel_width, 0)
	center.add_child(panel)
	var rows := VBoxContainer.new()
	rows.add_theme_constant_override(&"separation", 6)
	panel.add_child(rows)
	title = Label.new()
	title.theme_type_variation = &"SubtitleLabel"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.text = title_key
	rows.add_child(title)
	body = HBoxContainer.new()
	body.add_theme_constant_override(&"separation", 10)
	rows.add_child(body)
	var scroll := ScrollContainer.new()
	scroll.follow_focus = true
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.custom_minimum_size = Vector2(panel_width - 16, 0)
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_child(scroll)
	list = OptionList.new()
	list.add_theme_constant_override(&"separation", 2)
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(list)
	hint = Label.new()
	hint.theme_type_variation = &"MutedLabel"
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hint.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	rows.add_child(hint)


func is_open() -> bool:
	return visible


func open() -> void:
	var owner_focus := get_viewport().gui_get_focus_owner()
	_return_focus = owner_focus if owner_focus != null else _return_focus
	list.clear_rows()
	_build()
	list.refresh()
	_fit_height()
	frame.show()
	show()
	list.focus_first()
	opened.emit()
	Log.info(Log.Category.UI, "menu open", {"menu": str(name)})


func close() -> void:
	if not visible:
		return
	hide()
	# The key that confirmed the last row must not also trigger the world when the game resumes.
	Input.action_release(&"interact")
	# Listeners first: a parent menu shows its panel again, then it can take the focus back.
	closed.emit()
	if (
		_return_focus != null
		and is_instance_valid(_return_focus)
		and _return_focus.is_visible_in_tree()
	):
		_return_focus.grab_focus()


## Rebuilds the rows and keeps the focused row (after values or slots changed).
func rebuild() -> void:
	var focused := get_viewport().gui_get_focus_owner()
	var index := list.buttons().find(focused)
	list.clear_rows()
	_build()
	list.refresh()
	var buttons := list.buttons()
	if not buttons.is_empty():
		buttons[clampi(index, 0, buttons.size() - 1)].grab_focus.call_deferred()


## Hides this menu's panel while `child` is open on top of it.
func stack(child: MenuLayer) -> void:
	child.opened.connect(func() -> void: frame.hide())
	child.closed.connect(func() -> void: frame.show())


## Subclasses add their rows here.
func _build() -> void:
	pass


func _fit_height() -> void:
	var scroll := list.get_parent() as ScrollContainer
	var viewport_height := get_viewport().get_visible_rect().size.y
	scroll.custom_minimum_size.y = minf(list.get_combined_minimum_size().y, viewport_height - 120)


func _unhandled_input(event: InputEvent) -> void:
	if visible and (event.is_action_pressed(&"cancel") or event.is_action_pressed(&"menu")):
		get_viewport().set_input_as_handled()
		_on_cancel()


func _on_cancel() -> void:
	close()
