# Entscheidungen (ADRs)

Kurzform: Kontext · Entscheidung · Konsequenzen. Neue Einträge unten anhängen, alte nicht löschen,
sondern mit „Ersetzt durch ADR-xxx“ markieren. Grundlage: [`PRE_IMPLEMENTATION_REVIEW.md`](PRE_IMPLEMENTATION_REVIEW.md).

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

## ADR-012 · Welt im SubViewport, zwei Kameramodi
- **Status:** angenommen · 2026-10-02 · Kameramodus wird nach Playtest festgelegt
- **Kontext:** Bei reinem Pixel-Snapping ruckelt das Scrollen (abwechselnd 1 und 2 Spielpixel pro Frame). Ein Experiment hat gezeigt: Unter `canvas_items`-Stretch lässt sich ein Sprite mit der Viewport-Textur auf Bildschirmpixel genau verschieben, wenn das Hauptfenster nicht snappt. Mit Snapping springt es in ganzen Spielpixeln.
- **Entscheidung:** Das Hauptfenster nutzt `canvas_items` mit Integer-Scaling und ohne 2D-Snapping. Die Welt rendert pixelgenau in einem SubViewport (642×362, 1 Pixel Rand) und wird als Sprite um Bruchteile eines Spielpixels verschoben. `GameView` setzt die Canvas-Transformation direkt (keine `Camera2D`). Das Anzeige-Sprite ist von der Physik-Interpolation ausgenommen. Beides ist gemessen und beseitigt einen Frame Verzögerung. Physik-Interpolation ist global an, damit 120- und 144-Hz-Bildschirme flüssig laufen. Der Player liefert seine interpolierte Position selbst.
- **Modi:** *Weich* scrollt gleichmäßig (gemessen 3 bzw. 4 Bildschirmpixel pro Frame bei 2×), die Figur wackelt um ±0,5 Spielpixel. *Pixelgenau* scrollt in ganzen Spielpixeln (2 bzw. 4 Bildschirmpixel), die Figur steht ruhiger. Beide sind im Pause-Menü umschaltbar.
- **Konsequenzen:** Weltknoten bekommen keine Input-Events und fragen den `Input`-Singleton ab. UI liegt in CanvasLayern außerhalb des SubViewports. Wer Knoten in `_process` bewegt, schaltet deren Physik-Interpolation ab.

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

## ADR-018 · Einstellungen als JSON, getrennte Profile für automatische Läufe
- **Status:** angenommen · 2026-10-03 · ersetzt die Testoptionen aus ADR-016
- **Kontext:** Geplant war `user://settings.cfg` mit `ConfigFile`. Dessen Parser kann aus Text Objekte und Ressourcen-Verweise erzeugen. Für Saves gilt bereits „kein Code aus Nutzerdateien“ (ADR-008). Außerdem schrieben Smoke-Runs, Tests und Aufnahmen bisher in denselben Nutzerordner wie das echte Spiel.
- **Entscheidung:**
  - Der Autoload `Settings` speichert `settings.json` (Version, Werte, Eingabe-Overrides). Jeder Wert hat ein Schema mit Standard und Bereich; Ungültiges fällt auf den Standard zurück und wird geloggt. Geschrieben wird atomar über eine temporäre Datei.
  - Startargumente (`--camera`, `--tuning`, `--directions`, `--sprint`, `--overlay`, `--text=instant`) gelten nur für die Sitzung und werden nie gespeichert.
  - Eingabe-Overrides werden als einfache Daten gespeichert (Taste, Pad-Knopf, Achse, immer `device = -1`). Die Rebinding-Oberfläche folgt nach dem Slice (ADR-011).
  - `RuntimeEnv`: GUT-Läufe nutzen `user://profiles/test/`, Läufe mit `--profile=<name>` `user://profiles/<name>/`. `check.sh` und `smoke_export.sh` nutzen `smoke`, `capture.sh` nutzt `capture`.
- **Konsequenzen:** Keine Objekterzeugung aus Nutzerdateien. Automatische Läufe überschreiben nie Spielstände oder Einstellungen des Spielers. Die Phase-1-Testoptionen liegen jetzt dauerhaft im Einstellungsmenü.

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

## ADR-021 · Speichern im Spiel
- **Status:** angenommen · 2026-10-03 · konkretisiert ADR-008
- **Entscheidung:**
  - Slots: `autosave` plus drei manuelle. Autosave beim Betreten eines Bereichs (nicht nach dem Laden) und bei jedem Quest-Schritt.
  - Gespeichert werden darf nur, wenn nichts sperrt (Dialog, Ladevorgang) und die Szene speicherbar ist. Encounter sind nicht speicherbar; ihr Autosave folgt im nächsten Bereich.
  - Vor dem Überschreiben wird die bisherige Datei zur Sicherung (`.bak`), aber nur, wenn sie lesbar ist. Eine beschädigte Datei verdrängt nie eine gute Sicherung. Das Lademenü bietet bei beschädigten Slots die Sicherung an.
  - Laden ersetzt den Zustand, wechselt in die gespeicherte Szene und setzt die Figur an die gespeicherte Position. Weltobjekte stellen ihren Zustand aus Flags her.
  - Spielzeit zählt nur, solange eine Spielszene läuft und nichts pausiert ist.
- **Konsequenzen:** Keine halben Gespräche in Spielständen. Startet man im Prototyp-Menü eine Szene neu, überschreibt deren erstes Autosave den alten Autosave (die Sicherung bleibt). Das ändert sich mit dem echten Titelablauf.

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
- **Konsequenzen:** Rund 7,6 MB WAV im Repo (22,05 kHz Stereo), im Build komprimiert. Die Klangqualität ist Platzhalter-Niveau; Komposition und Aufnahme brauchen später Budget oder Musiker. Neue Tracks: Funktion in `make_music.py` und Eintrag in `AudioDirector.TRACKS`.

## ADR-024 · UI-Bogen: Elysia-Skin mit HUD, Real-Skin fast leer
- **Status:** angenommen · 2026-10-03
- **Entscheidung:**
  - Zwei Themes (`ui/theme/elysia_skin.tres`, `real_skin.tres`) überschreiben nur, was sich unterscheidet. `UiSkin.attach(control)` hält Dialogbox, Menüs, Journal, Prompt und HUD im Stil des aktuellen UI-Modus, auch nach dem Laden.
  - Elysia: Goldrahmen mit Edelsteinen (`tools/art/make_ui.py`), HUD mit Level, XP-Leiste, Gold und Quest-Anzeige samt Marker, laute Popups für XP, Gold, Level-Up und Loot. Seltenheit erscheint immer auch als Wort, nie nur als Farbe.
  - Real: keine Rahmen, gedämpfte Farben, kein HUD; nur eine leise Zeile, wenn man etwas aufhebt.
  - Items haben eine Seltenheit; der Stein hat keine („Seltenheit: —“).
- **Konsequenzen:** Weitere UI-Elemente bekommen `UiSkin.attach`. Der spätere persönliche Stil („Handschrift, Kritzeleien“) wird ein dritter Skin.

## ADR-025 · Übergangssequenz und Tageslicht
- **Status:** angenommen · 2026-10-03
- **Entscheidung:**
  - `RiftSequence`: Spieler wird festgehalten, Speichern gesperrt, die Welt ruckelt (nur mit Bildschirmwackeln an), die HUD-Elemente verschwinden einzeln (ohne Flackern bei „Blitzeffekte reduzieren“), die Musik läuft als Bandstopp aus, Stille, Abblende. Danach UI-Modus REAL, Inventar Stein und Samen, Szenenwechsel ins Tal mit Regen, Autosave dort.
  - Autoload `ScreenFade`: schwarze Abdeckung über Szenenwechsel hinweg; neue Szenen blenden selbst auf.
  - `DayLight` für Szenen der Wirklichkeit: Presets Regentag, Abend, Nacht blenden Weltfarbe, Farbstimmung, Lampen, Regen und Ton. Im Tal lässt Ausruhen auf der Bank die Zeit weiterlaufen. Elysia hat bewusst kein Tageslicht.
- **Konsequenzen:** Der Ablauf ist getestet und als Video belegt. Echte Story-Platzierung (Kind, versteckter Riss, Hilfe nach Zeit) folgt mit Phase 4.

## ADR-026 · Schrift und Bewegung der Oberfläche
- **Status:** angenommen · 2026-10-04 · ersetzt die Schriftwahl aus Phase 0
- **Kontext:** Tiny5 ist nur 5 Pixel hoch. Dialoge und Menüs waren bei 640×360 kaum lesbar, das Startmenü eine Entwicklerliste auf Schwarz.
- **Entscheidung:**
  - Hauptschrift **Jersey 10** in ihrer Pixelgröße 19 (Versalhöhe 10 px), Titel **Jersey 15** in 27, beide aus google/fonts (OFL 1.1). Tiny5 bleibt für kleine Beschriftungen (Hinweise, Tasten-Kappe, Entwickler-Panels).
  - Menüs: gleitender Cursor je Skin (Elysia Goldjuwel, Real Strich), das Spiel dahinter weichgezeichnet und getönt (`menu_backdrop.gdshader`), Panels gleiten 6 px ein. Animiert wird die CanvasLayer-Verschiebung, nie ein verankerter Container.
  - Dialogbox mit Namensschild, Weiter-Pfeil, Cursor auf Antworten und Stimme je Sprecher (`content/dialogue/voices.json`).
  - Startmenü mit eigener Titelgrafik (`tools/art/make_title.py`), Prototypen in einem Untermenü.
- **Konsequenzen:** Längere Listen (Einstellungen) scrollen. Wer UI baut, nutzt die Theme-Typen (`SmallLabel`, `HintLabel`, `PromptText` …) statt Schriftgrößen im Code.

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

## ADR-039 · Das Haus von innen: kleine Karte, gemalte Raumhülle
- **Status:** angenommen · 2026-10-06
- **Kontext:** Der Boden-Baker malt Landschaft, keine Innenräume mit Wänden.
- **Entscheidung:** Das Haus ist eine kleine Textkarte (Dielen, feste Wände) mitten in Schwarz; Blockwand, Fenster, Seitenwände und Türöffnung malt ein flaches Requisit `haus/shell`. Licht: kalt-blauer Raum mit Fensterschein, bis das Feuer brennt; dann wechselt der Raum über Sekunden ins Warme, und Regen auf dem Dach plus Kaminfeuer ersetzen die Stille.
- **Konsequenzen:** Weitere Innenräume brauchen eine eigene Hülle (oder später ein Tileset). Der Raum ist klein auf dem Bildschirm (KNOWN_ISSUES #44).

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

## ADR-044 · Playtest-Gate: Release-Entwurf auf Versions-Tag, Beat-Zeilen in jedem Build
- **Status:** angenommen · 2026-10-06 (Phase 5, Auftrag des Projektinhabers: „Weiter“ nach dem Merge von Phase 4)
- **Kontext:** Phase 5 verlangt Build, Testanleitung, bekannte Probleme, Playtest-Fragen, Risiken, Leistung, Platzhalter und nächste Schritte (Master-Prompt §47). ADR-009 sah Playtest-Builds als GitHub-Release vor. Das Repository ist inzwischen öffentlich; ein veröffentlichtes Release kann jeder herunterladen. Beim Vorbereiten fiel auf, dass Release-Builds nur Warnungen und Fehler loggen: Die Beat-Zeilen mit den Spielminuten, mit denen der Playtest die Spielzeit misst, fehlten ohne `--log-debug`.
- **Entscheidung:**
  - Version **0.5.0** (Phase 5). Ein Tag `v<Version>` auf `main` baut Windows, macOS und Linux und legt mit `tools/release.sh` einen **Release-Entwurf** an (Pre-Release, je System ein Zip mit `LIESMICH.txt`). Der Tag muss zur Version in `project.godot` passen. Den Entwurf veröffentlicht der Projektinhaber.
  - `Log.record` schreibt in jedem Build. Genutzt nur für die Minute jedes Beats und die Build-Zeile beim Start, damit jedes Tester-Log Spielzeiten und Version enthält, ohne persönliche Daten.
  - Eine Testanleitung für alle Tester (`PLAYTEST.md`, Fragen nach Master-Prompt §48) und ein Gate-Bericht mit Gate-Matrix M/Ä, Risiken, Leistung, Platzhaltern und nächsten Schritten (`GATE_REPORT.md`).
- **Konsequenzen:** Releases zählen nicht zum Artefakt-Speicher. Ohne Veröffentlichung bleibt der Build privat. Die Schwellen der Gates sind Vorschläge, die der Projektinhaber vor der Auswertung festlegt. Nach Phase 5: STOP, bis Ergebnisse vorliegen.

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

