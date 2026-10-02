# Placeholder-Liste

Jede Datei, die nicht final ist, steht hier. Regeln: nur CC0 (Schriften OFL), Herkunft und Lizenz pro
Eintrag, Austausch ohne Logikänderung möglich (ADR-003).

## Im Projekt

| Datei | Art | Quelle | Lizenz | Ersatz geplant |
|-------|-----|--------|--------|----------------|
| `icon.svg` | App-Icon | selbst erstellt (Riss im Feld) | projekt-eigen | finales Icon nach Art-Direction |
| `assets/fonts/tiny5/Tiny5-Regular.ttf` | UI-Schrift | google/fonts `ofl/tiny5` (Stefan Schmidt) | OFL 1.1 (`OFL.txt` liegt bei) | evtl. final; Entscheidung mit Art-Direction |
| `core/boot/boot.tscn` | Startmenü des Prototyps | selbst erstellt | projekt-eigen | echter Titel-Flow (Phase 4) |
| `assets/placeholder/tiles/greybox_tiles.png` | 16-px-Tiles (Gras, Erde, Stein, Mauer, Wasser, Holz) | projekt-eigen, programmatisch | projekt-eigen | CC0-Tileset (Phase 3), später finale Art |
| `assets/placeholder/characters/{player,npc,antreiber}.png` | 16×24-Figuren, 8 Richtungen, Idle/Walk/Run/Sit | projekt-eigen, programmatisch | projekt-eigen | finales Figurendesign |
| `assets/placeholder/props/*.png` | Bank, Schild, Hebel, Tor, Grasbüschel, Pfütze, Spritzer, Busch, Flagge, Vogel, Staub | projekt-eigen, programmatisch | projekt-eigen | CC0 bzw. finale Art |
| `assets/placeholder/audio/*.wav` | Schritte je Oberfläche, Rascheln, Platschen, UI, Hebel, Tor, Sitzen, Vogel, Antreiber-Murmeln | projekt-eigen, synthetisch | projekt-eigen | CC0-Sounds bzw. Sounddesign |
| `assets/generated/maps/look_*_{ground,water}.png` | gebackene Böden und Wassermasken der Look-Karten | projekt-eigen, programmatisch (`tools/art/bake_ground.py`) | projekt-eigen | handgemalte Böden bzw. Tilesets (ADR-017) |
| `assets/generated/props/**` | Weltenbaum, Bäume in vier Farben, Büsche, Marmorsäulen, Kristall, leuchtende Blumen, Riesenblumen, Formschnitt, Felsen, Brunnen, Laternen, Zäune, Bänke, Haus, Wolken, Partikel, `catalog.json` | projekt-eigen, programmatisch (`tools/art/make_sprites.py`) | projekt-eigen | handgepixelte Assets |
| `assets/generated/characters/player.png` | Spielfigur 24×32, 8 Richtungen | projekt-eigen, programmatisch (`tools/art/make_character.py`) | projekt-eigen | finales Figurendesign |
| `assets/generated/audio/*_loop.wav` | Regen, Garten, Wasser (Ambience-Loops) | projekt-eigen, synthetisch (`tools/audio/make_ambience.py`) | projekt-eigen | Field Recordings bzw. Sounddesign |
| `content/maps/look_{elysia,tal}.txt` | Look-Karten Elysia-Garten und Tal | projekt-eigen | projekt-eigen | Slice-Karten (Phase 3) |
| `content/dialogue/**/*.dialogue` | Schildtexte und Antreiber-Sätze (alle `[#ph]`) | Entwurf Claude | projekt-eigen | Writing-Pass mit Voice-Sheets (Phase 4) |
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
