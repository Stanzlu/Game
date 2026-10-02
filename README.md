# REAL

Arbeitstitel. Ein atmosphärisches Pixel-Art-RPG über einen Menschen, der ein perfektes Fantasy-Paradies
verlässt und entdeckt, dass ein unkontrollierbares, unperfektes Leben vielleicht viel lebendiger ist.

**Status:** Phase 0 (Technical Pre-Production). Ziel ist ein 45–60-minütiger Vertical Slice, danach
Playtest-Gate. Noch kein Gameplay. Grafik, Schrift und Icon sind Platzhalter.

## Entwicklung

- **Engine:** Godot **4.7.2** (Standard-Version, nicht .NET). Download: godotengine.org.
  Danach `project.godot` im Editor öffnen.
- **Linux / Cloud / CI:** Godot wird gepinnt und mit SHA512-Prüfung geladen.

| Befehl | Zweck |
|--------|-------|
| `tools/setup_godot.sh` | Godot 4.7.2 laden (Linux) |
| `tools/setup_godot.sh --templates` | zusätzlich Export-Templates |
| `python3 -m venv .venv && .venv/bin/pip install -r requirements-dev.txt` | gdlint und gdformat |
| `tools/check.sh` | Lint, Format, Import, Smoke-Run, Unit-Tests |
| `tools/export.sh windows\|macos\|linux` | Build nach `build/` |
| `tools/smoke_export.sh` | exportierten Linux-Build starten und prüfen |
| `tools/capture.sh` | Screenshots via Xvfb nach `captures/` |
| `tools/godot.sh …` | gepinntes Godot mit diesem Projekt starten |

## Builds testen

CI baut Windows- und macOS-Versionen auf `main`, per manuellem Start oder wenn eine Commit-Nachricht
`[export]` enthält. Download: GitHub → **Actions** → Lauf auswählen → **Artifacts**. Die Builds sind
nicht signiert, deshalb warnt das Betriebssystem beim ersten Start.

- **Windows:** `REAL-windows` entpacken, `REAL.exe` starten. Bei „Der Computer wurde durch Windows
  geschützt“ auf **Weitere Informationen** und dann **Trotzdem ausführen** klicken.
- **macOS:** `REAL-macos` entpacken, darin `REAL.zip` entpacken, `REAL.app` öffnen. Wenn macOS den Start
  blockiert: **Systemeinstellungen → Datenschutz & Sicherheit → Dennoch öffnen**. Alternativ im Terminal:
  `xattr -dr com.apple.quarantine REAL.app`
- **Ausführliche Logs für Fehlerberichte:** mit dem Argument `-- --log-debug` starten.
- **Steuerung im Boot-Screen:** Esc oder B-Taste beendet.

## Dokumentation

| Dokument | Inhalt |
|----------|--------|
| [`docs/GAME_BIBLE.md`](docs/GAME_BIBLE.md) | verbindliche Produktvision (Source of Truth) |
| [`docs/TECH_MASTER_PROMPT.md`](docs/TECH_MASTER_PROMPT.md) | Prozess, Scope, technische Anforderungen |
| [`docs/PRE_IMPLEMENTATION_REVIEW.md`](docs/PRE_IMPLEMENTATION_REVIEW.md) | Review, Engine-Vergleich, Roadmap |
| [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) | Aufbau, Autoloads, Formate, Eingabe |
| [`docs/DECISIONS.md`](docs/DECISIONS.md) | Architekturentscheidungen (ADRs) |
| [`docs/CONTENT_GUIDE.md`](docs/CONTENT_GUIDE.md) | IDs, Dialogformat, Schreibregeln |
| [`docs/SAVE_FORMAT.md`](docs/SAVE_FORMAT.md) | Spielstandformat |
| [`docs/PLACEHOLDERS.md`](docs/PLACEHOLDERS.md) | alle Platzhalter-Assets mit Lizenz |
| [`docs/DEPENDENCIES.md`](docs/DEPENDENCIES.md) | Abhängigkeiten, Versionen, Lizenzen |
| [`docs/KNOWN_ISSUES.md`](docs/KNOWN_ISSUES.md) | bekannte Probleme |
| [`docs/PERFORMANCE.md`](docs/PERFORMANCE.md) | Budget-Vorschlag und Messwerte |

## Lizenzen

Die Lizenz des Spiels ist noch nicht festgelegt. Drittanbieter-Komponenten und ihre Lizenzen stehen in
`docs/DEPENDENCIES.md` und `docs/PLACEHOLDERS.md`.
