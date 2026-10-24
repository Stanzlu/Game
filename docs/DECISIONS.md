# Entscheidungen (ADRs)

Kurzform: Kontext · Entscheidung · Konsequenzen. Neue Einträge unten anhängen, alte nicht löschen,
sondern mit „Ersetzt durch ADR-xxx“ markieren. Grundlage: [`PRE_IMPLEMENTATION_REVIEW.md`](PRE_IMPLEMENTATION_REVIEW.md).

---

## Index

Zum Nachschlagen: Nur den ADR lesen, der zur Aufgabe passt (die Datei ist groß). Der Index steht oben, neue ADRs hängen unten an und kommen hier hinein (`tools/adr_index.py` erzeugt ihn).

| ADR | Titel |
|---|---|
| ADR-001 | Engine: Godot 4.7.2 mit typisiertem GDScript |
| ADR-002 | Sprache Deutsch, Lokalisierung vorbereitet |
| ADR-003 | Placeholder: CC0 bzw. OFL, austauschbar |
| ADR-004 | Level-Layouts als Textkarten |
| ADR-005 | Plattformen: Desktop-only für den Slice |
| ADR-006 | Dependencies: vendored und gepinnt |
| ADR-007 | Darstellung: 640×360, Integer-Scaling, Nearest |
| ADR-008 | Savegames als JSON |
| ADR-009 | CI-Budget |
| ADR-010 | Git-Workflow: ein Branch und ein Pull Request pro Phase |
| ADR-011 | Eingabe über Actions, physische Tasten, alle Geräte |
| ADR-012 | Welt im SubViewport, zwei Kameramodi |
| ADR-013 | Kartenformat im Detail |
| ADR-014 | Programmatische Grey-Box-Platzhalter |
| ADR-015 | Regeln des Antreiber-Prototyps |
| ADR-016 | Testoptionen und Autopilot in Phase 1 |
| ADR-017 | Look-Pipeline: eigene, prozedural erzeugte Pixel-Art |
| ADR-018 | Einstellungen als JSON, getrennte Profile für automatische Läufe |
| ADR-019 | Spielzustand und Inhalte |
| ADR-020 | Dialoge mit statischen IDs und geprüften Zustandsaufrufen |
| ADR-021 | Speichern im Spiel |
| ADR-022 | Renderer: Compatibility (OpenGL 3) auf allen Plattformen |
| ADR-023 | Musik: eigene prozedurale Loops und ein AudioDirector |
| ADR-024 | UI-Bogen: Elysia-Skin mit HUD, Real-Skin fast leer |
| ADR-025 | Übergangssequenz und Tageslicht |
| ADR-026 | Schrift und Bewegung der Oberfläche |
| ADR-027 | Soundeffekte: eigene, prozedural erzeugte Klänge |
| ADR-028 | Requisiten-Atlas je Stil |
| ADR-029 | Spielstand Schema 2 |
| ADR-030 | Zwei Startbilder: Elysias Schein-Titel, REAL erst nach dem Übertritt |
| ADR-031 | Elysia perfekt, die Wirklichkeit ungepflegt |
| ADR-032 | Elysias Loop schrumpft |
| ADR-033 | Idle-Animationen und große Schrift überall |
| ADR-034 | Naturklang der Wirklichkeit: Schichten und Zufall statt Schleife |
| ADR-035 | Der wahre Titel heißt „Nach Elysia“ |
| ADR-036 | Slice-Texte sind Playtest-Text, Prototypen bleiben markiert |
| ADR-037 | Die Geschichte steht in Flags, Karten und Szenen reagieren darauf |
| ADR-038 | Der Antreiber im Slice: dieselben Regeln, neues Gewand |
| ADR-039 | Das Haus von innen: kleine Karte, gemalte Raumhülle |
| ADR-040 | Der Slice nach dem Bible-Abgleich: mehr Leben, keine neuen Systeme |
| ADR-041 | Die Wirklichkeit warm gemalt (Ghibli-Gefühl), Elysia bleibt Hochglanz |
| ADR-042 | Tiefe statt Breite: der Slice nach dem Abgleich mit vier Referenzspielen |
| ADR-043 | Zoom und Tiefen-Bogen: Elysia flach, die Wirklichkeit näher und tiefer |
| ADR-044 | Playtest-Gate: Release-Entwurf auf Versions-Tag, Beat-Zeilen in jedem Build |
| ADR-045 | Nach dem ersten Spielen: Zoom 1,25× überall, gewachsene Waldränder, Gate-Schwellen |
| ADR-046 | Polish-Runde: Gefühl, Bedienung, Erzählung, Technik, Bild und Ton |
| ADR-047 | Polish-Runde 2: Ton nach Lautheit, Erwachen und Ende, Bedienung, Figuren und Bild |
| ADR-048 | Tastenumbelegung: Modell, Schutzregeln und Oberfläche |
| ADR-049 | Playtest-Gate ohne Tester: Freigabe der Vorproduktion für Full Production |
| ADR-050 | Arbeitsannahmen für Full Production |
| ADR-051 | Unit-Tests mit fester Bildrate |
| ADR-052 | Speicher-Politik, Kapitelmarken, Kartenstempel und Querprüfung (P6.2) |
| ADR-053 | Schreibwerkzeuge: Status-Tags, ID-Sperre, Vokabel- und Zahlen-Lint (P6.3) |
| ADR-054 | Stilbuch, Stimmenblätter und Motivbuch (P6.4) |
| ADR-055 | Karten-Linter, Elysia-Regler, Registerlisten und Kalibrierung (P6.6) |
| ADR-056 | Writing-Pass auf den Slice, Lesefassung und Tests auf Zeilen-IDs (P6.5) |
| ADR-057 | Entscheidungen 1 und 2 des Produktionsplans, Musik als Ogg Vorbis, kleine Bilder als Text (P6.7) |
| ADR-058 | Akt I: Aufbau der Segmente, Segmentskripte und das Gasthaus (P6.8) |
| ADR-059 | Akt I: der Markt von Elysia, Gold ausgeben und die Stufe „market“ (P6.9) |
| ADR-060 | Akt I: die Halle der Spiegel, Wahrnehmung als Aufgabe und die erste Facette (P6.10) |
| ADR-061 | Akt I: das Fest, Erfahrung für ein Glas und Level 48 (P6.11, A6) |
| ADR-062 | Akt I: die Wiederholung beginnt mit dem Hoch, Musikstufen nach Fortschritt, lange Uhr (P6.11, A7) |
| ADR-063 | Akt I: die Spur des Kindes, drei Fragmente und die Melodie (P6.12, A8) |
| ADR-064 | Akt I: Stein nach dem Hoch, der Samen in Elysia, Schleife 2 in Schritten (P6.12, A9) |

---

## ADR-001 · Engine: Godot 4.7.2 mit typisiertem GDScript
- **Status:** angenommen · 2026-10-02
- **Kontext:** 2D-Pixel-Art, Licht, Wetter, kein Combat, Desktop zuerst, 0 €, Arbeit mit Claude Code ohne GUI in der Cloud.
- **Entscheidung:** Godot 4.7.2-stable (gepinnt in `tools/godot_env.sh`), GDScript mit statischer Typisierung. `untyped_declaration` ist ein Fehler, `unsafe_*` sind Warnungen.
- **Konsequenzen:** MIT, keine Lizenzkosten. Szenen und Ressourcen sind Textdateien. Headless-Import, Tests und Exporte laufen per CLI. Konsolen-Ports später nur über kostenpflichtige Partner. Ein Versionswechsel ist eine eigene Entscheidung mit neuem ADR.

## ADR-002 · Sprache Deutsch, Lokalisierung vorbereitet
- **Status:** angenommen · 2026-10-02
- **Entscheidung:** Quellsprache ist Deutsch (`de`), Fallback-Locale `de`. UI-Texte stehen in `content/locale/*.csv` mit Schlüsseln in `UPPER_SNAKE_CASE` und werden nur über `tr()` angezeigt. Dialogzeilen bekommen in Phase 2 statische IDs des Dialogue Managers.
- **Konsequenzen:** Englisch kann später als weitere CSV-Spalte bzw. Übersetzung ergänzt werden, ohne Logik zu ändern. Die Schrift muss Umlaute, ß und typografische Anführungszeichen können.

## ADR-003 · Placeholder: CC0 bzw. OFL, austauschbar
- **Status:** angenommen · 2026-10-02
- **Entscheidung:** Bis zur Validierung nur klar lizenzierte Placeholder (CC0, für Schriften OFL). Jede Datei steht in [`PLACEHOLDERS.md`](PLACEHOLDERS.md). Assets werden nur über Szenen und Ressourcen referenziert, nie über Logik. Solange Asset-Seiten in der Cloud-Umgebung blockiert sind, werden einfache programmatische Placeholder verwendet.
- **Schrift:** Tiny5 (OFL 1.1). Ausgewählt per Render-Vergleich gegen Pixelify Sans, Silkscreen, Micro 5, VT323 und Jersey 10: sauberes 8-px-Raster, verlustfrei in ganzzahligen Vielfachen skalierbar, Umlaute, ß, „…“, Latin-Ext, Griechisch, Kyrillisch. Import ohne Antialiasing, Hinting und Subpixel-Positionierung.
- **Konsequenzen:** Playtester müssen gebrieft werden, dass Grafik und Musik Platzhalter sind.

## ADR-004 · Level-Layouts als Textkarten
- **Status:** angenommen · 2026-10-02 · Umsetzung ab Phase 1
- **Entscheidung:** Tile-Layouts liegen als ASCII-Karten in `content/maps/<map>.txt` mit einer Legende (Zeichen → Terrain, Oberfläche, Kollision). Objekte, NPCs und Trigger liegen in `.tscn`-Szenen.
- **Konsequenzen:** Claude kann Level vollständig bauen, der Projektinhaber kann sie im Texteditor ändern. Ein späterer Wechsel zu Tiled oder LDtk bleibt mit derselben Legende möglich.

## ADR-005 · Plattformen: Desktop-only für den Slice
- **Status:** angenommen · 2026-10-02
- **Entscheidung:** Builds für Windows (x86_64) und macOS (universal, ad-hoc signiert, nicht notarisiert). Linux wird nur für CI und Smoke-Tests exportiert. Kein Mobile, keine Touch-UI.
- **Konsequenzen:** 0 € (kein Apple-Developer-Account). Tester sehen Warnungen von SmartScreen bzw. Gatekeeper (Anleitung im README). Input, UI-Skalierung und Save-Pfade bleiben abstrahiert, damit Mobile später möglich bleibt.

## ADR-006 · Dependencies: vendored und gepinnt
- **Status:** angenommen · 2026-10-02
- **Entscheidung:** Dialogue Manager 4.1.0 und GUT 9.7.1 liegen unverändert in `addons/`. gdtoolkit 4.5.0 ist in `requirements-dev.txt` gepinnt. Details in [`DEPENDENCIES.md`](DEPENDENCIES.md).
- **Konsequenzen:** Reproduzierbare Builds ohne Netz. Updates sind bewusste Schritte. Die automatische POT-Pflege des Dialogue Managers ist abgeschaltet, damit Testdateien nicht in Übersetzungsvorlagen landen. C#-Varianten des Addons werden vom Export ausgeschlossen.

## ADR-007 · Darstellung: 640×360, Integer-Scaling, Nearest
- **Status:** vorläufig · 2026-10-02 · Stretch-Modus und Snapping ersetzt durch ADR-012; Renderer ersetzt durch ADR-022
- **Entscheidung:** Viewport 640×360, Fenster 1280×720, Stretch-Modus `viewport`, Skalierung `integer`, Texturfilter Nearest, Pixel-Snapping für 2D-Transforms. Arbeitsraster 16-px-Tiles. Renderer Forward+ mit OpenGL3-Fallback.
- **Konsequenzen:** Scharfe Pixel bei 720p, 1080p, 1440p und 4K. Ruhiges Kamerascrolling braucht in Phase 1 einen Subpixel-Ansatz. ETC2/ASTC-Import ist aktiv, weil universelle macOS-Exporte es verlangen; Pixel-Art nutzt verlustfreie Texturen.

## ADR-008 · Savegames als JSON
- **Status:** angenommen · 2026-10-02 · Umsetzung Phase 2
- **Entscheidung:** Spielstände sind JSON-Dateien mit `schema_version`, atomar geschrieben (temporäre Datei, dann Umbenennen) und mit Backup. Kein `str_to_var` und kein Laden von Godot-Ressourcen aus dem Nutzerverzeichnis.
- **Konsequenzen:** Aus Savegames kann kein Code ausgeführt werden. Migrationen sind explizite Funktionen pro Schema-Version. Details in [`SAVE_FORMAT.md`](SAVE_FORMAT.md).

## ADR-009 · CI-Budget
- **Status:** angenommen · 2026-10-02
- **Kontext:** Privates Repository: 2.000 Actions-Minuten und 500 MB Artefakt-Speicher pro Monat kostenlos.
- **Entscheidung:** Nur Ubuntu-Runner. Checks (Lint, Format, Import, Smoke-Run, Tests) bei jedem Push. Exporte nur auf `main`, per manuellem Start oder wenn die Commit-Nachricht `[export]` enthält. Artefakte werden 2 Tage aufbewahrt (vorher 7; das Gratiskontingent von GitHub Free erlaubt nur 500 MB Artefakt-Speicher, ein Windows/macOS-Paar hat rund 100 MB, und darüber blockiert GitHub ohne Zahlungsmethode alle Actions-Jobs). Kein Git LFS.
- **Konsequenzen:** Keine Kosten. Playtest-Builds für Phase 5 kommen als GitHub-Release, das nicht auf den Artefakt-Speicher zählt.

## ADR-010 · Git-Workflow: ein Branch und ein Pull Request pro Phase
- **Status:** angenommen · 2026-10-02
- **Entscheidung:** Jede Phase entsteht auf einem eigenen Branch mit kleinen Commits. Am Phasenende öffnet Claude einen Pull Request mit Zusammenfassung, Testergebnissen und offenen Punkten. Der Projektinhaber merged.

## ADR-011 · Eingabe über Actions, physische Tasten, alle Geräte
- **Status:** angenommen · 2026-10-02
- **Entscheidung:** Gameplay-Code fragt nur Actions ab (`move_*`, `interact`, `cancel`, `sprint`, `menu`, `journal`, `debug_overlay`). Tastaturbelegungen nutzen physische Tastencodes, damit WASD auf QWERTZ, QWERTY und AZERTY an derselben Stelle liegt. Alle Events gelten für alle Geräte (`device = -1`). Ein Test sichert beides ab.
- **Konsequenzen:** Rebinding ist technisch vorbereitet. Die Rebinding-Oberfläche folgt nach dem Slice.
- **Nachtrag 22.10. (ADR-047):** Das Umbelegen von Tasten kommt nicht erst nach dem Slice, sondern als eigener Pull Request unmittelbar nach der Polish-Runde 2 und vor dem Playtest (Bible §50 verlangt es von Anfang an; Linkshänder, AZERTY und Barrierefreiheit brauchen es). Es bekommt einen eigenen ADR, weil `controls_menu`, `input_device` und `settings` dabei umgebaut werden. Bis dahin bleibt „Steuerung anzeigen“ eine Lesetafel.
- **Nachtrag (ADR-048):** Gebaut mit ADR-048: Seite „Tastenbelegung“ (Pause-Menü, Einstellungen), feste Schutzereignisse, Format Version 2. „Steuerung anzeigen“ ist keine Lesetafel mehr.

## ADR-012 · Welt im SubViewport, zwei Kameramodi
- **Status:** angenommen · 2026-10-02 · Kameramodus wird nach Playtest festgelegt
- **Kontext:** Bei reinem Pixel-Snapping ruckelt das Scrollen (abwechselnd 1 und 2 Spielpixel pro Frame). Ein Experiment hat gezeigt: Unter `canvas_items`-Stretch lässt sich ein Sprite mit der Viewport-Textur auf Bildschirmpixel genau verschieben, wenn das Hauptfenster nicht snappt. Mit Snapping springt es in ganzen Spielpixeln.
- **Entscheidung:** Das Hauptfenster nutzt `canvas_items` mit Integer-Scaling und ohne 2D-Snapping. Die Welt rendert pixelgenau in einem SubViewport (642×362, 1 Pixel Rand) und wird als Sprite um Bruchteile eines Spielpixels verschoben. `GameView` setzt die Canvas-Transformation direkt (keine `Camera2D`). Das Anzeige-Sprite ist von der Physik-Interpolation ausgenommen. Beides ist gemessen und beseitigt einen Frame Verzögerung. Physik-Interpolation ist global an, damit 120- und 144-Hz-Bildschirme flüssig laufen. Der Player liefert seine interpolierte Position selbst.
- **Modi:** *Weich* scrollt gleichmäßig (gemessen 3 bzw. 4 Bildschirmpixel pro Frame bei 2×), die Figur wackelt um ±0,5 Spielpixel. *Pixelgenau* scrollt in ganzen Spielpixeln (2 bzw. 4 Bildschirmpixel), die Figur steht ruhiger. Beide sind im Pause-Menü umschaltbar.
- **Konsequenzen:** Weltknoten bekommen keine Input-Events und fragen den `Input`-Singleton ab. UI liegt in CanvasLayern außerhalb des SubViewports. Wer Knoten in `_process` bewegt, schaltet deren Physik-Interpolation ab.
- **Nachtrag 11.10. (ADR-046):** *Pixelgenau* folgt der Figur jetzt starr (gerundete Fußposition plus gerundeter Vorlauf): Die Figur steht auf dem Bildschirm still, nur die Welt scrollt in ganzen Spielpixeln. Der Vorlauf ändert sich nur, solange die Figur sich bewegt; nach dem Anhalten driftet die Kamera nicht mehr nach. *Weich* bleibt Standard.
- **Nachtrag 22.10. (ADR-047):** *Weich* bleibt Standard (Entscheidung des Projektinhabers), *Pixelgenau* bleibt als Einstellung „Kamera“ und wird im Playtest gefragt. *Weich* ist straffer: `follow_sharpness` 14 → 30, `look_ahead` 14 → 12 px, `look_ahead_sharpness` 3 → 4, und bei Richtungsumkehr schwenkt der Vorlauf sofort auf die halbe neue Seite (`CameraMath.lead_toward`). Gemessen im Tal (60 Ticks, offener Weg): Restweg der Kamera nach dem Loslassen vorher 5,1 px, jetzt 2,3 px; *Pixelgenau* 0. Der Satz „driftet nicht mehr nach“ aus dem Nachtrag vom 11.10. gilt weiter nur für *Pixelgenau*; *Weich* rutscht nach dem Stopp noch rund 2 px. Die Kamera des Welt-Viewports ist auch der Audio-Hörer: mit der höheren Schärfe kommt ein Positionsklang (der Bach) schneller am neuen Ort an. „Bewegungsgefühl“ und „Richtungen“ (Phase-1-Tuning, ADR-016) stehen in der Einstellungsgruppe „Entwicklung“, die nur Debug-Builds zeigen; im Spiel gilt das fertige Gefühl.
- **Nachtrag 23.10. (Version 0.8.1):** Der Vorlauf der *weichen* Kamera ist entfernt (`look_ahead`, `CameraMath.lead_toward`); die Figur bleibt auf dem Bildschirm, wo sie ist, auch beim Wenden. Anlass: Der Projektinhaber meldete im Playtest mit 0.8.0, das Bild verschiebe sich beim Laufen und springe, etwa beim Gehen nach unten und gleich wieder nach oben. Ursache war der Nachtrag vom 22.10.: Bei Richtungsumkehr schwenkte der Vorlauf sofort auf die halbe neue Seite (bis zu 18 px), und die straffere Kamera (`follow_sharpness` 30) gab den Sprung fast ungedämpft weiter. Gemessen mit einer Figur, die 1 s nach unten und 1 s nach oben geht (96 px/s): die Kamera bewegte sich bis zu 416 px/s schnell (6,9 px in einem Bild bei 1,6 px Gehweg), und die Figur lief auf dem Bildschirm über 19 px hin und her (UI-Pixel 178 bis 198); jetzt höchstens 107 px/s (1,8 px pro Bild, der Gehweg plus Nachlauf), und die Figur bleibt beim Gehen und Wenden innerhalb von 3 UI-Pixeln um die Mitte. Die Tests `test_the_picture_does_not_jump_when_the_figure_turns_around` und `test_the_figure_keeps_its_place_on_screen_while_walking` fassen das; auf dem Stand 0.8.0 schlagen sie fehl. *Pixelgenau* folgt unverändert der gerundeten Fußposition. Eine Kamera, die vorausschaut, kann später wiederkommen, dann mit begrenzter Geschwindigkeit und ohne Sprung beim Wenden.

## ADR-013 · Kartenformat im Detail
- **Status:** angenommen · 2026-10-02 · konkretisiert ADR-004
- **Entscheidung:** Globale Symbole in `content/maps/legend.json`. Jede Karte darf einen `[legend]`-Block mit lokalen Symbolen (JSON pro Zeile) und Kommentaren (`;`) vor dem `[map]`-Block haben. Ein Symbol ist entweder ein Tile (`atlas`, `surface`, `solid`) oder eine Platzierung auf einem Tile (`ground` plus `prop` oder `marker`, optional `params`). `MapView` baut das TileSet zur Laufzeit; pro Symbol entsteht eine alternative Kachel, damit gleiche Grafik unterschiedliche Oberfläche oder Kollision haben kann. Props können in eine gemeinsame, nach Höhe sortierte Ebene gelegt werden (`props_parent`).
- **Konsequenzen:** Karten sind Textdateien und werden per `include_filter` exportiert. Fehler (unbekanntes Symbol, ungleiche Zeilen, fehlende Szene) erscheinen mit Datei, Zeile und Spalte. Terrain-Autotiling folgt mit echten Tilesets in Phase 3.

## ADR-014 · Programmatische Grey-Box-Platzhalter
- **Status:** angenommen · 2026-10-02
- **Kontext:** Asset-Seiten sind in der Cloud-Umgebung blockiert (KNOWN_ISSUES #4).
- **Entscheidung:** `tools/placeholders/make_placeholders.py` erzeugt Tiles, Figuren, Props und Klänge reproduzierbar (nur Standardbibliothek, fester Seed). Klänge werden über Dateinamen gefunden (`SoundBank`: `<präfix>_<n>.wav`), Figuren über `CharacterSheet`.
- **Konsequenzen:** Austausch gegen CC0-Packs oder finale Assets heißt Dateien ersetzen, nicht Code ändern.

## ADR-015 · Regeln des Antreiber-Prototyps
- **Status:** vorläufig · 2026-10-02 · Werte werden nach Playtest justiert
- **Entscheidung:** Konzept E3 („Der Weg, der nicht endet“) mit diesen Regeln: Gehen schiebt das Ziel um Faktor 1,15 weg, Sprinten um 1,6. Sprinten ermüdet und senkt das Höchsttempo um bis zu 45 Prozent, ohne HP und ohne Scheitern. Stillstehen ohne Bewegungseingabe für 3 Sekunden löst den Encounter, auf einer Bank sitzend 1,5 Sekunden. **Ergänzung:** Die Auflösung zählt erst, wenn man mindestens 480 Pixel (1,5 Segmente) gelaufen ist. Sonst ließe sich der Encounter lösen, ohne das Weichen des Ziels je erlebt zu haben.
- **Konsequenzen:** Alle Werte liegen in `AntreiberModel` und sind getestet. `encounter_speed` bereitet die Accessibility-Option „Encounter-Geschwindigkeit“ vor.
- **Nachtrag 10.10. (Text- und Rätsel-Durchsicht):** 480 Pixel waren rund sechs Sekunden Gehen; wer danach drei Sekunden stand (Umschauen, Schild lesen), löste den Weg zufällig. Stillstand zählt jetzt erst, wenn man mindestens 960 Pixel (drei Segmente) gelaufen ist **und** entweder 2 Sekunden gesprintet hat oder 40 Sekunden unterwegs ist (`is_engaged`); Stehen davor zählt nicht mit. Wer zu früh stehen bleibt, hört eine eigene Zeile (`puzzled_early`: „Pause? Wir haben doch noch gar nicht angefangen.“). Seine Zurufe bleiben so lange stehen, wie man zum Lesen braucht (14 Zeichen pro Sekunde, mindestens 2,2 Sekunden), und ein Stimmungswechsel unterbricht keine Zeile mehr. Werte bleiben vorläufig bis zum Playtest.
- **Nachtrag 22.10. (ADR-047):** Die Regeln und Werte bleiben vorläufig und unverändert. Zwei Dinge sind neu. Der Encounter fragt `Player.is_sprinting()`: Der Zustand folgt der Absicht (Sprint gehalten oder eingerastet und fest gelenkt), nicht dem gemessenen Tempo; Rennen zählt also für die Sprintzeit des Modells auch dann, wenn die Ermüdung das Tempo schon unter die Gehschwelle gedrückt hat (vorher sprang das Bild zwischen Gehen und Laufen). Und wird der Weg gelöst, läuft die Musik des Antreibers über 2,5 s in Stille aus, ohne Bandstopp (diese Geste gehört dem Riss); Regen, Vogel und Schritte bleiben.

## ADR-016 · Testoptionen und Autopilot in Phase 1
- **Status:** Testoptionen ersetzt durch ADR-018 (2026-10-03) · Autopilot gilt weiter
- **Entscheidung:** Das Pause-Menü stellt Bewegungsgefühl, Kamera, Richtungen, Sprint und Info-Anzeige um (`SessionOptions`, nur für die laufende Sitzung). Dieselben Optionen gibt es als Startargumente. Ein Autopilot spielt in Debug-Builds zeitgesteuerte Eingaben ab (`--autopilot=<json>`); er wird nicht exportiert.
- **Konsequenzen:** Varianten lassen sich ohne Neubau vergleichen. Aufnahmen und Messungen sind reproduzierbar.

## ADR-017 · Look-Pipeline: eigene, prozedural erzeugte Pixel-Art
- **Status:** vorläufig · 2026-10-02 · Abnahme durch den Projektinhaber anhand der Look-Szenen
- **Kontext:** Die Grey-Box wirkte nicht wie das gewünschte Spiel. Zielstil laut Rückmeldung: moderne Top-Down-Pixel-Art wie Referenzbild 2 (Bilder liegen nicht im Repo). Vorgabe: nur eigene Grafik, 0 €. Asset-Seiten sind ohnehin blockiert (KNOWN_ISSUES #4).
- **Entscheidung:**
  - Böden werden aus der Textkarte **gebacken** (`tools/art/bake_ground.py`): eine Textur pro Karte mit organischen Übergängen statt sichtbarem Raster, Schattierung nur aus handgewählten Paletten pro Stil, Schattenkanten, Heckenkronen, Klippenwände, Prop-Schatten und eine Wassermaske. Die TileMap bleibt für Kollision und Oberflächen erhalten und wird ausgeblendet. Ein `[meta]`-Block der Karte nennt Stil, Boden- und Wassertextur.
  - Props und Figur kommen aus `tools/art/make_sprites.py` und `tools/art/make_character.py`. `assets/generated/props/catalog.json` beschreibt Anker, Kollision, Wind, Lichter und Effekte; `world/props/decor.tscn` setzt sie generisch um. Varianten werden pro Position deterministisch gewählt.
  - Atmosphäre in Godot: Shader für Wind, Wasser, Regenringe, Wolkenschatten und Farbstimmung mit Bloom und Vignette; CPU-Partikel für Regen, Blüten und Lichtpunkte; `PointLight2D` plus `CanvasModulate` für Nacht; Ambience-Loops aus `tools/audio/make_ambience.py`. Alles bleibt auf dem Spielpixel-Raster.
  - numpy und Pillow nur für die Generatoren (`requirements-art.txt`). Nicht im Build, nicht in CI; die erzeugten Dateien sind eingecheckt.
- **Alternativen:** CC0-Packs (blockiert, Stilmischung), KI-generierte Bilder (Lizenz- und Konsistenzrisiko, laut Master-Prompt nie final), handgezeichnete Pixel-Art (beste Qualität, braucht Artist oder Budget).
- **Konsequenzen:** Die erzeugte Grafik ist Platzhalter mit klarer Grenze: deutlich besser als die Grey-Box, aber unter Referenzbild 2. Nach jeder Kartenänderung muss neu gebacken werden (ein Test prüft die Größe). Gebackene Böden und Katalog-Sprites lassen sich später durch handgemalte Texturen oder Tilesets ersetzen, ohne Gameplay-Code zu ändern.
- **Ergänzung (Look-Runden 2 und 3):** Leuchtende Teile sind Emissive-Ebenen mit `render_mode unshaded` direkt am Objekt (richtige Verdeckung, keine Abdunklung durch `CanvasModulate`). Dritte Szene „Wald bei Nacht“. Figuren werden aus Designs erzeugt (Spieler, Mira, Elysianer). Maßstab sind alle Referenzbilder des Projektinhabers.
- **Nachtrag 22.10. (ADR-047):**
  - **Dithering:** Der Himmel (`sky.gdshader`) mischt nur noch die Nähte zwischen zwei Bändern (Uniform `seam_contrast` 3,5, dieselbe Formel wie `pixelart.quantize`); im Spiel sind es zehn Bänder (`LookScene._add_sky`, `SkyLayer.setup(..., steps)`), der Titel behält seine Bandzahl. Die Böden der Wirklichkeit (Stile `tal` und `wald`) backen Wiesen und Wege mit Kontrast 6,0 statt 3,0 und halb so viel Wegrauschen (0,05 statt 0,1): ruhige Flächen, Dither nur an Rändern. Elysia ist bitgleich geblieben (neu gebacken und verglichen, `git status` ohne Änderung).
  - **Figurenblätter:** Der Gehzyklus der Seitenansicht hat vier unterscheidbare Bilder: die ferne Hüfte liegt 1 px weiter vorn und das ferne Bein greift mit 1,5 statt 2 Stufen aus, sonst waren „nahes Bein vorn“ und „fernes Bein vorn“ dieselbe Silhouette. Der Körper senkt sich auf den Kontaktbildern (0 und 2) um 1 px, statt sich auf den Passing-Bildern zu heben; so wird der Scheitel nie mehr abgeschnitten. Idle-, Sitz- und Umschauen-Zeilen sind pixelgleich geblieben.
  - **Zustand „work“:** Nur Mira hat ihn (2 Bilder, 2 fps, Schleife, nach den Umschauen-Zeilen; Sheet 96×1536 statt 96×1280). `CharacterSheet.has_work()` liest, was die Textur hat; `NpcWalker` nimmt das Karten-Param `work_face`.

## ADR-018 · Einstellungen als JSON, getrennte Profile für automatische Läufe
- **Status:** angenommen · 2026-10-03 · ersetzt die Testoptionen aus ADR-016
- **Kontext:** Geplant war `user://settings.cfg` mit `ConfigFile`. Dessen Parser kann aus Text Objekte und Ressourcen-Verweise erzeugen. Für Saves gilt bereits „kein Code aus Nutzerdateien“ (ADR-008). Außerdem schrieben Smoke-Runs, Tests und Aufnahmen bisher in denselben Nutzerordner wie das echte Spiel.
- **Entscheidung:**
  - Der Autoload `Settings` speichert `settings.json` (Version, Werte, Eingabe-Overrides). Jeder Wert hat ein Schema mit Standard und Bereich; Ungültiges fällt auf den Standard zurück und wird geloggt. Geschrieben wird atomar über eine temporäre Datei.
  - Startargumente (`--camera`, `--tuning`, `--directions`, `--sprint`, `--overlay`, `--text=instant`) gelten nur für die Sitzung und werden nie gespeichert.
  - Eingabe-Overrides werden als einfache Daten gespeichert (Taste, Pad-Knopf, Achse, immer `device = -1`). Die Rebinding-Oberfläche folgt nach dem Slice (ADR-011).
  - `RuntimeEnv`: GUT-Läufe nutzen `user://profiles/test/`, Läufe mit `--profile=<name>` `user://profiles/<name>/`. `check.sh` und `smoke_export.sh` nutzen `smoke`, `capture.sh` nutzt `capture`.
- **Konsequenzen:** Keine Objekterzeugung aus Nutzerdateien. Automatische Läufe überschreiben nie Spielstände oder Einstellungen des Spielers. Die Phase-1-Testoptionen liegen jetzt dauerhaft im Einstellungsmenü.
- **Nachtrag 22.10. (ADR-047):** Einstellungen werden atomar und sparsam geschrieben: `Settings.request_save()` fasst alle Änderungen eines Frames zu einem Schreibvorgang zusammen (ein Regler ändert jeden Frame einen Wert), `flush()` schreibt Ausstehendes sofort (`AppGuard` beim Schließen, `_exit_tree`). `save_file()` ersetzt die Datei per `rename_absolute` ohne vorheriges Löschen; nur wo ein Umbenennen nicht überschreibt, wird als Rückfall gelöscht und erneut umbenannt (Windows-Verhalten im Container nicht prüfbar). Bei `--profile=<name>` gewinnt das **letzte** gültige Argument; `tools/capture.sh` legt je Aufnahme ein eigenes Profil `capture_<pid>` an und löscht es danach (ein gemeinsames Profil trug Spielstände in den nächsten Lauf, das Startmenü zeigte dann „Fortsetzen“). GUT-Läufe nutzen `user://profiles/test_<pid>/` (je Prozess eigen, `RuntimeEnv.test_profile`), nicht mehr das gemeinsame `test`.
- **Nachtrag (ADR-048):** `settings.json` hat die Version 2; der Block `input` hält je Aktion eine flache Liste, ein Gerät gilt als überschrieben, wenn sie Ereignisse dieses Geräts enthält (feste Ereignisse und die Ereignisse beider Geräte werden mitgeschrieben; Aktionen ohne Änderung nie). Eine Datei, die nicht lesbar ist, bleibt als `settings.json.bad`, die einer neueren Version als `settings.json.newer` liegen. Die Rebinding-Oberfläche steht in ADR-048.

## ADR-019 · Spielzustand und Inhalte
- **Status:** angenommen · 2026-10-03
- **Entscheidung:**
  - `WorldState` (Autoload) ist die einzige Schreibstelle. Die Daten liegen in `GameState` mit typisierten Teilen: Flags, Quests (Stufe, Verlauf, erledigte Ziele), Beziehungen (Zustand `stranger/cautious/familiar/close/strained` plus Erinnerungen), Facetten (Flags), Haus, Inventar, entdeckte Orte, UI-Modus, Elysia-Werte (XP, Gold; Level wird aus XP berechnet), Spieler und Spielzeit. Jede Änderung wird geprüft, unter `WORLD_STATE` bzw. `QUEST` geloggt und als typisiertes Signal gemeldet. Ungültiges wird abgelehnt und als Fehler geloggt.
  - Quests und Items sind `.tres`-Ressourcen (`QuestDef` mit `QuestStageDef`, `ItemDef`). Erlaubte Quest-Übergänge stehen in `next`; eine Stufe ohne `next` beendet die Quest mit ihrem `outcome`. Journal- und Itemtexte haben abgeleitete Schlüssel (`QUEST_<ID>_<STUFE>`, `<ITEM_ID>_NAME`). `ContentDB` lädt sie exportfest über `ResourceLoader.list_directory()`.
  - `ContentValidator` prüft Quests (IDs, Übergänge, Erreichbarkeit, Ende, Übersetzungen), Items und Dialoge. Er läuft in den Tests und bei jedem Start eines Debug-Builds.
  - Karten dürfen Weltzustand nur über eine feste Liste von Aktionen ändern (`StateActions`: Flag, Quest-Schritt, Item, Ort). Hebel merken sich ihren Zustand über ein Flag, Auslösezonen feuern einmal.
  - Beziehungen und Facetten werden nie als Zahl angezeigt (Game Bible §23).
- **Konsequenzen:** Quests lassen sich ohne Code anlegen, Fehler fallen beim Start auf. Neue Teilbereiche des Zustands brauchen Methoden in `WorldState`, Serialisierung in `GameState` und eine Testdatei.

## ADR-020 · Dialoge mit statischen IDs und geprüften Zustandsaufrufen
- **Status:** angenommen · 2026-10-03
- **Entscheidung:**
  - Jede Dialogzeile und jede Antwort hat eine statische ID (`[ID:<bereich>_<cue>_<n>]`, Antworten `_r<n>`), projektweit eindeutig. Die IDs dienen als Übersetzungs-Kontext (`use_static_ids_as_translation_keys = false`), damit ohne Übersetzung immer der Quelltext erscheint und nie die ID.
  - Bedingungen und Mutationen rufen nur `WorldState`-Methoden auf. Der Validator prüft Methode, Quest-, Item-, Figuren- und Facetten-IDs sowie Flag-Namensräume.
  - Fake Choices werden erkannt: Eine Antwortgruppe, deren Antworten alle gleich weitergehen, ist ein Fehler.
  - Die Dialogbox sperrt das Speichern; während des Dialogs angeforderte Autosaves folgen direkt nach dem Ende. Gewählte Antworten werden mit ihrer ID geloggt.
- **Konsequenzen:** Übersetzungen können später über die Kontexte zugeordnet werden. Dialoge können keinen Zustand am Validator vorbei ändern, solange sie `WorldState` benutzen.
- **Nachtrag 22.10. (ADR-047):**
  - Antworten mit Bedingung (`[if … /]`) verschwinden aus der Liste, wenn die Bedingung nicht zutrifft (`hide_failed_responses` an der Antwortliste der Dialogbox); vorher standen sie ausgegraut da. Deshalb braucht **jede Antwortgruppe mindestens eine unbedingte Antwort** (`test_every_group_of_answers_has_one_that_always_applies` prüft alle Dialoge).
  - Der Validator lehnt eine Antwort mit `{{Wert}}` ab, wenn keine Bedingung diesen Wert nennt (ein leerer Katzenname ließe „ wohnt jetzt bei mir.“ stehen); `WorldState.player_name()` ist ausgenommen.
  - Texteffekte (`[wave]`, `[shake]`, `[rainbow]`, `[tornado]`, `[pulse]`, `[fade]`) sind nur in gesprochenen Zeilen erlaubt, nicht in Erzählzeilen. `[wait=…]` setzt eine Pause. „Weniger Flackern“ (`display.reduce_flashing`) entfernt die Bewegungseffekte, `[wait]` bleibt. Ein Druck während einer laufenden Pause ändert nichts (Miras „Zum Meer.“ lässt sich nicht wegklicken); bei Textgeschwindigkeit „Sofort“ entfällt die Pause.
  - Ein Linksklick auf die Dialogbox bringt den Text weiter wie Bestätigen (nie bei sichtbaren Antworten). Die Box meldet `syllable(character)` bei jedem Stimmklang einer gesprochenen Zeile, damit Sprecher mit dem Mund wippen.

## ADR-021 · Speichern im Spiel
- **Status:** angenommen · 2026-10-03 · konkretisiert ADR-008
- **Entscheidung:**
  - Slots: `autosave` plus drei manuelle. Autosave beim Betreten eines Bereichs (nicht nach dem Laden) und bei jedem Quest-Schritt.
  - Gespeichert werden darf nur, wenn nichts sperrt (Dialog, Ladevorgang) und die Szene speicherbar ist. Encounter sind nicht speicherbar; ihr Autosave folgt im nächsten Bereich.
  - Vor dem Überschreiben wird die bisherige Datei zur Sicherung (`.bak`), aber nur, wenn sie lesbar ist. Eine beschädigte Datei verdrängt nie eine gute Sicherung. Das Lademenü bietet bei beschädigten Slots die Sicherung an.
  - Laden ersetzt den Zustand, wechselt in die gespeicherte Szene und setzt die Figur an die gespeicherte Position. Weltobjekte stellen ihren Zustand aus Flags her.
  - Spielzeit zählt nur, solange eine Spielszene läuft und nichts pausiert ist.
- **Konsequenzen:** Keine halben Gespräche in Spielständen. Startet man im Prototyp-Menü eine Szene neu, überschreibt deren erstes Autosave den alten Autosave (die Sicherung bleibt). Das ändert sich mit dem echten Titelablauf.
- **Nachtrag 22.10. (ADR-047):** Gespeichert wird zusätzlich bei jedem Beat (`Beat.mark` ruft `SaveSystem.request_autosave_soon("beat:<id>")`; am Frameende, bei Dialog, Zwischensequenz oder Begegnung zurückgestellt wie die Quest-Schritte) und beim Schließen des Fensters (Autoload `AppGuard`, siehe ADR-047). Der Slot-Dialog zeigt gefüllte Slots als zweizeilige Karte („Kai · Das Tal“ über „12 min · 03.10. 14:05“, der Slotname als gedämpftes Etikett); leere und beschädigte Slots behalten die eine Zeile. Wer „Zum Startmenü“ oder „Spiel beenden“ wählt, während der Autosave fehlschlägt, wird gefragt (Nein vorausgewählt), statt still zu verlassen. `SaveSystem.summary()` kennt `finished`, `SaveSystem.slice_finished()` sagt, ob ein lesbarer Stand das Ende trägt.

## ADR-022 · Renderer: Compatibility (OpenGL 3) auf allen Plattformen
- **Status:** angenommen · 2026-10-03 · ersetzt die Renderer-Angabe in ADR-007
- **Kontext:** Geplant war Forward+ (Vulkan, Metal, D3D12) mit Compatibility als Rückfall. REAL ist reines 2D: Licht über `PointLight2D` und `CanvasModulate`, Bloom, Vignette und Farbstimmung macht ein eigener Shader (`grade.gdshader`), nicht `WorldEnvironment`. Alle Aufnahmen und Sichtprüfungen seit Phase 1 laufen im Container ohnehin über OpenGL 3. Zielhardware sind auch ältere Laptops mit integrierter Grafik.
- **Entscheidung:** `gl_compatibility` für Desktop und Mobile.
- **Konsequenzen:** Builds rendern wie die geprüften Aufnahmen. Breitere Hardware-Unterstützung und schnellerer Start. Funktionen, die nur Forward+ hat (z. B. 2D-Glow über `WorldEnvironment`, SDF-Effekte), sind bewusst nicht im Einsatz. Ein Wechsel bleibt eine Projekteinstellung, falls später ein Effekt Forward+ braucht.

## ADR-023 · Musik: eigene prozedurale Loops und ein AudioDirector
- **Status:** angenommen · 2026-10-03 · Platzhalter bis zur echten Komposition
- **Kontext:** Phase 3 verlangt Musikzustände und einen Elysia-Loop. Asset-Seiten sind blockiert, die Vorgabe ist 0 € und eigene Inhalte (wie bei der Grafik, ADR-017).
- **Entscheidung:**
  - `tools/audio/make_music.py` (numpy) erzeugt nahtlose Loops: Elysia (C-Dur, 100 BPM, streng quantisiert, Glockenspiel und Pads), Tal (D-Dorisch, gezupft, menschliches Timing), Nachtwald (Drone, Glasglocken), Antreiber (treibend, das Motiv steigt und kommt nie an). Alle tragen dasselbe Motiv, das spätere Hauptthema (Game Bible §35).
  - Nahtlosigkeit: Noten laufen über das Loop-Ende in den Anfang, Filter und Hall sind zirkulär (Frequenzraum).
  - Autoload `AudioDirector`: Musik-Tracks mit Überblendung, gleicher Track läuft über Szenenwechsel weiter, leiser während Dialogen, „Bandstopp“ (Tonhöhe und Lautstärke sinken) für den Übergang, Ambience-Betten. Musik und Ambience laufen in Menüs weiter.
  - Szenen wählen Musik und Ambience über `GameScene`-Exports.
- **Konsequenzen:** Rund 7,6 MB WAV im Repo (22,05 kHz Stereo; seit ADR-046 44,1 kHz, rund 18 MB), im Build komprimiert. Die Klangqualität ist Platzhalter-Niveau; Komposition und Aufnahme brauchen später Budget oder Musiker. Neue Tracks: Funktion in `make_music.py` und Eintrag in `AudioDirector.TRACKS`.

## ADR-024 · UI-Bogen: Elysia-Skin mit HUD, Real-Skin fast leer
- **Status:** angenommen · 2026-10-03
- **Entscheidung:**
  - Zwei Themes (`ui/theme/elysia_skin.tres`, `real_skin.tres`) überschreiben nur, was sich unterscheidet. `UiSkin.attach(control)` hält Dialogbox, Menüs, Journal, Prompt und HUD im Stil des aktuellen UI-Modus, auch nach dem Laden.
  - Elysia: Goldrahmen mit Edelsteinen (`tools/art/make_ui.py`), HUD mit Level, XP-Leiste, Gold und Quest-Anzeige samt Marker, laute Popups für XP, Gold, Level-Up und Loot. Seltenheit erscheint immer auch als Wort, nie nur als Farbe.
  - Real: keine Rahmen, gedämpfte Farben, kein HUD; nur eine leise Zeile, wenn man etwas aufhebt.
  - Items haben eine Seltenheit; der Stein hat keine („Seltenheit: —“).
- **Konsequenzen:** Weitere UI-Elemente bekommen `UiSkin.attach`. Der spätere persönliche Stil („Handschrift, Kritzeleien“) wird ein dritter Skin.
- **Nachtrag 22.10. (ADR-047):** Das HUD baut sich beim Erwachen auf: `Hud.hold_back()` leert Elysias Ecke, `Hud.reveal_elysia()` lässt Level, XP-Leiste und Gold nacheinander aufpoppen (0,35 s je Element, 0,4 s Abstand, 8 Funken, ein Klang für alle drei; ohne Funken bei „Blitzeffekte reduzieren“). Nur die Szene, die das Erwachen inszeniert, ruft das auf; Look-Szenen, Sandbox und geladene Stände behalten das HUD sofort. Der goldene Ortsname bleibt stehen, auch im Gespräch (nur die leise Zeile der Wirklichkeit weicht). „Gespeichert“ erscheint nicht in den ersten 5 s Spielzeit und nicht während einer Zwischensequenz. Beute-Karten zeigen die Zeile des Gegenstands (3,4 statt 2,6 s). Untertitel zählen Spielzeit statt Wanduhr; `Hud.show_caption()` schreibt einen Klang unabhängig von der Einstellung (der ferne Riss). Journal: Offene Ziele tragen in Elysia ein Juwel (`JournalMark`), erledigte sind gedämpft; die ASCII-Kästchen sind weg.

## ADR-025 · Übergangssequenz und Tageslicht
- **Status:** angenommen · 2026-10-03
- **Entscheidung:**
  - `RiftSequence`: Spieler wird festgehalten, Speichern gesperrt, die Welt ruckelt (nur mit Bildschirmwackeln an), die HUD-Elemente verschwinden einzeln (ohne Flackern bei „Blitzeffekte reduzieren“), die Musik läuft als Bandstopp aus, Stille, Abblende. Danach UI-Modus REAL, Inventar Stein und Samen, Szenenwechsel ins Tal mit Regen, Autosave dort.
  - Autoload `ScreenFade`: schwarze Abdeckung über Szenenwechsel hinweg; neue Szenen blenden selbst auf.
  - `DayLight` für Szenen der Wirklichkeit: Presets Regentag, Abend, Nacht blenden Weltfarbe, Farbstimmung, Lampen, Regen und Ton. Im Tal lässt Ausruhen auf der Bank die Zeit weiterlaufen. Elysia hat bewusst kein Tageslicht.
- **Konsequenzen:** Der Ablauf ist getestet und als Video belegt. Echte Story-Platzierung (Kind, versteckter Riss, Hilfe nach Zeit) folgt mit Phase 4.
- **Nachtrag 22.10. (ADR-047):** Der Übertritt ist kürzer und körperlicher. Beim Berühren macht die Figur einen Schritt von 8 px auf den Riss zu (0,45 s) und schaut hin; der Riss schwillt über 3,2 s (Glühen +1,7, Bild ×1,5). Bei jedem Verlust eines HUD-Teils (drei- bis viermal) friert das Weltbild 0,12 s ein (`SubViewport.render_target_update_mode`, das HUD läuft weiter); mit „Blitzeffekte reduzieren“ entfällt das Einfrieren. Die schwarze Pause ist 0,6 s statt 1,4 s; von der Berührung bis zum Dunkel vergehen rund 7,2 s statt 8,8 s. Elysia verfällt dabei nicht (Bible §8, §9; ADR-041). Öffnet sich der Riss nach Zeit ohne das Kind (`RIFT_AFTER_LOOPS` 150 statt 240 s), hört man ein fernes Grollen (−6 dB), die Ansicht wackelt kurz und die Untertitelzeile erscheint unabhängig von der Einstellung. Die Ankunft im Tal beginnt mit rund 0,9 s Schwarz (Laden der Szene) und dem Beginn der 3,5-s-Blende: kein Darstellungsfehler, siehe KNOWN_ISSUES #69.

## ADR-026 · Schrift und Bewegung der Oberfläche
- **Status:** angenommen · 2026-10-04 · ersetzt die Schriftwahl aus Phase 0
- **Kontext:** Tiny5 ist nur 5 Pixel hoch. Dialoge und Menüs waren bei 640×360 kaum lesbar, das Startmenü eine Entwicklerliste auf Schwarz.
- **Entscheidung:**
  - Hauptschrift **Jersey 10** in ihrer Pixelgröße 19 (Versalhöhe 10 px), Titel **Jersey 15** in 27, beide aus google/fonts (OFL 1.1). Tiny5 bleibt für kleine Beschriftungen (Hinweise, Tasten-Kappe, Entwickler-Panels).
  - Menüs: gleitender Cursor je Skin (Elysia Goldjuwel, Real Strich), das Spiel dahinter weichgezeichnet und getönt (`menu_backdrop.gdshader`), Panels gleiten 6 px ein. Animiert wird die CanvasLayer-Verschiebung, nie ein verankerter Container.
  - Dialogbox mit Namensschild, Weiter-Pfeil, Cursor auf Antworten und Stimme je Sprecher (`content/dialogue/voices.json`).
  - Startmenü mit eigener Titelgrafik (`tools/art/make_title.py`), Prototypen in einem Untermenü.
- **Konsequenzen:** Längere Listen (Einstellungen) scrollen. Wer UI baut, nutzt die Theme-Typen (`SmallLabel`, `HintLabel`, `PromptText` …) statt Schriftgrößen im Code.
- **Nachtrag 22.10. (ADR-047):** Die Scrollbalken der Menüs sind 3 UI-Pixel breit und je Skin gefärbt (Basis neutral grau, Elysia Gold, Real gedämpft); die Standardleiste der Engine war dreimal so breit wie die Pixelwelt. Menülisten scrollen nie seitwärts (`MenuLayer.keep_upright`): ein Fokus hatte die ganze Liste 3 px nach links geschoben und die ersten Buchstaben der Überschriften abgeschnitten. Reine Textseiten (Steuerung, Mitwirkende) erben von `ScrollPage` (`ui/menus/scroll_page.gd`): der Fokus zieht die Seite nicht nach unten, Hoch/Runter und der rechte Stick blättern. Panels messen ihre Höhe nach einem Layoutdurchlauf noch einmal (Schriftwechsel, umbrochene Zeilen). Lautstärkeregler stoppen an den Enden (0 bis 10, kein Sprung von 10 auf stumm); „Effekte“ und „Stimmen“ spielen beim Ändern einen Probeklang. Mausbewegung, nicht Mausposition, verschiebt den Fokus in einer frisch gebauten Liste.

## ADR-027 · Soundeffekte: eigene, prozedural erzeugte Klänge
- **Status:** angenommen · 2026-10-04 · Platzhalter bis zum Sounddesign
- **Entscheidung:** `tools/audio/make_sfx.py` (numpy, 0 €) erzeugt alle Effekte: Menüklänge in zwei Sets (Elysia Glas in Dur und nie variiert; Real Holz und Papier mit kleinen Abweichungen), Münzen, XP, Level-up, Truhe, Beute je Seltenheit, Aufheben im Tal, Dialogstimmen, Glitches und das Brummen des Risses. `AudioDirector.ui()`, `sfx()` und `voice()` spielen sie auf den Bussen UI, SFX und Voice; `SoundBank` sucht erst in `assets/generated/sfx/`.
- **Konsequenzen:** Die Klänge sind technisch geprüft (Pegel, Hüllkurven, Schleifen), aber nicht angehört. Ein Austausch ist reiner Dateitausch.

## ADR-028 · Requisiten-Atlas je Stil
- **Status:** angenommen · 2026-10-04
- **Kontext:** Jede Look-Szene hat ~1.700 Streu-Sprites mit 20–37 verschiedenen Texturen. In Y-Reihenfolge wechselt die Textur ständig, jeder Wechsel ist ein Draw Call (574–928 pro Bild).
- **Entscheidung:** `PropCatalog` packt beim ersten Gebrauch alle Grafiken eines Stils in eine Atlas-Textur und gibt `AtlasTexture`-Ausschnitte aus. Shader dürfen deshalb nicht mit `UV` als 0..1 der Figur rechnen (Wind nutzt `VERTEX`, Spiegelungen die Einzeltextur über `PropCatalog.source_texture`). Streu-Sprites werden nicht von Lampen beleuchtet (`light_mask = 0`).
- **Konsequenzen:** Elysia 574 → 81, Tal 928 → 119, Wald 818 → 197 Draw Calls. Neue Requisiten landen automatisch im Atlas ihres Stils (Breite 1024 px).

## ADR-029 · Spielstand Schema 2
- **Status:** angenommen · 2026-10-04
- **Entscheidung:** Die Tageszeit (`day_preset`) gehört zum Spielzustand. Migration 1 → 2 setzt `ui_mode` nach der Szene des Stands, weil Stände aus Phase 2 immer `ELYSIA` enthielten.
- **Konsequenzen:** Ältere Stände laden weiter (Migration getestet). `docs/SAVE_FORMAT.md` ist aktualisiert.

## ADR-030 · Zwei Startbilder: Elysias Schein-Titel, REAL erst nach dem Übertritt
- **Status:** angenommen · 2026-10-04 · rückgängig machbar (ein Schalter in `core/boot/boot.gd`)
- **Kontext:** Game Bible §10: „Elysia täuscht zunächst ein klassisches RPG vor.“ §56 setzt den Titel ans Ende des Slice („Schwarz. Titel.“). Das bisherige Startmenü zeigte von Anfang an „REAL“ mit dem Riss im A und nahm damit die Wendung vorweg.
- **Entscheidung:**
  - Solange kein Spielstand die Wirklichkeit erreicht hat (`SaveSystem.reached_reality()`), heißt das Spiel „Elysia“: goldenes Serifen-Logo mit Kristall und Filigran, Untertitel „Ein Abenteuer für die Ewigkeit“, spiegelsymmetrische Insel mit Zwillings-Wasserfällen, Menü mittig im Elysia-Skin, Elysias Musik.
  - Danach zeigt das Startmenü „REAL“ in schlichten Buchstaben über einem Abendtal (krummer Baum im Wind, Bank, Laterne, kaputter Zaun, Haus mit Licht), Tal-Musik und Abend-Ambience, Menü links im Real-Skin.
  - `TitleCard` (`ui/title/title_card.gd`) spielt den Schluss des Slice: schwarz, Musik aus, „REAL“ blendet ein und aus. Bis Phase 4 nur unter Prototypen abspielbar.
  - Prototypen → „Startbild wechseln“ und `--title=elysia|real` zeigen beide Titel ohne Spielstand.
- **Konsequenzen:** Wer Spielstände löscht, sieht wieder Elysia; das ist gewollt. Der Schein-Titel braucht später Key-Art auf Elysia-Niveau.
- **Nachtrag 22.10. (ADR-047):** Die Endkarte trägt keine Zeile mehr: Schwarz, dann der Titel („Schwarz. Titel.“, Bible §56). `TitleCard.play(self, "")` zeigt nur das Logo. Die Schlusszeile „Hier endet der Prototyp. Danke fürs Spielen.“ (`END_OF_SLICE`) steht als leiser Untertitel unter dem „Nach Elysia“-Logo im Startmenü, sobald ein lesbarer Stand `slice.finished` trägt. Trägt der Autosave das Ende (`SaveSystem.summary()` kennt `finished`), fragt „Neues Spiel“ nicht mehr nach (direkt die Namenswahl). Die Ambience des Real-Titels liegt dabei bei −8 statt −12 dB. Zum Ende: erst `ending` (bis „Mira schaut zu den Bergen. Lange.“), die Kamera schwenkt 4,0 s zu den Bergen, 2,5 s Halt, `ending_sea` („Zum Meer.“), 2,5 s Halt, Speichern, 2,5 s Abblende, Titelkarte.

## ADR-031 · Elysia perfekt, die Wirklichkeit ungepflegt
- **Status:** angenommen · 2026-10-04
- **Kontext:** Game Bible §9 (perfekte Symmetrie, keine Alterung, Schmetterlinge auf denselben Routen, Wolken wiederholen sich, Wasser spiegelt alles außer dem Protagonisten), §12 (schiefe Bäume, kaputte Zäune, Wind), Risiko 10 (Wirklichkeit darf nicht gleich Leid sein).
- **Entscheidung:**
  - Elysia ist um Spalte 32 spiegelsymmetrisch (`[meta] symmetry`): Karte, gebackener Boden (pixelgenau, gespiegeltes Dithering), Streu im exakten Raster, Requisiten als Spiegelpaare. Nur der unscheinbare Stein und der Riss haben keinen Zwilling.
  - Elysia-Boden ohne trockene Flecken und Kiesel, mit Mährichtungs-Streifen und Blumenpunkten im Raster.
  - Bewegung ohne Zufall: Pflanzen wiegen sich ohne Böen gespiegelt im Gleichtakt, derselbe Vogelschwarm im exakten Takt, Koi kreisen gleichmäßig, Libellen und Schmetterlinge fliegen gespiegelte Routen, Wolkenschatten kehren sichtbar wieder, die Elysianer laufen gespiegelt im Gleichtakt und schauen sich nie um.
  - Tal: krumme Bäume mit totem Ast, kaputte Zaunstücke, Wind (Ambience mit Böen und knarrendem Holz, Blätter in unregelmäßigen Böen). Ankunft bei Regen am Tag statt in der Nacht (Slice: „Regen. Wind.“ und später „Abend“); die Bank führt zu Abend und Nacht.
  - In der Wirklichkeit (Tal, Wald) spiegelt sich die Hauptfigur in Wasser und Pfützen, in Elysia nie.
  - Real-UI ruhig statt düster: wärmere Farben, sanfter abgedunkelter Hintergrund.
- **Konsequenzen:** Änderungen an Elysias Karte müssen symmetrisch bleiben (`tools/art/layout_look_maps.py elysia` erzeugt sie gespiegelt, ein Test prüft die Paare). Der Tal-Start ist in `world/levels/look_tal.tscn` (`day_preset`) einstellbar.

## ADR-032 · Elysias Loop schrumpft
- **Status:** angenommen · 2026-10-04
- **Kontext:** Game Bible §35: „Loops werden zunehmend wahrnehmbar.“ (KNOWN_ISSUES #32)
- **Entscheidung:** `make_music.py` schneidet Elysias Musik auf 4 und 2 Takte. `AudioDirector` wechselt nach Spielzeit (150 s, 300 s) oder Fortschritt (Truhe geöffnet, Stein genommen) zur nächsten Stufe, immer erst am Loop-Ende, damit der Wechsel auf dem Taktanfang landet.
- **Konsequenzen:** Die Stufe hängt am Spielstand (Spielzeit, Flags) und ist damit nach dem Laden dieselbe. Feinabstimmung der Schwellen im Playtest.
- **Nachtrag 22.10. (ADR-047):** Die Zeitschwellen sind 300 und 600 s (vorher 150 und 300 s). Die Flags `elysia.chest_tree_opened` und `elysia.stone_taken` sind der eigentliche Auslöser; die Zeiten fangen nur ab, wer trödelt. Die Loops dauern 19, 10 und 5 s. Gemessen sieht man den Wechsel nur in einer Aufnahme mit Ton (Headless-Läufe rücken das Audio nicht vor).
- **Nachtrag (ADR-062):** Die Stufen folgen jetzt dem Fortschritt: Stufe 1 mit `elysia.market_seen` (Markt betreten), Stufe 2 mit `elysia.stone_taken`; die Uhr fängt erst nach 20 und 40 Minuten. `elysia.chest_tree_opened` verkürzt die Musik nicht mehr.

## ADR-033 · Idle-Animationen und große Schrift überall
- **Status:** angenommen · 2026-10-04
- **Kontext:** Game Bible §36 („viele Idle-Animationen“) und §50 („skalierbare Textgröße“). Bisher vergrößerte die Einstellung nur die Dialogbox (KNOWN_ISSUES #23).
- **Entscheidung:**
  - Figurenblätter bekommen den Zustand „look“ (blinzeln, nach links, nach rechts, blinzeln) als letzte Zeilen. Die Hauptfigur schaut sich nach 4 bis 9 s Stillstand um, Mira ebenso (`"glance": true`), Elysianer nie.
  - `TextSize` schaltet die gemeinsamen Themes um (Fließtext Jersey 15 in 27 px, kleine Schrift Tiny5 in 16 px, Entwickler-Panels mit). Auswahlzeilen reservieren Platz für ihren Wert, Menüs wachsen mit.
- **Konsequenzen:** Neue UI nutzt Theme-Typen statt fester Schriftgrößen, sonst wächst sie nicht mit. Grey-Box-Blätter ohne „look“-Zeilen funktionieren weiter.

## ADR-034 · Naturklang der Wirklichkeit: Schichten und Zufall statt Schleife
- **Status:** angenommen · 2026-10-05
- **Kontext:** Playtest Phase 3: „Naturgeräusche in der realen Welt realistischer bauen als in Elysia.“ Game Bible §9 (Elysia wiederholt sich), §12 (die Wirklichkeit ist lebendig und unberechenbar). Bisher spielte jede Szene eine einzige 12–24-s-Mono-Schleife.
- **Entscheidung:**
  - Elysia behält eine Schleife (`garden_loop`) und klingt bewusst zu perfekt: gleichmäßige Brise, dieselbe Vogelphrase auf exaktem Takt.
  - Die Wirklichkeit spielt eine `SoundscapeDef` (`content/audio/*.tres`) über `SoundscapePlayer` im `AudioDirector`:
    - **Flächen** ohne Einzelereignisse (Regen, Wind, Laub, Bach, Grillen) laufen zweimal, links und rechts, eine halbe Schleife versetzt. Das klingt breit und nie phasengleich.
    - **Einzelklänge** (Amsel, Rotkehlchen, Kohlmeise, Ringeltaube, Krähe, Waldkauz, ferner Hund, Tropfen, Zweig, Rascheln, Knarren) kommen zu zufälligen Zeiten aus zufälligen Richtungen, mit zufälliger Tonhöhe und Lautstärke.
    - **Böen** aus langsamem Rauschen: Wind und Laub schwellen mit, Knarren und Rascheln werden häufiger, und die wehenden Blätter im Bild folgen demselben Signal (`AudioDirector.wind_gust()`).
  - Klänge sind physikalisch modelliert (`tools/audio/make_nature.py`, 0 €): Tropfen mit log-normaler Lautstärke und Blasenresonanz, Wind durch wandernde Resonanzen, Vogelrufe nach Gesangsstruktur, Entfernung über Tiefpass und Außenhall.
  - Richtung über vier Panorama-Busse (`NatureL2`, `NatureL1`, `NatureR1`, `NatureR2`), die zur Laufzeit angelegt werden und in `Ambience` münden; die Lautstärke-Einstellung gilt also weiter.
- **Konsequenzen:** Tageszeiten und Orte wählen eine Definition statt einer Datei (`DayLight`, Szenen-Export `ambience`). Neue Orte brauchen nur eine neue `.tres`. Ob es nach Natur klingt, entscheidet das Ohr im Playtest (KNOWN_ISSUES #29).
- **Nachtrag 22.10. (ADR-047):** Der Bach ist dort zu hören, wo er fließt: `MapView` setzt auf Karten mit `[meta] style = "tal"` Schleifen-Emitter (Bus `Ambience`, −6 dB, Reichweite 220 px, Dämpfung 1,5, Wasserfälle +4 dB) aus der gebackenen Wassermaske, nicht aus den Kartenzellen (Trittsteine und Brücke sind dort „Stein“ und „Holz“). Abstand mindestens 8 Zellen, von der Mitte des Wassers nach außen; im Tal sind es fünf, einer davon bei den Trittsteinen. Gemessen am Netz +2,9 dB über dem Bett. Die Betten aller sechs Soundscapes liegen in einer Aufnahme innerhalb von 1,4 dB (−26,2 bis −24,8 LUFS); der Abend ist so voll wie der Tag, `content/audio/haus_abend.tres` (Feuer −11 dB, Grillen −16 dB, Knarren, kein Dach, Wind 0,15) ersetzt das Haus-Bett am Abend. Positionsklänge (`SoundBank.play_at`) tragen `HEARING_DISTANCE` 360 px mit Dämpfung 1,5.

## ADR-035 · Der wahre Titel heißt „Nach Elysia“
- **Status:** angenommen · 2026-10-06 (vorläufig, Bestätigung durch den Projektinhaber ausstehend)
- **Kontext:** Playtest Phase 3: „Finde einen passenderen Namen als ‚Real‘, Elysia ist für die erste Welt super.“ Die Bible führt REAL ausdrücklich als Arbeitstitel. §2 will gerade nicht die Frage „fake oder real?“ stellen, sondern „Was bedeutet es, wirklich am Leben zu sein?“; §65: „Du musst keinen Teil von dir vernichten, um weiterzugehen.“
- **Entscheidung:** Der Titel nach dem Übertritt (Startbild, Titelkarte am Ende des Slice, Fenstertitel) lautet **„Nach Elysia“** (englisch später „After Elysia“).
  - Das Logo nimmt dieselben Serifen-Buchstaben wie Elysia, aber ungeschmückt (kein Gold, keine Filigran-Ranken), mit einem feinen Riss durch das Y. Wo Elysias Kristall schwebte, wächst ein Keimling (§29/30: der Samen ist das zentrale Symbol).
  - Der Fenstertitel folgt dem Startbild: „Elysia“, bis ein Spielstand die Wirklichkeit erreicht hat.
  - REAL bleibt interner Projektname: Ordner der Spielstände (`REAL`), Bundle-ID, Repository und Dokumente ändern sich nicht, damit keine Spielstände verloren gehen.
- **Begründung:** Der Spieler kennt das Wort Elysia, und im Moment der Enthüllung bekommt es eine neue Bedeutung: Es geht um das Leben danach, nicht um Echtheit gegen Fälschung. Der Titel stellt Elysia nicht als Feind hin, er spricht vom Weitergehen.
- **Verworfene Vorschläge:** „Wildwuchs“ (stark als Gegenbild zum gemähten Elysia, aber schwer international), „Lebendig“ (trifft die Kernfrage, aber kaum auffindbar), „Unscripted“ (klug, aber wieder fake gegen echt), REAL behalten (vom Projektinhaber als unpassend empfunden).
- **Konsequenzen:** Ein anderer Titel braucht nur `logo_real()` in `tools/art/make_title.py` und die Schlüssel `GAME_TITLE` und `BOOT_TITLE` in `content/locale/ui.csv`.

## ADR-036 · Slice-Texte sind Playtest-Text, Prototypen bleiben markiert
- **Status:** angenommen · 2026-10-06
- **Kontext:** Bisher musste jede gesprochene Zeile `[#ph]` tragen, „solange es keine finalen Texte gibt“. Gleichzeitig sagt die Content-Regel: vor dem Playtest darf keine `[#ph]`-Zeile übrig sein. Der Vertical Slice ist der Playtest.
- **Entscheidung:** Dialoge unter `content/dialogue/slice/` sind der Playtest-Text und tragen kein `[#ph]`; die Prototyp-Dialoge (Sandbox, Look-Prototypen, Grey-Box-Antreiber) bleiben vollständig markiert. Ein Test prüft beide Richtungen und dazu, dass jeder Sprecher im Slice eine Stimme in `voices.json` hat (ein Doppelpunkt in einer Erzählzeile machte sonst einen halben Satz zum Namensschild).
- **Konsequenzen:** Slice-Texte sind Entwürfe des Assistenten in der Stimme der Bible und werden nach dem Playtest überarbeitet. Zeilen ohne Sprecher sind Erzählung.

## ADR-037 · Die Geschichte steht in Flags, Karten und Szenen reagieren darauf
- **Status:** angenommen · 2026-10-06
- **Kontext:** Der Slice erzählt sieben Beats an vier Orten. Dieselbe Karte muss je nach Fortschritt anders aussehen (das Kind erscheint, der Riss öffnet sich, Mira kommt ins Haus, die Brücke wird geflickt, das Haus leuchtet).
- **Entscheidung:**
  - Jeder Zustand ist ein `WorldState`-Flag, eine Quest-Stufe, eine Erinnerung oder das Haus-Modell. Dialoge ändern ihn (`do WorldState...`), nie Szenen-Skripte über Umwege.
  - Requisiten in Karten tragen Bedingungen: `"if"`/`"unless"` (Flag oder Liste) lassen sie live erscheinen und verschwinden; `"sprite_when": {"<flag>": "<sprite>"}` wechselt ihr Bild. Türen und Kartenränder sind Requisiten (`door`, Spawn-Marker `spawn_<name>`), Sperren (`blocker`) erklären sich beim Untersuchen.
  - Je Ort ein Szenen-Skript (`world/levels/slice/*_scene.gd`), das nur inszeniert: Cutscenes, Licht, Musik, Rückfälle gegen Festhängen (der Riss öffnet sich nach Zeit auch ohne das Kind).
  - `Beat.mark(id)` setzt `beat.<id>` und loggt Spielminute und Sekunde, damit der Playtest-Log die Minuten jedes Beats belegt.
- **Konsequenzen:** Laden eines Spielstands stellt jede Szene richtig her, weil sie nur aus dem Zustand gebaut wird. Neue Beats brauchen meist nur Dialog, Flags und Kartenzeilen.

## ADR-038 · Der Antreiber im Slice: dieselben Regeln, neues Gewand
- **Status:** angenommen · 2026-10-06
- **Kontext:** Der Grey-Box-Encounter aus Phase 1 (Regeln in `AntreiberModel`) ist geprüft, sah aber nach Platzhalter aus.
- **Entscheidung:** `SliceAntreiber` erbt vom Encounter und tauscht nur, was man sieht und hört: zwei sich wiederholende Wegstücke im Tal-Stil (gebackener Boden, Bäume auf jeder Naht), eigene Figur, eigene Zurufe, der Schuppen als zurückweichendes Ziel, Regen und Farbkorrektur wie im Tal. Wer stehen bleibt, hat den Schuppen neben sich und das Holz vor den Füßen. Ein Wegweiser zeigt immer „Schuppen 200 m“; wer ihn liest, bleibt dabei stehen.
- **Konsequenzen:** Der Grey-Box-Encounter bleibt als Prototyp (`--start=antreiber`) und testet die Regeln weiter. Die Szene des Slice heißt `weg`.
- **Nachtrag 22.10. (ADR-047):** Der Weg ist ein Trampelpfad statt einer Straße: Mittellinie und Breite wandern (2 bis 4,4 Zellen), zwei Graszungen ragen hinein (`_trail` in `layout_slice_maps.py`). In der Prüfung des Reviews hält keine Kante mehr als 6 Spalten dieselbe Zeile (das Skript nennt 5). Die Nahtspalten 0 und 19 (Zeilen 9 bis 13) sind unverändert. Der Antreiber läuft aus seinem eigenen Schritt: Er gilt als gehend ab 6 px/s, schaut in Gehrichtung (Rückweg nach Westen ohne Rückwärtsgehen) und wählt die Animationsgeschwindigkeit nach seinem Tempo (Gehen /88, Rennen /144, wie beim Spieler); das Schrittpaddeln beim Hinterhergehen ist weg. Sein Ruf liegt bei −1 dB, ein Wippen von 1 px hebt ihn bei jedem Ruf.

## ADR-039 · Das Haus von innen: kleine Karte, gemalte Raumhülle
- **Status:** angenommen · 2026-10-06
- **Kontext:** Der Boden-Baker malt Landschaft, keine Innenräume mit Wänden.
- **Entscheidung:** Das Haus ist eine kleine Textkarte (Dielen, feste Wände) mitten in Schwarz; Blockwand, Fenster, Seitenwände und Türöffnung malt ein flaches Requisit `haus/shell`. Licht: kalt-blauer Raum mit Fensterschein, bis das Feuer brennt; dann wechselt der Raum über Sekunden ins Warme, und Regen auf dem Dach plus Kaminfeuer ersetzen die Stille.
- **Konsequenzen:** Weitere Innenräume brauchen eine eigene Hülle (oder später ein Tileset). Der Raum ist klein auf dem Bildschirm (KNOWN_ISSUES #44).
- **Nachtrag 22.10. (ADR-047):** Das Haus ist 1,5× gezoomt (Ausnahme von ADR-045), die Vignette 0,5 statt 0,34, und ein weicher dunkler Ring (`NightSurround`, Alpha 0,8 bei 256 px) hängt um den Raum. Das Fenster zeigt den Regentag, nicht die Nacht (Glas in Graublau bis Himmelblau; die Abnahme fand es etwas heller und bläulicher als geplant, `RAIN_GLASS` in `slice_props.py`). Die Seitenwände sind zweistufige Balken. Mira kommt sichtbar herein: Die Tür öffnet sich, ein `GuestWalker` geht mit 40 px/s um den Teppich zum Feuer und setzt sich (`house.mira_seated`, danach übernimmt die Mira der Karte); nach dem Gespräch steht sie auf, geht mit 45 px/s hinaus, die Tür schließt (`house.mira_left`). Das Feuer zündet in zwei Takten: Holz ablegen, 0,5 s später Streichholz und Aufflackern (`Fireplace.IGNITE_DELAY`, Flare-Licht 2,4 → 0 in 1,4 s, Glut, Ansicht wackelt 1,5 px für 0,25 s); Fensterlicht pulst beim Öffnen der Tür um 0,35 für 1,2 s. Am Abend gilt `haus_abend.tres`. Die Katze am Fenster miaut gedämpft bei jedem Ansehen, die schlafende schnurrt (ADR-047).

## ADR-040 · Der Slice nach dem Bible-Abgleich: mehr Leben, keine neuen Systeme
- **Status:** angenommen · 2026-10-06 (Freigabe des Projektinhabers: „Gleiche es mit der Game-Bible ab und optimiere es, dass es immer besser und realistischer und natürlicher wirkt“)
- **Kontext:** Der Slice deckte alle Beats von §56 ab, war aber kürzer als geplant (KNOWN_ISSUES #43) und an einigen Stellen dünner als die Bible: Elysianer sagen nie Nein, ohne dass man es ausprobieren kann (§1, §46); das spätere Hauptthema fehlte in Elysia (§35); die Wirklichkeit hatte wenig zu riechen und zu schmecken (§12); Mira stand nur da (§13: eigene Ziele); der Antreiber zeigte nicht, warum seine Strategie Sinn hatte (§59, Risiko 8); nach dem Feuer fehlte die Ruhe (§45); die Ziege tauchte nicht absurd auf (§33).
- **Entscheidung:**
  - Elysia: Die Zwillinge am Eingang fragen, was sie für dich tun können, und sagen zu allem Ja, auch zur Bitte, einmal Nein zu sagen. Miras erstes Nein greift das danach in einer Erzählzeile auf. Das Kind summt leise das Motiv der Tal-Musik; das Summen ist nur in der Nähe zu hören und führt zu ihm.
  - Tal: Mira hat einen Tagesablauf (Netz, Feuer, Angel am Bach, jedes Mal unterschiedlich lang), abends sitzt sie auf der anderen Seite ihres Feuers. Neue Stellen zum Ansehen: die Muschel an ihrer Plane (am Ende dreht sie sich im Wind), der Stiefelabdruck am Feuer, Wildblumen, die nach etwas riechen, Brombeeren, die sauer und süß sind, ein krummer Baum, eine Zaunlücke. Wer sich Mira als „Held von Elysia“ vorstellt, bekommt ein „Aha.“, und im Haus erinnert sie sich daran.
  - Weg: mehr Zurufe; nach dem Holz sagt der Antreiber, warum Rennen für ihn immer funktioniert hat, mit drei Antworten.
  - Haus: Der Teppich am Kamin ist ein Sitzplatz. Wer sich ans brennende Feuer setzt, hat einen ruhigen Moment, danach klopft Mira; ohne Sitzen klopft sie spätestens nach 40 Sekunden.
  - Abend: Nach dem Tausch trottet die Ziege davon und steht kurz darauf oben auf dem Holzstapel am Haus; Mira kommentiert es.
  - Bausteine dafür: `NpcWalker` mit `"pause"` und `"face"`, `Decor` mit `"sit"`, Karten-Requisiten bekommen `"live": true`, wenn die Geschichte sie während der Szene bringt (Auftritt mit Verzögerung), Requisiten mit `leave()` gehen ihren eigenen Weg ab.
- **Nicht gemacht:** ein Händler in Elysia (§10) braucht neue Figuren- und Standgrafik mit Spiegelzwilling; er steht als Vorschlag in `PHASE4_PLAN.md`.
- **Konsequenzen:** Alles hängt an Flags und Karten (ADR-037), Speichern und Laden stellen es her. Geschätzt kommen beim ersten Spielen einige Minuten dazu, vor allem durch Entdecken; gemessen wird im Playtest.

## ADR-041 · Die Wirklichkeit warm gemalt (Ghibli-Gefühl), Elysia bleibt Hochglanz
- **Status:** angenommen · 2026-10-06 (Wunsch und Auswahl des Projektinhabers: nur die Wirklichkeit, Figuren nur weichere Farben)
- **Kontext:** Der Projektinhaber wünscht sich „mehr das Aussehen und den Vibe von Studio Ghibli, ohne die DNA zu ändern“. Die Bible will „Elysia ist perfekter. Die Wirklichkeit wird schöner.“ (§12, §3.4), moderne Pixel-Art (§36) und nichts Kopiertes (§60). Das Tal war bisher als gedämpfter Regentag gemalt (graues Oliv, flaches Licht).
- **Entscheidung:**
  - Nur die Wirklichkeit (Tal, Haus, Weg, Titel-Abendtal) bekommt die warme, gemalte Natur; Elysia bleibt symmetrischer Hochglanz. So wird der Kontrast stärker: Elysia schön wie ein Prospekt, die Wirklichkeit schön wie ein echter Tag.
  - Palette `tal` (`tools/art/pixelart.py`, `make_sprites.py` EXTRA): leuchtende Grüntöne mit gelbgrünen Lichtern und blaugrünen Schatten, Ocker-Erde, klarer Bach, honigfarbenes Holz, moosiges Schieferdach.
  - Licht (`DayLight`): Regen kühl und satt statt grau; Abend golden mit violetten Schatten, Wolkenschatten über den Wiesen und schrägen Lichtstrahlen (`SunRays`, Bildschirmebene, additiv); Nacht unverändert im Charakter.
  - Wind (`wind_sway.gdshader`): breite Wellen laufen durch Gras und Pflanzen, lassen sie stärker neigen und hell schimmern; in Elysia (Spiegelachse) nie.
  - Haus: warme Balken, Patchwork-Decke, Flickenteppich, Kräuterbündel, Pflanze, Kupferkessel mit Dampf, Staub im Licht (`AmbientParticles.dust`).
  - Kleines Leben: Frösche am Ufer, die weghüpfen (`AmbientLife.add_frogs`).
  - Figuren der Wirklichkeit (Spielfigur, Mira, Kind, Antreiber) mit angehobenen, angewärmten Dunkeltönen und warmbraunem Umriss; Proportionen und Designs bleiben.
  - Musik: Die Tal-Musik bekommt ein weiches, synthetisches Klavier mit dem Motiv und einer Antwort (2-3-5-3-2-1). Eigene Melodie, keine Anleihen.
- **Konsequenzen:** Alles bleibt prozedural und kostenlos. Die Referenz dient nur der Stimmung (keine Figuren, Kreaturen, Motive oder Kompositionen, keine Werbung mit dem Namen). Handgepixelte Schlüssel-Assets (ART_DIRECTION, „Nächste Schritte“) sollen diese Richtung später aufnehmen.
- **Nachtrag 22.10. (ADR-047):** Der Regentag ist kühl und satt (gemessen, nicht geschätzt): `world_tint` (0,97, 0,99, 1,0), Sättigung 1,14, Kontrast 1,08, Helligkeit 0,07, `shadow_tint` (0, 0,02, 0,05) ohne grünen Schleier, `depth_haze` 0,12, `haze_color` (0,8, 0,87, 0,9), `water_glints` 0,6. Das Holz der Brücke erreicht Chroma 51 (Ziel ab 50); die Helligkeit des 95. Perzentils liegt bei 0,57 statt der geplanten 0,65, bewusst: heller wäre ein klarer Tag. Die Werte in `tal.tscn` waren tot (`DayLight.set_preset` überschreibt sie) und sind entfernt; die Presets tragen jetzt `sky_top` und `sky_bottom`, die `DayLight` auf den `Backdrop` blendet. Der Abendhimmel (`sky_top` (0,45, 0,6, 1,0)) kommt nach Tönung und Grading als kühles Dämmerviolett über goldenem Horizont an (vorher grau-beige). Regen: 320 Tropfen, 1×8 px, Alpha 0,75, Geschwindigkeit 380 bis 440; Abendstrahlen Alpha 0,18. Der Dunst am Fuß der drei Bergketten ist schwächer (0,45, 0,3, 0,15 statt 0,75, 0,6, 0,5), die fernste Kette klarer.


## ADR-042 · Tiefe statt Breite: der Slice nach dem Abgleich mit vier Referenzspielen
- **Status:** angenommen · 2026-10-06 (Auftrag des Projektinhabers: „Analysiere und optimiere dieses Spiel, ohne seine Grundidee, Philosophie oder Identität zu verändern“, Maßstab Explorers of Sky, HeartGold/SoulSilver, Black/White, Black 2/White 2; ausgewählt: alle vier Pakete; Zusatz: „Behalte auch die Suchtmetapher stets im Hinterkopf“)
- **Kontext:** Analyse in `docs/ANALYSE_REFERENZEN.md`. Der Slice war thematisch geschlossen, aber systemisch dünn: Von 23 Erinnerungen an Mira las er nur 3 wieder; der Protagonist sagt selbst nie Nein; die fehlende Spiegelung in Elysia hatte keine Auflösung; die Lösung des Antreibers (stehen bleiben) wurde vorher nirgends erfahrbar (§46); Stein und Samen kamen nach dem Übertritt nicht mehr vor; geschätzte Spielzeit 25–38 statt 45–60 Minuten. Jeder Vorschlag wurde an vier Fragen geprüft: verstärkt er die Kernfantasie, erzeugt er echte Entscheidungen, vertieft er Bestehendes statt neue Systeme, bleibt das Spiel intuitiv und es selbst.
- **Entscheidung:**
  - **Echo** (Explorers of Sky: der Partner erinnert sich): Am Abend an Miras Feuer greift sie auf, was am Tag war (erste Begegnung, ihr Nein, was du ihr erzählst: Brombeeren oder Blumen, der Weg zum Schuppen, die Katze). Sie fragt nach Elysia; „Darüber will ich nicht reden.“ nimmt sie mit „Gut.“ an (Grenzen I/II, §17, Spiegel ihres eigenen Neins), „Manchmal fehlt es mir.“ mit „Klar.“. Wer nach der Muschel gefragt hat, kann „Zum Meer?“ erraten (Wahrnehmung). Nach dem Regen zeigt die Pfütze am Lager dich selbst (Auflösung von §9). Der Stein bekommt einen Platz im Regal (`ItemDef.placeable`). Leise Echos: Miras Fisch schmeckt nach etwas, im kalten Haus denkt man kurz an die Suppe drüben.
  - **Innehalten** (HeartGold/SoulSilver: die Welt reagiert, ein Begleiter geht mit): Frösche kommen näher und quaken, wenn man still steht; Elysias Schmetterlinge fliegen ihre Runde, egal was man tut. Der Antreiber geht nach dem Schuppen hinter dir statt voraus und setzt sich am Talrand hin. Im Haus kommt er, wenn du am Feuer sitzt, und hat Ideen; bleibst du sitzen, setzt er sich dazu, und später schläft die Katze auf ihm (§28); stehst du auf, geht er hinaus und sucht sich etwas.
  - **Bindung:** Die Katze bekommt einen Namen, wenn man will (§28; `GameState.House.cat_name`, Namenswahl wiederverwendet), Mira fragt danach. Das Journal liest sich in der Wirklichkeit wie ein Tagebuch: keine Häkchen, und unter „Menschen“ steht in kurzen Sätzen, was mit Mira war (§23: Beziehung über gemeinsame Erinnerungen, nie als Wert).
  - **Elysia-Dichte** (Black 2/White 2): Die zweite Aufgabe der Gärtnerin (der stille Brunnen) löst sich unterwegs von selbst, mit +10.000 XP und einem Levelsprung (§8, §10).
  - Nebenbei: NPCs können sitzen (`"sit": true`); Mira sitzt jetzt im Haus und abends an ihrem Feuer (KNOWN_ISSUES #48).
- **Suchtmetapher:** bleibt ungenannter Subtext (§3.2, §4: keine Suchtbegriffe, kein Abstinenzspiel). Sie lenkt die Gestaltung: Elysias Belohnungen steigen, während die Tat verschwindet; die Wirklichkeit belohnt langsam und nur, wer da ist (Frösche); die Sehnsucht nach Elysia darf auftauchen und wird nicht bestraft (Suppe, „Klar.“); Verbindung ist das Gegengewicht (Mira, Katze); der Antreiber wird integriert, nicht besiegt.
- **Verworfen:** Sammel- und Prozentanzeigen, Medaillen (Elysias Logik); tägliche Ereignisse (§52); ein Persönlichkeitstest am Anfang (Therapie-Risiko, Werte erst später, §18); Mira als ständige Begleiterin (§13); mehr Nebenquests (§48); den Samen pflanzen (Finale, §30).
- **Konsequenzen:** Keine neuen Systeme; alles hängt an Flags, Erinnerungen und Karten (ADR-037). Speicherstand: optionales Feld `house.cat_name` (fehlt es, gilt leer; kein neues Schema). Geschätzt 8–12 Minuten mehr beim ersten Spielen, durch Gespräch und Entdecken. Offen für den Playtest: ob der Antreiber im Haus für andere sichtbar wirken soll (Mira spricht ihn nie an) und ob die Frösche ohne Hinweis entdeckt werden.
- **Nachtrag 22.10. (ADR-047):** Mira arbeitet am Netz: am ersten Routenpunkt steht sie im Profil nach links (`work_face`, Standard `w`) und wechselt zwischen den zwei Bildern des Zustands „work“; von hinten wären die Hände verdeckt gewesen. NPCs und der Antreiber gehen hörbar (`NpcSteps`, 6 dB unter den Schritten des Spielers, positional, Untergrund von der Karte); Elysianer schweigen, das Kind nicht (es ist dort das Einzige, das sich spiegelt). Sprecher wippen 1 px für 0,06 s, höchstens alle 0,12 s, im Takt der Stimmklänge; das Kind summt alle 4 bis 8 s statt 7 bis 13 s. Die Frösche hört man jetzt (−2 dB am Aufruf, Reichweite 360 px, Untertitel „Frösche quaken.“).

## ADR-043 · Zoom und Tiefen-Bogen: Elysia flach, die Wirklichkeit näher und tiefer
- **Status:** angenommen · 2026-10-06 · Zoom und Vordergrund ersetzt durch ADR-045 (Wunsch des Projektinhabers: „ein etwas stärkerer Zoom auf den Charakter, damit die Map größer wirkt“, „etwas mehr 3D und dadurch auch mehr räumliche Tiefe … natürlich nur, wenn es dadurch tatsächlich besser aussieht“; die Tiefe soll mit der Verbindung zur echten Welt wachsen, anfangs eher 2D wie HeartGold, später räumlicher wie Schwarz/Schwarz 2; ausgewählt: „Zoom 1,5× + Tiefen-Bogen“)
- **Kontext:** Bei 640×360 Spielpixeln wirkten Figur und Räume klein; das Haus lag als Kasten in viel Schwarz (KNOWN_ISSUES #44). Echtes 3D oder eine perspektivische Verzerrung würde die Pixel ungleich machen und die Pixel-Art brechen (ART_DIRECTION, Raster). Tiefe muss also aus Ebenen, Dunst und Kamera kommen.
- **Entscheidung:**
  - **Zoom pro Szene** (`GameScene.view_zoom`): Elysia bleibt bei 1× (weit, flach, ein Bild), Tal, Haus und der Weg zum Schuppen haben 1,5×. Die `GameView` verkleinert dafür den Welt-Viewport (`view_size` = 640×360 / Zoom) und vergrößert das Weltbild. Bei ganzzahligem Zoom bleibt Nearest; sonst tastet der Anzeige-Shader scharf ab (`sharp_sample.gdshaderinc`: innerhalb eines Pixels flach, an der Kante ein Bildschirmpixel Übergang). So bleiben die Pixel bei jeder Fenstergröße gleich groß. Die UI bleibt bei 640×360.
  - **Tiefen-Bogen:** Elysia hat keine Tiefe (kein Dunst, Wolken ohne Parallaxe). Die Wirklichkeit bekommt drei Mittel, die zur Draufsicht passen:
    - **Luftdunst** (`grade.gdshader`, `depth_haze`, `haze_color`): Nach oben im Bild, also in die Ferne, wird es leicht dunstiger. Die Stärke folgt dem Tageslicht (Regen mehr, Abend warm).
    - **Hintergrund** (`Backdrop`): Über der nördlichen Baumgrenze liegen Himmel und drei Bergketten, die sich mit der Kamera umso langsamer bewegen, je weiter weg sie sind. Die Kamera darf dafür bis zu 128 Pixel über die Karte hinaus. Im Regen verdeckt sie der Nebel, am Abend leuchten sie. Am Ende schwenkt die Kamera mit, wenn „Mira schaut zu den Bergen. Lange.“ (`valley.mountains_seen`): Die Zeile stand schon im Slice, jetzt sieht man, wohin sie schaut.
    - **Vordergrund** (`ForegroundFoliage`): Am südlichen Waldrand, dem Teil der Welt, der der Kamera am nächsten ist, ragen dunkle Kronen ins Bild und gleiten schneller vorbei als der Boden.
  - Einstellung „Tiefenebenen bewegen sich mit“ (`display.parallax`, an): Aus heißt, Hintergrund und Vordergrund stehen still (Bewegungsempfindlichkeit).
- **Verworfen:**
  - Echte Perspektive oder schräge Projektion: Die Pixel würden ungleich.
  - Vordergrund-Zweige an den Seitenrändern: Durch die Parallaxe rutschen sie gerade dann aus dem Bild, wenn der Rand zu sehen ist, und im Standbild wirkten sie wie dunkle Flecken.
  - 2× Zoom: zu wenig Überblick für Bach und Trittsteine.
  - Zoom auch in Elysia: Elysia soll weit und flach wirken, das ist der Kontrast.
- **Konsequenzen:** Der Zoom gilt pro Szene; neue Szenen erben 1×. Was Weltkoordinaten in UI umrechnet, nutzt `GameView.world_to_ui`. Die Berge und Kronen sind prozedural gemalt, ohne Asset-Dateien. Die Kamera zeigt am Nordrand jetzt Himmel statt Kartenende. Mehrkosten: ein Polygonzug pro Kette und einige Texturen am Südrand, nur bei Kamerabewegung neu gezeichnet. KNOWN_ISSUES #44 ist behoben.
- **Nachtrag 22.10. (ADR-047):** Der Interaktions-Hinweis ist Teil der UI: ein `Control` in einer eigenen `CanvasLayer` der `GameScene` (`GameScene.PROMPT_LAYER` 11, unter dem HUD auf 12; neue Menüs und Overlays liegen darüber), Position `GameView.world_to_ui(Anker).round()`, Wippen 1 UI-Pixel. Er wird nicht mehr mit 1,25× vergrößert und ist optisch rund 20 % kleiner. `world_to_ui` zieht den Bruchteil der weichen Kamera ab (`GameView.camera_remainder`), damit Overlays beim Scrollen nicht gegen die Welt schwimmen. Der Prompt gehört der Szene (`GameScene.prompt`); der Spieler hat keinen mehr. Die Sprechblasen des Antreibers liegen noch im Weltraum.

## ADR-044 · Playtest-Gate: Release-Entwurf auf Versions-Tag, Beat-Zeilen in jedem Build
- **Status:** angenommen · 2026-10-06 (Phase 5, Auftrag des Projektinhabers: „Weiter“ nach dem Merge von Phase 4)
- **Kontext:** Phase 5 verlangt Build, Testanleitung, bekannte Probleme, Playtest-Fragen, Risiken, Leistung, Platzhalter und nächste Schritte (Master-Prompt §47). ADR-009 sah Playtest-Builds als GitHub-Release vor. Das Repository ist inzwischen öffentlich; ein veröffentlichtes Release kann jeder herunterladen. Beim Vorbereiten fiel auf, dass Release-Builds nur Warnungen und Fehler loggen: Die Beat-Zeilen mit den Spielminuten, mit denen der Playtest die Spielzeit misst, fehlten ohne `--log-debug`.
- **Entscheidung:**
  - Version **0.5.0** (Phase 5; nach dem zweiten Spielen 0.5.1). Ein Tag `v<Version>` oder ein manueller CI-Lauf mit „release“ baut Windows, macOS und Linux und legt mit `tools/release.sh` einen **Release-Entwurf** an (Pre-Release, je System ein Zip mit `LIESMICH.txt`). Der Tag muss zur Version in `project.godot` passen; ohne Tag zeigt der Entwurf auf den Commit, und GitHub legt den Tag beim Veröffentlichen an (die Cloud-Sitzung kann keine Tags pushen). Den Entwurf veröffentlicht der Projektinhaber.
  - `Log.record` schreibt in jedem Build. Genutzt nur für die Minute jedes Beats und die Build-Zeile beim Start, damit jedes Tester-Log Spielzeiten und Version enthält, ohne persönliche Daten.
  - Eine Testanleitung für alle Tester (`PLAYTEST.md`, Fragen nach Master-Prompt §48) und ein Gate-Bericht mit Gate-Matrix M/Ä, Risiken, Leistung, Platzhaltern und nächsten Schritten (`GATE_REPORT.md`).
- **Konsequenzen:** Releases zählen nicht zum Artefakt-Speicher. Ohne Veröffentlichung bleibt der Build privat. Die Schwellen der Gates sind Vorschläge, die der Projektinhaber vor der Auswertung festlegt. Nach Phase 5: STOP, bis Ergebnisse vorliegen.
- **Nachtrag 22.10. (ADR-047):** Die Lizenztexte reisen mit dem Build: `export_presets.cfg` nimmt `assets/fonts/*/OFL.txt` und `addons/dialogue_manager/LICENSE` in alle drei Presets auf, `tools/release.sh` legt in jedes Zip einen Ordner `Lizenzen` (OFL der drei Schriften, MIT von Dialogue Manager und GUT) und nennt ihn in `LIESMICH.txt`. Version 0.7.0.

## ADR-045 · Nach dem ersten Spielen: Zoom 1,25× überall, gewachsene Waldränder, Gate-Schwellen
- **Status:** angenommen · 2026-10-06 (Rückmeldung des Projektinhabers zum Build von Phase 4e: „Ich finde den Rand an der Map nicht natürlich, das stört total und sieht nach Bug aus“, „Im Wald sind die Stämme der Bäume merkwürdig weiß“, „den Zoom würde ich gefühlt überall auf 1,25 setzen“; die Gate-Schwellen hat er an Claude übertragen)
- **Kontext:** Aufnahmen aller Kartenränder zeigten zwei Fehlerbilder:
  - Der Waldboden war zellengenau als dunkle Fläche gebacken, der Schatten darunter folgte den Zellen. Wo die Kronen eine Lücke ließen, entstanden gerade Linien und dunkle Rechtecke am Übergang zur Wiese.
  - Die dunklen Vordergrund-Kronen am Südrand (ADR-043) wirkten im Spiel wie ein Darstellungsfehler.

  Im Nachtwald lagen die Birkenstämme fast ganz auf der Leuchtebene und blieben dadurch weiß, während die Nacht alles andere abdunkelte.
- **Entscheidung:**
  - **Zoom:** 1,25× überall (`GameScene.view_zoom` als Vorgabe, keine Ausnahmen; Welt 512 × 288 Spielpixel). Der Kontrast Elysia/Wirklichkeit kommt allein aus Dunst und Bergen.
  - **Waldränder der Wirklichkeit:** Der Rand entsteht aus Kronen statt aus dem Zellraster.
    - Unter dem Waldrand liegt Wiese, nur das Waldinnere (über 10 Pixel vom Rand) ist dunkler Boden.
    - Eine zusätzliche Reihe Kronen steht leicht zurückgesetzt entlang des Rands.
    - Der Schatten folgt dem Umriss der Kronen.

    Elysia behält seine geschnittenen Hecken; ihr Boden bleibt bitgenau gleich.
  - **Vordergrund-Kronen** entfernt.
  - **Birken:** Rinde blassgrau statt weiß; nur ein schmaler Mondlichtsaum und die Blattspitzen leuchten.
  - **Gate-Schwellen** fest:
    - Pro Tester und Gate gilt ja / teils / nein.
    - Ein Gate ist erfüllt ab zwei Dritteln ja und verfehlt unter einem Drittel.
    - Bestanden heißt: Desire erfüllt und die Kern-Gates der Mechanik erfüllt.
    - Mindestens vier fremde Tester; Spielzeit-Median ab 35 Minuten (`GATE_REPORT.md`).
- **Konsequenzen:**
  - Die gebackenen Böden von Tal, Weg, Look-Tal und Wald sind neu erzeugt.
  - Die Kollision bleibt zellengenau; an Waldrändern kann die Figur einige Pixel vor den Kronen stehen bleiben, wie am Ufer (KNOWN_ISSUES #15).
  - Berechtigung: Der Projektinhaber erlaubt künftig Pull, Commit und Merge ohne Rückfrage.
- **Nachtrag 07.10.** Der Projektinhaber markierte im Abendbild drei weitere unnatürliche Stellen:
  - **Waldkante vor den Bergen:** Die Oberkante war ein Lineal. Jetzt gibt es eine eigene, mit dem Laub des Waldes gebackene Baumgrenze (`[meta] treeline`, `bake_ground.py`): Kronen verschiedener Größe, einzelne höhere Bäume, 32 Pixel über und unter dem Kartenrand, vor den ersten Kartenreihen. Die runden Kronen und die ferne Baumreihe des Hintergrunds entfallen.
  - **Bachursprung:** Der Bach begann mitten im Wald, daneben standen Stämme im Wasser wie Pfosten. Jetzt kommt er vom Kartenrand unter den Bäumen hervor, und über Wasser werden keine Stämme mehr gemalt.
  - **Felsstufen:** Sie endeten gerade im Wald. Jetzt hängen Kronen bis zu 7 Pixel über ihre Kante. Felsstücke unter drei Zellen Breite werden Wald oder Wiese (`layout_slice_maps.py`).

  Elysia bleibt bitgenau gleich.
- **Nachtrag 10.10.** Nach dem zweiten Spielen („ansonsten fand ich alles stimmig“):
  - **Wald in die Tiefe:** Die letzte Baumreihe vor den Bergen wirkte abgehackt. Die Baumgrenze reicht jetzt 64 statt 32 Pixel über den Kartenrand. Hinter der vorderen Reihe (unverändert) geht der Wald in vier Reihen über sanfte Hügel weiter, nach hinten kleiner, kontrastärmer und dunstiger. Die hintersten Reihen sind leicht durchscheinend, damit der Nebel im Regen sie mit den Bergen verschluckt. Die vorderste Bergkette steht 16 Pixel höher und wird zu Vorbergen über dem Wald; sonst ragten nur ihre Spitzen wie kleine Pyramiden über die Bäume.
  - **Birken:** Auch blassgrau wirkten die Stämme im Dunkeln komisch. Sie sind durch alte Bäume mit dunklem Stamm ersetzt; nur die hellsten Blätter oben auf der Krone leuchten schwach (`wald/glow_tree`, ID bleibt).
  - **Nasen:** Die Einzelpixel-Nase wirkte von vorn wie ein Fleck, im Profil wie ein umrandetes Kästchen. Die Figuren haben keine Nase mehr; Augen und Wangen tragen das Gesicht (`make_character.py`).
  - **Größere Karten** wünscht sich der Projektinhaber für das ganze Spiel; das gehört zur Kartenpipeline der Full Production (`OFFENE_PUNKTE.md`).
- **Nachtrag 22.10. (ADR-047) · Ausnahme Innenräume:** Das Haus (`haus.tscn`, `view_zoom = 1.5`) ist die einzige Ausnahme vom 1,25-fachen Zoom. Der Raum (16×12 Zellen, 256×192 px) füllt bei 1280×720 rund 60 % der Breite und 80 % der Höhe (gemessen 768×576 von 1280×720), bleibt mittig und ganz sichtbar (Ansicht 427×240 Weltpixel, Kamera auf den Raum geklemmt); bei 640×360 sind es 384×288 UI-Pixel. Grund: Ein kleiner Raum soll sich wie ein Raum anfühlen und nicht wie eine Karteikarte im Dunkeln (KNOWN_ISSUES #44). Bei 720p ergibt 1,5× genau 3 Bildschirmpixel je Weltpixel, ohne Mischpixel. Alle anderen Orte bleiben bei 1,25×. Weitere Innenräume bekommen 1,5 über `view_zoom` in ihrer `.tscn`. Offen bleiben die ungleich breiten Pixel bei 1,25× (jede fünfte Bildspalte ist bei 1280×720 ein Mischpixel): unverändert bis zum Playtest, scharfes Abtasten wie bisher (ADR-043); eine Einstellung „Pixelraster exakt“ wird nur gebaut, wenn Tester es nennen.
- **Nachtrag 23.10. (Version 0.8.4):** Der Projektinhaber bestätigt auf dem Mac im Vollbild einen schwarzen Rand (Retina 3024×1964 mit ganzzahliger Skalierung ×4: rechnerisch 15 % an den Seiten und 27 % oben und unten). Die in ADR-047 versprochene Option ist gebaut: Einstellung „Bild füllen (schmalere Ränder)“ (`display.fill_screen`, vorab aus). Sie stellt `Window.content_scale_stretch` auf *Fractional* (`SettingsService.apply_fill_screen`): Das Bild wird um einen beliebigen Faktor vergrößert, der Rand schrumpft auf das, was das Seitenverhältnis verlangt (hier oben und unten je rund 7 %). Preis: Spielpixel der Oberfläche sind nicht mehr alle gleich breit (bei 4,725× ist gut jede vierte Spalte einen Bildschirmpixel schmaler); die Welt bleibt durch das scharfe Abtasten (ADR-043) gleichmäßig. Der Standard bleibt pixelgenau. Ein Bild ohne jeden Rand (Seitenverhältnis dehnen oder mehr Welt zeigen) ist nicht gebaut: Es bräuchte ein größeres Sichtfeld, das die Karten nicht vorsehen.

## ADR-046 · Polish-Runde: Gefühl, Bedienung, Erzählung, Technik, Bild und Ton
- **Status:** angenommen · 2026-10-11 (Auftrag des Projektinhabers: „allumfassende Optimierungen, Verbesserungen, Korrekturen, Test in jeglichen wichtigen Aspekten und verbessere vor allem Spielgefühl und Design“)
- **Kontext:** Fünf Prüfungen des Slice (Spielgefühl, Bedienung, Erzählung, Technik, Bild und Ton) ergaben rund 110 Funde. Umgesetzt wurde alles mit hoher und mittlerer Priorität und die meisten kleinen Punkte; keine neuen Systeme, keine neuen Orte.
- **Entscheidung:**
  - **Spielgefühl:**
    - Die Blickrichtung hält eine Diagonale 0,08 s nach dem Loslassen; ein Stick an der Grenze zweier Richtungen flackert nicht mehr.
    - Scharfe Kurven nutzen das Wendetempo.
    - Schritte kommen aus dem Gehzyklus (Animation 10 statt 8, Laufen 14 statt 12 Bilder pro Sekunde); der Zyklus beginnt beim Richtungswechsel nicht neu.
    - Interagieren wird 0,12 s gepuffert und dreht die Figur zum Ziel; das gewählte Ziel haftet, damit der Hinweis nicht springt.
    - Hinsetzen und Aufstehen gleiten in 0,12 s; Türen behalten die Blickrichtung.
    - NPCs gehen mit ihrer Geschwindigkeit im Takt.
  - **Dialoge:**
    - Eine Sperre von 0,3 s nach dem Erscheinen der Antworten verhindert eine Antwort aus Versehen.
    - Der Text atmet an Satzzeichen.
    - Gedrückt halten blättert schnell, hält aber an Antworten; Zurück blättert ebenfalls weiter.
    - Die Box blendet aus; ein zweiter Dialog wartet, statt verloren zu gehen.
  - **Bedienung:**
    - Rückfragen mit vorausgewählter sicherer Antwort: Neues Spiel über einem Autosave, Beenden mit ungespeichertem Fortschritt (sonst wird vorher gespeichert), Einstellungen zurücksetzen, Spielstand überschreiben.
    - Laden und Menüwechsel blenden.
    - Das Journal scrollt; Hinweise nennen die Tasten des benutzten Geräts.
    - Neu: „Steuerung anzeigen“ und „Geräusche als Text“ (Bible §50).
    - Das Pause-Menü öffnet auch im Gespräch; Namensschild und Hinweise der Wirklichkeit sind lesbar.
  - **Erzählung (ADR-015, Nachtrag 10.10.):**
    - Der Antreiber ist nicht mehr zufällig lösbar.
    - Spiegel vor Brunnen; Elysias Wiederholungen erst nach Truhe und Schmetterlingen.
    - Die Trittsteine erklären sich beim Ansehen und nach dem Sturz.
    - Das Ende folgt direkt auf »Zum Meer.«.
    - Mira widerspricht beim Fisch; neue Stellen zum Ansehen in Tal und Elysia.
  - **Bild:**
    - Im Haus ruht die Kamera mittig auf dem Raum, statt der Figur ins Schwarz zu folgen; das Feuer leuchtet aus dem Kamin statt den Raum zu fluten. Klein bleibt das Haus mit Zoom 1,25× trotzdem (KNOWN_ISSUES #44).
    - Belohnungen in Elysia kommen in Wellen (höchstens zwei zugleich) und verdecken die Figur nicht mehr.
    - Der Abendhimmel hat weichen Sonnenschein; Strahlen fallen nur über der Wiese.
    - Figuren haben echte Schritte und eigene Silhouetten.
    - Schilf, Zaun, Trittsteine und Weltenbaum sind überarbeitet; die Streu wächst in Gruppen.
  - **Ton:**
    - Limiter auf Master; Überblendungen in Amplitude statt in dB.
    - Die Lautheit zwischen den Orten ist angeglichen.
    - Musik in 44,1 kHz; die Tal-Musik pausiert zwischen den Runden.
    - Schritte mit Ferse und Ballen je Untergrund; Lautstärkeregler mit quadratischer Kurve.
  - **Technik:**
    - Zwischensequenzen sperren unter eigenem Schlüssel.
    - Laden gilt ganz oder gar nicht; jede Blende hat ihr eigenes Signal.
    - Spielregeln messen Spielzeit, nie die Wanduhr.
    - Jeder Testlauf hat sein eigenes Profil.
    - `check.sh` spielt den ganzen Slice per Autopilot (rund 10 Sekunden).
- **Konsequenzen:**
  - Version 0.6.0.
  - Regeln für neue Arbeit:
    - Zeitfenster im Spiel laufen über `delta` oder `NodeTimer`, nicht über `Time.get_ticks_*` (schnelle Läufe mit `--fixed-fps` hätten sonst eine andere Spielzeit).
    - Jede neue Rückfrage fokussiert die sichere Antwort.
    - Klänge mit Erzählwert bekommen einen Eintrag in `AudioDirector.CAPTIONS`.
    - Ändert sich ein Menüablauf, muss `slice_full.json` mit; `check.sh` meldet es.
  - Die Klänge sind nur gemessen, nicht angehört (KNOWN_ISSUES #29, #34, #46).
  - Offen beim Projektinhaber:
    - die Endkarte („Ende des Prototyps. Danke fürs Spielen.“) gegenüber der Bible (§56: „Schwarz. Titel.“);
    - ungleich breite Pixel durch den Zoom 1,25× (ADR-045), sichtbar bei genauem Hinsehen.
- **Nachtrag 22.10. (ADR-047):**
  - **Tal-Musik:** Die Pause der Tal-Musik endete nie, wenn eine Szene denselben Track erneut anforderte (Ursprung: Commit 862dd7b, Backlog A25); Abend und Ende blieben stumm. `play_music(gleicher Track)` weckt jetzt einen rastenden Track (Einblenden mit dem übergebenen `fade`, neue Runden; fadet er noch aus, spielt er weiter). Rasten gilt nur, wenn `current_scene` eine `GameScene` ist (das Startbild rastet nie). `TRACK_REST` für `valley`: nach 2 bis 3 Loops (25,3 s) 25 bis 50 s Pause statt 40 bis 90 s. Belegt im echten Haus mit Feuer: „music rests“ bei 46,6 s Spielzeit, die erneute Anforderung 12 s später gibt „music returns“, die Lautheit steigt von −29 auf −24,7 LUFS.
  - **Ducking:** `duck()` senkt die Musik wie bisher um 7 dB und neu Soundscape und Ambience-Bett um 3 dB (0,4 s, in Amplitude). Belohnungen (Präfixe `coin`, `xp`, `loot`, `level_up`, `chest_open`, `praise`) ducken die Musik 1,2 s um 3 dB (Zähler `_reward_ducks`, gestapelte Belohnungen addieren sich nicht). Gemessen in Elysia: Spitzen höchstens −4,5 dBFS und Kurzzeit höchstens −17 LUFS (vorher −1,1 dBFS und −12,8 LUFS, die Musik allein liegt bei −19,2). Elysias Dialogstimme variiert nicht mehr in Tonhöhe und Pegel (wie `ui()`).
  - **Untertitel:** `CAPTIONS` kennt `cat_meow` (`CAPTION_CAT`) und `purr` (`CAPTION_PURR`). `cat_meow_muffled` (durch die Tür gehört) hat bewusst keine Zeile. Die Entprellung zählt Spielzeit statt Wanduhr.
  - **Türen:** Die Tonblende folgt der Bildblende (`GameScene.sound_fade_for`: unter 1 s doppelt so lang, Tür 0,4 → 0,8 s; Neustart 2 s und Riss 3,5 s unverändert), `SceneTravel.go` wartet auf die Blende selbst statt auf einen Timer am Tür-Knoten.
  - **Pegel und Messung:** Siehe ADR-047, Abschnitt Ton. Die Klänge sind jetzt gemessen, aber weiter nicht angehört (KNOWN_ISSUES #29, #34, #46).
  - **Offene Punkte dieses ADR:** Die Endkarte ist entschieden (keine Zeile auf der Karte, ADR-030, Nachtrag 22.10.). Die ungleich breiten Pixel bleiben bis zum Playtest (ADR-045, Nachtrag 22.10.).

## ADR-047 · Polish-Runde 2: Ton nach Lautheit, Erwachen und Ende, Bedienung, Figuren und Bild
- **Status:** angenommen · 2026-10-22 (zweite Prüfung des Slice in acht Linsen mit Gegenprüfung, danach neun Arbeitspakete mit je einer Abnahme; zu den sieben Entscheidungen, die dem Projektinhaber vorlagen, sagte er „Weiter“, also zu den Empfehlungen)
- **Kontext:** Nach ADR-046 prüfte eine zweite Runde den Slice erneut: Spielgefühl, Bedienung, Erzählung, Erstkontakt, Technik, Bild, Ton und der Vergleich mit anderen Spielen. Die Funde wurden gegengeprüft; 29 fielen weg (Geschmack ohne Beleg, nicht reproduzierbar oder Sache des Projektinhabers). Umgesetzt haben neun Pakete: Ton, Text, Bild, Menüs, Gefühl, Elysia, Haus, Figuren und Start. Keine neuen Orte und Beats; neue Bausteine nur dort, wo ein Fund sie braucht.
- **Entscheidung:**
  - **Entscheidungen des Projektinhabers (angewendet):**
    - Endkarte: keine Zeile mehr auf der Karte (Bible §56: Schwarz, dann der Titel). Die Zeile steht als Untertitel unter dem Logo des Startmenüs, sobald `slice.finished` gesetzt ist (ADR-030, Nachtrag 22.10.).
    - Kamera: *Weich* bleibt Standard und ist nachgestellt, *Pixelgenau* bleibt Option, der Playtest fragt (ADR-012, Nachtrag 22.10.). „Bewegungsgefühl“ und „Richtungen“ sind nur noch in Debug-Builds wählbar.
    - Zoom: 1,25× überall, im Haus 1,5× (ADR-045, Nachtrag „Ausnahme Innenräume“).
    - Mischpixel durch 1,25×: unverändert bis zum Playtest. Eine Vollbild-Rand-Option wird nicht gebaut; der Projektinhaber prüft das Vollbild auf dem Mac (Startmenü → Leistungstest, Bericht schicken).
    - Elysias erste Zeilen sind wärmer und ernster geschrieben (Erwachen, Gärtnerin, Journal-Eintrag „Der Held von Elysia“); die unheimlich-aufrichtigen Sätze („Du erkennst alles.“, die immer gleichen Runden) bleiben.
    - Tastenumbelegung: eigener Pull Request unmittelbar nach dieser Runde mit eigenem ADR (ADR-011, Nachtrag 22.10.).
  - **Ton (Lautheit statt Spitze):**
    - Alle erzeugten Effekte sind nach Lautheit je Gruppe normiert (LUFS, K-gewichtet nach BS.1770, weiche Decke −1 dBFS; `tools/audio/loudness.py`). Die Gruppenziele stehen in `make_sfx.GROUPS` und `make_slice_sfx.GROUPS`. Nicht alles ist erreichbar: Türen −18 (Plan −16), Wasser −15,5 (−14) und Stein −18 (−17), weil die scharfen Spitzen sonst mehr als 6 dB (`SQUASH_DB`) in die Decke gedrückt würden.
    - Aufrufgains: Pegel im Spiel = Dateilautheit + Aufrufgain + Bus-Trim (SFX −2 dB). Die Tabelle `CLASSES` in `tools/audio/check_levels.py` ist die Quelle der Gains. Real (dB am Aufruf): `door_open`, `door_knock`, `fire_light`, `wood_drop`, `splash_fall`, `stone_wobble`, `sit`, `stand`, `cat_meow`, `purr`, `pickup_real` 0; `door_close` −3; `frog_croak`, `goat_bleat`, `goat_munch`, `bird` −2; `bark` −1. Elysia: `xp` −6, `coin` −10, `level_up` −2, `chest_open` −2, `loot_*` −2, `praise` −8, `rift_touch` 0. Stimmen: Real −2, Elysia −1 (`VOICE_DB_REAL`, `VOICE_DB_ELYSIA`). Ohne die Elysia-Gains träfen die Schmetterlinge den Limiter.
    - Schritte: alle Untergründe −19 LUFS (Energie über 100 ms), Spitzen höchstens −6 dBFS (weiches Knie in `make_placeholders.fit_step`). Pegel nach Untergrund in `FootstepPlayer.SURFACE_DB` (gehen/rennen): Gras −5/−1, hohes Gras −8/−4, Erde −3/+1, Stein und Holz −2/+2, Pfütze und Wasser −1/+3; in Elysia zusätzlich −3 (`ELYSIA_DB`). Schritte anderer Figuren (`NpcSteps`) liegen 6 dB darunter.
    - Orte: Die sechs Soundscapes liegen innerhalb von 1,4 dB, Regentag −25,2, Abend −25,7, Nacht −25,1, Haus kalt −24,8, Haus mit Feuer −26,2, Wald −25,6 LUFS (Energiemittel in Aufnahmen; die Ziele des Plans standen auf einer um rund 2 dB tieferen Skala). Dazu Bach-Emitter, `haus_abend.tres` und Positionsklänge mit Reichweite (ADR-034, Nachtrag 22.10.).
    - Neue Klänge (eigene Synthese in `make_slice_sfx.py`): `cat_meow_muffled`, `purr`, `sit`, `stand`, `bird` (zwei Flügelschläge und Ruf), `bark_0` bis `bark_2` (drei Stockschläge des Antreibers). `fire_crackle` ist entfallen (nie aufgerufen; das Feuer ist das Bett `nature_fire_bed`).
    - Messen statt Hören: `tools/audio/check_levels.py` prüft Dateien (Lautheit, Decke, Gleichstrom, Knackser), Schritte, Orte und Klangklassen über dem Bett (150 Messungen) und läuft als Schritt „audio levels“ in `tools/check.sh`. `tools/audio/measure.sh` nimmt das Spiel mit Ton auf (Xvfb, Movie-Writer) und gibt die Lautheit je Sekunde aus (`timeline.py`), `bed_probe.gd` spielt die sechs Soundscapes nacheinander. Tal-Musik, Ducking, Belohnungen und Türblende: ADR-046, Nachtrag 22.10.
  - **Erzählung und Text:**
    - Elysia: Das Erwachen beginnt mit einer Erzählzeile (`el_wake_0`). Neue Stellen zum Ansehen: Weltenbaum (unsichtbarer Punkt am Südufer, Radius 18; der Baum steht 4 Kacheln im See), Säule, Kristall (150 XP einmal, Flag `elysia.crystal_touched`), Gischt und Stein; im Tal der Antreiber am Holzstapel. Jeder Elysianer sagt, sobald der Riss offen ist, dieselbe Zeile über das Flimmern „ganz unten rechts, am Rand“ (`el_loop_2`, deterministisch). Die Begrüßer stehen als Zwillingspaar versetzt (Buchstaben `N` und `n`), damit die Symmetrie hält.
    - Wirklichkeit: Mira heißt „Die Frau“ (Stimme `warm` in `voices.json`), bis sie sich vorstellt („Mira, übrigens.“). Im Haus fragt sie nach dem Namen: Antworten sind der Name des Spielers, „Der Held von Elysia.“ (nur wenn er sich nicht schon so vorgestellt hat) und „…“. Erinnerungen `said_name`, `said_title` und `kept_name` haben Journalsätze. Hat der Spieler seinen Namen genannt, beginnt der Schluss mit „Mira: <Name>.“.
    - Ende: Der Cue ist geteilt. `ending` hört nach „Mira schaut zu den Bergen. Lange.“ auf, `ending_sea` trägt die Antwort („Zum Meer.“, je nach Erinnerung `guessed_sea` oder `end_silence`). Die Szene ruft beide und schwenkt dazwischen die Kamera (siehe ADR-030, Nachtrag).
    - Emphase nur in gesprochenen Zeilen: `[wait=0.9]` vor Miras erstem „Nein.“, `[wait=1.2]` vor „Zum Meer.“, `[wave amp=14 freq=5]` auf „Held!“, `[rainbow freq=0.6 sat=0.5]` auf „Legendär“ (ADR-020, Nachtrag).
    - Der Sprint-Hinweis im Erwachen heißt „Und wenn's eilig ist, hilft {{InputDevice.label_for("sprint")}}. Helden rennen.“ und nennt die Taste des benutzten Geräts.
  - **Bedienung:**
    - Pause-Menü mit acht Zeilen: Weiter, Journal, Speichern, Laden, Einstellungen, Steuerung anzeigen, Zum Startmenü, Spiel beenden. Das Pause-Menü öffnet auch in Gesprächen von Zwischensequenzen (`Cutscene.in_dialogue`) und schon während der Aufblende.
    - Steuerungsseite: alle Belegungen je Aktion, ohne Wiederholungen; „Zurück“ nennt Esc nicht (Esc öffnet das Menü, geht aber zurück); PlayStation-Tasten stehen als Wörter (Kreuz, Kreis, Quadrat, Dreieck), weil die Textschrift die Zeichen nicht hat; Schultertasten LB/RB, L1/R1, L/R. Pfeiltasten erscheinen als Wort. Die Fußzeile des Startbilds nennt Bewegen, Rennen und Bestätigen für das benutzte Gerät.
    - Startmenü: Mitwirkende (im Elysia-Titel „Die Helden hinter dem Helden“) mit den Lizenzen und `CREDITS_TEXT`; Elysia-Menü in Goldrahmen auf dunklem Grund; die Fußzeile trägt Hinweis (Textschrift) links und Version rechts. Esc im Startbild springt auf „Beenden“. „Fortsetzen“ lässt sich nicht doppelt auslösen.
    - Journal: Abschnitt „Dinge“ (Name, Zeile des Gegenstands, in Elysia die Seltenheit); bei langen Einträgen zweite Hinweiszeile (Bild auf/ab, rechter Stick).
    - Robustheit (Autoload `AppGuard`, `core/app_guard.gd`): Das Schließen des Fensters schreibt den Autosave, wo gespeichert werden darf, und die Einstellungen, dann Ende. Verliert das Fenster den Fokus, öffnet sich das Pause-Menü; wo das nicht geht, hält der Baum an, bis der Fokus zurückkehrt (Zeitfenster zählen Spielzeit und dürfen nicht hinter dem Rücken ablaufen). Headless und `--autopilot` ignorieren den Fokus. Wird das letzte Gamepad abgezogen, zeigen die Hinweise wieder Tasten und gehaltene Bewegung wird losgelassen; Anschließen ändert nichts bis zur ersten Eingabe.
  - **Spielgefühl:**
    - Sprint bleibt Sprint (`Player.is_sprinting()`), Gehen und Rennen teilen einen Gangzyklus, Antippen zum Umdrehen macht erst ab 9 px Weg einen Schritt (`FIRST_STEP_DISTANCE`, gemessen 8 px nach 50 ms).
    - Kamera, Prompt: siehe ADR-012 und ADR-043. Sperren (`blocker`): Die Zone ist die Sperre plus 12 px, der Hinweis steht 26 px über dem Weg.
    - Trittsteine: Kippzone 12×4 px um (0, −2,5), gleichweit aus allen Richtungen. Der Sturz in den Bach schüttelt die Ansicht (1,5 px, 0,35 s, mit Rumble am ersten Gamepad), spritzt 30 Partikel und blendet in ein kaltes Blaugrau (0,05, 0,08, 0,12) statt in Schwarz. Der Rumble hängt an der Einstellung „Bildschirmwackeln“ (schwach 0,3×, stark 0,6× der Stärke des Wackelns).
    - Im Regen hinterlässt die Figur auf Matsch nasse Fußspuren (höchstens 40, 3×2 px, Alpha 0,28, 4 s); Matsch heißt, die Legende der Karte malt das Symbol als `mud`.
  - **Elysia, Haus und Figuren:**
    - Erwachen: weißes Licht (0,4 s Halt, dann 2,6 s Aufblende), die Figur sitzt 1,2 s und steht auf, die Begrüßerin schaut weg und dreht sich nach 0,4 s zu ihr, Leben, XP und Gold bauen sich auf (ADR-024), die erste Zeile folgt nach rund 3 s. Geladene Stände überspringen alles.
    - Riss: ADR-025, Nachtrag. Haus: ADR-039, Nachtrag. Figuren: ADR-017 und ADR-042, Nachträge.
  - **Bild:** Regentag, Himmel, Dither und Trampelpfad: ADR-041, ADR-017 und ADR-038, Nachträge. Das Ende zeigt die Berge ganz im Bild, bevor Mira antwortet (Schwenk 4,0 s statt 5,0 s, danach 2,5 s Halt); wer von einem Stand lädt, der den Schwenk schon gesehen hat (`valley.mountains_seen`), bekommt ihn trotzdem.
- **Konsequenzen:**
  - Version 0.7.0.
  - Regeln für neue Arbeit:
    - Ein neuer oder geänderter Klang bekommt eine Gruppe mit Lautheit (`GROUPS`) und einen Aufrufgain nach der Tabelle `CLASSES` in `check_levels.py`; `tools/audio/check_levels.py` läuft vor jedem Push, der Klänge, Aufrufgains, Busse oder `content/audio/*.tres` berührt. Ändert sich `default_bus_layout.tres`, gehört die Bus-Annahme `BUS_TRIM_DB` im Skript dazu.
    - Antworten mit Bedingung verschwinden. Jede Antwortgruppe braucht eine unbedingte Antwort; Antworten mit `{{Wert}}` brauchen eine Bedingung auf den Wert; Texteffekte stehen nur in gesprochenen Zeilen.
    - Zoom ist 1,25× überall, ein Innenraum darf 1,5× über `view_zoom` in seiner `.tscn`.
    - Wer ein Gespräch in einer Zwischensequenz zeigt, nutzt `Cutscene.say()`; nur dann darf das Pause-Menü öffnen. Zeitgesteuerte Phasen bleiben gesperrt.
    - Overlays, die einer Weltposition folgen, liegen in einer `CanvasLayer` über der Welt (Prompt 11, HUD 12) und rechnen mit `GameView.world_to_ui(...).round()`.
    - Aufnahmen und Testläufe nutzen ein Profil je Lauf; das letzte `--profile` gewinnt. Headless-Läufe rücken das Audio nicht vor (der Dummy-Treiber mischt auf der Wanduhr): Musikpausen, Loops und Elysias Stufen zeigt nur `measure.sh`.
    - `layout_slice_maps.py tal --write` löscht Handänderungen in `content/maps/tal.txt` (Buchstabe `6` am Holzstapel, ein erweitertes `unless` bei `t`): vorher vergleichen.
  - Offene Punkte, die der Playtest klärt, stehen gesammelt in `OFFENE_PUNKTE.md`: Bach und Belohnungen im Mix, Wetter und Enden, Weich oder Pixelgenau, Mischpixel, Elysia-Menü über dem Becken, Miras Arbeitspose. Miras Besuch erzählt jetzt, was das Bild zeigt (sie sitzt schon am Feuer; `haus_mira_1`, `_7`, `_24`, `_29`, KNOWN_ISSUES #61 erledigt).
  - Offen beim Projektinhaber: Vollbild auf dem Mac prüfen, einen Namen in `CREDITS_TEXT` eintragen (heute „das Projekt REAL“), Tastenumbelegung als eigener Pull Request freigeben.
- **Nachtrag (ADR-062):** `RIFT_AFTER_LOOPS` ist 900 s (nicht mehr 150 s), `LOOPS_AFTER` 3.600 s; der Auslöser der Schleifen ist das Hoch auf dem Fest.

## ADR-048 · Tastenumbelegung: Modell, Schutzregeln und Oberfläche
- **Status:** angenommen · 2026-10-23 · umgesetzt in Version 0.8.0; der Projektinhaber, nach dem Bericht zur Polish-Runde 2 mit der Frage nach der Tastenumbelegung: „Ich stimme dir mit allem zu und möchte, dass du alles initiierst und entsprechend umsetzt, ich gebe alles frei“
- **Kontext:** Bible §50 verlangt Umbelegen für Tastatur und Controller von Anfang an (Linkshänder, AZERTY und QWERTZ, Barrierefreiheit); ADR-011 und ADR-018 hatten es vorbereitet (nur Daten, kein Menü), ADR-047 zog es vor den Playtest. Freies Umbelegen hat drei Risiken: **Aussperren** (kein Weg mehr ins Menü, nichts bestätigt mehr, eine Aktion ohne Taste), **Doppelbelegung** (eine Taste, zwei Aktionen, die Menüs und Spielwelt gleichzeitig auslösen) und **veraltete Hinweise** (die Taste „E“ steht noch im Hinweis, obwohl sie umgelegt ist). Dazu kommen Fallen der Eingabe selbst: ein Analogwert löst eine Action bei jedem Bewegungsereignis aus (ein Trigger auf `interact` würde ein Menü mehrfach bestätigen), `ui_accept` kennt keinen Pad-Knopf (A bestätigt nur über `interact`), und das Erfassen einer Taste muss Wiederholung, Loslassen, Modifikatoren und Fensterwechsel überstehen.
- **Entscheidung:**
  - **Umfang:** Neun Aktionen sind umbelegbar: `move_up/down/left/right` (nur Tastatur; am Controller gehen immer Stick und Steuerkreuz), `sprint`, `interact`, `cancel` („Zurück“), `menu` („Pause“) und `journal`. Alles andere (`ui_*`, `scroll_*`, `debug_*`) bleibt fest und steht nicht in der Datei.
  - **Feste Ereignisse** gehören zur Aktion und lassen sich weder entfernen noch abgeben; sie sind die Schutzregeln gegen Aussperren: Esc auf `cancel` und `menu`, Enter und Num-Enter auf `interact`, Controller-A auf `interact`, Start auf `menu`, Stick und Steuerkreuz für das Gehen. Esc (zurück, Pause), Enter und A (bestätigen) und Start (Pause) funktionieren also, was auch umgelegt wird.
  - **Zwei Felder je Gerät** (`InputBindings.SLOTS`) neben den festen Ereignissen; die Liste der Felder ist lückenlos (Feld 2 rückt auf Feld 1). Je Aktion und Gerät bleibt mindestens eine Belegung (feste zählen mit). Eine Taste gehört je Gerät einer Aktion; nur das feste Esc teilen sich `cancel` und `menu`. Die Standardwerte kommen aus `project.godot` (`ProjectSettings`), nie aus der lebenden `InputMap`; welche davon fest sind, steht in `InputBindings` (`FIXED_KEYS`, `FIXED_BUTTONS`, `PAD_FIXED_ACTIONS`; ein Test hält die Tabelle).
  - **Reserviert** (mit kurzer Meldung abgelehnt): Esc, Enter, Entf (leert ein Feld auf der Seite), Bild auf/ab und F3/F4 für niemanden; Pfeile und WASD nur für die vier Geh-Aktionen (sie bewegen den Fokus in jedem Menü); Leertaste für `interact` und `sprint`, Tab für `menu` und `sprint` (Rennen wird nur abgefragt, kein Ereignis-Verbraucher hängt daran; die Seite sagt dort „ist für »…« oder »…« reserviert“, nicht „fest“, weil der Spieler die Taste dorthin legen darf); am Controller A, Y (leert ein Feld), Start und Steuerkreuz für niemanden, Guide gar nicht. Nie belegbar sind außerdem Alt und Meta (Systemtasten: Alt+Tab, Cmd+Q), Feststell-, Num- und Rollen-Taste und die Sondertasten (Medien, Lautstärke, Browser, Start von Programmen); Strg und Umschalt bleiben belegbar. Sticks sind nie belegbar, Trigger nur für `sprint` (Analogereignisse wiederholen sich). Ein Test hält fest, dass jedes Menü-, Scroll-, Debug- und Seitenereignis geschützt ist, auch wenn `project.godot` später wächst.
  - **Konflikte** (dieselbe Taste gehört schon einer anderen Aktion desselben Geräts): *Tauschen* (die andere Aktion bekommt die Taste, die das Feld vorher trug, sofern sie ihr erlaubt ist), sonst *Hier verwenden* (die andere Aktion gibt sie ab, sofern ihr eine Belegung bleibt), sonst eine Erklärung ohne Rückfrage. Gefragt wird mit `ConfirmMenu`, die sichere Antwort ist vorausgewählt. Liegt die Taste schon im anderen Feld derselben Aktion: „hat sie schon“.
  - **Format** (ADR-018): `settings.json`, Version 2, derselbe flache Block `input` mit einer Liste je Aktion. **Ein Gerät gilt als überschrieben, wenn die Liste Ereignisse dieses Geräts enthält**; feste Ereignisse werden mitgeschrieben; Aktionen ohne Änderung werden nie geschrieben. Ist eine Aktion auf einem Gerät überschrieben, stehen die Ereignisse **beider** Geräte in der Liste (ein Build 0.7.0, der die ganze Aktion ersetzt, behielte so die Controller-Knöpfe). Dateien der Version 1 bleiben lesbar; eine Liste nur mit Tasten lässt die Controller-Standards stehen (sie löschte sie früher, weil sie die ganze Aktion ersetzte; kein Menü hat je Version 1 geschrieben, Handänderungen meinten „diese Taste ändern“). Der Lader ist nachsichtig: jedes unbrauchbare Stück wird verworfen und als Warnung gezählt (`binding dropped`), Doppelbelegungen aus Handarbeit werden repariert, nie ein Fehler. Eine Datei, die nicht lesbar ist, bleibt als `settings.json.bad` liegen, die einer neueren Version als `settings.json.newer`, bevor das nächste Speichern sie ersetzt.
  - **Kern ohne Szene** (`core/`, getestet): `BindingCodec` (strenge Kodierung, nie geklemmt, `key_is_valid` aus einer Liste echter Tasten), `InputBindings` (Regeln, Felder, Abgleich; `Settings.bindings`) und `BindingCapture` (Zustandsmaschine der Erfassung: Wiederholung und Loslassen zählen nicht; Esc und Start brechen sofort ab; 0,3 s Spielzeit lang zählt kein Druck, damit der Druck, der die Erfassung startete, nicht doppelt zählt; ein Stick oder Trigger, der beim Start noch ausgelenkt ist, zählt erst nach einem Moment der Ruhe; Strg und Umschalt binden beim Loslassen, wenn ihr Druck in dieser Erfassung lag; ein Trigger zählt einmal je Zug). `InputBindings.apply` gleicht diffbasiert mit der `InputMap` ab (nur geänderte Aktionen, nie leer dazwischen, Totzonen bleiben) statt alle 104 Actions neu zu schreiben, was gehaltene Eingaben losließ. `Settings.bindings_changed` und `InputDevice.labels_changed` melden Änderungen; `Settings.changed` bleibt den Werten vorbehalten (jede Szene wendet auf ihn alle Einstellungen an).
  - **Oberfläche:** `ControlsMenu` („Tastenbelegung“) ist eine interaktive `MenuLayer`-Seite statt einer `ScrollPage`. Der Abschnitt des zuletzt benutzten Geräts steht zuerst (neun Tastaturzeilen, fünf Controllerzeilen), je Zeile zwei Felder (`BindingRow`), feste Tasten als gedämpfter Text davor, das gewählte Feld hell hinterlegt. Ein Feld wählen Links/Rechts, **eine Spalte für die ganze Seite**; Enter, Leertaste, E oder A (und ein Klick) starten die Erfassung („Drücke die neue Taste“, der Rest der Liste tritt zurück), Entf, Y oder ein Rechtsklick leeren ein Feld (Entf und Y auch, während die Erfassung wartet: Tastatur und Controller gleich); abgelehnte Tasten zeigen eine Meldung in der Fußzeile und lassen die Erfassung bestehen. Die Fußzeile ist immer zwei Zeilen hoch, die Felder haben eine feste Breite (das breiteste Muster aus „Pfeil rechts“, „Leertaste“, „Umschalt“, „Backspace“ und den PlayStation-Wörtern; längere Namen werden gekürzt), die Seite bleibt unter 620 px Breite (ein Test misst es, auch bei großer Schrift). Nach einer Änderung werden nur die Felder neu beschriftet (Cursor und Scrollstand bleiben). Eine Zeile „Alles auf Standard“ fragt nach (und sagt, wenn nichts zu tun ist), „Weitere Tasten“ öffnet eine Textseite (`ControlsNotes`, eine `ScrollPage`) mit dem, was die Zeilen nicht zeigen (Enter, Esc, Start, Menüs, Gespräch überspringen, Journal blättern); ihre Fußzeile sagt, dass sich dort nichts ändern lässt und Hoch/Runter blättert. Das wartende Feld pulsiert nur in Füllung und Rahmen, die Punkte darin bleiben voll lesbar (mit „Blitze reduzieren“ steht es still). Die Seiten eines Menüs, das der Welt nicht folgt (Startmenü), tragen dessen Haut (`MenuLayer.stack`), und `SettingsMenu.close` schließt seine Seiten mit. Pause-Menü und Einstellungen (unter „Steuerung“) besitzen je eine Seite; eine verborgene tut nichts (`MenuLayer.rebuild` kehrt zurück, wenn das Menü nicht sichtbar ist, alle Signalhandler der Seite auch). Auf dem Mac fehlt die Entf-Taste: dort steht „Fn+Löschen“ im Hinweis, der Rechtsklick leert überall.
  - **Alles, was eine Taste nennt, folgt sofort:** Interaktions-Hinweis, Fußzeile des Startmenüs, Hinweis des Pause-Menüs und die Seite selbst (`labels_changed`). Antworten im Dialog bestätigt auch `ui_accept` (die Dialogbox kennt sonst nur `interact`; nach dem Umlegen von `interact` bestätigte die Leertaste sonst nicht mehr).
  - **„Einstellungen zurücksetzen“** (früher „Alles zurücksetzen“) lässt die Belegung stehen und sagt es in der Rückfrage; die Seite hat ihr eigenes „Alles auf Standard“.
  - **Wortschatz:** „Gehen“ und „Rennen“ (Startfußzeile, Einstellungen, Seite), „Pause“, „Zurück, Abbrechen“ (die Aktion; die Zeile zum Verlassen heißt „Zurück“), „Ansehen, Sprechen“. PlayStation-Knöpfe stehen auf der Seite und in ihrer Fußzeile als Wörter (Kreuz, Kreis, Quadrat, Dreieck), weil die Textschriften die Zeichen nicht haben.
  - **Autopilot:** `key` und `pad` tippen echte Tasten und Knöpfe und lassen sie als solche los; `controls_rebind.json` und `controls_pad.json` spielen die Seite für Aufnahmen.
- **Verworfen:**
  - Ein einziges Feld je Gerät: Mehrfach-Standardwerte (E und Leertaste, W und Pfeil, X und Trigger) gingen verloren.
  - Eine geschachtelte Datei (Version 2 mit Blöcken je Gerät): ohne Not, die flache Liste bleibt mit Version 1 lesbar.
  - Trigger und Sticks für alle Aktionen: Analogereignisse wiederholen sich (gemessen: jedes Bewegungsereignis über der Totzone löst `is_action_pressed` aus), Sticks driften.
  - Ein zweiter Rettungsweg „Standard für eine Zeile“: jede Taste, die die Seite selbst liest, muss reserviert sein, und der Controller hat keinen freien Knopf; „Alles auf Standard“ genügt.
  - Ein „Taste ausprobieren“-Feld: Hinweise, Fußzeile und Pause-Menü folgen sofort, das ist die Probe.
  - Pfeile als Zeichen in den Fußzeilen: Jersey 10 und 15 haben sie nicht (nur Tiny5), die Seite nutzt Wörter.
- **Konsequenzen:**
  - Eine sichtbare Dialogzeile mit `{{InputDevice.label_for(...)}}` behält den alten Namen bis zur nächsten Zeile (betrifft nur `el_wake_8`, KNOWN_ISSUES #77); ein erneutes Auflösen der Zeile könnte ihre Nebenwirkungen wiederholen.
  - Die Beschriftung auf echten Layouts (QWERTZ, AZERTY, macOS) ist im Container nicht prüfbar (KNOWN_ISSUES #75), die Erfassung am echten Controller auch nicht (#76).
  - Wer Umschalt oder Strg auf `cancel` oder `menu` legt, schließt Menüs mit Umschalt+Tab: die Entscheidung des Spielers (Esc, Start und die Pfeile bleiben).
  - `ScrollPage` bleibt für Textseiten (Mitwirkende, Weitere Tasten); `CONTROLS_MOVE_KEYS`, `CONTROLS_HINT` und `KEY_TRIGGER` sind entfallen (`InputDevice.move_label`, `trigger_label`).
  - Version 0.8.0.
- **Nachtrag zu ADR-011:** Gebaut mit ADR-048 (Seite „Tastenbelegung“); die Beschreibung „Die Rebinding-Oberfläche folgt nach dem Slice“ gilt nicht mehr.
- **Nachtrag zu ADR-018:** `settings.json` hat die Version 2 (Block `input` wie oben); `settings.json.bad` und `.newer` bewahren Dateien, die der Lader nicht übernimmt.
- **Nachtrag zu ADR-047:** „Steuerung anzeigen“ ist jetzt die Seite „Tastenbelegung“ (im Pause-Menü und unter Einstellungen → Steuerung). Die Tastenumbelegung ist mit ADR-048 gebaut; der Punkt unter „Offen“, sie als eigenen Pull Request freizugeben, entfällt.

## ADR-049 · Playtest-Gate ohne Tester: Freigabe der Vorproduktion für Full Production
- **Status:** angenommen · 2026-10-23 · der Projektinhaber, nach dem Test von v0.8.3 und der Klärung der offenen Punkte: „Überspringe das gerne mit den Testern, also den Playtest, passt schon. Du kannst also weitermachen, du hast meine Freigabe nach dem du die anderen Punkte geklärt hast.“
- **Kontext:** Bible §57 und §58 und Master-Prompt §47 verlangen Playtests, die zeigen, dass Spieler weiterspielen wollen („Desire“), bevor Full Production beginnt. Der Slice wurde über mehrere Builds (v0.5.0 bis v0.8.3) vom Projektinhaber gespielt und in Rückmelderunden verbessert (Zoom, Ränder, Kamera, Ton, Tasten, Leistung). Die Prüfungen am echten Gerät sind erledigt oder entschieden: Mac (Maus, Bild, VSync, Tastenbelegung) läuft gut; der schwarze Rand im Vollbild ist bestätigt und mit der Einstellung „Bild füllen“ gelöst (ADR-045, Nachtrag); der Name steht bei den Mitwirkenden; Windows kann der Projektinhaber nicht prüfen (KNOWN_ISSUES #6, akzeptiert); das Veröffentlichen des Release-Entwurfs ist nicht nötig.
- **Entscheidung:** Das Playtest-Gate gilt als vom Projektinhaber abgenommen, ohne Rückmeldungen von Testern (Abweichung von Bible §57, vom Projektinhaber so entschieden). Freigegeben ist die **Vorproduktion für Full Production** (GATE_REPORT, „Nächste mögliche Schritte“, erste Zeile): Content-Plan für Akt I nach Bible §48, Writing-Pass, Karten-Pipeline, Art- und Audio-Weg ohne Kosten, Plan in `docs/PRODUKTIONSPLAN.md` (entsteht im nächsten Schritt). Es bleiben die Regeln des Projekts: kleine Schritte, ein Pull Request je Phase, `tools/check.sh` vor jedem Push, die 0-€-Regel (nichts Kostenpflichtiges ohne ausdrückliche Zustimmung), Fragen bei großen Weichenstellungen (Master-Prompt), Bible-Abweichungen nur mit ADR.
- **Verworfen:** Auf Tester warten (der Projektinhaber verzichtet). Full Production ohne Plan: Die Kartenpipeline skaliert nicht auf sieben Regionen (OFFENE_PUNKTE, Abschnitt 3), und die Art- und Audio-Entscheidung hängt an der 0-€-Regel.
- **Konsequenzen:** Die Fragen in `PLAYTEST*.md` bleiben für spätere Tester gültig. Die Gates M und Ä des Gate-Berichts werden nicht mehr gemessen; der Desire-Test ist der des Projektinhabers. Ohne fremde Spieler fehlen Daten zur Verständlichkeit des Antreibers, zur Spielzeit (vermutlich unter 45 Minuten) und zu den Texten; sie stehen als Fragen für einen späteren Test in `OFFENE_PUNKTE.md`.

## ADR-050 · Arbeitsannahmen für Full Production
- **Status:** angenommen als Arbeitsannahmen · 2026-10-23 · gelten, bis der Projektinhaber einer widerspricht (`docs/PRODUKTIONSPLAN.md`, Abschnitt 3 und 11: ohne Antwort oder mit „Weiter“ gilt die Empfehlung, umkehrbar)
- **Kontext:** ADR-049 gibt die Vorproduktion frei. Der Produktionsplan entstand aus vier Analysen und zwei Gegenprüfungen; einige Fragen beantwortet die Bible nicht eindeutig. Statt jede einzeln zu stellen, stehen die Lesarten hier gesammelt. Keine davon weicht von der Bible ab; echte Weichen stehen im Plan als Entscheidungen.
- **Entscheidung:**
  - Twist I (§38, „Elysia ist nicht die gesamte Welt“, ca. 20–25 %) ist der Riss, bei 11 h Hauptpfad rechnerisch bei 16 %; kein zusätzlicher Story-Beat.
  - Die Signature-Begegnung des Antreibers bleibt die aus dem Slice; Akt III zeigt sein Warum, die neue Begegnung dort gehört dem Einsiedler.
  - Mira reist nicht dauerhaft mit (Bible §13, §37; ADR-042); die Wege kreuzen sich in Akt II, IV, VI und VII.
  - Der Richter beginnt in Akt II, sein Bogen läuft über drei Akte.
  - Elysias Mini-Quests zählen nicht zu den 15–20 Nebenquests (§43); sie sind die RPG-Täuschung.
  - Elysias Humor bleibt auf dem Niveau des Slice (§59 Risiko 9).
  - Erscheinungsbild (§6): wenige symmetrische Startvarianten beim neuen Spiel, Zusätze später als Überlagerungen; die Zusätze sind Cut-First.
  - Das Haus bleibt im Tal und ist Rückkehrort jedes Akts; keine Schnellreise.
  - Spielstände aus Slice-Builds müssen nicht überleben; dafür ein eingefrorenes v2-Fixture und eine Alias-Tabelle für Szenen.
  - Textkarten bleiben; Prototyp-Szenen bleiben, bis eine echte Szene sie ersetzt (der Leistungstest bleibt vergleichbar).
  - Englisch gehört nicht zu diesem Plan.
  - Kuriositäten-Ziel 36; Porträts erst nach einem Pilot.
  - ADR-007 und ADR-015 gelten als angenommen; ADR-017 schließt Entscheidung 1 des Plans.
  - Ohne Tester ist der Desire-Test aus §57 das Urteil des Projektinhabers; die offenen Playtest-Fragen gelten mit den heutigen Werten, bis er beim Akt-I-Durchlauf etwas anders sieht.
- **Konsequenzen:** Jede Annahme lässt sich mit einem Satz des Projektinhabers kippen; betroffene Teile des Plans werden dann neu geschnitten. Externe Playtests bleiben vor einer Veröffentlichung Pflicht (Bible §61, `OFFENE_PUNKTE.md`).

## ADR-051 · Unit-Tests mit fester Bildrate
- **Status:** angenommen · 2026-10-23 (P6.1 des Produktionsplans)
- **Kontext:** Die GUT-Suite (691 Tests) brauchte 592 s in Echtzeit, `check.sh` rund 12 Minuten. Fast alles davon war Warten: Die Story-Tests spielen Szenen, Zwischensequenzen und Fades in Spielzeit ab (`test_slice_haus` 148 s, `test_slice_tiefe` 112 s, `test_slice_tal` 55 s). Der Plan rechnete bei wachsendem Inhalt mit einer Stunde je Prüfung (`docs/PRODUKTIONSPLAN.md`, Risiken).
- **Entscheidung:** `tools/check.sh` startet GUT mit `--fixed-fps 60`: Jedes Bild zählt 1/60 s Spielzeit, der Rechner rechnet so schnell er kann. Danach 70 s statt 592 s (`check.sh` insgesamt 189 s); 3 Wiederholungen mit je 691 von 691 grün. `GUT_FIXED_FPS=0` fährt in Echtzeit. Der Smoke-Lauf des ganzen Slice nutzte schon `--fixed-fps 30`. Ein Test maß mit der Wanduhr (`Time.get_ticks_msec`) und schlug als einziger fehl; er zählt jetzt Spielzeit. Regel in `CLAUDE.md`: Tests messen nie mit der Wanduhr. Am Ende der GUT-Stufe zeigt `tools/gut_times.py` die fünf langsamsten Testdateien, damit Wachstum sichtbar bleibt.
- **Nicht gebaut (Cut-First):** keine Aufteilung auf mehrere Prozesse und keine Stufe `check.sh --quick`; bei 3 Minuten lohnt beides nicht. Wieder prüfen, wenn der Lauf über 6 Minuten liegt.
- **Grenzen:** Der Dummy-Audiotreiber läuft weiter auf der Wanduhr (KNOWN_ISSUES #67): Audio-Zeiten prüft nur `tools/audio/measure.sh`. Fehler, die nur bei echter Bildrate auftreten (ungleiche Bildzeiten, Rennen zwischen Physik und Bild), fängt der schnelle Lauf nicht; dafür der Echtzeitlauf vor jedem Phasenende.
- **Konsequenzen:** Schnellere Rückmeldung (3 statt 12 Minuten) bei gleicher Testzahl. Tests sind unter fester Bildrate deterministischer (ein Physikschritt je Bild).

## ADR-052 · Speicher-Politik, Kapitelmarken, Kartenstempel und Querprüfung (P6.2)
- **Status:** angenommen · 2026-10-23 (T2 und T3 des Produktionsplans)
- **Kontext:** ADR-050 nimmt an, dass Spielstände aus Slice-Builds nicht überleben müssen. Ab dem ersten veröffentlichten Stand von Full Production gilt das nicht mehr, und ein Schema-Bruch oder eine umbenannte Szene wird dann teuer. Der Slice hatte außerdem eine einzige Endmarke (`slice.finished`), und Karten mussten von Hand neu gebacken werden, ohne dass etwas auffiel, wenn man es vergaß. Querbezüge zwischen Karten, Skripten, Dialogen und Quests prüfte nur ein einzelner Test (Cues und gelesene Flags).
- **Entscheidung:**
  - **Speicher-Politik:** Ein Spielstand eines veröffentlichten Full-Production-Builds lädt in jedem späteren Build. Jede Schema-Version behält ein eingefrorenes Beispiel `tests/fixtures/saves/v<N>_*.json`, das nie von Hand geändert wird; `test_save_policy` verlangt es und lässt alle laden. `v2_slice_end.json` ist der echte End-Spielstand des Slice (v0.8.4, vom Autopilot geschrieben). Neue Felder sind optional mit Vorgabe; ein Bruch bekommt einen Migrationsschritt (`SaveCodec.migrations()`) und ein neues Beispiel im selben Pull Request. Das nächste Schema (3) kommt einmal, mit dem Zustandsmodell der Akte (T9).
  - **Alias-Tabelle:** Ein Szenen-Schlüssel, der in Spielständen stehen kann, wird nie entfernt. Wird eine Szene umbenannt, zieht der alte Schlüssel nach `SceneRegistry.aliases` (alt → neu); Türen, `--start=`, Titel und Spielstände nehmen ihn weiter an, `SaveCodec` schreibt auf den neuen um.
  - **Kapitelmarken:** `Chapter.mark("<id>")` setzt `chapter.<id>` (der Slice ist das Kapitel `slice`, die Akte folgen). Startmenü und Spielstand-Liste lesen `Chapter`; das alte Flag `slice.finished` wird weiter gelesen, aber nicht mehr gesetzt.
  - **Kartenstempel:** `tools/art/map_stamps.json` hält je gebackener Karte eine Prüfsumme aus allem, was der Baker liest (Malart jeder Zelle, Schatten platzierter Deko, `[meta]` ohne `scatter`, Seed, Quelltext von Baker, Paletten und `mapfile.py`). `tools/art/bake_ground.py` schreibt sie nach dem Backen; Schritt „map stamps“ in `check.sh` meldet vergessene Bakes. Reine Requisiten-Parameter ändern den Stempel nicht. Alle acht gebackenen Karten ließen sich vorher bitgenau neu erzeugen (47 s).
  - **Querprüfung:** `StoryLint` (`core/content/story_lint.gd`) prüft über Dateien hinweg: Türziele und Spawn-Marker, Cues aus Karten und Skripten (`Talk.present`, `cut.say`), Quest-Stufen ohne Auslöser, gelesene Flags ohne Setzer und gesetzte ohne Leser (Ausnahmen mit Begründung in `WRITE_ONLY_FLAGS`), doppelte Spawn-Marker, Beats und Kapitel, Blitz- und Wackeleffekte ohne Einstellungsabfrage. Je Regel ein roter Fixture in `test_story_lint`.
- **Funde beim ersten Lauf:** Lampenflackern (`Decor`) und das weiße Aufblitzen der XP-Leiste ignorierten »Blitzeffekte reduzieren« (behoben); drei Flags nur für Tests und Autopilot (`house.mira_knocked`, `elysia.rift_crossed`, `encounter.antreiber_resolved`) stehen mit Begründung auf der Ausnahmeliste.
- **Konsequenzen:** Jeder Akt, der ein Flag setzt, muss es auch lesen oder begründen: so gilt »keine Fake Choices« über Akte hinweg (Plan 5.7). Die Regeln lesen Quelltext und laufen nur im Projekt, nicht im Export. Muster, die sie nicht verstehen (Flags aus Variablen, Quest-IDs aus Variablen), zwingen zu Konstanten oder Literalen: das ist gewollt.

## ADR-053 · Schreibwerkzeuge: Status-Tags, ID-Sperre, Vokabel- und Zahlen-Lint (P6.3)
- **Status:** angenommen · 2026-10-23 (Abschnitt 9.5 des Produktionsplans)
- **Kontext:** Der Validator prüft Struktur, nicht Stimme oder Ton (Plan 9.1). Bei rund 4.100 Zeilen-IDs in Full Production und einem einzigen Leser (ADR-049) muss jede mechanische Prüfung, die ein Mensch sonst von Hand täte, ein Werkzeug sein. Die Bible verbietet Therapiesprache, Diagnosen und Suchtbegriffe (§3.2) und Zahlen für Beziehungen und Facetten (§16).
- **Entscheidung:** Werkzeuge in `tools/writing/` (nur Standardbibliothek, laufen in `check.sh` ohne Godot):
  - **Status-Tags** `[#draft]` und `[#ok]` auf Zeilen (neben `[#ph]`). `[#ok]` heißt: eingefroren (Ablauf 9.4, Schritt 6). Höchstens ein Status je Zeile.
  - **ID-Sperre** `content/dialogue/ids.lock` (`tools/writing/id_lock.py`): hält jede Zeilen-ID der Story-Dialoge (heute 444) und für eingefrorene Zeilen einen Hash von Art, Sprecher und Text. Fehler: eine gesperrte ID verschwindet (umbenannt oder gelöscht; Ausweg `--retire <id> <Grund>`), eine eingefrorene Zeile ändert sich oder verliert ihr `[#ok]` (Ausweg nach Durchsicht `--refreeze <id>`), eine zurückgezogene ID kehrt wieder. Hinweise (`note:`): ID noch nicht gesperrt, `[#ok]`-Zeile noch nicht eingefroren, ID in andere Datei gewandert. `--update` sperrt neue IDs, rührt aber nie einen vorhandenen Hash an.
  - **Vokabel-Lint** (`tools/writing/vocabulary.json`): Begriffe aus Trauma, Therapie, Diagnose, Störungen, Psychologie, Depression, Sucht, Selbsthilfe-Jargon und Englisch; Gewöhnliches (»sucht«, »Störung«, »nüchtern«) trifft nicht. Treffer sind Hinweise im Entwurf und Fehler in `[#ok]`-Zeilen; berechtigte Treffer stehen mit Grund unter `exceptions`.
  - **Zahlen-Lint:** Ziffern in Story-Text (Dialoge, Journal, Gegenstände) sind Hinweise bzw. Fehler; Zahlen werden ausgeschrieben, Schilder und Größen stehen als Ausnahme mit Grund (heute drei).
  - **Bericht** (`tools/writing/report.py`, nicht in `check.sh`): Zeilen und Wörter je Sprecher, Entwurf/Frei/Platzhalter je Datei, Cues, die nichts mehr startet. »Gesetzt, aber nie gelesen« (Flags) prüft `StoryLint` (ADR-052).
- **Messwerte des Slice** (für das Stilbuch, P6.4): 444 Zeilen, 3.826 Wörter, im Mittel 8,6 Wörter je Zeile; Erzählung 39 % der Zeilen, Mira 19 %, Antworten 15 %, Antreiber 10 %. Kein Treffer im Vokabel-Lint; Ziffern nur auf dem Wegweiser (»200 m«) und in der Schuhgröße.
- **Konsequenzen:** Die Hinweise gelten als Arbeitsliste, nicht als Sperre, bis eine Zeile eingefroren ist; dann sind sie Fehler. Frei gegebene Zeilen lassen sich nur mit Absicht ändern (`--refreeze`). Der Writing-Pass (P6.5) setzt die Slice-Zeilen auf `[#ok]` und friert sie ein. Die Wortliste ist ein Netz mit Löchern, kein Urteil über Ton: Stimme und Takt prüfen weiter die Prüflinsen (Plan 9.4) und der Leser.

## ADR-054 · Stilbuch, Stimmenblätter und Motivbuch (P6.4)
- **Status:** angenommen als Entwurf · 2026-10-23 · wird verbindlich, wenn der Projektinhaber die Blätter gelesen hat
- **Kontext:** Stimmenblätter, Glossar, Motivbuch und eine lesbare Fassung des Texts gab es nicht (Plan 9.1). Neue Segmente brauchen etwas, wogegen sie geschrieben und gemessen werden, und der einzige Leser (ADR-049) braucht es kurz.
- **Entscheidung:** Unter `docs/writing/`:
  - **`STIL.md`**: ein Stilbuch, gemessen am Slice (444 Zeilen, `report.py`) und an der Bible: kurze Zeilen, Erzählung in der zweiten Person Präsens ohne Doppelpunkt und ohne Ausrufe, Gefühl durch Geste, Humor je Welt (Elysia: Wiederholung und Lob; Wirklichkeit: Untertreibung und Dinge), eine „Nie“-Liste (keine ständigen Weisheiten, kein Trost durch Worte, keine Beschämung, keine Therapiesprache, Mira nie Mentorin).
  - **`stimmen/`**: 15 Blätter mit Funktion, Signatur, Verlauf, Goldzeilen und Gegenbeispielen. Sieben haben Beleg im Slice (Mira, Antreiber, Elysianer, Gärtnerin, Gastwirt, Kind, Spielfigur), acht stammen aus der Bible (Tess, Orin, Lio, Richter, Gefälliger, Einsiedler, Wächter, Betäuber) und tragen statt Goldzeilen „Probezeilen“ als Entwurf; Betäuber verweist auf den Gastwirt als Gesicht.
  - **`MOTIVE.md`** (erzeugt aus `motive.json`): Vorausdeutungen (§46), Gags (§33), Kind-Bilder (§15) mit Auftritten im Slice und Auflösung, dazu das **Konsequenzen-Register** (Plan 5.7) mit allen 57 Story-Flags, ihrer Achse und den Dateien, die sie setzen und lesen.
  - **Prüfer** `tools/writing/motifs.py` (in `check.sh`): Zitate mit Zeilen-ID in den Seiten (`` `id` „Text“ ``) müssen dem Text im Spiel entsprechen (85 geprüft); eine verschwundene ID oder ein verschwundenes Flag im Buch ist ein Fehler; ein Story-Flag, das nicht im Register steht, ist ein Hinweis; `MOTIVE.md` muss der Erzeugung entsprechen.
- **Annahmen, die du kippen kannst:** Alles bei den Figuren ohne Beleg (Signatur, Probezeilen) ist eine Lesart der Bible und kein Text; die Messwerte des Stilbuchs beschreiben den Slice, nicht eine Pflicht, ihn in allem zu wiederholen. Orin, Lio und der Richter sind in Akt IV bzw. II, IV, VI angesetzt, wie der Plan es zeigt.
- **Konsequenzen:** Ein Segment schreibt gegen sein Blatt; ändert sich eine Goldzeile, ändert sich das Blatt im selben Pull Request, sonst schlägt `check.sh` fehl. Neue Flags tragen sich ins Register ein. Der Writing-Pass (P6.5) misst den Slice am Stilbuch.

## ADR-055 · Karten-Linter, Elysia-Regler, Registerlisten und Kalibrierung (P6.6)
- **Status:** angenommen · 2026-10-23 (T4, T5, T11 des Produktionsplans)
- **Kontext:** Die Akte brauchen vier Dinge, die der Slice nur nebenbei hatte: eine Prüfung, dass Karten begehbar und spiegelsymmetrisch bleiben (Elysia, ADR-031), eine Uhr für Elysias Reizbogen, die in mehr als einer Szene läuft (bisher nur im Garten), Szenenlisten, die man nicht an vier Stellen von Hand pflegt, und eine Rechnung für die Spieldauer statt einer Schätzung. Der Slice sollte sich dabei nicht ändern.
- **Entscheidung:**
  - **Karten-Linter** `MapLint` (`core/content/map_lint.gd`, Test `test_map_lint` prüft alle ausgelieferten Karten): jede Szenenkarte hat `player_spawn`; Marker und Dinge, die man anspricht (Türen, Riss, Fundstücke, Truhen, Hebel, Schilder, Falter, Figuren), stehen auf begehbaren Zellen; alles Anzusprechende und jede Türankunft ist vom Spawn aus erreichbar (Fläche aus Feldern, die nicht fest sind, plus Trittsteine; Reichweite zwei Zellen, damit Möbel in der Wand von vorn benutzt werden); eine Karte mit `[meta] symmetry` ist wirklich um ihre Mittelspalte gespiegelt (Boden und Requisiten; Stein, Riss und Kind sind ohne Zwilling erlaubt). Karten, die nur ein Skript füttert (die Wegstücke des Antreibers), brauchen keinen eigenen Spawn. Bäume, Hauswände und bedingte Sperren kennt der Linter nicht: er findet Inseln aus Feldern, nicht jede Sperre. `tools/art/map_overview.py content/maps/<karte>.txt` zeichnet das Übersichtsbild (Boden mit allen Platzierungen, `build/map_overview`).
  - **Elysia-Regler** `ElysiaDirector` (`world/elysia_director.gd`): eine Uhr und ein Satz Stufen für jede Elysia-Szene; sie hängt sich mit `ElysiaDirector.attach(self)` an. Die Stufen sind Flags, die andere Szenen lesen können: `elysia.loops_1` und `elysia.loops_2` (die Musikschleife schrumpft; Truhe bzw. Stein genommen, spätestens nach 5 und 10 Minuten Spielzeit), `elysia.loops` (die Sätze wiederholen sich wörtlich; Quests erledigt oder spätestens nach 12 Minuten) und `elysia.rift_open` (der Riss öffnet sich von selbst 150 s später). `ElysiaDirector.stage()` liefert 0 bis 3. Die Garten-Szene behält nur, was ihre Karte betrifft. Der Slice spielt sich unverändert (`test_slice_elysia`, `test_elysia_polish` und der Autopilot-Durchlauf bleiben grün).
  - **Sammelstücke** `Collection` (`core/slice/collection.gd`): Erinnerungsfragmente und Melodien sind Flags `fragment.<id>` und `melody.<id>`, Kuriositäten sind Gegenstände `curiosity_<name>` (im Rucksack oder im Regal); Zählung nach Präfix, bisher 24 Fragmente und 12 Melodien als Obergrenze der Bible (§31). Kein Zähler erscheint im Spiel (Bible §23). `StoryLint.WRITE_ONLY_FLAG_PREFIXES` nimmt `beat.`, `fragment.` und `melody.` von der Regel „gesetzt, aber nie gelesen“ aus: der Leser kommt mit dem Ende und dem Journal.
  - **Facette Wahrnehmung:** Die Kennung ist `perception` (`GameState.FACETS`, `WorldState.set_facet`); Akt I (Spiegelhalle, A5) setzt sie, der Validator prüft jede Facetten-ID gegen die Liste. Sichtbar wird sie als neue Möglichkeit (verborgene Details), nie als Zahl.
  - **Registerlisten:** `SceneRegistry.SMOKE` und `SceneRegistry.BENCHMARK` sind die einzigen Listen für den Smoke-Lauf (`check.sh`, `smoke_export.sh` über `tools/scene_keys.py smoke`) und den Leistungstest (`BenchmarkRunner`); `test_scene_registry` hält sie mit `SCENES` zusammen. Eine neue Akt-I-Karte trägt sich dort ein, nicht in Skripten.
  - **Kalibrierung** `tools/writing/calibrate.py` mit `calibration_baseline.json` (Beat-Zeiten des Autopiloten): Spielzeit aus Zeichen mal Textgeschwindigkeit plus Weg mal Umweg; Beschreibung und Zahlen in `docs/KALIBRIERUNG.md`.
- **Funde beim ersten Lauf:** Keine ausgelieferte Karte musste sich ändern: was zunächst als Fund erschien, waren Annahmen, die der Linter jetzt kennt (Trittsteine über den Bach, Möbel in der Wand, Stein, Riss und Kind in Elysia, Wegstücke ohne eigenen Spawn). Das Modell ergibt für den Slice 20,6 Minuten bei normalem Tempo und 21,5 Zeilen je Minute; der Plan rechnet für Akt I mit 6 (Abschnitt 4.2 und 9.6) und muss in P6.12 entscheiden, ob Akt I seine rund 100 Minuten aus mehr Text oder aus mehr Spiel zieht.
- **Konsequenzen:** Jede neue Szene braucht `player_spawn` oder ist ausdrücklich Skriptkarte; Elysia-Szenen hängen den Regler an und schreiben keine eigene Uhr; Sammelstücke gehen über `Collection`. Wo der Linter eine Sperre nicht kennt (Bäume, Wände), prüft sie weiter der Autopilot-Durchlauf. Das Modell der Spielzeit ist eine Rechnung mit drei Annahmen, bis ein echter Durchlauf sie festlegt.
- **Nachtrag (ADR-062):** Der Auslöser der Sätze ist das Hoch auf dem Fest (`elysia.feast_toast`), die Musikstufen folgen `elysia.market_seen` und `elysia.stone_taken`, die Uhr fängt erst nach 20 und 40 Minuten (Musik) und nach einer Stunde (Sätze), der Riss nach 15 Minuten danach; die Wartezeit läuft ab dem Hoch über die Szenen hinweg, der Riss wird in jeder Elysia-Szene angesagt.

## ADR-056 · Writing-Pass auf den Slice, Lesefassung und Tests auf Zeilen-IDs (P6.5)
- **Status:** angenommen · 2026-10-24 (Abschnitt 9.2 des Produktionsplans; der Projektinhaber hat den Plan am 24.10. mit „bau alles“ freigegeben, die Lektüre der Blätter bleibt als Durchsicht offen)
- **Kontext:** Der Slice-Text war ein ungeprüfter Entwurf (ADR-036). Der Writing-Pass misst ihn am Stilbuch (ADR-054) und räumt auf, was der Plan nennt. Tests, die den Wortlaut festnagelten, verhinderten jede Textänderung.
- **Entscheidung:**
  - **Gestrichen:** `haus_rest_5` (tote Zeile, KNOWN_ISSUES #74); die ID ist in `ids.lock` zurückgezogen.
  - **Geändert**, weil sie als Weisheit statt als Ding klangen („keine ständigen Weisheiten“, STIL.md): `tal_stones_2` („Auf den runden hält sich nichts. Nicht mal Moos.“) und `tal_west_3` („Der Weg wird dich nicht vermissen.“). Der Rest des Slice entspricht dem Stilbuch; Zeilen, die als Goldzeile auf einem Stimmenblatt stehen (z. B. `tal_mira_19`), bleiben, auch wo ein Ausdruck zweimal vorkommt („läuft nicht weg“: bei Mira trocken, beim Antreiber mit „Trotzdem.“ sein Tick).
  - **Belassen, mit Begründung:** `el_wake_8` (der Tastenhinweis in Elysias Ton: „Helden rennen.“ ist der Köder, der Antreiber später verwertet) und `el_loop_2` (Elysia nennt den Riss „nichts Wichtiges“; der Hinweis ist die Täuschung). Der Name erscheint zweimal (`haus_mira_36` probiert ihn aus, `tal_end_12` sagt ihn zum Abschied): das ist gewollt, die zweite Stelle ist die Auflösung. Miras Ansprache des Antreibers (KNOWN_ISSUES #49): sie bleibt aus; die Erzählzeile `haus_mira_29` lässt offen, ob sie ihn sieht, und das ist die Lesart von ADR-042.
  - **Nicht angefasst:** das erste „Nein.“ und „Zum Meer.“ (Bible §56).
  - **Lesefassung** (`tools/writing/readable.py`): der Text als Skript in Spielreihenfolge, je Szene eine Nummer (E1, T12 …), Bedingungen sichtbar, Code nicht. `docs/lesefassung/SLICE.md` ist der Stand dieses Pull Requests; jedes Segment bekommt seine eigene Datei, nur das Delta. Zum Antworten genügt „OK“, „ändern: …“ oder „raus“ je Nummer.
  - **Tests auf IDs:** `LineText.of("<id>")` (`tests/unit/line_text.gd`) liefert den Wortlaut aus den Dialogdateien; über 40 festgenagelte Stellen in acht Testdateien nennen jetzt die ID. Absichtlich im Wortlaut bleiben „Zum Meer.“ und „… Ja. Zum Meer.“ (Bible §56) und Zeilen, deren Text unter mehreren IDs vorkommt.
- **Einfrieren steht aus:** Die Slice-Zeilen bleiben `[#draft]`/ungetaggt, bis der Projektinhaber die Lesefassung gesehen hat; `[#ok]` heißt „gelesen“ (ADR-053). Ein Satz in der Antwort genügt, dann friert `id_lock.py --update` sie ein.
- **Konsequenzen:** Ein Texteingriff ändert nur die `.dialogue`-Datei; Tests und Motivbuch folgen den IDs. Wer eine Zeile umschreibt, die auf einem Blatt zitiert wird, ändert das Blatt im selben Pull Request (der Prüfer meldet es sonst).

## ADR-057 · Entscheidungen 1 und 2 des Produktionsplans, Musik als Ogg Vorbis, kleine Bilder als Text (P6.7)
- **Status:** angenommen · 2026-10-24 (der Projektinhaber schrieb am 24.10.: „Du hast mein go für alles, bau alles“; nach Abschnitt 11 des Plans gilt damit die Empfehlung, und sie bleibt umkehrbar)
- **Kontext:** Plan 11 stellt zwei Weichen: Budget und endgültiger Look und Klang (Entscheidung 1), Länge von Akt I (Entscheidung 2). ADR-017 (Look-Pipeline) blieb dafür vorläufig. Die Musik als WAV macht 17,9 MB des Repos aus.
- **Entscheidung:**
  - **Entscheidung 1: 0 € bleibt, der Look heißt „erzeugt und kuratiert“.** Grafik und Klang entstehen weiter aus den Generatoren in `tools/art` und `tools/audio` (Paletten, Licht, Wind, Symmetrie, gemessene Lautheit), darüber eine dünne, von Hand geschriebene Datenschicht (Karten, Kataloge, `.pix`-Bilder). Das schließt ADR-017: **bewusste Abweichung** von Bible §36 („handgezeichnete Pixel-Art“) und §61 („keine Placeholder-Assets“), umkehrbar und vor einer Veröffentlichung neu zu stellen. `PLACEHOLDERS.md` führt ein Asset weiter als Platzhalter, bis der Projektinhaber die Region abgenommen hat; erst dann gilt es als endgültig. Instrumentenklänge aus Sample-Bibliotheken: nur CC0 und erst nach seiner Hörprobe (ich höre nicht); bis dahin bleibt die Musik synthetisch. Titel- und Schlüsselbild, 5–8 Schlüsselstücke der Musik und Porträts sind ohne Geld am schwächsten; die Budgetfrage kommt vor einer Veröffentlichung mit Gegenüberstellung nach Master-Prompt §51.
  - **Entscheidung 2: Akt I wird in der geplanten Länge (rund 100 Minuten) gebaut** und nach dem Durchlauf in P6.12 entschieden: wirkt es zu lang, wird per ADR gekürzt, fehlt Elysia, kommt das Minispiel A4 dazu. Die Kalibrierung (ADR-055) zeigt, dass der Slice bei 21,5 Zeilen je Minute läuft, der Plan aber mit 6 rechnet; Akt I zieht seine Minuten also aus Spiel (Erkunden, Spiegelhalle, Händler, Fest), nicht aus mehr Text. Die Segmente werden gegen `docs/KALIBRIERUNG.md` gerechnet.
  - **Musik als Ogg Vorbis:** `assets/generated/music/*.ogg` (Qualität 5, ffmpeg mit libvorbis) statt WAV; 17,9 MB wurden 1,4 MB. Die Generatoren rendern das WAV nach `build/audio/music/` (nicht im Repo, bitgleich zur früheren Fassung) und `tools/audio/encode.py` kodiert und prüft Länge und Naht der Schleife. Der Import setzt `loop=true`; Godot spielt die Schleife aus dem Decoder, nicht aus dem Dateirand. Ambience-Betten und Effekte bleiben WAV (klein, Lautheit mit `check_levels.py` gemessen).
  - **Neue Entwicklungsabhängigkeit:** ffmpeg (nur zum Erzeugen und Messen von Audio, nicht im Spiel, nicht im Build; das Repo trägt nur die `.ogg`-Ergebnisse). Eintrag in `DEPENDENCIES.md`.
  - **Kleine Bilder als Text:** `tools/art/pixelgrid.py` liest `.pix`-Dateien (Raster aus Zeichen, Schlüssel zur Palette, höchstens zwölf Farben, optional geschlossener Umriss) und schreibt die PNG; die Prüfung braucht nur die Standardbibliothek und läuft in `check.sh`. Gedacht für Kuriositäten, Fragmente, Schilder und Gegenstände (Plan 8).
- **Verworfen:** Geld jetzt ausgeben, bevor Akt I steht (Stile ändern sich noch); WAV behalten (wächst linear mit jedem Akt); QOA oder ADPCM im Import (verlustbehaftet und größer als Vorbis bei Musik).
- **Konsequenzen:** Ein neues Musikstück heißt `<name>_loop.ogg`; `AudioDirectorService.track_path` kennt nur noch OGG. Wer Musik ändert, braucht ffmpeg; ohne ffmpeg bricht der Generator mit einer klaren Meldung ab. Der Pegel-Check misst Musik nicht (nur Effekte, Schritte und Orte); Musikpausen und Elysias Stufen misst weiter `tools/audio/measure.sh`.

## ADR-058 · Akt I: Aufbau der Segmente, Segmentskripte und das Gasthaus (P6.8)
- **Status:** angenommen · 2026-10-24 (Plan 4, 10; „bau alles“ vom 24.10.)
- **Kontext:** Akt I wächst von einem Ort auf fünf Segmente (Plan 4.2). Jedes braucht dieselben Dinge: Karte, Szene, Dialog, Quest, Tests, ein Skript, das es von Hand spielt, und einen Brief, der sagt, was es soll.
- **Entscheidung:**
  - **Ordner:** Szenen unter `world/levels/akt1/`, Dialoge unter `content/dialogue/akt1/` (Slice-Regeln: kein `[#ph]`, `[#draft]` bis zur Lesefassung, Test `test_content` prüft beide Ordner), Requisiten in `tools/art/akt1_props.py` (gleicher Katalog wie `slice_props.py`), Briefe in `docs/akt1/REGIONSBRIEFE.md` (Beat-Tabelle, Flags, Figuren, Humor, Gewicht, Motive, Scheitern und Speichern, Barrierefreiheit, Endlichkeit, gerechnete Minuten).
  - **Heldenquest:** `main_elysia_hero` endet nicht mehr an der Truhe, sondern wächst je Segment um eine Stufe (Fluss in den Briefen). A2 hängt `inn` an. Die Schleifen beginnen bis A7 weiter am Slice-Auslöser; A7 verlegt ihn auf die Stufe `repeat`.
  - **Segmentskripte:** `tools/autopilot/akt1_<segment>.json` spielt ein Segment von seiner Szene aus (`--start=<schlüssel>`); der Schritt „segment“ in `check.sh` verlangt je Segment seine Marken (Beats und Flags, Liste `segments` im Skript). Der Slice-Durchlauf bleibt unverändert.
  - **A2:** das Gasthaus zum Immer steht in der Mitte der Nordterrasse des Gartens (Spalte 32, Zellen 28–36 mal 3–6 sind fest, die Tür in Zelle 32, 6); innen eine spiegelsymmetrische Halle mit zwei Zimmern. Der Gastwirt macht drei Angebote (Brot, Zimmer, Nacht), jedes frei abzulehnen. Neue Nebenquest „Das Gästebuch“ (2.000 XP, 500 Gold für nichts). Die Spielfigur schläft im Bett; die Szene blendet auf Weiß und zurück (derselbe Morgen).
  - **Karten:** Innenräume des Akts sind `elysia`-Stil mit gebackenem Boden (`cobble`) und einer flachen Hülle (`inn_shell`) für Wände und Fenster, wie das Haus im Tal; Zoom 1,5 (ADR-045, Nachtrag); die Kamera bleibt in den Räumen (`view.bounds`).
- **Verworfen:** ein eigener Ordner je Segment (die Orte sind wenige und wiederkehrend); die Segmentskripte in den Slice-Durchlauf zu schreiben (jede Änderung am Slice verschöbe alle Zeiten).
- **Alte Spielstände:** Ein Slice-Stand (v0.8.4) hat die Heldenquest auf `celebrated`, früher final, jetzt die Stufe vor dem Gasthaus: er lädt ohne Reparatur und die Quest steht wieder offen (das eingefrorene Beispiel `v2_slice_end.json` bleibt unverändert, `test_save_policy` erwartet das neue Bild). Spielstände aus Slice-Builds müssen den Akt nicht überleben (ADR-050).
- **Konsequenzen:** Jedes weitere Segment trägt Brief, Segmentskript und Marken-Eintrag in `check.sh` im selben Pull Request. Die Nordterrasse hat nun einen Zweck; die Elysianer, die dort gingen, gehen auf Reihe 2.


## ADR-059 · Akt I: der Markt von Elysia, Gold ausgeben und die Stufe „market“ (P6.9)
- **Status:** angenommen · 2026-10-24 (Plan 4.2, A3; „bau alles“ vom 24.10.)
- **Kontext:** A3 ist die Stadt hinter dem Garten: ein Platz für Menschen, die zweimal dort stehen, eine Tafel, ein Händler, eine Melodie, die verschlossene Halle der Spiegel (A5). Es braucht dafür einen Weg aus dem Garten, ein erstes Mal Gold ausgeben und eine Stufe der Heldenquest.
- **Entscheidung:**
  - **Lage:** Die Treppe liegt am Südende des Gartens (Spalte 32, Zellen 31–33, Reihen 34–35, Auslöser in Reihe 35); sie führt auf den Markt (`markt`, 61 × 36, spiegelsymmetrisch um Spalte 30, Zoom 1,25, Ankunft `spawn_garden`; zurück nach `spawn_markt` am Treppenabsatz). Alle Fassaden schauen nach Süden, deshalb betritt man den Markt von Süden: Tor in der Südmauer, die Halle im Norden an der Mittelachse. Die Halle ist bis A5 zu (`unless elysia.hall_open`, ein Schild: „geöffnet ab morgen“).
  - **Menschen:** sieben Rollen (Torwächter, Bäckerin, Händler, Blumenfrau, Schneiderin, Dichter, Musikerin) je zweimal, spiegelbildlich in derselben Reihe, mit eigenen Figurenbögen (`make_character.py`); die Verkäufer stehen vor ihrem Stand, damit man sie von Süden erreicht (Sprechradius 14 Pixel).
  - **Heldenquest:** Stufe `market` hängt an `celebrated` und `inn` und ist vorläufig final. Der Markt setzt sie beim Betreten (`MarktScene`); wer den Markt vor der Truhe besucht, bekommt die Stufe von der Truhe nachgetragen (`ElysiaScene._catch_up_the_hero_quest`, erst `inn`, dann `market`).
  - **Gold ausgeben:** `WorldState.gold()` und `spend_gold(n) -> bool` (nie mehr, als da ist; die Anzeige zählt hinunter, ohne Münzenflug). Gold ändert nichts, es kauft nur (Bible §10): ein Kompliment (zehn Gold, bestehender Gegenstand), den Glücksbringer (hundertfünfzig, neu, einmal), eine Münze in den Brunnen. Antworten, die man nicht bezahlen kann, erscheinen nicht; „Ich schaue nur.“ steht immer da.
  - **Nebenquest „Die Auftragstafel“** (`side_elysia_board`): Brot von der Bäckerin zur Schneiderin tragen (Stufen `bread`, `deliver`, `done`), die es gestern schon hatte; der Lohn (3.000 XP, 800 Gold) war abgezählt. Der Auftrag lässt sich liegen lassen.
  - **Erste Melodie:** die perfekte der Musikerin (`melody.elysia_perfect`, +1.000 XP): Zuhören reicht; sie ist die Vorarbeit für die Melodie des Kindes (A8, die zweite von zwei in Akt I).
  - **Wasser:** `water_loop.wav` (Brunnen) fehlte seit dem Katalogeintrag des Brunnens; `make_ambience.py` erzeugt sie jetzt (acht Sekunden, ohne Zufall im Takt).
- **Verworfen:** Verkäufer hinter dem Stand (von Süden nicht ansprechbar); ein Laden mit Preisliste und Menü (ein Händler mit zwei Waren und der Antwort „Ich schaue nur“ reicht für die Satire und bleibt im Dialog, Cut-First); einen Zähler für die Melodien zeigen (Bible §23).
- **Alte Spielstände:** `inn` war in A2 final; jetzt führt es zu `market`. Ein Stand auf `inn` lädt ohne Reparatur und die Quest steht wieder offen, bis der Markt betreten ist (derselbe Weg wie bei `celebrated` in ADR-058).
- **Konsequenzen:** A5 setzt `elysia.hall_open` und nimmt die Türen weg (der Markt zählt den Beat `market_hall_open`; **teilweise ersetzt durch ADR-060**: die Türen öffnen sich, wenn man dagegen drückt, nicht erst in A5); A6 und A7 spielen auf derselben Karte (Fest- und Schleifenzustand per Flags). Das Verkaufen bleibt im Dialog, bis ein zweites Segment es braucht.

## ADR-060 · Akt I: die Halle der Spiegel, Wahrnehmung als Aufgabe und die erste Facette (P6.10)
- **Status:** angenommen · 2026-10-24 (Plan 4.2, A5; Bible §16, §59 Risiko 2; „bau alles“ vom 24.10.)
- **Kontext:** Bible §59 verlangt eine mechanische Herausforderung je Region; in Elysia ist es die Wahrnehmung, alles andere bleibt mühelos. Elysia ist spiegelsymmetrisch (ADR-031), das heißt: ein Ding, das nur auf einer Seite liegt, ist in dieser Welt schon eine Aussage. Die Aufgabe darf nicht scheitern, nicht drängen und nicht von der Auffassungsgabe allein abhängen (Bible §49, §50).
- **Entscheidung:**
  - **Aufgabe:** Die Halle (`spiegelhalle`, 33 × 42, drei Räume übereinander, Zoom 1,5) steht voller Paare; im ersten und zweiten Raum liegt ein Gegenstand nur auf einer Seite (Blatt links, Feder rechts). Ihn anzusehen („bemerken“) öffnet das Tor zum nächsten Raum; im letzten Raum zeigt der große Spiegel die Halle und nicht die Spielfigur, wer hinsieht, bekommt die Facette `perception` (Wahrnehmung I: man darf sagen, was man bemerkt). Aufheben ist eine eigene, freie Entscheidung (Kuriosität für das Regal, `curiosity_dry_leaf`, `curiosity_feather`). **Nachtrag (ADR-064):** Beim Übergang in die Wirklichkeit bleiben Blatt und Feder in Elysia zurück (nur Stein und Samen gehen mit, Bible §11).
  - **Hilfe:** Der Hallenwächter in der Vorhalle hilft in drei Stufen (Hinweis, genauer, die Antwort), für den Raum, in dem die Spielfigur steht, so oft man fragt; keine Strafe, kein Zähler. Ein Fehlversuch existiert nicht: der Spiegel lässt sich ansehen oder wegsehen, die Tore öffnen, wenn man hinsieht.
  - **Karten-Regel:** Die Abweichung ist die Aufgabe, deshalb darf `MapLint` sie dulden: `SINGLE_CUES` kennt `leaf` und `feather` (zu den bisherigen Einzelstücken, ADR-031, ADR-055). Alles andere in der Halle bleibt paarweise geprüft.
  - **Der Eingang** (ändert ADR-059): Die Türen der Halle am Markt sind nie abgeschlossen. Das Schild sagt „geöffnet ab morgen“; wer gegen die Türen drückt, öffnet sie (`elysia.hall_open`, die Fassade wechselt auf `hall_front_open`, der Eingang erscheint auf den Stufen). Das ist der erste Fall von Wahrnehmung: nachsehen statt glauben. „Morgen wiederkommen“ ist die Antwort daneben, frei und folgenlos. Damit hängt das Weiterkommen in Akt I nicht am Gasthaus (Bible §14: Aufbrechen ist die eigene Tat der Spielfigur).
  - **Heldenquest:** Stufe `hall` hängt an `market` und ist vorläufig final; die Truhe trägt `inn`, `market` und `hall` nach (`ElysiaScene._catch_up_the_hero_quest`).
  - **Neue Möglichkeit:** Der Dichter im Markt hat mit `perception` eine vierte Antwort (bedingte Antwort, die unbedingten bleiben). Weitere Stellen kommen mit A6 und A7 (die Wiederholung bemerken).
  - **Kleine Bilder:** Symbole für Brot, Glücksbringer, Blatt und Feder als `.pix` (ADR-057), die ersten ihrer Art.
- **Verworfen:** Eine Suche mit Zeitdruck oder Fehlern (Bible §49); ein Wahrnehmungs-Wert oder ein Hilfezähler (keine Zahlen, §16); Hinweise erst nach langem Suchen (zeitgesteuerte Hilfe zählt Wanduhrzeit); die Halle am Gasthaus zu öffnen („morgen“ als Nacht, die man annehmen muss).
- **Alte Spielstände:** `market` war in A3 final und führt jetzt zu `hall`: ein Stand auf `market` lädt ohne Reparatur, die Quest steht wieder offen (wie bei ADR-058, ADR-059).
- **Konsequenzen:** Jedes Tor, jede Facette und jede Aufgabe, die Wahrnehmung verlangt, braucht eine Hilfe in Worten. A6 (Fest) und A7 (Wiederholung) benutzen `perception` für die Antwort „Das hast du gestern auch gesagt.“.

## ADR-061 · Akt I: das Fest, Erfahrung für ein Glas und Level 48 (P6.11, A6)
- **Status:** angenommen · 2026-10-24 (Plan 4.2, A6; Bible §8, §10, §14; „bau alles“ vom 24.10.)
- **Kontext:** Elysia belohnt mehr, je weniger man tut (Bible §10). Das Fest bringt rund 11.000 Erfahrung und macht Level 48 sicher, auch wenn alles Freiwillige ausgelassen wurde (Plan 4.4: Slice 22.600 + Fest 11.000; Level 48 ab 33.135 Erfahrung). Der Gastwirt ist das Gesicht des Betäubers (Bible §14): er lädt ein und hält nie fest.
- **Entscheidung:**
  - **Auslöser:** Das Fest ist ein Zustand des Marktes (ADR-037), kein neuer Ort: `elysia.feast` wird gesetzt, sobald die Halle bemerkt wurde (`elysia.hall_mirror_seen`) und der Markt betreten wird, vor dem Bau der Karte, damit die Requisiten nicht aufpoppen. Die Requisiten des Festes sind Karteneinträge mit `if: elysia.feast` (Girlanden, Tafeln, zwei Paare Gäste) und zwei Einzelfiguren auf der Mittelachse: der Gastwirt (Einladung) und die Festmeisterin (das Hoch).
  - **Das Hoch:** Ein Glas zu heben ist die ganze Tat und zahlt 11.000 Erfahrung und 3.000 Gold einmalig; „Später“ ist eine freie Antwort. Der Fest-Zustand bleibt, die Festmeisterin hat danach eine feste Zeile (A7: ihr Gruß, wortgleich).
  - **Level 48:** Der Weg zum Markt und zur Halle hängt an nichts im Garten (die Treppe ist offen); wer Truhe, Schmetterlinge und Brunnen ausgelassen hat, hat am Hoch nur rund 19.500 Erfahrung. Darum zahlt das Hoch 11.000 und danach `WorldState.ensure_level(48)`, das genau die fehlende Erfahrung bis Level 48 (33.135) auffüllt und nichts wegnimmt (`GameState.xp_for_level` ist die Umkehrung von `level_for_xp`). Mit dem Slice-Stand (22.600) ist Level 48 auch ohne Auffüllen erreicht; ein Test deckt beide Wege ab. Die Zahl 11.000 steht im Dialog und im Test, nicht in einer Konstante (Dialoge setzen Erfahrung wie bei allen Segmenten, ADR-058).
  - **Einladung und Neue Möglichkeit:** Der Gastwirt lädt ein (frei abzulehnen, sagt der Festmeisterin Bescheid); mit der Facette Wahrnehmung gibt es bei der Festmeisterin die Antwort „Das ist dasselbe Fest wie gestern.“ (`elysia.feast_noticed`, der Gastwirt reagiert: „Hier darf man bemerken, so viel man will.“). Die Wiederholung zu bemerken ist damit zum zweiten Mal möglich (Dichter, Festmeisterin); A7 baut darauf.
  - **Heldenquest:** Stufe `feast` hängt an `hall` und ist vorläufig final; die Truhe trägt sie nach.
  - **Boden-Schatten:** Requisiten mit `if` oder `unless` werfen keinen gebackenen Schatten (`mapfile.shadow_cells`); sonst bliebe er unter den Festtafeln oder dem Blatt liegen, wenn sie nicht da sind. Alle Karten wurden neu gebacken (der Bäcker hat sich geändert), nur Markt und Halle sehen anders aus.
  - **Tor-Untertitel:** Das Öffnen eines Tores in der Halle schreibt „Ein Tor öffnet sich.“ aus, wie der Riss (`hud.show_caption`, unabhängig von der Einstellung): es ist die Antwort auf das Bemerken (Bible §50).
- **Verworfen:** Ein Fest als eigene Karte (der Markt ist schon da, ADR-037); ein Tanz oder ein Minispiel zum Hoch (Cut-First, A4 bleibt offen für P6.13); die Einladung als Pflicht (Bible §14: nichts im Hauptweg hängt an einem Angebot des Betäubers; das Fest läuft auch ohne Einladung).
- **Alte Spielstände:** `hall` war in A5 final und führt jetzt zu `feast`: ein Stand auf `hall` lädt ohne Reparatur, die Quest steht wieder offen (wie bei ADR-058 bis ADR-060).
- **Konsequenzen:** A7 verlegt den Auslöser der Schleifen hinter das Hoch (Stufe `repeat`). Akt I liegt nach A6 bei rund 29 statt 49 geplanten Minuten; die Neuplanung (P6.13) entscheidet über A4 und mehr Erkundung.

## ADR-062 · Akt I: die Wiederholung beginnt mit dem Hoch, Musikstufen nach Fortschritt, lange Uhr (P6.11, A7)
- **Status:** angenommen · 2026-10-24 (Plan 4.6, A7; Bible §35, §56 Beat 2; „bau alles“ vom 24.10.)
- **Kontext:** Im Slice begannen die Schleifen, sobald Truhe und Schmetterlinge erledigt waren (`_start_loops_when_ready`), mit Rückfallzeiten von 12 und 2,5 Minuten und Musikstufen nach 5 und 10 Minuten. Akt I dauert nach A2 bis A6 aber 30 bis 45 Minuten: die Uhr hätte mitten im Gasthaus, auf dem Markt oder in der Halle die Sätze wiederholt und den Riss geöffnet, bevor das Fest begann. Eine Karte der Folgen (vier Leser über Code und Tests, Autopilot, Dialoge, Doku) zeigte, was am alten Auslöser hing.
- **Entscheidung:**
  - **Auslöser:** Das Hoch auf dem Fest (`elysia.feast_toast`) beginnt die Sätze (`elysia.loops`), in jeder Elysia-Szene, nicht nur im Garten: der `ElysiaDirector` reagiert auf das Flag (und beim Laden eines Standes vom Fest). `begin_loops()` markiert den Beat `irritation` einmal. Die Heldenquest bekommt die Stufe `repeat` (vorläufig final), der Markt rückt beim Hoch von `feast` auf `repeat`, die Truhe trägt beide nach. `ElysiaScene._start_loops_when_ready` entfällt.
  - **Musikstufen:** `ELYSIA_STAGES` folgt dem Fortschritt: Stufe 1 mit `elysia.market_seen` (nach 1.200 s Spielzeit sonst), Stufe 2 mit `elysia.stone_taken` (nach 2.400 s sonst). Die Sätze allein sind schon Stufe 1 (`elysia.loops` impliziert mindestens Stufe 1; wichtig für Stände aus dem Slice).
  - **Uhr:** `LOOPS_AFTER` 3.600 s (eine Stunde Spielzeit), `RIFT_AFTER_LOOPS` 900 s (eine Viertelstunde Zeit für die Spur des Kindes). Die Uhr fängt nur, wer nicht weiterspielt; ein Test verlangt, dass nach 45 Minuten Spielzeit noch nichts von selbst beginnt. Der Riss durch die Uhr wird in jeder Elysia-Szene angesagt (Beben, Untertitel; Brief A7).
  - **Wortgleiche Zeilen:** Gewählt allein von `elysia.loops` (nicht von `loops_1`/`loops_2`, die nur die Musik sind). Schleife 1 für Torwächter, Bäckerin, Schneiderin, Blumenfrau, Händler (Begrüßung), Festmeisterin, Gastwirt im Gasthaus und die Gärtnerin, solange die Schmetterlinge frei sind; jede Zeile ist eine, die die Person schon gesagt hat, Wort für Wort: bei fester Rede die erste (Torwächter, Festmeisterin, Händler, Gastwirt im Gasthaus), bei Zufallsrede die erste der Reihe (Bäckerin, Schneiderin, Blumenfrau), bei der Gärtnerin ihre Wartezeile. Zeilen, die etwas schulden (Laib, Quest-Angebot, Laden, Gästebuch-Einträge), stehen in den Dialogen vor der Schleife. Schleife 2 (mit `elysia.rift_open`, wie `el_loop_2` im Garten) bleibt für A9.
  - **Slice-Durchlauf:** `slice_full.json` und `slice_elysia.json` setzen das Hoch als Flag nach der Truhe (die Reise durch Gasthaus bis Fest decken die Segmentskripte ab); die gemessene Grundzeit (`calibration_baseline.json`, 372 s) bleibt, der Beat `irritation` kommt in derselben Sekunde.
- **Verworfen:** Die Schleifen an Truhe und Schmetterlinge zu lassen und nur die Uhr zu verlängern (die Truhe ist der erste Schritt von sechs, die Wiederholung käme vor Gasthaus und Markt); Schleifenzeilen in den Dialogen nach `loops_1`/`loops_2` zu wählen (die setzt der Direktor als Musikstufen, der Markt ist schon ein Besuch alt, wenn die ersten Sätze fallen); einen eigenen Ort für die Wiederholung (sie ist ein Zustand aller Orte, ADR-037).
- **Alte Spielstände:** `feast` war in A6 final und führt jetzt zu `repeat`: ein Stand auf `feast` lädt ohne Reparatur, die Quest steht wieder offen; ein Stand mit gehobenem Glas, aber ohne Sätze (A6-Stand) beginnt die Schleife beim Laden. Slice-Stände mit Truhe und Schleife, aber ohne Markt, hören die Musik ab Stufe 1.
- **Konsequenzen:** A8 baut die Spur des Kindes auf `elysia.loops`: das Kind erscheint hinter dem Hoch, nicht davor. Die Kalibrierung (`docs/KALIBRIERUNG.md`) beschreibt weiter den Slice-Durchlauf; Akt I braucht nach P6.12 eine eigene Messung.

## ADR-063 · Akt I: die Spur des Kindes, drei Fragmente und die Melodie (P6.12, A8)
- **Status:** angenommen · 2026-10-24 (Plan 4.2, A8; Bible §15, §31, §38, §46, §51; „bau alles“ vom 24.10.)
- **Kontext:** Im Slice zeigte sich das Kind nur im Garten, summte und verschwand; der Plan verlangt in Akt I drei Stationen, drei Fragmente und die Melodie des Kindes (A8, 12 Minuten). Seit A7 beginnen die Sätze erst nach dem Hoch, das Kind kommt also hinter dem Fest, wenn Elysia sich wiederholt.
  Die Bible erlaubt dem Kind Bilder, keine Ursachen (§15), und die Bilder des Hauses kommen nur über das Kind und werden nie erklärt (§38, Plan 4.1). Der Plan legt für Akt I drei Fragmente aus den Bildern von §15 fest (Flur, geschlossene Tür, leeres Zimmer; Plan 4.2, 4.4); die übrigen und die zentrale Szene „Ich bin da.“ mit sechs Fragmenten gehören Akt V.
- **Entscheidung:**
  - **Drei unabhängige, freiwillige Stationen**, je ein Einzelstück auf der Karte (`child_guide.tscn`, `if: elysia.loops`, `unless: fragment.<bild>`): der Gang vor dem Südtor des Marktes (Flur), die Tür hinter dem Tresen im Gasthaus (geschlossene Tür), der große Spiegel in der Halle (leeres Zimmer).
    Jede Station bietet ein Bild einmal, danach geht das Kind. Keine Station steht in der Heldenquest, keine sperrt etwas (Bible §14, §31); die Reihenfolge ist offen.
  - **Bilder nur aus der Liste der Bible §15:** Flur, Tür, leeres Zimmer. Hand, Verstecken und das ursprüngliche Haus bleiben für Akt V. Das Kind spricht höchstens drei Wörter („Komm.“, „Leise.“, „Hier.“); die Erzählzeilen beschreiben, was zu sehen ist, und deuten nichts.
  - **Die Karte des Fundes ist leise:** Flags mit dem Präfix `fragment.` zeigen im Hud eine Karte mit dem 64-Pixel-Bild und „Etwas fällt dir ein.“ (3,6 Sekunden Spielzeit, kein Klang, kein Zähler, keine Seltenheit; `Collection.FRAGMENT_PREFIX`). Die Bilder sind `.pix`-Texte (ADR-057).
  - **Die Melodie:** Der letzte Satz des Kindes im Garten (`el_child_4`) setzt `melody.child_hum`; mit `melody.elysia_perfect` sind es zwei Melodien in Akt I (Bible §31). Die Melodie braucht keine Station.
  - **Eigene Hauptquest `main_elysia_trail`** (Das Summen): `hum` (beginnt mit den Sätzen) → `trail` (erstes Bild) → `rift` (final, der Riss öffnet sich); die Heldenquest bleibt auf `repeat`. Ein Stand aus der Schleife bekommt die Quest beim Laden.
  - **Der Riss wartet auf kein Bild.** Die Uhr aus A7 (15 Minuten nach dem Beginn der Sätze) und das Verschwinden des Kindes im Garten öffnen ihn, mit oder ohne Bilder.
  - **Beats:** `trail_hallway`, `trail_door`, `trail_room`, `child_melody` (jeder einmal, löst einen Autosave aus).
- **Verworfen:** Bilder als Pflicht für den Riss (Bible §14, §31: nichts im Hauptweg hängt an einem Angebot); ein Zähler oder Journal der Fragmente („3/6“; keine sichtbaren Zahlen für Facetten und Bilder, Bible §15, §38); alle sechs Fragmente schon in Akt I (Akt V verliert die zentrale Szene „Ich bin da.“); ein Kind, das etwas erklärt oder tröstet (§15); eine vierte Station im Garten (der Garten hat das Kind schon).
- **Alte Spielstände:** Neue Flags und eine neue Quest; kein Schema ändert sich. Ein Stand aus der Schleife (A7) startet `main_elysia_trail` beim Laden (und beendet sie gleich, wenn der Riss schon offen ist), ein Stand ohne Schleife noch nicht.
- **Konsequenzen:** A9 passt den Anschluss an: der Stein (`j`) liegt heute auch vor der Schleife und verkürzt die Musik; Samen und Riss brauchen Elysia-Inhalt, den Übergang in die Wirklichkeit trägt der Riss mit Stein und Samen. Die Kalibrierung (`docs/KALIBRIERUNG.md`) beschreibt weiter nur den Slice; P6.13 misst Akt I als Ganzes.

## ADR-064 · Akt I: Stein nach dem Hoch, der Samen in Elysia, Schleife 2 in Schritten (P6.12, A9)
- **Status:** angenommen · 2026-10-24 (Plan 4.2, A9; Bible §11, §30, §46, §56, §62; „bau alles“ vom 24.10.)
- **Kontext:** Der Plan führt A9 als „vorhanden, Anschluss anpassen“. Stein, Kind und Riss stammen aus dem Slice; seit A7 beginnt die Wiederholung erst nach dem Fest und seit A8 hat das Kind eine Spur. Drei Dinge passten nicht mehr: Der Stein lag von der ersten Minute an und verkürzte die Musik, bevor sich irgendjemand wiederholte; der Samen, den die Spielfigur seit dem Erwachen trägt, kam in Elysia nirgends vor; und die Schleife 2 (Plan 4.4: „normal, Schleife 1, Schleife 2“) hatte nur die eine Zeile im Garten. Ein Leserlauf über Stein, Samen, Riss, Schleife 2 und den Übergang (fünf Leser, eine Synthese) fand sonst nichts, was gebaut werden müsste.
- **Entscheidung:**
  - **Stein:** Seine Karteneinfügung und die Zeile zum Stein tragen `if: elysia.loops`; er liegt erst, wenn sich Elysia wiederholt (Reihenfolge der Bible §56: Wiederholung, fehlende Spiegelung, Stein, Kind, Riss). Kein Code; die Musikstufe 2 (`elysia.loops_2`) folgt weiter dem Flag `elysia.stone_taken` oder der Uhr (40 Minuten, ADR-062). Ein Stand, der ihn früher genommen hat, behält ihn.
  - **Samen:** Eine Zeile im Erwachen (`el_wake_seed`, nur mit `item_seed`): der Elysianer nimmt den Samen für Elysia in Anspruch („Aus unserem Garten, natürlich.“). Der Samen ist nach Bible §30 vor der ersten Erinnerung da, `haus_rest_4` widerspricht später. Kein Flag, kein Beet, kein Pflanzen (ADR-042, Bible §29).
  - **Schleife 2:** ein ganzer, kürzerer Satz, den die Person schon gesagt hat, wortgleich; die Sätze schrumpfen mit der Musik. Torwächter: `mk_gate_11` (wortgleich `mk_gate_4`, „Das Tor ist offen. Wie immer.“, statt der zwölf Wörter der Schleife 1); Gastwirt: nur noch der zweite seiner beiden Sätze (`gh_host_loop_2`, ohne neue Zeile). Wer keinen kürzeren ganzen Satz hat (Bäckerin mit vier Wörtern, Blumenfrau, Händler, Gärtnerin, Gäste, Festmeisterin mit einer Zeile), bleibt bei Schleife 1. Die Zeile im Garten (`el_loop_2`) bleibt die erklärte Ausnahme: sie weist auf den Riss und wiederholt nichts. Die Regel gilt ab hier; sie ändert den Wortlaut von ADR-062 („Schleife 2 bleibt für A9“) nicht.
  - **Übergang:** `RiftSequence.KEEP` bleibt Stein und Samen (Bible §11). Blatt und Feder aus der Halle (A5) bleiben in Elysia zurück: der Text von ADR-060 und der Register-Einträge „für das Regal im Haus“ wird zu „eine Kuriosität, die in Elysia bleibt“. Ein Haus-Regal für Elysias Kuriositäten wäre ein eigenes Segment (Regalplätze in `haus.dialogue`, Inventarschlüssel in `test_elysia_and_rift`).
  - **Segmentskript:** `tools/autopilot/akt1_anschluss.json` spielt Erwachen, Hoch, Stein, Kind und Riss bis zur Ankunft im Tal; die Marken stehen in `check.sh`.
- **Verworfen:** Die Schleife 2 für alle (mit längeren Ketten von Wiederholungen entstehen Sätze, die nicht mehr „schon gesagt“ sind: Bible §35); ein Samen-Flag oder ein Beet in Elysia (Cut-First, Akt V); den Stein in einer Szene früh sichtbar zu lassen und nur das Aufnehmen zu sperren (Code für ein Bild, das sonst niemand sieht); `KEEP` zu erweitern (es würde Blatt und Feder übergeben, die nie genommen wurden).
- **Entscheidungen auf Vorschlag (umkehrbar):** Schleife 2 nur für zwei Personen und die Kuriositäten bleiben zurück; beides hat der Projektinhaber nicht ausdrücklich entschieden (Rückfrage im Pull Request).
- **Alte Spielstände:** Keine neue Flag, kein neues Schema. Stände mit genommenem Stein laden ohne Reparatur; Stände ohne Schleife zeigen den Stein erst, wenn die Schleife beginnt.
- **Konsequenzen:** P6.13 misst Akt I als Ganzes (Kalibrierung gegen den Slice-Lauf reicht nicht mehr) und entscheidet über A4 und mehr Erkundung; die Rückkehr nach Elysia in Akt VI löscht `elysia.loops`, `elysia.rift_open` und `elysia.stone_taken` nicht (offen für die Planung von Akt VI).
