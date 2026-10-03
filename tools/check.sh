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
if grep -Eq "$ERROR_PATTERN" "$import_log"; then
  grep -E "$ERROR_PATTERN" "$import_log"
  echo "check: import reported errors" >&2
  exit 1
fi
echo "import ok"

step "smoke: run main scene headless"
smoke_log="$(mktemp)"
tools/godot.sh --headless --quit-after 120 >"$smoke_log" 2>&1 || { cat "$smoke_log"; exit 1; }
if grep -Eq "$ERROR_PATTERN" "$smoke_log"; then
  grep -E "$ERROR_PATTERN" "$smoke_log"
  echo "check: main scene reported errors" >&2
  exit 1
fi
echo "smoke ok"

step "unit tests (GUT)"
tools/godot.sh --headless -s addons/gut/gut_cmdln.gd -gexit

echo
echo "check: all green"
