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
| market | A3 Markt und Straße | `markt` | | geplant |
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
endet die Quest vorläufig („done“), bis A3 die Stufe `market` anhängt.

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
