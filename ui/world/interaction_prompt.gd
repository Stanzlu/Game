class_name InteractionPrompt
extends Node2D
## Small "[E] Lesen" label above the current interaction target (inside the world).

var _label: Label
var _target: Interactable


func _ready() -> void:
	top_level = true
	physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF
	z_index = 50
	_label = Label.new()
	_label.theme_type_variation = &"PromptLabel"
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(_label)
	visible = false
	InputDevice.device_changed.connect(func(_kind: int) -> void: _refresh())


func show_for(target: Interactable) -> void:
	_target = target
	_refresh()


func _refresh() -> void:
	visible = _target != null and is_instance_valid(_target)
	if not visible:
		return
	_label.text = "[%s] %s" % [InputDevice.label_for(&"interact"), tr(_target.prompt_key)]
	_label.reset_size()


func _process(_delta: float) -> void:
	if visible and is_instance_valid(_target):
		var anchor := _target.global_position + _target.prompt_offset
		global_position = anchor.round()
		_label.position = Vector2(-roundf(_label.size.x * 0.5), -_label.size.y)
