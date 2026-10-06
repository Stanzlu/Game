class_name QuestDef
extends Resource
## A quest as content: ordered stages, the first one is where it starts. Stored as
## content/quests/<id>.tres. Stage changes only through WorldState.advance_quest(), which
## allows exactly the transitions listed in `next`. Checked by ContentValidator.
##
## Journal texts come from translations with derived keys (content/locale/journal.csv):
## QUEST_<ID>_TITLE, QUEST_<ID>_<STAGE> and QUEST_<ID>_OBJ_<OBJECTIVE>, all upper case.

enum Kind { MAIN, SIDE }

@export var id := ""
@export var kind := Kind.SIDE
@export var stages: Array[QuestStageDef] = []
## Draft content with placeholder text. Must be false before a playtest build.
@export var draft := true


func first_stage() -> QuestStageDef:
	return stages[0] if not stages.is_empty() else null


func stage(stage_id: String) -> QuestStageDef:
	for s in stages:
		if s.id == stage_id:
			return s
	return null


func has_stage(stage_id: String) -> bool:
	return stage(stage_id) != null


func has_objective(objective_id: String) -> bool:
	for s in stages:
		if s != null and objective_id in s.objectives:
			return true
	return false


func can_advance(from_stage: String, to_stage: String) -> bool:
	var current := stage(from_stage)
	return current != null and to_stage in current.next and has_stage(to_stage)


func title_key() -> String:
	return "QUEST_%s_TITLE" % id.to_upper()


func stage_key(stage_id: String) -> String:
	return "QUEST_%s_%s" % [id.to_upper(), stage_id.to_upper()]


func objective_key(objective_id: String) -> String:
	return "QUEST_%s_OBJ_%s" % [id.to_upper(), objective_id.to_upper()]
