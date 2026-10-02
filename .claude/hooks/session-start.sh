#!/bin/bash
# SessionStart hook for Claude Code cloud sessions: makes tools/check.sh work immediately.
# Installs the pinned Godot editor (SHA512-verified), gdtoolkit in .venv, and warms the
# Godot import cache. Export templates (~470 MB) are NOT installed here; run
# `tools/setup_godot.sh --templates` when a build is needed.
set -euo pipefail

if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

cd "${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/../.." && pwd)}"

tools/setup_godot.sh

if [ ! -x .venv/bin/gdlint ]; then
  python3 -m venv .venv
  .venv/bin/pip install --quiet --disable-pip-version-check -r requirements-dev.txt
fi

# Warm-up import builds .godot/ (class cache, imported fonts) so the first check is fast.
tools/godot.sh --headless --import >/dev/null 2>&1 || true

if [ -n "${CLAUDE_ENV_FILE:-}" ]; then
  echo "export PATH=\"$PWD/.venv/bin:\$PATH\"" >> "$CLAUDE_ENV_FILE"
fi

echo "session-start: Godot $(tools/godot.sh --version | tail -1), gdtoolkit $(.venv/bin/gdlint --version)"
