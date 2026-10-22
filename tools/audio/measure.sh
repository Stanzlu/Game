#!/usr/bin/env bash
# Records the game's sound (Xvfb + OpenGL3 + movie writer, fixed 30 fps: game time stays
# right) and prints the loudness per second. Nobody can listen in CI, so this is how a mix
# change is checked. Needs Xvfb, ffmpeg and numpy (.venv).
# Usage: tools/audio/measure.sh <label> <frames> [--script res://tools/audio/bed_probe.gd]
#                               [--autopilot <json>] [-- game args, e.g. --start=tal]
# Output: captures/audio/<label>/frame.wav; with --autopilot the events are printed beside.
set -euo pipefail
# shellcheck source=tools/godot_env.sh
source "$(dirname "${BASH_SOURCE[0]}")/../godot_env.sh"
cd "$REPO_ROOT"

label="$1"; frames="$2"; shift 2
script=""; autopilot=""
while [ $# -gt 0 ]; do
  case "$1" in
    --script) script="$2"; shift 2 ;;
    --autopilot) autopilot="$2"; shift 2 ;;
    --) shift; break ;;
    *) break ;;
  esac
done
out="captures/audio/$label"
mkdir -p "$out" captures && touch captures/.gdignore
rm -f "$out/movie.avi" "$out/frame.wav"
args=(--rendering-driver opengl3 --audio-driver Dummy --fixed-fps 30 --resolution 640x360
  --write-movie "$out/movie.avi" --quit-after "$frames")
[ -n "$script" ] && args+=(-s "$script")
args+=(-- "--profile=measure_$label" --text=instant)
[ -n "$autopilot" ] && args+=("--autopilot=$autopilot")
args+=("$@")
xvfb-run -a -s "-screen 0 1920x1080x24" tools/godot.sh "${args[@]}" >"$out/godot.log" 2>&1 || { tail -20 "$out/godot.log"; exit 1; }
ffmpeg -loglevel error -y -i "$out/movie.avi" -vn -acodec pcm_s16le "$out/frame.wav"
rm -f "$out/movie.avi"
PYTHON=".venv/bin/python"; [ -x "$PYTHON" ] || PYTHON="python3"
if [ -n "$script" ]; then
  "$PYTHON" tools/audio/timeline.py "$out/frame.wav" - --segments 36 4
else
  "$PYTHON" tools/audio/timeline.py "$out/frame.wav" "${autopilot:--}"
fi
