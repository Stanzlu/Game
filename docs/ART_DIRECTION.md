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
| Raster | 16-px-Kacheln, 640×360, alles auf ganze Spielpixel. Pixel-Art wird nie gedreht oder frei skaliert; nur das ganze Weltbild darf um den Zoom der Szene wachsen und wird dann scharf abgetastet (ADR-043). Wind schert in ganzen Pixeln, Wasser animiert in Stufen (8 fps). |
| Licht | Hauptlicht von oben links. Schatten fallen nach rechts unten und liegen als dunklere Palettenstufe am Boden, nicht als schwarzes Alpha. |
| Paletten | Pro Material eine Rampe mit 4 bis 6 Stufen, farbverschoben: Schatten kühler, Lichter wärmer (`tools/art/pixelart.py`, `STYLES`). Keine Farben außerhalb der Rampen im Boden. |
| Dithering | Nur in schmalen Übergangsbändern (Kontrastparameter in `quantize`), nicht als Flächenrauschen. |
| Umrisse | Dunkler, farbiger Umriss pro Stil (Elysia violett-dunkel, Tal fast schwarz), nie reines Schwarz. Innere Kanten eine Rampenstufe dunkler. |
| Figuren | 24×32-Rahmen, Füße auf y = 30, Chibi-Proportionen (Kopf etwa 40 Prozent). 8 Richtungen, West gespiegelt. Idle 2, Gehen 4, Laufen 4, Sitzen 1, Umschauen 4 Bilder (blinzeln, links, rechts, blinzeln; ADR-033). Kontaktschatten unter den Füßen. Flache 4-Ton-Schattierung, Haar mit Glanzbogen, Augen mit Lichtpunkt, innere Konturen zwischen Teilen. Designs in `make_character.py` (Spieler, Mira, Elysianer). |
| Klippen | Geschichtete Steinplatten (breite flache Zellen), Licht oben, dunkler zum Fuß. Gewölbte Graskappe mit heller Kante und Ranken, Schatten unter der Kappe und am Fuß. Wasserfälle mit Streifen, Gischt und Spritzpartikeln. |
| Dichte | Kleinvegetation per Streu-Regeln im `[meta]`-Block (`scatter`): Grasbüschel, Wildblumen, Kiesel, Zweige, Laub und Pilze unter Bäumen, Schilf am Wasser, Sträucher am Waldrand, Gras, das in Wegränder wächst. Deterministisch, ohne Kollision, mit Wind. |
| Natürlichkeit | Grasflächen mit trockenen und saftigen Flecken, kahle Stellen (Tal, Wald), feuchte Erde am Ufer, Kiesel im flachen Wasser, Waldränder aus einzelnen Kronen mit Stämmen, Bäume mit unregelmäßigen Kronen, schiefen Stämmen und drei Größen. |
| Spiegelungen | Props und Figuren nahe am Wasser spiegeln sich gewellt und blass im Wasser. In Elysia nie der Protagonist (Game Bible §9); in der Wirklichkeit (Tal, Wald) spiegelt er sich in Wasser und Pfützen (ADR-031). |
| Tierleben | Vogelschwärme mit Schatten am Boden (Wald: Fledermäuse), Koi im heiligen Becken, Fischschatten in Bach und Teich, Libellen über dem Wasser. |
| Leuchten | Leuchtende Teile (Pilze, Kristalle, Blätter, Lichthöfe, Lichtstrahl) sind eigene Emissive-Ebenen mit `render_mode unshaded`: richtig verdeckt, aber nicht von Nacht-Abdunklung oder Licht gedimmt. Echte `PointLight2D` nur für größere Lichtquellen. |
| Tiefe | Props sortieren nach ihrer Fußlinie. Flaches (Seerosen) liegt auf Ebene −5, Boden auf −10, Himmel und Berge auf −20, Kronen im Vordergrund auf 40. |
| Laub | Kronen und Hecken aus einzelnen Blattbüscheln (`render_foliage`): flache Tonstufen, Licht oben links, dunkle Kante unten rechts je Büschel. Kein Rauschen. |
| Elysia | Game Bible §9: perfekte Symmetrie (Karte, Boden und Streu spiegeln sich pixelgenau um Spalte 32; nur Stein und Riss haben keinen Zwilling), makellose Architektur, leuchtende Pflanzen, gemähte Rasenstreifen, kein Schmutz. Bewegung ohne Zufall: Pflanzen im Gleichtakt, immer derselbe Vogelschwarm, gespiegelte Schmetterlinge und Libellen, kreisende Koi, wiederkehrende Wolkenschatten. Grün mit Türkisstich, violette Schatten, warme Lichter. Bunte Bäume (grün, blau, lila, rosa), weißer Marmor, türkises Wasser, leuchtende Kristalle und Blumen. Mittelpunkt: Weltenbaum mit Hängeblüten im symmetrischen Marmorbecken. Terrassen mit Felskanten, Wasserfall von der Insel in die Wolken. Bewusst „zu perfekt“. |
| Tal | Wie echtes Land (Playtest 05.10.: „natürlicher, wie in der echten Welt“), gemalt mit Wärme (ADR-041): ausgefranster Waldrand mit Buchten, eine Felsstufe, die kommt und geht, ein mäandernder Bach wechselnder Breite mit Kolk, ein Trampelpfad statt einer Straße, Bäume in gemischten Gruppen, Felsen in Gruppen. Nur der Hof ist gerade, den haben Menschen gebaut. Farben: leuchtendes Saft- und Wiesengrün mit gelbgrünen Lichtern und kühlen blaugrünen Schatten, Ocker-Erde, ein klarer türkiser Bach, honigfarbenes Holz, ein moosgrünes Schieferdach. Der Regen bleibt (Ankunft), aber schön: kühles Licht, nasses Glänzen, keine Grauschicht. Abend golden mit violetten Schatten, ziehenden Wolkenschatten und schrägen Lichtstrahlen von links oben; Nacht dunkelblau. Wind läuft in breiten Wellen als heller Schimmer durch Gras und Pflanzen. Frösche am Ufer, die weghüpfen. Krumme Bäume, kaputte Zaunstücke: ungepflegt, aber nie trostlos (Risiko 10). |
| Haus | Eine Blockhütte, die warm werden will: honigfarbene Balken, Patchwork-Decke, Flickenteppich in Rot, Ocker und Indigo, Kräuterbündel unter dem Balken, eine Pflanze am Fenster, ein Kupferkessel am Kamin, der dampft, wenn das Feuer brennt; Staub, der im Licht schwebt. Kalt blaugrau, mit Feuer bernsteinfarben. |
| Figuren der Wirklichkeit | Spielfigur, Mira, Kind und Antreiber in weicheren Farben: dunkle Töne angehoben und angewärmt, warmbraune statt fast schwarzer Umrisse. Elysianer und Gastwirt bleiben hart und strahlend. |
| Wald | Ein echter Wald bei Nacht (Akt III; Playtest 05.10.: „natürlicher, wie in der echten Welt“). Mondlicht statt Fantasy-Leuchten: tiefe Blaugrün-Töne, Schiefer-Fels, dunkles Wasser. Was leuchtet, leuchtet auch in Wirklichkeit: die weiße Rinde der Birken im Mondlicht, grünes Foxfire an morschem Holz, Glühwürmchen. Dazu Hallimasch und Fliegenpilze, bemooste Felsen mit Tau, eine Lichtung mit Mondstrahl, Felsstufe mit Wasserfall, Baumstammbrücke, ausgefranster Waldrand. |

## Phase 3: UI-Bogen, Licht, Ton

| Thema | Regel |
|-------|-------|
| UI Elysia | Goldrahmen mit Edelsteinecken, warme Creme-Schrift, violett-dunkler Grund. HUD oben links (Level, XP, Gold), Quest oben rechts mit hüpfendem Marker, Popups laut und übertrieben. Seltenheit immer als Wort. |
| UI Real | Keine Rahmen, warmes Grau (ruhig, nicht düster), kein HUD. Aufgehobenes erscheint als eine leise Zeile unten links. |
| Startbild | Vor dem Übertritt der Schein-Titel „Elysia“ (Gold, Kristall, symmetrisch), danach der wahre Titel „Nach Elysia“ über einem Abendtal: dieselben Buchstaben, ungeschmückt, mit Riss, und statt des Kristalls ein Keimling (ADR-030, ADR-035). |
| Übergang | HUD zerfällt einzeln (Gold, XP, Level), Musik läuft als Bandstopp aus, Stille, schwarz, Regen. Ohne Flackern und Wackeln, wenn der Spieler es abgeschaltet hat. |
| Tageslicht Tal | Regentag (kühl, nass glänzend, Grün bleibt satt), Abend (golden, violette Schatten, Wolkenschatten, Lichtstrahlen, kein Regen, Bach und Klavier), Nacht (kühles Blau, Lampen warm). Elysia hat kein Tageslicht. |
| Musik | Ein Motiv (Stufen 3-5-6-5-3-2) in allen Welten: Elysia perfekt, Tal menschlich (weiches Klavier mit einer Antwort, die heimkommt: 2-3-5-3-2-1; Gitarre, Fläche), Wald versteckt, Antreiber hetzend. Das Kind in Elysia summt es. Elysias Loop schrumpft von 8 auf 4 und 2 Takte (ADR-032). |

## Tiefen-Bogen (ADR-043)

Elysia ist ein Bild, die Wirklichkeit ein Raum. Je näher das Spiel der Wirklichkeit kommt, desto
mehr Tiefe hat es; das Mittel ist nie Perspektive, sondern Ebenen, Dunst und Kamera.

| Thema | Regel |
|-------|-------|
| Zoom | Elysia 1× (weit, flach, alles auf einmal). Tal, Haus, Weg 1,5×: die Figur näher, die Welt größer, als ginge sie über den Rand hinaus. |
| Dunst | Nur in der Wirklichkeit: nach oben im Bild leicht heller und in der Farbe der Luft (Regen kühl, Abend warm, Nacht blau). Nie so stark, dass Wege verschwimmen. |
| Hintergrund | Über der nördlichen Baumgrenze Himmel und drei Bergketten, die fernste mit Schnee. Flanken zur Sonne (links) warm, die anderen kühl wie der Himmel, flache Facetten statt Rauschen. Jede Kette verschwimmt am Fuß im Dunst. Im Regen fast ganz im Nebel, am Abend im Alpenglühen. Ferne Ketten bewegen sich kaum mit (Parallaxe 0,16 bis 0,48). |
| Vordergrund | Nur am südlichen Waldrand, dem Teil der Welt, der der Kamera am nächsten ist: große, fast schwarze Blätter in Kronen, größer als jedes Blatt am Boden. Sie gleiten 1,22-mal so schnell wie der Boden und verlassen das Bild zuerst. Nie über Wegen, die die Karte verlassen. |
| Schwenk | Einmal im Slice: Wenn Mira am Ende zu den Bergen schaut, schaut die Kamera mit (5 Sekunden, weich). Die Sonnenstrahlen treten dabei zurück, sie gehören zur Wiese. |

## Referenzen

Seit dem 06.10. ist das Referenzgefühl für die Wirklichkeit die warme, gemalte Natur klassischer
Anime-Filme (Wunsch des Projektinhabers: „mehr Aussehen und Vibe von Studio Ghibli, ohne die DNA zu
ändern“, ADR-041). Wie alle Referenzen nur als Orientierung für Stimmung und Qualität (Bible §60):
keine Figuren, Kreaturen, Motive oder Kompositionen, keine Werbung mit dem Namen. Elysia bleibt
bewusst Hochglanz-Fantasy.

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
| `tools/art/make_title.py [--preview x.png]` | Startbilder: symmetrische Insel, Wasserfall, Logos „Elysia“ und „Nach Elysia“, Abendtal |
| `tools/art/make_ui.py [--preview x.png]` | Elysia-Rahmen, Münze, Funkeln, Riss, Truhe, Stein |

Installation: `.venv/bin/pip install -r requirements-art.txt`. Alle Generatoren sind
deterministisch (feste Seeds). Nach Änderungen an Karten oder Generatoren: erzeugen, `tools/check.sh`,
Ergebnis mit `tools/capture.sh` ansehen.

## Fragen an den Projektinhaber

1. Wirkt Elysia unheimlich-perfekt (Symmetrie, Gleichtakt, kürzer werdende Musik) und trotzdem schön?
2. Lädt das Tal trotz Regen und Wind ein, oder wirkt es trostlos?
3. Verrät der Schein-Titel „Elysia“ zu wenig oder zu viel?
4. Was stört an Figur, Bäumen, Haus oder Licht am meisten, bevor Schlüssel-Assets von Hand entstehen?

## Nächste Schritte (nicht Teil dieser Phase)

- Handgepixelte Schlüssel-Assets: Spielfigur mit Animationen, Mira, Haus, Baumarten.
- Terrain-Übergänge als Tileset statt gebacken, sobald Karten wachsen (Speicher, Iteration).
- Innenräume; handgemalte Tagespalette fürs Tal (KNOWN_ISSUES #30).
- Performance der Look-Szenen auf Zielhardware messen (KNOWN_ISSUES #12).
