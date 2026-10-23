# CLAUDE.md – Arbeitsregeln für REAL

REAL ist ein narratives Pixel-Art-RPG in Godot 4.7.2 (typisiertes GDScript). Der 45–60-minütige Vertical Slice
steht; das Playtest-Gate hat der Projektinhaber am 23.10. ohne Tester abgenommen (ADR-049). Jetzt läuft die
Vorproduktion für Full Production (`docs/PRODUKTIONSPLAN.md`): Inhalt entsteht nur nach dem Plan, in kleinen
Schritten, ein Pull Request je Phase. Die 0-€-Regel und Fragen bei großen Weichenstellungen gelten weiter.

## Zuerst lesen
- `docs/GAME_BIBLE.md` – verbindliche Produktvision. Abweichungen nur nach Rückfrage und ADR.
- `docs/DECISIONS.md` – getroffene Entscheidungen (Index oben; nur den passenden ADR lesen). `docs/ARCHITECTURE.md` – Aufbau und Status.
- `docs/TECH_MASTER_PROMPT.md` – Prozessregeln (Fragen bei großen Entscheidungen, 0-€-Regel, Cut-First).

## Befehle
- `tools/check.sh` vor jedem Push (Lint, Format, Import, Smoke-Run, GUT). Muss grün sein; rund 3 Minuten, die Tabelle am
  Ende zeigt die Zeit je Schritt. GUT läuft mit `--fixed-fps 60` (Spielzeit so schnell wie der Rechner rechnet, ADR-051);
  `GUT_FIXED_FPS=0 tools/check.sh` fährt in Echtzeit (rund 12 Minuten, vor jedem Phasenende und bei Zeitfehlern).
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
- Wartezeiten in Knoten mit `await NodeTimer.after(self, s)`, nicht `get_tree().create_timer()`. Zeitfenster
  im Spiel zählen Spielzeit (`delta`), nie die Wanduhr (`Time.get_ticks_*`): Autopilot-Läufe sind schneller.
- Rückfragen über `ConfirmMenu` (sichere Antwort vorausgewählt); Klänge mit Erzählwert brauchen einen Eintrag
  in `AudioDirector.CAPTIONS` („Geräusche als Text“, ADR-046).
- Karten sind Textdateien (`content/maps`, ADR-013); Platzhalter-Assets erzeugt `tools/placeholders`.
- Look-Grafik ist prozedural (ADR-017, `docs/ART_DIRECTION.md`): `tools/art/make_sprites.py`, dann
  `tools/art/bake_ground.py <karte>` nach jeder Änderung an Look-Karten. Braucht `requirements-art.txt`.
- Autopilot für reproduzierbare Aufnahmen: `tools/autopilot/*.json` (nur Debug; `tap` für Menüs/Dialoge).
- Elysia ist spiegelsymmetrisch (`[meta] symmetry`, ADR-031); das Startbild heißt „Elysia“, bis ein Stand
  die Wirklichkeit erreicht, danach „Nach Elysia“ (ADR-030, ADR-035; REAL bleibt Projektname;
  `--title=elysia|real` für Aufnahmen).
- Klänge: `tools/audio/make_sfx.py` (Effekte), `make_music.py` (Loops), `make_nature.py` (Wirklichkeit:
  Soundscapes in `content/audio`, ADR-034), `make_ambience.py` (Elysias Garten); Titel: `tools/art/make_title.py`.
  UI-Schriften nur über Theme-Typen (ADR-026); Shader auf Requisiten nie mit `UV` als 0..1 (Atlas, ADR-028).
- Zoom `view_zoom` überall 1,25×, scharf abgetastet (ADR-045); einzige Ausnahme sind Innenräume mit 1,5× in
  ihrer `.tscn` (das Haus, ADR-045 Nachtrag); Tiefen-Bogen (Dunst, `Backdrop`) nur in der Wirklichkeit
  (ADR-043). Welt→UI über `GameView.world_to_ui`. Waldränder der Wirklichkeit aus Kronen, nie Raster; Baumgrenze
  vor dem Himmel als `[meta] treeline` (gebacken, mit Waldreihen in die Tiefe).
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
- `tools/art/layout_slice_maps.py tal --write` löscht Handänderungen in `content/maps/tal.txt` (Buchstabe `6`,
  `unless` von `t`): vorher vergleichen.

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
