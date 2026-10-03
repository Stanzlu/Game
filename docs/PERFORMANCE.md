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

