class_name BoxAnswers
extends RefCounted
## Answers the real dialogue box of a scene in a test (the box does not pick for the player, not
## even with auto advance). Call it in the predicate of `wait_until`: it picks once per call while
## a group of answers is up.


## Picks the allowed answer with this text (the first allowed one without text). True if it did.
static func pick(box: DialogueBox, text := "") -> bool:
	if not (box.is_open() and box.line != null and box._responses.visible):
		return false
	for response: DialogueResponse in box.line.responses:
		if response.is_allowed and (text.is_empty() or response.text == text):
			box._responses.response_selected.emit(response)
			return true
	return false
