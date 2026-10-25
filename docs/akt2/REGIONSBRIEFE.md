# Akt II (Riss und Tal): Regionsbriefe

Je Segment ein Brief nach Abschnitt 4.5 des Produktionsplans, wie in `docs/akt1/REGIONSBRIEFE.md`: Beat-Tabelle, Flags, Figuren, Humor-Ziel, Gewicht, Motive,
Scheitern und Speichern, Barrierefreiheit, Endlichkeit. Der Brief eines Segments wird hier verbindlich, sobald es gebaut ist; Änderungen im Pull Request des Segments.
Zeiten rechnet `tools/writing/calibrate.py` (`docs/KALIBRIERUNG.md`); seit ADR-066 stehen die Modellminuten neben der geplanten Zahl, und gebaut wird nach Zeilen, Karten, Requisiten und Pull Requests.

**Stand (V0, ADR-067):** Brief und Anschluss-Daten sind gebaut. Geplant (Plan 5.1): 90 Minuten, Humor 3, „UI-Verlust, Wetter, Mira, erstes Nein, Haus, Wahrnehmung“, Tal plus 1–2 Karten der Klasse M.

## Was Akt II schon hat

Die Wirklichkeits-Hälfte des Slice ist Akt II im Rohbau: **354 Zeilen** (`tal.dialogue` 189, `haus.dialogue` 124, `antreiber.dialogue` 41), alle noch nicht eingefroren, im Modell **rund 16 Minuten**.

| Beat des Plans | Stand | Ort |
|---|---|---|
| UI-Verlust beim Überschreiten des Risses | vorhanden | `RiftSequence`, HUD |
| Ankunft im Tal, Regenwetter, Bachlauf, Trittsteine | vorhanden | `tal` (68 × 38) |
| Mira, erster Tag, das erste Nein | vorhanden, rund 106 Zeilen | `tal`, `haus` |
| Antreiber (Warum, Weg zum Schuppen, Platz am Feuer) | vorhanden | `weg`, `haus` |
| Haus: kalter Kamin, Feuer, Regal mit zwei Plätzen, Katze | vorhanden | `haus` (40 × 24) |
| Abend am Feuer, Mira-Besuch, Ende „Zum Meer.“ | vorhanden | `tal`, `haus` |
| Ziege und Kartoffel | vorhanden | `tal` |
| Wetter | drei Voreinstellungen (Regentag, Abend, Nacht) | `DayLight` |
| „Erste Sicherheit“ (Bible §37; der Plan nennt sie nicht): das erste Mal, dass das Feuer hält und jemand bleibt | vorhanden als Szene `fire_rest`, ohne eigene Marke; B5 gibt ihr den Beat `act2_safe` | `haus` |
| Wahrnehmung in der Wirklichkeit | **dünn**: die Funde des Tals (Moosregel, Stiefelabdruck, Muschel mit Riss) sehen alle, die Facette wird nur in Akt I gelesen; die Muschel hängt an `tal_end_8` | `tal` |
| Grenzen als echte Möglichkeit (das Nein als Antwort) | **dünn**: gesetzt am Ende des Abends, kein Leser | `tal.dialogue` |
| Richter | **fehlt** (Stimmenblatt ohne Beleg) | – |
| Werte beim ersten Abend am Feuer (Bible §18) | **fehlt** | – |
| Lied des Kindes im Haus (`melody.child_hum` wird nur im Tal gelesen, von B1 in `ank_hum_1`; im Haus nirgends) | **fehlt** | – |
| Karte der Klasse M (Plan: Tal plus 1–2) | **fehlt** | – |
| Sammelstücke: Nebenquests 1 von 2, Kuriositäten 1 von 6, Fragmente 0 von 3, Melodien 0 von 1 | teilweise | – |

Was bleibt, wie es ist: alle 354 IDs (nie umbenennen, nur `id_lock.py --retire`), die Szenenschlüssel `tal`, `haus`, `weg`, `tal_mira_7/8`, `tal_end_5/8/10` („Nein.“, „Zum Meer.“), `tal_fell_1` bis `5`, die Flags `valley.*`, `house.*`, `elysia.*`, `slice_full.json`, die Prüfung „vertical slice finished“ und das eingefrorene `v2_slice_end.json`. `tools/art/layout_slice_maps.py tal --write` löscht Handänderungen in `tal.txt`: Änderungen dort von Hand, danach neu backen.

## Der Fluss von Akt II

| Segment | Inhalt | Ort | Neue Zeilen | Pull Requests | Stand |
|---|---|---|---|---|---|
| V0 | Brief, Kapitelmarke `act1`, eingefrorener Stand `v2_akt1_end.json`, ADR-067 | – | 0 | 1 | **gebaut** |
| V1 | T6 Großkarten-Spike und T7 (nur der kleine Teil) | – | 0 | 1 | **gebaut** (ADR-068, `docs/PERFORMANCE.md`: Klasse M bis 120 × 70, Aufbau rund 0,5 s) |
| B1 | Ankunft: die Wirklichkeit antwortet auf Elysia | `tal` | 6 (geplant 15) | 1 | **gebaut** (6 Zeilen, 0,5 Modellminuten) |
| B2 | Nein und Blick: Grenzen als echte Möglichkeit, Wahrnehmung in der Wirklichkeit | `tal`, `haus` | 25 | 1 | geplant |
| B3 | Bachlauf: die erste Karte der Klasse M, Nebenquest, Kuriositäten, Nebel | `bachlauf` (neu) | 62 | 1 | geplant |
| B4 | Richter: eine Stimme nach dem zweiten Sturz | `tal` | 12 | 1 | geplant (Cut-First-Platz 2) |
| B5 | Feuer: Werte, das Lied im Haus, ein Fragment | `haus` | 30 | 1 | geplant |
| B6 | Abend und Anschluss: Mira liest die Werte, Kapitelmarke `act2` | `tal` | 18 | 1 | geplant |
| B7 | Durchlauf: `akt2_full.json`, Lesefassung, Messung | – | 0 | 1 | geplant |
| **Summe** | | | **153** (geplant 162) | **9** | |

**Budget.** 354 vorhandene plus 153 neue Zeilen sind 507 von den im Plan abgeleiteten 557 (91 %); im Modell rund 22 Minuten (16 für die vorhandenen 354 Zeilen nach `calibrate.py`, dazu 153 / 24) gegen 90 geplante. Die Lücke von rund 68 Minuten kommt nicht aus Text (ADR-066, Plan 10.1);
Bible §43 und §59 verbieten, sie mit Gehen zu füllen. Rund 14 neue Tests je Segment. Mit einer zweiten Karte (B3b) wären es 569 Zeilen und 10 Pull Requests, mit dem Pull Request für das Streuen der Karten (T6.3, nur wenn V1 es verlangt) 11. **Auslöser für Cut-First:** mehr als 11 Pull Requests oder mehr als 700 Zeilen im Akt (Bestand plus neu).

**Reihenfolge.** V0, V1, B1, B2, B3, B5, B6, B4 (nach B6, damit der Abend zuerst steht), B7. B1 und B2 können vor V1 gebaut werden, wenn der Leistungstest auf dem Mac auf sich warten lässt.

**Speicher-Frage in jedem Segment:** Benennt oder ändert dieser Akt ein gespeichertes Feld? Dann Schema 3 mit Migrationstest (Plan T9). Vorgabe für Akt II: nein; neue Felder sind additiv und optional (`docs/SAVE_FORMAT.md`, Vorbild `cat_name`), Werte sind Flags `value.<id>`.

## Vorgaben und Voreinstellungen (ADR-067)

Wo die Quellen sich widersprechen oder eine Weiche offen ist, gilt die Voreinstellung; jede ist umkehrbar und steht in Plan 11, Frage 7.

| Nr | Frage | Voreinstellung |
|---|---|---|
| O1 | Wo endet Akt II? | Das Ende des Slice bleibt der Schluss („Zum Meer.“, Schwarz, Titel), dazu die Kapitelmarke `act2`; die Prüfung „vertical slice finished“, der Schutz gegen doppeltes Enden und `v2_slice_end.json` bleiben. Ein Übergang in den Wald wäre ein ADR-030-Nachtrag. |
| O2 | Ton und Auslöser des Richters | Nur Text unter dem Sprecher „Stimme“, im Aktenton, über Dinge, nie über die Spielerin; Auslöser ist der **zweite** Sturz in den Bach (nicht der erste: `tal_fell_*` bleibt kalt und komisch), nie nahe Mira, ihrem Nein oder dem Rennen. Wer nie zweimal fällt, trifft ihn nicht; Akt IV führt ihn ohnehin selbst ein. Bible §51 und `STIL.md` sind die Leitplanken. |
| O3 | Form der Werte (Bible §18) | Drei bis vier konkrete Wahlmöglichkeiten am Feuer, je ein Wert, kein Test, keine Zahl (ADR-042 verwarf den Persönlichkeitstest); jede Wahl hat eine andere Folge. |
| O4 | Eine oder zwei Karten der Klasse M? | Eine (`bachlauf`). Die zweite (B3b) erst nach deinem Durchlauf und einem Leistungstest auf dem Mac. |
| O5 | Fragmente und das Lied | Das Lied im Haus ist hörbar und kein Fragment; die drei Fragmente von Akt II sind Spuren der Welt und der Vergangenheit, keine Bilder des Kindes (Plan 4.4: die Bilder des Hauses bleiben Akt V). `MOTIVE.md` und Plan 5.5 werden in B5 angeglichen. |
| O6 | Richtung der neuen Karte | Südlich am Bach entlang, abends nach dem Besuch von Mira. |
| O7 | Einfrieren des Slice-Textes | Dein „OK“ auf `docs/lesefassung/SLICE.md`; kein Hindernis, aber neue Zeilen zitieren noch ungefrorenen Text. |
| O8 | Blatt und Feder aus Akt I | Bleiben in Elysia (ADR-064): nur Stein und Samen kommen über den Riss. |
| O9 | Pläne zu Länge und Nachspiel (Plan 11, Fragen 3 bis 6) | „Weiter“: nach Abschnitt 5 weiterbauen, keine Länge ändern. |

**Ohne Rückfrage entschieden:** T7 nur zum kleinen Teil (die Bake-Messtabelle und die Regel, dass das Layout einer Karte in einem Pull Request landet; der große Baker mit eigenen Zufallsströmen je Durchgang kommt mit der ersten Karte der Klasse L, Akt IV);
kein Schema 3; Wetter ohne neue Voreinstellung (Nebel über das vorhandene `fog_banks` der `LookScene`); Hilfen zum Abrufen als Journaleintrag; der Richter nutzt die Stimmart `neutral`; für Mira höchstens sechs neue Erinnerungsvarianten; die Katze „ab II“ statt „ab III“ im Plan (sie liegt schon im Slice auf dem Antreiber);
neue IDs werden gesperrt (`id_lock.py --update`), neue Flags stehen vor dem Text in `motive.json`.

## Risiken und Kürzungen

- **Das Ende hängt an allem:** die Prüfung in `check.sh`, der Schutz gegen doppeltes Enden, das Startmenü und der eingefrorene Stand gehen davon aus, dass der Slice das Spiel beendet. Darum bleibt das Ende (O1).
- **Ton:** der Richter kann nach einem Sturz wie Beschämen klingen (§51); Werte können wie ein Quiz wirken; kein schwerer Moment direkt hinter dem anderen (§45); Mira darf nicht zur Mentorin oder zur Trösterin werden.
- **Grenzen ohne Leser:** die Facette `boundaries` wird nur am Ende des Abends gesetzt und von nichts gelesen. B2 gibt ihr eine frühere Quelle und zwei Leser; ein Test verlangt zu jedem gesetzten Facetten-Literal einen Leser (StoryLint prüft Facetten nicht).
- **Karten der Klasse M:** jede Zelländerung färbt rund 17 % der Pixel neu, darum landet das Layout in einem Pull Request; die Zahl verschiedener Zeichen je Karte ist nur durch die Legende begrenzt (das Tal braucht 66; V1, ADR-068); der Aufbau der Klasse M ist gemessen (120 × 70: rund 0,5 s, V1), das Zeichnen nicht, und der Container sagt nichts über den Mac.
- **StoryLint:** gesetzte Flags brauchen einen Leser; Antworten mit Bedingung brauchen daneben eine unbedingte Antwort.
- **Prozess:** der Slice-Text ist ungefroren, die Stimmenblätter sind ungelesen; die Stolpersteine in `check.sh` sind ungesperrte IDs, Flags ohne Eintrag in `motive.json` und goldene Zeilen, die nicht mehr passen.

**Cut-First für Akt II:** 1. B3b (nie in der Basis), 2. B4 (Richter) auf ein bis zwei Cues verkleinern oder streichen, 3. Kuriositäten von 6 auf 4, 4. die zweite Nebenquest (die Ziege bleibt), 5. Nebenvarianten von Mira.
**Nie streichen:** Miras Ankunft und das Feuer, der UI-Verlust, das Haus, der Antreiber mit seiner Hilfe, die Rückkehr der Musik, Ziege und Kartoffel, der getragene Samen.

---

## B1 Ankunft

**Stand:** gebaut. **Szene:** `tal` (`tal_scene.gd`, `_arrival_echo`). **Dialog:** `content/dialogue/akt2/ankunft.dialogue` (ein Cue `arrival_echo`, sechs Zeilen `ank_*`, `[#draft]`, kein `[#ph]`).

**Zweck.** Der Riss ist überschritten, das Tal ist da. Akt I hat dem Spielstand Entscheidungen mitgegeben (der Gastwirt, das Fest, das Kind); in der Wirklichkeit las bisher kaum eine davon eine Zeile (`MOTIVE.md`). B1 gibt drei davon ein Echo: kurze bedingte Erzählzeilen, jede an ein Ding gebunden, das schon im Bild steht
(das Feuer unter der Plane, die Pfütze am Weg, das Laub). Kein Rückblick, keine Erklärung; wer nichts davon getan hat, hört nur die Böe und den Boden.

| Beat | Auslöser | Was geschieht | Marke |
|---|---|---|---|
| Ankunft | `valley_arrival` (vorhanden) | unverändert | Beat `valley_arrival` |
| Das Echo | die ersten zwei Zellen zu Fuß, nur mit `chapter.act1` | die Spielerin bleibt stehen, bis der Wind des Tals stößt (höchstens vier Sekunden Spielzeit), dann `arrival_echo`: Böe, Boden, dazu je Flag eine Zeile | Beat `arrival_echo` (nach dem Cue, Autosave); keine neuen Flags |

| Zeile | Bedingung | Ding im Bild | Was Elysia nie sagte |
|---|---|---|---|
| `ank_gust_1`, `ank_ground_1` | immer | Laub, Boden unter den Füßen | der Boden behält den Abdruck |
| `ank_fire_1` | `elysia.inn_stayed` | das Feuer unter der Plane | niemand ruft, dass du bleiben kannst |
| `ank_fire_2` | `elysia.inn_declined` (und nicht `inn_stayed`) | dasselbe Feuer | niemand fragt ein zweites Mal |
| `ank_rings_1` | `elysia.feast_noticed` | die Pfützen am Weg | kein Ring gleicht dem davor (das Tal wiederholt nichts) |
| `ank_hum_1` | `melody.child_hum` | der Regen auf dem Laub | ein Summen für einen Atemzug, dann Regen (B5 gibt dem Lied sein Haus) |

**Regeln der Szene.** Die Schritte zählen nur zu Fuß: ein Sprung von mehr als 8 Pixeln zwischen zwei Physikbildern (Teleport des Autopiloten) ist kein Schritt, und Stehen löst nichts aus; wer Mira vorher anspricht (`valley.mira_met`), hört das Echo nie. Ein offenes Gespräch, ein offenes Menü und das Einblenden des Bildes halten es zurück (die Spielerin darf schon laufen, während der Riss die Welt noch aus dem Schwarz holt: kein Text ins Dunkel), es stapelt sich nie auf eines. Die Spielerin landet bei `spawn_rift` (58, 9) im Nordosten; Plane und Feuer (53, 17) kommen auf dem Weg nach Süden ins Bild, die Pfützen liegen am Weg. Es läuft nur, wenn Akt I erreicht ist (`Chapter.reached("act1")`, vom Riss gesetzt): ein Tal, das auf anderem Weg betreten wird (Debug-Start, alter Stand), hat nichts zu beantworten.
Die Böe ist keine neue Wettervoreinstellung, sondern der vorhandene Wind des Tals (`AudioDirector.wind_gust()`, die Windblätter folgen ihm): Bild und Ton sind schon da, der Cue wartet nur auf einen Stoß. Ohne Klangkulisse gibt es nichts zu erwarten und der Cue beginnt sofort.

**Figuren.** Keine. **Humor-Ziel (3/10).** Leise: ein Ding sagt, was Elysia nie sagte. **Gewicht (§45).** leicht. **Motive.** Elysia gegen Wirklichkeit, Wiederholung (das Tal wiederholt nichts), Menschen ohne echte Ablehnung (am Feuer fragt niemand ein zweites Mal), Perfekte Natur (der Boden behält den Abdruck), Lied und Summen. `MOTIVE.md` und `motive.json` führen die sechs Zeilen.
**Scheitern und Speichern (§49).** Kein Scheitern; die Marke löst einen Autosave aus, davor ist das Speichern gesperrt (Szene `Cutscene`). **Barrierefreiheit (§50).** Kein Blitz, kein Wackeln; die Böe ist Bild und Ton, der Text trägt sie allein. **Endlichkeit (§52).** Einmal. **Gerechnet.** sechs Zeilen, 70 Wörter, `calibrate.py --segment 70 6 0.2`: rund 0,5 Minuten.
**Geplant waren 15 Zeilen**; gebaut sind 6, weil drei Echos mit je einer Zeile reichen und eine vierte Zeile ohne Ding im Bild gegen „Ding vor Gedanke“ (`STIL.md`) liefe. Die Reserve von 9 Zeilen bleibt im Budget des Akts.
**Prüfungen.** `tests/unit/test_akt2_ankunft.gd` (17 Tests: Zeilen über `LineText.of(id)`, die Szene mit Schritten, Teleport, Mira, Einmaligkeit, offenem Gespräch, Einblenden), `tools/autopilot/akt2_ankunft.json` mit Eintrag in `segments` (`valley_arrival`, `chapter.act1`, `arrival_echo`). `slice_full.json` bleibt unverändert: der Lauf geht nach der Ankunft nur über Sprünge und trifft Mira zuerst.

## B2 Nein und Blick

**Stand:** geplant. **Szenen:** `tal`, `haus`. **Dialog:** neue Datei `content/dialogue/akt2/nein.dialogue`.

**Zweck.** Akt II hat die Facette Grenzen (Bible §16–17: das Nein als Antwort) und die Wahrnehmung aus Akt I in der Wirklichkeit zu belegen. Heute setzt der Slice `boundaries` am Ende des Abends, und kein Dialog fragt nach ihr; `perception` wird nur in Akt I gelesen.
B2 gibt Grenzen eine frühere Quelle (eine Antwort an den Antreiber am Feuer oder an eine kleine Bitte von Mira) und zwei Leser, jeweils neben einer unbedingten Antwort; jedes Nein hat eine wahrnehmbare Folge und bestraft nie (§16, §24, §51).
Mira hat einen trockenen, sachlichen Moment, in dem sie unfair ist, und tröstet nicht. Die Wahrnehmung bekommt zwei bis drei **zusätzliche** freiwillige Einzelheiten, die nur mit der Facette zu sehen sind, an neuen Stellen (am Bachlauf in B3, im Haus); die vorhandenen Funde (Moosregel, Stiefelabdruck, die Muschel mit dem Riss) bleiben für alle unverändert, denn an der Muschel hängen `valley.shell_seen`, `Zum Meer?` und `tal_end_8`.
Hilfen zum Abrufen (Bachlauf, Weg des Antreibers) stehen als Journaltext, ohne neue Oberfläche (Plan 6).

| Beat | Auslöser | Was geschieht | Marke |
|---|---|---|---|
| Das frühere Nein | die Bitte am Feuer | Grenzen kommt früher als am Ende des Abends; das Nein wird angenommen und hat eine Folge | Facette `boundaries` (Quelle verschoben oder verdoppelt), Beat `act2_nein` |
| Zwei Leser | spätere Gespräche | eine Antwort mehr, wenn die Facette da ist | keine neuen Flags |
| Der Blick | neue Stellen am Bach und im Haus | zwei bis drei zusätzliche Funde nur mit `perception`, nie als Voraussetzung für etwas | Beat `act2_blick` |

**Figuren.** Mira (ihr unfairer Moment, ohne Trost), der Antreiber (die Bitte am Feuer). **Humor-Ziel (3/10).** Trockenes, nicht Komisches. **Gewicht (§45).** mittel. **Motive.** Grenzen, Wahrnehmung, Miras Würde.
**Scheitern und Speichern (§49).** Kein Scheitern; ein Nein wird nie bestraft, die Marken lösen Autosaves aus. **Barrierefreiheit (§50).** Kein Blitz, kein Wackeln; die Funde sind Text und Bild, die Hilfen stehen im Journal. **Endlichkeit (§52).** Jede Bitte und jeder Fund einmal. **Gerechnet.** rund 25 Zeilen, 260 Wörter: `calibrate.py --segment 260 25 2` gibt rund 4 Minuten.
**Prüfungen.** `tests/unit/test_akt2_nein.gd` und ein Test, der zu jedem `set_facet`-Literal einen Leser verlangt, `tools/autopilot/akt2_nein.json` mit Eintrag in `segments`.

---

*B3 bis B7 bekommen ihren Brief in dem Pull Request, der sie baut.*
