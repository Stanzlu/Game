class_name Beat
extends RefCounted
## Marks the beats of the vertical slice (docs/PHASE4_PLAN.md) once per playthrough: sets
## the flag "beat.<id>" and logs the play time, so a playtest log shows the minutes of
## every beat (Master-Prompt §46, Pre-Implementation Review: timestamps per beat).


static func mark(id: String) -> void:
	var flag := "beat." + id
	if WorldState.has_flag(flag):
		return
	WorldState.set_flag(flag)
	var seconds := WorldState.state.playtime_seconds
	Log.info(
		Log.Category.WORLD_STATE,
		"beat",
		{"beat": id, "minute": snappedf(seconds / 60.0, 0.1), "seconds": roundi(seconds)}
	)


static func reached(id: String) -> bool:
	return WorldState.has_flag("beat." + id)
