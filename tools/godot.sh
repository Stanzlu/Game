#!/usr/bin/env bash
# Runs the pinned Godot binary with the repository as project path.
# Example: tools/godot.sh --headless --import
set -euo pipefail
# shellcheck source=tools/godot_env.sh
source "$(dirname "${BASH_SOURCE[0]}")/godot_env.sh"

if [ ! -x "$GODOT_BIN" ]; then
  echo "godot: Godot ${GODOT_TAG} not found at $GODOT_BIN" >&2
  echo "godot: run tools/setup_godot.sh first (or set GODOT_BIN)" >&2
  exit 1
fi
exec "$GODOT_BIN" --path "$REPO_ROOT" "$@"
