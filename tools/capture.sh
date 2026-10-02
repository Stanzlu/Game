#!/usr/bin/env bash
# Renders a scene off-screen and saves PNG frames for visual review.
# Usage: tools/capture.sh [scene] [out_dir] [frames] [user args...]
#   scene   res:// path, default: the main scene ("" for default)
#   out_dir default: captures/<timestamp>
#   frames  default: 30 (at 30 fps); the last frame is copied to <out_dir>/last.png
#   user args are passed after "--", e.g. --start=sandbox --autopilot=res://tools/autopilot/walk.json
# Frames are written at window size (1280x720 = 2x the 640x360 game resolution).
# Uses Xvfb + OpenGL3 because the cloud container has no Vulkan driver.
set -euo pipefail
# shellcheck source=tools/godot_env.sh
source "$(dirname "${BASH_SOURCE[0]}")/godot_env.sh"
cd "$REPO_ROOT"

scene="${1:-}"
out_dir="${2:-captures/$(date +%Y%m%d-%H%M%S)}"
frames="${3:-30}"
shift $(( $# < 3 ? $# : 3 ))
user_args=("$@")
mkdir -p "$out_dir"
out_abs="$(cd "$out_dir" && pwd)"

args=(--rendering-driver opengl3 --audio-driver Dummy
  --fixed-fps "${CAPTURE_FPS:-30}" --write-movie "${out_abs}/frame.png" --quit-after "$frames")
[ -n "$scene" ] && args+=("$scene")
[ ${#user_args[@]} -gt 0 ] && args+=(-- "${user_args[@]}")

xvfb-run -a -s "-screen 0 1920x1080x24" tools/godot.sh "${args[@]}" >"${out_abs}/godot.log" 2>&1 || {
  cat "${out_abs}/godot.log"
  exit 1
}
last="$(find "$out_abs" -name 'frame*.png' | sort | tail -1)"
[ -n "$last" ] || { echo "capture: no frames written" >&2; cat "${out_abs}/godot.log"; exit 1; }
cp "$last" "${out_abs}/last.png"
echo "capture: $(find "$out_abs" -name 'frame*.png' | wc -l) frames, last frame: ${out_abs}/last.png"
