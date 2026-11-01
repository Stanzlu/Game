# CLAUDE.md – Arbeitsregeln für REAL

REAL ist ein narratives Pixel-Art-RPG in Godot 4.7.2 (typisiertes GDScript). Der Vertical Slice (Ziel 45–60 Minuten, im
Modell rund 21, ADR-065) steht; das Playtest-Gate hat der Projektinhaber am 23.10. ohne Tester abgenommen (ADR-049). Jetzt läuft die
Vorproduktion für Full Production (`docs/PRODUKTIONSPLAN.md`): Inhalt entsteht nur nach dem Plan, in kleinen
Schritten, ein Pull Request je Phase. Die 0-€-Regel und Fragen bei großen Weichenstellungen gelten weiter.

## Zuerst lesen
- `docs/GAME_BIBLE.md` – verbindliche Produktvision. Abweichungen nur nach Rückfrage und ADR.
- `docs/DECISIONS.md` – getroffene Entscheidungen (Index oben; nur den passenden ADR lesen). `docs/ARCHITECTURE.md` – Aufbau und Status.
- `docs/TECH_MASTER_PROMPT.md` – Prozessregeln (Fragen bei großen Entscheidungen, 0-€-Regel, Cut-First).

## Befehle
- `tools/check.sh` vor jedem Push (Lint, Format, Import, Smoke-Run, GUT). Muss grün sein; rund 3 Minuten, die Tabelle am
  Ende zeigt die Zeit je Schritt. GUT läuft mit `--fixed-fps 60` (Spielzeit so schnell wie der Rechner rechnet, ADR-051);
  `GUT_FIXED_FPS=0 tools/check.sh` fährt in Echtzeit (rund 12 Minuten, vor jedem Phasenende und bei Zeitfehlern). Ein Testskript, das nicht lädt oder nicht von `GutTest` erbt, lässt `check.sh` scheitern.
- Einzelne Testdatei: `tools/godot.sh --headless -s addons/gut/gut_cmdln.gd -gselect=test_log -gexit`
- `tools/export.sh <ziel>` und `tools/smoke_export.sh` für Builds; `tools/capture.sh` für Screenshots.
- gdtoolkit liegt in `.venv/` (`python3 -m venv .venv && .venv/bin/pip install -r requirements-dev.txt`).

## Aufbau in Kürze
- Szenen erben von `GameScene` (`world/game_scene.gd`); die Welt lebt im SubViewport der `GameView` (ADR-012).
- Spielzustand nur über den Autoload `WorldState` ändern (ADR-019); Speichern über `SaveSystem` (ADR-021,
  `docs/SAVE_FORMAT.md`), Einstellungen über `Settings` (ADR-018). Quests/Items sind `.tres` in `content/`,
  `ContentValidator` prüft sie und alle Dialoge (statische IDs, keine Fake Choices).
- Automatische Läufe mit `--profile=<name>` starten, damit nie echte Spielstände berührt werden (das letzte
  `--profile` gewinnt; `tools/capture.sh` legt je Aufnahme ein eigenes an).
- Musik/Ambience über `AudioDirector` (Szenen-Exports `music`, `ambience`), UI-Stil über `UiSkin.attach`
  (Elysia/Real folgt `WorldState.ui_mode`), Übergänge mit `ScreenFade`. Renderer: Compatibility (ADR-022).
- Weltknoten fragen den `Input`-Singleton ab; UI liegt in CanvasLayern und nutzt `_unhandled_input`.
- In `_process` bewegte Knoten: `physics_interpolation_mode = OFF`.
- Wartezeiten in Knoten mit `await NodeTimer.after(self, s)`, nicht `get_tree().create_timer()`; nie in einer Schleife auf `get_tree().physics_frame` oder `process_frame` warten (die Koroutine überlebt den Knoten, `check.sh` meldet „instance is gone“): eine Phase in `_physics_process` führen. Zeitfenster
  im Spiel zählen Spielzeit (`delta`), nie die Wanduhr (`Time.get_ticks_*`): Autopilot-Läufe sind schneller.
- Rückfragen über `ConfirmMenu` (sichere Antwort vorausgewählt); Klänge mit Erzählwert brauchen einen Eintrag
  in `AudioDirector.CAPTIONS` („Geräusche als Text“, ADR-046).
- Karten sind Textdateien (`content/maps`, ADR-013); Platzhalter-Assets erzeugt `tools/placeholders`.
- Look-Grafik ist prozedural (ADR-017, `docs/ART_DIRECTION.md`): `tools/art/make_sprites.py`, dann
  `tools/art/bake_ground.py <karte>` nach jeder Änderung an Look-Karten. Braucht `requirements-art.txt`. Der Bake schreibt
  einen Stempel (`tools/art/map_stamps.json`); `check.sh` meldet Karten, die nach einer Änderung nicht neu gebacken sind (ADR-052).
- Kleine Bilder (16×16, Kuriositäten, Fragmente, Schilder) als Text in `tools/art/small/*.pix`; `tools/art/pixelgrid.py` schreibt die PNG und prüft Größe, Palette und Umriss (ADR-057).
- Autopilot für reproduzierbare Aufnahmen: `tools/autopilot/*.json` (nur Debug; `tap` für Menüs/Dialoge). Autopilot v2 (ADR-065) wartet auf das Spiel (`wait_for`: Flag, Beat, Szene, Quest-Stufe, Gespräch), kennt `talk`/`use`/`enter` und relative Zeiten (`{"relative": true}`); `{"quest": "<id>", "stage": "<stufe>"}` stellt eine Quest über die echten Aufrufe auf eine Stufe (nur Debug; für ein Segment mitten im Akt); `akt1_full.json` spielt ganz Akt I (in `check.sh`), `calibrate.py --akt1` rechnet daraus; `akt2_full.json` spielt ganz Akt II aus dem eingefrorenen Stand am Ende von Akt I (ein Eintrag der Liste `segments` mit `@<stand>` statt einer Szene kopiert `tests/fixtures/saves/<stand>.json` als Autosave und startet mit `--continue`; ADR-069), `calibrate.py --akt2` rechnet daraus (Akt III ebenso, `akt3_full.json` aus `@v2_akt2_end`, `--akt3`). Ein späterer Akt schreibt sich in `calibrate.act_sources` ein (ein Test prüft, dass jede Story-Datei zu einem Akt gehört).
- Elysia ist spiegelsymmetrisch (`[meta] symmetry`, ADR-031); das Startbild heißt „Elysia“, bis ein Stand
  die Wirklichkeit erreicht, danach „Nach Elysia“ (ADR-030, ADR-035; REAL bleibt Projektname;
  `--title=elysia|real` für Aufnahmen).
- Klänge: `tools/audio/make_sfx.py` (Effekte), `make_music.py` (Loops als Ogg Vorbis über `encode.py`, braucht ffmpeg; WAV nur als Zwischenstand in `build/audio`, ADR-057), `make_nature.py` (Wirklichkeit:
  Soundscapes in `content/audio`, ADR-034), `make_ambience.py` (Elysias Garten); Titel: `tools/art/make_title.py`.
  UI-Schriften nur über Theme-Typen (ADR-026); Shader auf Requisiten nie mit `UV` als 0..1 (Atlas, ADR-028).
- Zoom `view_zoom` überall 1,25×, scharf abgetastet (ADR-045); einzige Ausnahme sind Innenräume mit 1,5× in
  ihrer `.tscn` (das Haus, ADR-045 Nachtrag; die Hütte schließt das Bild beim Bleiben auf 1,75 und 2,0, `GameView.zoom_to`, ein Schritt und nie ein Tween, ADR-070 O6); Tiefen-Bogen (Dunst, `Backdrop`) nur in der Wirklichkeit
  (ADR-043). Welt→UI über `GameView.world_to_ui`. Waldränder der Wirklichkeit aus Kronen, nie Raster; Baumgrenze
  vor dem Himmel als `[meta] treeline` (gebacken, mit Waldreihen in die Tiefe).
- Querprüfung `StoryLint` (`core/content/story_lint.gd`, Test `test_story_lint`): Türziele und Spawn-Marker, Cues, Quest-Stufen
  ohne Auslöser, gesetzte und nie gelesene Flags (Ausnahmen mit Begründung in `WRITE_ONLY_FLAGS`) und Facetten (`set_facet`/`has_facet` mit Literal), doppelte Marken, Effekte ohne
  Einstellung. Dafür Flags, Quest-IDs und Cues als Literale oder Konstanten schreiben, nicht aus Variablen bauen. Szenen-Schlüssel
  werden nie entfernt (umbenennen über `SceneRegistry.aliases`), Spielstand-Schemas behalten ein eingefrorenes Beispiel
  (`tests/fixtures/saves/v<N>_*.json`), Kapitel mit `Chapter.mark` (ADR-052).
- Story-Text prüfen `tools/writing/lint.py` (in `check.sh`, ADR-053): Vokabel-Lint gegen Therapie-, Diagnose- und Suchtsprache,
  Ziffern, Status-Tags `[#draft]`/`[#ok]` und die ID-Sperre `content/dialogue/ids.lock` (neue IDs mit
  `tools/writing/id_lock.py --update` sperren, eine ID nie still umbenennen: `--retire`). `note:`-Zeilen abarbeiten, eingefrorene
  (`[#ok]`) Zeilen nur mit `--refreeze` ändern. Statistik: `tools/writing/report.py`. Geschrieben wird gegen `docs/writing/`
  (`STIL.md`, Blatt der Figur in `stimmen/`, `MOTIVE.md` mit dem Konsequenzen-Register); `tools/writing/motifs.py` prüft
  Zitate und Flags, ein neues Story-Flag gehört in `docs/writing/motive.json` (dann `motifs.py --write`). Tests nennen Zeilen über
  `LineText.of("<id>")`, nie über den Wortlaut; die Lesefassung eines Segments erzeugt `tools/writing/readable.py` (ADR-056).
- Vertical Slice: Orte `elysia`, `tal`, `haus`, `weg` (`world/levels/slice/`, ADR-037). Geschichte nur über
  WorldState (Flags, Quests, Haus); Karten-Requisiten reagieren mit `if`/`unless`/`sprite_when`, Szenen-Skripte
  inszenieren nur. Slice-Dialoge in `content/dialogue/slice/` ohne `[#ph]` (ADR-036), Erzählzeilen ohne
  Doppelpunkt. Das Ende ist Schwarz, dann der Titel ohne Zeile (Bible §56); die Schlusszeile steht im Startmenü
  unter dem Logo. Durchlauf ohne Hand: `--autopilot=res://tools/autopilot/slice_full.json`; `check.sh` spielt
  ihn bis zum Ende, also bei geänderten Menüabläufen das Skript mitziehen. Testläufe nutzen je Prozess ein
  eigenes Profil.
- Ton wird gemessen, nicht gehört: Effekte sind nach Lautheit je Gruppe normiert (`make_sfx.GROUPS`,
  `make_slice_sfx.GROUPS`, `tools/audio/loudness.py`); die Aufrufgains stehen in der Tabelle `CLASSES` von
  `tools/audio/check_levels.py` (Schritt „audio levels“ in `check.sh`, braucht numpy; `note:`-Zeilen
  abarbeiten). Musikpausen, Loops und Elysias Stufen zeigt nur `tools/audio/measure.sh`: Headless-Läufe rücken
  das Audio nicht vor.
- Dialoge: Antworten mit Bedingung verschwinden, wenn sie nicht zutreffen. Jede Antwortgruppe braucht also eine
  unbedingte Antwort, eine Antwort mit `{{Wert}}` eine Bedingung auf den Wert, Texteffekte (`[wave]`,
  `[rainbow]` …) stehen nur in gesprochenen Zeilen (Validator, `test_dialogue_box`). Mehrzeilige CSV-Texte mit
  echten Zeilenumbrüchen, nie mit `\n`.
- Pause im Gespräch: `MenuLayer.can_pause` lässt das Pause-Menü in Zwischensequenzen nur zu, solange
  `Cutscene.in_dialogue` gilt; Gespräche dort laufen über `Cutscene.say()`, zeitgesteuerte Phasen bleiben
  gesperrt. Overlays, die einer Weltposition folgen, liegen in einer eigenen CanvasLayer (Prompt 11 unter HUD
  12) und rechnen mit `GameView.world_to_ui(...).round()`.
- Fenster-X und Fokusverlust regelt `AppGuard`, Controller-Hotplug `InputDevice`; `Beat.mark` löst einen
  Autosave aus. Nach `change_scene_to_file` ist `get_tree()` im freigegebenen Knoten null: den `SceneTree`
  vorher merken.
- Tasten: Belegungen nur über `Settings.bindings` (`InputBindings`, ADR-048). Feste Tasten (Esc, Enter, Start, A auf
  `interact`, Pfeile/WASD/Steuerkreuz in Menüs) sind die Schutzregeln gegen Aussperren; `ControlsMenu` erfasst über
  `BindingCapture`. Hinweise mit Tastennamen holen `InputDevice.label_for(...)` und frischen sich über
  `InputDevice.labels_changed` auf (`Settings.changed` nur für Werte). Der Autopilot tippt echte Tasten mit `key`/`pad`.
  Die Erfassung ist der eine bewusste `_input`-Verbraucher der UI (`ControlsMenu`, sie ruft `InputDevice.observe` selbst
  auf). Seiten, die ein Menü öffnet, hängt `MenuLayer.stack` an; folgt das Menü der Welt nicht (Startmenü), erben sie
  dessen Theme.
- Karten und Elysia (ADR-055): `MapLint` prüft in GUT jede Karte (Spawn, Erreichbarkeit, feste Zellen, Spiegelsymmetrie;
  `tools/art/map_overview.py content/maps/<karte>.txt` zeichnet sie). Elysia-Szenen hängen `ElysiaDirector.attach(self)` an (Uhr und Stufen-Flags
  `elysia.loops_1`/`_2`/`loops`), Sammelstücke gehen über `Collection`, Szenenlisten für Smoke und Leistungstest stehen in
  `SceneRegistry.SMOKE`/`BENCHMARK`. Dauer eines Segments rechnet `tools/writing/calibrate.py` (`docs/KALIBRIERUNG.md`).
- Akt I (ADR-058, `docs/akt1/REGIONSBRIEFE.md`): Szenen in `world/levels/akt1/`, Dialoge in `content/dialogue/akt1/` (`[#draft]`, kein `[#ph]`), Requisiten in `tools/art/akt1_props.py`. Jedes Segment trägt einen Brief, ein Segmentskript
  `tools/autopilot/akt1_<segment>.json` und seine Marken in der Liste `segments` von `tools/check.sh` (Beats und Flags, die der Lauf erreichen muss). Die Heldenquest `main_elysia_hero`
  wächst je Segment um eine Stufe; die Schleifen (`elysia.loops`) beginnen mit dem Hoch auf dem Fest (`elysia.feast_toast`, Stufe `repeat`, A7), wortgleiche Zeilen wählt allein `elysia.loops`, Schleife 2 (`elysia.rift_open`) gibt es nur für Torwächter, Festmeisterin und Gastwirt (ADR-064); der Stein liegt erst mit der Schleife. Tests spielen Dialoge mit `DialogueWalk` (`tests/unit/dialogue_walk.gd`) und nennen Zeilen über `LineText.of(id)`.
- Große Karten (ADR-068): Klasse M bis 120 × 70 Zellen (Aufbau rund 0,5 s); `tools/perf/map_spike.py` misst gekachelte Tal-Karten (`tools/art/tile_map.py`, Ausgabe in `spike_tmp/`, nicht versioniert); Symbole dürfen außerhalb von ASCII liegen, aber nie ein Leerzeichen sein (auch kein Unicode-Leerzeichen). Das Layout einer Karte landet in einem Pull Request.
- Akt II (ADR-067, `docs/akt2/REGIONSBRIEFE.md`): Segmente V0 bis B7 mit Brief, Segmentskript und Marken wie in Akt I; Kapitelmarken `act1` (am Riss) und `act2`; Skript je Akt `tools/autopilot/akt<N>_full.json`. Dialoge in `content/dialogue/akt2/` (`[#draft]`, kein `[#ph]`); jede neue Datei steht in der POT-Liste der `project.godot`, ein neuer Ordner in `STORY_DIALOGUES` (`test_content`); Szenen-Skripte starten Erzählzeilen mit `Cutscene.begin`/`say` und markieren danach den Beat. Eine Facette zeigt sich als Antwort mit `[if WorldState.has_facet("…") /]` neben den unbedingten Antworten, das Schweigen „…“ bleibt die letzte (Karten kennen nur Flags: die Szene leitet einen Flag aus der Facette ab, `house.looks_closely`). Szenen-Tests antworten der echten Box mit `BoxAnswers.pick` (sie wählt nie selbst, auch nicht mit Auto-Weiter), `DialogueWalk.groups` listet die erlaubten Antworten je Wahl; `readable.py` nimmt `datei.dialogue#cue,cue` für das Delta in einer älteren Datei. Karten der Klasse M (B3, `bachlauf`) schreibt ein Generator, `tools/art/layout_akt2_maps.py bachlauf --write` (der Kopf der Karte ist von Hand, `test_layout_akt2.py` vergleicht), Requisiten stehen in `tools/art/akt2_props.py` (Stil `tal`; `make_sprites.py` vor dem Backen); ein neuer Szenenschlüssel gehört in `SceneRegistry.SCENES`, `SMOKE` und `BENCHMARK` und braucht `PLACE_<SCHLÜSSEL>` in `ui.csv`; das HUD zeigt in der Wirklichkeit keine Fragmentkarte, die Zeilen tragen das Fragment. Fragmente: sechs Bilder des Kindes (Akt I und V), alle anderen Spuren der Welt (Plan 5.5); `Collection.fragments()` zählt beide, Akt V liest die sechs Kind-Flags einzeln. Werte (Bible §18) sind Flags `value.<id>` (`freedom`, `closeness`, `calm`; das Schweigen setzt keines); eine Wahl und ihr Leser stehen nie im selben Cue (B5, `feuer.dialogue`), und die Szene `haus` zeigt die Folge als Ding im Raum. Das Lied im Haus ist `melody.house_hum` (hörbar, kein Fragment). Mira liest die Werte am Abend nur als Spur, die man von ihrem Platz aus sieht oder hört, nie als Wertwort (B6, Cue `evening_values`); `Chapter.mark("act2")` steht einmal vor `Chapter.mark("slice")` im Ende des Tals. Der Richter heißt in Akt II „Stimme“ (`voices.json`), spricht genau einmal beim zweiten Sturz und nur über Dinge, nie über die Spielerin (B4, Beat `act2_richter`).
- Akt III (ADR-070, `docs/akt3/REGIONSBRIEFE.md`): Segmente V0, W1 bis W7 mit Brief, Segmentskript und Marken wie in Akt II; „Weiter“ nach dem Ende von Akt II beginnt den Morgen danach (gebaut in W1: Tor `Chapter.reached("slice")` ohne Beat `act3_morning`, Voreinstellung `morgen`, Mira fort über `valley.mira_gone`), der Weg führt durch den Bachlauf nach Süden in den Wald; „fertig“ (Menüzeile, Rückfrage bei „Neues Spiel“) heißt, dass der neueste Stand `Chapter.LAST` erreicht hat, und `Chapter.reached("act3")` steht nie im Spielcode, bevor ein Akt das Kapitel setzt; der Lauf `akt3_full.json` beginnt mit `@v2_akt2_end` und spielt ganz Akt III (in `check.sh`, endet im Haus; `calibrate.py --akt3` rechnet daraus; sein letzter Autosave ist der eingefrorene Stand `tests/fixtures/saves/v2_akt3_end.json`, in dem Akt IV beginnt). Alle Dialoge in `content/dialogue/akt3/` (auch die des Hauses, damit `calibrate.act_sources` sauber bleibt; `akt3` steht dort seit V0, `BASELINES`, `START_SAVES` und `ACT_STARTS` seit W7); Fürsorge (`care`) setzt das Rasten am Rastplatz, nie eine Zahl; der Einsiedler lässt bleiben (drei Stufen, jede eine Antwort, nie eine Uhr), Werkbank und Gäste sind Flags (`house.workbench`, `house.guest_<id>`), kein Schema 3. W2 (`waldweg`, Klasse M, Layout `tools/art/layout_akt3_maps.py waldweg --write`, Requisiten `tools/art/akt3_props.py`): die Tür im Süden des Bachlaufs braucht `beat.act3_morning` (davor schließt ein Blocker die Lücke am Kartenrand); die erste Rast setzt `care` und `forest.rested` (der Hang geht danach im vollen Tempo), jeder Ring hat sein Feuer-Flag (`forest.fire_1`/`_2`); der Antreiber fehlt auf dem Weg, wenn er im Haus am Feuer sitzt, und fehlt im Tal, sobald `forest.antreiber_met` gilt; der Südausgang ist seit W4 die Tür in die `flutlichtung` (Ankunft `w` vier Zeilen über ihr, der Waldweg bleibt dabei unverändert gebacken). W4 (`flutlichtung`, Klasse M, 88 × 54, Layout `tools/art/layout_akt3_maps.py flutlichtung --write`, Requisiten `tools/art/akt3_props.py`): das Warum des Antreibers sind drei Dinge (die Spur eines Läufers, das Lager mit der roten Kreidelinie, die Marke mit der Schlicklinie über Kopfhöhe an jeder Buche der Lichtung), keine Zeile erklärt es; `forest.flood_seen` (Cue `flood_mark`) erfüllt das Ziel `flood`, die Szene spiegelt den Auslöser der Hütte (`night`, wenn `hermit` schon erfüllt ist); der Antreiber steht an der Marke (Figur A), mit der Antwort „Setz dich. Es gibt Tee.“ (nur mit `care`) sitzt er auf dem Boden (Figur E, `forest.flood_sat`), und beim ersten Betreten der Lichtung (nie am Feuer im Haus) setzt die Szene `forest.antreiber_ahead`, das ihn im Waldweg und im Tal (Glyphen A, E, t, 6) wegräumt, damit er nie an zwei Orten steht; Nebenquest B `side_forest_nest` (Nest aufheben, in die Gabel legen), Treibholz (Kuriosität), Trittsteine (Fragment); die Lücke im Südrand trägt einen Blocker (Cue `south_wait`), der mit `unless forest.night_way` weicht, sobald die Heldenquest in `night` steht (das Flag setzen `FlutlichtungScene` und `HuetteScene`, nie ohne Quest), ein Layout ändert sich nach dem Bake nicht mehr (ADR-068). W5 (`nachtwald`, Klasse S, 44 × 34, Layout `tools/art/layout_akt3_maps.py nachtwald --write`): das Warten (O10) ist eine Laterne am Boden, die bleibt, wo sie ist; wer sich neben sie setzt, hört das Summen genau einmal (`forest.waited` mitten im Cue, die Szene spielt `child_hum` und markiert `act3_waiting`), kein Kind, kein Fragment, nichts gezählt; die Nacht sind Exporte der Szene (`world_tint` und Verwandte), nie `day_preset` (die Voreinstellung ist globaler Zustand), kein `PointLight2D` im Wald (Leuchtbäume, Laterne und Leuchtholz sind gebackenes Glühen mit `emissive`); die Tür nach Süden führt ins Tal (`spawn_bach`), `night` bleibt Endstufe bis W6. W3 (`huette`, Klasse S von Hand, Zoom 1,5, `huette_scene.gd`): die Tür in `waldweg` ist nie abgeschlossen und nie gesperrt, was vor ihr liegt (Becher, Zweige, Kiesel, Leine: Stellen `C`, `Z`, `Y`, `X`) setzt der Generator nach der Streuung, damit der Wald bleibt, und die Requisiten haben keinen Schatten im Katalog, damit der Stempel bleibt; beim Sitzen auf dem Hocker fragt die Szene einmal je Sitzen (`stay`), jede Antwort „Bleiben“ setzt `forest.hut_stay_N` (1 bis 3) und schließt das Bild (1,75, 2,0, 2,0), nur solange sie sitzt, nie nach Zeit; Aufstehen gibt 1,5 sofort zurück, ein geladenes Spiel beginnt nie eng, nach der dritten steht die Tür offen und das Spiel speichert einmal; die Quest `main_forest_way` hat in `wood` die Ziele `hermit` (beim Betreten) und `flood` (W4) und danach `night`; die Flöte (`melody.hermit_flute`) spielt beim ersten Sitzen. W6 (`haus`, `tal`, `akt3/heimkehr.dialogue`, `haus_scene.gd`): die Heimkehr ist eine Cutscene als Phasenautomat in `_physics_process` beim ersten Betreten des Hauses in der Stufe `home` (`home` setzt `TalScene._ready` aus `night`, `done` das Haus am Ende: ein Block ohne Warten mit `Chapter.mark("act3")` und Beat `act3_home`, still, ohne Titel); `house.workbench` setzt das Haus vor dem Bau der Karte (Quest in `home`/`done`), die Karte liest es (Werkbank `B`, Antreiber `A`, Katze `Z`, Plan `Y`; `a`, `z`, `k` am Feuer und `A`, `E` der Flutlichtung tragen `unless house.workbench`: der Antreiber ist nie an zwei Orten), der Stuhl `C` steht mit `house.guest_hermit` (Besuch des Einsiedlers nur mit `forest.hermit_invited`, der Akt hängt nie am Gast), neue Haus-Requisiten ohne Katalogschatten und bedingt, damit der Stempel bleibt (kein Bake), das Tal bleibt der Morgen (der Zaun `B` ist mit der Bank geflickt).
- Akt IV (ADR-071, `docs/akt4/REGIONSBRIEFE.md`): V0 (Brief, Voreinstellungen O1 bis O20) ist gebaut, die Segmente S1 bis S10 folgen (Straße, Platz, Blumenladen, Werkstatt, Liste, Konzert, Streit, Heimkehr, Durchlauf, Handschrift); der Anfang ist `tests/fixtures/saves/v2_akt3_end.json` (still im Haus, ohne Menü), der Weg ist der Westweg des Tals (nach `chapter.act3` weicht der Blocker `V` einer Tür, nur `,`-Zellen: kein Bake). Die Stadt sind zwei Karten der Klasse M (`strasse`, `stadt`) und drei Innenräume der Klasse S (`rathaus`, `blumenladen`, `werkstatt`), keine Karte der Klasse L; Generator `tools/art/layout_akt4_maps.py`, Requisiten `tools/art/akt4_props.py`. Alle Dialoge in `content/dialogue/akt4/` (auch die des Hauses; der Ordner entsteht mit S1 und gehört dann in `STORY_DIALOGUES` und die POT-Liste); `calibrate.act_sources("akt4")` kennt ihn seit V0, `BASELINES`, `START_SAVES`, `ACT_STARTS` und `akt4_full.json` (`@v2_akt3_end`) folgen in S9. Der Gefällige spielt eine Liste (Nummern bis 19, bis zu drei Aufgaben tun, zu den übrigen Nein: jede Folge im Raum, keine Uhr, nie im selben Cue wie die Wahl), Verbindung (`city.asked_help`, Hilfe erbitten) und Integrität (Wahl nach den Werten aus Akt II) brauchen Setzer und Leser im selben Pull Request, Beziehungen und Facetten bleiben ohne Zahl im Bild; `Chapter.LAST` wird mit S1 `act4`, `Chapter.mark("act4")` steht am Ende von S8 (still, im Haus), kein Schema 3 (Liste, Gäste und Regale sind Flags, Quest-Ziele und `curiosity_slots`). Das Konzert (S6) ist die erste Nachtkarte der Stadt mit höchstens acht `PointLight2D` (Rückfall gebackenes Glühen), der Skin „persönlich“ (S10) ist Cut-First-Platz 1.
- `tools/art/layout_slice_maps.py tal --write` ersetzt nur den `[map]`-Block von `content/maps/tal.txt`; seit B3 deckt der Generator
  auch die Marke `6` und die Lücke in der Hecke (Marken `7`, `8`, `9`) ab, Änderungen der Legende bleiben von Hand: vorher vergleichen.

## Konventionen
- Statisch typisiertes GDScript, `gdformat`-formatiert, `gdlint`-sauber. Tabs. Lambdas kopieren einfache Locals
  (bool, float, String): Zustand für `wait_until` und Signalhandler in Array oder Dictionary halten;
  Tests messen Zeit nie mit der Wanduhr (`Time.get_ticks_*`), sondern in Spielzeit (`get_physics_process_delta_time()` je
  Prüfaufruf); Testschleifen zählen Frames lokal, nie mit `get_tree().get_frame()`. Was sich in `_process` oder nach
  `process_frame` aufbaut (Menü-Layout, `MenuCursor`), wartet der Test mit `wait_process_frames` ab: Unter Last laufen
  mehrere Physik-Schritte in einem Bild, `wait_physics_frames` ist dort zu früh fertig.
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
- CI: Der GitHub-Workflow `CI` (`.github/workflows/ci.yml`, ADR-009) führt bei jedem Push `tools/check.sh` aus (Stand 23.10.
  läuft er, Ergebnis als Check-Run am Pull Request); Exporte nur auf `main`, bei `[export]`, manuell oder auf einem Tag, ein
  manueller Lauf mit „release“ legt den Release-Entwurf an. Ist der Workflow abgeschaltet, ersetzt ihn `local-ci`
  (`local-ci status`, `local-ci run game <branch|sha>`). `PASS_2.VERSUCH` heißt: erster Versuch rot, zweiter grün (kein
  sauberes Grün). `check.sh` schreibt am Ende die Zeit je Schritt.

## Cloud-Umgebung
- Ein SessionStart-Hook installiert Godot 4.7.2 automatisch.
- Kein Vulkan im Container: Screenshots laufen über OpenGL3 (`tools/capture.sh`).
- Asset-Seiten wie kenney.nl sind blockiert, GitHub-Releases und PyPI sind erreichbar.
