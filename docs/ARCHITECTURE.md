# Architektur

Kurz und praktisch. Grundsätze: einfach, modular, datengetrieben, testbar, austauschbar.
Autoloads nur für echte Querschnittsaufgaben. Keine Questlogik in UI, kein Spielzustand im Rendering-Code.
Herleitung und Alternativen: [`PRE_IMPLEMENTATION_REVIEW.md`](PRE_IMPLEMENTATION_REVIEW.md), Abschnitt D.

Legende: ✅ vorhanden · 🔜 geplant (Phase)

## Verzeichnisse

```
core/        Querschnitt: Autoloads, Boot/Startmenü, Physik-Layer  ✅ · state/, save/, content/ (Phase 2) · util/, benchmark/ (Phase 3)
entities/    Player, NPC, Interaktion, Figuren-Sheets             ✅ Phase 1
world/       Karten, GameView, Props, FX, Shader, Szenen           ✅ Phase 1 · Look-Prototyp: Wetter, Licht, Himmel ✅
encounters/  eigenständige Encounter-Szenen                       ✅ antreiber/ (Grey-Box und Slice-Fassung)
ui/          Theme, Skins Elysia/Real, HUD, Dialogbox, Prompt, Menüs, Journal, Debug-Panel ✅
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
| `AudioDirector` | `core/audio_director.gd` | Musik-Tracks mit Überblendung, Ducking, Bandstopp, Ambience (ADR-023); Menü-, Spiel- und Stimmklänge `ui()`, `sfx()`, `voice()` (ADR-027) | ✅ |
| `ScreenFade` | `core/screen_fade.gd` | schwarze Abdeckung über Szenenwechsel (ADR-025) | ✅ |

## Spielszenen

```
GameScene (world/game_scene.gd)          gemeinsame Komposition, Gruppe "save_context"
├─ GameView                              Welt im SubViewport, Kamera Weich/Pixelgenau (ADR-012), Zoom (ADR-043)
│  ├─ WorldViewport/World                MapView (Karte, Props), Player, FX, NPCs
│  └─ WorldDisplay                       Sprite, um Bruchteile verschoben
├─ Hud (CanvasLayer 12)                  Elysia: Level, XP, Gold, Quest, Popups · Real: leise Zeile
├─ DialogueBox (CanvasLayer 20)          Gruppe "dialogue_presenter", sperrt Speichern, Musik leiser
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
- Alle UI-Teile folgen dem UI-Modus über `UiSkin.attach` (ADR-024): Elysia golden und verziert,
  Real minimal. Szenen wählen Musik und Ambience über Exports (`music`, `ambience`, ADR-023).
- Menüs erben von `MenuLayer` (`ui/menus/menu_layer.gd`) und nutzen `OptionList`: Hoch/Runter mit
  Umbruch, Links/Rechts ändert Werte, Bestätigen mit Enter, Leertaste, E oder A, Zurück mit Esc oder B.
  Sie laufen auch bei pausiertem Baum.
- Startmenü: Fortsetzen (neuester lesbarer Stand), Neues Spiel (Namenswahl `NameEntry`, dann Elysia),
  Laden, Prototypen (jede startet einen neuen Spielzustand), Einstellungen. `--start=<schlüssel>` und
  `--continue` für Tests und Aufnahmen. Zwei Titel (ADR-030): „Elysia“, bis
  `SaveSystem.reached_reality()` wahr ist, danach „Nach Elysia“ (ADR-035); `--title=elysia|real`.

### Vertical Slice (Phase 4, ADR-037)

```
elysia  world/levels/slice/elysia.tscn   ElysiaScene: Erwachen, Schmetterlinge, Truhe, Wiederholung, Kind, Riss
tal     world/levels/slice/tal.tscn      TalScene: Ankunft, Miras Nein, Trittsteine, Abend, Ziege, Schluss
haus    world/levels/slice/haus.tscn     HausScene: kalter Kamin, Feuer, Miras Besuch, Katze
weg     encounters/antreiber/slice_antreiber.tscn   SliceAntreiber: der Weg zum Schuppen (ADR-038)
```

- Szenen-Skripte reagieren nur auf `WorldState` (Flags, Quests, Haus) und inszenieren: `Cutscene`
  (sperrt Spieler und Speichern, zeigt Cues nacheinander), Licht, Musik, Rückfälle gegen Festhängen.
  `Beat.mark(id)` loggt die Spielminute jedes Beats.
- Karten: Requisiten mit `"if"`/`"unless"` erscheinen live (MapView); wer einen eigenen Abgang hat
  (`leave()`: das Kind verblasst, der Schmetterling blitzt auf), spielt ihn zu Ende. Was sich selbst
  entfernt hat (eingesammelt, gefangen), bleibt weg. `"sprite_when"` baut das Requisit mit dem neuen
  Bild neu auf (Licht, Form, Ebene, Spiegelzwilling). `door` (Tür oder Kartenrand mit `"auto"`),
  Spawn-Marker `spawn_<name>`, `SceneTravel.go()` blendet über und setzt die Figur vor dem Autosave an
  den Marker; während der Blende öffnet kein Pausenmenü. `blocker` sperrt Wege mit Erklärung, mit
  `"offset"` auch über Zellen mit anderen Requisiten (der Bach bis zu Miras Nein, die Haustür bis zu
  ihrem Besuch). `test_content` prüft, dass jedes gelesene Flag irgendwo gesetzt wird.
- Neue Requisiten: `stepping_stone` (runde kippen, zurück ans Ufer), `golden_butterfly`, `goat`
  (`"perch"` hebt sie auf den Holzstapel), `fireplace`, `blocker`; `Talk` (Interaktionsfläche und
  Dialog über den Presenter); `ChildGuide` (NpcWalker, der vorausgeht, wartet und das Hauptmotiv summt).
- `NpcWalker`: `"pause": [min, max]` lässt Menschen an Wegpunkten verschieden lange verweilen (Mira),
  Elysianer laufen ohne Pause im Gleichtakt; `"face"` ist die Blickrichtung im Stand. `Decor` mit
  `"sit"` ist ein Sitzplatz (der Teppich am Kamin). Bringt die Geschichte ein Requisit während der
  Szene, bekommt es `"live": true` und darf auftreten (die Ziege erscheint mit Verzögerung).
- Tiefe nach ADR-042: `NpcWalker` mit `"sit": true` sitzt (Mira, der Antreiber); `Decor` mit
  `"lift"` zeichnet höher, als es sortiert (die Katze auf dem Schoß); `ItemDef.placeable` lässt ein
  normales Item ins Regal (der Stein). `AntreiberActor.trail`, `walk_to`, `sit_down` inszenieren ihn
  nach dem Schuppen (`TalScene`, `HausScene`). `AmbientLife`: Frösche kommen, wenn die Spielfigur
  still steht. `NameEntry` ist wiederverwendbar (`title_key`, `suggestions`) und benennt die Katze
  (`WorldState.cat_name`). Das Journal zeigt in der Wirklichkeit keine Häkchen und unter „Menschen“
  die Erinnerungen als Sätze (`MEMORY_<FIGUR>_<ID>`). Dialoge nutzen `=><` (Teilgespräch mit
  Rückkehr) und Antworten mit `[if … /]`, die nur erscheinen, wenn man das Erzählte erlebt hat.
- Autopilot: `"meet": "<cue>"` stellt die Figur neben die NPC mit diesem Cue, wo immer sie gerade ist.
- Der Riss gibt das Ziel samt Spawn weiter (`RiftSequence.spawn`), die Ankunft blendet langsam auf.
- Durchlauf ohne Hand: `tools/autopilot/slice_full.json` (Hauptmenü bis Titelkarte); Teilstrecken
  `slice_{elysia,tal,haus,weg,abend}.json`. Der Autopilot klickt Gespräche durch (`"dialogue"`) und
  setzt bei Bedarf Zustand (`"give"`, `"flag"`).

- Sandbox: `world/levels/sandbox.tscn` lädt `content/maps/sandbox.txt`.
- Antreiber: `encounters/antreiber/antreiber_encounter.gd` erbt von `GameScene` und baut endlose Segmente;
  Hooks (`segment_*`, `goal_scene`, `_configure_actor`, `_after_resolved`) für die Slice-Fassung.
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
der `GameView`, die UI in Fensterauflösung (ADR-012). Szenen setzen `view_zoom` (ADR-043): Der
Welt-Viewport schrumpft auf `view_size` = 640×360 / Zoom, das Anzeige-Sprite wächst um den Zoom, und
bei nicht ganzzahligem Zoom tastet `sharp_display.gdshader` bzw. `grade.gdshader` scharf ab
(`sharp_sample.gdshaderinc`). Welt nach UI rechnet `GameView.world_to_ui` um. Theme in
`ui/theme/base_theme.tres` (ADR-026): Grundschrift Jersey 10 in 19 px, `TitleLabel`/`SubtitleLabel` in
Jersey 15 (27 px), `SmallLabel`/`HintLabel`/`PromptText` in Tiny5 (8 px), dazu `MutedLabel`,
`MenuEntry`, `MenuCursor`, `DialogueNamePlate`, `PromptPanel`/`PromptKey`, `TitleMenuPanel`.
Die Skins Elysia und Real überschreiben nur Farben und Rahmen. `TextSize` (`ui/theme/text_size.gd`)
schaltet für „Große Schrift“ die Schriftgrößen aller gemeinsamen Themes um (ADR-033). `MenuLayer` legt einen weichgezeichneten
Hintergrund (`menu_backdrop.gdshader`) unter das Panel; `OptionList` führt einen `MenuCursor` mit und
spielt die Menüklänge. Entwickler-Panels nutzen `compact_theme.tres`. Renderer: Compatibility
(OpenGL 3) auf allen Plattformen (ADR-022).

**Startmenü:** `core/boot/boot.tscn` mit `TitleBackground` (`ui/title/`) in zwei Stimmungen: Elysia
(symmetrische Insel, Zwillings-Wasserfälle, Vögel im exakten Takt) oder REAL (Abendtal mit Wind,
Laterne, Sternen). Prototyp-Szenen, Leistungstest, Titelkarte (`TitleCard`) und Titelwechsel im
Untermenü `PrototypeMenu`.

**HUD (`ui/hud/hud.gd`):** Elysia mit `XpBar`, hochzählendem Gold mit fliegenden Münzen, Level-up
(Strahlen, Funken, Aufblitzen), Beute-Karte mit Icon (`ItemDef.icon()`) und `fancy_text.gdshader`;
Real mit einer leisen Zeile. Für beide: Ortsname beim Betreten (`show_area`) und „Gespeichert“.

**Look-Prototyp (ADR-017, `docs/ART_DIRECTION.md`):** `LookScene` (`world/levels/look_scene.gd`) erweitert
`GameScene` um Atmosphäre. Ebenen in der Welt: Himmel `SkyLayer` (z −20) → gebackener Boden mit
`ground.gdshader` (z −10, Wasser, Regenringe, Wolkenschatten) → flache Deko (z −5) → nach Fußlinie
sortierte Figuren und Props (`decor.gd`, Wind über `wind_sway.gdshader`, Lichter, Rauch) → Partikel
(z 30). Tiefen-Bogen (ADR-043, Gruppe „Depth“ der `LookScene`): `Backdrop` (`world/fx/backdrop.gd`,
z −20) malt Himmel und Bergketten über der Karte und erweitert die Kamera-Grenzen nach oben;
`ForegroundFoliage` (z 40) legt Kronen an den Südrand; `depth_haze`/`haze_color` im Grade-Shader
folgen dem `DayLight`, das auch `Backdrop.clear` (Nebel) blendet; `display.parallax` schaltet die
Parallaxe ab. Regen liegt in einer eigenen `CanvasLayer` im SubViewport, damit `CanvasModulate` ihn nicht
abdunkelt. Die Farbstimmung (`grade.gdshader`: Bloom, Sättigung, Kontrast, Tönung, Vignette) sitzt auf
dem Anzeige-Sprite der `GameView` und wirkt auf das fertige Weltbild. `MapView` streut zusätzlich
Kleinvegetation nach `[meta]`-Regeln (`world/map/scatter.gd`, rein und getestet) und hängt Props und
NPCs nahe am Wasser eine Spiegelung an (`reflection.gdshader`, maskiert mit der Wassermaske). Den Player
spiegelt nur eine Szene mit `reflect_player` (Tal und Wald, auch in Pfützen), Elysia nie. `AmbientLife`
(`world/fx/ambient_life.gd`) bewegt Vögel, Fische, Koi und Libellen; mit `perfect_loops` (Elysia)
ohne Zufall und gespiegelt an der Achse aus `[meta] symmetry`, die auch Boden, Streu, Requisiten und
Wind (`wind_sway.gdshader`, `mirror_x`) spiegelt (ADR-031).
`PropCatalog` gibt die Grafiken als Ausschnitte eines Atlas je Stil aus (ADR-028); Shader rechnen
deshalb nicht mit `UV` als 0..1 der Figur.

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
`AudioDirector` spielt die Musik-Loops (`assets/generated/music/`, `tools/audio/make_music.py`) auf `Music`
und die Ambience-Loops auf `Ambience`, je mit zwei Spielern zum Überblenden. Musik: Elysia, Tal (Abend),
Nachtwald, Antreiber, Stille. Elysias Loop schrumpft nach Spielzeit und Fortschritt (`ELYSIA_STAGES`,
Wechsel am Loop-Ende, ADR-032). Während Dialogen −7 dB. Der Brunnen hat einen positionalen Wasser-Loop,
der Riss ein Brummen. Effekte aus `assets/generated/sfx/` (`tools/audio/make_sfx.py`, ADR-027) laufen
über je sechs Spieler pro Bus: `ui()` wählt das Klangset nach UI-Modus, `voice()` die Stimme aus
`content/dialogue/voices.json`.

## Übergang und Licht (ADR-025)

- `RiftSequence` (`world/fx/rift_sequence.gd`) inszeniert den ersten Übertritt; der Riss
  (`world/props/rift.tscn`) startet sie. Danach UI-Modus REAL, Inventar Stein und Samen, Tal.
- `DayLight` (`world/fx/day_light.gd`) in `LookScene` (`day_preset`): Regentag, Abend, Nacht.
  Die Bank im Tal (`pass_time`) und das Debug-Panel schalten weiter.
- Elysia-Objekte: Truhe (`chest.tscn`), Aufheben (`pickup.tscn`), Lob mit XP über Dialog-Mutationen.
- Während der Sequenz ist sie in der Gruppe `cutscene`: Pause-Menü und Tagebuch bleiben zu
  (`MenuLayer.any_open`), Speichern ist gesperrt und wird beim vorzeitigen Verlassen freigegeben.
- Wartezeiten in Szenenknoten laufen über `NodeTimer.after(owner, s)` statt
  `get_tree().create_timer()`: Der Timer stirbt mit seinem Besitzer, nichts läuft auf gelöschten Knoten weiter.

## Leistungstest

`core/benchmark/`: Startmenü „Leistungstest“ oder `--benchmark` (`=quick` für Smoke-Runs) fährt Elysia,
Tal und Wald je 12 s mit Bewegung ab und misst Frame-Zeiten (`FrameStats`). Bericht in
`benchmark.txt` im Nutzerordner, Ergebnis im Startmenü. Speichern ist dabei gesperrt.

## Build und Prüfung

- `tools/check.sh`: gdlint, gdformat, Import, Headless-Smoke-Runs (Menü, jede Szene, `--continue`), GUT.
  Automatische Läufe nutzen eigene Profile (`--profile=smoke`), nie die Spielstände des Spielers.
- `tools/export.sh windows|macos|linux`: Export mit Build-Stempel (Commit, Datum).
- `tools/smoke_export.sh`: startet den exportierten Linux-Build, prüft Boot, Stempel, jede Szene,
  vorhandene Quests und Items sowie das Laden eines Spielstands.
- `tools/capture.sh`: rendert Frames per Xvfb + OpenGL3 zur Sichtprüfung; Startargumente werden durchgereicht.
- `tools/autopilot/`: zeitgesteuerte Eingaben für Aufnahmen (nur Debug-Builds).
- `tools/placeholders/make_placeholders.py`: erzeugt die Grey-Box-Assets (ADR-014).
- `tools/audio/make_music.py`, `tools/art/make_ui.py`: Musik-Loops, UI-Rahmen, Truhe, Stein, Riss.
- CI: `.github/workflows/ci.yml` (ADR-009).
