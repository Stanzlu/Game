# Performance

## Budget (Vorschlag, Abstimmung offen)

Abschnitt 52 des Master-Prompts verlangt ein gemeinsam definiertes Budget. Vorschlag für den Slice:

| Messgröße | Ziel | Referenzsystem |
|-----------|------|----------------|
| Bildrate | stabil 60 fps, keine Ruckler beim Kameraschwenk | Laptop mit integrierter Grafik (ca. 2019), 1080p |
| Frame-Zeit | 95. Perzentil unter 16,6 ms | wie oben |
| Start bis Titel | unter 3 s | SSD |
| Szenenwechsel | unter 0,5 s | SSD |
| Speichern | unter 100 ms, ohne spürbares Stocken | SSD |
| Arbeitsspeicher | unter 500 MB | – |
| Build-Größe | unter 200 MB pro Plattform | – |

## Baseline Phase 0 (2026-10-02)

Gemessen im Cloud-Container (keine Grafikkarte, Software-Rendering). Nur als Vergleichswert für spätere Phasen.

| Messung | Ergebnis |
|---------|----------|
| Exportierter Linux-Build, headless, bis „boot screen ready“ | 0,26–0,33 s (3 Läufe) |
| Prozessdauer headless inkl. Beenden | 0,38–0,49 s |
| Speicher headless (max. RSS) | ca. 91 MB |
| Fenster unter Xvfb, OpenGL3 via llvmpipe, 300 Frames | 4,2 s gesamt, Boot nach 0,86 s, grob 90 fps in Software |
| Speicher im Fenster (max. RSS) | ca. 215 MB |
| Build-Größen | Windows 105 MB · macOS 59 MB (zip, universal) · Linux 71 MB |

Die Build-Größe kommt fast vollständig von der Engine. Echte Frame-Zeit-Messungen auf GPU-Hardware
folgen mit den ersten Szenen in Phase 1 und mit Licht und Wetter in Phase 3.

## Phase 1 (2026-10-02)

Gemessen im Cloud-Container. Headless-Läufe zeigen die reine CPU-Last (Physik, Skripte) ohne Rendering.

| Messung | Ergebnis |
|---------|----------|
| Sandbox headless, 900 Frames mit Autopilot | 0,98 ms pro Frame, ca. 121 MB |
| Antreiber headless, 900 Frames inkl. Segment-Aufbau | 1,43 ms pro Frame, ca. 121 MB |
| Sandbox im Fenster 1280×720, Software-Rendering (llvmpipe) | 24 ms pro Frame, ca. 254 MB; nicht repräsentativ für GPUs |
| Build-Größen | Windows 105 MB · macOS 59 MB · Linux 71 MB (unverändert ggü. Phase 0) |

### Kamera-Messung (ADR-012)

Ost-Lauf mit 88 px/s bei 60 fps, Aufnahme in 2× (1280×720), gemessen an der Kante eines Schilds.

| Modus | Welt-Scroll pro Frame | Figur gegenüber Bildschirm |
|-------|-----------------------|----------------------------|
| Weich | 3 / 3 / 3 / 4 Bildschirmpixel (gleichmäßig) | ±1 Bildschirmpixel |
| Pixelgenau | 4 / 2 / 4 / 4 / 2 Bildschirmpixel (Ruckeln) | meist ruhig, gelegentlich ±2 |

Reproduzieren: `CAPTURE_FPS=60 tools/capture.sh "" captures/walk 300 --start=sandbox --camera=smooth --autopilot=res://tools/autopilot/walk_east.json`

Hinweis: Die CPU-Last liegt weit unter dem Budget von 16,6 ms. Echte Frame-Zeiten auf GPU-Hardware misst du mit der Info-Anzeige (F3) im Build.

## Phase 2 (2026-10-03)

Gemessen im Cloud-Container.

| Messung | Ergebnis |
|---------|----------|
| Speichern (Autosave, Prototyp-Zustand, inkl. Sicherung und Umbenennen) | 0,5–1,5 ms, Ziel < 100 ms erfüllt |
| Inhalte prüfen beim Start (Debug-Builds: 1 Quest, 3 Items, 3 Dialoge) | ca. 30 ms |
| Exportierter Linux-Build: „Fortsetzen“ bis „scene ready“ (Wald) | Teil des 240-Frame-Smoke-Runs, ohne Fehler |

## Phase 3 (2026-10-03)

Renderer jetzt Compatibility (ADR-022). Messung im Container mit dem neuen Leistungstest unter Xvfb
und **Software-Rendering** (Mesa llvmpipe, 4 vCPU Xeon). Nur ein Vergleichswert, keine Aussage über
echte Grafikkarten.

| Szene | Ø fps | Ø ms | 95 % ms | 99 % ms | Drawcalls |
|-------|-------|------|---------|---------|-----------|
| Elysia | 25 | 39,2 | 46,9 | 58,8 | 567 |
| Tal | 27 | 37,4 | 43,6 | 50,2 | 837 |
| Wald | 26 | 38,1 | 45,7 | 48,7 | 855 |

Headless ohne Rendering (nur Skripte und Physik) laufen alle drei Szenen mit rund 7 ms pro Frame.

**Für den Projektinhaber:** Startmenü → **Leistungstest** (ca. 45 Sekunden). Das Ergebnis erscheint im
Menü, der vollständige Bericht liegt in `benchmark.txt` im Spielordner
(`%APPDATA%\REAL\` bzw. `~/Library/Application Support/REAL/`). Ziel: Urteil „flüssig“ in allen drei
Szenen, also 95 % der Frames unter 18 ms bei 60 Hz.

## Feinschliff Phase 3 (2026-10-04)

Requisiten-Atlas je Stil und unbeleuchtete Streu-Sprites (ADR-028). Gleiche Messumgebung
(Software-Rendering, llvmpipe, 4 vCPU), Leistungstest mit 12 s pro Szene:

| Szene | Ø fps | Ø ms | 95 % ms | 99 % ms | Drawcalls vorher → jetzt |
|-------|-------|------|---------|---------|--------------------------|
| Elysia | 33 | 30,3 | 36,4 | 38,4 | 574 → 79 |
| Tal | 35 | 28,7 | 34,4 | 36,4 | 928 → 110 |
| Wald | 30 | 32,8 | 39,0 | 42,1 | 818 → 195 |

Draw Calls je Quelle (Elysia, vorher): Streu-Sprites und Requisiten ~550, Lichter 0, Partikel 4,
HUD 9. Im Wald kosten die 12 Lichtquellen weiterhin ~180 Draw Calls; das ist der nächste Hebel,
falls die Zielhardware knapp wird. Der Titelbildschirm liegt unter 30 Draw Calls.

## Bible-Abgleich (2026-10-04)

Elysia ist jetzt spiegelsymmetrisch mit Streu im Raster und Zwillings-Requisiten, das Tal hat Wind,
Blätter und das Spiegelbild der Figur (ADR-031). Gleiche Messumgebung (Software-Rendering, llvmpipe,
4 vCPU), Leistungstest mit 12 s pro Szene:

| Szene | Ø fps | Ø ms | 95 % ms | 99 % ms | Drawcalls vorher → jetzt |
|-------|-------|------|---------|---------|--------------------------|
| Elysia | 27 | 36,8 | 42,3 | 57,1 | 79 → 113 |
| Tal | 33 | 30,0 | 36,6 | 41,0 | 110 → 116 |
| Wald | 29 | 34,0 | 43,5 | 48,4 | 195 → 196 |

Elysia hat mehr Requisiten (jede Seite vollständig) und daher rund 30 Draw Calls mehr; das ist weit
unter dem Stand vor dem Atlas (574). Die Software-Werte schwanken zwischen Läufen um einige fps und
sagen nichts über echte Grafikkarten. Das Urteil „ruckelt“ gilt nur für die Container-Software.

## Erster Test auf dem Zielrechner (Playtest 2026-10-05)

Foto des Ergebnisbildschirms (macOS, Vollbild): Elysia, Tal und Wald jeweils **exakt 30 fps**, langsamste 5 % bei 34,2–34,4 ms, 100 % der Frames über 16,7 ms.

- **Deutung:** Drei unterschiedlich schwere Szenen (113–196 Draw Calls) mit identisch 30 fps sind kein Grafiklimit, sondern eine Taktbremse. Headless kostet ein Frame im Container nur rund 7 ms CPU, die Szenen sind für eine Mac-GPU winzig (640×360).
- **Wahrscheinliche Ursache:** macOS 26 hält Programme im **Stromsparmodus** im **Vollbild mit VSync** fest bei 30 fps. Apple nennt das gewollt ([Apple Developer Forums](https://developer.apple.com/forums/thread/795447)); Factorio meldet dasselbe.
- **Umgesetzt:**
  - Der Leistungstest misst jede Szene zusätzlich einige Sekunden ohne VSync („ohne VSync“) sowie CPU- und GPU-Zeit pro Frame (`viewport_set_measure_render_time`). Bei 30 fps trotz Reserve lautet das Urteil „auf 30 begrenzt“, mit Hinweis auf die Abhilfe.
  - Neue Einstellung **Anzeige → Bildsynchronisierung (VSync)**. Aus: Die Engine begrenzt die Bildrate selbst auf die Bildwiederholrate des Bildschirms (kein Leerlauf der GPU, eventuell leichtes Tearing).
  - Der Bericht nennt Vollbild ja/nein.
- **Offen:** Bestätigung mit dem neuen Leistungstest (Spalte „ohne VSync“, Bericht `benchmark.txt`) auf dem Mac. Mit Netzteil oder ohne Stromsparmodus sollten es 60 fps oder mehr sein.

## Vertical Slice (Phase 4)

Der Leistungstest misst jetzt Elysia (Look-Karte), die drei Slice-Orte Tal, Haus und Weg zum Schuppen und
den Nachtwald. Headless im Container (nur Skripte und Physik) liegen alle bei rund 7 ms pro Frame; die
langsamsten Frames bei 8–10 ms.

- **Weg zum Schuppen:** Jedes neu gebaute Wegstück kostete einen Ruckler von 25–35 ms (Karte parsen,
  rund 370 Streu-Sprites setzen). Wegstücke, die das Fenster verlassen, werden jetzt geparkt und vorne
  wiederverwendet; zwei Reservestücke je Sorte entstehen schon beim Laden. Danach max. 9 ms.

## Playtest-Gate (Phase 5, v0.5.0)

Mit Zoom 1,5× und Tiefen-Bogen (ADR-043). Container, Software-Rendering (Mesa llvmpipe, 4 vCPU),
Leistungstest im Fenster 1280×720, zweiter Lauf (Shader im Cache):

| Szene | Ø fps | Ø ms | 95 % ms | 99 % ms | max ms | Draw Calls |
|-------|-------|------|---------|---------|--------|------------|
| Elysia | 41 | 24,4 | 29,9 | 33,8 | 38,9 | 113 |
| Tal | 38 | 26,3 | 31,9 | 34,8 | 37,2 | 78 |
| Haus | 46 | 21,8 | 26,3 | 29,1 | 44,4 | 11 |
| Weg | 39 | 25,8 | 32,9 | 36,8 | 42,4 | 61 |
| Wald | 48 | 20,9 | 24,8 | 28,0 | 32,5 | 186 |

Beim ersten Lauf hatte das Tal einen einmaligen Hänger von 255 ms (Shader-Kompilierung, KNOWN_ISSUES #53).
Build-Größen aus CI (Zip): Windows rund 50 MB, macOS rund 71 MB. Offen bleibt die Messung auf dem
Zielrechner mit v0.5.0 (Startmenü → Prototypen → Leistungstest, Spalte „ohne VSync“).

## Zoom 1,25× überall (ADR-045, 07.10.)

Der Container war an diesem Tag deutlich langsamer als am 06.10. (das Haus mit 11 Draw Calls: 37 statt
22 ms). Deshalb steht hier ein Vergleich beider Stände in derselben Umgebung: Software-Rendering,
Leistungstest im Fenster 1280×720, jeweils zweiter Lauf.

| Szene | `main` (Zoom vorher) | Ø ms | Draw Calls | 1,25× | Ø ms | Draw Calls |
|-------|----------------------|------|------------|-------|------|------------|
| Elysia | 1× | 35,5 | 113 | 1,25× | 48,2 | 92 |
| Tal | 1,5× | 40,8 | 78 | 1,25× | 43,2 | 106 |
| Haus | 1,5× | 36,8 | 11 | 1,25× | 38,8 | 11 |
| Weg | 1,5× | 40,9 | 60 | 1,25× | 40,5 | 85 |
| Wald | 1× | 34,7 | 186 | 1,25× | 42,4 | 133 |

- **Unverändert:** Szenen, die schon vorher gezoomt waren (Tal, Haus, Weg), bleiben gleich.
- **Langsamer:** Elysia und Wald werden im Software-Rendering langsamer, obwohl weniger Draw Calls
  anfallen. Bei nicht ganzzahligem Zoom wird das Weltbild linear statt nach dem nächsten Pixel
  abgetastet, mit neun Zugriffen pro Bildpunkt (scharfe Abtastung und Bloom). Das kostet llvmpipe Zeit,
  einer Grafikkarte erfahrungsgemäß nicht.
- **Ausreißer:** Im zweiten Lauf mit 1,25× hatten Elysia und Wald einzelne Frames bis 240 ms, `main`
  nicht. Die Ursache ist offen, vermutlich Last im Container; im Playtest beobachten
  (KNOWN_ISSUES #53).
- **Offen:** Die Messung auf dem Mac.

