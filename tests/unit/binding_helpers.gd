extends RefCounted
## Shared by the tests of the key layout: encoded events by name and the invariant checker
## that every edit sequence and every loaded file has to satisfy.

const KEYBOARD := InputBindings.Device.KEYBOARD
const GAMEPAD := InputBindings.Device.GAMEPAD


static func key(code: int) -> Dictionary:
	return {"type": "key", "physical_keycode": code}


static func button(index: int) -> Dictionary:
	return {"type": "joy_button", "button": index}


static func axis(index: int, value: float) -> Dictionary:
	return {"type": "joy_axis", "axis": index, "value": value}


## "k69" strings of an event list, for readable comparisons.
static func ids(list: Array[Dictionary]) -> Array[String]:
	var out: Array[String] = []
	for data in list:
		out.append(BindingCodec.event_id(data))
	return out


static func key_ids(codes: Array) -> Array[String]:
	var out: Array[String] = []
	for code: int in codes:
		out.append("k%d" % code)
	return out


static func slot_ids(model: InputBindings, action: StringName, device: int) -> Array[String]:
	return ids(model.slots(action, device as InputBindings.Device))


static func effective_ids(model: InputBindings, action: StringName, device: int) -> Array[String]:
	return ids(model.effective(action, device as InputBindings.Device))


## The whole layout as one string per (action, device), to compare two models.
static func layout(model: InputBindings) -> Dictionary:
	var out := {}
	for action in InputBindings.ACTIONS:
		for device: int in InputBindings.Device.values():
			out["%s:%d" % [action, device]] = effective_ids(model, action, device)
	return out


## Every rule that must hold whatever was done to the model; empty when all hold.
static func violations(model: InputBindings) -> PackedStringArray:
	var found := PackedStringArray()
	var owner_of := {}
	for device: int in InputBindings.Device.values():
		owner_of[device] = {}
	for action in InputBindings.ACTIONS:
		for device: int in InputBindings.Device.values():
			found.append_array(_pair_violations(model, action, device, owner_of[device]))
	return found


static func _pair_violations(
	model: InputBindings, action: StringName, device: int, owner_of: Dictionary
) -> PackedStringArray:
	var found := PackedStringArray()
	var where := "%s/%d" % [action, device]
	var kind := device as InputBindings.Device
	var slots := model.slots(action, kind)
	var effective := model.effective(action, kind)
	if effective.is_empty():
		found.append(where + ": no binding left")
	if slots.size() > InputBindings.SLOTS:
		found.append(where + ": more than %d slots" % InputBindings.SLOTS)
	if not model.is_editable(action, kind) and not slots.is_empty():
		found.append(where + ": slots on a device that cannot be edited")
	var seen := {}
	for data in effective:
		var id := BindingCodec.event_id(data)
		if BindingCodec.normalize(data) != data or BindingCodec.device_of(data) != device:
			found.append(where + ": %s is not a clean event of the device" % id)
		if seen.has(id):
			found.append(where + ": %s twice" % id)
		seen[id] = true
		var shared_esc: bool = id == "k%d" % KEY_ESCAPE and ["cancel", "menu"].has(str(action))
		if owner_of.has(id) and not shared_esc:
			found.append(where + ": %s also belongs to %s" % [id, owner_of[id]])
		owner_of[id] = action
	for data in slots:
		found.append_array(_rule_violations(action, data, where))
	return found


## A slot event must be one the action may hold (independent of the model's own checks).
static func _rule_violations(
	action: StringName, data: Dictionary, where: String
) -> PackedStringArray:
	var found := PackedStringArray()
	var id := BindingCodec.event_id(data)
	var rule := InputBindings.reservation(data)
	if rule.has("blocked"):
		found.append(where + ": %s can never be bound" % id)
	elif not rule.is_empty() and not (rule["owners"] as Array).has(action):
		found.append(where + ": %s is reserved" % id)
	if str(data["type"]) == "joy_axis":
		var trigger := BindingCodec.is_trigger(int(data["axis"]))
		if not trigger or action != &"sprint":
			found.append(where + ": %s is not allowed on an action" % id)
	return found
