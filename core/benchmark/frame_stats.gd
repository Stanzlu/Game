class_name FrameStats
extends RefCounted
## Frame time statistics for the performance test: average, percentiles, worst frame and
## the share of frames slower than 60 and 30 fps. Pure and unit-tested.

const FRAME_60 := 1000.0 / 60.0
const FRAME_30 := 1000.0 / 30.0

var frames: PackedFloat32Array = []
var draw_calls := 0.0
var _draw_samples := 0


func add(frame_ms: float, draw_call_count := -1) -> void:
	frames.append(frame_ms)
	if draw_call_count >= 0:
		draw_calls += draw_call_count
		_draw_samples += 1


func percentile(p: float) -> float:
	if frames.is_empty():
		return 0.0
	var sorted := frames.duplicate()
	sorted.sort()
	var index := clampi(int(ceil(p / 100.0 * sorted.size())) - 1, 0, sorted.size() - 1)
	return sorted[index]


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
	}


## "flüssig" (p95 within a 60 fps frame), "meist flüssig" (within 40 fps) or "ruckelt".
static func verdict(stats: Dictionary) -> String:
	var p95: float = stats["p95_ms"]
	if p95 <= FRAME_60 * 1.1:
		return "BENCH_SMOOTH"
	if p95 <= 25.0:
		return "BENCH_MOSTLY"
	return "BENCH_STUTTER"
