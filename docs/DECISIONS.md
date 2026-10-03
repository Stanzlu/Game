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
- **Status:** vorläufig · 2026-10-02 · Abnahme durch Playsession in Phase 1, Renderer-Entscheidung in Phase 3
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
