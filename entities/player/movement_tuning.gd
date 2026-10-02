class_name MovementTuning
extends Resource
## Feel parameters for top-down movement. Presets live in entities/player/tuning/.
## Speeds in pixels per second (16 px = 1 tile), rates in pixels per second².

@export var display_key := "TUNING_DIREKT"
@export var walk_speed := 84.0
@export var run_speed := 140.0
@export var acceleration := 1200.0
@export var deceleration := 1600.0
## Used when the new target points against the current motion (quick turnarounds).
@export var turn_acceleration := 2400.0
## Speed fraction at the smallest analog tilt above the deadzone.
@export_range(0.1, 1.0) var slow_walk_factor := 0.4
## Minimum stick tilt for sprinting.
@export_range(0.0, 1.0) var sprint_min_tilt := 0.5
@export var step_distance_walk := 14.0
@export var step_distance_run := 20.0
## How far the player is nudged sideways around a corner they barely clip.
@export_range(0, 8) var corner_nudge_px := 4
