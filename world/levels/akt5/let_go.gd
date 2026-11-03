class_name LetGo
extends Node
## The keeper's load, the way out (Act V, G5; docs/akt5/REGIONSBRIEFE.md, O4, O10): the load has
## stopped (G4) and every lever stands up and asks. Whoever steps away from the console and waits
## has done what the procedure has no step for. The levers then go down by themselves, one after
## the other, in the order of the trial (Three, One, Two) and then Four to Twelve: a bar of
## clicks. Half way something goes wrong (a burst of steam), a little later a lamp goes out and
## nobody mends it, and when the last lever has gone down the hall settles. Nothing needs her
## hand; the only thing asked of her is that she is not at the console while it happens.
## Time is play time only: `step(delta, away, talking)` is driven by the scene's physics process,
## the clock stands still while anyone speaks and while she stands at the console.

## She has stepped away: the first time, before anything falls.
signal began
## A lever goes down by itself (`number`: the lever, `index`: its place in the order, from zero).
signal fell(number: int, index: int)
## Something goes wrong in the hall: the burst of steam.
signal mid
## A lamp goes out and stays out.
signal defect
## The hall has settled.
signal finished

enum State { IDLE, RUNNING, DONE }

## The order the levers go down: the trial's order first (the keeper called it in G3).
const ORDER: Array[int] = [3, 1, 2, 4, 5, 6, 7, 8, 9, 10, 11, 12]
## Seconds from the first step away to the first lever, and between two levers.
const FIRST_FALL := 2.0
const FALL_EVERY := 1.6
## Seconds from the last lever to the end (the hall settles; the dials follow the levers).
const SETTLE := 6.0
## The places in the order at which something goes wrong (the sixth lever, the ninth).
const MID_INDEX := 5
const DEFECT_INDEX := 8

var state := State.IDLE
## Seconds of play time she has spent away from the console since it began.
var elapsed := 0.0
## The levers that went down by themselves so far.
var fallen := 0

var _next := 0
var _events: Array[Dictionary] = []


func _init() -> void:
	_events = _schedule()


## Every event of the whole time, in order: {"t", "kind" ("fall", "mid", "defect", "end"), "index"}.
static func _schedule() -> Array[Dictionary]:
	var list: Array[Dictionary] = []
	for i in ORDER.size():
		var at := FIRST_FALL + FALL_EVERY * i
		list.append({"t": at, "kind": "fall", "index": i})
		if i == MID_INDEX:
			list.append({"t": at, "kind": "mid", "index": i})
		if i == DEFECT_INDEX:
			list.append({"t": at, "kind": "defect", "index": i})
	list.append({"t": seconds(), "kind": "end", "index": ORDER.size()})
	return list


## The whole time she has to be away (the last lever plus the settling).
static func seconds() -> float:
	return FIRST_FALL + FALL_EVERY * (ORDER.size() - 1) + SETTLE


## The time of the n-th lever (from zero).
static func fall_time(index: int) -> float:
	return FIRST_FALL + FALL_EVERY * index


## She stepped away from the console after the load stopped. Once.
func begin() -> void:
	if state != State.IDLE:
		return
	state = State.RUNNING
	began.emit()


## One tick of play time. `away`: she is not at the console; `talking`: a conversation is open.
func step(delta: float, away: bool, talking: bool) -> void:
	if state != State.RUNNING or not away or talking:
		return
	elapsed += delta
	# one event per tick: the scene may start to speak at it, and then the clock stands still
	if _next >= _events.size() or elapsed < float(_events[_next]["t"]):
		return
	var event := _events[_next]
	_next += 1
	match str(event["kind"]):
		"fall":
			fallen += 1
			fell.emit(ORDER[int(event["index"])], int(event["index"]))
		"mid":
			mid.emit()
		"defect":
			defect.emit()
		"end":
			state = State.DONE
			finished.emit()


## A loaded game, or one that was already through: no events are left.
func finish_silently() -> void:
	state = State.DONE
	_next = _events.size()
	fallen = ORDER.size()
	elapsed = seconds()
