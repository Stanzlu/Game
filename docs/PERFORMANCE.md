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
