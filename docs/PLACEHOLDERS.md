# Placeholder-Liste

Jede Datei, die nicht final ist, steht hier. Regeln: nur CC0 (Schriften OFL), Herkunft und Lizenz pro
Eintrag, Austausch ohne Logikänderung möglich (ADR-003).

## Im Projekt

| Datei | Art | Quelle | Lizenz | Ersatz geplant |
|-------|-----|--------|--------|----------------|
| `icon.svg` | App-Icon | selbst erstellt (Riss im Feld) | projekt-eigen | finales Icon nach Art-Direction |
| `assets/fonts/tiny5/Tiny5-Regular.ttf` | UI-Schrift | google/fonts `ofl/tiny5` (Stefan Schmidt) | OFL 1.1 (`OFL.txt` liegt bei) | evtl. final; Entscheidung mit Art-Direction |
| `core/boot/boot.tscn` | Startbildschirm | selbst erstellt | projekt-eigen | echter Titel-Flow (Phase 4) |

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

Solange keine Packs vorliegen, entstehen einfache Formen und einfarbige Tiles im Code bzw. als kleine,
selbst erzeugte PNGs. Sie werden hier mit „projekt-eigen, programmatisch“ eingetragen.
