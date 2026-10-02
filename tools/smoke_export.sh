#!/usr/bin/env bash
# Boots an exported Linux build headless and verifies it reached the boot screen
# with a build stamp and without script errors. Usage: tools/smoke_export.sh [binary]
set -euo pipefail
binary="${1:-build/linux/REAL.x86_64}"
[ -x "$binary" ] || { echo "smoke_export: $binary not found (run tools/export.sh linux)" >&2; exit 1; }

log="$(mktemp)"
timeout 60 "$binary" --headless --quit-after 60 -- --log-debug >"$log" 2>&1 || {
  cat "$log"
  echo "smoke_export: build exited with an error" >&2
  exit 1
}
cat "$log"
fail() { echo "smoke_export: $*" >&2; exit 1; }
grep -q "boot screen ready" "$log" || fail "boot screen was not reached"
if grep -q '"commit":"dev"' "$log"; then fail "build stamp missing (commit is 'dev')"; fi
if grep -qE "SCRIPT ERROR|ERROR: " "$log"; then fail "errors in exported build"; fi
echo "smoke_export: ok"
