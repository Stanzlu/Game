class_name InputBindings
extends RefCounted
## The key and button layout of the nine rebindable actions (ADR-048, Game Bible §50): the
## rules, the editable slots and the sync into the InputMap. No scene needed.
##
## Every action has, per device, FIXED events and up to SLOTS editable ones. Fixed events are
## the lock-out guards (Esc, Enter, pad Start and A, the stick and D-pad of the walk) and can
## neither be removed nor given away. Defaults come from project.godot (never from the live
## InputMap, which may be changed). Only OVERRIDES are held: a (action, device) pair whose
## slots equal the defaults is not an override. Rules that always hold, whatever is edited:
## every action keeps at least one binding per device; no event belongs to two actions of one
## device (except the fixed Esc on cancel and menu); every slot event is allowed for its action.
## User mistakes are never errors: edits answer with a Result, nothing is logged for a refusal.

## The InputMap already holds the new events when this is emitted (once per edit, with every
## action whose events really changed). Never emitted by load_data or apply.
signal changed(actions: PackedStringArray)

enum Device { KEYBOARD, GAMEPAD }
## What check() found out. Values of Device equal InputDevice.Kind (a test pins it).
enum Code {
	OK,
	UNCHANGED,
	UNKNOWN_ACTION,
	NOT_EDITABLE,
	BAD_SLOT,
	INVALID_EVENT,
	WRONG_DEVICE,
	STICK,
	TRIGGER,
	RESERVED,
	SAME_ACTION,
	CONFLICT,
	LAST_BINDING,
}
## How bind() settles a CONFLICT: leave it, swap the two keys or take the key away.
enum Resolve { REFUSE, SWAP, TAKE }

## Page and file order.
const ACTIONS: Array[StringName] = [
	&"move_up",
	&"move_down",
	&"move_left",
	&"move_right",
	&"sprint",
	&"interact",
	&"cancel",
	&"menu",
	&"journal",
]
## Editable cells per action and device.
const SLOTS := 2
## Fixed events come first in the display order (and the InputMap) of these actions, so the
## label of "Zurück" stays Esc and the pause key stays Esc/Start. Everything else shows its
## own keys first (the interaction prompt keeps showing "E", not "Enter").
const FIXED_FIRST: Array[StringName] = [&"cancel", &"menu"]
## Default events that are fixed (everything else a default has is an editable slot).
const FIXED_KEYS := {
	&"interact": [KEY_ENTER, KEY_KP_ENTER],
	&"cancel": [KEY_ESCAPE],
	&"menu": [KEY_ESCAPE],
}
const FIXED_BUTTONS := {&"menu": [JOY_BUTTON_START], &"interact": [JOY_BUTTON_A]}
## The pad cannot be edited for walking: every default pad event of these is fixed.
const PAD_FIXED_ACTIONS: Array[StringName] = [&"move_up", &"move_down", &"move_left", &"move_right"]

## Keys nobody may hold: pinned (Esc, Enter), clear a cell (Delete), scroll (Page Up/Down) or
## developer keys (F3, F4).
const KEYS_FOR_NOBODY: Array[int] = [
	KEY_ESCAPE, KEY_ENTER, KEY_KP_ENTER, KEY_DELETE, KEY_PAGEUP, KEY_PAGEDOWN, KEY_F3, KEY_F4
]
## Arrows and WASD move the focus in every menu (ui_up/down/left/right): walking only.
const KEYS_FOR_WALKING: Array[int] = [
	KEY_UP, KEY_DOWN, KEY_LEFT, KEY_RIGHT, KEY_W, KEY_A, KEY_S, KEY_D
]
## Space confirms and Tab moves the focus. Sprint is only polled, so it may use both.
const SPACE_OWNERS: Array[StringName] = [&"interact", &"sprint"]
const TAB_OWNERS: Array[StringName] = [&"menu", &"sprint"]
## Buttons nobody may hold: A is pinned on interact, Start on menu, Y clears a cell, the
## D-pad walks and moves the focus.
const BUTTONS_FOR_NOBODY: Array[int] = [
	JOY_BUTTON_A,
	JOY_BUTTON_Y,
	JOY_BUTTON_START,
	JOY_BUTTON_DPAD_UP,
	JOY_BUTTON_DPAD_DOWN,
	JOY_BUTTON_DPAD_LEFT,
	JOY_BUTTON_DPAD_RIGHT,
]
## Keys that toggle, are taken by the operating system (Alt, Win/Cmd) or are media keys.
const KEYS_BLOCKED: Array[int] = [KEY_CAPSLOCK, KEY_NUMLOCK, KEY_SCROLLLOCK, KEY_ALT, KEY_META]
## Back, volume, media, browser, launch and standby keys up to the IME keys.
const BLOCKED_FIRST := KEY_BACK
const BLOCKED_LAST := KEY_JIS_KANA

## false: apply() leaves the InputMap alone (pure-model tests).
var live := true

var _defaults: Dictionary = {}
var _override: Dictionary = {}


## What check() and bind() found. `data` is the normalised event that was looked at.
class Result:
	extends RefCounted
	var code := Code.OK
	var data: Dictionary = {}
	## CONFLICT, SAME_ACTION: who holds the event; RESERVED: the first action that may.
	## After a swap or take that worked: the other action that was touched.
	var other := &""
	## Slot of the holder, -1 for a fixed event.
	var other_slot := -1
	## RESERVED: every action that may hold the event (empty: nobody).
	var owners: Array[StringName] = []
	var can_swap := false
	var can_take := false

	func ok() -> bool:
		return code == Code.OK or code == Code.UNCHANGED


func _init(live_map := true) -> void:
	live = live_map
	for action in ACTIONS:
		for device: int in Device.values():
			_defaults[_pair(action, device)] = {"fixed": [], "slots": []}
		var setting: Variant = ProjectSettings.get_setting("input/" + str(action), {})
		var events: Array = (
			(setting as Dictionary).get("events", []) if setting is Dictionary else []
		)
		for event: Variant in events:
			_add_default(action, event as InputEvent)


# --- Read (everything is a copy) ---------------------------------------------------------


## The editable events, compact, at most SLOTS.
func slots(action: StringName, device: Device) -> Array[Dictionary]:
	if not ACTIONS.has(action):
		return []
	var key := _pair(action, device)
	if _override.has(key):
		return _copy(_override[key])
	return default_slots(action, device)


## The pinned events in default order.
func fixed(action: StringName, device: Device) -> Array[Dictionary]:
	if not ACTIONS.has(action):
		return []
	return _copy((_defaults[_pair(action, device)] as Dictionary)["fixed"])


## What the InputMap gets for that device, in display order (see FIXED_FIRST).
func effective(action: StringName, device: Device) -> Array[Dictionary]:
	return _effective_of(action, device, slots(action, device))


func default_slots(action: StringName, device: Device) -> Array[Dictionary]:
	if not ACTIONS.has(action):
		return []
	return _copy((_defaults[_pair(action, device)] as Dictionary)["slots"])


## False for the walk on the pad (all fixed) and for unknown actions.
func is_editable(action: StringName, device: Device) -> bool:
	return ACTIONS.has(action) and not (device == Device.GAMEPAD and PAD_FIXED_ACTIONS.has(action))


## "" = any action, -1 = any device.
func is_overridden(action := &"", device := -1) -> bool:
	for target in _actions_in(action):
		for dev in _devices_in(device):
			if _override.has(_pair(target, dev)):
				return true
	return false


# --- Rules and edits ---------------------------------------------------------------------


## Read-only: what bind() would do. Order of the checks: unknown action, device not editable,
## bad slot, invalid event, wrong device, analog rules, reserved or blocked, unchanged or the
## same action, conflict. `slot == slots().size()` appends.
func check(action: StringName, device: Device, slot: int, data: Dictionary) -> Result:
	var result := _check_target(action, device, slot)
	if result.code != Code.OK:
		return result
	result = _check_event(action, device, data)
	if result.code != Code.OK:
		return result
	return _check_holders(action, device, slot, result.data)


## Sets the cell. Changes nothing unless the result is OK; `resolve` settles a CONFLICT
## (SWAP or TAKE act only when check() said can_swap / can_take, otherwise the CONFLICT or,
## for TAKE, LAST_BINDING comes back unchanged).
func bind(
	action: StringName, device: Device, slot: int, data: Dictionary, resolve := Resolve.REFUSE
) -> Result:
	var result := check(action, device, slot, data)
	if result.code == Code.CONFLICT:
		return _settle(result, action, device, slot, resolve)
	if result.code == Code.OK:
		var edited := slots(action, device)
		_put(edited, slot, result.data)
		var info := {"action": action, "device": device, "slot": slot}
		info["event"] = BindingCodec.event_id(result.data)
		_commit([[action, device, edited]], "binding set", info)
	return result


## Empties a cell; later cells move up. LAST_BINDING if the action would have nothing left.
func clear(action: StringName, device: Device, slot: int) -> Code:
	if not ACTIONS.has(action):
		return Code.UNKNOWN_ACTION
	if not is_editable(action, device):
		return Code.NOT_EDITABLE
	var edited := slots(action, device)
	if slot < 0 or slot >= edited.size():
		return Code.BAD_SLOT
	edited.remove_at(slot)
	if _effective_of(action, device, edited).is_empty():
		return Code.LAST_BINDING
	var info := {"action": action, "device": device, "slot": slot}
	_commit([[action, device, edited]], "binding cleared", info)
	return Code.OK


## Back to the defaults. "" = every action, -1 = both devices.
func reset(action := &"", device := -1) -> void:
	var touched := _actions_in(action)
	var before := _fingerprints(touched)
	for target in touched:
		for dev in _devices_in(device):
			_override.erase(_pair(target, dev))
	_announce(touched, before, "bindings reset", {"action": action, "device": device})


# --- Persistence and InputMap ------------------------------------------------------------


## {"<action>": [encoded events]} for every action that is overridden on any device. The
## effective events of BOTH devices are written (keyboard first, fixed ones included): a build
## that replaces a whole action from the file still finds the other device's buttons.
func to_data() -> Dictionary:
	var out := {}
	for action in ACTIONS:
		if not is_overridden(action):
			continue
		var list: Array[Dictionary] = []
		for device: int in Device.values():
			list.append_array(effective(action, device as Device))
		out[str(action)] = list
	return out


## Replaces the state from untrusted data (the "input" block of settings.json). Lenient: every
## piece that cannot be used is dropped and logged as a warning, never an error. A device is
## overridden if the action's list holds events of that device; a list that holds nothing usable
## for a device leaves its defaults; two actions that claim one key are repaired so that every
## rule holds. Returns the number of dropped or repaired pieces. No signal, no InputMap write.
func load_data(data: Variant) -> int:
	_override.clear()
	if data == null:
		return 0
	if not data is Dictionary:
		return _drop("input block is not a dictionary", {"type": type_string(typeof(data))})
	var dropped := 0
	for key: Variant in data as Dictionary:
		dropped += _load_action(key, (data as Dictionary)[key])
	return dropped + _repair_claims()


## Brings the InputMap in line with the model: only actions whose events differ are touched
## (a held Shift stays pressed while journal is rebound), changed ones are released. The
## deadzones stay. An action is never left without events in between.
func apply(only: PackedStringArray = []) -> void:
	if not live:
		return
	var names := only
	if names.is_empty():
		for action in ACTIONS:
			names.append(str(action))
	for each in names:
		_apply_action(StringName(each))


## {} = free, {"owners": [...]} = only these actions may hold it (empty: nobody),
## {"blocked": true} = can never be bound. Analog events: sticks belong to nobody, a trigger
## to sprint. Takes an encoded event (BindingCodec).
static func reservation(data: Dictionary) -> Dictionary:
	match str(data.get("type", "")):
		BindingCodec.TYPE_KEY:
			return _key_reservation(int(data.get("physical_keycode", 0)))
		BindingCodec.TYPE_BUTTON:
			return _button_reservation(int(data.get("button", -1)))
		BindingCodec.TYPE_AXIS:
			var owners: Array[StringName] = []
			if BindingCodec.is_trigger(int(data.get("axis", -1))):
				owners.append(&"sprint")
			return {"owners": owners}
	return {"blocked": true}


# --- Rules (private) ---------------------------------------------------------------------


static func _key_reservation(code: int) -> Dictionary:
	if KEYS_BLOCKED.has(code) or (code >= BLOCKED_FIRST and code <= BLOCKED_LAST):
		return {"blocked": true}
	var owners: Array[StringName] = []
	if KEYS_FOR_WALKING.has(code):
		owners.assign(PAD_FIXED_ACTIONS)
	elif code == KEY_SPACE:
		owners.assign(SPACE_OWNERS)
	elif code == KEY_TAB:
		owners.assign(TAB_OWNERS)
	elif not KEYS_FOR_NOBODY.has(code):
		return {}
	return {"owners": owners}


static func _button_reservation(button: int) -> Dictionary:
	if button == JOY_BUTTON_GUIDE:
		return {"blocked": true}
	if BUTTONS_FOR_NOBODY.has(button):
		return {"owners": [] as Array[StringName]}
	return {}


## Steps 1 to 3 of check().
func _check_target(action: StringName, device: Device, slot: int) -> Result:
	var result := Result.new()
	if not ACTIONS.has(action):
		result.code = Code.UNKNOWN_ACTION
	elif not is_editable(action, device):
		result.code = Code.NOT_EDITABLE
	elif slot < 0 or slot > slots(action, device).size() or slot >= SLOTS:
		result.code = Code.BAD_SLOT
	return result


## Steps 4 to 7 of check(): is this event allowed for the action on that device at all?
## Also decides the loader and whether a swap is possible.
func _check_event(action: StringName, device: Device, data: Variant) -> Result:
	var result := Result.new()
	result.data = BindingCodec.normalize(data)
	if result.data.is_empty():
		result.code = Code.INVALID_EVENT
	elif BindingCodec.device_of(result.data) != int(device):
		result.code = Code.WRONG_DEVICE
	else:
		result.code = _rule_code(action, result)
	return result


func _rule_code(action: StringName, result: Result) -> Code:
	var analog := str(result.data["type"]) == BindingCodec.TYPE_AXIS
	if analog and not BindingCodec.is_trigger(int(result.data["axis"])):
		return Code.STICK
	var rule := reservation(result.data)
	if rule.has("blocked"):
		return Code.INVALID_EVENT
	if rule.is_empty():
		return Code.OK
	result.owners.assign(rule["owners"])
	if result.owners.has(action):
		return Code.OK
	result.other = result.owners[0] if not result.owners.is_empty() else &""
	return Code.TRIGGER if analog else Code.RESERVED


## Steps 8 and 9 of check(): the same cell, the same action, another action.
func _check_holders(action: StringName, device: Device, slot: int, data: Dictionary) -> Result:
	var result := Result.new()
	result.data = data
	var id := BindingCodec.event_id(data)
	var own := slots(action, device)
	for i in own.size():
		if BindingCodec.event_id(own[i]) != id:
			continue
		result.code = Code.UNCHANGED if i == slot else Code.SAME_ACTION
		result.other = action
		result.other_slot = i
		return result
	var holder := _holder(action, device, id)
	if holder.is_empty():
		return result
	result.code = Code.CONFLICT
	result.other = holder["action"]
	result.other_slot = holder["slot"]
	result.can_take = result.other_slot >= 0 and _effective_count(result.other, device) > 1
	result.can_swap = (
		result.other_slot >= 0 and slot < own.size() and _fits(result, own[slot], device)
	)
	return result


## True if the key the edited cell holds could move to the other action's cell.
func _fits(result: Result, moved: Dictionary, device: Device) -> bool:
	return _check_event(result.other, device, moved).code == Code.OK


## The other action that holds an event on that device: {"action", "slot"} (slot -1 = fixed).
func _holder(action: StringName, device: Device, id: String) -> Dictionary:
	for other in ACTIONS:
		if other == action:
			continue
		for data in fixed(other, device):
			if BindingCodec.event_id(data) == id:
				return {"action": other, "slot": -1}
		var theirs := slots(other, device)
		for i in theirs.size():
			if BindingCodec.event_id(theirs[i]) == id:
				return {"action": other, "slot": i}
	return {}


func _effective_count(action: StringName, device: Device) -> int:
	return effective(action, device).size()


func _settle(
	result: Result, action: StringName, device: Device, slot: int, resolve: Resolve
) -> Result:
	var other := result.other
	var info := {"action": action, "other": other, "device": device, "slot": slot}
	var mine := slots(action, device)
	var theirs := slots(other, device)
	if resolve == Resolve.SWAP and result.can_swap:
		var moved := mine[slot]
		_put(mine, slot, result.data)
		_put(theirs, result.other_slot, moved)
		_commit([[action, device, mine], [other, device, theirs]], "bindings swapped", info)
	elif resolve == Resolve.TAKE:
		if not result.can_take:
			result.code = Code.LAST_BINDING
			return result
		theirs.remove_at(result.other_slot)
		_put(mine, slot, result.data)
		_commit([[action, device, mine], [other, device, theirs]], "binding taken", info)
	else:
		return result
	result.code = Code.OK
	return result


# --- Model helpers (private) ---------------------------------------------------------------


static func _pair(action: StringName, device: int) -> String:
	return "%s:%d" % [action, device]


static func _copy(list: Array) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for entry: Variant in list:
		out.append((entry as Dictionary).duplicate())
	return out


static func _ids(list: Array) -> PackedStringArray:
	var out := PackedStringArray()
	for entry: Variant in list:
		out.append(BindingCodec.event_id(entry as Dictionary))
	return out


## The same list without repeats (by event id), order kept.
static func _unique(list: Array[Dictionary]) -> Array[Dictionary]:
	var seen := {}
	var out: Array[Dictionary] = []
	for data in list:
		var id := BindingCodec.event_id(data)
		if not seen.has(id):
			seen[id] = true
			out.append(data)
	return out


static func _actions_in(action: StringName) -> Array[StringName]:
	if action == &"":
		return ACTIONS.duplicate()
	var out: Array[StringName] = []
	if ACTIONS.has(action):
		out.append(action)
	return out


static func _devices_in(device: int) -> Array[int]:
	var out: Array[int] = []
	for value: int in Device.values():
		if device < 0 or device == value:
			out.append(value)
	return out


## Slots are filled in place; `slot == size` appends.
static func _put(list: Array[Dictionary], slot: int, data: Dictionary) -> void:
	if slot >= list.size():
		list.append(data)
	else:
		list[slot] = data


func _effective_of(
	action: StringName, device: Device, slot_list: Array[Dictionary]
) -> Array[Dictionary]:
	var pinned := fixed(action, device)
	var list: Array[Dictionary] = []
	if FIXED_FIRST.has(action):
		list.append_array(pinned)
		list.append_array(slot_list)
	else:
		list.append_array(slot_list)
		list.append_array(pinned)
	return _unique(list)


func _add_default(action: StringName, event: InputEvent) -> void:
	var data := BindingCodec.encode(event)
	var device := BindingCodec.device_of(data)
	if device < 0:
		return
	var entry: Dictionary = _defaults[_pair(action, device)]
	var pinned_keys: Array = FIXED_KEYS.get(action, [])
	var pinned_buttons: Array = FIXED_BUTTONS.get(action, [])
	var is_fixed := device == int(Device.GAMEPAD) and PAD_FIXED_ACTIONS.has(action)
	if event is InputEventKey:
		is_fixed = pinned_keys.has(int((event as InputEventKey).physical_keycode))
	elif event is InputEventJoypadButton:
		is_fixed = (
			is_fixed or pinned_buttons.has(int((event as InputEventJoypadButton).button_index))
		)
	var target: Array = entry["fixed"] if is_fixed else entry["slots"]
	target.append(data)


## Stores one pair's slots; a list equal to the defaults (same order) is no override.
func _store(action: StringName, device: int, list: Array[Dictionary]) -> void:
	var key := _pair(action, device)
	if _ids(list) == _ids((_defaults[key] as Dictionary)["slots"]):
		_override.erase(key)
	else:
		_override[key] = list


## An action's events on both devices as one string, to see afterwards whether it changed.
func _fingerprints(actions: Array[StringName]) -> Dictionary:
	var out := {}
	for action in actions:
		var parts := PackedStringArray()
		for device: int in Device.values():
			parts.append(",".join(_ids(effective(action, device as Device))))
		out[action] = "|".join(parts)
	return out


func _commit(edits: Array, message: String, info: Dictionary) -> void:
	var touched: Array[StringName] = []
	for edit: Array in edits:
		var action: StringName = edit[0]
		if not touched.has(action):
			touched.append(action)
	var before := _fingerprints(touched)
	for edit: Array in edits:
		var action: StringName = edit[0]
		var device: int = edit[1]
		var list: Array[Dictionary] = edit[2]
		_store(action, device, list)
	_announce(touched, before, message, info)


## Tells the world about the actions whose events really changed: log, InputMap, signal.
func _announce(
	touched: Array[StringName], before: Dictionary, message: String, info: Dictionary
) -> void:
	var after := _fingerprints(touched)
	var names := PackedStringArray()
	for action in touched:
		if after[action] != before[action]:
			names.append(str(action))
	if names.is_empty():
		return
	Log.info(Log.Category.INPUT, message, info)
	apply(names)
	changed.emit(names)


# --- InputMap (private) ----------------------------------------------------------------------


func _apply_action(action: StringName) -> void:
	if not InputMap.has_action(action):
		Log.warn(Log.Category.INPUT, "action missing in the input map", {"action": action})
		return
	var desired: Array[InputEvent] = []
	for device: int in Device.values():
		for data in effective(action, device as Device):
			var event := BindingCodec.decode(data)
			if event != null:
				desired.append(event)
	if desired.is_empty():
		Log.warn(Log.Category.INPUT, "no events for an action, left as it is", {"action": action})
		return
	if _event_ids(InputMap.action_get_events(action)) == _event_ids(desired):
		return
	InputMap.action_erase_events(action)
	for event in desired:
		InputMap.action_add_event(action, event)
	# a key held while its meaning changed must not stay "pressed" under the new one
	Input.action_release(action)


static func _event_ids(events: Array[InputEvent]) -> PackedStringArray:
	var out := PackedStringArray()
	for event in events:
		out.append(BindingCodec.event_id(BindingCodec.encode(event)))
	return out


# --- Loading (private) -------------------------------------------------------------------------


func _drop(reason: String, info: Dictionary = {}) -> int:
	Log.warn(Log.Category.INPUT, "binding dropped: " + reason, info)
	return 1


## One action of the file: its entries split by device, then each device on its own.
func _load_action(key: Variant, value: Variant) -> int:
	if not key is String or not ACTIONS.has(StringName(str(key))):
		return _drop("unknown action", {"action": str(key)})
	if not value is Array:
		return _drop("not a list", {"action": str(key)})
	var action := StringName(str(key))
	var dropped := 0
	var found: Array = [[], []]
	var seen := {}
	for entry: Variant in value as Array:
		var data := BindingCodec.normalize(entry)
		if data.is_empty():
			dropped += _drop("not a usable event", {"action": action, "entry": str(entry)})
		elif not seen.has(BindingCodec.event_id(data)):
			seen[BindingCodec.event_id(data)] = true
			(found[BindingCodec.device_of(data)] as Array).append(data)
	for device: int in Device.values():
		dropped += _load_device(action, device as Device, found[device])
	return dropped


## One (action, device) pair of the file. No entries: defaults. Entries: the device is
## overridden with the usable ones (fixed events in the list only prove that it was written).
func _load_device(action: StringName, device: Device, entries: Array) -> int:
	var dropped := 0
	var kept: Array[Dictionary] = []
	var pinned := _ids(fixed(action, device))
	var usable := false
	for data: Dictionary in entries:
		var info := {"action": action, "event": BindingCodec.event_id(data)}
		if pinned.has(BindingCodec.event_id(data)):
			usable = true
		elif not is_editable(action, device):
			dropped += _drop("this device cannot be changed here", info)
		elif _check_event(action, device, data).code != Code.OK:
			dropped += _drop("event not allowed for the action", info)
		elif kept.size() >= SLOTS:
			dropped += _drop("more than %d events" % SLOTS, info)
		else:
			usable = true
			kept.append(data)
	if usable:
		_store(action, device, kept)
	return dropped


## Hand-edited files: two actions may claim one key, an action may be left with nothing.
## Walks the actions in order; defaults of actions that are not overridden and all fixed
## events are claimed first, an overridden list loses what is claimed. An action left without
## any binding gets its defaults back and the walk starts again (each round removes one
## override, so it ends).
func _repair_claims() -> int:
	var dropped := 0
	for device: int in Device.values():
		var walk := _claim_round(device as Device)
		dropped += int(walk["dropped"])
		while walk["emptied"] != &"":
			var emptied: StringName = walk["emptied"]
			dropped += _drop("nothing left, defaults back", {"action": emptied})
			_override.erase(_pair(emptied, device))
			walk = _claim_round(device as Device)
			dropped += int(walk["dropped"])
	# a list may have become the defaults again
	for action in ACTIONS:
		for device: int in Device.values():
			if _override.has(_pair(action, device)):
				_store(action, device, _copy(_override[_pair(action, device)]))
	return dropped


## One walk over the actions of a device: {"dropped": n, "emptied": the first action that
## was left with no binding, or &""}.
func _claim_round(device: Device) -> Dictionary:
	var claimed := {}
	for action in ACTIONS:
		for data in fixed(action, device):
			claimed[BindingCodec.event_id(data)] = true
		if not _override.has(_pair(action, device)):
			for data in default_slots(action, device):
				claimed[BindingCodec.event_id(data)] = true
	var dropped := 0
	for action in ACTIONS:
		var key := _pair(action, device)
		if not _override.has(key):
			continue
		var kept: Array[Dictionary] = []
		for data in slots(action, device):
			var id := BindingCodec.event_id(data)
			if claimed.has(id):
				dropped += _drop("key belongs to another action", {"action": action, "event": id})
			else:
				claimed[id] = true
				kept.append(data)
		_override[key] = kept
		if kept.is_empty() and fixed(action, device).is_empty():
			return {"dropped": dropped, "emptied": action}
	return {"dropped": dropped, "emptied": &""}
