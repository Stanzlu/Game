# Content Guide

Regeln für alles, was Spielerinnen und Spieler lesen, hören oder anklicken. Verbindlich sind
[`GAME_BIBLE.md`](GAME_BIBLE.md) und die Writing-Abschnitte 55–59 in [`TECH_MASTER_PROMPT.md`](TECH_MASTER_PROMPT.md).

## IDs

- Stabile IDs in `snake_case`, nie Anzeigenamen in Logik: `mira`, `tess`, `antreiber`, `item_stone`, `curiosity_tiny_spoon`.
- Story-Flags mit Namensraum: `elysia.mirror_noticed`, `valley.mira_first_no`, `house.fire_lit`.
- Quests: `main_<ort>_<thema>` bzw. `side_<thema>`, z. B. `main_elysia_butterflies`, `side_goat_roof`.
- UI-Schlüssel in `content/locale/ui.csv`: `UPPER_SNAKE_CASE` mit Bereichspräfix (`BOOT_`, `MENU_`, `JOURNAL_`, `HUD_`).
- Eine ID wird nie umbenannt, sobald Spielstände sie enthalten können. Stattdessen Migration (siehe `SAVE_FORMAT.md`).

## Dateien

| Inhalt | Ort | Format |
|--------|-----|--------|
| UI-Texte | `content/locale/ui.csv` | Spalten `keys,de` |
| Dialoge | `content/dialogue/<bereich>/<szene>.dialogue` | Dialogue Manager 4 |
| Quests, Items, Kuriositäten | `content/quests/`, `content/items/` | `.tres` (ab Phase 2) |
| Karten | `content/maps/<map>.txt` | Textkarte, siehe unten |

Neue Dialogdateien werden ab Phase 2 bewusst in die Übersetzungsvorlagen eingetragen. Die automatische
Eintragung des Dialogue Managers ist aus (ADR-006). Testdateien liegen nur unter `tests/`.

## Kartenformat (ADR-004, ADR-013)

```
; Kommentare sind vor dem [map]-Block erlaubt
[legend]
1 = {"ground": "_", "prop": "res://world/props/sign.tscn", "params": {"cue": "sign_parcours"}}
L = {"ground": ".", "prop": "res://world/props/lever.tscn", "params": {"target": "garden_gate"}}
G = {"ground": ",", "prop": "res://world/props/gate.tscn", "params": {"id": "garden_gate"}}
[map]
#######
#@.1LG#
#######
```

- Globale Symbole stehen in `content/maps/legend.json`. Lokale Symbole im `[legend]`-Block überschreiben sie.
- Tiles: `.` `:` Gras · `,` Erde · `_` Stein · `#` Mauer (fest) · `~` Wasser (fest) · `=` Holz · `X` dunkel (fest).
- Platzierungen: `@` Startpunkt · `"` hohes Gras · `o` Pfütze · `*` Busch · `B` Bank (2 Tiles breit).
- Alle Zeilen gleich lang. Fehler erscheinen mit Datei, Zeile und Spalte im Log und lassen Tests scheitern.
- Schilder: `params.cue` (und optional `params.dialogue`). Hebel: `params.target`, Tore: `params.id`. NPC-Route: `params.route` in Tiles relativ zum Startfeld.
- Das Symbol ist immer das erste Zeichen der Zeile, deshalb kann auch `=` lokal definiert werden (`= = {...}`).

### Look-Karten (ADR-017)

```
[meta]
style = "elysia"
ground = "res://assets/generated/maps/look_elysia_ground.png"
water = "res://assets/generated/maps/look_elysia_water.png"
[legend]
f = {"atlas": [1, 0], "surface": "grass", "paint": "meadow"}
T = {"ground": ".", "prop": "res://world/props/decor.tscn", "params": {"sprite": "elysia/tree"}}
```

- `[meta]`: `key = <JSON-Wert>`. `ground` ersetzt die Kachelgrafik durch eine gebackene Textur; Kollision und Oberflächen kommen weiter aus den Kacheln. `water` ist die Maske für den Wasser-Shader, `style` wählt die Paletten beim Backen.
- `paint` legt fest, wie der Baker ein Tile malt: `grass`, `meadow` (Gras mit Blumenteppich), `path`, `mud`, `puddle`, `cobble`, `water`, `planks_v`, `planks_h`, `hedge` (Laubkronen, fest), `cliff` (Felswand unter der Kante), `void` (durchsichtig, Himmel dahinter), `marble` (weiße Steinplatten mit Kante), `stairs` (Stufen durch eine Felskante), `fall` (Wasserfall, fest; über `void` blendet er nach unten aus), `field` (Gemüsebeet). Ohne `paint` wird aus `surface` abgeleitet.
- Deko: `world/props/decor.tscn` mit `params.sprite` = Katalog-ID (`<stil>/<name>`, siehe `assets/generated/props/catalog.json`). Bänke nehmen ebenfalls `params.sprite`. Katalog-Felder: `anchor`, `shape`, `sway`, `flat`, `bob`, `shadow`, `lights`, `flicker`, `surface`/`rustle`, `smoke`, `sparkle`, `loop_sound`, `glow` (Lichthof), `emissive` (leuchtende Pixel je Variante), `beam` (Lichtstrahl), `petal_rain`, `splash` (Gischt am Wasserfall).
- Figuren: `entities/npc/npc_walker.tscn` nimmt `params.sheet` (CharacterSheet-Pfad), `params.route` und `params.speed`. Ohne Route steht die Figur und schaut den Spieler an, wenn er nahe kommt.
- Nach jeder Kartenänderung neu backen: `.venv/bin/python tools/art/bake_ground.py content/maps/<karte>.txt`. Ein Test meldet, wenn die Texturgröße nicht mehr zur Karte passt.

## Dialogformat (Dialogue Manager 4)

```
~ valley_first_meeting
Mira: Du stehst im Regen.
- …
	Mira: Gut. Dann stehen wir beide hier.
- Ich weiß nicht, wo ich bin.
	Mira: Im Tal. Hilft dir wahrscheinlich nicht.
=> END
```

- Cues (`~ name`) in `snake_case`.
- „…“ ist eine vollwertige Antwort und bekommt eine eigene Reaktion.
- Keine Fake Choices: Jede Antwortgruppe braucht mindestens eine wahrnehmbare Konsequenz (andere Reaktion, Zustand, spätere Erinnerung). Ab Phase 2 prüft ein Validator das.
- Platzhalterzeilen werden mit dem Tag `[#ph]` markiert. Vor dem Playtest darf keine solche Zeile übrig sein. Ein Test prüft, dass jede Entwurfszeile markiert ist.
- Neue Dialogdateien in `internationalization/locale/translations_pot_files` eintragen. Ein Test prüft das.
- Statische Zeilen-IDs für Übersetzungen werden in Phase 2 eingeführt.

## Schreibregeln

- Natürlich, knapp, figurenbezogen. Keine Expositionsmonologe, keine ständigen Weisheiten.
- Keine Therapiesprache, keine Diagnosen, keine Suchtbegriffe, keine Lebensweisheiten auf Ladebildschirmen.
- Menschen dürfen über Essen, Wetter, Tiere, Unsinn und Alltag reden.
- Humor folgt emotionalen Momenten nicht reflexartig. Stille darf stehen bleiben.
- Fehler werden nie beschämt. Kein „Du bist schlecht“, keine Punktabzüge.
- Keine relevante Information nur über Farbe.

## Figurenstimmen

Kurzprofile als Arbeitsgrundlage. Ausführliche Voice-Sheets mit Beispielzeilen entstehen vor der
Dialogproduktion in Phase 4 und werden vom Projektinhaber abgenommen.

| Figur | Kern | Nie |
|-------|------|-----|
| Protagonist | neugierig, humorvoll, unsicher, anfangs reaktiv, später eigene Meinung | leeres Gefäß, allwissend |
| Elysia-NPCs | sympathisch, lobend, angenehm; Unbehagen erst durch Wiederholung | creepy von Anfang an |
| Mira | pragmatisch, trocken, warm ohne Sentimentalität, stur, neugierig, witzig, eigenes Ziel (Meer) | Mentorin, Therapeutin, Belohnung, Manic Pixie Dream Girl |
| Tess | direkt, warm, praktisch, verlangt Beteiligung | Weisheitsautomat |
| Antreiber | effizient, hilfreich, zunehmend erschöpfend | Monster, Bösewicht |
| Betäuber | charmant, warm, lustig, bequem | sinister |
| Richter | wiederkehrende Stimme, anfangs bedrohlich, später durchschaubar und komisch | verschwindet ganz |
