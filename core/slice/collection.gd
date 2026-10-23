class_name Collection
extends RefCounted
## The collectibles of the whole game (Game Bible §31): 24 memory fragments, 12 melodies and about
## 30 curiosities. Fragments and melodies are flags "fragment.<id>" and "melody.<id>" (the IDs are
## snake_case, stable, never renamed); curiosities are items ("curiosity_<name>", ContentDB).
## Counting reads the flags by their prefix, so a new one needs no change here. Nothing shows a
## number to the player (Bible §23: no counters for what matters); the counts are for the ending,
## the journal and the tests.

const FRAGMENT_PREFIX := "fragment."
const MELODY_PREFIX := "melody."
const CURIOSITY_PREFIX := "curiosity_"
const FRAGMENTS_TOTAL := 24
const MELODIES_TOTAL := 12


## Marks a memory fragment as found. True if it is new.
static func collect_fragment(id: String) -> bool:
	return _collect(FRAGMENT_PREFIX + id)


## Marks a melody as found. True if it is new.
static func collect_melody(id: String) -> bool:
	return _collect(MELODY_PREFIX + id)


static func has_fragment(id: String) -> bool:
	return WorldState.has_flag(FRAGMENT_PREFIX + id)


static func has_melody(id: String) -> bool:
	return WorldState.has_flag(MELODY_PREFIX + id)


static func fragments() -> int:
	return _flags_with(FRAGMENT_PREFIX)


static func melodies() -> int:
	return _flags_with(MELODY_PREFIX)


## Curiosities carried or standing on a shelf.
static func curiosities() -> int:
	var count := 0
	for item_id: String in WorldState.state.inventory:
		if item_id.begins_with(CURIOSITY_PREFIX):
			count += 1
	for slot_id: String in WorldState.state.house.curiosity_slots:
		if str(WorldState.state.house.curiosity_slots[slot_id]).begins_with(CURIOSITY_PREFIX):
			count += 1
	return count


static func _collect(flag: String) -> bool:
	if not GameState.is_flag_id(flag):
		Log.error(Log.Category.CONTENT, "invalid collectible id", {"flag": flag})
		return false
	if WorldState.has_flag(flag):
		return false
	WorldState.set_flag(flag)
	return true


static func _flags_with(prefix: String) -> int:
	var count := 0
	for flag: String in WorldState.state.flags:
		if flag.begins_with(prefix):
			count += 1
	return count
