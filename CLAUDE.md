# CLAUDE.md – Arbeitsregeln für REAL

REAL ist ein narratives Pixel-Art-RPG in Godot 4.7.2 (typisiertes GDScript). Wir bauen **nur** bis zum
45–60-minütigen Vertical Slice. Danach STOP und Playtest-Gate. Kein Full-Production-Content ohne Freigabe.

## Zuerst lesen
- `docs/GAME_BIBLE.md` – verbindliche Produktvision. Abweichungen nur nach Rückfrage und ADR.
- `docs/DECISIONS.md` – getroffene Entscheidungen. `docs/ARCHITECTURE.md` – Aufbau und Status.
- `docs/TECH_MASTER_PROMPT.md` – Prozessregeln (Fragen bei großen Entscheidungen, 0-€-Regel, Cut-First).

## Befehle
- `tools/check.sh` vor jedem Push (Lint, Format, Import, Smoke-Run, GUT). Muss grün sein.
- Einzelne Testdatei: `tools/godot.sh --headless -s addons/gut/gut_cmdln.gd -gselect=test_log -gexit`
- `tools/export.sh <ziel>` und `tools/smoke_export.sh` für Builds; `tools/capture.sh` für Screenshots.
- gdtoolkit liegt in `.venv/` (`python3 -m venv .venv && .venv/bin/pip install -r requirements-dev.txt`).

## Aufbau in Kürze
- Szenen erben von `GameScene` (`world/game_scene.gd`); die Welt lebt im SubViewport der `GameView` (ADR-012).
- Spielzustand nur über den Autoload `WorldState` ändern (ADR-019); Speichern über `SaveSystem` (ADR-021,
  `docs/SAVE_FORMAT.md`), Einstellungen über `Settings` (ADR-018). Quests/Items sind `.tres` in `content/`,
  `ContentValidator` prüft sie und alle Dialoge (statische IDs, keine Fake Choices).
- Automatische Läufe mit `--profile=<name>` starten, damit nie echte Spielstände berührt werden.
- Musik/Ambience über `AudioDirector` (Szenen-Exports `music`, `ambience`), UI-Stil über `UiSkin.attach`
  (Elysia/Real folgt `WorldState.ui_mode`), Übergänge mit `ScreenFade`. Renderer: Compatibility (ADR-022).
- Weltknoten fragen den `Input`-Singleton ab; UI liegt in CanvasLayern und nutzt `_unhandled_input`.
- In `_process` bewegte Knoten: `physics_interpolation_mode = OFF`.
- Wartezeiten in Knoten mit `await NodeTimer.after(self, s)`, nicht `get_tree().create_timer()`.
- Karten sind Textdateien (`content/maps`, ADR-013); Platzhalter-Assets erzeugt `tools/placeholders`.
- Look-Grafik ist prozedural (ADR-017, `docs/ART_DIRECTION.md`): `tools/art/make_sprites.py`, dann
  `tools/art/bake_ground.py <karte>` nach jeder Änderung an Look-Karten. Braucht `requirements-art.txt`.
- Autopilot für reproduzierbare Aufnahmen: `tools/autopilot/*.json` (nur Debug; `tap` für Menüs/Dialoge).

## Konventionen
- Statisch typisiertes GDScript, `gdformat`-formatiert, `gdlint`-sauber. Tabs.
- Gameplay fragt nur Input-Actions ab, nie konkrete Tasten. Events mit `device = -1`.
- Alle sichtbaren Texte über `tr()` bzw. Dialogdateien. Inhalte auf Deutsch.
- Stabile IDs nach `docs/CONTENT_GUIDE.md`. Keine Logik über Anzeigenamen.
- Logging über `Log.<level>(Log.Category.X, ...)`. Fehler nie still schlucken.
- Addons in `addons/` nicht verändern. Neue Dependencies nur mit Prüfung, ADR und Eintrag in `docs/DEPENDENCIES.md`.
- Keine kostenpflichtigen Tools, Assets oder Dienste ohne ausdrückliche Zustimmung.
- Jedes Placeholder-Asset in `docs/PLACEHOLDERS.md` eintragen (Quelle, Lizenz).
- Keine Fake Choices, keine Therapiesprache, keine sichtbaren Zahlen für Beziehungen oder Facetten.

## Workflow
- Ein Branch und ein Pull Request pro Phase, kleine thematische Commits.
- Nach jeder Phase: Ergebnis, Tests, offene Probleme, Entscheidungen, nächster Schritt.
- Commit-Nachricht mit `[export]` löst in CI Windows-/macOS-Builds aus.

## Cloud-Umgebung
- Ein SessionStart-Hook installiert Godot 4.7.2 automatisch.
- Kein Vulkan im Container: Screenshots laufen über OpenGL3 (`tools/capture.sh`).
- Asset-Seiten wie kenney.nl sind blockiert, GitHub-Releases und PyPI sind erreichbar.
