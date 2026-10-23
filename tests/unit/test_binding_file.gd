extends GutTest
## The "input" block of settings.json: what is written (both devices of an overridden action),
## what is read (leniently, repairing hand edits) and that no file can leave the game without
## a binding. Pure model; the file itself is tested in test_settings.

const H := preload("res://tests/unit/binding_helpers.gd")
const KB := InputBindings.Device.KEYBOARD
const PAD := InputBindings.Device.GAMEPAD
const KEY_POOL: Array[int] = [
	KEY_A,
	KEY_B,
	KEY_E,
	KEY_F,
	KEY_G,
	KEY_H,
	KEY_J,
	KEY_K,
	KEY_L,
	KEY_Q,
	KEY_W,
	KEY_S,
	KEY_D,
	KEY_1,
	KEY_2,
	KEY_F1,
	KEY_F5,
	KEY_F12,
	KEY_F3,
	KEY_SPACE,
	KEY_TAB,
	KEY_SHIFT,
	KEY_CTRL,
	KEY_ALT,
	KEY_META,
	KEY_ENTER,
	KEY_KP_ENTER,
	KEY_ESCAPE,
	KEY_BACKSPACE,
	KEY_DELETE,
	KEY_PAGEUP,
	KEY_UP,
	KEY_DOWN,
	KEY_LEFT,
	KEY_RIGHT,
	KEY_CAPSLOCK,
	KEY_VOLUMEUP,
	KEY_KP_5,
	KEY_SEMICOLON,
	KEY_INSERT,
	KEY_UNKNOWN,
	0,
	99999,
]

var model: InputBindings


func before_each() -> void:
	model = InputBindings.new(false)


func after_each() -> void:
	Settings.bindings.reset()
	Settings.apply_all()


func _loaded(data: Variant) -> InputBindings:
	var fresh := InputBindings.new(false)
	fresh.load_data(data)
	return fresh


## The slots of every pair as the defaults have them, except the pairs in `changed`.
func _slots_except(changed: Dictionary) -> Dictionary:
	var out := {}
	var defaults := InputBindings.new(false)
	for action in InputBindings.ACTIONS:
		for device: int in InputBindings.Device.values():
			var pair := "%s:%d" % [action, device]
			var kind := device as InputBindings.Device
			out[pair] = changed.get(pair, H.ids(defaults.default_slots(action, kind)))
	return out


func _slots_of(loaded: InputBindings) -> Dictionary:
	var out := {}
	for action in InputBindings.ACTIONS:
		for device: int in InputBindings.Device.values():
			out["%s:%d" % [action, device]] = H.slot_ids(loaded, action, device)
	return out


func test_to_data_writes_the_effective_events_of_both_devices() -> void:
	model.bind(&"cancel", KB, 0, H.key(KEY_F))
	model.clear(&"cancel", KB, 0)
	model.bind(&"journal", PAD, 0, H.button(JOY_BUTTON_LEFT_SHOULDER))
	var data := model.to_data()
	assert_eq(data.keys().size(), 2, "only the overridden actions")
	# cancel: Backspace removed leaves the pinned Esc; the pad side is written along
	assert_eq(data["cancel"], [H.key(KEY_ESCAPE), H.button(JOY_BUTTON_B)])
	assert_eq(data["journal"], [H.key(KEY_J), H.button(JOY_BUTTON_LEFT_SHOULDER)])
	assert_false(data.has("sprint"), "defaults are never written")
	for action: String in data:
		for entry: Dictionary in data[action]:
			assert_eq(BindingCodec.normalize(entry), entry, "every entry is in its normal form")
	var reread: Variant = JSON.parse_string(JSON.stringify(data))
	assert_eq(H.layout(_loaded(reread)), H.layout(model), "and survives the trip through JSON")


func test_a_pad_override_writes_the_keyboard_too() -> void:
	# a 0.7.0 build replaces a whole action from the file: it must still find the keys
	model.bind(&"interact", PAD, 0, H.button(JOY_BUTTON_LEFT_SHOULDER))
	var list: Array = model.to_data()["interact"]
	assert_eq(
		H.ids(_typed(list)),
		H.key_ids([KEY_E, KEY_SPACE, KEY_ENTER, KEY_KP_ENTER]) + ["b9", "b0"] as Array[String]
	)


func _typed(list: Array) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for entry: Dictionary in list:
		out.append(entry)
	return out


func test_every_layout_reads_back_the_same() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	for index in 40:
		model.reset()
		for step in rng.randi_range(1, 8):
			_random_edit(rng, model)
		var copy := InputBindings.new(false)
		assert_eq(copy.load_data(model.to_data()), 0, "a file we wrote needs no repair")
		assert_eq(H.layout(copy), H.layout(model), "round %d" % index)
		assert_eq(copy.is_overridden(), model.is_overridden())


## Loader cases: the file's "input" block, how many pieces get dropped (each one warns), and
## the slots that differ from the defaults afterwards.
func _loader_cases() -> Array[Dictionary]:
	var f := H.key(KEY_F)
	var g := H.key(KEY_G)
	var h := H.key(KEY_H)
	var lb := H.button(JOY_BUTTON_LEFT_SHOULDER)
	var rt := H.axis(JOY_AXIS_TRIGGER_RIGHT, 1.0)
	return [
		{"name": "nothing", "data": null, "drops": 0, "slots": {}},
		{"name": "empty block", "data": {}, "drops": 0, "slots": {}},
		{"name": "block of the wrong type", "data": [f], "drops": 1, "slots": {}},
		{"name": "block is a string", "data": "interact", "drops": 1, "slots": {}},
		{"name": "unknown action", "data": {"no_action": [f]}, "drops": 1, "slots": {}},
		{"name": "ui_accept", "data": {"ui_accept": [f]}, "drops": 1, "slots": {}},
		{"name": "scroll_up", "data": {"scroll_up": [f]}, "drops": 1, "slots": {}},
		{"name": "debug_panel", "data": {"debug_panel": [f]}, "drops": 1, "slots": {}},
		{"name": "action key is a number", "data": {5: [f]}, "drops": 1, "slots": {}},
		{"name": "value is a string", "data": {"interact": "F"}, "drops": 1, "slots": {}},
		{"name": "value is a dictionary", "data": {"interact": f}, "drops": 1, "slots": {}},
		{
			"name": "entries are no dictionaries",
			"data": {"journal": ["F", 7, null]},
			"drops": 3,
			"slots": {}
		},
		{"name": "mouse entry", "data": {"journal": [{"type": "mouse"}]}, "drops": 1, "slots": {}},
		{
			"name": "script entry",
			"data": {"cancel": [{"type": "script", "source": "res://x.gd"}]},
			"drops": 1,
			"slots": {}
		},
		{"name": "key 0", "data": {"journal": [H.key(0)]}, "drops": 1, "slots": {}},
		{"name": "reserved key", "data": {"sprint": [H.key(KEY_ENTER)]}, "drops": 1, "slots": {}},
		{
			"name": "blocked key",
			"data": {"journal": [H.key(KEY_CAPSLOCK)]},
			"drops": 1,
			"slots": {}
		},
		{
			"name": "stick axis",
			"data": {"journal": [H.axis(JOY_AXIS_LEFT_X, -1.0)]},
			"drops": 1,
			"slots": {}
		},
		{"name": "trigger on interact", "data": {"interact": [rt]}, "drops": 1, "slots": {}},
		{"name": "pad button for the walk", "data": {"move_up": [lb]}, "drops": 1, "slots": {}},
		{
			"name": "pad A as a cell",
			"data": {"journal": [H.button(JOY_BUTTON_A)]},
			"drops": 1,
			"slots": {}
		},
		{
			"name": "three entries",
			"data": {"journal": [f, g, h]},
			"drops": 1,
			"slots": {"journal:0": ["k70", "k71"]}
		},
		{
			"name": "repeats",
			"data": {"journal": [f, f, f]},
			"drops": 0,
			"slots": {"journal:0": ["k70"]}
		},
		{
			"name": "invalid only",
			"data": {"sprint": [H.key(KEY_ENTER), {"type": "x"}]},
			"drops": 2,
			"slots": {}
		},
		{"name": "empty list", "data": {"interact": []}, "drops": 0, "slots": {}},
		{
			"name": "fixed only",
			"data": {"cancel": [H.key(KEY_ESCAPE)]},
			"drops": 0,
			"slots": {"cancel:0": []}
		},
		{
			"name": "fixed keys only: the cells are empty",
			"data": {"interact": [H.key(KEY_ENTER), H.key(KEY_KP_ENTER)]},
			"drops": 0,
			"slots": {"interact:0": []},
		},
		{
			"name": "the defaults, listed",
			"data": {"journal": [H.key(KEY_J), H.button(JOY_BUTTON_BACK)]},
			"drops": 0,
			"slots": {}
		},
		{
			"name": "a key that a default action holds",
			"data": {"journal": [H.key(KEY_E)]},
			"drops": 2,
			"slots": {},
		},
		{
			"name": "same key on two actions: the later one loses it",
			"data": {"journal": [f], "sprint": [f]},
			"drops": 2,
			"slots": {"sprint:0": ["k70"]},
		},
		{
			"name": "a swap written by hand holds together",
			"data": {"interact": [H.key(KEY_J), H.key(KEY_SPACE)], "journal": [H.key(KEY_E)]},
			"drops": 0,
			"slots": {"interact:0": ["k74", "k32"], "journal:0": ["k69"]},
		},
		{
			"name": "a chain: both fall back, the second round frees the first",
			"data": {"move_up": [H.key(KEY_J)], "journal": [H.key(KEY_E)]},
			"drops": 4,
			"slots": {},
		},
		{
			"name": "one device does not touch the other",
			"data": {"sprint": [lb]},
			"drops": 0,
			"slots": {"sprint:1": ["b9"]},
		},
		{
			"name": "pad entries of a walk action that are its own",
			"data": {"move_up": [H.axis(JOY_AXIS_LEFT_Y, -1.0), H.button(JOY_BUTTON_DPAD_UP)]},
			"drops": 0,
			"slots": {},
		},
		{
			"name": "json numbers",
			"data": JSON.parse_string('{"journal": [{"type": "key", "physical_keycode": 70.0}]}'),
			"drops": 0,
			"slots": {"journal:0": ["k70"]},
		},
	]


func test_loader_table() -> void:
	var warned := 0
	for entry in _loader_cases():
		var loaded := InputBindings.new(false)
		var drops := loaded.load_data(entry["data"])
		var label: String = entry["name"]
		assert_eq(drops, entry["drops"], label + ": dropped pieces")
		assert_eq(_slots_of(loaded), _slots_except(entry["slots"]), label + ": slots")
		assert_eq(H.violations(loaded), PackedStringArray(), label + ": rules")
		warned += drops
	# every dropped piece is exactly one warning, and the texts say what happened
	assert_gt(warned, 20, "the table has to drop a lot")
	assert_push_warning_count(warned)
	var errors: Array = gut.error_tracker.get_errors_for_test()
	for tracked: GutTrackedError in errors:
		assert_true(tracked.contains_text("binding dropped"), str(tracked.code))


func test_v1_flat_list_is_read_per_device() -> void:
	# version 1 wrote a bare list; a key-only list used to drop the pad. Now a device with no
	# entries keeps its defaults.
	var keys_only := _loaded({"interact": [H.key(KEY_F)]})
	assert_eq(H.slot_ids(keys_only, &"interact", KB), H.key_ids([KEY_F]))
	assert_eq(H.effective_ids(keys_only, &"interact", PAD), ["b0"] as Array[String], "pad A stays")
	assert_eq(
		H.effective_ids(keys_only, &"interact", KB),
		H.key_ids([KEY_F, KEY_ENTER, KEY_KP_ENTER]),
		"the pinned keys come along"
	)
	var pad_only := _loaded({"sprint": [H.button(JOY_BUTTON_LEFT_SHOULDER)]})
	assert_eq(H.effective_ids(pad_only, &"sprint", KB), H.key_ids([KEY_SHIFT]))
	assert_eq(H.effective_ids(pad_only, &"sprint", PAD), ["b9"] as Array[String])
	assert_true(pad_only.is_overridden(&"sprint", PAD))
	assert_false(pad_only.is_overridden(&"sprint", KB))


func test_the_defaults_in_a_file_are_no_override() -> void:
	# both devices are written for an overridden action: the untouched one must not stick
	model.bind(&"sprint", KB, 0, H.key(KEY_F))
	var loaded := _loaded(model.to_data())
	assert_true(loaded.is_overridden(&"sprint", KB))
	assert_false(loaded.is_overridden(&"sprint", PAD), "the pad list is the defaults")
	assert_eq(loaded.to_data(), model.to_data())
	# the order of the cells counts: [Space, E] is not the default [E, Space]
	var swapped := _loaded({"interact": [H.key(KEY_SPACE), H.key(KEY_E), H.key(KEY_ENTER)]})
	assert_true(swapped.is_overridden(&"interact", KB))
	assert_eq(H.slot_ids(swapped, &"interact", KB), H.key_ids([KEY_SPACE, KEY_E]))
	var plain := _loaded({"interact": [H.key(KEY_E), H.key(KEY_SPACE), H.key(KEY_ENTER)]})
	assert_false(plain.is_overridden(), "[E, Space] is the default")


func test_an_action_left_with_nothing_gets_its_defaults_back() -> void:
	# sprint wants the key that interact (not overridden) keeps: nothing is left for it
	var loaded := _loaded({"sprint": [H.key(KEY_E)]})
	assert_eq(H.effective_ids(loaded, &"sprint", KB), H.key_ids([KEY_SHIFT]))
	assert_push_warning_count(2)
	# the fall-back may free keys that an earlier action wanted: everything is walked again
	var chain := _loaded({"sprint": [H.key(KEY_J)], "journal": [H.key(KEY_K)]})
	assert_eq(H.violations(chain), PackedStringArray())
	assert_eq(H.slot_ids(chain, &"sprint", KB), H.key_ids([KEY_J]))
	assert_eq(H.slot_ids(chain, &"journal", KB), H.key_ids([KEY_K]))


func test_the_loader_survives_hostile_data() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 20261022
	Log.muted_categories.append(Log.Category.INPUT)
	for index in 300:
		var loaded := InputBindings.new(false)
		loaded.load_data(_garbage_block(rng))
		var found := H.violations(loaded)
		assert_eq(found, PackedStringArray(), "round %d" % index)
		var copy := InputBindings.new(false)
		assert_eq(copy.load_data(loaded.to_data()), 0, "what it keeps is clean: round %d" % index)
		assert_eq(H.layout(copy), H.layout(loaded))
	Log.muted_categories.erase(Log.Category.INPUT)


func test_invariants_hold_over_random_edits() -> void:
	# several walks: a single seed never reached a reset of one action after a take or a swap
	var seen := {}
	var settled := [0]
	for seed_value: int in [48, 49, 50, 51]:
		_walk_random_edits(seed_value, seen, settled)
	# the walks have to be real ones: edits that worked, conflicts that were settled, refusals
	assert_gt(int(seen.get(InputBindings.Code.OK, 0)), 40, str(seen))
	assert_gt(int(settled[0]), 5, "swaps and takes happened: " + str(seen))
	assert_gt(seen.size(), 7, "many kinds of refusal: " + str(seen))


## One walk of 400 random edits; counts the results into `seen` and the settled conflicts into
## settled[0].
func _walk_random_edits(seed_value: int, seen: Dictionary, settled: Array) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	var live := InputBindings.new()
	for step in 400:
		var before := H.layout(live)
		var result := _random_edit(rng, live)
		if result != null:
			seen[result.code] = int(seen.get(result.code, 0)) + 1
			settled[0] = (
				int(settled[0]) + int(result.code == InputBindings.Code.OK and result.other != &"")
			)
		var found := H.violations(live)
		var where := "seed %d step %d: %s" % [seed_value, step, str(result)]
		assert_eq(found, PackedStringArray(), where)
		if result != null and not result.ok():
			assert_eq(H.layout(live), before, where + ": a refusal changed something")
		var copy := InputBindings.new(false)
		assert_eq(copy.load_data(live.to_data()), 0, where + ": the file needs no repair")
		assert_eq(H.layout(copy), H.layout(live), where + ": the file says the same")
		if step % 25 == 0:
			_assert_input_map_follows(live, step)
		if not found.is_empty():
			break
	live.reset()
	live.apply()
	_assert_input_map_follows(live, -1)


func _assert_input_map_follows(live: InputBindings, step: int) -> void:
	for action in InputBindings.ACTIONS:
		var wanted: Array[String] = []
		for device: int in InputBindings.Device.values():
			wanted.append_array(H.effective_ids(live, action, device))
		var have: Array[String] = []
		for event in InputMap.action_get_events(action):
			have.append(BindingCodec.event_id(BindingCodec.encode(event)))
		assert_eq(have, wanted, "step %d: the input map of %s" % [step, action])
		for event in InputMap.action_get_events(action):
			assert_eq(event.device, -1, "every event listens to all devices")


# --- random edits and random files -------------------------------------------------------


## An event for `device` (rarely one of the other device or plain garbage): often one that is
## held right now, which provokes conflicts, repeats and pinned events.
func _random_event(
	rng: RandomNumberGenerator, from: InputBindings, device: InputBindings.Device
) -> Dictionary:
	var roll := rng.randi_range(0, 99)
	if roll < 6:
		return [{}, {"type": "mouse"}, {"type": "key"}, {"type": 5}][rng.randi_range(0, 3)]
	if roll < 12:
		device = (1 - int(device)) as InputBindings.Device
	if roll < 45:
		var action: StringName = InputBindings.ACTIONS[rng.randi_range(0, 8)]
		var list := from.effective(action, device)
		if not list.is_empty():
			return list[rng.randi_range(0, list.size() - 1)]
	if device == InputBindings.Device.KEYBOARD:
		return H.key(KEY_POOL[rng.randi_range(0, KEY_POOL.size() - 1)])
	if roll < 90:
		return H.button(rng.randi_range(-1, 27))
	var value := 1.0 if rng.randi_range(0, 1) == 0 else -1.0
	return H.axis(rng.randi_range(0, 6), value * rng.randf_range(0.0, 1.0))


## One random bind, clear or reset. Returns the Result of a bind, else null.
func _random_edit(rng: RandomNumberGenerator, target: InputBindings) -> InputBindings.Result:
	var action: StringName = InputBindings.ACTIONS[rng.randi_range(0, 8)]
	if rng.randi_range(0, 19) == 0:
		action = [&"nothing", &"ui_accept", &"debug_panel"][rng.randi_range(0, 2)]
	var device := rng.randi_range(0, 1) as InputBindings.Device
	var slot := rng.randi_range(0, target.slots(action, device).size())
	if rng.randi_range(0, 14) == 0:
		slot = rng.randi_range(-1, 4)
	var roll := rng.randi_range(0, 99)
	if roll < 72:
		var resolve := [0, 0, 1, 1, 2, 2][rng.randi_range(0, 5)] as InputBindings.Resolve
		return target.bind(action, device, slot, _random_event(rng, target, device), resolve)
	if roll < 92:
		target.clear(action, device, slot)
	elif roll < 96:
		target.reset(action, device)
	elif roll < 98:
		target.reset(&"", device)
	else:
		target.reset()
	return null


func _garbage_value(rng: RandomNumberGenerator, depth: int) -> Variant:
	var scalars: Array = [
		null,
		-3,
		0,
		87,
		100000,
		NAN,
		INF,
		-INF,
		1e30,
		-0.0,
		87.9,
		0.5,
		"",
		"key",
		"up",
		"joy_axis",
		true,
		false
	]
	var roll := rng.randi_range(0, 11)
	var value: Variant = scalars[rng.randi_range(0, scalars.size() - 1)]
	if roll >= 7 and depth <= 2:
		value = _garbage_entry(rng, depth + 1)
	elif roll >= 5 and depth <= 2:
		var list := []
		for i in rng.randi_range(0, 4):
			list.append(_garbage_value(rng, depth + 1))
		value = list
	return value


func _garbage_entry(rng: RandomNumberGenerator, depth: int) -> Dictionary:
	var kinds := ["key", "joy_button", "joy_axis", "mouse", "script"]
	var entry := {"type": kinds[rng.randi_range(0, kinds.size() - 1)]}
	for field: String in ["physical_keycode", "button", "axis", "value"]:
		if rng.randi_range(0, 2) > 0:
			entry[field] = _garbage_value(rng, depth + 1)
	if rng.randi_range(0, 3) == 0:
		entry["type"] = _garbage_value(rng, depth + 1)
	return entry


func _garbage_block(rng: RandomNumberGenerator) -> Variant:
	if rng.randi_range(0, 9) == 0:
		return _garbage_value(rng, 0)
	var block := {}
	var names: Array = []
	names.append_array(InputBindings.ACTIONS)
	names.append_array(["ui_accept", "no_action", "scroll_up", 5])
	for i in rng.randi_range(0, 12):
		var list := []
		for k in rng.randi_range(0, 5):
			if rng.randi_range(0, 4) == 0:
				list.append(_garbage_value(rng, 0))
			elif rng.randi_range(0, 1) == 0:
				list.append(H.key(KEY_POOL[rng.randi_range(0, KEY_POOL.size() - 1)]))
			else:
				list.append(_garbage_entry(rng, 0))
		block[names[rng.randi_range(0, names.size() - 1)]] = list
	return block
