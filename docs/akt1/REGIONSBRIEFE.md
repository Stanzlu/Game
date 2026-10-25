# Akt I (Elysia): Regionsbriefe

Je Segment ein Brief nach Abschnitt 4.5 des Produktionsplans: Beat-Tabelle, Flags, Figuren, Humor-Ziel, Gewicht, Motive,
Scheitern und Speichern, Barrierefreiheit, Endlichkeit. Briefe sind verbindlich, sobald das Segment gebaut ist; Änderungen
im Pull Request des Segments. Zeiten rechnet `tools/writing/calibrate.py` (`docs/KALIBRIERUNG.md`).

## Der Fluss von Akt I

Die Heldenquest `main_elysia_hero` wächst mit den Segmenten um eine Stufe je Ort und endet vorläufig bei `repeat`; die Schleifen (A7) beginnen erst nach dem Fest. Die Spur des Kindes (A8) und der Riss (A9) sind eine eigene Quest, `main_elysia_trail`.

| Stufe | Segment | Ort (Szenenschlüssel) | Beat | Stand |
|---|---|---|---|---|
| greet, butterflies, reward, celebrated | A1 Erwachen und Garten | `elysia` | `elysia_start` … `butterflies_caught` | vorhanden |
| inn | A2 Gasthaus | `gasthaus` | `inn_enter`, `inn_fed`, `inn_room`, `inn_slept` | **gebaut (ADR-058)** |
| market | A3 Markt und Straße | `markt` | `market_enter`, `market_board`, `market_bread`, `market_board_done`, `market_melody` | **gebaut (ADR-059)** |
| hall | A5 Spiegelhalle | `spiegelhalle` | `hall_enter`, `hall_room_1`, `hall_room_2`, `hall_mirror`, `perception` | **gebaut (ADR-060)** |
| feast | A6 Fest | `markt` (Festzustand) | `feast_enter`, `feast` | **gebaut (ADR-061)** |
| repeat | A7 Wiederholung | alle Orte | `irritation` | **gebaut (ADR-062)** |
| – (eigene Quest `main_elysia_trail`: hum, trail, rift) | A8 Kind-Spur | `markt`, `gasthaus`, `spiegelhalle`, `elysia` | `trail_hallway`, `trail_door`, `trail_room`, `child_melody` | **gebaut (ADR-063)** |
| – (Stufe `rift` der Spur) | A9 Stein, Samen, Riss | `elysia` (und die Schleife 2 im Markt und im Gasthaus) | `stone`, `rift_found` | **gebaut (ADR-064)** |

Raumschichtung (Plan 4.1): Zimmer (Gasthaus) – Mauer und Tor – Garten – Straße – Stadt (Markt) – Welt (Weltenbaum), unbeschriftet.
Die Schleifen beginnen mit dem Hoch auf dem Fest (`elysia.feast_toast`, Stufe `repeat`, A7); die Musikstufen folgen `elysia.market_seen` und `elysia.stone_taken`, die Uhr fängt nur, wer nicht weiterspielt (20, 40 und 60 Minuten).

---

## A2 Gasthaus zum Immer

**Stand:** gebaut. **Szene:** `world/levels/akt1/gasthaus.tscn` (`GasthausScene`), Karte `content/maps/gasthaus.txt` (41 × 24, spiegelsymmetrisch um
Spalte 20, Zoom 1,5), Dialog `content/dialogue/akt1/gasthaus.dialogue` (69 Zeilen, 16 Cues, alle `[#draft]`). **Zugang:** die Tür in der Mitte der
Nordterrasse des Gartens (Zelle 32, 6), erreichbar über die Treppen im Westen und Osten; zurück zum Ankunftspunkt `spawn_inn`.

**Zweck.** Der Gastwirt ist das Gesicht des Betäubers (Bible §14): drei Angebote, Essen, Zimmer, Nacht, jedes frei abzulehnen, jedes beim
nächsten Mal freundlich erneuert. Hier steht zum ersten Mal der gefährlichste Satz: „Du musst heute nicht zurück.“ (`gh_room_3`).
Die Ebene „Zimmer“ der Raumschichtung (Plan 4.1). Die Halle sieht überall gleich aus und ist es auch: zwei Fenster, zwei Türen
hinter dem Tresen, zwei Kamine, zwei Zimmer.

| Beat | Auslöser | Was geschieht | Marke |
|---|---|---|---|
| Betreten | Szene beginnt | die Halle, der Gastwirt hinter dem Tresen, vier Gäste an vier Tischen | Beat `inn_enter` |
| Begegnung 1: das Brot | Gespräch mit dem Gastwirt (`host_first`, `host_meal`) | er heißt willkommen, bittet ins Gästebuch, serviert Brot; Antworten: setzen, nur schauen, schweigen | Flags `elysia.inn_met`, `elysia.inn_fed`; Beat `inn_fed`; +300 XP |
| Begegnung 2: das Zimmer | zweites Gespräch (`host_room`) | „Dein Zimmer ist fertig.“ Annehmen öffnet beide Zimmertüren; „Ich muss weiter.“ lässt sie zu, er fragt später wieder anders | `elysia.inn_room` (+200 XP, Beat `inn_room`) oder `elysia.inn_declined` |
| Begegnung 3: die Nacht | das Bett (`bed`) | Hinlegen: Blende auf Weiß, derselbe Morgen (`woke`), +500 XP; danach der dritte Antrag („Du kannst für immer bleiben.“) | `elysia.inn_slept`, Beat `inn_slept`, `elysia.inn_stayed` |
| Gästebuch | das Pult (`guestbook`), zweimal vorhanden | dein Name steht auf jeder Seite in fremder Schrift; Eintragen zahlt 2.000 XP und 500 Gold für nichts | Nebenquest `side_elysia_guestbook`, `elysia.inn_book_seen`, `elysia.inn_book_signed` |
| Kleinigkeiten | Fenster, Uhr, Türen hinter dem Tresen, Kamin | zwei Fenster zeigen denselben Garten; die Uhr hat nur ein Wort („Jetzt.“); zwei Türen, beide zu | keine Flags (Vorausdeutung auf A8: „Flur“, „geschlossene Tür“) |

**Heldenquest.** Das erste Gespräch mit dem Gastwirt setzt die Stufe `inn` (wenn die Truhe schon offen ist, sonst setzt die Truhe sie, `ElysiaScene`); damit
geht die Quest zur Stufe `market` weiter (A3).

**Figuren.** Gastwirt (`sheet_host_look`, Stimme `Gastwirt`), vier Gäste (`sheet_elysian_look`, sitzend, wortgleich: „Das Brot hier! Ich komme jeden
Tag. Es ist jeden Tag das beste.“). Keine neue Figur.

**Humor-Ziel (2/10).** Wiederholung und Lob, die sich selbst widersprechen: das Rezept „von gestern, gestern von vorgestern“; „Nach Brot! Ha!“;
zwei Zimmer, die beide „deins“ sind, weil sie genau gleich sind. Der Gastwirt macht Witze über sein Brot, nie über den Gast.

**Gewicht (§45).** leicht; die schwerste Zeile ist freundlich gesagt.

**Motive.** `betaeuber` (Bible §14, §46; Auflösung Akt VI: das freiwillige Aufstehen), Wiederholung („derselbe Morgen“, `gh_woke_2` hallt `el_wake_0` nach), Spiegelung
(zwei Fenster, kein Unterschied).

**Scheitern und Speichern (§49).** Es gibt kein Scheitern: Jedes Angebot ist abzulehnen, nichts sperrt die Tür nach draußen (die Tür ist automatisch, auch
mitten in der Nacht lädt der Spielstand die Nacht zu Ende). Jede Beat-Marke speichert; die Nacht blockiert das Speichern nur für ihre sieben Sekunden
(Cutscene).

**Barrierefreiheit (§50).** Die Blende der Nacht ist ein Weißlicht ohne Blitz (`ScreenFade`, 1,8 s heraus, 2,6 s hinein); der Text läuft über die
normale Dialogbox mit Textgröße, Tempo und Automatik der Einstellungen. Kein Rätsel, keine Zeit.

**Endlichkeit (§52).** Gäste und Gastwirt wiederholen sich in den Schleifen von A7 (dann wortgleich); bis dahin ist das Gespräch endlich: nach dem dritten
Antrag gibt es nur noch kurze Zeilen.

**Gerechnet.** 69 Zeilen, 675 Wörter, rund drei Minuten Weg: nach `calibrate.py` rund 6 Minuten bei normalem Tempo (Plan: 9). Die Lücke füllt das
Fest (A6), das den Gastwirt wieder braucht.

**Prüfungen.** `test_akt1_gasthaus` (15 Tests), `tools/autopilot/akt1_gasthaus.json` (Schritt „segment“ in `check.sh`: alle Marken in der Reihenfolge), `MapLint`
(Symmetrie, Erreichbarkeit), `StoryLint` (Flags, Cues, Türen).

---

## A3 Markt und Straße

**Stand:** gebaut. **Szene:** `world/levels/akt1/markt.tscn` (`MarktScene`), Karte `content/maps/markt.txt` (61 × 36, spiegelsymmetrisch um Spalte 30, Zoom 1,25), Dialog
`content/dialogue/akt1/markt.dialogue` (64 Zeilen, 10 Cues, alle `[#draft]`). **Zugang:** die Treppe am Südende des Gartens (Spalte 32, Reihen 34–35), Ankunft
`spawn_garden`; zurück durch das Tor in der Südmauer (Zelle 30, 35) zum Treppenabsatz `spawn_markt`.

**Zweck.** Die Stadt hinter dem Garten, die Ebene „Straße und Stadt“ der Raumschichtung (Plan 4.1). Sieben Rollen stehen zweimal da (Bible §9), und niemand
hat etwas gegen etwas: der Markt gibt, was man nicht braucht, und verlangt dafür Gold, das nichts bedeutet. Die Halle der Spiegel steht im Norden an der Mittelachse
und ist zu („geöffnet ab morgen“): die mechanische Herausforderung von Elysia (Wahrnehmung, A5) ist angekündigt; wer gegen die Türen drückt, sieht, dass sie nie abgeschlossen waren.

| Beat | Auslöser | Was geschieht | Marke |
|---|---|---|---|
| Betreten | Szene beginnt | der Platz, der Brunnen, zwei Torwächter am Tor; die Heldenquest rückt auf `market` | Beat `market_enter`, Flag `elysia.market_seen` |
| Begrüßung | Gespräch mit dem Torwächter (`gatekeeper`) | „Das Tor steht offen. Es stand immer offen.“ Die Halle öffnet morgen; danach nur noch ein Satz | `elysia.market_greeted`, +150 XP |
| Tafel | die Tafel (`board`) | drei Zettel (Nachmittag, Chor, „das Fest von gestern, das Fest von morgen“) und der Auftrag: Brot zur Schneiderin | Nebenquest `side_elysia_board`, Beat `market_board` |
| Brot | die Bäckerin (`baker`) | der Laib ist fertig, „wenn jemand danach fragt“ | Gegenstand `item_loaf`, Stufe `deliver`, Beat `market_bread` |
| Lohn | die Schneiderin (`tailor`) | sie hat das Brot gestern schon bekommen; der Lohn war abgezählt | Stufe `done`, +3.000 XP, +800 Gold, Beat `market_board_done` |
| Händler | `merchant` | ein Kompliment (zehn Gold), der Glücksbringer (hundertfünfzig); „Ich schaue nur.“ steht immer da | `WorldState.spend_gold`, `item_compliment`, `item_trinket`, Flag `elysia.market_shop_seen` |
| Melodie | die Musikerin (`musician`) | Zuhören gibt die perfekte Melodie, ohne Fehler | `melody.elysia_perfect`, +1.000 XP, Beat `market_melody` |
| Brunnen | `fountain` | eine Münze (zehn Gold) in das Becken; der Wunsch geht in Erfüllung, bevor man fertig ist | `spend_gold` |
| Halle | die Türen (`hall_door`) | ein Schild „geöffnet ab morgen“; Drücken öffnet sie, sie waren nie abgeschlossen; „Morgen wiederkommen“ lässt sie zu | `elysia.hall_open`, Beat `market_hall_open`; die Fassade zeigt die offene Tür, der Eingang erscheint auf den Stufen |
| Kleinigkeiten | Dichter, Blumenfrau | Reime ohne Neues, Blumen ohne Preis; mit der Facette „Wahrnehmung“ kann man dem Dichter sagen, dass es gestern schon da war | keine Flags |

**Heldenquest.** Die Stufe `market` (vorläufig final) folgt auf `celebrated` und auf `inn`. Wer den Markt vor der Truhe besucht, bekommt sie von der Truhe nachgetragen
(`ElysiaScene`: erst `inn`, dann `market`).

**Figuren.** Sieben neue Rollen (`tools/art/make_character.py`: Torwächter, Bäckerin, Händler, Blumenfrau, Schneiderin, Dichter, Musikerin), Stimmen `Torwächter`, `Bäckerin`,
`Händler`, `Blumenfrau`, `Schneiderin`, `Dichter`, `Musikerin`. Die Verkäufer stehen vor ihren Ständen, die Zwillinge in derselben Reihe, spiegelverkehrt.

**Humor-Ziel (3/10).** Zusagen, die sich selbst erfüllen: das Brot, das schon da war; der Wunsch, der in Erfüllung geht, bevor man ihn zu Ende gedacht hat; der Dichter,
dem nichts Neues einfällt und der das nicht für ein Problem hält. Gelacht wird über die Stadt, nie über den Gast.

**Gewicht (§45).** leicht; die dunkelste Zeile ist das Fest, das „von gestern und von morgen“ ist.

**Motive.** Spiegelung (alles zweimal), wortgleiche Sätze (`npc-bewegung`, `formulierungen`), die erste Melodie (`melodien`), Menschen ohne Nein (`kein-nein`); Vorausdeutung
auf das Fest (A6) und die Wiederholung (A7) in der Tafel.

**Scheitern und Speichern (§49).** Es gibt kein Scheitern: der Auftrag kann liegen bleiben, jede Antwort lässt sich lassen, ohne Gold bleibt „Ich schaue nur.“ Jede Beat-Marke speichert.

**Barrierefreiheit (§50).** Keine Zeit, kein Rätsel; Gold wird in Worten genannt, Antworten, die man nicht bezahlen kann, erscheinen nicht, statt grau zu stehen. Der Brunnen läuft als
Ortsklang (`water_loop`, Bus Ambience).

**Endlichkeit (§52).** Die Torwächter, die Bäckerin und die Schneiderin haben je drei Zeilen im Wechsel (`%`); die übrigen reden, bis sie es nicht mehr tun müssen; in den Schleifen von A7 sagen alle
dasselbe (wortgleich).

**Gerechnet.** 64 Zeilen, 702 Wörter, rund viereinhalb Minuten Weg (geschätzt, bis eine Aufnahme es misst): nach `calibrate.py` rund 9 Minuten bei normalem Tempo (Plan: 14). Der Rest ist
die Halle (A5) und das Fest (A6).

**Prüfungen.** `test_akt1_markt` (16 Tests), `tools/autopilot/akt1_markt.json` (Schritt „segment“ in `check.sh`: Beats und Begrüßung), `MapLint` (Symmetrie, Erreichbarkeit),
`StoryLint` (Flags, Cues, Türen).

---

## A5 Die Halle der Spiegel

**Stand:** gebaut. **Szene:** `world/levels/akt1/spiegelhalle.tscn` (`SpiegelhalleScene`), Karte `content/maps/spiegelhalle.txt` (33 × 42, drei Räume übereinander,
spiegelsymmetrisch um Spalte 16, Zoom 1,5), Dialog `content/dialogue/akt1/spiegelhalle.dialogue` (46 Zeilen, 8 Cues, alle `[#draft]`). **Zugang:** die Türen der Halle am Markt
(Zelle 30, 13, erst nach `elysia.hall_open`), Ankunft `spawn_markt` in der Vorhalle; zurück auf die Stufen (`spawn_hall`).

**Zweck.** Die mechanische Herausforderung von Elysia (Bible §59, Risiko 2): Wahrnehmung (Bible §16), „bemerken, was ist“. Alles in der Halle steht zweimal, links wie rechts, genau gleich;
je ein Raum hat einen Gegenstand, der nur auf einer Seite liegt (ein trockenes Blatt links, eine Feder rechts). Wer ihn bemerkt, öffnet das Tor zum nächsten Raum; der letzte Raum hat einen Spiegel,
der die Halle zeigt und nicht die Spielfigur. Die Aufgabe ist Sehen; es gibt kein Scheitern, keine Zeit, keinen Zähler.

| Beat | Auslöser | Was geschieht | Marke |
|---|---|---|---|
| Betreten | Szene beginnt | die Vorhalle: Säulen, Laternen, Kristalle, Pflanzen, jedes Ding zweimal; in der Mitte der Hallenwächter | Beat `hall_enter`, Flag `elysia.hall_seen`; die Heldenquest rückt auf `hall` |
| Der Wächter | Gespräch (`keeper`) | „Ich stehe in der Mitte. Darum gibt es mich nur einmal. Das ist die einzige Ausnahme, die ich kenne.“ Hilfe in drei Stufen, so oft man fragt: ein Hinweis, genauer, die Antwort; für den Raum, in dem man steht (Vorhalle, Galerie, Spiegelkammer) | `elysia.hall_met` |
| Raum 1 | das Blatt (`leaf`, links, zwischen den Säulen) | „Auf der anderen Seite der Halle liegt keines.“ Bemerken genügt; Aufheben macht es zur Kuriosität | `elysia.hall_room_1` (+1.500 XP, das Tor öffnet sich), Beat `hall_room_1`; `curiosity_dry_leaf`, `elysia.hall_leaf_taken` |
| Raum 2 | die Feder (`feather`, rechts, zwischen den Säulen) | dasselbe für die Galerie: „Die Halle hat keine Vögel.“ | `elysia.hall_room_2` (+2.000 XP, das zweite Tor), Beat `hall_room_2`; `curiosity_feather`, `elysia.hall_feather_taken` |
| Raum 3 | der große Spiegel (`mirror`) | „Dich zeigt er nicht.“ Weiter hinsehen schenkt die Facette; Wegsehen nimmt nichts, der Spiegel wartet | Facette `perception`, +5.000 XP, `elysia.hall_mirror_seen`, Beats `hall_mirror`, `perception` |
| Die Tore | `gate_shut` | „Es bleibt zu, bis dir etwas auffällt.“ | keine Flags |

**Neue Möglichkeit (Facette I, Bible §17).** Wahrnehmung I heißt in Akt I: Man darf sagen, was man bemerkt. Der Dichter im Markt hat eine vierte Antwort („Das hast du gestern auch gesagt.“), die nur mit der Facette
erscheint; A6 und A7 bauen darauf, dass die Wiederholung bemerkt werden kann.

**Heldenquest.** Die Stufe `hall` (vorläufig final) folgt auf `market`. Wer die Halle vor der Truhe betritt, bekommt die Stufen von der Truhe nachgetragen (`ElysiaScene`: `inn`, `market`, `hall`).

**Figuren.** Der Hallenwächter (neu, `keeper`, Stimme `Hallenwächter`): silbernes Haar, ein langer Umhang in Spiegelblau; ruhig, hat Zeit, hilft, ohne zu entscheiden.

**Humor-Ziel (2/10).** Ein Wächter, der jede Ausnahme verneint und selbst die einzige ist; ein Tor, das hört, was einem auffällt; ein Spiegel ohne Gast.

**Gewicht (§45).** mittel: „Dich zeigt er nicht.“ ist die ernsteste Zeile von Akt I bisher, freundlich gesagt und ohne Erklärung (Vorausdeutung auf Twist II, Motiv `spiegelung`).

**Motive.** Spiegelung (`sh_mirror_3`, `sh_mirror_5`; das Becken im Garten hat dich auch nicht gezeigt), perfekte Natur (das Blatt, die Feder: das Einzige, was altern oder fliegen durfte), wortgleiche Formulierungen
(„Fast.“).

**Scheitern und Speichern (§49).** Es gibt kein Scheitern: Der Wächter nennt die Antwort, wenn man sie will; die Tore öffnen, wenn man hinsieht, nicht wenn man etwas richtig macht; Wegsehen am Spiegel nimmt nichts. Jede Beat-Marke speichert.

**Barrierefreiheit (§50).** Die Aufgabe ist rein visuell, und der Wächter beschreibt sie in Worten (Hilfe in drei Stufen, jederzeit, unbegrenzt); die Antworten des Spiels hängen an der Dialogbox mit Textgröße, Tempo und
Automatik der Einstellungen. Das Tor öffnet sich mit Klang und kurzem Wackeln (Bildschirmwackeln folgt der Einstellung), und der Untertitel „Ein Tor öffnet sich.“ steht immer da. Keine Zeit, kein Rätsel mit Fehlversuch.

**Endlichkeit (§52).** Alles wiederholt sich nicht, es liegt einmal da: Blatt und Feder lassen sich mitnehmen, dann ist die Halle wieder so vollkommen wie vorher (in A7 wird sie es wortgleich).

**Gerechnet.** 46 Zeilen, 449 Wörter, rund viereinhalb Minuten Weg (geschätzt): nach `calibrate.py` rund 8 Minuten (Plan: 12); wer lange sucht, braucht mehr, mit Wächter weniger.

**Prüfungen.** `test_akt1_spiegelhalle` (13 Tests), `tools/autopilot/akt1_spiegelhalle.json` (Schritt „segment“ in `check.sh`), `MapLint` (Symmetrie, Erreichbarkeit; `SINGLE_CUES` kennt Blatt und Feder), `StoryLint`.

---

## A6 Das Fest

**Stand:** gebaut. **Szene:** dieselbe wie A3 (`markt.tscn`, `MarktScene`), im Festzustand; Karte `content/maps/markt.txt` (Requisiten mit `if: elysia.feast`), Dialog `content/dialogue/akt1/markt.dialogue`
(35 neue Zeilen, 3 neue Cues `host_feast`, `festmaster`, `feast_guest`, Festvarianten der fünf Rollen mit freien Zeilen, alle `[#draft]`). **Zugang:** kein eigener Ort: wer die Halle der Spiegel bemerkt hat
(`elysia.hall_mirror_seen`), findet den Markt beim nächsten Betreten im Festzustand (`elysia.feast`, gesetzt vor dem Bau der Karte).

**Zweck.** Elysia belohnt das Bemerken: Es feiert es. Die Belohnung wächst (rund 11.000 Erfahrung, 3.000 Gold), die Tat schrumpft (ein Glas heben; Bible §10, §8), und mit dem Hoch ist Level 48 sicher, auch wenn
alles Freiwillige ausgelassen wurde (Slice 22.600 + Fest 11.000 = 33.600, Level 48 ab 33.135); wer auch den Garten ausgelassen hat, bekommt vom Hoch nach den 11.000 genau das Fehlende bis Level 48 dazu (`WorldState.ensure_level`). Der Gastwirt lädt ein (der Betäuber, Bible §14), freundlich und nie verbindlich.

| Beat | Auslöser | Was geschieht | Marke |
|---|---|---|---|
| Festzustand | Markt betreten nach `hall_mirror_seen` | Girlanden, Tafeln mit Speisen, Gäste (zwei Paare), die Festmeisterin am Brunnen, der Gastwirt vor dem Brunnen | Flag `elysia.feast`, Beat `feast_enter` |
| Einladung | der Gastwirt (`host_feast`) | „Da ist er! Der Held des Tages! Jedes Tages!“ Annehmen sagt der Festmeisterin Bescheid (er hat es schon getan); Umschauen und Schweigen sind Antworten | `elysia.feast_invited` |
| Das Hoch | die Festmeisterin (`festmaster`) | „Du hebst das Glas, wir machen den Rest.“ Glas heben, später, oder (mit Wahrnehmung) „Das ist dasselbe Fest wie gestern.“ | `elysia.feast_toast`, +11.000 XP (und bis Level 48 aufgefüllt), +3.000 Gold, Beat `feast`; mit Wahrnehmung zusätzlich `elysia.feast_noticed` |
| Nach dem Hoch | der Gastwirt | „Du musst heute nicht zurück. Das Fest hat keinen Abend.“; hat die Spielfigur es bemerkt: „Das macht nichts. Hier darf man bemerken, so viel man will.“ | keine Flags |
| Festvarianten | Torwächter, Bäckerin, Schneiderin, Blumenfrau, Händler | je zwei bis drei freie Zeilen im Festzustand; die Gäste sagen alle dasselbe („Auf den Helden!“) | keine Flags |

**Heldenquest.** Die Stufe `feast` (vorläufig final) folgt auf `hall`; die Truhe trägt sie nach, wenn das Hoch vor der Truhe gehoben wurde (`ElysiaScene`: `inn`, `market`, `hall`, `feast`).
Die Schleifen (A7) beginnen bis dahin weiter am Slice-Auslöser.

**Figuren.** Die Festmeisterin (neu, `festmaster`, Stimme `Festmeisterin`): magentafarbene Jacke, hoher Zopf. Der Gastwirt, die Elysianer-Gäste und die fünf Rollen des Marktes kehren zurück.

**Humor-Ziel (3/10).** Eine Festmeisterin, die das Hoch schon vorher kennt („Er sagt immer vorher, was ich nachher sage.“); ein Fest, das größer ist als gestern, weil es gestern kleiner war; Gäste, die alle dasselbe rufen.

**Gewicht (§45).** leicht; die dunkelste Zeile ist die des Gastwirts („Das Fest hat keinen Abend.“), freundlich gesagt, wie alle Angebote des Betäubers.

**Motive.** Der Betäuber (`betaeuber`, Wiederholung seiner Sätze), wortgleiche Sätze (`npc-bewegung`, `formulierungen`), Wahrnehmung (die vierte Antwort); die Wiederholung wird in A7 zur Aufgabe.

**Scheitern und Speichern (§49).** Es gibt kein Scheitern: das Hoch lässt sich vertagen („Später“), ohne Einladung, ohne Folgen. Das Hoch speichert über den Beat `feast`.

**Barrierefreiheit (§50).** Keine Zeit, keine Geschicklichkeit; die Gläser klingen als Text („Es klingt dreimal gleich.“); das Fest bringt keinen neuen Blitz und kein Wackeln des Bildes; die Girlanden wiegen sich wie alle Pflanzen leicht im Wind.

**Endlichkeit (§52).** Das Hoch wird einmal gehoben und einmal bezahlt; die Festmeisterin hat danach eine feste Zeile (A7: der wortgleiche Gruß).

**Gerechnet.** 35 neue Zeilen, 401 Wörter, rund drei Minuten Weg (geschätzt): nach `calibrate.py` rund 6 Minuten (Plan: 14). Akt I liegt damit nach A6 bei rund 29 statt 49 Minuten Plan; die Neuplanung (P6.13)
entscheidet, ob A4 (Minispiel) oder mehr Erkundung die Lücke füllt.

**Prüfungen.** `test_akt1_fest` (14 Tests, darunter „Level 48 ist sicher“ für beide Wege), `tools/autopilot/akt1_fest.json` (Schritt „segment“ in `check.sh`), `MapLint` (Zwillinge der Festgäste, Mittelachse), `StoryLint`.

---

## A7 Wiederholung

**Stand:** gebaut. **Szene:** kein eigener Ort; die Schleifen sind ein Zustand aller Elysia-Szenen (`elysia`, `gasthaus`, `markt`, `spiegelhalle`), geregelt vom `ElysiaDirector`. **Dialog:** neun wortgleiche
Zeilen in `markt.dialogue`, `gasthaus.dialogue` und `elysia.dialogue` (alle `[#draft]`).

**Zweck.** Nach dem Hoch wiederholt sich Elysia (Bible §35, §56 Beat 2): dieselben Sätze, wortgleich, jedes Mal. Die Musik ist schon seit dem Markt kürzer geworden; jetzt wird auch das Reden eine Schleife. Das Kind
(A8) zeigt sich erst jetzt. Nichts im Hauptweg hängt an einem Angebot (Bible §14): wer das Hoch auslässt, bleibt in Elysia, und die Uhr (eine Stunde) öffnet den Rückweg trotzdem.

| Beat | Auslöser | Was geschieht | Marke |
|---|---|---|---|
| Musik 1 | der Markt wird betreten (`elysia.market_seen`) oder 20 Minuten | die Musikschleife ist halb so lang | Flag `elysia.loops_1` |
| Die Schleife beginnt | das Hoch (`elysia.feast_toast`) oder 60 Minuten Spielzeit | jede Rolle sagt nur noch einen Satz, jedes Mal denselben; das Kind erscheint | Flag `elysia.loops`, Beat `irritation`, Heldenstufe `repeat` |
| Musik 2 | der Stein (`elysia.stone_taken`; er liegt erst nach dem Hoch, A9) oder 40 Minuten | ein Viertel der Schleife | Flag `elysia.loops_2` |
| Der Riss | das Kind folgt (A8, A9), sonst 15 Minuten nach dem Beginn der Sätze (die Wartezeit läuft über die Szenen hinweg) | der Riss öffnet sich; durch die Uhr mit Beben und Untertitel in jeder Elysia-Szene | `elysia.rift_open`, Beat `rift_found` |

**Wortgleiche Zeilen** (Schleife 1, gewählt allein von `elysia.loops`; Schleife 2 mit `elysia.rift_open` kommt in A9 für den Torwächter und den Gastwirt): Torwächter (`mk_gate_10`), Bäckerin (`mk_baker_8`), Schneiderin (`mk_tailor_9`), Blumenfrau
(`mk_flower_6`), Händler (Begrüßung, `mk_shop_8`; der Laden bleibt offen), Festmeisterin (`mk_fest_9`, die eine Zeile nach dem Hoch: ihr Gruß, als wäre es das erste Mal), Gastwirt im Gasthaus (`gh_host_loop_1`, `gh_host_loop_2`), Gärtnerin, solange die Schmetterlinge
frei sind (`el_gard_loop`). Jede Schleifenzeile ist eine, die die Person schon gesagt hat, Wort für Wort: bei fester Rede die erste (Torwächter: der Willkommensgruß, Festmeisterin: der Gruß des Festes, Händler, Gastwirt), bei Zufallsrede die erste der Reihe (Bäckerin, Schneiderin, Blumenfrau), bei der Gärtnerin ihre Wartezeile; ein Test prüft den Wortlaut gegen die jeweilige Zeile. Was die Person schuldet (der Laib, das Angebot der Gärtnerin, der
Laden) steht in den Dialogen vor der Schleife und geht nicht verloren; die Gäste im Gasthaus und die Elysianer im Garten hatten sie schon.

**Heldenquest.** Die Stufe `repeat` (vorläufig final) folgt auf `feast`; der Markt rückt beim Hoch von `feast` auf `repeat`, die Truhe trägt beide nach.

**Figuren.** Keine neuen.

**Humor-Ziel (3/10).** Je öfter sie es sagen, desto weniger ist es ein Witz: der Humor liegt in der Tonlage, nicht im Text (Bible §35: erst hübsch, dann zu vollkommen).

**Gewicht (§45).** mittel: die Schleife ist die erste Beunruhigung, ohne dass jemand etwas Böses sagt.

**Motive.** Wortgleiche Sätze (`npc-bewegung`), die Schleife der Musik (`loop-musik`), der Betäuber (der Gastwirt sagt, was er zuerst sagte).

**Scheitern und Speichern (§49).** Es gibt kein Scheitern; die Schleifen speichern über `elysia.loops`; ein Stand vom Hoch ohne Schleifen (Spielstand vor A7) beginnt sie beim Laden.

**Barrierefreiheit (§50).** Kein Blitz, kein Wackeln: die Wiederholung ist Text und Musik. Die Musikstufen wechseln am Ende der Schleife (auf dem Taktschlag).

**Endlichkeit (§52).** Die Schleife ist das Ende des Redens in Elysia: danach sagt niemand etwas Neues; was kommt, kommt vom Kind.

**Gerechnet.** Neun Zeilen, rund 100 Wörter: zwei Minuten (Gespräche mit der Wiederholung). Akt I liegt damit nach A7 bei rund 31 statt 58 geplanten Minuten (A2 bis A7); A8 und A9 sind noch offen.

**Prüfungen.** `test_akt1_wiederholung` (13 Tests), `test_elysia_director` (Hoch beginnt die Sätze, lange Uhr), `tools/autopilot/akt1_wiederholung.json` (Schritt „segment“ in `check.sh`), der Slice-Durchlauf (`slice_full.json` setzt das Hoch als Flag).

---

## A8 Kind-Spur

**Stand:** gebaut. **Szenen:** kein eigener Ort; drei Stationen in vorhandenen Karten (`markt`, `gasthaus`, `spiegelhalle`) und die Melodie im Garten (`elysia`). **Dialog:** `content/dialogue/akt1/kind.dialogue`
(drei Cues, zwölf Zeilen, alle `[#draft]`) und eine Zeile mehr im Kind-Gespräch des Gartens (`el_child_4`). **Karte:** je ein Einzelstück (`child_guide.tscn`, `if: elysia.loops`, `unless: fragment.<bild>`): `markt` Zelle (32, 33), `gasthaus` (17, 8), `spiegelhalle` (14, 8).

**Zweck.** Nach dem Hoch wiederholt sich Elysia; das Kind ist der Einzige, der sich nicht wiederholt (Bible §15). Es zeigt drei Bilder aus der Liste der Bible, ohne ein Wort der Erklärung: einen Flur, eine geschlossene Tür, ein leeres Zimmer.
Die Bilder sind Fragmente des Hauses, das der Spielerin später gehört (Bible §38); hier sind es Eindrücke, keine Ursache, keine Diagnose, keine Tat. Hand, Verstecken und das ursprüngliche Haus bleiben Akt V.

| Beat | Auslöser | Was geschieht | Marke |
|---|---|---|---|
| Das Summen | das Hoch (`elysia.loops`, A7) | irgendwo summt jemand; das Tagebuch führt „Das Summen“ | Quest `main_elysia_trail`, Stufe `hum` |
| Der Flur | das Kind im Gang vor dem Südtor des Marktes ansprechen | „Komm.“ – ein Flur, länger als der Gang; das Kind geht | Flag `fragment.hallway`, Beat `trail_hallway`, Stufe `trail` |
| Die Tür | das Kind hinter dem Tresen im Gasthaus ansprechen | „Leise.“ – eine geschlossene Tür; das Kind geht | Flag `fragment.closed_door`, Beat `trail_door`, Stufe `trail` |
| Das Zimmer | das Kind vor dem großen Spiegel der Halle ansprechen | „Hier.“ – ein leeres Zimmer; das Kind geht | Flag `fragment.empty_room`, Beat `trail_room`, Stufe `trail` |
| Die Melodie | der letzte Satz des Kindes im Garten (`elysia.child_met`, Slice) | „Es ist die Melodie, der du gefolgt bist. Du kannst sie jetzt.“ | Flag `melody.child_hum`, Beat `child_melody` |
| Der Riss | das Kind verschwindet im Garten, sonst die Uhr (A7) | der Riss öffnet sich | `elysia.rift_open`, Beat `rift_found`, Stufe `rift` (final) |

**Fragmentkarte.** Jedes Bild erscheint als leise Karte oben im Bild: das Bild in 64 Pixeln, darunter „Etwas fällt dir ein.“ (3,6 Sekunden Spielzeit, kein Klang, kein Zähler, keine Seltenheit; der Hud hört auf Flags mit dem Präfix `fragment.`).
Die Bilder liegen als Text in `tools/art/small/fragment_*.pix` und werden von `pixelgrid.py` geprüft (Größe, Palette, Umriss; ADR-057).

**Reihenfolge.** Die drei Stationen sind unabhängig und jede freiwillig (Bible §14, §31): kein Bild sperrt etwas, der Riss wartet auf keines (die Uhr aus A7 und das Verschwinden des Kindes im Garten öffnen ihn). Wer einem Kind folgt, hat danach einen Satz zum Erinnern;
wer nicht, verpasst nur das Bild. Jede Station gibt es nur, solange sich Elysia wiederholt (`elysia.loops`), und nur einmal (`unless fragment.<bild>`).

**Heldenquest und Spur.** Die Heldenquest `main_elysia_hero` bleibt auf `repeat` stehen. Die Spur ist eine eigene Hauptquest `main_elysia_trail`: `hum` → (`trail` →) `rift`; `rift` ist final. Sie beginnt mit der Schleife (`begin_loops`, und beim Laden eines Standes aus der Schleife vor A8), `trail` kommt mit dem ersten Bild, `rift` mit dem Riss.

**Figuren.** Das Kind (`child_guide.tscn`, Blattdatei `sheet_child_look.tres`; es schaut den Spieler an, wenn er nahe ist, und geht, sobald es gezeigt hat, was es zeigt).
Sprecher „Kind“ spricht höchstens drei Wörter, antwortet nicht, lobt und tröstet nicht (`docs/writing/stimmen/kind.md`).

**Humor-Ziel (0/10).** Keiner. Die Lage ist leise; die Wärme kommt aus der Ruhe der Erzählzeilen („Du klopfst nicht. Das Kind auch nicht.“).

**Gewicht (§45).** mittel bis schwer: drei Bilder mit Schweigen darin, jedes kurz. Eine Station dauert unter einer Minute; zwischen ihnen liegen Orte voller Wiederholung, nicht voller Last.

**Motive.** Das Kind und seine Fragmente (`kind-fragmente`: Flur, Tür, leeres Zimmer), das Summen (`kind-lied`, `melodien`: die zweite Melodie des Aktes), Spiegelung (das Kind steht vor dem Spiegel, im Spiegel steht ein Kind: das Bild ist zugleich Vorausdeutung auf Akt V).

**Prüflinse Kind und Sensibilität (§15, §51).** Kein Täter, keine Tat, keine Ursache, keine Einordnung; Bilder aus der Liste der Bible, nicht erfunden; keine Zahl und kein „Sammeln“ (kein Zähler, kein Klang, keine Auszeichnung); das Kind zwingt nichts, bietet nichts an, belohnt nichts; wer wegsieht, verliert nichts.
Die Karte sagt „Etwas fällt dir ein.“, nicht „Erinnerung“ (Bible §38: das Haus wird nie erklärt).

**Scheitern und Speichern (§49).** Es gibt kein Scheitern. Jedes Bild speichert mit seinem Flag und löst einen Autosave aus (`Beat.mark`); ein Stand aus der Schleife ohne Spur (A7-Stand) bekommt die Quest beim Laden, und steht gleich auf `rift`, wenn der Riss schon offen ist.

**Barrierefreiheit (§50).** Kein Blitz, kein Wackeln; die Karte ist Bild und Text (der Text allein trägt den Sinn, das Bild ist Zugabe); alle Zeilen laufen über die Dialogbox mit allen Tempo- und Auto-Einstellungen.

**Endlichkeit (§52).** Drei Bilder, je einmal; danach steht das Kind nicht mehr da. Das Summen bleibt eine Melodie, keine Quelle.

**Gerechnet.** Zwölf Zeilen plus eine, rund 110 Wörter; die Wege zwischen den drei Stationen sind der größte Teil: `calibrate.py --segment 110 13 5` (fünf Minuten reiner Weg zwischen Garten, Gasthaus, Markt und Halle) ergibt rund acht Minuten (bei einer Station weniger rund sechs). Gegen zwölf geplante ist das wenig, weil die Orte schon stehen und das Kind sie nur zeigt. Akt I liegt damit nach A8 bei rund 40 statt 70 geplanten Minuten (A2 bis A8); die Neuplanung (P6.13) entscheidet, ob A4 oder mehr Erkundung die Lücke schließt.

**Prüfungen.** `test_akt1_kind_spur` (11 Tests: Stationen nur in der Schleife, einmal je Bild, drei Fragmente ohne Zähler, höchstens drei Wörter, Quest, Uhr ohne Bilder, Melodie, Karte), die drei Segmentskripte `tools/autopilot/akt1_kind_spur_{markt,gasthaus,spiegelhalle}.json` (Schritt „segment“ in `check.sh`, Marken `trail_*`), `test_writing`, `MapLint` (das Kind ist ein Einzelstück ohne Zwilling, wie der Stein).

---

## A9 Stein, Samen, Riss

**Stand:** gebaut. **Szene:** kein neuer Ort; der Garten (`elysia`, die Zellen am Becken und am Inselrand) und zwei Sätze der Schleife 2 (`markt`, `gasthaus`). **Dialog:** drei neue Zeilen (`el_wake_seed` in `slice/elysia.dialogue`, `mk_gate_11` und `mk_fest_11` in `akt1/markt.dialogue`), eine Bedingung an `host_loop` (`gasthaus.dialogue`: die erste Zeile entfällt, sobald `elysia.rift_open`); alle `[#draft]`. **Karte:** `elysia.txt` (Stein und Zeile zum Stein mit `if: elysia.loops`).

**Zweck.** Der Anschluss macht aus den drei Stücken des Slice (Stein, Kind, Riss; Bible §11, §30, §56) die Folge, die Akt I braucht: erst die Wiederholung, dann der Stein, dann das Kind, dann der Riss. Nichts davon ist neu gebaut; A9 ordnet es und füllt zwei Lücken: der Samen hat in Elysia keine Stimme, und die Schleife 2 (Plan 4.4: „normal, Schleife 1, Schleife 2“) hat bisher nur die Zeile im Garten.

| Beat | Auslöser | Was geschieht | Marke |
|---|---|---|---|
| Der Samen | das Erwachen (Slice, A1) | der Samen ist schon im Gepäck; der Elysianer nimmt ihn für Elysia in Anspruch: „Aus unserem Garten, natürlich.“ | Zeile `el_wake_seed`, nur mit `item_seed`; kein Flag |
| Der Stein | die Wiederholung beginnt (`elysia.loops`) | am Becken liegt der Stein, daneben die Zeile „Ein Stein. Grau. Das Einzige hier, das nicht glänzt.“; er liegt neben der Stelle, an der das Kind steht | Flag `elysia.stone_taken`, Beat `stone`, Musikstufe 2 (`elysia.loops_2`) |
| Das Kind | der Stein oder nicht (A8) | das Kind führt zum Inselrand | `elysia.child_met`, `elysia.child_vanished`, Beat `child`, `child_melody` |
| Der Riss | das Kind verschwindet oder die Uhr (A7) | der Riss öffnet sich; wer ihn berührt, geht hinüber und nimmt Stein und Samen mit, sonst nichts | `elysia.rift_open`, Beat `rift_found`, `elysia.rift_crossed`, Beat `valley_arrival` |
| Schleife 2 | der Riss ist offen (`elysia.loops` und `elysia.rift_open`) | der Torwächter sagt nur noch „Das Tor ist offen. Wie immer.“; die Festmeisterin nur noch ihr dreifaches Hoch; der Gastwirt nur noch den zweiten seiner beiden Sätze | Zeilen `mk_gate_11`, `mk_fest_11`, `gh_host_loop_2` |

**Der Stein erst nach dem Hoch.** Im Slice lag der Stein von Anfang an am Becken, und wer ihn früh nahm, verkürzte die Musik, bevor irgendjemand sich wiederholte. Bible §56 ordnet: Wiederholung, fehlende Spiegelung, Stein, Kind, Riss. Der Stein liegt darum erst, wenn sich Elysia wiederholt (Flag `elysia.loops` an seiner Karteneinfügung und an der Zeile zum Stein). Ein Stand, der ihn früher genommen hat, behält ihn.

**Der Samen ohne Mechanik.** Der Samen ist nach Bible §30 vor der ersten Erinnerung an Elysia da. Elysia bekommt dafür einen Satz, keine Handlung: sie hält ihn für ihren. Das Haus widerspricht später, ohne zu erklären (`haus_rest_4`: „Du weißt nicht, seit wann er da ist.“). Kein Flag, kein Beet, kein Pflanzen (ADR-042, Bible §29: der Garten wächst in Akt V).

**Schleife 2.** Nach ADR-064: Schleife 2 ist ein ganzer Satz, den die Person schon gesagt hat, wortgleich, und höchstens halb so lang wie ihr Satz der Schleife 1; die Sätze schrumpfen mit der Musik (19, 10, 5 Sekunden). Das trifft drei Personen: den Torwächter (`mk_gate_11`, 6 statt 12 Wörter, ein Satz seiner Reihe), die Festmeisterin (`mk_fest_11`, ihr Hoch: 9 statt 20 Wörter) und den Gastwirt im Gasthaus (nur der zweite seiner beiden Sätze, `gh_host_loop_2`, 11 statt 26 Wörter).
Alle anderen haben keinen halb so langen Satz und bleiben bei Schleife 1: die Bäckerin (4 Wörter, schon die kürzeste), die Blumenfrau (9, die kürzeste), die Schneiderin (13 gegen 10), der Händler (13 gegen 9), die Gärtnerin (13 gegen 10), die Gäste (13 gegen 12) und der Gastwirt im Garten (`el_host_loop_1` bis `3`, jede ist schon kurz). Die Zeile im Garten (`el_loop_2`, „Ganz unten rechts … Bleib lieber hier bei uns.“) bleibt die Ausnahme: sie weist auf den Riss.

**Der Übergang.** Beim Überschreiten bleibt nur, was die Bible nennt: der Stein und der Samen (`RiftSequence.KEEP`). Blatt und Feder aus der Halle bleiben in Elysia zurück: die Bible (§11) nennt nur Stein und Samen. (Die Gegenstände zeigen keinen Zähler; die Beschreibungen versprechen kein Regal.)

**Heldenquest.** Unverändert: `repeat` ist die letzte Stufe von `main_elysia_hero`; die Spur (`main_elysia_trail`) endet am Riss.

**Figuren.** Keine neuen.

**Humor-Ziel (2/10).** Der Anspruch auf den Samen („Du denkst an alles.“) und das Tor, das „wie immer“ offen ist, während etwas am Rand aufgeht.

**Gewicht (§45).** leicht bis mittel: der Stein und der Samen sind die ersten Dinge, die nicht zu Elysia gehören, und niemand sagt es.

**Motive.** `stein`, `samen` (die erste Erwähnung ist falsch: Elysia nennt ihn den ihren), Wiederholung in Schritten (`loop-musik`, `npc-bewegung`), das Kind (`kind-lied`).

**Scheitern und Speichern (§49).** Es gibt kein Scheitern. Der Stein speichert mit `elysia.stone_taken` und löst einen Autosave aus; der Samen braucht keinen Stand; ein Stand mit früh genommenem Stein lädt ohne Reparatur.

**Barrierefreiheit (§50).** Keine neue Zeitnot; der Stein ist ein gewöhnliches Aufnehmen mit Beutekarte und Text; die Schleife 2 ist Text.

**Endlichkeit (§52).** Ein Stein, ein Samen, ein Riss; Schleife 2 gibt es nur dort, wo ein halb so langer Satz da ist.

**Gerechnet.** Drei neue Zeilen, 29 Wörter; `calibrate.py --segment 29 3 2` ergibt rund drei Minuten bei zwei Minuten Weg, davon liegt der Weg zum Riss schon im Slice: neu kommt rund eine Minute dazu. Akt I liegt damit (A2 bis A9) bei rund 42 statt 75 geplanten Minuten; P6.13 misst und entscheidet über A4 und mehr Erkundung.

**Prüfungen.** `test_akt1_anschluss` (13 Tests: kein Stein vor der Schleife, Stein und Zeile mit der Schleife auf der Zelle (41, 17), Musikstufe 2 durch den Stein, früh genommener Stein bleibt genommen, Samen-Zeile mit und ohne Samen, Schleife 2 für Torwächter, Festmeisterin und Gastwirt und ihre Länge, nichts vor der Schleife, Übergang lässt Blatt und Feder zurück), das Segmentskript `tools/autopilot/akt1_anschluss.json` (Schritt „segment“ in `check.sh`: Erwachen, Hoch, Stein, Kind, Riss, Tal), `test_elysia_and_rift`, `test_slice_saves`.
