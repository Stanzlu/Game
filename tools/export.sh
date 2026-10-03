#!/usr/bin/env bash
# Exports a release build. Usage: tools/export.sh windows|macos|linux
# Needs export templates: tools/setup_godot.sh --templates
# Writes core/build_info.cfg (git commit + date) so the build can show where it came from.
set -euo pipefail
# shellcheck source=tools/godot_env.sh
source "$(dirname "${BASH_SOURCE[0]}")/godot_env.sh"
cd "$REPO_ROOT"

target="${1:-}"
case "$target" in
  windows) preset="Windows"; out="build/windows/REAL.exe" ;;
  macos) preset="macOS"; out="build/macos/REAL.zip" ;;
  linux) preset="Linux"; out="build/linux/REAL.x86_64" ;;
  *) echo "Usage: tools/export.sh windows|macos|linux" >&2; exit 2 ;;
esac

if [ ! -f "${GODOT_TEMPLATES_DIR}/version.txt" ]; then
  echo "export: templates missing, run tools/setup_godot.sh --templates" >&2
  exit 1
fi

commit="$(git rev-parse --short HEAD 2>/dev/null || echo unknown)"
if [ -n "$(git status --porcelain --untracked-files=no 2>/dev/null)" ]; then
  commit="${commit}+dirty"
fi
# The stamp is only for the exported build; remove it afterwards so dev runs show "dev".
trap 'rm -f core/build_info.cfg' EXIT
cat > core/build_info.cfg <<CFG
[build]
commit="${commit}"
date="$(date -u +%Y-%m-%d)"
CFG

rm -rf "$(dirname "$out")"
mkdir -p "$(dirname "$out")"
touch build/.gdignore
tools/godot.sh --headless --import >/dev/null 2>&1
tools/godot.sh --headless --export-release "$preset" "$out"
[ -s "$out" ] || { echo "export: no output produced at $out" >&2; exit 1; }
echo "export: $out ($(du -h "$out" | cut -f1))"
