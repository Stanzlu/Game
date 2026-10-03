# REAL

Arbeitstitel. Ein atmosphärisches Pixel-Art-RPG über einen Menschen, der ein perfektes Fantasy-Paradies
verlässt und entdeckt, dass ein unkontrollierbares, unperfektes Leben vielleicht viel lebendiger ist.

**Status:** Phase 1 (Movement Sandbox). Ziel ist ein 45–60-minütiger Vertical Slice, danach
Playtest-Gate. Spielbar sind eine Bewegungs-Sandbox und ein Grey-Box-Prototyp des Antreiber-Encounters.
Grafik, Ton und Texte sind Platzhalter. Testanleitung: [`docs/PLAYTEST_PHASE1.md`](docs/PLAYTEST_PHASE1.md).

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
| `tools/capture.sh "" captures/x 300 --start=sandbox` | Bildfolge via Xvfb nach `captures/` |
| `tools/godot.sh -- --start=sandbox --camera=pixel` | direkt in eine Szene, Einstellungen nur für diese Sitzung überschreiben |
| `tools/godot.sh -- --continue` | neuesten Spielstand laden |
| `tools/godot.sh -- --profile=test1 --start=sandbox` | eigener Ordner für Spielstände und Einstellungen (Tests, Aufnahmen) |
| `python3 tools/placeholders/make_placeholders.py` | Grey-Box-Platzhalter neu erzeugen |
| `.venv/bin/pip install -r requirements-art.txt` | numpy und Pillow für die Look-Generatoren |
| `.venv/bin/python tools/art/make_sprites.py` | Look-Props und Katalog erzeugen (siehe `docs/ART_DIRECTION.md`) |
| `.venv/bin/python tools/art/bake_ground.py content/maps/look_tal.txt` | Boden einer Look-Karte backen |
| `tools/godot.sh -- --start=look_elysia` | Look-Szene direkt starten (`look_elysia`, `look_tal`, `look_wald`) |
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
- **Steuerung:** siehe `docs/PLAYTEST_PHASE2.md`. Esc oder Start öffnet das Pause-Menü, J oder Back das
  Journal.
- **Spielstände und Einstellungen** liegen lokal unter `%APPDATA%\REAL\` (Windows) bzw.
  `~/Library/Application Support/REAL/` (macOS), siehe `docs/SAVE_FORMAT.md`.

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
| [`docs/PLAYTEST_PHASE1.md`](docs/PLAYTEST_PHASE1.md) | Testanleitung und Fragen für Phase 1 |
| [`docs/PLAYTEST_PHASE2.md`](docs/PLAYTEST_PHASE2.md) | Prüfliste für Phase 2 (Speichern, Dialoge, Journal, Menüs) |
| [`docs/ART_DIRECTION.md`](docs/ART_DIRECTION.md) | Look-Regeln, Generatoren, Fragen zur Look-Phase |

## Lizenzen

Die Lizenz des Spiels ist noch nicht festgelegt. Drittanbieter-Komponenten und ihre Lizenzen stehen in
`docs/DEPENDENCIES.md` und `docs/PLACEHOLDERS.md`.
