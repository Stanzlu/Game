# Architektur

Kurz und praktisch. Grundsätze: einfach, modular, datengetrieben, testbar, austauschbar.
Autoloads nur für echte Querschnittsaufgaben. Keine Questlogik in UI, kein Spielzustand im Rendering-Code.
Herleitung und Alternativen: [`PRE_IMPLEMENTATION_REVIEW.md`](PRE_IMPLEMENTATION_REVIEW.md), Abschnitt D.

Legende: ✅ vorhanden · 🔜 geplant (Phase)

## Verzeichnisse

```
core/        Querschnitt: Autoloads, Boot/Startmenü, Physik-Layer  ✅
entities/    Player, NPC, Interaktion, Figuren-Sheets             ✅ Phase 1
world/       Karten, GameView, Props, Footsteps/FX, Szenen         ✅ Phase 1 · Wetter/Licht 🔜 Phase 3
encounters/  eigenständige Encounter-Szenen                       ✅ antreiber/ (Grey-Box)
ui/          Theme, Dialogbox, Prompt, Pause-Menü, Info-Anzeige    ✅ · HUD Elysia/Real, Journal 🔜 Phase 2/3
content/     Daten: locale/, dialogue/, maps/                      ✅ · quests/, items/ 🔜 Phase 2
assets/      Placeholder-Grafik, -Audio, Schriften                ✅ fonts/
tests/       GUT-Unit-Tests und Fixtures                           ✅
tools/       Toolchain-, Export-, Capture-Skripte                  ✅
addons/      vendored: dialogue_manager, gut                       ✅
docs/        Dokumentation                                         ✅
```

## Autoloads

| Name | Datei | Aufgabe | Status |
|------|-------|---------|--------|
| `Log` | `core/log.gd` | strukturiertes Logging mit Kategorien und Levels; `--log-debug` in Release-Builds | ✅ |
| `DialogueManager` | `addons/dialogue_manager/dialogue_manager.gd` | Dialog-Runtime | ✅ (Addon) |
| `InputDevice` | `core/input_device.gd` | letztes Eingabegerät, Beschriftung von Actions | ✅ |
| `WorldState` | `core/world_state.gd` | typisierter Spielzustand, einzige Schreibstelle | 🔜 Phase 2 |
| `SaveSystem` | `core/save_system.gd` | JSON-Saves, Slots, Autosave, Migration | 🔜 Phase 2 |
| `Settings` | `core/settings.gd` | Accessibility, Lautstärken, Eingabe-Overrides | 🔜 Phase 2 |
| `AudioDirector` | `core/audio_director.gd` | Musikzustände, Crossfades, Ambience | 🔜 Phase 3 |

## Spielszenen (Phase 1)

```
GameScene (world/game_scene.gd)          gemeinsame Komposition
├─ GameView                              Welt im SubViewport, Kamera Weich/Pixelgenau (ADR-012)
│  ├─ WorldViewport/World                MapView (Karte, Props), Player, FX, NPCs
│  └─ WorldDisplay                       Sprite, um Bruchteile verschoben
├─ DialogueBox (CanvasLayer)             Gruppe "dialogue_presenter"
├─ InfoOverlay (CanvasLayer)             F3
└─ PauseMenu (CanvasLayer)               Testoptionen (SessionOptions, ADR-016)
```

- Sandbox: `world/levels/sandbox.tscn` lädt `content/maps/sandbox.txt`.
- Antreiber: `encounters/antreiber/antreiber_encounter.gd` erbt von `GameScene` und baut endlose Segmente.
- Kopplung ohne Event-Bus: Schilder rufen die Gruppe `dialogue_presenter`, Hebel die Gruppe `link_<id>`.
- Reine Logik ohne Knoten, voll getestet: `MovementModel`, `MapData`, `InteractionSelector`, `CameraMath`, `AntreiberModel`.

## Zustandsmodell (Phase 2)

`WorldState` besteht aus typisierten Teilmodellen statt einer losen Flag-Sammlung:
`StoryFlags` (namespaced IDs wie `elysia.mirror_noticed`), `Quests` (Stage, Ziele, Ausgang),
`Relationships` (Zustand `stranger/cautious/familiar/close/strained` plus Erinnerungs-Flags),
`Facets` (im Slice nur Flags), `House`, `Inventory`, `Discovered`, `Player`, `UiMode` (`ELYSIA`/`REAL`),
`ElysiaProgression` (XP, Level, Gold; rein kosmetisch). Änderungen nur über Methoden, die unter
`WORLD_STATE` loggen.

## Content-Formate

| Inhalt | Format | Status |
|--------|--------|--------|
| UI-Texte | CSV → Godot-Translation, Zugriff nur über `tr()` | ✅ |
| Dialoge | Dialogue-Manager-Dateien `.dialogue` | ✅ Format verifiziert · Inhalte 🔜 |
| Quests, Items, Kuriositäten | typisierte `.tres`-Ressourcen mit Validator | 🔜 Phase 2 |
| Maps | Textkarten mit globaler und lokaler Legende (ADR-004, ADR-013) | ✅ |
| Einstellungen | `user://settings.cfg` | 🔜 Phase 2 |
| Spielstände | JSON (ADR-008) | 🔜 Phase 2 |

## Darstellung

640×360 Basisauflösung, Integer-Scaling, Nearest-Filter. Die Welt rendert pixelgenau im SubViewport
der `GameView`, die UI in Fensterauflösung (ADR-012). Theme in
`ui/theme/base_theme.tres` mit Typvariationen `TitleLabel` (32 px), `SubtitleLabel` (16 px),
`MutedLabel`. Grundschrift Tiny5 in 8 px; Text-Skalierung später in ganzzahligen Vielfachen.

## Eingabe

Nur Actions (ADR-011). Belegungen in `project.godot`, Tests in `tests/unit/test_project_settings.gd`.

| Action | Tastatur | Controller |
|--------|----------|------------|
| `move_up/down/left/right` | WASD, Pfeiltasten | linker Stick, D-Pad |
| `interact` | E, Leertaste, Enter | A / Kreuz |
| `cancel` | Esc, Rücktaste | B / Kreis |
| `sprint` | Shift | X / Viereck, rechter Trigger |
| `menu` | Esc, Tab | Start |
| `journal` | J | Back / Select |
| `debug_overlay` | F3 | – (nur Dev-Builds) |

## Audio

Busse `Master`, `Music`, `Ambience`, `SFX`, `UI`, `Voice` (alle → Master) in `default_bus_layout.tres`.

## Build und Prüfung

- `tools/check.sh`: gdlint, gdformat, Import, Headless-Smoke-Run der Hauptszene, GUT.
- `tools/export.sh windows|macos|linux`: Export mit Build-Stempel (Commit, Datum).
- `tools/smoke_export.sh`: startet den exportierten Linux-Build und prüft Boot und Stempel.
- `tools/capture.sh`: rendert Frames per Xvfb + OpenGL3 zur Sichtprüfung; Startargumente werden durchgereicht.
- `tools/autopilot/`: zeitgesteuerte Eingaben für Aufnahmen (nur Debug-Builds).
- `tools/placeholders/make_placeholders.py`: erzeugt die Grey-Box-Assets (ADR-014).
- CI: `.github/workflows/ci.yml` (ADR-009).
