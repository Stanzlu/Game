extends GutTest
## The dialogue box: a stray press never picks an answer, a quick double confirm never runs
## an answer twice, back moves the text on, and a cue asked for while another conversation
## is open waits for it.

const BOX := preload("res://ui/dialogue/dialogue_box.tscn")
const TEXT := (
	"~ ask\n"
	+ "Mira: Bleibst du noch?\n"
	+ "- Ja\n"
	+ "\tdo WorldState.add_gold(100)\n"
	+ "\tMira: Gut.\n"
	+ "- Nein\n"
	+ "\tMira: Schade.\n"
	+ "=> END\n"
	+ "~ first\n"
	+ "Mira: Eins.\n"
	+ "=> END\n"
	+ "~ second\n"
	+ "Mira: Zwei.\n"
	+ "=> END\n"
)

const SANDBOX := "res://content/dialogue/sandbox/sandbox.dialogue"

var box: DialogueBox
var resource: DialogueResource
var gold_before := 0


func before_each() -> void:
	WorldState.new_game()
	Settings.set_value("text.speed", 1, false)
	resource = DialogueManager.create_resource_from_text(TEXT)
	box = BOX.instantiate()
	add_child_autofree(box)
	gold_before = _gold()


func _gold() -> int:
	return WorldState.state.elysia.gold - gold_before


func after_each() -> void:
	WorldState.new_game()


func _send(action: StringName) -> void:
	for pressed: bool in [true, false]:
		var event := InputEventAction.new()
		event.action = action
		event.pressed = pressed
		Input.parse_input_event(event)
		await wait_physics_frames(1)


func test_mashing_does_not_pick_the_first_answer() -> void:
	box.present(resource, "ask")
	await wait_seconds(0.1)
	await _send(&"interact")  # finishes typing, the answers appear
	await _send(&"interact")  # a quick second press
	await _send(&"interact")
	await wait_physics_frames(2)
	assert_true(box.is_open())
	assert_eq(_gold(), 0, "no answer was picked")
	await wait_seconds(0.4)
	await _send(&"interact")
	await wait_seconds(0.3)
	assert_eq(_gold(), 100, "a deliberate press picks the focused answer")


func test_a_double_confirm_runs_an_answer_once() -> void:
	box.present(resource, "ask")
	await wait_seconds(0.1)
	await _send(&"interact")
	await wait_seconds(0.5)
	var yes: DialogueResponse = box.line.responses[0]
	box._responses.response_selected.emit(yes)
	box._responses.response_selected.emit(yes)
	await wait_seconds(0.3)
	assert_eq(_gold(), 100, "the second confirm while the next line loads does nothing")


func test_back_moves_the_text_on() -> void:
	box.present(resource, "first")
	await wait_seconds(0.1)
	await _send(&"cancel")  # skips typing (Backspace or B; Esc is the pause menu's)
	await _send(&"cancel")
	await wait_seconds(0.3)
	assert_false(box.is_open(), "back closed the last line")


func test_a_cue_asked_for_while_another_is_open_waits() -> void:
	var holder := Node.new()
	add_child_autofree(holder)
	box.present(load(SANDBOX), "sign_pond")
	await wait_seconds(0.1)
	var shown: Array[String] = []
	box.finished.connect(func() -> void: shown.append(box.cue))
	Talk.present(holder, SANDBOX, "sign_meadow")
	await wait_seconds(0.1)
	assert_eq(box.cue, "sign_pond", "the open conversation goes on")
	for i in 10:
		await _send(&"interact")
		await wait_seconds(0.2)
		if shown.size() == 2:
			break
	assert_eq(shown, ["sign_pond", "sign_meadow"] as Array[String], "the waiting cue followed")
