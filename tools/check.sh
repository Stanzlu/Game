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
  | sort)

# Godot prints these markers for script and resource problems but may still exit 0.
ERROR_PATTERN='SCRIPT ERROR|Parse Error|Failed to load script|ERROR: '
# Known exit-time report caused by Dialogue Manager keeping a resource (KNOWN_ISSUES #2).
IGNORE_PATTERN='resources still in use at exit'
has_errors() { grep -E "$ERROR_PATTERN" "$1" | grep -vEq "$IGNORE_PATTERN"; }

step() { echo; echo "== $*"; }

step "gdlint (${#GD_FILES[@]} files)"
"$GDLINT" "${GD_FILES[@]}"

step "gdformat --check"
"$GDFORMAT" --check "${GD_FILES[@]}"

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
for target in "" sandbox antreiber look_elysia look_tal look_wald; do
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

step "unit tests (GUT)"
tools/godot.sh --headless -s addons/gut/gut_cmdln.gd -gexit

echo
echo "check: all green"
