#!/usr/bin/env bash
# One command for all automated checks: lint, format, import, smoke run, unit tests.
# Exit code is non-zero if any step fails. Used locally, in cloud sessions and in CI.
set -euo pipefail
# shellcheck source=tools/godot_env.sh
source "$(dirname "${BASH_SOURCE[0]}")/godot_env.sh"
cd "$REPO_ROOT"

GDLINT="gdlint"
GDFORMAT="gdformat"
if [ -x .venv/bin/gdlint ]; then
  GDLINT=".venv/bin/gdlint"
  GDFORMAT=".venv/bin/gdformat"
fi

# Our own GDScript files (third-party addons are excluded on purpose).
mapfile -t GD_FILES < <(find . -name '*.gd' \
  -not -path './addons/*' -not -path './.godot/*' -not -path './.venv/*' -not -path './build/*' \
  -not -path './.claude/*' | sort)

# Godot prints these markers for script and resource problems but may still exit 0.
ERROR_PATTERN='SCRIPT ERROR|Parse Error|Failed to load script|ERROR: '
# Known exit-time report caused by Dialogue Manager keeping a resource (KNOWN_ISSUES #2).
IGNORE_PATTERN='resources still in use at exit'
has_errors() { grep -E "$ERROR_PATTERN" "$1" | grep -vEq "$IGNORE_PATTERN"; }

# Time per step (the check is a cost on every push; the table at the end shows where it goes).
STEP_NAMES=()
STEP_SECONDS=()
STEP_NAME=""
STEP_T0=$SECONDS
end_step() {
  if [ -n "$STEP_NAME" ]; then
    STEP_NAMES+=("$STEP_NAME")
    STEP_SECONDS+=($((SECONDS - STEP_T0)))
  fi
}
step() {
  end_step
  STEP_NAME="$*"
  STEP_T0=$SECONDS
  echo; echo "== $*"
}
print_timings() {
  end_step
  STEP_NAME=""
  echo
  echo "== timings (seconds)"
  local i
  for i in "${!STEP_NAMES[@]}"; do
    printf '%6d  %s\n' "${STEP_SECONDS[$i]}" "${STEP_NAMES[$i]}"
  done
  printf '%6d  total\n' "$SECONDS"
}
trap print_timings EXIT

step "gdlint (${#GD_FILES[@]} files)"
"$GDLINT" "${GD_FILES[@]}"

step "gdformat --check"
"$GDFORMAT" --check "${GD_FILES[@]}"

step "adr index"
python3 tools/adr_index.py --check

# Nobody can listen in CI: the mix is measured (loudness per sound group, steps, soundscapes,
# sound classes over the bed). Needs numpy, a dev-only dependency (requirements-art.txt).
step "audio levels"
PYTHON="python3"
[ -x .venv/bin/python ] && PYTHON=".venv/bin/python"
if "$PYTHON" -c "import numpy" >/dev/null 2>&1; then
  "$PYTHON" tools/audio/check_levels.py
else
  echo "audio levels: SKIPPED, numpy is missing (.venv/bin/pip install -r requirements-art.txt)"
fi

step "map stamps"
# Every baked ground image is as new as its map (standard library only, ADR-052).
python3 tools/art/map_stamp.py
python3 -m unittest discover -s tools/art -p 'test_*.py' -q

step "writing lint"
# Vocabulary, numbers, status tags and the ID lock of the story text; `note:` lines are to be
# worked off, `error:` lines fail (standard library only, ADR-053).
python3 tools/writing/lint.py
python3 tools/writing/motifs.py
python3 -m unittest discover -s tools/writing -p 'test_*.py' -q

step "godot import"
# Warm-up import: on a fresh checkout Godot loads the project theme before the font
# is imported and logs spurious errors. Only the second, warm import must be clean.
tools/godot.sh --headless --import >/dev/null 2>&1 || true
import_log="$(mktemp)"
tools/godot.sh --headless --import >"$import_log" 2>&1 || { cat "$import_log"; exit 1; }
if has_errors "$import_log"; then
  grep -E "$ERROR_PATTERN" "$import_log" | grep -vE "$IGNORE_PATTERN"
  echo "check: import reported errors" >&2
  exit 1
fi
echo "import ok"

# Each start target runs a few hundred frames headless and must log its ready line.
# --profile=smoke keeps saves and settings of these runs away from real ones.
# (the scene list lives in core/scene_registry.gd, SMOKE)
for target in "" $(python3 tools/scene_keys.py smoke); do
  step "smoke: ${target:-main menu}"
  smoke_log="$(mktemp)"
  args=(--headless --quit-after 240 -- --profile=smoke)
  [ -n "$target" ] && args+=("--start=$target")
  tools/godot.sh "${args[@]}" >"$smoke_log" 2>&1 || { cat "$smoke_log"; exit 1; }
  if has_errors "$smoke_log"; then
    grep -E "$ERROR_PATTERN" "$smoke_log" | grep -vE "$IGNORE_PATTERN"
    echo "check: smoke run reported errors" >&2
    exit 1
  fi
  if [ -n "$target" ] && ! grep -q "scene ready" "$smoke_log"; then
    cat "$smoke_log"
    echo "check: scene '$target' did not report ready" >&2
    exit 1
  fi
  echo "smoke ok"
done

# Loading for real: the smoke runs above autosaved; --continue must load it and
# rebuild the saved scene (scene change, position, state).
step "smoke: continue (load newest save)"
smoke_log="$(mktemp)"
tools/godot.sh --headless --quit-after 240 -- --profile=smoke --continue >"$smoke_log" 2>&1 || { cat "$smoke_log"; exit 1; }
if has_errors "$smoke_log" || ! grep -q "SAVE: loaded" "$smoke_log" || ! grep -q "scene ready" "$smoke_log"; then
  cat "$smoke_log"
  echo "check: continue did not load a save" >&2
  exit 1
fi
echo "smoke ok"

# Performance test, short: all look scenes in a row, saving blocked, report written.
step "smoke: benchmark (quick)"
smoke_log="$(mktemp)"
tools/godot.sh --headless --quit-after 20000 -- --profile=smoke --benchmark=quick --quit-after-benchmark >"$smoke_log" 2>&1 || { cat "$smoke_log"; exit 1; }
if has_errors "$smoke_log" || ! grep -q "benchmark done" "$smoke_log"; then
  cat "$smoke_log"
  echo "check: benchmark did not finish" >&2
  exit 1
fi
echo "smoke ok"

# The whole vertical slice without a hand (autopilot, instant text, fixed frame rate): every
# beat in order up to the end. Starts on a fresh profile, so "Neues Spiel" asks nothing.
step "smoke: full slice (autopilot)"
case "$(uname -s)" in
  Darwin) user_root="$HOME/Library/Application Support/REAL" ;;
  MINGW* | MSYS* | CYGWIN*) user_root="${APPDATA:-$HOME/AppData/Roaming}/REAL" ;;
  *) user_root="${XDG_DATA_HOME:-$HOME/.local/share}/REAL" ;;
esac
rm -rf "$user_root/profiles/slice_check"
smoke_log="$(mktemp)"
tools/godot.sh --headless --fixed-fps 30 --quit-after 13800 -- --profile=slice_check --text=instant \
  --autopilot=res://tools/autopilot/slice_full.json >"$smoke_log" 2>&1 || { cat "$smoke_log"; exit 1; }
rm -rf "$user_root/profiles/slice_check"
if has_errors "$smoke_log" || ! grep -q "vertical slice finished" "$smoke_log"; then
  grep -E "beat|WARN|ERROR" "$smoke_log" | tail -40
  echo "check: the slice did not reach its end" >&2
  exit 1
fi
grep -o '"beat":"[a-z_]*"' "$smoke_log" | cut -d'"' -f4 | paste -sd' ' -
echo "smoke ok"

# The segments of Act I (docs/akt1/REGIONSBRIEFE.md): each plays its own script from its own scene
# on a fresh profile and has to reach its marks. "script:scene:frames:mark mark ..."; a mark is a
# beat (the log line "beat":"<id>") or, with a dot in it, a flag that was set ("flag":"<id>","value":true).
segments=(
  "akt1_gasthaus:gasthaus:2400:inn_enter inn_fed inn_room inn_slept elysia.inn_book_signed"
  "akt1_markt:markt:2500:market_enter market_board market_bread market_board_done market_melody elysia.market_greeted"
  "akt1_spiegelhalle:spiegelhalle:1300:hall_enter hall_room_1 hall_room_2 hall_mirror perception elysia.hall_leaf_taken"
)
for segment in "${segments[@]}"; do
  IFS=: read -r name scene frames marks <<<"$segment"
  step "smoke: segment $name (autopilot)"
  rm -rf "$user_root/profiles/segment_check"
  smoke_log="$(mktemp)"
  tools/godot.sh --headless --fixed-fps 30 --quit-after "$frames" -- --profile=segment_check --text=instant \
    --start="$scene" --autopilot="res://tools/autopilot/$name.json" >"$smoke_log" 2>&1 || { cat "$smoke_log"; exit 1; }
  rm -rf "$user_root/profiles/segment_check"
  if has_errors "$smoke_log"; then
    grep -E "$ERROR_PATTERN" "$smoke_log" | grep -vE "$IGNORE_PATTERN"
    echo "check: segment $name reported errors" >&2
    exit 1
  fi
  for mark in $marks; do
    case "$mark" in
      *.*) pattern="\"flag\":\"$mark\",\"value\":true" ;;
      *) pattern="\"beat\":\"$mark\"" ;;
    esac
    if ! grep -q "$pattern" "$smoke_log"; then
      grep -E "beat|WARN|ERROR|autopilot" "$smoke_log" | tail -30
      echo "check: segment $name never reached '$mark'" >&2
      exit 1
    fi
  done
  echo "segment ok: $marks"
done

step "unit tests (GUT)"
# Fixed frame rate: game time runs as fast as the machine can step it (a day of waits in the story
# tests takes seconds, not minutes). GUT_FIXED_FPS=0 runs in real time, e.g. to hunt a timing bug.
gut_fps="${GUT_FIXED_FPS:-60}"
gut_args=()
[ "$gut_fps" != "0" ] && gut_args+=(--fixed-fps "$gut_fps")
gut_xml="$(mktemp)"
tools/godot.sh --headless "${gut_args[@]}" -s addons/gut/gut_cmdln.gd -gjunit_xml_file="$gut_xml" -gexit
python3 tools/gut_times.py "$gut_xml" 5 || true
rm -f "$gut_xml"

echo
echo "check: all green"
