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
Zielrechner mit v0.5.1 (Startmenü → Leistungstest, Spalte „ohne VSync“).

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

## Playtest v0.8.0 auf dem Mac (23.10.)

Foto des Ergebnisbildschirms (Bildschirm mit 145 Hz):

| Szene | Ø fps | langsamste 5 % | ohne VSync | Urteil |
|-------|-------|----------------|------------|--------|
| Elysia | 37 | 36,4 ms | 312 | ruckelt |
| Das Tal | 145 | 8,5 ms | 145 | flüssig |
| Das Haus | 145 | 8,3 ms | 145 | flüssig |
| Der Weg zum Schuppen | 144 | 9,6 ms | 145 | flüssig |
| Wald | 145 | 8,5 ms | 145 | flüssig |

- **Deutung:** Die Szenen sind für die Grafikkarte kein Problem (Elysia schafft ohne VSync 312 fps, also gut 3 ms pro Bild). Elysia läuft mit VSync auf rund ein Viertel der Bildwiederholrate (145 / 4 = 36), und nur dort, als einzige Szene vor dem ersten Umschalten von VSync im Test. Die Reihenfolge deutet auf den Zustand des Fensters hin, nicht auf die Szene.
- **Umgesetzt (0.8.1):** `SettingsService.restart_vsync` schaltete VSync beim ersten Start kurz aus und wieder an. Es half nicht (dritter Lauf unten) und ist in 0.8.2 wieder entfernt.
- **Hütte beim Laufen:** Im Leistungstest wandert die Hütte mit der Figur mit. Das ist die Antreiber-Mechanik („Der Weg zum Schuppen“): Das Ziel hält sich 120 bis 250 Pixel vor der Figur und weicht zurück, solange sie läuft; der Test läuft auch nach links, und die Hütte folgt.

### Zweiter Lauf, Bericht `benchmark.txt` (23.10.)

MacBook mit Apple M1 Pro, eingebauter Bildschirm 3024×1964 mit 120 Hz, Fenster 1294×734, VSync an. Der Lauf gehört nicht zum Screenshot oben (dort 145 fps, also vermutlich ein anderer Bildschirm).

| Szene | Ø fps | langsamste 5 % | ohne VSync | Draw Calls |
|-------|-------|----------------|------------|------------|
| Elysia | 60 | 18,6 ms | 205 | 80 |
| Tal | 58 | 33,3 ms | 474 | 81 |
| Haus | 76 | 18,1 ms | 184 | 14 |
| Weg | 60 | 19,4 ms | 461 | 88 |
| Wald | 108 | 17,3 ms | 145 | 128 |

- **Deutung:** Die Maschine schafft in jeder Szene deutlich mehr als die 120 Hz des Bildschirms. Mit VSync liefert sie die Hälfte oder weniger, im Tal mit Aussetzern von 33 ms (jedes vierte Bild). Das passt nicht zur Vermutung „nur die erste Szene“ aus dem ersten Lauf: Elysia ist hier die erste Szene und mit 60 fps nicht schlechter als Weg. Beides spricht für die Bildsynchronisierung von macOS (Spiel läuft über die OpenGL-Schicht, `Compatibility`), nicht für die Szenen. Die Spalten CPU ms und GPU ms taugen nicht: GPU-Zeit liefert macOS mit OpenGL nicht (0,00), und die CPU-Zeit (bis 12 ms bei 205 fps) zählt Wartezeiten des Treibers mit.
- **Umgesetzt:** Der Leistungstest zeigt jetzt „VSync bremst“ und den Hinweis auf die Einstellung, wenn eine Szene ohne VSync mindestens das 1,5-Fache der Bildwiederholrate schafft, mit VSync aber unter 85 % davon bleibt (`FrameStats.held_by_vsync`, `BENCH_VSYNC_HINT`; die Werte dieses Laufs sind die Testfälle).
- **Offen:** Läuft das Spiel mit Einstellungen → Anzeige → Bildsynchronisierung **aus** ruhig (die Engine begrenzt dann selbst auf 120 fps)? Wenn ja, wird „aus“ auf macOS der Standard (OFFENE_PUNKTE).

### Dritter Lauf mit 0.8.1 (23.10.)

Gleiche Maschine, Fenster 1280×720, VSync an, 120 Hz laut Bildschirmabfrage:

| Szene | Ø fps | langsamste 5 % | max | ohne VSync | Urteil |
|-------|-------|----------------|-----|------------|--------|
| Elysia | 36 | 35,9 ms | 201 ms | 282 | VSync bremst |
| Tal | 145 | 8,5 ms | 13 ms | 145 | flüssig |
| Haus | 145 | 8,9 ms | 13 ms | 145 | flüssig |
| Weg | 121 | 17,1 ms | 42 ms | 145 | flüssig |
| Wald | 145 | 8,3 ms | 15 ms | 145 | flüssig |

- **Deutung:** Wie im Screenshot (erster Lauf): nur die erste Szene ist langsam, die übrigen laufen danach mit 145 fps. Mit VSync auf einem 120-Hz-Bildschirm sind 145 fps nicht möglich; nach dem ersten Aus- und Einschalten im Test synchronisiert VSync also offenbar nicht mehr. Der zweite Lauf (60, 58, 76, 60, 108) passt in kein Muster. Die Ursache bleibt offen; die Auffrischung beim Start war es nicht.
- **Umgesetzt (0.8.2):** Das Ergebnis des Leistungstests hat bei „VSync bremst“ einen Knopf „Bildsynchronisierung ausschalten“.
- **Hütte beim Laufen:** Ab 0.8.2 bleibt die Hütte im Leistungstest stehen (`AntreiberEncounter.goal_recedes`, vom Test ausgeschaltet); im Spiel weicht sie weiter zurück, solange die Figur läuft (die Mechanik von „Der Weg, der nicht endet“).

### Recherche zu VSync auf dem Mac (23.10.)

Drei unabhängige Recherchen (Godot-Issues, Apple-Plattform, Godot-Quelltext 4.7.2) und eine Synthese. Belegt und Vermutung getrennt:

- **Belegt (Quelltext 4.7.2, `platform/macos/gl_manager_macos_legacy.mm`):** VSync im nativen OpenGL-Pfad ist ein einziger Aufruf `CGLSetParameter(kCGLCPSwapInterval)` auf dem aktuellen Kontext, danach `flushBuffer`. Es gibt keinen Display-Link und keinen Takt im Spiel; `window_get_vsync_mode()` gibt nur den gewünschten Wert zurück. Deshalb war das kurze Aus- und Einschalten beim Start wirkungslos.
- **Belegt (Godot-Issue 79646, offen, bestätigt):** Im Compatibility-Renderer läuft VSync auf macOS mit der falschen Rate (doppelt so schnell wie der Bildschirm; reproduziert 2026 mit 4.5.1 auf macOS 26.2). Dort schreibt ein Nutzer, dass es mit dem ANGLE-Treiber stimmt. Andere OpenGL-Engines melden dasselbe auf Apple Silicon (GLFW-Issue 2249; SDL wartet deshalb selbst auf einen Display-Link, SDL-Issue 4918).
- **Belegt (Apple Developer Forums, Thread 795447):** Unter macOS 26 hält der Stromsparmodus VSync-Spiele im Vollbild bei 30 fps; Apple nennt es „möglicherweise gewollt“. Das passt zum ersten Mac-Lauf (überall genau 30 fps).
- **Nicht belegt:** Niemand meldet „nur die erste Szene bei einem Viertel der Bildrate“. Auch denkbar: Die 145 fps sind Schleifendurchläufe ohne gezeichnetes Bild, weil Godot ein nicht zeichenbares Fenster auf 6,9 ms pro Durchlauf bremst (`low_processor_mode_sleep_usec`, 1000/6,9 = 145). v0.8.3 misst darum die wirklich gezeichneten Bilder (`Engine.get_frames_drawn()`), den Anteil der Durchläufe, in denen das Fenster nicht zeichenbar war oder keinen Fokus hatte, die fps je Sekunde, alle Bildschirme mit Wiederholrate und den Bildschirm des Fensters.
- **Gegenmittel, nach Aussicht geordnet:** (1) ANGLE-Treiber, VSync dann über Metal (`CAMetalLayer.displaySyncEnabled`); nach 4.5 ANGLE über Metal, auf 4.7 nicht gemessen. Der Export von Linux aus legt die Bibliotheken nicht bei (geprüft), siehe `OFFENE_PUNKTE.md`. (2) VSync aus und Begrenzung auf die Bildwiederholrate (der Knopf im Leistungstest); mögliche Nebenwirkungen: Tearing im Vollbild, Takt der Schlafzeit. (3) Netzteil, Energiemodus „Hoch“, Fenster statt Vollbild als Gegenprobe. (4) VSync nach dem Fokuswechsel erneut setzen (unbelegt).

### Rückmeldung zum Spielgefühl (23.10., Version 0.8.2)

Der Projektinhaber: Maus, Bild und VSync laufen gut, und es fühlt sich gleich an, ob VSync aus oder an ist. Die Zahlen des Leistungstests (36 bis 108 fps mit VSync, mehr ohne) decken sich also nicht mit dem Gefühl im Spiel. Mögliche Gründe, noch nicht unterschieden: Die gezählten Durchläufe sind nicht alle gezeichnete Bilder (Godot bremst ein nicht zeichenbares Fenster auf 6,9 ms pro Durchlauf), oder die Messung selbst (Szenenwechsel, Umschalten von VSync, Eingaben im Takt) stört. Der Bericht von 0.8.3 trennt beides (gezeichnete Bilder, Fensterzustand, fps je Sekunde); der zuletzt geschickte `benchmark.txt` war noch der von 0.8.1 (gleicher Zeitstempel 16:57:21). Der Standard bleibt VSync an auf allen Systemen: VSync auf macOS standardmäßig auszuschalten wurde erwogen und verworfen, weil der Befund im Spiel fehlt. Der Leistungstest nennt „VSync bremst“ nur noch, wenn VSync bei der Messung an war.

## Karten der Klasse M: der Großkarten-Spike (T6, 25.10., ADR-068)

Akt II baut die erste Karte der Klasse M (Plan 5.1: 15 bis 30 Minuten, größer als das Tal mit 68 × 38; gebaut mit B3: `bachlauf`, 84 × 66, Aufbau im Container rund 0,4 s). Bevor sie entsteht, misst `tools/perf/map_spike.py` an synthetischen Karten, was Größe kostet:
das Tal wird gekachelt (`tools/art/tile_map.py`), gebacken (`tools/perf/spike_bake.py`, ohne Stempel) und in einem `MapView` gebaut (`tools/perf/map_spike.gd`, headless; die Bilder liegen in `spike_tmp/`, das Git nicht behält).
Gemessen im Cloud-Container, ein Kern; **headless wird nichts gezeichnet**, die Werte sind Prozessorlast und Vergleichswerte untereinander, keine Zeiten eines Spielrechners. Aufbau und Prozesszeit sind das Beste aus drei Läufen (ein Container ist unruhig, die Läufe streuen um bis zu 25 %).

| Karte | Zellen | Kacheln | Bake (s) | Bake (MB) | PNG (MB) | Parse (ms) | Aufbau (ms) | Knoten | Speicher (MB) | Prozess (µs/Bild) |
|---|---|---|---|---|---|---|---|---|---|---|
| tal_1x1 | 68 × 38 | 15 | 12 | 146 | 0,4 | 3,0 | 205 | 1.447 | 13,7 | 640 |
| tal_2x1 | 136 × 38 | 15 | 26 | 254 | 0,9 | 4,7 | 351 | 2.761 | 23,9 | 51 |
| tal_2x2 | 136 × 76 | 15 | 49 | 475 | 1,8 | 8,2 | 661 | 5.688 | 44,4 | 118 |
| tal_3x3 | 204 × 114 | 15 | 120 | 922 | 4,1 | 16,3 | 1.175 | 12.923 | 95,7 | 1.085 |

(„Kacheln“ ist die Zahl der Bodenarten der Legende; das Tal malt sie mit 66 verschiedenen Zeichen.)

- **Aufbau:** rund 85 ms fest plus 47 µs je Zelle (angepasst an die erste und letzte Zeile, die mittleren liegen bis 15 % darüber), mit der Streu und den Requisiten des Tals. Das Tal braucht 205 ms; eine Karte von 120 × 70 (8.400 Zellen) rechnerisch 480 ms, zwischen den Zeilen 2 und 3 gelesen 545 ms: **rund 0,5 s**. Das Budget „Szenenwechsel unter 0,5 s“ (oben, Vorschlag) hält also bis rund 8.000 bis 9.000 Zellen; darüber deckt die Überblendung den Aufbau, und bei Klasse L (204 × 114: 1,2 s) reicht das nicht mehr (Streu und Requisiten in Blöcken, Akt IV).
- **Parse** ist unkritisch (16 ms bei 23.000 Zellen). **Knoten und Speicher** wachsen linear (13.000 Knoten, 96 MB bei 204 × 114) und liegen weit unter den 500 MB des Budgets.
- **Prozess- und Physikzeit je Bild** liegen bei jeder Größe unter 1,1 ms (Median nach 40 Bildern Einschwingen) und wachsen nicht erkennbar mit der Fläche. **Das Zeichnen ist nicht gemessen** (kein Grafikprozessor im Container); dafür bräuchte es einen Leistungstest auf dem Mac, siehe offene Punkte.
- **Baker:** Zeit rund 20 s je Megapixel (Karte × 16 Pixel je Seite, also Zellen × 256), Spitzenspeicher rund 50 MB plus 147 MB je Megapixel. Eine Karte von 120 × 70 (2,15 MP) braucht rund 42 s und 365 MB, 200 × 120 (6,14 MP) rund 123 s und 950 MB. Die PNG-Datei wiegt rund 0,7 MB je Megapixel (Klasse M: rund 1,5 MB).
- **Wie viel ein Zellwechsel neu malt**, am Tal gemessen (Gras → Weg an drei Stellen, Hecke → Weg, Hecke → Pfütze): Boden, Weg und Wasser ändern nur ihre Umgebung (37 Pixel von 660.000); Hecken und Klippen zeichnet der Baker aus einem durchlaufenden Zufallsstrom, und eine Änderung färbt dann 18 bis 59 % des Bildes anders. Darum landet das Layout einer Karte in **einem** Pull Request, und ihre Bakes werden erst beim Einfrieren der Region committet (Plan T7).
- **Kartenformat:** Symbole außerhalb von ASCII (Grundebene, höhere Ebenen) laufen durch beide Parser (`tests/fixtures/maps/unicode_symbols.txt`, `test_map_data`, `tools/art/test_mapfile.py`). Nicht erlaubt sind Leerzeichen jeder Art: ASCII-Leerzeichen und Tabulatoren schneiden beide Parser ab, Unicode-Leerzeichen (U+00A0, U+2003, U+3000 und weitere) schneidet nur Python ab, darum lehnt `MapData` sie als Symbol ab. Ein Kartenformat v2 wird nicht gebraucht; die Zahl der Symbole begrenzt nur die Legende.

**Obergrenze der Klasse M:** 120 × 70 Zellen (8.400), aus den Messwerten abgeleitet: rund 0,5 s Aufbau im Container, am Rand des Budgets; was größer wird, braucht Nachweis (Aufbau in Blöcken). **Offen:** Die Bildrate auf dem Mac ist nicht gemessen und blockiert Akt II nicht; gemessen werden soll jetzt an `bachlauf` und `waldweg` (beide stehen in `SceneRegistry.BENCHMARK`; `waldweg`, 100 × 62 mit 3.453 Streu-Sprites, braucht im Container vom Laden bis „scene ready“ rund 0,5 s, `bachlauf` 0,38 s; `huette`, 32 × 20 von Hand, ist eine Klasse-S-Karte wie das Haus) und, als Vergleich, an einer 136 × 76-Karte (`spike_tmp/tal_2x2.txt` nach einem Lauf von `map_spike.py`).
