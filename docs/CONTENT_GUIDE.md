# Content Guide

Regeln für alles, was Spielerinnen und Spieler lesen, hören oder anklicken. Verbindlich sind
[`GAME_BIBLE.md`](GAME_BIBLE.md) und die Writing-Abschnitte 55–59 in [`TECH_MASTER_PROMPT.md`](TECH_MASTER_PROMPT.md).

## IDs

- Stabile IDs in `snake_case`, nie Anzeigenamen in Logik: `mira`, `tess`, `antreiber`, `item_stone`, `curiosity_tiny_spoon`.
- Story-Flags mit Namensraum: `elysia.mirror_noticed`, `valley.mira_first_no`, `house.fire_lit`. Bereiche bisher: `elysia`, `valley`, `forest`, `house`, `encounter`, `sandbox` (nur Prototyp).
- Figuren mit Beziehung: `mira`, `tess`, `orin`, `lio`. Erinnerungen und Orte in `snake_case` (`door_silence`, `valley_bridge`).
- Szenen-Schlüssel (`core/scene_registry.gd`) stehen in Spielständen und werden nie umbenannt.
- Quests: `main_<ort>_<thema>` bzw. `side_<thema>`, z. B. `main_elysia_butterflies`, `side_goat_roof`.
- UI-Schlüssel in `content/locale/ui.csv`: `UPPER_SNAKE_CASE` mit Bereichspräfix (`BOOT_`, `MENU_`, `JOURNAL_`, `HUD_`).
- Eine ID wird nie umbenannt, sobald Spielstände sie enthalten können. Stattdessen Migration (siehe `SAVE_FORMAT.md`).

## Dateien

| Inhalt | Ort | Format |
|--------|-----|--------|
| UI-Texte | `content/locale/ui.csv` | Spalten `keys,de` |
| Journaltexte | `content/locale/journal.csv` | Schlüssel aus Quest- und Stufen-ID |
| Item-Texte | `content/locale/items.csv` | Schlüssel aus Item-ID |
| Dialoge | `content/dialogue/<bereich>/<szene>.dialogue` | Dialogue Manager 4 |
| Quests | `content/quests/<id>.tres` | `QuestDef` (ADR-019) |
| Items, Kuriositäten | `content/items/<id>.tres` | `ItemDef` (ADR-019) |
| Karten | `content/maps/<map>.txt` | Textkarte, siehe unten |

Neue Dialogdateien werden bewusst in die Übersetzungsvorlagen eingetragen
(`internationalization/locale/translations_pot_files`). Die automatische Eintragung des Dialogue
Managers ist aus (ADR-006). Neue CSV-Dateien gehören in `internationalization/locale/translations`.
Testdateien liegen nur unter `tests/`.

`ContentValidator` prüft alles unter `content/` bei jedem Start eines Debug-Builds und in den Tests.
Probleme erscheinen als `ERROR CONTENT: <datei>:<zeile>: <problem>` und lassen `tools/check.sh` scheitern.
Im Spiel prüft das Debug-Panel (F4, „Inhalte prüfen“) auf Knopfdruck.

## Quests und Items (ADR-019)

```
[gd_resource type="Resource" script_class="QuestDef" format=3]
[ext_resource type="Script" path="res://core/content/quest_def.gd" id="1_quest"]
[ext_resource type="Script" path="res://core/content/quest_stage_def.gd" id="2_stage"]
[sub_resource type="Resource" id="Resource_find"]
script = ExtResource("2_stage")
id = "find_lever"
objectives = PackedStringArray("look_around")
next = PackedStringArray("done")
[sub_resource type="Resource" id="Resource_done"]
script = ExtResource("2_stage")
id = "done"
outcome = "done"
[resource]
script = ExtResource("1_quest")
id = "side_sandbox_gate"
stages = Array[ExtResource("2_stage")]([SubResource("Resource_find"), SubResource("Resource_done")])
```

- Die erste Stufe ist der Start. `next` nennt die erlaubten Folgestufen, mehrere sind möglich (unterschiedliche Ausgänge). Eine Stufe ohne `next` beendet die Quest und braucht ein `outcome` (`done`, `missed`, …). Andere Ausgänge sind kein Scheitern.
- Texte: `QUEST_<ID>_TITLE`, `QUEST_<ID>_<STUFE>` (Journaleintrag, wenn die Stufe erreicht ist) und `QUEST_<ID>_OBJ_<ZIEL>` in `journal.csv`, alles in Großbuchstaben. Das Journal zeigt alle erreichten Einträge in Reihenfolge, darunter die Ziele der aktuellen Stufe mit `[ ]` bzw. `[x]`.
- Items: `id` beginnt mit `item_` bzw. `curiosity_` (Art `CURIOSITY`), `max_stack` ist die Stapelgrenze, `rarity` die Elysia-Seltenheit (`NONE` bis `LEGENDARY`; der Stein hat `NONE` und zeigt „Seltenheit: —“). Texte `<ID>_NAME` und `<ID>_DESC` in `items.csv`.
- `draft = true` markiert Platzhalter-Inhalt. Vor dem Playtest-Build darf keine Quest und kein Item mehr `draft` sein (`ContentValidator.drafts()`).
- Dateiname = ID. Keine Marker im Slice außer bewusst in Elysia.

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
- NPCs zum Ansprechen: `params.cue` und `params.dialogue`. Die Figur bleibt im Gespräch stehen und schaut den Spieler an.
- Hebel mit Gedächtnis: `params.flag` (Zustand wird gespeichert) und `params.actions` (beim ersten Umlegen). Auslösezone `world/props/trigger_zone.tscn`: `params.flag` (feuert einmal), `params.actions`, optional `params.size` in Tiles.
- Weltaktionen (`StateActions`, nichts anderes ist erlaubt): `{"flag": "bereich.name"}`, `{"quest": "<id>", "stage": "<stufe>", "start": true}`, `{"item": "<id>", "count": 1}`, `{"discover": "<ort>"}`, `{"xp": 250}`, `{"gold": 100}`. Ein Test prüft alle Aktionen in allen Karten.
- Truhe `world/props/chest.tscn`: `params.flag` (öffnet einmal) und `params.actions` (Loot, Gold, XP, Quest-Schritt). Aufheben `world/props/pickup.tscn`: `params.item`, `params.flag`. Riss `world/props/rift.tscn`: `params.target` (Szenen-Schlüssel). Bank: `params.pass_time` lässt die Tageszeit weiterlaufen (nur Szenen mit `day_preset`).
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
- Streuen (`[meta]`): `scatter = [{"sprite": "<id>", "on": "<Bodensymbole>", "density": 0.3, "spacing": 12, "near": "<Symbole>", "radius": 1}, ...]`. Setzt kleine Deko deterministisch auf passende Zellen (nie auf Zellen mit Platzierung). `near` verlangt ein Boden- oder Platzierungssymbol in `radius` Zellen Umkreis (z. B. Laub nur unter Bäumen, Schilf nur am Wasser).
- Figuren: `entities/npc/npc_walker.tscn` nimmt `params.sheet` (CharacterSheet-Pfad), `params.route` und `params.speed`. Ohne Route steht die Figur und schaut den Spieler an, wenn er nahe kommt.
- Nach jeder Kartenänderung neu backen: `.venv/bin/python tools/art/bake_ground.py content/maps/<karte>.txt`. Ein Test meldet, wenn die Texturgröße nicht mehr zur Karte passt.

## Szenen: Musik, Ambience, Licht

- `GameScene`-Exports: `music` (`keep`, `silence`, `elysia`, `valley`, `forest`, `antreiber`), `ambience` (Loop) und `ambience_db`.
- `LookScene.day_preset` (`keine`, `regentag`, `abend`, `nacht`) aktiviert das Tageslicht. Elysia bleibt ohne.
- Startet man eine Szene im Prototyp-Menü, gilt ihr UI-Modus aus `SceneRegistry.START_MODES`.

## Dialogformat (Dialogue Manager 4)

```
~ valley_first_meeting
if not WorldState.has_flag("valley.mira_met")
	Mira: Du stehst im Regen. [ID:valley_first_meeting_1]
	- … [ID:valley_first_meeting_r1]
		Mira: Gut. Dann stehen wir beide hier. [ID:valley_first_meeting_2]
		do WorldState.add_memory("mira", "rain_silence")
	- Ich weiß nicht, wo ich bin. [ID:valley_first_meeting_r2]
		Mira: Im Tal. Hilft dir wahrscheinlich nicht. [ID:valley_first_meeting_3]
	do WorldState.set_flag("valley.mira_met")
else
	Mira: Immer noch nass? [ID:valley_first_meeting_4]
=> END
```

- Cues (`~ name`) in `snake_case`.
- Jede Zeile und jede Antwort trägt eine statische ID `[ID:<bereich>_<cue>_<n>]`, Antworten `_r<n>`. IDs sind projektweit eindeutig und werden nie umbenannt; sie sind der Übersetzungs-Kontext (ADR-020).
- „…“ ist eine vollwertige Antwort und bekommt eine eigene Reaktion.
- Keine Fake Choices: Jede Antwortgruppe braucht mindestens eine wahrnehmbare Konsequenz (andere Reaktion, Zustand, spätere Erinnerung). Der Validator meldet Gruppen, deren Antworten alle gleich weitergehen.
- Zustand nur über `WorldState` (der Validator prüft Methode und IDs):
  - Flags: `has_flag`, `set_flag`, `clear_flag` (immer mit Namensraum, z. B. `valley.mira_met`)
  - Quests: `start_quest`, `advance_quest(id, stufe)`, `complete_objective`, `quest_stage`, `is_quest_active`, `is_quest_done`, `quest_outcome`
  - Beziehungen: `relationship_state("mira") == "cautious"`, `set_relationship`, `add_memory`, `has_memory`
  - Inventar und Haus: `has_item`, `add_item`, `remove_item`, `item_count`, `is_fire_lit`, `set_fire_lit`
  - Sonstiges: `set_facet`, `has_facet`, `discover`, `is_real`, `add_xp`, `add_gold`
- Während eines Dialogs wird nicht gespeichert; Quest-Schritte im Dialog lösen das Autosave direkt nach dem Ende aus.
- Platzhalterzeilen werden mit dem Tag `[#ph]` markiert. Vor dem Playtest darf keine solche Zeile übrig sein. Ein Test prüft, dass jede gesprochene Zeile markiert ist, solange es keine finalen Texte gibt.
- Neue Dialogdateien in `internationalization/locale/translations_pot_files` eintragen. Ein Test prüft das.

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
