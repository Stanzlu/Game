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
| Karte der Klasse M (Plan: Tal plus 1–2) | **fehlt**; B3 baut `bachlauf` (84 × 66) | – |
| Sammelstücke: Nebenquests 1 von 2, Kuriositäten 1 von 6, Fragmente 0 von 3, Melodien 0 von 1 | teilweise; B3 bringt die zweite Nebenquest, drei Kuriositäten (4 von 6) und zwei Fragmente (2 von 3) | – |

Was bleibt, wie es ist: alle 354 IDs (nie umbenennen, nur `id_lock.py --retire`), die Szenenschlüssel `tal`, `haus`, `weg`, `tal_mira_7/8`, `tal_end_5/8/10` („Nein.“, „Zum Meer.“), `tal_fell_1` bis `5`, die Flags `valley.*`, `house.*`, `elysia.*`, `slice_full.json`, die Prüfung „vertical slice finished“ und das eingefrorene `v2_slice_end.json`. `tools/art/layout_slice_maps.py tal --write` löscht Handänderungen in `tal.txt`: Änderungen dort von Hand, danach neu backen.

## Der Fluss von Akt II

| Segment | Inhalt | Ort | Neue Zeilen | Pull Requests | Stand |
|---|---|---|---|---|---|
| V0 | Brief, Kapitelmarke `act1`, eingefrorener Stand `v2_akt1_end.json`, ADR-067 | – | 0 | 1 | **gebaut** |
| V1 | T6 Großkarten-Spike und T7 (nur der kleine Teil) | – | 0 | 1 | **gebaut** (ADR-068, `docs/PERFORMANCE.md`: Klasse M bis 120 × 70, Aufbau rund 0,5 s) |
| B1 | Ankunft: die Wirklichkeit antwortet auf Elysia | `tal` | 6 (geplant 15) | 1 | **gebaut** (6 Zeilen, 0,5 Modellminuten) |
| B2 | Nein und Blick: Grenzen als echte Möglichkeit, Wahrnehmung in der Wirklichkeit | `tal`, `haus` | 23 (geplant 25) | 1 | **gebaut** (23 Zeilen, 2,1 Modellminuten) |
| B3 | Bachlauf: die erste Karte der Klasse M, Nebenquest, Kuriositäten, Nebel | `bachlauf` (neu) | 45 (geplant 62) | 1 | **gebaut** (45 Zeilen, 6,1 Modellminuten) |
| B4 | Richter: eine Stimme nach dem zweiten Sturz | `tal` | 12 | 1 | geplant (Cut-First-Platz 2) |
| B5 | Feuer: Werte, das Lied im Haus, ein Fragment | `haus` | 30 | 1 | geplant |
| B6 | Abend und Anschluss: Mira liest die Werte, Kapitelmarke `act2` | `tal` | 18 | 1 | geplant |
| B7 | Durchlauf: `akt2_full.json`, Lesefassung, Messung | – | 0 | 1 | geplant |
| **Summe** | | | **134** (geplant 162) | **9** | |

**Budget.** 354 vorhandene plus 134 neue Zeilen sind 488 von den im Plan abgeleiteten 557 (88 %); im Modell rund 22 Minuten (16 für die vorhandenen 354 Zeilen nach `calibrate.py`, dazu 134 / 24) gegen 90 geplante. Die Lücke von rund 68 Minuten kommt nicht aus Text (ADR-066, Plan 10.1);
Bible §43 und §59 verbieten, sie mit Gehen zu füllen. Rund 14 neue Tests je Segment. Mit einer zweiten Karte (B3b) wären es 550 Zeilen und 10 Pull Requests, mit dem Pull Request für das Streuen der Karten (T6.3, nur wenn V1 es verlangt) 11. **Auslöser für Cut-First:** mehr als 11 Pull Requests oder mehr als 700 Zeilen im Akt (Bestand plus neu).

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
- **Grenzen ohne Leser:** die Facette `boundaries` wird nur am Ende des Abends gesetzt und von nichts gelesen. B2 gibt ihr eine frühere Quelle und zwei Leser; `StoryLint.facet_problems` verlangt zu jeder gesetzten Facette einen Leser und zu jeder gelesenen einen Setzer (B2).
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

**Regeln der Szene.** Die Schritte zählen nur zu Fuß: ein Sprung von mehr als 8 Pixeln zwischen zwei Physikbildern (Teleport des Autopiloten) ist kein Schritt, und Stehen löst nichts aus; wer Mira vorher anspricht (`valley.mira_met`), hört das Echo nie. Die Phasen laufen im `_physics_process` der Szene (Schritte, Böe, Zeilen), nicht als Koroutine auf `physics_frame`: eine Szene, die währenddessen freigegeben wird, lässt nichts zurück, das ohne sie aufwacht. Ein offenes Gespräch, ein offenes Menü und das Einblenden des Bildes halten es zurück (die Spielerin darf schon laufen, während der Riss die Welt noch aus dem Schwarz holt: kein Text ins Dunkel), es stapelt sich nie auf eines. Die Spielerin landet bei `spawn_rift` (58, 9) im Nordosten; Plane und Feuer (53, 17) kommen auf dem Weg nach Süden ins Bild, die Pfützen liegen am Weg. Es läuft nur, wenn Akt I erreicht ist (`Chapter.reached("act1")`, vom Riss gesetzt): ein Tal, das auf anderem Weg betreten wird (Debug-Start, alter Stand), hat nichts zu beantworten.
Die Böe ist keine neue Wettervoreinstellung, sondern der vorhandene Wind des Tals (`AudioDirector.wind_gust()`, die Windblätter folgen ihm): Bild und Ton sind schon da, der Cue wartet nur auf einen Stoß. Ohne Klangkulisse gibt es nichts zu erwarten und der Cue beginnt sofort.

**Figuren.** Keine. **Humor-Ziel (3/10).** Leise: ein Ding sagt, was Elysia nie sagte. **Gewicht (§45).** leicht. **Motive.** Elysia gegen Wirklichkeit, Wiederholung (das Tal wiederholt nichts), Menschen ohne echte Ablehnung (am Feuer fragt niemand ein zweites Mal), Perfekte Natur (der Boden behält den Abdruck), Lied und Summen. `MOTIVE.md` und `motive.json` führen die sechs Zeilen.
**Scheitern und Speichern (§49).** Kein Scheitern; die Marke löst einen Autosave aus, davor ist das Speichern gesperrt (Szene `Cutscene`). **Barrierefreiheit (§50).** Kein Blitz, kein Wackeln; die Böe ist Bild und Ton, der Text trägt sie allein. **Endlichkeit (§52).** Einmal. **Gerechnet.** sechs Zeilen, 70 Wörter, `calibrate.py --segment 70 6 0.2`: rund 0,5 Minuten.
**Geplant waren 15 Zeilen**; gebaut sind 6, weil drei Echos mit je einer Zeile reichen und eine vierte Zeile ohne Ding im Bild gegen „Ding vor Gedanke“ (`STIL.md`) liefe. Die Reserve von 9 Zeilen bleibt im Budget des Akts.
**Prüfungen.** `tests/unit/test_akt2_ankunft.gd` (8 Tests: die Zeilen je Flag über `LineText.of(id)`) und `test_akt2_ankunft_szene.gd` (11 Tests: Schritte, Teleport, Stehen, Mira, Einmaligkeit, offenes Gespräch, Einblenden, eine Szene, die während des Wartens freigegeben wird), `tools/autopilot/akt2_ankunft.json` mit Eintrag in `segments` (`valley_arrival`, `chapter.act1`, `arrival_echo`). `slice_full.json` bleibt unverändert: der Lauf geht nach der Ankunft nur über Sprünge und trifft Mira zuerst.

## B2 Nein und Blick

**Stand:** gebaut. **Szenen:** `haus` (der Antreiber am Feuer, Miras Besuch, die Funde), `tal` (der Abend). **Dialog:** neue Datei `content/dialogue/akt2/nein.dialogue` (Cue `antreiber_ask`, 8 Zeilen, `[#draft]`) und 15 Zeilen in `haus.dialogue` und `tal.dialogue` (ohne Tag wie die Dateien).

**Zweck.** Akt II hat die Facette Grenzen (Bible §16–17: das Nein als Antwort) und die Wahrnehmung aus Akt I in der Wirklichkeit zu belegen. Der Slice setzte `boundaries` nur am Ende des Abends, und kein Dialog fragte nach ihr; `perception` wurde nur in Akt I gelesen.
B2 gibt Grenzen eine frühere Quelle (die Antwort an den Antreiber am Feuer) und zwei Leser, jeweils neben Antworten, die immer gelten; jedes Nein hat eine wahrnehmbare Folge und bestraft nie (§16, §24, §51).
Mira ist einmal trocken unfair und tröstet nicht. Die Wahrnehmung bekommt zusätzliche freiwillige Einzelheiten, die nur mit der Facette zu sehen sind; die vorhandenen Funde (Moosregel, Stiefelabdruck, die Muschel mit dem Riss) bleiben für alle unverändert, denn an der Muschel hängen `valley.shell_seen`, `Zum Meer?` und `tal_end_8`.

**Das Nein am Feuer.** Der Antreiber sagt seine beiden Sätze (`haus_antr_1`, `haus_antr_2`: Holz für morgen, das Dach) und wartet; dann folgt `antreiber_ask` mit drei Antworten. Alle drei sind immer da, keine ist bedingt.

| Antwort | Was er tut | Folge | Marke |
|---|---|---|---|
| „Heute nicht.“ | wiederholt es, als notiere er es; hebt einen Finger für ein Zweitens, es kommt keins | er setzt sich (auch wenn die Spielerin aufsteht: die Antwort entscheidet, nicht der Körper); er bleibt am Feuer, die Katze legt sich später auf ihn; am Feuer sagt er „Das Dach hat Zeit. Steht auf der Liste. Ganz unten.“ oder zählt nichts mehr an den Fingern | Facette `boundaries`, Flag `house.antreiber_refused`, Beat `act2_nein` |
| „Morgen.“ | „Das ist ein Termin.“, geht nachsehen, ob das Dach noch da ist | er geht hinaus, ohne das „Ja! Los!“ des Aufstehens; kein Nein, keine Facette | Flag `house.antreiber_postponed` |
| „…“ | wartet und zählt etwas an den Fingern ab | das Sitzen entscheidet wie bisher: sitzen bleiben setzt ihn dazu, aufstehen schickt ihn mit „Ja! Los!“ hinaus | – |

Er fragt nicht, warum; er lobt nicht; er ruft nicht (kein „!“ im Sitzen). Sein Zweitens, das ausfällt, greift `sl_antr_start_3` („Erstens gehen. Zweitens schneller gehen.“) auf: seine Liste verliert etwas, er wird nicht besiegt. Die Folgen sind am Antreiber und an seinem Platz zu sehen, nicht an Mira: sie ist beim Besuch dieselbe wie sonst. Der Besuch bleibt überspringbar (kommt Mira nach 40 Sekunden, ohne dass die Spielerin sitzt, entfällt er), und die späte Quelle am Ende des Abends (die Antwort `tal_eve_ely_r3`, Miras „Gut.“ `tal_eve_ely_7`) bleibt unverändert; wer den Antreiber nie verneint, kann `boundaries` dort weiter bekommen.

**Zwei Leser.** Beide sind Antworten mit `[if WorldState.has_facet("boundaries") /]` neben den unbedingten Antworten der Gruppe (das Schweigen „…“ bleibt die letzte); wer die Facette nicht hat, sieht die Gruppe wie vorher.

| Wo | Antwort | Mira / Folge |
|---|---|---|
| Besuch, „Wo kommst du eigentlich her?“ (`haus.dialogue`) | „Das sag ich nicht.“ | „Dann kommst du von hier.“ „Das spart Weg.“ Erinnerung `kept_origin`; am Abend fragt sie nicht nach Elysia: `evening_elysia` sagt nur „Mira schaut ins Feuer. Nach Elysia fragt sie nicht.“ (sie fragt nie zweimal, `tal_eve_ely_8`) |
| Abend, „Erzähl was. Irgendwas.“ (`tal.dialogue`, `evening_day`) | „Heute nicht mehr.“ | Mira zieht das Netz näher ans Feuer, das nasse Garn dampft; sie erzählt nichts dazu (die Antwort „…“ hat dagegen ihre eigene Wendung mit den Löchern im Netz). Erinnerung `kept_day` |

Beide Erinnerungen haben einen Satz im Journal (`MEMORY_MIRA_KEPT_ORIGIN`, `MEMORY_MIRA_KEPT_DAY`); damit sind zwei der sechs neuen Erinnerungsvarianten für Mira in Akt II verbraucht. Ein neuer Lint (`StoryLint.facet_problems`) verlangt zu jeder gesetzten Facette einen Leser und zu jeder gelesenen einen Setzer; ein Test fordert für `boundaries` mindestens zwei Leser.

**Miras unfairer Moment.** Im Besuch, nach dem Fisch und vor der Ziege, ohne Antwortgruppe und ohne Verbindung zum Nein: „Dein Kamin zieht schlecht.“ Der Rauch steigt gerade nach oben, sie wedelt ihn trotzdem weg („Meiner raucht nie.“). Sie nimmt nichts zurück, entschuldigt sich nicht, und die Erzählung kommentiert nichts. Er steht für alle gleich da, mit und ohne Facette, und nie nach einem Sturz in den Bach (O2).

**Der Blick.** Zwei zusätzliche Funde im Haus, beide nur mit der Facette `perception`; der dritte ist der aufgeknotete Knoten am Haken im Bachlauf (B3).
- **Abdrücke im Staub.** Ein neuer Punkt im Raum (`p`, Zelle 22 / 10, ohne Sprite, Boden `_`, kein neues Backen), den die Karte nur zeigt, wenn `house.looks_closely` gesetzt ist; die Szene setzt ihn aus der Facette. „Klein, rund, vier Zehen. Sie laufen ans Fenster und wieder zurück, mehrmals.“ Beim Ansehen: `house.prints_seen`, Beat `act2_blick`. Hängt an nichts.
- **Die Decke am Bett:** ein Satz mehr im vorhandenen Cue `bed` (haus_bed_6): „Die Decke ist aus Quadraten genäht. Eins davon ist neuer als die anderen, der Faden dicker.“ Sie knüpft an den Flickenteppich im Bild an (vier Farben).
Beide meiden das Kind (O5: keine Bilder des Kindes im Haus vor Akt V) und erklären nichts.

**Hilfe zum Abrufen.** Die Stufe `wood` von `main_valley_shelter` trägt jetzt: „Der Weg soll lang sein. Länger, wenn man es eilig hat.“ Es nennt die Lösung nicht und steht für jede Spielerin im Journal; die Hilfe zum Bachlauf steht seit B3 in der ersten Stufe der Quest „Die Reuse“.

**Figuren.** Der Antreiber (seine Antwort), Mira (der unfaire Moment, zwei Antworten). **Humor-Ziel (3/10).** Trockenes, nicht Komisches: ein Zweitens, das ausfällt; ein Kamin, der schlecht zieht, während der Rauch steigt. **Gewicht (§45).** mittel. **Motive.** Grenzen (Aufgabe ablehnen, Gespräch beenden: Bible §16, Stufe I und II; Stufe III, „Nähe“, gehört in Akt IV), Wahrnehmung, Miras Würde, der Antreiber optimiert Freizeit.
**Scheitern und Speichern (§49).** Kein Scheitern; ein Nein wird nie bestraft; `act2_nein` und `act2_blick` lösen Autosaves aus; `act2_nein` wird erst nach dem Besuch gesetzt (ein Beat im Besuch hielte einen Autosave vor, den das Verlassen der Szene halb schriebe: verneint, aber noch nicht sitzend). **Barrierefreiheit (§50).** Kein Blitz, kein Wackeln; Funde sind Text, die Hilfe steht im Journal. **Endlichkeit (§52).** Jede Frage und jeder Fund einmal; nichts wird zweimal gefragt.
**Gerechnet.** 23 Zeilen, 163 Wörter, `calibrate.py --segment 163 23 1`: rund 2,1 Minuten. Geplant waren 25.
**Ohne Rückfrage entschieden.** Die Quelle ist der Antreiber, nicht Mira (der Plan nannte beides; Mira macht im Slice nirgends eine Bitte, ihre Fragen nehmen schon jetzt ein Schweigen an, und der Antreiber hat die Bitte schon); der erste Leser ist eine Frage von Mira, keine Bitte. Ein abgeleitetes Flag `house.looks_closely` statt einer Facette in der Karte (Karten kennen nur Flags; ein `if_facet` hätte den Baker, `map_view.gd` und `mapfile.py` berührt, und jede Änderung an `mapfile.py` macht alle Stempel ungültig). Der Besuch des Antreibers zeigt jetzt eine Antwortgruppe: Tests, die ihn mit Auto-Weiter durchspielen, antworten mit „…“ (`BoxAnswers`).
**Prüfungen.** `tests/unit/test_akt2_nein.gd` (15 Tests: die Antworten und ihre Folgen, die zwei Leser mit und ohne Facette, der Abend, Mira, die Funde, das Journal; Hilfsmittel `DialogueWalk.groups`) und `test_akt2_nein_szene.gd` (8 Tests: jede Antwort in der echten Szene, „die Antwort entscheidet, nicht der Körper“, Mira kommt wie immer, der Punkt nur mit der Facette, kein Muss), `StoryLint.facet_problems` mit Fixtures, `tools/autopilot/akt2_nein.json` mit Eintrag in `segments` (`act2_nein`, `act2_blick`, `house.antreiber_refused`, `house.antreiber_by_fire`, `house.mira_visited`, `house.prints_seen`; das Skript setzt `house.looks_closely` selbst, denn der Autopilot kennt kein `facet`). `slice_full.json` nimmt die erste Antwort („Heute nicht.“) und setzt sich wie bisher; sein Fenster für Feuer, Antreiber und Besuch wurde nicht verändert.

## B3 Bachlauf

**Stand:** gebaut. **Szenen:** `bachlauf` (neu: `world/levels/akt2/bachlauf.tscn`, `BachlaufScene`; die erste Karte der Klasse M), `tal` (Zugang und Rückweg). **Dialog:** neue Datei `content/dialogue/akt2/bachlauf.dialogue` (13 Cues, 44 Zeilen `bl_*`, `[#draft]`, kein `[#ph]`) und eine Zeile in `haus.dialogue` (`haus_window_4`, die Einladung). **Quest:** `side_valley_trap` „Die Reuse“ (`hook`, `float`, `weir`, `done`). Dazu drei Kuriositäten, zwei Fragmente und ein Fund nur mit der Facette Wahrnehmung.

**Zweck.** Abends, nach Miras Besuch, geht ein Pfad am Bach nach Süden (O6). Das Tal war bisher die einzige Karte der Wirklichkeit und halb so groß wie ein Platz zum Verlaufen; der Bachlauf muss zeigen, dass eine große Karte ohne Marker trägt (Plan 6: „ein leises Mittel, festgelegt im Brief der ersten M-Karte“) und dass alles, was auf ihr liegt, wie in der Wirklichkeit einen Grund hat, nur nicht den, den man vermutet (Bible §12: „weniger kontrollierbar, nicht schlechter“). Gewicht „leicht“ nach dem mittleren B2 (§45). Nichts hier hängt an der Hauptgeschichte: der Abend endet auch, wenn die Spielerin nie hinunterging (O1).

**Zugang und Rückweg.** Im Tal öffnet sich die Hecke am Südrand neben dem Bach (Zellen 41 bis 43, Reihen 35 bis 37) zu einem Pfad. Bis Mira da war, steht in der Lücke ein Blocker (Cue `bach_wait`: „Hinter der Hecke geht ein Pfad am Bach entlang. Der Regen hat ihn zu Matsch gemacht.“); danach führt dort eine Tür hinunter (`if house.mira_visited`), und im Fenster des Hauses steht am Abend die Einladung: „Weiter unten steigt vom Bach Nebel auf.“ (`haus_window_4`, nur mit Feuer und Abend, wie `haus_window_3`). Die Lücke ändert Zellen des Tals (Hecke wird Pfad): `tal_ground.png` und `tal_water.png` sind neu gebacken, der Tal-Generator `layout_slice_maps.py` trägt die Lücke und die Marken nach (auch die von Hand gesetzte Marke `6`, die er vorher nicht kannte, sodass `tal --write` keine Handänderung mehr löscht). Der Rückweg: eine Tür in der Lücke im Wald im Norden des Bachlaufs (Zelle 35 / 1, drei Zellen breit) führt zu `spawn_bach` im Tal (42 / 33); den Beat `bachlauf_back` setzt das Tal bei der Ankunft (nie in der Türzone: ein Beat dort schriebe einen Autosave, der beim Laden wieder in die Tür liefe).

**Die Karte.** 84 × 66 Zellen (5.544; Klasse M reicht bis 120 × 70, ADR-068 – gebaut nach der Strecke, nicht nach dem Rahmen), Stil `tal`, ein gebackener Boden (`bachlauf_ground.png`, 1344 × 1056). Ein Rundkurs: vom Wald im Norden das Westufer hinunter, über den Baumstamm der Südfurt (Zelle 44 bis 47 / 57), das Ostufer hinauf und über den Stamm der Kopffurt (Zelle 40 bis 42 / 9) zurück zur Lücke. Kein Weg wird zweimal gegangen, keine Richtung ist vorgeschrieben (die Reihenfolge der Quest regeln Flags, nicht die Geografie). Der Bach kommt aus dem Wald im Norden und verlässt die Karte im Süden; ein Wehr (eine Reihe Wasserfall über einem Balken, Zelle 42 bis 44 / 50) staut ihn zwischen den Ufern. Dazu eine trockene Rinne am Ostufer (neun Zellen vom Bach, zwölf Reihen), drei Mulden aus Matsch und eine Pfütze, ein Aussichtsplatz mit Bank im Südosten, ein Stichpfad durch das Schilf zum Flachwasser. Die Karte entsteht aus `tools/art/layout_akt2_maps.py bachlauf` (die Köpfe `[meta]` und `[legend]` von Hand), `tools/art/test_layout_akt2.py` prüft: die eingecheckte Karte ist, was der Generator zeichnet; Maße höchstens 120 × 70; jedes benannte Ding steht einmal; alles ist zu Fuß vom Start erreichbar; ohne die zwei Baumstämme liegt das Ostufer in einer anderen Welt; die Ankunft liegt außerhalb der Türzone; das Wehr liegt quer über dem ganzen Bach. 259 Zellen Pfad, 227 Zellen Wasser, 9 Emitter am Wasser, 129 Platzierungen, rund 2.150 gestreute Dinge.

**Hinweise ohne Marker (Plan 6).** Der Pfad ist der Hinweis: ein getretener, gebackener Streifen, der dem Bach in vier bis sechs Zellen Abstand folgt und ihn nur an den Furten kreuzt (im Mittel vier Zellen vom Wasser, der weiteste Punkt, der Aussichtsplatz, elf; alles liegt in der Reichweite der Emitter von 13,75 Zellen). Der Bach selbst ist das Zweite: man sieht ihn von jeder Stelle des Pfads, er ist das einzige Wasser der Karte. Das Dritte ist das Journal: die erste Stufe der Quest (`QUEST_SIDE_VALLEY_TRAP_HOOK`) steht dort, sobald der Pfosten gelesen ist, und sagt „Ich bleibe am Wasser. Zurück zeigt der Rauch über den Bäumen.“; am Aussichtsplatz sagt der Cue `look_back` dasselbe als Bild („Über den Bäumen steht dünner Rauch, gerade nach oben. Das Haus.“). Der Klang trägt nichts allein (§50): die Karte spielt die Klangkulisse des Abends (`tal_abend`, ein Wasserbett überall) und die Emitter am Wasser; eine eigene Kulisse ohne Wasserbett, in der der Bach wirklich Richtung gäbe, hätte `DayLight` berührt und ist nicht gebaut. Ehrlich dazu: die Rauchfahne des Hauses ist kein Bild der Karte, nur Text; wer sie sehen will, geht zurück.

**Nebel.** `fog_banks` und `fog_color` der `LookScene` (kein neues Wetter, kein neuer Voreinstellungswert): Bänke über der ganzen Karte, warm gefärbt (der Abend färbt jede Farbe warm), dünn genug, dass Pfad und Funde lesbar bleiben (26 Bänke, Alpha 0,2; auf einer Aufnahme geprüft). Er driftet 3 bis 7 Pixel je Sekunde und hat keine Einstellung zum Abschalten, weil er weder blitzt noch wackelt.

### Die Nebenquest „Die Reuse“

Ein Gegenstand gibt sie, kein Mensch (Mira macht im Slice nirgends eine Bitte). Sie schickt die Spielerin am Bach hinunter; nichts wird getragen, nichts verfolgt.

| Stufe | Wo | Was geschieht | Marke |
|---|---|---|---|
| `hook` | der Pfosten mit dem leeren Haken am Anfang des Pfads, ein heller Streifen im Holz | `start_quest`; das Journal hat die Hilfe | Flag `valley.trap_hooked`, Beat `bachlauf_hook` |
| `float` | der Schwimmer aus Kork im Schilf am Westufer (die Karte zeigt ihn erst mit `valley.trap_hooked`) | seine Spitze zeigt bachabwärts | Flag `valley.trap_floated`, Beat `bachlauf_float` |
| `weir` | die Reuse hinter dem Wehr (die Karte zeigt sie erst mit `valley.trap_floated`) | gesehen: „Eine Reuse“; die Antwort „Sie lösen.“ oder „Klemmen lassen.“ | Beat `bachlauf_weir` |
| `done` | dieselbe Reuse | „Sie lösen.“: ein Kamm, dem bis auf einen Zahn alle fehlen; die Reuse liegt frei im Strom | Flag `valley.trap_freed` (zuletzt gesetzt: die Karte tauscht das Bild), Beat `bachlauf_freed`, Kuriosität `curiosity_comb` |

Die Belohnung ist ein Ding und eine sichtbare Änderung der Welt, keine Zahl (Real-HUD hat keine). „Klemmen lassen.“ ändert nichts; die Reuse bleibt, die Quest bleibt bei `weir`. Wer die Ziege zuerst erledigt und den Stiefel abgibt, beendet den Abend (O1): eine offene Reuse bleibt dann offen, ohne Text, ohne Scham.

### Was der Bach liegen gelassen hat

| Fund | Wo | Wie | Marke |
|---|---|---|---|
| Senkblei (`curiosity_lead_weight`) | im Gras am Fuß des Pfostens | „Einstecken.“ / „Liegen lassen.“ (die nehmende Antwort steht zuerst) | Flag `valley.weight_taken`; die Karte nimmt das Ding weg |
| Blaues Glas (`curiosity_blue_glass`) | im Flachwasser am Ende des Stichpfads | wie oben | Flag `valley.glass_taken` |
| Kamm mit einem Zahn (`curiosity_comb`) | die Belohnung der Reuse | – | – |
| Uferbrett auf zwei Stümpfen (`fragment.bank_table`) | am Westufer | zwei Ringe auf dem Brett, wo Becher standen; „Du setzt dich auf den einen.“; für einen Atemzug dampfen zwei Becher | Fragment, einmal erzählt (`bl_table_5` danach) |
| Trockene Rinne (`fragment.dry_bed`) | am Ostufer | neben dem Bach eine Rinne, so breit wie er, trocken, die Kiesel alle gleich gedreht; für einen Atemzug liegt Wasser darin | Fragment, einmal erzählt |
| Der aufgeknotete Knoten | am Haken, nur mit `valley.looks_closely` | „Sie ist nicht gerissen. Sie ist aufgeknotet, flach und sauber, von jemandem, der das oft getan hat.“ | Flag `valley.knot_seen`, Beat `bachlauf_blick` |
| Hufabdrücke auf dem Balken | am Wehr, für alle | „Das wurde der Ziege offenbar nicht gesagt.“ | – (rührt Quest, Flags und Stiefel der Ziege nicht an) |

Mit dem Löffel sind das **vier von sechs Kuriositäten** (die Cut-First-Untergrenze), **zwei von drei Fragmenten**, **zwei von zwei Nebenquests**. Die Fragmente sind Spuren der Welt und der Vergangenheit, keine Bilder des Kindes (O5): kein Kind, keine Figur, kein Grund, warum jemand ging; ein Test verbietet in der ganzen Datei die Wörter Kind, Erinnerung, Zuhause, Meer, Heim und verlor. Das HUD zeigt in der Wirklichkeit keine Fragmentkarte (das Pop-up hängt am Elysia-Teil, Bible §34: „fast leer“); die Zeilen tragen das Fragment, die Bilder liegen da, damit eine spätere Ansicht keines vermisst. Die Kuriositäten kann das Regal im Haus noch nicht aufnehmen (zwei feste Antworten, Löffel und Stein; die allgemeine Platzierung kommt mit Akt IV); sie liegen bis dahin im Beutel und im Journal unter „Dinge“.

**Das Verhältnis zur Ziege (Bible §33).** Die Ziege steht schon am Zaunspalt (vor dem Tausch) und auf dem Holzstapel (danach); eine dritte Ziege wäre ein Bruch (und `goat.gd` spricht fest den Cue `goat` des Tals). Darum sind es Spuren: sie war hier, auf einem Balken über tiefem Wasser, und niemand weiß, wie sie wieder zurück ist. Keine Kartoffel, kein Flag, kein Stiefel.

**Figuren.** Keine; Mira bleibt draußen (kein Zuspruch, keine Erinnerung, keine Variante: zwei von sechs sind in B2 verbraucht, vier bleiben für B5 und B6). **Humor-Ziel (3/10).** Trocken: ein Senkblei, das die Tasche nach unten zieht, „genau wie vorgesehen“; eine Reuse, die „sich dort eingerichtet“ hat; ein Kamm, der „kämmt, was er kann“. **Gewicht (§45).** leicht. **Motive.** Ziege, Spuren der Welt und der Vergangenheit (neu in `MOTIVE.md`), Wahrnehmung (der dritte Fund), Wirklichkeit gegen Elysia (nichts wiederholt sich; alles hat einen Grund). `motive.json` führt neun Flags und das neue Motiv.
**Scheitern und Speichern (§49).** Kein Scheitern, kein Sturz in den Bach (die Furten sind Baumstämme, kein Trittstein, `valley.fell_*` und der Richter bleiben dem Tal); Autosaves bei jedem Beat; das Speichern ist nie gesperrt (keine Zwischensequenz). **Barrierefreiheit (§50).** Kein Blitz, kein Wackeln, keine Zeitgrenze; Funde sind Text, die Hilfe steht im Journal; kein Hinweis hängt am Klang oder an einer Farbe allein. **Endlichkeit (§52).** Jeder Fund einmal; die Wiederholung ist eine kürzere Zeile.
**Gerechnet.** 45 Zeilen (44 neu im Bachlauf, eine im Haus), 503 Wörter, `calibrate.py --segment 503 45 3`: rund 6,1 Minuten (drei Minuten Weg: der Rundkurs ist rund 30 Sekunden lang, dazu die Stationen und das Umschauen). Geplant waren 62 Zeilen. Die Zeit der Karte kommt vom Weg, nicht vom Text; ein Spiel, das die Klasse M mit Minuten füllen wollte, bräuchte mehr zu tun, nicht mehr zu lesen (Bible §43, §59).
**Ohne Rückfrage entschieden.** Die Quest „Die Reuse“ (ein Gegenstand gibt sie, der Bach führt) statt der Furt mit dem fehlenden Stein (sie hätte einen Stein, die Moosregel, einen Tausch und einen Satz Mira gebraucht, also Änderungen in `tal.dialogue`, die B6 neu schreibt); Hilfe und Quest beginnen am Eingang, weil `main_valley_shelter` am Abend schon beendet ist; der Zugang durch eine Lücke in der Hecke (neu gebackenes Tal) statt einer Tür auf unverändertem Gras (die Tür allein sähe aus wie ein Gang in eine Hecke); Fragmente ohne Karte in der Wirklichkeit (kein Eingriff in das HUD, §34); keine Melodie in B3 (Plan 5.5 weist die eine Melodie von Akt II keinem Segment zu; sie gehört zu B5); der dritte Fund hängt an einem eigenen abgeleiteten Flag `valley.looks_closely` (das Flag des Hauses hängt am Besuch des Hauses, und `house.looks_closely` bleibt, wie B2 es baute).
**Prüfungen.** `tests/unit/test_akt2_bachlauf.gd` (14 Tests: Quest, Reihenfolge, Antworten, Kuriositäten, Fragmente, Ziege, Einladung, kein Fragezeichen, kein Kind), `test_akt2_bachlauf_szene.gd` (9 Tests: die große Karte mit Nebel und Bach, Ankunft, der Punkt nur mit der Facette, Float und Reuse nacheinander, die Beats, die Reuse lösen, genommene Dinge, die Tür zurück), `test_akt2_bachlauf_tal.gd` (3 Tests: Blocker, Tür, Rückweg), `tools/art/test_layout_akt2.py` (7 Tests), `StoryLint` (neue Flags haben Leser), `tools/autopilot/akt2_bachlauf.json` mit Eintrag in `segments` (alle sieben Beats, beide Fragmente, beide genommenen Dinge); der Smoke läuft über `SMOKE` und `BENCHMARK`.
**Gemessen.** Der Aufbau der Karte dauert im Container rund 0,4 Sekunden (Log: `open scene` bis `scene ready`; 129 Platzierungen, 2.154 gestreute Dinge, 9 Emitter), also wie in ADR-068 für die Klasse M. `bachlauf` steht in `SMOKE` und `BENCHMARK` (der Leistungstest läuft die Karte mit ab); die Bildrate auf dem Mac ist weiter ungemessen (Plan 11).

---

*B4 bis B7 bekommen ihren Brief in dem Pull Request, der sie baut.*
