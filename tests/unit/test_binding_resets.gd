extends GutTest
## Resetting ONE action after a take or a swap (ADR-048): the defaults it gets back may have
## been given to another action meanwhile; no key may ever belong to two actions.
## Pure model, nothing here touches the InputMap.

const H := preload("res://tests/unit/binding_helpers.gd")
const KB := InputBindings.Device.KEYBOARD

var model: InputBindings


func before_each() -> void:
	model = InputBindings.new(false)


func _sorted(names: PackedStringArray) -> PackedStringArray:
	var copy := names.duplicate()
	copy.sort()
	return copy


func test_resetting_the_one_who_gave_a_key_away_takes_it_back() -> void:
	model.bind(&"journal", KB, 0, H.key(KEY_E), InputBindings.Resolve.TAKE)
	assert_eq(H.slot_ids(model, &"interact", KB), H.key_ids([KEY_SPACE]), "E was taken")
	model.reset(&"interact", KB)
	assert_eq(H.slot_ids(model, &"interact", KB), H.key_ids([KEY_E, KEY_SPACE]))
	assert_eq(H.violations(model), PackedStringArray(), "no key on two actions")
	assert_eq(
		H.slot_ids(model, &"journal", KB), H.key_ids([KEY_J]), "the taker is left with its own"
	)
	assert_false(model.is_overridden(&"journal", KB), "that is the default again")


func test_resetting_the_one_who_took_a_key_hands_the_old_owner_its_key_back() -> void:
	model.bind(&"journal", KB, 0, H.key(KEY_E), InputBindings.Resolve.SWAP)
	assert_eq(H.slot_ids(model, &"interact", KB), H.key_ids([KEY_J, KEY_SPACE]))
	model.reset(&"journal", KB)
	assert_eq(H.violations(model), PackedStringArray())
	assert_eq(H.slot_ids(model, &"journal", KB), H.key_ids([KEY_J]))
	assert_eq(H.slot_ids(model, &"interact", KB), H.key_ids([KEY_SPACE]), "J went back")


func test_a_reset_that_empties_the_holder_goes_on_until_every_rule_holds() -> void:
	# sprint and journal swap (sprint J, journal Shift), journal takes E from interact: when
	# interact asks for E back, journal falls back to J, which sprint holds, and sprint to Shift
	model.bind(&"sprint", KB, 0, H.key(KEY_J), InputBindings.Resolve.SWAP)
	var taken := model.bind(&"journal", KB, 0, H.key(KEY_E), InputBindings.Resolve.TAKE)
	assert_eq(taken.code, InputBindings.Code.OK)
	assert_eq(H.slot_ids(model, &"sprint", KB), H.key_ids([KEY_J]))
	assert_eq(H.slot_ids(model, &"journal", KB), H.key_ids([KEY_E]))
	watch_signals(model)
	model.reset(&"interact", KB)
	assert_eq(H.violations(model), PackedStringArray())
	assert_eq(H.slot_ids(model, &"interact", KB), H.key_ids([KEY_E, KEY_SPACE]))
	assert_eq(H.slot_ids(model, &"journal", KB), H.key_ids([KEY_J]))
	assert_eq(H.slot_ids(model, &"sprint", KB), H.key_ids([KEY_SHIFT]))
	assert_false(model.is_overridden(), "every action is on its defaults again")
	assert_signal_emit_count(model, "changed", 1)
	var names: PackedStringArray = get_signal_parameters(model, "changed")[0]
	assert_eq(_sorted(names), PackedStringArray(["interact", "journal", "sprint"]))


func test_the_file_of_a_partial_reset_needs_no_repair() -> void:
	model.bind(&"journal", KB, 0, H.key(KEY_E), InputBindings.Resolve.SWAP)
	model.bind(&"sprint", KB, 0, H.key(KEY_F))
	model.reset(&"journal", KB)
	var copy := InputBindings.new(false)
	assert_eq(copy.load_data(model.to_data()), 0, "nothing dropped on the way back in")
	assert_eq(H.layout(copy), H.layout(model))


func test_a_single_reset_never_breaks_a_rule_over_many_edits() -> void:
	for seed_value in 12:
		var rng := RandomNumberGenerator.new()
		rng.seed = 900 + seed_value
		var walk := InputBindings.new(false)
		for step in 120:
			var action: StringName = InputBindings.ACTIONS[rng.randi_range(0, 8)]
			var other: StringName = InputBindings.ACTIONS[rng.randi_range(0, 8)]
			var key_code: int = [KEY_E, KEY_J, KEY_F, KEY_Q, KEY_SPACE, KEY_TAB, KEY_SHIFT][
				rng.randi_range(0, 6)
			]
			var resolve := rng.randi_range(0, 2) as InputBindings.Resolve
			walk.bind(action, KB, rng.randi_range(0, 1), H.key(key_code), resolve)
			if rng.randi_range(0, 2) == 0:
				walk.reset(other, KB)
			var found := H.violations(walk)
			assert_eq(found, PackedStringArray(), "seed %d step %d" % [seed_value, step])
			if not found.is_empty():
				return
