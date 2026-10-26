# Placeholder-Liste

Jede Datei, die nicht final ist, steht hier. Regeln: nur CC0 (Schriften OFL), Herkunft und Lizenz pro
Eintrag, Austausch ohne Logikänderung möglich (ADR-003).

## Im Projekt

| Datei | Art | Quelle | Lizenz | Ersatz geplant |
|-------|-----|--------|--------|----------------|
| `icon.svg` | App-Icon | selbst erstellt (Riss im Feld) | projekt-eigen | finales Icon nach Art-Direction |
| `assets/fonts/tiny5/Tiny5-Regular.ttf` | kleine Beschriftungen | google/fonts `ofl/tiny5` (Stefan Schmidt) | OFL 1.1 (`OFL.txt` liegt bei) | evtl. final; Entscheidung mit Art-Direction |
| `assets/fonts/jersey10/Jersey10-Regular.ttf` | Hauptschrift (ADR-026) | google/fonts `ofl/jersey10` (Soft Type) | OFL 1.1 (`OFL.txt` liegt bei) | evtl. final; Entscheidung mit Art-Direction |
| `assets/fonts/jersey15/Jersey15-Regular.ttf` | Titel, Belohnungen (ADR-026) | google/fonts `ofl/jersey15` (Soft Type) | OFL 1.1 (`OFL.txt` liegt bei) | evtl. final; Entscheidung mit Art-Direction |
| `core/boot/boot.tscn`, `ui/title/title_card.gd` | Startmenü mit zwei Titeln, Titelkarte | selbst erstellt | projekt-eigen | echter Titel-Flow (Phase 4) |
| `assets/placeholder/tiles/greybox_tiles.png` | 16-px-Tiles (Gras, Erde, Stein, Mauer, Wasser, Holz) | projekt-eigen, programmatisch | projekt-eigen | CC0-Tileset (Phase 3), später finale Art |
| `assets/placeholder/characters/{player,npc,antreiber}.png` | 16×24-Figuren, 8 Richtungen, Idle/Walk/Run/Sit | projekt-eigen, programmatisch | projekt-eigen | finales Figurendesign |
| `assets/generated/props/fx/frog.png` | Frosch am Ufer (sitzend, im Sprung) | projekt-eigen, programmatisch (`tools/art/make_sprites.py`) | projekt-eigen | finales Tierleben |
| `assets/placeholder/props/*.png` | Bank, Schild, Hebel, Tor, Grasbüschel, Pfütze, Spritzer, Busch, Flagge, Vogel, Staub | projekt-eigen, programmatisch | projekt-eigen | CC0 bzw. finale Art |
| `assets/placeholder/audio/*.wav` | Schritte je Oberfläche (Ferse und Ballen, je 8 Varianten), Rascheln, Platschen, UI (`ui_move`, `ui_confirm`, `ui_back`), Hebel, Tor. Sitzen, Vogel und Antreiber-Ruf sind seit 22.10. echte Klänge in `assets/generated/sfx` | projekt-eigen, synthetisch (`tools/placeholders/make_placeholders.py`) | projekt-eigen | CC0-Sounds bzw. Sounddesign |
| `assets/generated/maps/*_{ground,water,treeline}.png` | gebackene Böden, Wassermasken und Baumgrenzen der Karten | projekt-eigen, programmatisch (`tools/art/bake_ground.py`) | projekt-eigen | handgemalte Böden bzw. Tilesets (ADR-017) |
| `assets/generated/props/**` | Elysia: Weltenbaum, Bäume in vier Farben, Büsche, Marmorsäulen, Kristall, leuchtende Blumen, Riesenblumen, Formschnitt, Felsen, Brunnen, Laternen, Zäune, Bänke, Gischt, Wolken, Schwebeinseln, Regenbogen. Tal: Haus, Bäume, krumme Bäume, Kiefern, Zäune, kaputte Zaunstücke, Laterne, Fass, Holzstapel, Bank. Wald: Nachtbäume, Bäume mit Mondschimmer, Foxfire, Hallimasch, Fliegenpilze, bemooste Felsen, Farne, Baumstamm, Mondstrahl. Brückengeländer je Stil, Nebelbank, Partikel, Emissive-Ebenen, `catalog.json` | projekt-eigen, programmatisch (`tools/art/make_sprites.py`) | projekt-eigen | handgepixelte Assets |
| `assets/generated/characters/{player,mira,elysian,host,child,antreiber}.png` | Spielfigur, Mira, Elysianer, Gastwirt, Kind, Antreiber; 24×32, 8 Richtungen, mit Umschauen; Mira zusätzlich mit Arbeitspose am Netz | projekt-eigen, programmatisch (`tools/art/make_character.py`) | projekt-eigen | finales Figurendesign |
| `assets/generated/audio/garden_loop.wav` | Elysias Garten (Ambience-Loop, bewusst gleichförmig) | projekt-eigen, synthetisch (`tools/audio/make_ambience.py`) | projekt-eigen | Sounddesign |
| `assets/generated/audio/nature_*_bed.wav`, `assets/generated/sfx/nature_*.wav` | Wirklichkeit (ADR-034): Flächen Regen, Wind, Laub, Bach, Grillen; Einzelklänge Amsel, Rotkehlchen, Kohlmeise, Ringeltaube, Krähe, Waldkauz, ferner Hund, Tropfen, Zweig, Rascheln, Knarren | projekt-eigen, physikalisch modelliert (`tools/audio/make_nature.py`) | projekt-eigen | Field Recordings (CC0) bzw. Sounddesign |
| `assets/generated/music/*_loop.ogg` | Musik-Loops Elysia (8, 4 und 2 Takte), Tal (synthetisches Klavier und Gitarre, ADR-041), Nachtwald, Antreiber mit gemeinsamem Motiv | projekt-eigen, synthetisch (`tools/audio/make_music.py`) | projekt-eigen | Komposition und Aufnahme (Phase 6 bzw. nach Budget) |
| `assets/generated/ui/*.png` | Elysia-Rahmen mit Edelsteinen, Münze, Funkeln, Riss, Lichtstrahlen, Quest-Marker | projekt-eigen, prozedural (`tools/art/make_ui.py`) | projekt-eigen | handgezeichnete UI im Elysia-Stil |
| `assets/generated/items/*.png` | Item-Icons 16×16 (Kompliment, Stein, Samen, Ewiger Ruhm, Suppe, trockenes Holz, Kartoffel, Miras Stiefel, Rest Fisch, sehr kleiner Löffel) | projekt-eigen, Pixel für Pixel in `tools/art/make_ui.py` | projekt-eigen | handgezeichnete Icons |
| `assets/generated/title/*.png` | Startbilder: symmetrische Insel mit Weltenbaum, Wasserfall, Logos „Elysia“ und „Nach Elysia“, Abendtal | projekt-eigen, aus den Spiel-Sprites zusammengesetzt (`tools/art/make_title.py`) | projekt-eigen | Key-Art |
| `assets/generated/sfx/*.wav` | Menü-, Belohnungs-, Dialog- und Riss-Klänge (ADR-027), nach Lautheit je Gruppe normiert (ADR-047) | projekt-eigen, synthetisch (`tools/audio/make_sfx.py`, `loudness.py`) | projekt-eigen | Sounddesign |
| `assets/generated/objects/*.png` | Elysia-Truhe (zu/offen), Stein | projekt-eigen, prozedural (`tools/art/make_ui.py`) | projekt-eigen | handgezeichnete Objekte |
| `content/maps/look_{elysia,tal,wald}.txt` | Look-Karten Elysia-Garten, Tal, Wald bei Nacht | projekt-eigen | projekt-eigen | Prototypen; der Slice nutzt `elysia`, `tal`, `haus`, `antreiber_tal*` |
| `content/dialogue/{sandbox,valley,elysia,antreiber}/*.dialogue` | Prototyp-Texte (alle `[#ph]`) | Entwurf Claude | projekt-eigen | entfallen mit den Prototypen |
| `content/dialogue/slice/*.dialogue` | Texte des Vertical Slice (Elysia, Tal, Haus, Weg zum Schuppen; ADR-036) | Entwurf Claude in der Stimme der Bible | projekt-eigen | Writing-Pass nach dem Playtest |
| `assets/generated/props/{tal,haus}/*` (Slice) | Trittsteine flach/rund, umgestürzter Baum, Bruchbretter und neue Bretter der Brücke, Miras Plane, Feuerstelle, Netzgestell, Kartoffel, Ziege (mit Stiefel/Kartoffel), Stiefel, Wegweiser, Schuppen, Holzbündel, dunkles Haus; Innenraum: Raumhülle mit Kräuterbündeln und Fensterpflanze, Kamin kalt und brennend (drei Bilder, mit Kupferkessel und Dampf), Tisch, Bett, Regal (leer, mit Löffel, mit Stein, mit beidem), Teppich, Eimer, Katze (Fenster/schlafend); Elysia: Festtafel, goldener Schmetterling | projekt-eigen, programmatisch (`tools/art/slice_props.py`, `make_sprites.py`) | projekt-eigen | handgepixelte Assets |
| `assets/generated/maps/{tal,haus,antreiber_tal,antreiber_tal_bench}_ground.png` | gebackene Böden des Slice | projekt-eigen, programmatisch (`tools/art/layout_slice_maps.py`, `bake_ground.py`) | projekt-eigen | handgemalte Böden bzw. Tilesets |
| `assets/generated/sfx/{door_*,wood_drop,splash_fall,stone_wobble,fire_light,cat_meow_*,purr,sit,stand,bird,bark_*,goat_*,child_hum_*,frog_croak_*}.wav`, `assets/generated/audio/nature_{roof,fire}_bed.wav` | Tür, Klopfen, Holz, Sturz in den Bach, Kippelstein, Streichholz und Feuer, Katze (auch gedämpft durch die Tür) und Schnurren, Sitzen und Aufstehen, landender Vogel, Ruf des Antreibers (drei Stockschläge), Ziege, das summende Kind (das spätere Hauptmotiv), Frösche am Ufer; Regen aufs Dach, Kaminfeuer | projekt-eigen, synthetisch (`tools/audio/make_slice_sfx.py`, `make_nature.py`) | projekt-eigen | Field Recordings (CC0) bzw. Sounddesign |
| `icon.svg` | siehe oben | | | |

### Polish-Runde 2 (22.10.): neu oder neu erzeugt

Alles aus eigenen Generatoren (Python mit numpy; Godot-Seite nur Daten), ohne fremde Quelle.

| Datei | Änderung | Quelle | Lizenz |
|-------|----------|--------|--------|
| `assets/generated/sfx/{bark_0..2,bird,sit,stand,cat_meow_muffled,purr}.wav` (mit `.import`) | neu; `bark`, `bird` und `sit` ersetzen die Platzhalter gleichen Namens | `tools/audio/make_slice_sfx.py` | projekt-eigen |
| `assets/placeholder/audio/{sit,bird,bark_0..2}.wav` (mit `.import`) | entfernt, ersetzt durch die Klänge oben | – | – |
| `assets/generated/sfx/fire_crackle.wav` (mit `.import`) | entfernt (nie aufgerufen; das Feuer ist das Bett `nature_fire_bed`) | – | – |
| `assets/generated/sfx/*.wav` (alle Effekte außer den Naturklängen) | neu erzeugt, nach Lautheit je Gruppe normiert, gleiche Namen | `make_sfx.py`, `make_slice_sfx.py`, `loudness.py` | projekt-eigen |
| `assets/placeholder/audio/{footstep_*,rustle_*}.wav` | neu erzeugt: −19 LUFS, Spitzen höchstens −6 dBFS | `tools/placeholders/make_placeholders.py` | projekt-eigen |
| `assets/generated/characters/{player,mira,elysian,antreiber,child,host}.png` | neu erzeugt: Gehzyklus mit vier Bildern, Scheitel im Rahmen; `mira.png` 96×1536 mit Zustand „work“ | `tools/art/make_character.py` | projekt-eigen |
| `assets/generated/maps/{tal,antreiber_tal,antreiber_tal_bench,look_tal,look_wald}_ground.png` | neu gebacken: ruhigere Wiesen und Wege, Trampelpfad (Elysia bitgleich) | `tools/art/bake_ground.py`, `layout_slice_maps.py` | projekt-eigen |
| `assets/generated/props/fx/raindrop.png` | 1×5 → 1×8 px | `tools/art/make_sprites.py` | projekt-eigen |
| `assets/generated/props/haus/shell.png` | Fensterglas zeigt den Regentag, Seitenwände zweistufig | `tools/art/slice_props.py` | projekt-eigen |
| `assets/generated/props/elysia/inn_*.png`, `guest_book.png` (Akt I, A2) | Gasthaus zum Immer: Fassade, Hülle der Halle mit Fenstern, Regalen, Uhr und zwei Türen, Tresen, Tisch mit Hockern, Kamin (drei Bilder mit Leuchtebene), Bett, Zimmertür, Gästebuch auf dem Pult | projekt-eigen, programmatisch (`tools/art/akt1_props.py`) | projekt-eigen | handgepixelte Assets, Abnahme der Region |
| `assets/generated/maps/gasthaus_ground.png` | gebackener Boden des Gasthauses (Pflaster, Dielen in den Zimmern) | projekt-eigen, programmatisch (`tools/art/bake_ground.py`) | projekt-eigen | handgemalter Boden |
| `assets/generated/props/elysia/town_house_*.png`, `town_gate.png`, `stall_*.png`, `job_board.png`, `hall_front.png` (Akt I, A3) | Markt: drei Stadthäuser, Tor in der Südmauer, vier Stände, Auftragstafel, Fassade der Halle der Spiegel | projekt-eigen, programmatisch (`tools/art/akt1_props.py`) | projekt-eigen | handgepixelte Assets, Abnahme der Region |
| `assets/generated/characters/{baker,florist,tailor,merchant,musician,poet,gatekeeper}.png` | die sieben Rollen des Marktes (Laufbögen, 8 Richtungen) | projekt-eigen, programmatisch (`tools/art/make_character.py`) | projekt-eigen | Figurenentwurf von Hand |
| `assets/generated/maps/markt_ground.png` | gebackener Boden des Marktes (Pflaster, Marmor, Mauer) | projekt-eigen, programmatisch (`tools/art/bake_ground.py`) | projekt-eigen | handgemalter Boden |
| `assets/generated/audio/water_loop.wav` | Brunnenwasser (Ortsklang, Loop) | projekt-eigen, synthetisch (`tools/audio/make_ambience.py`) | projekt-eigen | Sounddesign |
| `assets/generated/props/elysia/hall_{shell,gate,mirror,front_open}.png`, `odd_leaf.png`, `odd_feather.png` (Akt I, A5) | Halle der Spiegel: Hülle mit Spiegelwänden und Türrahmen, Tor, großer Spiegel, Fassade mit offenen Türen, Blatt und Feder | projekt-eigen, programmatisch (`tools/art/akt1_props.py`) | projekt-eigen | handgepixelte Assets, Abnahme der Region |
| `assets/generated/characters/keeper.png` | Hallenwächter (Laufbögen, 8 Richtungen) | projekt-eigen, programmatisch (`tools/art/make_character.py`) | projekt-eigen | Figurenentwurf von Hand |
| `assets/generated/maps/spiegelhalle_ground.png` | gebackener Boden der Halle (Marmor) | projekt-eigen, programmatisch (`tools/art/bake_ground.py`) | projekt-eigen | handgemalter Boden |
| `assets/generated/props/elysia/bunting.png`, `assets/generated/characters/festmaster.png` (Akt I, A6) | Girlande für das Fest, die Festmeisterin (Laufbögen, 8 Richtungen) | projekt-eigen, programmatisch (`tools/art/akt1_props.py`, `tools/art/make_character.py`) | projekt-eigen | handgepixelte Assets, Figurenentwurf von Hand |
| `assets/generated/items/{item_loaf,item_trinket,curiosity_dry_leaf,curiosity_feather}.png` | Symbole für Brot, Glücksbringer, Blatt und Feder (16 × 16) | projekt-eigen, von Hand als Text (`tools/art/small/*.pix`, `pixelgrid.py`) | projekt-eigen | Symbole von Hand nachzeichnen |
| `assets/generated/fragments/fragment_{hallway,closed_door,empty_room}.png` (Akt I, A8) | die drei Bilder der Kind-Spur: Flur, geschlossene Tür, leeres Zimmer (je 16 × 16, auf 64 Pixel gezeigt) | projekt-eigen, von Hand als Text (`tools/art/small/fragment_*.pix`, `pixelgrid.py`) | projekt-eigen | Bilder von Hand nachzeichnen (Bible §15, Prüflinse Kind) |
| `assets/generated/props/tal/bl_{post,float,trap_stuck,trap_free,weir,stumps,glass,weight,dry_pebbles}.png` (Akt II, B3) | Bachlauf: Pfosten mit dem leeren Haken, Schwimmer im Schilf, die Reuse (verklemmt und frei), Wehr mit Hufabdrücken im Moos, zwei Stümpfe mit Brett, blaues Glas, Senkblei, Kiesel in der trockenen Rinne | projekt-eigen, programmatisch (`tools/art/akt2_props.py`) | projekt-eigen | handgepixelte Assets, Abnahme der Region |
| `assets/generated/maps/bachlauf_{ground,water}.png` | gebackener Boden des Bachlaufs (84 × 66 Zellen: Wiese, Pfad, Bach, Furten, Wehr) und seine Wassermaske | projekt-eigen, programmatisch (`tools/art/bake_ground.py`) | projekt-eigen | handgemalter Boden |
| `assets/generated/maps/tal_{ground,water}.png` | neu gebacken: die Hecke am Südrand des Tals öffnet sich zu einem Pfad am Bach (Akt II, B3) | projekt-eigen, programmatisch (`tools/art/bake_ground.py`) | projekt-eigen | handgemalter Boden |
| `assets/generated/items/curiosity_{blue_glass,lead_weight,comb}.png` (Akt II, B3) | Symbole für blaues Glas, Senkblei und den Kamm mit einem Zahn (16 × 16) | projekt-eigen, von Hand als Text (`tools/art/small/*.pix`, `pixelgrid.py`) | projekt-eigen | Symbole von Hand nachzeichnen |
| `assets/generated/fragments/fragment_{bank_table,dry_bed}.png` (Akt II, B3) | die zwei Spuren der Welt: Uferbrett auf zwei Stümpfen, trockene Rinne mit gleich gedrehten Kieseln (16 × 16; Akt II zeigt keine Bilder des Kindes, Brief O5; in der Wirklichkeit zeigt das HUD keine Karte) | projekt-eigen, von Hand als Text (`tools/art/small/fragment_*.pix`, `pixelgrid.py`) | projekt-eigen | Bilder von Hand nachzeichnen |
| `assets/generated/fragments/fragment_beam_herbs.png` (Akt II, B5) | die dritte Spur der Welt: zwei Kräuterbündel unter dem Balken im Haus (16 × 16; Akt II zeigt keine Bilder des Kindes, Brief O5; in der Wirklichkeit zeigt das HUD keine Karte) | projekt-eigen, von Hand als Text (`tools/art/small/fragment_beam_herbs.pix`, `pixelgrid.py`) | projekt-eigen | Bilder von Hand nachzeichnen |
| `assets/generated/props/haus/{stool,table_one}.png` (Akt II, B5) | der zweite Hocker am Feuer und der Tisch mit einem Hocker (aus der vorhandenen Tisch-Zeichnung) | projekt-eigen, programmatisch (`tools/art/akt2_props.py`, `slice_props.table`) | projekt-eigen | handgemalte Requisiten |
| `assets/generated/sfx/house_hum_0.wav` (Akt II, B5) | das Lied im Haus: die Antwortphrase des Talthemas, gesummt, im Raum gehallt (3,9 s, −20 LUFS) | projekt-eigen, programmatisch (`tools/audio/make_slice_sfx.py`, Phrase `make_music.ANSWER`) | projekt-eigen | echte Stimme oder Instrument |
| `content/audio/haus_abend.tres` | neue Soundscape-Definition für das Haus am Abend (Daten aus vorhandenen Betten) | von Hand | projekt-eigen |
| `content/audio/{tal_abend,tal_regentag,haus_feuer}.tres` | Pegel angepasst | von Hand | projekt-eigen |
| `content/audio/haus_morgen.tres` (Akt III, W1) | neue Soundscape-Definition für das Haus am Morgen danach: Feuer, ein Knarren, ferne Amsel und Rotkehlchen, ohne Grillen (Daten aus vorhandenen Betten und Einzelklängen) | von Hand | projekt-eigen |
| `content/audio/tal_morgen.tres` (Akt III, W1) | neue Soundscape-Definition für das Tal am Morgen danach: Wind, Laub, Bach, dichter Vogelchor, Tropfen vom Tau, ohne Grillen (Daten aus vorhandenen Betten und Einzelklängen) | von Hand | projekt-eigen |
| `assets/generated/props/tal/wd_{spruce_0,spruce_1,spruce_2,beech_0,beech_1,beech_2,stone_mossy_0,stone_mossy_1,cone,fern_0,fern_1,fern_2}.png` (Akt III, W2) | der hohe Wald des Waldwegs: Fichten und Buchen mit hoher Krone (der Pfad darunter bleibt lesbar), bemooste Steine, ein Zapfen unter der Fichte, Farn | projekt-eigen, programmatisch (`tools/art/akt3_props.py`) | projekt-eigen | handgepixelte Assets, Abnahme der Region |
| `assets/generated/props/tal/wd_{hut,rest_log,rest_cold,rest_lit,rest_lit_emit,marker_arrow,marker_tally,marker_plain,marker_blank}.png` (Akt III, W2) | die Hütte im Westen (Dach grün von Moos), der Rastplatz (Stamm, Feuerring mit Kessel kalt und mit Glut samt gebackenem Glühen, kein Licht) und die sechs Bretter des Antreibers in vier Bildern (Pfeil, Striche, schlicht, leer) | projekt-eigen, programmatisch (`tools/art/akt3_props.py`) | projekt-eigen | handgepixelte Assets, Abnahme der Region |
| `assets/generated/maps/waldweg_{ground,water}.png` (Akt III, W2) | gebackener Boden des Waldwegs (100 × 62 Zellen, Klasse M: Hochwald, Pfad am Westufer, Bach, Hohlweg, Lichtung der Hütte) und seine Wassermaske | projekt-eigen, programmatisch (`tools/art/bake_ground.py`, Layout `tools/art/layout_akt3_maps.py`) | projekt-eigen | handgemalter Boden |
| `assets/generated/maps/bachlauf_{ground,water}.png` | neu gebacken: der Süden des Bachlaufs bekommt eine Lücke in der Hecke und einen Pfad zur Tür in den Wald (Akt III, W2) | projekt-eigen, programmatisch (`tools/art/bake_ground.py`) | projekt-eigen | handgemalter Boden |
| `assets/generated/items/curiosity_{cone,chalk_stub}.png` (Akt III, W2) | Symbole für den Zapfen und den Stummel rote Kreide (16 × 16) | projekt-eigen, von Hand als Text (`tools/art/small/*.pix`, `pixelgrid.py`) | projekt-eigen | Symbole von Hand nachzeichnen |
| `assets/generated/fragments/fragment_hang_steps.png` (Akt III, W2) | die Spur der Welt im Hohlweg: in die Erde gestochene Stufen (16 × 16; kein Bild des Kindes, Brief O5; in der Wirklichkeit zeigt das HUD keine Karte) | projekt-eigen, von Hand als Text (`tools/art/small/fragment_hang_steps.pix`, `pixelgrid.py`) | projekt-eigen | Bilder von Hand nachzeichnen |

Noch Platzhalter ohne Lautheitsnormierung: `gate`, `lever`, `splash` und `ui_move`, `ui_confirm`, `ui_back`
unter `assets/placeholder/audio` (Spitze −6 dBFS; KNOWN_ISSUES #65).

## Beschaffungsliste für den Slice

Kandidaten aus CC0-Quellen. Lizenz bei jedem Download erneut prüfen und hier eintragen.
Die Seiten sind in der Cloud-Umgebung derzeit blockiert (KNOWN_ISSUES #4).

| Beat | Bedarf | Kandidat | Quelle |
|------|--------|----------|--------|
| Alle | 16-px-Tileset Außenbereich (Gras, Wege, Wasser, Häuser) | Kenney „Tiny Town“ | kenney.nl (CC0) |
| Alle | Figuren-Sprites (Spieler, NPCs, Mira) | Kenney „Roguelike Characters“ oder „Tiny Dungeon“ | kenney.nl (CC0) |
| Tal, Haus | Innenräume, Möbel, Feuerstelle | Kenney „Roguelike Indoors“ bzw. „Tiny Dungeon“ | kenney.nl (CC0) |
| Elysia | UI-Rahmen, Ornamente, Icons für Loot | Kenney „UI Pack (RPG Expansion)“ | kenney.nl (CC0) |
| Alle | Schritte, Türen, Münzen, Truhen | Kenney „RPG Audio“ | kenney.nl (CC0) |
| Elysia | UI-Klicks, Belohnungs-Jingles | Kenney „Interface Sounds“, „Music Jingles“ | kenney.nl (CC0) |
| Tal | Regen, Wind, Vögel (Loops) | CC0-Ambience | opengameart.org / freesound.org (Filter CC0) |
| Elysia | perfekter Musik-Loop | CC0-Track oder eigene Komposition | opengameart.org (Filter CC0) |
| Haus | warmer, ruhiger Track | CC0-Track oder eigene Komposition | opengameart.org (Filter CC0) |
| Antreiber | treibender Loop | CC0-Track oder eigene Komposition | opengameart.org (Filter CC0) |

Hinweis: Kenney-Figuren sind 16×16 px. Das geplante Figurenraster (ADR-007) ist größer. Für den Slice ist
das in Ordnung, die finalen Figuren entstehen mit der Art-Produktion.

## Programmatische Placeholder

Alle Grey-Box-Dateien unter `assets/placeholder/` erzeugt `python3 tools/placeholders/make_placeholders.py`
reproduzierbar (ADR-014). Wer eine Datei ersetzt, behält Name und Format bei. Klänge werden über
`<präfix>_<n>.wav` gefunden, Figuren-Sheets über das Layout in `entities/character/character_sheet.gd`.
