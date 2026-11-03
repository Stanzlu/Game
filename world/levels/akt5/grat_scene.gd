class_name GratScene
extends LookScene
## Act V, G2: the high valley (docs/akt5/REGIONSBRIEFE.md). A valley between walls, a tarn, meadows,
## scree, a marmot's slope, three cairns, and in the east the Anlage whose smoke was seen from the
## pass. Things to look at, nothing speaks, nobody is here. Everything on the map lives in props
## with `if`/`unless` and in the dialogue; this script starts and ends the two quests that belong to
## the valley (the hero's walk takes its next step on arrival, the stone that will not stay lies
## down once all three cairns have been tried) and marks the beats. No cutscene, no lock.

const QUEST := "main_mountain_way"
const STONE_QUEST := "side_grat_stone"


func _ready() -> void:
	super()
	WorldState.flag_changed.connect(_on_flag_changed)
	# the walk goes on in the valley (a game begun in this scene has the walk too)
	if not WorldState.is_quest_started(QUEST):
		WorldState.start_quest(QUEST)
	if WorldState.quest_stage(QUEST) == "climb":
		WorldState.advance_quest(QUEST, "valley")
	_sync_stone_quest()
	Beat.mark("grat_enter")


func _on_flag_changed(id: String, value: bool) -> void:
	if not value:
		return
	if id == "fragment.hand":
		Beat.mark("grat_hand")
	elif id.begins_with("grat.stone_"):
		_sync_stone_quest()


## The stone's quest follows the flags: it begins with the stone in the pocket and ends with the
## third cairn that would not keep it. A flag set before the quest was there (a loaded game) is
## caught up here.
func _sync_stone_quest() -> void:
	if not WorldState.has_flag("grat.stone_taken"):
		return
	if not WorldState.is_quest_started(STONE_QUEST):
		WorldState.start_quest(STONE_QUEST)
	if _all_tries_made() and WorldState.is_quest_active(STONE_QUEST):
		WorldState.advance_quest(STONE_QUEST, "done")


## The flags are written out (StoryLint reads literals, not lists).
func _all_tries_made() -> bool:
	return (
		WorldState.has_flag("grat.stone_try_1")
		and WorldState.has_flag("grat.stone_try_2")
		and WorldState.has_flag("grat.stone_try_3")
	)
