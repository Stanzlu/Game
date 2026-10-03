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
- **Status:** vorläufig · 2026-10-02 · Stretch-Modus und Snapping ersetzt durch ADR-012; Renderer-Entscheidung in Phase 3
- **Entscheidung:** Viewport 640×360, Fenster 1280×720, Stretch-Modus `viewport`, Skalierung `integer`, Texturfilter Nearest, Pixel-Snapping für 2D-Transforms. Arbeitsraster 16-px-Tiles. Renderer Forward+ mit OpenGL3-Fallback.
- **Konsequenzen:** Scharfe Pixel bei 720p, 1080p, 1440p und 4K. Ruhiges Kamerascrolling braucht in Phase 1 einen Subpixel-Ansatz. ETC2/ASTC-Import ist aktiv, weil universelle macOS-Exporte es verlangen; Pixel-Art nutzt verlustfreie Texturen.

## ADR-008 · Savegames als JSON
- **Status:** angenommen · 2026-10-02 · Umsetzung Phase 2
- **Entscheidung:** Spielstände sind JSON-Dateien mit `schema_version`, atomar geschrieben (temporäre Datei, dann Umbenennen) und mit Backup. Kein `str_to_var` und kein Laden von Godot-Ressourcen aus dem Nutzerverzeichnis.
- **Konsequenzen:** Aus Savegames kann kein Code ausgeführt werden. Migrationen sind explizite Funktionen pro Schema-Version. Details in [`SAVE_FORMAT.md`](SAVE_FORMAT.md).

## ADR-009 · CI-Budget
- **Status:** angenommen · 2026-10-02
- **Kontext:** Privates Repository: 2.000 Actions-Minuten und 500 MB Artefakt-Speicher pro Monat kostenlos.
- **Entscheidung:** Nur Ubuntu-Runner. Checks (Lint, Format, Import, Smoke-Run, Tests) bei jedem Push. Exporte nur auf `main`, per manuellem Start oder wenn die Commit-Nachricht `[export]` enthält. Artefakte werden 7 Tage aufbewahrt. Kein Git LFS.
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
- **Status:** angenommen · 2026-10-02 · wird in Phase 2 durch den Settings-Autoload ersetzt
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
