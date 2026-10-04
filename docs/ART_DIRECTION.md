# Art Direction (Look-Prototyp)

Arbeitsstand der Look-Phase vor Phase 2 (ADR-017). Produktvision: Game Bible, Abschnitt 36
„Moderne handgezeichnete Pixel-Art … hochwertiges Licht, Wetter, Partikel, Wasser, Wind“.
Zielbild laut Rückmeldung des Projektinhabers: moderne Top-Down-Pixel-Art; Maßstab sind alle
gesendeten Referenzbilder (drei Runden), nicht nur Referenzbild 2.
Die Referenzbilder liegen bewusst nicht im Repo (fremdes Urheberrecht).

**Ehrliche Grenze:** Alles hier ist prozedural erzeugt. Es ist deutlich besser als die Grey-Box,
erreicht aber nicht die Qualität handgezeichneter Referenzen. Für finale Grafik braucht es
handgepixelte Schlüssel-Assets (Figuren, Haus, Bäume), siehe „Nächste Schritte“.

## Ansehen

Startmenü → **Look: Elysia-Garten**, **Look: Tal im Regen** oder **Look: Wald bei Nacht**, oder direkt:
`tools/godot.sh -- --start=look_elysia` · `--start=look_tal` · `--start=look_wald`.
Kurze Rundgänge für Aufnahmen: `tools/autopilot/look_elysia_walk.json` (zum Weltenbaum),
`look_elysia_edge.json` (Inselkante mit Wasserfall), `look_tal_walk.json`, `look_wald_walk.json`.

## Regeln

| Thema | Regel |
|-------|-------|
| Raster | 16-px-Kacheln, 640×360, alles auf ganze Spielpixel. Pixel-Art wird nie gedreht oder frei skaliert. Wind schert in ganzen Pixeln, Wasser animiert in Stufen (8 fps). |
| Licht | Hauptlicht von oben links. Schatten fallen nach rechts unten und liegen als dunklere Palettenstufe am Boden, nicht als schwarzes Alpha. |
| Paletten | Pro Material eine Rampe mit 4 bis 6 Stufen, farbverschoben: Schatten kühler, Lichter wärmer (`tools/art/pixelart.py`, `STYLES`). Keine Farben außerhalb der Rampen im Boden. |
| Dithering | Nur in schmalen Übergangsbändern (Kontrastparameter in `quantize`), nicht als Flächenrauschen. |
| Umrisse | Dunkler, farbiger Umriss pro Stil (Elysia violett-dunkel, Tal fast schwarz), nie reines Schwarz. Innere Kanten eine Rampenstufe dunkler. |
| Figuren | 24×32-Rahmen, Füße auf y = 30, Chibi-Proportionen (Kopf etwa 40 Prozent). 8 Richtungen, West gespiegelt. Idle 2, Gehen 4, Laufen 4, Sitzen 1, Umschauen 4 Bilder (blinzeln, links, rechts, blinzeln; ADR-033). Kontaktschatten unter den Füßen. Flache 4-Ton-Schattierung, Haar mit Glanzbogen, Augen mit Lichtpunkt, innere Konturen zwischen Teilen. Designs in `make_character.py` (Spieler, Mira, Elysianer). |
| Klippen | Geschichtete Steinplatten (breite flache Zellen), Licht oben, dunkler zum Fuß. Gewölbte Graskappe mit heller Kante und Ranken, Schatten unter der Kappe und am Fuß. Wasserfälle mit Streifen, Gischt und Spritzpartikeln. |
| Dichte | Kleinvegetation per Streu-Regeln im `[meta]`-Block (`scatter`): Grasbüschel, Wildblumen, Kiesel, Zweige, Laub und Pilze unter Bäumen, Schilf am Wasser, Sträucher am Waldrand, Gras, das in Wegränder wächst. Deterministisch, ohne Kollision, mit Wind. |
| Natürlichkeit | Grasflächen mit trockenen und saftigen Flecken, kahle Stellen (Tal, Wald), feuchte Erde am Ufer, Kiesel im flachen Wasser, Waldränder aus einzelnen Kronen mit Stämmen, Bäume mit unregelmäßigen Kronen, schiefen Stämmen und drei Größen. |
| Spiegelungen | Props und Figuren nahe am Wasser spiegeln sich gewellt und blass im Wasser. In Elysia nie der Protagonist (Game Bible §9); im Tal spiegelt er sich in Wasser und Pfützen (ADR-031). |
| Tierleben | Vogelschwärme mit Schatten am Boden (Wald: Fledermäuse), Koi im heiligen Becken, Fischschatten in Bach und Teich, Libellen über dem Wasser. |
| Leuchten | Leuchtende Teile (Pilze, Kristalle, Blätter, Lichthöfe, Lichtstrahl) sind eigene Emissive-Ebenen mit `render_mode unshaded`: richtig verdeckt, aber nicht von Nacht-Abdunklung oder Licht gedimmt. Echte `PointLight2D` nur für größere Lichtquellen. |
| Tiefe | Props sortieren nach ihrer Fußlinie. Flaches (Seerosen) liegt auf Ebene −5, Boden auf −10, Himmel auf −20. |
| Laub | Kronen und Hecken aus einzelnen Blattbüscheln (`render_foliage`): flache Tonstufen, Licht oben links, dunkle Kante unten rechts je Büschel. Kein Rauschen. |
| Elysia | Game Bible §9: perfekte Symmetrie (Karte, Boden und Streu spiegeln sich pixelgenau um Spalte 32; nur Stein und Riss haben keinen Zwilling), makellose Architektur, leuchtende Pflanzen, gemähte Rasenstreifen, kein Schmutz. Bewegung ohne Zufall: Pflanzen im Gleichtakt, immer derselbe Vogelschwarm, gespiegelte Schmetterlinge und Libellen, kreisende Koi, wiederkehrende Wolkenschatten. Grün mit Türkisstich, violette Schatten, warme Lichter. Bunte Bäume (grün, blau, lila, rosa), weißer Marmor, türkises Wasser, leuchtende Kristalle und Blumen. Mittelpunkt: Weltenbaum mit Hängeblüten im symmetrischen Marmorbecken. Terrassen mit Felskanten, Wasserfall von der Insel in die Wolken. Bewusst „zu perfekt“. |
| Tal | Ankunft an einem Regentag mit Wind (Böen, wehende Blätter, knarrendes Holz), später Abend und Nacht über die Bank. Krumme Bäume mit totem Ast, kaputte Zaunstücke: ungepflegt, aber nicht trostlos (Risiko 10). Nachts tiefes Blau und Violett, warmes Licht nur aus Fenstern und Laterne, Regen und Ringe auf Wasser und Pfützen. Das Haus ist der einzige warme Ort; Mira steht an der Tür, daneben ein Gemüsebeet, im Süden fällt der Bach über eine Geländestufe. |
| Wald | Nacht im Wald (Akt III): fast schwarzes Türkis, violetter Fels, Licht kommt nur von leuchtenden Dingen. Lichtung mit Lichtstrahl und aufsteigenden Funken, biolumineszente blaue Bäume, Leuchtpilze in Cyan, Violett und Rosa, magentafarbene Kristalle, Glühwürmchen, Felsstufe mit Wasserfall, Baumstammbrücke. |

## Phase 3: UI-Bogen, Licht, Ton

| Thema | Regel |
|-------|-------|
| UI Elysia | Goldrahmen mit Edelsteinecken, warme Creme-Schrift, violett-dunkler Grund. HUD oben links (Level, XP, Gold), Quest oben rechts mit hüpfendem Marker, Popups laut und übertrieben. Seltenheit immer als Wort. |
| UI Real | Keine Rahmen, warmes Grau (ruhig, nicht düster), kein HUD. Aufgehobenes erscheint als eine leise Zeile unten links. |
| Startbild | Vor dem Übertritt der Schein-Titel „Elysia“ (Gold, Kristall, symmetrisch), danach „REAL“ über einem Abendtal (ADR-030). |
| Übergang | HUD zerfällt einzeln (Gold, XP, Level), Musik läuft als Bandstopp aus, Stille, schwarz, Regen. Ohne Flackern und Wackeln, wenn der Spieler es abgeschaltet hat. |
| Tageslicht Tal | Regentag (hell, entsättigt, flach), Abend (warmes Orange, kein Regen, Bach und leise Musik), Nacht (kühles Blau, Lampen warm). Elysia hat kein Tageslicht. |
| Musik | Ein Motiv (Stufen 3-5-6-5-3-2) in allen Welten: Elysia perfekt, Tal menschlich, Wald versteckt, Antreiber hetzend. Elysias Loop schrumpft von 8 auf 4 und 2 Takte (ADR-032). |

## Referenzen

Der Projektinhaber hat drei Runden Referenzbilder geschickt (nicht im Repo, fremdes Urheberrecht).
Übernommen werden Techniken, keine Motive oder Figuren:

| Runde | Was übernommen wurde |
|-------|----------------------|
| 1 (u. a. „Bild 2“: moderne Top-Down-Szene) | gemalte Böden ohne Raster, Klippe über Wolken, Licht, Wetter, Wasser, Wind |
| 2 (Stadt mit heiligem Baum, schwebende Inseln, Nachtwald, Panorama, Kristall-Klippe) | Paletten mit Türkis und Violett, bunte Baumarten, Laub aus Büscheln, Wahrzeichen im Zentrum, Höhenstufen, Wasserfälle, leuchtende Kristalle und Pflanzen, Nachtpalette in Blau und Violett |
| Rückmeldung nach Runde 3: „mehr ins Detail, Welt verdichten, natürlicher, Realismus auf gewisse Art“ | Streu-System, natürliche Bodenvariation, Spiegelungen, Tierleben, realistischere Bäume und Waldränder, Hausdetails |
| 3 (violette Nacht mit leuchtenden Bäumen, Waldfluss mit Pilzen, gemütlicher Hof mit Kirschbäumen) | geschichtete Klippen mit Graskappe und Ranken, Gischt, Grasbüschel, Wassergrund, Gemüsebeet, Schwebeinseln und Regenbogen, Leuchtpilze, Glühwürmchen, dritte Szene „Wald bei Nacht“, detailliertere Figuren |

## Werkzeuge

| Werkzeug | Erzeugt |
|----------|---------|
| `tools/art/layout_look_maps.py elysia\|tal\|wald --write` | `[map]`-Block der Look-Karten aus Formen (optional, Karten sind auch von Hand editierbar) |
| `tools/art/make_sprites.py [--sheet x.png]` | Props, Wolken, Partikel und `assets/generated/props/catalog.json` (entfernt nicht mehr katalogisierte Sprites) |
| `tools/art/make_character.py [--preview x.png]` | `assets/generated/characters/{player,mira,elysian}.png` |
| `tools/art/bake_ground.py <karte> [--preview-dir d]` | gebackener Boden und Wassermaske laut `[meta]` (nach `make_sprites.py`, wegen der Prop-Schatten) |
| `tools/audio/make_ambience.py` | Regen-, Garten-, Wasser-, Nachtwald-, Wind-, Regen-mit-Wind- und Abend-Loops (nahtlos) |
| `tools/audio/make_music.py [--only elysia]` | Musik-Loops Elysia (drei Längen), Tal, Wald, Antreiber (nahtlos, gemeinsames Motiv) |
| `tools/art/make_title.py [--preview x.png]` | Startbilder: symmetrische Insel, Wasserfall, Logos „Elysia“ und „REAL“, Abendtal |
| `tools/art/make_ui.py [--preview x.png]` | Elysia-Rahmen, Münze, Funkeln, Riss, Truhe, Stein |

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
- Innenräume; handgemalte Tagespalette fürs Tal (KNOWN_ISSUES #30).
- Performance der Look-Szenen auf Zielhardware messen (KNOWN_ISSUES #12).
