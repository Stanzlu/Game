# Akt I (Elysia): Regionsbriefe

Je Segment ein Brief nach Abschnitt 4.5 des Produktionsplans: Beat-Tabelle, Flags, Figuren, Humor-Ziel, Gewicht, Motive,
Scheitern und Speichern, Barrierefreiheit, Endlichkeit. Briefe sind verbindlich, sobald das Segment gebaut ist; Änderungen
im Pull Request des Segments. Zeiten rechnet `tools/writing/calibrate.py` (`docs/KALIBRIERUNG.md`).

## Der Fluss von Akt I

Die Heldenquest `main_elysia_hero` wächst mit den Segmenten um eine Stufe je Ort; die Schleifen (A7) beginnen erst nach dem Fest.

| Stufe | Segment | Ort (Szenenschlüssel) | Beat | Stand |
|---|---|---|---|---|
| greet, butterflies, reward, celebrated | A1 Erwachen und Garten | `elysia` | `elysia_start` … `butterflies_caught` | vorhanden |
| inn | A2 Gasthaus | `gasthaus` | `inn_enter`, `inn_fed`, `inn_room`, `inn_slept` | **gebaut (ADR-058)** |
| market | A3 Markt und Straße | `markt` | `market_enter`, `market_board`, `market_bread`, `market_board_done`, `market_melody` | **gebaut (ADR-059)** |
| hall | A5 Spiegelhalle | `spiegelhalle` | | geplant |
| feast, repeat | A6 Fest, A7 Wiederholung | `markt` (Festzustand), alle Orte | | geplant |
| trail, rift | A8 Kind-Spur, A9 Stein, Samen, Riss | `gasthaus`, `markt`, `spiegelhalle`, `elysia` | | geplant |

Raumschichtung (Plan 4.1): Zimmer (Gasthaus) – Mauer und Tor – Garten – Straße – Stadt (Markt) – Welt (Weltenbaum), unbeschriftet.
Bis zu A7 beginnen die Schleifen noch mit Truhe und Schmetterlingen (Slice-Stand); A7 verlegt den Auslöser auf die Stufe `repeat`.

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
mit verschlossenen Türen („geöffnet ab morgen“): die mechanische Herausforderung von Elysia (Wahrnehmung, A5) ist angekündigt, aber noch zu.

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
| Kleinigkeiten | Dichter, Blumenfrau, Halle (`hall_door`) | Reime ohne Neues, Blumen ohne Preis, ein Schild, das schon lange dort steht | keine Flags |

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

