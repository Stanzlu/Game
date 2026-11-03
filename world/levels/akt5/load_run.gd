class_name LoadRun
extends Node
## The keeper's load (Act V, G4; docs/akt5/REGIONSBRIEFE.md, O4): a run of the levers at the
## console. A lever that is down springs up after its period and then asks to be pulled again;
## there are four waves with three, six, nine and twelve levers in use and shorter periods with
## each. The last wave cannot be kept by anyone (`possible()` says so for every setting of "more
## time" and "pace of encounters", a test counts it): the run does not end in a failure, it ends
## when the fourth wave has run its time, and nothing is locked. Whoever leaves the console is
## waited for. The levers show what is open (up = asks to be pulled, down = held); everything else
## is the scene's business: it reads `trouble()` for the dials, the steam and the lamps and plays
## the keeper's lines at the signals. Time is play time only: `step(delta, ...)` is driven by the
## scene's physics process.

signal wave_began(wave: int)
signal waited
signal returned
signal overloaded

enum State { IDLE, RUNNING, OVER }

## Per wave: how many levers are in use, the seconds a pulled lever holds at normal pace, how long
## the wave lasts at normal pace.
const WAVES: Array[Dictionary] = [
	{"levers": 3, "period": 14.0, "seconds": 40.0},
	{"levers": 6, "period": 9.0, "seconds": 40.0},
	{"levers": 9, "period": 5.0, "seconds": 30.0},
	{"levers": 12, "period": 1.0, "seconds": 24.0},
]
## The least time one hand needs for one pull (a step along the console and the press): a bound
## that no play beats, so a demand above `hand_rate()` is impossible for anyone.
const HAND_SECONDS := 0.45
## Seconds at the console's back before the run waits for her (at normal pace).
const AWAY_SECONDS := 3.0

var state := State.IDLE
var wave := 1
## The levers of the hall by number; the scene sets it before the run begins.
var levers: Dictionary = {}

var _wave_time := 0.0
var _holds: Dictionary = {}
var _away := 0.0
var _waiting := false
var _armed := false


## How far the periods and the waves are stretched by the settings: "more time" and the calmer
## paces multiply, at most four times.
static func stretch() -> float:
	return Settings.timing_factor() / Settings.encounter_speed()


static func levers_in(wave_number: int) -> int:
	return int(WAVES[clampi(wave_number, 1, WAVES.size()) - 1]["levers"])


## The seconds a pulled lever holds in this wave, at this stretch.
static func period(wave_number: int, stretched: float) -> float:
	return float(WAVES[clampi(wave_number, 1, WAVES.size()) - 1]["period"]) * stretched


## The seconds the wave lasts (only "more time" stretches it, the pace of the encounter does not).
static func wave_seconds(wave_number: int) -> float:
	return (
		float(WAVES[clampi(wave_number, 1, WAVES.size()) - 1]["seconds"]) * Settings.timing_factor()
	)


## Pulls per second that the levers of the wave ask for.
static func demand(wave_number: int, stretched: float) -> float:
	return levers_in(wave_number) / period(wave_number, stretched)


## Pulls per second the best hand can give.
static func hand_rate() -> float:
	return 1.0 / HAND_SECONDS


static func possible(wave_number: int, stretched: float) -> bool:
	return demand(wave_number, stretched) <= hand_rate()


## The run begins at this wave; `armed` false waits for her at the console first (a game loaded in
## the middle of the load does not start without her).
func begin(first_wave := 1, armed := true) -> void:
	wave = first_wave
	state = State.RUNNING
	_wave_time = 0.0
	_away = 0.0
	_waiting = false
	_armed = armed
	_holds.clear()
	_use_levers_up_to(levers_in(wave))
	for number: int in levers:
		var lever := levers[number] as ConsoleLever
		if lever.active and lever.down:
			_holds[number] = period(wave, stretch())


## Held for the rest of the wave: a lever that is down springs up again after its period.
func pull(number: int) -> void:
	if state != State.RUNNING:
		return
	var lever := levers.get(number) as ConsoleLever
	if lever == null or not lever.active or lever.down:
		return
	lever.set_down(true, true)
	_holds[number] = period(wave, stretch())


## The levers in use that stand up, asking to be pulled.
func open_count() -> int:
	var open := 0
	for number: int in levers:
		var lever := levers[number] as ConsoleLever
		if lever.active and not lever.down:
			open += 1
	return open


## How much of the load is not kept, 0 to 1.
func trouble() -> float:
	var used := levers_in(wave)
	return clampf(float(open_count()) / float(used), 0.0, 1.0) if state != State.IDLE else 0.0


func is_waiting() -> bool:
	return _waiting


## One tick of play time. `at_console`: she stands at the console; `talking`: a conversation is
## open (the run stands still while anyone speaks).
func step(delta: float, at_console: bool, talking: bool) -> void:
	if state != State.RUNNING or talking:
		return
	if at_console:
		_armed = true
		_away = 0.0
		if _waiting:
			_waiting = false
			returned.emit()
	elif _armed:
		_away += delta
		if _away >= AWAY_SECONDS * Settings.timing_factor() and not _waiting:
			_waiting = true
			waited.emit()
	if _waiting or not _armed:
		return
	_wave_time += delta
	for number: int in _holds.keys():
		_holds[number] = float(_holds[number]) - delta
		if _holds[number] <= 0.0:
			_holds.erase(number)
			(levers[number] as ConsoleLever).set_down(false, true)
	if _wave_time >= wave_seconds(wave):
		_next_wave()


func _next_wave() -> void:
	_wave_time = 0.0
	if wave >= WAVES.size():
		state = State.OVER
		overloaded.emit()
		return
	wave += 1
	_use_levers_up_to(levers_in(wave))
	wave_began.emit(wave)


## The levers up to this number are in use; the ones that were not stand up and ask.
func _use_levers_up_to(count: int) -> void:
	for number: int in levers:
		var lever := levers[number] as ConsoleLever
		if number <= count and not lever.active:
			lever.set_active(true)
			lever.set_down(false)
