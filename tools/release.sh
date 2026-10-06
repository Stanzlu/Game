#!/usr/bin/env bash
# Packs the exported builds for testers and creates a DRAFT GitHub release (Phase 5, ADR-044).
# Usage: tools/release.sh <tag>   (after tools/export.sh windows|macos|linux)
# A draft is only visible to the repository's collaborators; the project owner publishes it.
# RELEASE_DRY_RUN=1 only packs into build/release/ and prints what it would create.
set -euo pipefail
# shellcheck source=tools/godot_env.sh
source "$(dirname "${BASH_SOURCE[0]}")/godot_env.sh"
cd "$REPO_ROOT"

tag="${1:-}"
[ -n "$tag" ] || { echo "Usage: tools/release.sh <tag>" >&2; exit 2; }
version="$(sed -n 's/^config\/version="\(.*\)"$/\1/p' project.godot)"
if [ "v${version}" != "$tag" ]; then
  echo "release: tag ${tag} does not match project version ${version} (expected v${version})" >&2
  exit 1
fi

out="build/release"
rm -rf "$out"
mkdir -p "$out"
readme="$out/LIESMICH.txt"
cat > "$readme" <<TXT
Nach Elysia (Arbeitstitel REAL) – Playtest ${tag}

Danke fürs Testen! Grafik, Musik und Klänge sind selbst erzeugte Platzhalter, die Texte Entwürfe.
Plane 45–60 Minuten mit Ton ein und spiel am Stück, ohne Eile.

Die Builds sind nicht signiert, deshalb warnt das Betriebssystem beim ersten Start:
- Windows: "Weitere Informationen" und dann "Trotzdem ausführen".
- macOS: REAL.app öffnen; wenn macOS blockiert: Systemeinstellungen > Datenschutz & Sicherheit >
  "Dennoch öffnen".

Anleitung und Fragen: https://github.com/${GITHUB_REPOSITORY:-Stanzlu/Game}/blob/${tag}/docs/PLAYTEST.md
TXT

pack() {
  # pack <archive> <files...>: flat zip with the readme next to the game
  local archive="$1"
  shift
  zip -q -j "$archive" "$@" "$readme"
}

assets=()
if [ -f build/windows/REAL.exe ]; then
  pack "$out/REAL-${tag}-windows.zip" build/windows/REAL.exe
  assets+=("$out/REAL-${tag}-windows.zip")
fi
if [ -f build/macos/REAL.zip ]; then
  # the macOS export is already a zip with REAL.app; keep it intact (signature, permissions)
  cp build/macos/REAL.zip "$out/REAL-${tag}-macos.zip"
  assets+=("$out/REAL-${tag}-macos.zip")
fi
if [ -f build/linux/REAL.x86_64 ]; then
  chmod +x build/linux/REAL.x86_64
  pack "$out/REAL-${tag}-linux.zip" build/linux/REAL.x86_64
  assets+=("$out/REAL-${tag}-linux.zip")
fi
[ "${#assets[@]}" -gt 0 ] || { echo "release: no builds found in build/" >&2; exit 1; }
cp "$readme" "$out/notes.md"

for a in "${assets[@]}"; do
  echo "release: $(basename "$a") ($(du -h "$a" | cut -f1))"
done
if [ "${RELEASE_DRY_RUN:-0}" = "1" ]; then
  echo "release: dry run, would create draft ${tag} with ${#assets[@]} files"
  exit 0
fi
gh release create "$tag" "${assets[@]}" --draft --prerelease \
  --title "Playtest ${tag}" --notes-file "$out/notes.md" --verify-tag
echo "release: draft ${tag} created; publish it on GitHub when it is ready for testers"
