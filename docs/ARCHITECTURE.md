# Architektur

Kurz und praktisch. Grundsätze: einfach, modular, datengetrieben, testbar, austauschbar.
Autoloads nur für echte Querschnittsaufgaben. Keine Questlogik in UI, kein Spielzustand im Rendering-Code.
Herleitung und Alternativen: [`PRE_IMPLEMENTATION_REVIEW.md`](PRE_IMPLEMENTATION_REVIEW.md), Abschnitt D.

Legende: ✅ vorhanden · 🔜 geplant (Phase)

## Verzeichnisse

```
core/        Querschnitt: Autoloads, Boot/Startmenü, Physik-Layer  ✅ · state/, save/, content/ (Phase 2)
entities/    Player, NPC, Interaktion, Figuren-Sheets             ✅ Phase 1
world/       Karten, GameView, Props, FX, Shader, Szenen           ✅ Phase 1 · Look-Prototyp: Wetter, Licht, Himmel ✅
encounters/  eigenständige Encounter-Szenen                       ✅ antreiber/ (Grey-Box)
ui/          Theme, Dialogbox, Prompt, Menüs, Journal, Debug-Panel ✅ · HUD Elysia/Real, Skins 🔜 Phase 3
content/     Daten: locale/, dialogue/, maps/, quests/, items/     ✅
assets/      Placeholder-Grafik, -Audio, Schriften                ✅ fonts/, placeholder/, generated/ (ADR-017)
tests/       GUT-Unit-Tests und Fixtures                           ✅
tools/       Toolchain-, Export-, Capture-Skripte, Generatoren     ✅ art/, audio/ (ADR-017)
addons/      vendored: dialogue_manager, gut                       ✅
docs/        Dokumentation                                         ✅
```

## Autoloads

| Name | Datei | Aufgabe | Status |
|------|-------|---------|--------|
| `Log` | `core/log.gd` | strukturiertes Logging mit Kategorien und Levels; `--log-debug` in Release-Builds | ✅ |
| `DialogueManager` | `addons/dialogue_manager/dialogue_manager.gd` | Dialog-Runtime | ✅ (Addon) |
| `InputDevice` | `core/input_device.gd` | letztes Eingabegerät, Beschriftung von Actions | ✅ |
| `Settings` | `core/settings.gd` | Einstellungen (JSON, ADR-018): Lautstärken, Text, Steuerung, Anzeige, Barrierefreiheit, Eingabe-Overrides | ✅ |
| `WorldState` | `core/world_state.gd` | typisierter Spielzustand (`GameState`), einzige Schreibstelle (ADR-019) | ✅ |
| `SaveSystem` | `core/save_system.gd` | JSON-Saves, Slots, Autosave, Sperren, Laden (ADR-021) | ✅ |
| `AudioDirector` | `core/audio_director.gd` | Musikzustände, Crossfades, Ambience | 🔜 Phase 3 |

## Spielszenen

```
GameScene (world/game_scene.gd)          gemeinsame Komposition, Gruppe "save_context"
├─ GameView                              Welt im SubViewport, Kamera Weich/Pixelgenau (ADR-012)
│  ├─ WorldViewport/World                MapView (Karte, Props), Player, FX, NPCs
│  └─ WorldDisplay                       Sprite, um Bruchteile verschoben
├─ DialogueBox (CanvasLayer 20)          Gruppe "dialogue_presenter", sperrt Speichern
├─ Journal (MenuLayer 42)                J / Back
├─ InfoOverlay (CanvasLayer 30)          F3
├─ PauseMenu (MenuLayer 40)              Esc / Start
│  ├─ SettingsMenu (50)
│  └─ SaveMenu (50)                      Speichern / Laden
└─ DebugPanel (MenuLayer 60)             F4, nur Debug-Builds
```

- Die Szene liefert `SaveSystem` Ort und Speicherbarkeit (`is_saveable()`, `save_location()`), wendet
  Einstellungen an und setzt die Figur nach dem Laden an die gespeicherte Position. Beim Betreten ohne
  Laden fordert sie ein Autosave an. Encounter setzen `saveable = false`.
- Menüs erben von `MenuLayer` (`ui/menus/menu_layer.gd`) und nutzen `OptionList`: Hoch/Runter mit
  Umbruch, Links/Rechts ändert Werte, Bestätigen mit Enter, Leertaste, E oder A, Zurück mit Esc oder B.
  Sie laufen auch bei pausiertem Baum.
- Startmenü: Fortsetzen (neuester lesbarer Stand), Laden, Einstellungen, Prototyp-Szenen (jede startet
  einen neuen Spielzustand). `--start=<schlüssel>` und `--continue` für Tests und Aufnahmen.

- Sandbox: `world/levels/sandbox.tscn` lädt `content/maps/sandbox.txt`.
- Antreiber: `encounters/antreiber/antreiber_encounter.gd` erbt von `GameScene` und baut endlose Segmente.
- Kopplung ohne Event-Bus: Schilder und NPCs rufen die Gruppe `dialogue_presenter`, Hebel die Gruppe
  `link_<id>`. Zustandsänderungen laufen über `WorldState` und dessen typisierte Signale.
- Reine Logik ohne Knoten, voll getestet: `MovementModel`, `MapData`, `InteractionSelector`, `CameraMath`,
  `AntreiberModel`, `GameState`, `SaveCodec`, `ContentValidator`, `StateActions`.

## Zustandsmodell (ADR-019)

`WorldState` hält einen `GameState` (`core/state/game_state.gd`) aus typisierten Teilen statt einer losen
Flag-Sammlung: Flags (Namensraum-IDs wie `elysia.mirror_noticed`), Quests (Stufe, Verlauf, erledigte
Ziele; Ausgang aus der Endstufe), Beziehungen (Zustand `stranger/cautious/familiar/close/strained` plus
Erinnerungen), Facetten (im Slice nur Flags), Haus (Feuer, Kuriositäten-Plätze), Inventar, entdeckte Orte,
Spieler (Name, Preset, Szene, Position), UI-Modus (`ELYSIA`/`REAL`), Elysia-Werte (XP, Gold; Level aus XP)
und Spielzeit. Änderungen nur über `WorldState`-Methoden; sie prüfen gegen `ContentDB`, loggen unter
`WORLD_STATE`/`QUEST` und senden typisierte Signale (`flag_changed`, `quest_changed`,
`relationship_changed`, `inventory_changed`, `ui_mode_changed`, …). Dialoge benutzen dieselben Methoden.

```
Inhalt (.tres, .dialogue, .txt) ──► ContentDB / ContentValidator
                                         │
Dialoge, Hebel, Zonen, Debug ──► WorldState ──► GameState ──► SaveCodec ──► SaveSystem ──► user://saves
                                         │ Signale
                         Journal, Autosave, (später HUD)
```

## Content-Formate

| Inhalt | Format | Status |
|--------|--------|--------|
| UI-Texte | CSV → Godot-Translation, Zugriff nur über `tr()` | ✅ |
| Dialoge | Dialogue-Manager-Dateien `.dialogue` mit statischen Zeilen-IDs (ADR-020) | ✅ · echte Inhalte 🔜 Phase 4 |
| Quests, Items, Kuriositäten | typisierte `.tres`-Ressourcen (`QuestDef`, `ItemDef`) mit Validator | ✅ |
| Maps | Textkarten mit globaler und lokaler Legende, `[meta]` für gebackene Böden (ADR-004, ADR-013, ADR-017) | ✅ |
| Prop-Grafik | `assets/generated/props/catalog.json` (Anker, Kollision, Wind, Licht), erzeugt von `tools/art/make_sprites.py` | ✅ Look-Prototyp |
| Einstellungen | `user://settings.json` (ADR-018) | ✅ |
| Spielstände | JSON (ADR-008, ADR-021, `SAVE_FORMAT.md`) | ✅ |

## Darstellung

640×360 Basisauflösung, Integer-Scaling, Nearest-Filter. Die Welt rendert pixelgenau im SubViewport
der `GameView`, die UI in Fensterauflösung (ADR-012). Theme in
`ui/theme/base_theme.tres` mit Typvariationen `TitleLabel` (32 px), `SubtitleLabel` (16 px),
`MutedLabel`. Grundschrift Tiny5 in 8 px; Text-Skalierung später in ganzzahligen Vielfachen.

**Look-Prototyp (ADR-017, `docs/ART_DIRECTION.md`):** `LookScene` (`world/levels/look_scene.gd`) erweitert
`GameScene` um Atmosphäre. Ebenen in der Welt: Himmel `SkyLayer` (z −20) → gebackener Boden mit
`ground.gdshader` (z −10, Wasser, Regenringe, Wolkenschatten) → flache Deko (z −5) → nach Fußlinie
sortierte Figuren und Props (`decor.gd`, Wind über `wind_sway.gdshader`, Lichter, Rauch) → Partikel
(z 30). Regen liegt in einer eigenen `CanvasLayer` im SubViewport, damit `CanvasModulate` ihn nicht
abdunkelt. Die Farbstimmung (`grade.gdshader`: Bloom, Sättigung, Kontrast, Tönung, Vignette) sitzt auf
dem Anzeige-Sprite der `GameView` und wirkt auf das fertige Weltbild. `MapView` streut zusätzlich
Kleinvegetation nach `[meta]`-Regeln (`world/map/scatter.gd`, rein und getestet) und hängt Props und
NPCs nahe am Wasser eine Spiegelung an (`reflection.gdshader`, maskiert mit der Wassermaske; der Player
bekommt keine). `AmbientLife` (`world/fx/ambient_life.gd`) bewegt Vögel, Fische, Koi und Libellen.

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
| `debug_panel` | F4 | – (nur Debug-Builds) |

In Menüs bestätigen `ui_accept` (Enter, Leertaste, A) und `interact` (E) gleichermaßen.
Eingabe-Overrides liegen in den Einstellungen; die Belegungsoberfläche folgt nach dem Slice (ADR-011).

## Audio

Busse `Master`, `Music`, `Ambience`, `SFX`, `UI`, `Voice` (alle → Master) in `default_bus_layout.tres`.
Look-Szenen spielen nahtlose Ambience-Loops auf `Ambience`; der Brunnen hat einen positionalen Wasser-Loop.

## Build und Prüfung

- `tools/check.sh`: gdlint, gdformat, Import, Headless-Smoke-Runs (Menü, jede Szene, `--continue`), GUT.
  Automatische Läufe nutzen eigene Profile (`--profile=smoke`), nie die Spielstände des Spielers.
- `tools/export.sh windows|macos|linux`: Export mit Build-Stempel (Commit, Datum).
- `tools/smoke_export.sh`: startet den exportierten Linux-Build, prüft Boot, Stempel, jede Szene,
  vorhandene Quests und Items sowie das Laden eines Spielstands.
- `tools/capture.sh`: rendert Frames per Xvfb + OpenGL3 zur Sichtprüfung; Startargumente werden durchgereicht.
- `tools/autopilot/`: zeitgesteuerte Eingaben für Aufnahmen (nur Debug-Builds).
- `tools/placeholders/make_placeholders.py`: erzeugt die Grey-Box-Assets (ADR-014).
- CI: `.github/workflows/ci.yml` (ADR-009).
