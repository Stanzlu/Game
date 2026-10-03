# Architektur

Kurz und praktisch. Grundsätze: einfach, modular, datengetrieben, testbar, austauschbar.
Autoloads nur für echte Querschnittsaufgaben. Keine Questlogik in UI, kein Spielzustand im Rendering-Code.
Herleitung und Alternativen: [`PRE_IMPLEMENTATION_REVIEW.md`](PRE_IMPLEMENTATION_REVIEW.md), Abschnitt D.

Legende: ✅ vorhanden · 🔜 geplant (Phase)

## Verzeichnisse

```
core/        Querschnitt: Autoloads, Boot                         ✅ log.gd, boot/
entities/    Player, NPC, Interactables, Tiere                    🔜 Phase 1
world/       Maps, Wetter, Tageslicht, Wasser/Spiegelung, Footsteps 🔜 Phase 1/3
encounters/  eigenständige Encounter-Szenen (Antreiber)            🔜 Phase 1 (Grey-Box)
ui/          Theme, HUD Elysia/Real, Dialogbox, Journal, Menüs     ✅ theme/ · Rest 🔜 Phase 2/3
content/     Daten: locale/, dialogue/, quests/, items/, maps/     ✅ locale/ · Rest 🔜
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
| `WorldState` | `core/world_state.gd` | typisierter Spielzustand, einzige Schreibstelle | 🔜 Phase 2 |
| `SaveSystem` | `core/save_system.gd` | JSON-Saves, Slots, Autosave, Migration | 🔜 Phase 2 |
| `Settings` | `core/settings.gd` | Accessibility, Lautstärken, Eingabe-Overrides | 🔜 Phase 2 |
| `AudioDirector` | `core/audio_director.gd` | Musikzustände, Crossfades, Ambience | 🔜 Phase 3 |

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
| Maps | Textkarten + `.tscn` für Objekte (ADR-004) | 🔜 Phase 1 |
| Einstellungen | `user://settings.cfg` | 🔜 Phase 2 |
| Spielstände | JSON (ADR-008) | 🔜 Phase 2 |

## Darstellung

640×360 Viewport, Integer-Scaling, Nearest-Filter, Pixel-Snapping (ADR-007). Theme in
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
- `tools/capture.sh`: rendert Frames per Xvfb + OpenGL3 zur Sichtprüfung.
- CI: `.github/workflows/ci.yml` (ADR-009).
