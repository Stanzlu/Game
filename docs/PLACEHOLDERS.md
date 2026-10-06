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
| `assets/placeholder/props/*.png` | Bank, Schild, Hebel, Tor, Grasbüschel, Pfütze, Spritzer, Busch, Flagge, Vogel, Staub | projekt-eigen, programmatisch | projekt-eigen | CC0 bzw. finale Art |
| `assets/placeholder/audio/*.wav` | Schritte je Oberfläche, Rascheln, Platschen, UI, Hebel, Tor, Sitzen, Vogel, Antreiber-Murmeln | projekt-eigen, synthetisch | projekt-eigen | CC0-Sounds bzw. Sounddesign |
| `assets/generated/maps/look_*_{ground,water}.png` | gebackene Böden und Wassermasken der Look-Karten | projekt-eigen, programmatisch (`tools/art/bake_ground.py`) | projekt-eigen | handgemalte Böden bzw. Tilesets (ADR-017) |
| `assets/generated/props/**` | Elysia: Weltenbaum, Bäume in vier Farben, Büsche, Marmorsäulen, Kristall, leuchtende Blumen, Riesenblumen, Formschnitt, Felsen, Brunnen, Laternen, Zäune, Bänke, Gischt, Wolken, Schwebeinseln, Regenbogen. Tal: Haus, Bäume, krumme Bäume, Kiefern, Zäune, kaputte Zaunstücke, Laterne, Fass, Holzstapel, Bank. Wald: Nachtbäume, Birken, Foxfire, Hallimasch, Fliegenpilze, bemooste Felsen, Farne, Baumstamm, Mondstrahl. Brückengeländer je Stil, Nebelbank, Partikel, Emissive-Ebenen, `catalog.json` | projekt-eigen, programmatisch (`tools/art/make_sprites.py`) | projekt-eigen | handgepixelte Assets |
| `assets/generated/characters/{player,mira,elysian,host,child,antreiber}.png` | Spielfigur, Mira, Elysianer, Gastwirt, Kind, Antreiber; 24×32, 8 Richtungen, mit Umschauen | projekt-eigen, programmatisch (`tools/art/make_character.py`) | projekt-eigen | finales Figurendesign |
| `assets/generated/audio/garden_loop.wav` | Elysias Garten (Ambience-Loop, bewusst gleichförmig) | projekt-eigen, synthetisch (`tools/audio/make_ambience.py`) | projekt-eigen | Sounddesign |
| `assets/generated/audio/nature_*_bed.wav`, `assets/generated/sfx/nature_*.wav` | Wirklichkeit (ADR-034): Flächen Regen, Wind, Laub, Bach, Grillen; Einzelklänge Amsel, Rotkehlchen, Kohlmeise, Ringeltaube, Krähe, Waldkauz, ferner Hund, Tropfen, Zweig, Rascheln, Knarren | projekt-eigen, physikalisch modelliert (`tools/audio/make_nature.py`) | projekt-eigen | Field Recordings (CC0) bzw. Sounddesign |
| `assets/generated/music/*_loop.wav` | Musik-Loops Elysia (8, 4 und 2 Takte), Tal, Nachtwald, Antreiber mit gemeinsamem Motiv | projekt-eigen, synthetisch (`tools/audio/make_music.py`) | projekt-eigen | Komposition und Aufnahme (Phase 6 bzw. nach Budget) |
| `assets/generated/ui/*.png` | Elysia-Rahmen mit Edelsteinen, Münze, Funkeln, Riss, Lichtstrahlen, Quest-Marker | projekt-eigen, prozedural (`tools/art/make_ui.py`) | projekt-eigen | handgezeichnete UI im Elysia-Stil |
| `assets/generated/items/*.png` | Item-Icons 16×16 (Kompliment, Stein, Samen, Ewiger Ruhm, Suppe, trockenes Holz, Kartoffel, Miras Stiefel, Rest Fisch, sehr kleiner Löffel) | projekt-eigen, Pixel für Pixel in `tools/art/make_ui.py` | projekt-eigen | handgezeichnete Icons |
| `assets/generated/title/*.png` | Startbilder: symmetrische Insel mit Weltenbaum, Wasserfall, Logos „Elysia“ und „Nach Elysia“, Abendtal | projekt-eigen, aus den Spiel-Sprites zusammengesetzt (`tools/art/make_title.py`) | projekt-eigen | Key-Art |
| `assets/generated/sfx/*.wav` | Menü-, Belohnungs-, Dialog- und Riss-Klänge (ADR-027) | projekt-eigen, synthetisch (`tools/audio/make_sfx.py`) | projekt-eigen | Sounddesign |
| `assets/generated/objects/*.png` | Elysia-Truhe (zu/offen), Stein | projekt-eigen, prozedural (`tools/art/make_ui.py`) | projekt-eigen | handgezeichnete Objekte |
| `content/maps/look_{elysia,tal,wald}.txt` | Look-Karten Elysia-Garten, Tal, Wald bei Nacht | projekt-eigen | projekt-eigen | Prototypen; der Slice nutzt `elysia`, `tal`, `haus`, `antreiber_tal*` |
| `content/dialogue/{sandbox,valley,elysia,antreiber}/*.dialogue` | Prototyp-Texte (alle `[#ph]`) | Entwurf Claude | projekt-eigen | entfallen mit den Prototypen |
| `content/dialogue/slice/*.dialogue` | Texte des Vertical Slice (Elysia, Tal, Haus, Weg zum Schuppen; ADR-036) | Entwurf Claude in der Stimme der Bible | projekt-eigen | Writing-Pass nach dem Playtest |
| `assets/generated/props/{tal,haus}/*` (Slice) | Trittsteine flach/rund, umgestürzter Baum, Bruchbretter und neue Bretter der Brücke, Miras Plane, Feuerstelle, Netzgestell, Kartoffel, Ziege (mit Stiefel/Kartoffel), Stiefel, Wegweiser, Schuppen, Holzbündel, dunkles Haus; Innenraum: Raumhülle, Kamin kalt und brennend (drei Bilder), Tisch, Bett, Regal (leer/mit Löffel), Teppich, Eimer, Katze (Fenster/schlafend); Elysia: Festtafel, goldener Schmetterling | projekt-eigen, programmatisch (`tools/art/slice_props.py`, `make_sprites.py`) | projekt-eigen | handgepixelte Assets |
| `assets/generated/maps/{tal,haus,antreiber_tal,antreiber_tal_bench}_ground.png` | gebackene Böden des Slice | projekt-eigen, programmatisch (`tools/art/layout_slice_maps.py`, `bake_ground.py`) | projekt-eigen | handgemalte Böden bzw. Tilesets |
| `assets/generated/sfx/{door_*,wood_drop,splash_fall,stone_wobble,fire_*,cat_meow_*,goat_*}.wav`, `assets/generated/audio/nature_{roof,fire}_bed.wav` | Tür, Klopfen, Holz, Sturz in den Bach, Kippelstein, Streichholz und Feuer, Katze, Ziege; Regen aufs Dach, Kaminfeuer | projekt-eigen, synthetisch (`tools/audio/make_slice_sfx.py`, `make_nature.py`) | projekt-eigen | Field Recordings (CC0) bzw. Sounddesign |
| `icon.svg` | siehe oben | | | |

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
