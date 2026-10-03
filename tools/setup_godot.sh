#!/usr/bin/env bash
# Downloads the pinned Godot editor for Linux and verifies it against the official
# SHA512-SUMS.txt. With --templates it also installs the export templates
# (Windows, macOS, Linux only). Idempotent: does nothing if already present.
set -euo pipefail
# shellcheck source=tools/godot_env.sh
source "$(dirname "${BASH_SOURCE[0]}")/godot_env.sh"

usage() {
  echo "Usage: tools/setup_godot.sh [--templates] [--quiet]"
}

want_templates=0
quiet=0
for arg in "$@"; do
  case "$arg" in
    --templates) want_templates=1 ;;
    --quiet) quiet=1 ;;
    -h | --help) usage; exit 0 ;;
    *) echo "setup_godot: unknown argument '$arg'" >&2; usage >&2; exit 2 ;;
  esac
done

log() { [ "$quiet" -eq 1 ] || echo "setup_godot: $*"; }
die() { echo "setup_godot: ERROR: $*" >&2; exit 1; }

fetch() {
  local url="$1" out="$2"
  curl -fsSL --retry 4 --retry-delay 2 -o "${out}.part" "$url" || die "download failed: $url"
  mv "${out}.part" "$out"
}

sums_file="${GODOT_CACHE_DIR}/SHA512-SUMS.txt"

verify() {
  local file="$1" name="$2" expected actual
  expected="$(awk -v n="$name" '$2 == n { print $1 }' "$sums_file")"
  [ -n "$expected" ] || die "no checksum for $name in SHA512-SUMS.txt"
  actual="$(sha512sum "$file" | awk '{ print $1 }')"
  [ "$expected" = "$actual" ] || die "checksum mismatch for $name"
  log "checksum ok: $name"
}

mkdir -p "$GODOT_CACHE_DIR"
[ -s "$sums_file" ] || fetch "${GODOT_RELEASE_URL}/SHA512-SUMS.txt" "$sums_file"

if [ -x "$GODOT_BIN" ]; then
  log "editor present: $GODOT_BIN"
else
  archive="${GODOT_CACHE_DIR}/${GODOT_ARCHIVE}"
  log "downloading ${GODOT_ARCHIVE}"
  fetch "${GODOT_RELEASE_URL}/${GODOT_ARCHIVE}" "$archive"
  verify "$archive" "$GODOT_ARCHIVE"
  python3 -m zipfile -e "$archive" "$GODOT_CACHE_DIR"
  chmod +x "${GODOT_CACHE_DIR}/${GODOT_BIN_NAME}"
  rm -f "$archive"
  log "editor installed: ${GODOT_CACHE_DIR}/${GODOT_BIN_NAME}"
fi

if [ "$want_templates" -eq 1 ]; then
  if [ -f "${GODOT_TEMPLATES_DIR}/version.txt" ]; then
    log "export templates present: $GODOT_TEMPLATES_DIR"
  else
    tpz="${GODOT_CACHE_DIR}/${GODOT_TEMPLATES_ARCHIVE}"
    log "downloading ${GODOT_TEMPLATES_ARCHIVE} (large)"
    fetch "${GODOT_RELEASE_URL}/${GODOT_TEMPLATES_ARCHIVE}" "$tpz"
    verify "$tpz" "$GODOT_TEMPLATES_ARCHIVE"
    mkdir -p "$GODOT_TEMPLATES_DIR"
    # Extract only the desktop templates we ship (see ADR-005).
    python3 - "$tpz" "$GODOT_TEMPLATES_DIR" <<'PY'
import os, sys, zipfile
tpz, dest = sys.argv[1], sys.argv[2]
wanted = ("version.txt", "windows_release_x86_64.exe", "windows_debug_x86_64.exe",
          "macos.zip", "linux_release.x86_64", "linux_debug.x86_64")
with zipfile.ZipFile(tpz) as z:
    for info in z.infolist():
        name = os.path.basename(info.filename)
        if name in wanted:
            target = os.path.join(dest, name)
            with z.open(info) as src, open(target, "wb") as out:
                out.write(src.read())
            if name.startswith("linux_"):
                os.chmod(target, 0o755)
missing = [w for w in wanted if not os.path.exists(os.path.join(dest, w))]
if missing:
    sys.exit("missing templates: " + ", ".join(missing))
PY
    rm -f "$tpz"
    log "export templates installed: $GODOT_TEMPLATES_DIR"
  fi
fi
