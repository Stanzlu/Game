class_name FrameStats
extends RefCounted
## Frame time statistics for the performance test: average, percentiles, worst frame and
## the share of frames slower than 60 and 30 fps. Pure and unit-tested.

const FRAME_60 := 1000.0 / 60.0
const FRAME_30 := 1000.0 / 30.0

var frames: PackedFloat32Array = []
var draw_calls := 0.0
var _draw_samples := 0
var _cpu_ms := 0.0
var _gpu_ms := 0.0
var _timing_samples := 0


func add(frame_ms: float, draw_call_count := -1) -> void:
	frames.append(frame_ms)
	if draw_call_count >= 0:
		draw_calls += draw_call_count
		_draw_samples += 1


## CPU time of the frame (game logic plus render setup) and GPU time, in ms.
func add_timing(cpu_ms: float, gpu_ms: float) -> void:
	_cpu_ms += cpu_ms
	_gpu_ms += gpu_ms
	_timing_samples += 1


func percentile(p: float) -> float:
	if frames.is_empty():
		return 0.0
	var sorted := frames.duplicate()
	sorted.sort()
	var index := clampi(int(ceil(p / 100.0 * sorted.size())) - 1, 0, sorted.size() - 1)
	return sorted[index]


## Frames per second over the run, one value per full second: a slow scene that is slow
## throughout looks different from one that recovers after a few seconds (a clock that ramps
## up), and the average hides the difference.
func timeline() -> PackedFloat32Array:
	var result := PackedFloat32Array()
	var elapsed := 0.0
	var count := 0
	for frame_ms: float in frames:
		elapsed += frame_ms
		count += 1
		if elapsed >= 1000.0:
			result.append(count * 1000.0 / elapsed)
			elapsed = 0.0
			count = 0
	return result


func summary() -> Dictionary:
	var total := 0.0
	var worst := 0.0
	var over_60 := 0
	var over_30 := 0
	for f in frames:
		total += f
		worst = maxf(worst, f)
		# a little tolerance: vsync timing jitters around 16.67 ms
		over_60 += int(f > FRAME_60 * 1.1)
		over_30 += int(f > FRAME_30 * 1.1)
	var count := maxi(frames.size(), 1)
	var avg := total / count
	return {
		"frames": frames.size(),
		"avg_fps": 1000.0 / avg if avg > 0.0 else 0.0,
		"avg_ms": avg,
		"p95_ms": percentile(95.0),
		"p99_ms": percentile(99.0),
		"max_ms": worst,
		"slow_60": 100.0 * over_60 / count,
		"slow_30": 100.0 * over_30 / count,
		"draw_calls": draw_calls / maxi(_draw_samples, 1),
		"cpu_ms": _cpu_ms / _timing_samples if _timing_samples > 0 else -1.0,
		"gpu_ms": _gpu_ms / _timing_samples if _timing_samples > 0 else -1.0,
	}


## "flüssig" (p95 within a 60 fps frame), "meist flüssig" (within 40 fps) or "ruckelt".
## With the uncapped measurement (`raw`): "auf 30 begrenzt" when the machine could do far
## more but something (VSync in macOS Low Power Mode) holds it at a steady 30.
static func verdict(stats: Dictionary, raw: Dictionary = {}, refresh_hz := 0.0) -> String:
	if capped_at_30(stats, raw):
		return "BENCH_CAPPED"
	if held_by_vsync(stats, raw, refresh_hz):
		return "BENCH_VSYNC"
	var p95: float = stats["p95_ms"]
	if p95 <= FRAME_60 * 1.1:
		return "BENCH_SMOOTH"
	if p95 <= 25.0:
		return "BENCH_MOSTLY"
	return "BENCH_STUTTER"


## The scene runs at least one and a half times the screen's refresh rate without VSync but
## stays clearly under it with VSync (playtest 23.10.: a MacBook with a 120 Hz screen gave
## 58 to 76 fps with VSync and 184 to 474 without): the synchronisation costs the frames, not
## the scene. `refresh_hz` <= 0 (unknown, headless) never says so.
static func held_by_vsync(stats: Dictionary, raw: Dictionary, refresh_hz: float) -> bool:
	if raw.is_empty() or refresh_hz <= 0.0:
		return false
	return float(raw["avg_fps"]) >= refresh_hz * 1.5 and float(stats["avg_fps"]) < refresh_hz * 0.85


## A steady ~30 fps while the same scene runs well above 60 without VSync.
static func capped_at_30(stats: Dictionary, raw: Dictionary) -> bool:
	if raw.is_empty():
		return false
	var played: float = stats["avg_fps"]
	return float(raw["avg_fps"]) >= 66.0 and played >= 27.0 and played <= 33.0
