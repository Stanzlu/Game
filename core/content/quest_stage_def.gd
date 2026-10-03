class_name QuestStageDef
extends Resource
## One stage of a quest. Journal text keys are derived from the quest and stage IDs
## (see QuestDef). A stage without `next` ends the quest with its `outcome`.

@export var id := ""
## Objective IDs listed under the stage text (optional, checked off independently).
@export var objectives: PackedStringArray = []
## Stage IDs that may follow this one. Empty: the quest ends here.
@export var next: PackedStringArray = []
## Outcome ID of a final stage, e.g. "done" or "missed". Different outcomes are not failures.
@export var outcome := ""


func is_final() -> bool:
	return next.is_empty()
