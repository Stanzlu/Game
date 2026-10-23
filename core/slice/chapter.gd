class_name Chapter
extends RefCounted
## Chapter marks (ADR-052): where the story has been, as the flags "chapter.<id>". The vertical
## slice is the chapter "slice", the acts of Full Production follow ("act1" ...). The start
## menu, the save slots and the ending read them, so no code has to know a flag per act.
## A mark is set once and never cleared; `Beat` marks the steps inside a chapter.

const PREFIX := "chapter."
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
