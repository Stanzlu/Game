# Content Guide

Regeln für alles, was Spielerinnen und Spieler lesen, hören oder anklicken. Verbindlich sind
[`GAME_BIBLE.md`](GAME_BIBLE.md) und die Writing-Abschnitte 55–59 in [`TECH_MASTER_PROMPT.md`](TECH_MASTER_PROMPT.md).

## IDs

- Stabile IDs in `snake_case`, nie Anzeigenamen in Logik: `mira`, `tess`, `antreiber`, `item_stone`, `curiosity_tiny_spoon`.
- Story-Flags mit Namensraum: `elysia.mirror_noticed`, `valley.mira_first_no`, `house.fire_lit`. Bereiche bisher: `elysia`, `valley`, `forest`, `house`, `encounter`, `sandbox` (nur Prototyp). Dazu `value.<id>` für die Werte der Spielerin (Bible §18; Akt II: `freedom`, `closeness`, `calm`; eine Wahl und ihr Leser stehen in verschiedenen Cues).
- Figuren mit Beziehung: `mira`, `tess`, `orin`, `lio`. Erinnerungen und Orte in `snake_case` (`door_silence`, `valley_bridge`).
- Jede Erinnerung, die das Tagebuch zeigen soll, bekommt einen Satz in `content/locale/journal.csv`
  unter `MEMORY_<FIGUR>_<ERINNERUNG>` (z. B. `MEMORY_MIRA_ASKED_SHELTER`): Ich-Form, trocken, was
  geschah, nie was es bedeutet (ADR-042, Bible §3.2, §23). Erinnerungen ohne Satz bleiben unsichtbar.
- Szenen-Schlüssel (`core/scene_registry.gd`) stehen in Spielständen und werden nie entfernt: eine Umbenennung trägt den alten Schlüssel in `SceneRegistry.aliases` ein (ADR-052).
- Kapitel: `Chapter.mark("slice")` setzt `chapter.slice`; die Akte folgen als `chapter.act1` usw. Beats (`Beat.mark`) gliedern innerhalb eines Kapitels.
- Quests: `main_<ort>_<thema>` bzw. `side_<thema>`, z. B. `main_elysia_butterflies`, `side_goat_roof`.
- UI-Schlüssel in `content/locale/ui.csv`: `UPPER_SNAKE_CASE` mit Bereichspräfix (`BOOT_`, `MENU_`, `JOURNAL_`, `HUD_`). Texte über mehrere Zeilen (`CREDITS_TEXT`) stehen mit echten Zeilenumbrüchen in Anführungszeichen in der CSV, nicht mit `\n`: Godot entschlüsselt Escapes beim Import, und der Übersetzungstest vergleicht die Rohzelle. Hinweise mit Tasten nehmen die Namen als `%s` aus `InputDevice.label_for(...)` und aktualisieren sich über `InputDevice.labels_changed`, wenn der Spieler umbelegt (ADR-048). Die Textschriften Jersey 10 und 15 haben keine Pfeile (↑ ↓) und keine Zeichen wie ○ □ △: Auf Seiten und in Zeilen aus Jersey stehen dafür Wörter (`CONTROLS_MOVE_ARROWS`, `CONTROLS_PS_CIRCLE`); die Zeichen gibt es nur in Hinweisen aus Tiny5 (`JOURNAL_SCROLL_HINT`).
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
- Texte: `QUEST_<ID>_TITLE`, `QUEST_<ID>_<STUFE>` (Journaleintrag, wenn die Stufe erreicht ist) und `QUEST_<ID>_OBJ_<ZIEL>` in `journal.csv`, alles in Großbuchstaben. Das Journal zeigt alle erreichten Einträge in Reihenfolge, darunter die Ziele der aktuellen Stufe: in Elysia mit einem Juwel vor den offenen und gedämpft die erledigten, in der Wirklichkeit nur die offenen (ein Tagebuch hat keine Häkchen). Gegenstände stehen unter „Dinge“ mit ihrer Zeile (`<ID>_DESC`) und in Elysia mit der Seltenheit.
- Items: `id` beginnt mit `item_` bzw. `curiosity_` (Art `CURIOSITY`), `max_stack` ist die Stapelgrenze, `rarity` die Elysia-Seltenheit (`NONE` bis `LEGENDARY`; der Stein hat `NONE` und zeigt „Seltenheit: —“). Texte `<ID>_NAME` und `<ID>_DESC` in `items.csv`. Icon 16×16 unter `assets/generated/items/<id>.png` (erzeugt von `tools/art/make_ui.py`); die Seltenheit bestimmt die Beute-Fanfare.
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
- Deko und Aufheben können einen Klang mitbringen: `params.sound` (Präfix der `SoundBank`, z. B. `cat_meow`, `wood_drop`) ist am Requisit zu hören, wenn man es ansieht bzw. aufhebt.
- Deko: `world/props/decor.tscn` mit `params.sprite` = Katalog-ID (`<stil>/<name>`, siehe `assets/generated/props/catalog.json`). Bänke nehmen ebenfalls `params.sprite`. Katalog-Felder: `anchor`, `shape`, `sway`, `flat`, `bob`, `shadow`, `lights`, `flicker`, `surface`/`rustle`, `smoke`, `sparkle`, `loop_sound`, `glow` (Lichthof), `emissive` (leuchtende Pixel je Variante), `beam` (Lichtstrahl), `petal_rain`, `splash` (Gischt am Wasserfall).
- Streuen (`[meta]`): `scatter = [{"sprite": "<id>", "on": "<Bodensymbole>", "density": 0.3, "spacing": 12, "near": "<Symbole>", "radius": 1}, ...]`. Setzt kleine Deko deterministisch auf passende Zellen (nie auf Zellen mit Platzierung). `near` verlangt ein Boden- oder Platzierungssymbol in `radius` Zellen Umkreis (z. B. Laub nur unter Bäumen, Schilf nur am Wasser). `pattern` ist `random` (Standard), `grid` oder `checker`, `jitter` die Zufallsverschiebung (0 = exakt), `offset` verschiebt das Raster. `clump` (px, nur `random`) lässt die Deko in Gruppen dieser Größe wachsen, mit kahlen Stellen dazwischen.
- Symmetrie (`[meta]`): `symmetry = <Spalte>` macht eine Karte spiegelsymmetrisch um diese Spalte (Elysia, ADR-031): Boden, Streu und Requisiten rechts der Achse zeigen ihren Zwilling gespiegelt, Pflanzen wiegen sich im Gleichtakt. Die Karte selbst muss symmetrisch sein (`tools/art/layout_look_maps.py elysia` erzeugt sie so).
- Figuren: `entities/npc/npc_walker.tscn` nimmt `params.sheet` (CharacterSheet-Pfad), `params.route` und `params.speed`. `params.face` (`n`, `ne`, `e`, `se`, `s`, `sw`, `w`, `nw`) ist die Blickrichtung im Stand; `params.work_face` (Standard `w`) die Blickrichtung der Arbeitspose, die nur Blätter mit dem Zustand „work“ haben (Mira am ersten Routenpunkt). `params.sit = true` setzt die Figur. Beim Sprechen wippt sie mit dem Stimmklang, ihre Schritte sind zu hören (nicht in Elysia). Ohne Route steht die Figur und schaut den Spieler an, wenn er nahe kommt. `params.glance = true` lässt sie im Stehen ab und zu blinzeln und sich umschauen (Menschen der Wirklichkeit; Elysianer nie).
- Nach jeder Kartenänderung neu backen: `.venv/bin/python tools/art/bake_ground.py content/maps/<karte>.txt`. Ein Test meldet, wenn die Texturgröße nicht mehr zur Karte passt; der Schritt „map stamps“ in `check.sh` meldet jede Karte, deren Malart, Schatten, `[meta]` (ohne `scatter`) oder Baker sich seit dem letzten Bake geändert hat (Stempel in `tools/art/map_stamps.json`, ADR-052). Reine Requisiten-Parameter ändern den Stempel nicht.
- **Querprüfung** (`StoryLint`, Test `test_story_lint`): Türen und `SceneTravel.go` nennen eine eingetragene Szene und einen Marker `spawn_<name>`, der in deren Karte steht (Marker einmal je Karte); jeder Cue aus Karten, `Talk.present` und `cut.say` steht in seinem Dialog; jede Quest-Stufe nach der ersten hat einen Auslöser (`advance_quest("quest", "stufe")` mit Literalen oder Konstanten, oder eine Weltaktion der Karte); ein gelesenes Flag wird irgendwo gesetzt, ein gesetztes irgendwo gelesen (Ausnahmen mit Begründung in `StoryLint.WRITE_ONLY_FLAGS`; `beat.*` braucht keinen Leser); ein Skript mit eigenem Blitz (`flash`, `flicker`, `strobe`, `lightning` als Funktion oder Variable) liest `display.reduce_flashing`, eines mit eigenem Wackeln `display.screen_shake`. Flags, Quest-IDs und Cues daher als Literale oder Konstanten schreiben, nicht aus Variablen bauen.

- **Kartenprüfung** (`MapLint`, Test `test_map_lint`, ADR-055): eine Szenenkarte hat `player_spawn`; Türen, Fundstücke, Truhen, Hebel, Schilder, Falter, Figuren und der Riss stehen auf begehbaren Zellen und sind vom Spawn aus erreichbar (Trittsteine zählen als Boden, Möbel in der Wand werden von vorn benutzt); eine Karte mit `[meta] symmetry` ist um ihre Mittelspalte gespiegelt (Stein, Riss und Kind ohne Zwilling). Eine Karte, die nur ein Skript füttert, braucht keinen Spawn. Neue Einzelstücke in einer Spiegelkarte tragen sich in `MapLint.SINGLE_PROPS`/`SINGLE_CUES` ein.
- **Sammelstücke** (`Collection`): Fragmente `fragment.<id>` (sechs Bilder des Kindes, 18 Spuren der Welt), Melodien `melody.<id>`, Kuriositäten `curiosity_<name>`; IDs snake_case und stabil. Die Facette der Wahrnehmung heißt `perception`.
- **Elysia über mehrere Szenen:** `ElysiaDirector.attach(self)` statt eigener Uhr; Stufen als Flags `elysia.loops_1`, `elysia.loops_2`, `elysia.loops`.
- **Dauer rechnen** statt schätzen: `python3 tools/writing/calibrate.py --segment WÖRTER ZEILEN WEG_MIN` (`docs/KALIBRIERUNG.md`).

## Schreibwerkzeuge (ADR-053)

- **Status einer Zeile:** `[#draft]` (Entwurf), `[#ok]` (eingefroren), `[#ph]` (Platzhalter, nur in Prototypen). Höchstens einer; unmarkierte Zeilen zählen als Entwurf. Eingefrorene Zeilen ändern sich nur mit Absicht.
- **ID-Sperre** (`content/dialogue/ids.lock`, `tools/writing/id_lock.py`): neue Zeilen-IDs mit `--update` eintragen; verschwindet eine ID, schlägt `check.sh` fehl, bis sie wiederkommt oder mit `--retire <id> <Grund>` zurückgezogen ist. Eingefrorene Zeilen tragen einen Hash; nach einer gewollten Änderung `--refreeze <id>`.
- **Vokabel-Lint** (`tools/writing/vocabulary.json`): keine Therapie-, Diagnose- oder Suchtsprache (Bible §3.2). Ein berechtigter Treffer steht mit Zeilen-ID, Begriff und Grund unter `exceptions`.
- **Zahlen:** Zahlen im Story-Text werden ausgeschrieben (Dialoge, Journal, Gegenstandsbeschreibungen); Schilder und Größen sind Ausnahmen mit Grund.
- **Schreiben gegen die Blätter:** `docs/writing/STIL.md` (Stil und „Nie“-Liste), `docs/writing/stimmen/<figur>.md` (Funktion, Signatur, Goldzeilen), `docs/writing/MOTIVE.md` (Motive und Konsequenzen-Register, erzeugt aus `motive.json` mit `tools/writing/motifs.py --write`). Zitate mit `` `id` „Text“ `` auf diesen Seiten prüft der Check gegen den Spieltext.
- **Lesefassung** (`tools/writing/readable.py`, ADR-056): zu jedem Segment erzeugt ein Pull Request `docs/lesefassung/<segment>.md`; der Projektinhaber antwortet je Szenennummer mit „OK“, „ändern: …“ oder „raus“. Danach `[#ok]` setzen und `id_lock.py --update`.
- **Tests nennen IDs, nicht Wortlaut:** `LineText.of("<id>")` (`tests/unit/line_text.gd`); nur Bible-Wortlaut („Zum Meer.“) bleibt als Text.
- `tools/writing/report.py` zeigt Zeilen und Wörter je Sprecher, den Stand je Datei und Cues, die nichts mehr startet.

## Szenen: Musik, Ambience, Licht

- `GameScene`-Exports: `music` (`keep`, `silence`, `elysia`, `valley`, `forest`, `antreiber`), `ambience` (Loop oder `SoundscapeDef`) und `ambience_db`, `view_zoom` (Vorgabe 1,25; nur Innenräume bekommen 1,5, ADR-045; die Hütte schließt sich beim Bleiben bis 2,0, `GameView.zoom_to`, ADR-070 O6).
- Ein neuer Klang mit Erzählwert (Frösche, Katze, Riss …) bekommt einen Eintrag in `AudioDirector.CAPTIONS` und eine Zeile `CAPTION_<NAME>` in `ui.csv` („Geräusche als Text“, ADR-046); wer ihn nur gedämpft oder von weit her hören soll, darf ohne bleiben (`cat_meow_muffled`). Jeder Klang braucht außerdem eine Lautheitsgruppe und einen Aufrufgain nach der Tabelle in `tools/audio/check_levels.py` (ADR-047).
- `LookScene.day_preset` (`keine`, `regentag`, `abend`, `nacht`, `morgen`) aktiviert das Tageslicht. Elysia bleibt ohne.
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
- **Bedingte Antworten verschwinden**, wenn ihre Bedingung nicht zutrifft (sie stehen nicht ausgegraut da). Jede Antwortgruppe braucht deshalb **mindestens eine unbedingte Antwort**; ein Test prüft alle Dialoge. Eine Antwort mit `{{Wert}}` im Text braucht eine Bedingung, die diesen Wert nennt (sonst bliebe sie bei leerem Wert halb leer stehen); `WorldState.player_name()` ist ausgenommen. Der Validator meldet beides.
- Keine Fake Choices: Jede Antwortgruppe braucht mindestens eine wahrnehmbare Konsequenz (andere Reaktion, Zustand, spätere Erinnerung). Der Validator meldet Gruppen, deren Antworten alle gleich weitergehen.
- Zustand nur über `WorldState` (der Validator prüft Methode und IDs):
  - Flags: `has_flag`, `set_flag`, `clear_flag` (immer mit Namensraum, z. B. `valley.mira_met`)
  - Quests: `start_quest`, `advance_quest(id, stufe)`, `complete_objective`, `quest_stage`, `is_quest_active`, `is_quest_done`, `quest_outcome`
  - Beziehungen: `relationship_state("mira") == "cautious"`, `set_relationship`, `add_memory`, `has_memory`
  - Inventar und Haus: `has_item`, `add_item`, `remove_item`, `item_count`, `is_fire_lit`, `set_fire_lit`
  - Sonstiges: `set_facet`, `has_facet`, `discover`, `is_real`, `add_xp`, `add_gold`
- Während eines Dialogs wird nicht gespeichert; Quest-Schritte im Dialog lösen das Autosave direkt nach dem Ende aus.
- Platzhalterzeilen werden mit dem Tag `[#ph]` markiert. Prototyp-Dialoge (`sandbox`, `valley`, `elysia`) tragen ihn auf jeder Zeile. Die Texte des Vertical Slice liegen in `content/dialogue/slice/` und sind der Playtest-Text: dort darf keine Zeile `[#ph]` tragen. Ein Test prüft beides. Slice-Texte bleiben Entwürfe, die nach dem Playtest überarbeitet werden.
- Zeilen ohne Sprecher sind Erzählung (Beschreibungen beim Untersuchen, Gesten wie „Sie schaut zu den Bergen.“). Sie bleiben stumm.
- **Texteffekte** (`[wave amp=14 freq=5]…[/wave]`, `[rainbow freq=0.6 sat=0.5]…[/rainbow]`, `[shake]`, `[tornado]`, `[pulse]`, `[fade]`) stehen nur in gesprochenen Zeilen, nie in Erzählzeilen (Validator). Sparsam einsetzen. `[wait=0.9]` setzt eine Pause vor dem nächsten Wort (Miras erstes „Nein.“, „Zum Meer.“); ein Druck hebt sie nicht auf, bei Textgeschwindigkeit „Sofort“ entfällt sie. „Blitzeffekte reduzieren“ entfernt die Bewegungseffekte aus dem Text, `[wait]` bleibt. Die Taste eines Geräts steht als `{{InputDevice.label_for("sprint")}}` im Text; sie folgt der Belegung des Spielers, eine schon sichtbare Zeile aktualisiert sich aber nicht (KNOWN_ISSUES #77).
- Neue Dialogdateien in `internationalization/locale/translations_pot_files` eintragen. Ein Test prüft das.
- Stimmen: `content/dialogue/voices.json` ordnet jedem Sprecher (Name wie in der Dialogdatei) eine Stimme zu (`elysia`, `warm`, `low`, `neutral`); unbekannte Sprecher bekommen `_default`. Zeilen ohne Sprecher (Schilder) bleiben stumm. Jeder Sprecher des Slice braucht einen Eintrag (Test).
- **„Die Frau“** ist der Sprecher für Mira, bis sie sich vorstellt („Mira, übrigens.“, `tal_mira_24`); danach heißt sie `Mira`. Beide haben die Stimme `warm`.

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
