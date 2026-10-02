# Art Direction (Look-Prototyp)

Arbeitsstand der Look-Phase vor Phase 2 (ADR-017). Produktvision: Game Bible, Abschnitt 36
„Moderne handgezeichnete Pixel-Art … hochwertiges Licht, Wetter, Partikel, Wasser, Wind“.
Zielbild laut Rückmeldung des Projektinhabers: moderne Top-Down-Pixel-Art wie Referenzbild 2.
Die Referenzbilder liegen bewusst nicht im Repo (fremdes Urheberrecht).

**Ehrliche Grenze:** Alles hier ist prozedural erzeugt. Es ist deutlich besser als die Grey-Box,
erreicht aber nicht die Qualität handgezeichneter Referenzen. Für finale Grafik braucht es
handgepixelte Schlüssel-Assets (Figuren, Haus, Bäume), siehe „Nächste Schritte“.

## Ansehen

Startmenü → **Look: Elysia-Garten** bzw. **Look: Tal im Regen**, oder direkt:
`tools/godot.sh -- --start=look_elysia` · `tools/godot.sh -- --start=look_tal`.
Kurze Rundgänge für Aufnahmen: `tools/autopilot/look_elysia_walk.json`, `look_tal_walk.json`.

## Regeln

| Thema | Regel |
|-------|-------|
| Raster | 16-px-Kacheln, 640×360, alles auf ganze Spielpixel. Pixel-Art wird nie gedreht oder frei skaliert. Wind schert in ganzen Pixeln, Wasser animiert in Stufen (8 fps). |
| Licht | Hauptlicht von oben links. Schatten fallen nach rechts unten und liegen als dunklere Palettenstufe am Boden, nicht als schwarzes Alpha. |
| Paletten | Pro Material eine Rampe mit 4 bis 6 Stufen, farbverschoben: Schatten kühler, Lichter wärmer (`tools/art/pixelart.py`, `STYLES`). Keine Farben außerhalb der Rampen im Boden. |
| Dithering | Nur in schmalen Übergangsbändern (Kontrastparameter in `quantize`), nicht als Flächenrauschen. |
| Umrisse | Dunkler, farbiger Umriss pro Stil (Elysia violett-dunkel, Tal fast schwarz), nie reines Schwarz. Innere Kanten eine Rampenstufe dunkler. |
| Figuren | 24×32-Rahmen, Füße auf y = 30, Chibi-Proportionen (Kopf etwa 40 Prozent). 8 Richtungen, West gespiegelt. Idle 2, Gehen 4, Laufen 4, Sitzen 1 Bild. Kontaktschatten unter den Füßen. |
| Tiefe | Props sortieren nach ihrer Fußlinie. Flaches (Seerosen) liegt auf Ebene −5, Boden auf −10, Himmel auf −20. |
| Elysia | Satt, warm, freundlich: kräftiges Grün, Blütenfarben in Gruppen, heller Himmel, Wolken unter der Insel, Blüten und Lichtpunkte in der Luft, Wolkenschatten über dem Boden, sanfter Bloom. Bewusst „zu perfekt“. |
| Tal | Entsättigt, kühl, Abend im Regen: `CanvasModulate` dunkelt die Welt, warmes Licht nur aus Fenstern und Laterne, Regen und Ringe auf Wasser und Pfützen, starke Vignette. Das Haus ist der einzige warme Ort. |

## Werkzeuge

| Werkzeug | Erzeugt |
|----------|---------|
| `tools/art/layout_look_maps.py elysia\|tal --write` | `[map]`-Block der Look-Karten aus Formen (optional, Karten sind auch von Hand editierbar) |
| `tools/art/make_sprites.py [--sheet x.png]` | Props, Wolken, Partikel und `assets/generated/props/catalog.json` |
| `tools/art/make_character.py [--preview x.png]` | `assets/generated/characters/player.png` |
| `tools/art/bake_ground.py <karte> [--preview-dir d]` | gebackener Boden und Wassermaske laut `[meta]` (nach `make_sprites.py`, wegen der Prop-Schatten) |
| `tools/audio/make_ambience.py` | Regen-, Garten- und Wasser-Loops (nahtlos) |

Installation: `.venv/bin/pip install -r requirements-art.txt`. Alle Generatoren sind
deterministisch (feste Seeds). Nach Änderungen an Karten oder Generatoren: erzeugen, `tools/check.sh`,
Ergebnis mit `tools/capture.sh` ansehen.

## Fragen an den Projektinhaber

1. Trifft die Richtung (Elysia hell und satt, Tal dunkel und warm beleuchtet) dein Bild?
2. Was stört am meisten: Figur, Boden, Bäume, Haus, Licht, Farben oder Bewegung?
3. Passt die Figurengröße im Verhältnis zu Bäumen und Haus?
4. Soll die Grafik so weit sein, bevor wir mit Phase 2 (Systeme) weitermachen, oder reicht die Richtung?

## Nächste Schritte (nicht Teil dieser Phase)

- Handgepixelte Schlüssel-Assets: Spielfigur mit Animationen, Mira, Haus, Baumarten.
- Terrain-Übergänge als Tileset statt gebacken, sobald Karten wachsen (Speicher, Iteration).
- Reflexionen (Game Bible: Wasser spiegelt alles außer dem Protagonisten), Tag-Nacht-Licht, Innenräume.
- Performance der Look-Szenen auf Zielhardware messen (KNOWN_ISSUES #12).
