#!/usr/bin/env bash
# Boots an exported Linux build headless and verifies it reached the boot screen
# with a build stamp and without script errors. Usage: tools/smoke_export.sh [binary]
set -euo pipefail
binary="${1:-build/linux/REAL.x86_64}"
[ -x "$binary" ] || { echo "smoke_export: $binary not found (run tools/export.sh linux)" >&2; exit 1; }

fail() { echo "smoke_export: $*" >&2; exit 1; }

# Boots the menu and each start target; every run must reach its ready line cleanly.
for target in "" sandbox antreiber look_elysia look_tal look_wald; do
  log="$(mktemp)"
  args=(--headless --quit-after 240 -- --log-debug --profile=smoke)
  [ -n "$target" ] && args+=("--start=$target")
  timeout 60 "$binary" "${args[@]}" >"$log" 2>&1 || { cat "$log"; fail "build exited with an error (${target:-menu})"; }
  grep -q "boot screen ready" "$log" || { cat "$log"; fail "boot screen was not reached"; }
  if grep -q '"commit":"dev"' "$log"; then fail "build stamp missing (commit is 'dev')"; fi
  if [ -n "$target" ] && ! grep -q "scene ready" "$log"; then cat "$log"; fail "scene '$target' not ready"; fi
  if grep -E "SCRIPT ERROR|ERROR: " "$log" | grep -vqE "resources still in use at exit"; then
    cat "$log"; fail "errors in exported build (${target:-menu})"
  fi
  echo "smoke_export: ${target:-menu} ok"
done

# Typed content must be present in the build, and a save from the runs above must load.
log="$(mktemp)"
timeout 60 "$binary" --headless --quit-after 240 -- --log-debug --profile=smoke --continue >"$log" 2>&1 \
  || { cat "$log"; fail "build exited with an error (continue)"; }
grep -qE '"items":[1-9][0-9]*,"quests":[1-9]' "$log" || { cat "$log"; fail "quests or items missing in the build"; }
grep -q "SAVE: loaded" "$log" || { cat "$log"; fail "continue did not load a save"; }
grep -q "scene ready" "$log" || { cat "$log"; fail "loaded scene not ready"; }
echo "smoke_export: content and continue ok"
