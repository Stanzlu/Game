class_name MenuLayer
extends CanvasLayer
## Base for full-screen menus over the game: the game blurred and dimmed behind a centred
## panel with title, a scrolling OptionList and a hint line. Works while the tree is paused.
## `cancel` closes the menu (and returns focus to whoever opened it). Subclasses fill the
## list in _build(). The panel follows the skin of the current world unless `follow_mode`
## is off (start menu); `compact` uses the small font (developer panels).

signal opened
signal closed

const GROUP := &"menu_layer"
const BACKDROP_SHADER := preload("res://ui/theme/menu_backdrop.gdshader")
const COMPACT_THEME := preload("res://ui/theme/compact_theme.tres")
const OPEN_SECONDS := 0.16

@export var title_key := ""
@export var panel_width := 240
@export var follow_mode := true
@export var compact := false
## Menu sounds when the panel does not follow the world (start menu); FOLLOW means Real.
var sound_set := AudioDirectorService.SoundSet.FOLLOW

var list: OptionList
var body: HBoxContainer
var title: Label
var hint: Label
var frame: Control
var backdrop: ColorRect
var _return_focus: Control
var _open_tween: Tween


## True while any menu, dialogue or cutscene is open (then pause menu and journal stay closed).
static func any_open(tree: SceneTree) -> bool:
	for group: StringName in [GROUP, &"dialogue_presenter", &"cutscene"]:
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
	backdrop = ColorRect.new()
	backdrop.name = "Backdrop"
	backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var material := ShaderMaterial.new()
	material.shader = BACKDROP_SHADER
	backdrop.material = material
	add_child(backdrop)
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	frame = center
	if follow_mode:
		UiSkin.attach(center)
	var panel := PanelContainer.new()
	panel.theme_type_variation = &"MenuPanel"
	panel.custom_minimum_size = Vector2(panel_width, 0)
	if compact:
		panel.theme = COMPACT_THEME
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
	list.add_theme_constant_override(&"separation", 0 if compact else 1)
	if not follow_mode:
		list.sound_skin = (
			sound_set
			if sound_set != AudioDirectorService.SoundSet.FOLLOW
			else AudioDirectorService.SoundSet.REAL
		)
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(list)
	hint = Label.new()
	hint.theme_type_variation = &"HintLabel"
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
	backdrop.show()
	show()
	list.focus_first()
	_animate_open()
	AudioDirector.ui("open", list.sound_skin)
	opened.emit()
	Log.info(Log.Category.UI, "menu open", {"menu": str(name)})


## The panel rises a few pixels and fades in; the backdrop blurs in. Real is calmer.
func _animate_open() -> void:
	var elysia := follow_mode and WorldState.ui_mode() == GameState.UiMode.ELYSIA
	var material := backdrop.material as ShaderMaterial
	material.set_shader_parameter(&"desaturate", 0.15 if elysia else 0.6)
	material.set_shader_parameter(&"darken", 0.3 if elysia else 0.5)
	material.set_shader_parameter(
		&"tint", Color(0.28, 0.12, 0.4, 0.22) if elysia else Color(0.03, 0.035, 0.04, 0.3)
	)
	if _open_tween != null and _open_tween.is_valid():
		_open_tween.kill()
	frame.modulate.a = 0.0
	frame.position.y = 6.0
	material.set_shader_parameter(&"amount", 0.0)
	_open_tween = create_tween().set_parallel()
	_open_tween.tween_property(frame, ^"modulate:a", 1.0, OPEN_SECONDS)
	(
		_open_tween
		. tween_property(frame, ^"position:y", 0.0, OPEN_SECONDS)
		. set_trans(Tween.TRANS_QUAD)
		. set_ease(Tween.EASE_OUT)
	)
	_open_tween.tween_method(
		func(v: float) -> void: material.set_shader_parameter(&"amount", v),
		0.0,
		1.0,
		OPEN_SECONDS * 1.5
	)


func close() -> void:
	if not visible:
		return
	if _open_tween != null and _open_tween.is_valid():
		_open_tween.kill()
	frame.modulate.a = 1.0
	frame.position.y = 0.0
	hide()
	AudioDirector.ui("close", list.sound_skin)
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
	list.focus_index.call_deferred(index)


## Hides this menu's panel (and backdrop, the child brings its own) while `child` is open.
func stack(child: MenuLayer) -> void:
	child.opened.connect(
		func() -> void:
			frame.hide()
			backdrop.hide()
	)
	child.closed.connect(
		func() -> void:
			frame.show()
			backdrop.show()
	)


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
