class_name InteractionPrompt
extends Node2D
## Small hint above the current interaction target (inside the world): a key cap with the
## button of the current device and the verb ("E  Öffnen"). Pops in, bobs gently, follows
## the skins (Elysia gold, Real quiet).

const FADE_IN_SECONDS := 0.12
const FADE_OUT_SECONDS := 0.08

var _panel: PanelContainer
var _key: Label
var _verb: Label
var _target: Interactable
var _shown_for: Interactable
var _time := 0.0
var _tween: Tween
var _fading := false


func _ready() -> void:
	top_level = true
	physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF
	z_index = 50
	_panel = PanelContainer.new()
	_panel.theme_type_variation = &"PromptPanel"
	add_child(_panel)
	UiSkin.attach(_panel)
	var row := HBoxContainer.new()
	row.add_theme_constant_override(&"separation", 3)
	_panel.add_child(row)
	var cap := PanelContainer.new()
	cap.theme_type_variation = &"PromptKey"
	row.add_child(cap)
	_key = Label.new()
	_key.theme_type_variation = &"PromptKeyLabel"
	_key.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	cap.add_child(_key)
	_verb = Label.new()
	_verb.theme_type_variation = &"PromptText"
	row.add_child(_verb)
	visible = false
	InputDevice.device_changed.connect(func(_kind: int) -> void: _refresh())


func show_for(target: Interactable) -> void:
	_target = target
	_refresh()


func _refresh() -> void:
	if _tween != null and _tween.is_valid():
		_tween.kill()
	if _target == null or not is_instance_valid(_target):
		_shown_for = null
		if visible and not _fading:
			# fade out where it stood instead of vanishing
			_fading = true
			_tween = _panel.create_tween()
			_tween.tween_property(_panel, ^"modulate:a", 0.0, FADE_OUT_SECONDS)
			_tween.tween_callback(_hide_now)
		return
	_fading = false
	visible = true
	_key.text = InputDevice.label_for(&"interact")
	_verb.text = tr(_target.prompt_key)
	_panel.reset_size()
	if _shown_for != _target:
		_shown_for = _target
		_panel.modulate.a = 0.0
		_tween = _panel.create_tween()
		_tween.tween_property(_panel, ^"modulate:a", 1.0, FADE_IN_SECONDS)
	else:
		_panel.modulate.a = 1.0


func _hide_now() -> void:
	_fading = false
	visible = false


func _process(delta: float) -> void:
	if _fading:
		return
	if visible and (not is_instance_valid(_target) or not _target.can_interact(null)):
		# the target was taken, opened or freed (e.g. a picked-up stone)
		_target = null
		_shown_for = null
		visible = false
		return
	if visible:
		_time += delta
		var anchor := _target.global_position + _target.prompt_offset
		global_position = anchor.round()
		var bob := float(int(_time * 2.0) % 2)
		_panel.position = Vector2(-roundf(_panel.size.x * 0.5), -_panel.size.y - bob)
