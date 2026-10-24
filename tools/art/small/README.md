# Kleine Bilder von Hand (`.pix`)

Quellen für 16×16-Bilder (Kuriositäten, Fragmente, Schilder, Gegenstände): ein Raster aus Zeichen, ein Schlüssel zur
Palette, daraus macht `tools/art/pixelgrid.py` die PNG (ADR-057). Format und Regeln stehen im Kopf des Skripts; geprüft wird
es mit `python3 tools/art/pixelgrid.py --check` (läuft in `check.sh` über `test_pixelgrid.py`).

```
name: curiosity_example
out: assets/generated/items
size: 8x8
palette: o=#1a1530 y=#f7cf4a
outline: o
---
..oooo..
.oyyyyo.
oyyyyyyo
oyyyyyyo
oyyyyyyo
oyyyyyyo
.oyyyyo.
..oooo..
```

Jedes Bild trägt seinen Eintrag in `docs/PLACEHOLDERS.md`, bis der Projektinhaber die Region abgenommen hat.
