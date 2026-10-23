class_name BindingCapture
extends RefCounted
## "Press the new key": a small state machine that turns the raw events of a capture into
## what the page should do (ADR-048). No scene needed, unit-tested with synthetic events.
## One instance per capture. The page feeds it every key and pad event while it captures and
## calls tick(delta) from its _process (game time, never the wall clock).
##
## The ways a capture goes wrong in the real world, and what is done about them:
##  - the press that started the capture repeats or is pressed twice: presses are ignored for
##    ARM_SECONDS (Esc and pad Start still cancel at once), key echo and releases never count;
##  - a stick or trigger that is still deflected when the capture starts (the stick that moved
##    to the row) counts only after it was seen at rest;
##  - Ctrl+W, Shift+Tab: Shift and Ctrl are bound when they are RELEASED without another key in
##    between, and only if their press was seen during this capture; Alt and Cmd (Alt+Tab,
##    Cmd+Tab) are never bound, the model refuses them at once;
##  - an analog axis reports a stream of events: a trigger counts once per pull, a stick is
##    only reported (it can never be bound).

enum Kind {
	NONE,
	## `data` is the encoded event to bind.
	EVENT,
	## Esc or pad Start: leave the capture.
	CANCEL,
	## Delete: empty the cell.
	CLEAR,
	## A stick was pushed (they cannot be bound): tell the player, keep capturing.
	STICK,
	## A key while a pad button is wanted, or the reverse; `data` is the event meant for the
	## other device.
	OTHER_DEVICE,
	## A key press that carries no physical key code, or a button that does not exist.
	INVALID,
}

## A trigger counts as pulled from here ...
const TRIGGER_ON := 0.6
## ... once it was seen below this (and the same re-arms a stick).
const REST := 0.3
const STICK_ON := 0.7
## Presses are ignored this long after the capture started (game time).
const ARM_SECONDS := 0.3

## Seconds left in which presses are ignored; tests set it to 0.
var armed_in := ARM_SECONDS

var _device: InputBindings.Device
## Shift or Ctrl pressed during this capture and not released yet (physical code, 0 = none).
var _pending := 0
## "pad:axis" of axes that have to be seen below REST before they count again.
var _held := {}


## Remembers every axis of every connected pad that is deflected right now.
func _init(for_device: InputBindings.Device) -> void:
	_device = for_device
	snapshot(Input.get_connected_joypads(), Input.get_joy_axis)


## Holds every axis of the given pads whose position, asked as axis_value.call(pad, axis), is
## at REST or beyond in either direction. The constructor passes the real pads; a test passes
## a stand-in (headless has no pad).
func snapshot(pads: Array[int], axis_value: Callable) -> void:
	for pad in pads:
		for axis: int in range(BindingCodec.AXIS_COUNT):
			if absf(float(axis_value.call(pad, axis))) >= REST:
				hold_axis(pad, axis)


## Lets game time pass: the press that started the capture is over after ARM_SECONDS.
func tick(delta: float) -> void:
	armed_in = maxf(armed_in - delta, 0.0)


## An axis that is deflected must be seen at rest before it counts (the constructor does this
## for every pad it finds; public so a test can stand in for a pad).
func hold_axis(pad: int, axis: int) -> void:
	_held[_axis_key(pad, axis)] = true


## Forgets a pending Shift or Ctrl (the page calls this when the capture is left).
func reset() -> void:
	_pending = 0


func feed(event: InputEvent) -> Outcome:
	if event is InputEventKey:
		return _feed_key(event as InputEventKey)
	if event is InputEventJoypadButton:
		return _feed_button(event as InputEventJoypadButton)
	if event is InputEventJoypadMotion:
		return _feed_motion(event as InputEventJoypadMotion)
	return _outcome(Kind.NONE)


func _feed_key(key: InputEventKey) -> Outcome:
	if key.echo:
		return _outcome(Kind.NONE)
	var code := int(key.physical_keycode)
	if not key.pressed:
		return _released(code)
	return _pressed(key, code)


func _pressed(key: InputEventKey, code: int) -> Outcome:
	# Esc and Delete are recognised by the logical key too: a remote-play tool may send no
	# physical code, and Esc must always get out
	var named := code if code != 0 else int(key.keycode)
	if named == KEY_ESCAPE:
		_pending = 0
		return _outcome(Kind.CANCEL)
	if armed_in > 0.0:
		return _outcome(Kind.NONE)
	if named == KEY_DELETE:
		_pending = 0
		return _outcome(Kind.CLEAR)
	if code == 0:
		return _outcome(Kind.INVALID)
	return _bindable_key(key, code)


## A key that could be the new binding: for the other device it only says so, Shift and Ctrl
## wait for their release.
func _bindable_key(key: InputEventKey, code: int) -> Outcome:
	var data := BindingCodec.encode(key)
	if _device == InputBindings.Device.GAMEPAD:
		return _outcome(Kind.OTHER_DEVICE, data)
	if code == KEY_SHIFT or code == KEY_CTRL:
		_pending = code
		return _outcome(Kind.NONE)
	_pending = 0
	return _outcome(Kind.EVENT if not data.is_empty() else Kind.INVALID, data)


## The release of the Shift or Ctrl whose press was seen in this capture binds it.
func _released(code: int) -> Outcome:
	if _pending == 0 or code != _pending:
		return _outcome(Kind.NONE)
	_pending = 0
	return _outcome(Kind.EVENT, {"type": BindingCodec.TYPE_KEY, "physical_keycode": code})


func _feed_button(button: InputEventJoypadButton) -> Outcome:
	if not button.pressed:
		return _outcome(Kind.NONE)
	if button.button_index == JOY_BUTTON_START:
		return _outcome(Kind.CANCEL)
	if armed_in > 0.0:
		return _outcome(Kind.NONE)
	var data := BindingCodec.encode(button)
	if data.is_empty():
		return _outcome(Kind.INVALID)
	var wanted := _device == InputBindings.Device.GAMEPAD
	return _outcome(Kind.EVENT if wanted else Kind.OTHER_DEVICE, data)


## Only a pad capture listens to the sticks and triggers. One report per push or pull.
func _feed_motion(motion: InputEventJoypadMotion) -> Outcome:
	var axis := int(motion.axis)
	if _device != InputBindings.Device.GAMEPAD or axis >= BindingCodec.AXIS_COUNT:
		return _outcome(Kind.NONE)
	var pad_axis := _axis_key(motion.device, axis)
	var strength := absf(motion.axis_value)
	if strength < REST:
		_held.erase(pad_axis)
		return _outcome(Kind.NONE)
	var trigger := BindingCodec.is_trigger(axis)
	var on := TRIGGER_ON if trigger else STICK_ON
	if strength < on or _held.has(pad_axis) or (trigger and motion.axis_value < 0.0):
		return _outcome(Kind.NONE)
	_held[pad_axis] = true
	if armed_in > 0.0:
		return _outcome(Kind.NONE)
	if not trigger:
		return _outcome(Kind.STICK)
	return _outcome(Kind.EVENT, {"type": BindingCodec.TYPE_AXIS, "axis": axis, "value": 1.0})


static func _axis_key(pad: int, axis: int) -> String:
	return "%d:%d" % [pad, axis]


static func _outcome(kind: Kind, data: Dictionary = {}) -> Outcome:
	var outcome := Outcome.new()
	outcome.kind = kind
	outcome.data = data
	return outcome


## What feed() found: `kind`, and the encoded event for EVENT and OTHER_DEVICE.
class Outcome:
	extends RefCounted
	var kind := Kind.NONE
	var data: Dictionary = {}
