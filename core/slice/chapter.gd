class_name Chapter
extends RefCounted
## Chapter marks (ADR-052): where the story has been, as the flags "chapter.<id>". The vertical
## slice is the chapter "slice", the acts of Full Production follow ("act1" ...). The start
## menu, the save slots and the ending read them, so no code has to know a flag per act.
## A mark is set once and never cleared; `Beat` marks the steps inside a chapter.
## The last chapter this build tells is LAST: a save that has reached it counts as finished (the
## start menu says so under the logo, "Neues Spiel" no longer asks). The end of Act II is not that
## any more: "Weiter" goes on with the morning after (ADR-070); nor is the end of Act III: the
## way west out of the valley goes on (ADR-071). LAST moves with the act that ends the build;
## game code never asks for a chapter by its id before an act sets it (StoryLint).

const PREFIX := "chapter."
const LAST := "act4"
## Flags that older builds set for a chapter: chapter id -> flag. Still read, never set again.
const LEGACY := {"slice": "slice.finished"}


static func flag_for(id: String) -> String:
	return PREFIX + id


## Marks the chapter as reached. The caller saves (the ending asks for its own autosave).
static func mark(id: String) -> void:
	WorldState.set_flag(flag_for(id))


static func reached(id: String) -> bool:
	return in_flags(WorldState.state.flags, id)


## The same for a saved flag table (save slots read it without loading the state).
static func in_flags(flags: Dictionary, id: String) -> bool:
	if bool(flags.get(flag_for(id), false)):
		return true
	return LEGACY.has(id) and bool(flags.get(LEGACY[id], false))
