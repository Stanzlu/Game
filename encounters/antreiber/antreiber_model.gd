class_name AntreiberModel
extends RefCounted
## Rules of "Der Weg, der nicht endet" (pure, unit-tested; concept E3 in the review).
##
## Moving makes the goal recede: the faster, the further. Sprinting builds fatigue that
## lowers the top speed (no HP, no failure). Standing still without movement input for
## `stillness_seconds`, or half as long while sitting, resolves the encounter, but only
## after the player has actually tried the race (`is_engaged`): far enough, and either
## hurried or kept at it a while. Stillness before that does not count (ADR-015).

signal resolved

enum Phase { RUNNING, RESOLVED }
enum Mood { START, URGING, CHEERING, TIRED, WORRIED, PUZZLED, PUZZLED_EARLY, SILENT }

## Goal recedes by this many pixels per pixel walked / sprinted.
const WALK_RECEDE := 1.15
const SPRINT_RECEDE := 1.6
const MIN_GOAL_DISTANCE := 96.0
const FATIGUE_PER_SECOND := 0.06
const RECOVERY_PER_SECOND := 0.25
const MAX_SLOWDOWN := 0.45
## Distance the player has to cover before stopping can resolve it (three segments)...
const ENGAGE_DISTANCE := 960.0
## ...and they must have hurried (sprinted this long) or kept going this long (seconds).
const ENGAGE_SPRINT_SECONDS := 2.0
const ENGAGE_SECONDS := 40.0

var phase := Phase.RUNNING
var goal_distance := 200.0
## Seconds without movement input (for his moods).
var stillness := 0.0
## The part of it that counts: stillness since the race was engaged.
var counted_stillness := 0.0
var fatigue := 0.0
var stillness_seconds := 3.0
## Accessibility: < 1 slows the receding goal and fatigue (encounter speed).
var encounter_speed := 1.0
var elapsed := 0.0
var distance_walked := 0.0
var sprint_seconds := 0.0
var max_fatigue := 0.0


func update(delta: float, moved: float, input_active: bool, sprinting: bool, sitting: bool) -> void:
	if phase == Phase.RESOLVED:
		return
	elapsed += delta
	distance_walked += moved
	stillness = 0.0 if input_active else stillness + delta
	var recede := SPRINT_RECEDE if sprinting else WALK_RECEDE
	goal_distance = maxf(
		goal_distance + moved * (recede - 1.0) * encounter_speed, MIN_GOAL_DISTANCE
	)
	if sprinting and moved > 0.0:
		sprint_seconds += delta
		fatigue = minf(fatigue + FATIGUE_PER_SECOND * encounter_speed * delta, 1.0)
	else:
		fatigue = maxf(fatigue - RECOVERY_PER_SECOND * delta, 0.0)
	max_fatigue = maxf(max_fatigue, fatigue)
	var still := not input_active and is_engaged()
	counted_stillness = counted_stillness + delta if still else 0.0
	var needed := stillness_seconds * (0.5 if sitting else 1.0)
	if counted_stillness >= needed:
		phase = Phase.RESOLVED
		resolved.emit()


## The player has really tried the race: covered the distance, and hurried or kept at it.
## Before that, stopping is only a pause (one would otherwise solve it by chance).
func is_engaged() -> bool:
	return (
		distance_walked >= ENGAGE_DISTANCE
		and (sprint_seconds >= ENGAGE_SPRINT_SECONDS or elapsed >= ENGAGE_SECONDS)
	)


## Multiplier for the player's speed (fatigue makes running less effective).
func speed_scale() -> float:
	return 1.0 - MAX_SLOWDOWN * fatigue


func is_resolved() -> bool:
	return phase == Phase.RESOLVED


## What the Antreiber is likely to say right now.
func mood(speed: float, walk_speed: float) -> Mood:
	var result := Mood.URGING
	if phase == Phase.RESOLVED:
		result = Mood.SILENT
	elif elapsed < 1.5:
		result = Mood.START
	elif stillness > 1.2:
		result = Mood.PUZZLED if is_engaged() else Mood.PUZZLED_EARLY
	elif speed < walk_speed * 0.5:
		result = Mood.WORRIED
	elif fatigue > 0.5:
		result = Mood.TIRED
	elif speed > walk_speed * 1.2:
		result = Mood.CHEERING
	return result


func stats() -> Dictionary:
	return {
		"seconds": snappedf(elapsed, 0.1),
		"distance_px": roundi(distance_walked),
		"sprint_seconds": snappedf(sprint_seconds, 0.1),
		"max_fatigue": snappedf(max_fatigue, 0.01),
	}
