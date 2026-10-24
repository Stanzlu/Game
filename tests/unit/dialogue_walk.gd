class_name DialogueWalk
extends RefCounted
## Plays a dialogue cue without a box, for tests of what a conversation sets and says. The helpers
## wait on the dialogue manager, so call them with await.


## Texts of the answers the player can pick at the first choice of `cue`.
static func answers(path: String, cue: String) -> PackedStringArray:
	var resource := load(path) as DialogueResource
	var line: DialogueLine = await DialogueManager.get_next_dialogue_line(resource, cue)
	while line != null and line.responses.is_empty():
		line = await DialogueManager.get_next_dialogue_line(resource, line.next_id)
	var texts: PackedStringArray = []
	if line != null:
		for r: DialogueResponse in line.responses:
			if r.is_allowed:
				texts.append(r.text)
	return texts


## Plays `cue` to its end, at each choice taking the answer that contains the next entry of `picks`
## (the first allowed one when `picks` has run out or nothing matches). Returns the line texts seen.
static func play(path: String, cue: String, picks: PackedStringArray = []) -> PackedStringArray:
	var resource := load(path) as DialogueResource
	var seen: PackedStringArray = []
	var choice := 0
	var line: DialogueLine = await DialogueManager.get_next_dialogue_line(resource, cue)
	while line != null:
		seen.append(line.text)
		var next_id := line.next_id
		if not line.responses.is_empty():
			var pick := picks[choice] if choice < picks.size() else ""
			choice += 1
			var chosen: DialogueResponse = null
			for r: DialogueResponse in line.responses:
				if r.is_allowed and (chosen == null or (not pick.is_empty() and pick in r.text)):
					chosen = r
			next_id = chosen.next_id
		line = await DialogueManager.get_next_dialogue_line(resource, next_id)
	return seen
