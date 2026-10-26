# Akt III (Wald): Regionsbriefe

Je Segment ein Brief nach Abschnitt 4.5 des Produktionsplans, wie in `docs/akt1/REGIONSBRIEFE.md` und `docs/akt2/REGIONSBRIEFE.md`: Beat-Tabelle, Flags, Figuren, Humor-Ziel, Gewicht, Motive,
Scheitern und Speichern, Barrierefreiheit, Endlichkeit. Der Brief eines Segments wird hier verbindlich, sobald es gebaut ist; Änderungen im Pull Request des Segments.
Zeiten rechnet `tools/writing/calibrate.py` (`docs/KALIBRIERUNG.md`); gebaut wird nach Zeilen, Karten, Requisiten und Pull Requests, die Minuten sind Modell (ADR-066).

**Stand (V0, ADR-070):** Akt III ist geplant, nichts davon ist gebaut. Dieser Pull Request legt den Brief, die Voreinstellungen, ADR-070 und den eingefrorenen Stand am Ende von Akt II an (`tests/fixtures/saves/v2_akt2_end.json`).
Geplant (Plan 5.1, Bible §37): 90 Minuten, Humor 4 bis 5, „Antreiber, Einsiedler, Fürsorge, erste Beschützerlogik, Natur“, zwei Karten der Klasse M, im Plan 557 Zeilen und im Modell 23 Minuten bei dieser Menge.

## Was Akt III schon hat

Akt III hat anders als Akt II keine Hälfte des Slice: es gibt Material, aber keine Szene, keine Figur und keine Zeile außer dem Antreiber.

| Beat des Plans | Stand | Ort |
|---|---|---|
| Antreiber, sein Warum | **Spur**: `sl_antr_why_1/2` („Ich wollte nur, dass wir ankommen, bevor es dunkel wird.“ / „Wer schnell genug ist, den holt nichts ein. Nicht die Kälte, nicht das Dunkel.“), die Freizeit-Gags in Tal und Haus; kein Woher | `weg`, `tal`, `haus` |
| Einsiedler | **fehlt**: Stimmenblatt ohne Beleg (`docs/writing/stimmen/einsiedler.md`), keine Figur, keine Stimme in `voices.json`, keine Hütte | – |
| Fürsorge (Facette `care`) | **fehlt**: steht in `GameState.FACETS`, hat weder Setzer noch Leser | – |
| Wald, Natur | **Prototyp**: `look_wald` (56 × 38, Nacht, Leuchtbäume), 22 Requisiten `wald/*`, `forest_loop`, `wald_nacht`; keine Tür, keine Figur | `look_wald` |
| Echo des Kindes („Warten“) | **fehlt**; `child_hum_0/1.wav` und der Untertitel `CAPTION_HUM` sind da | – |
| Haus: Tisch und Werkstatt, erste Gäste | **fehlt**: kein Werkbank- und kein Besucherzustand; der Tisch hat zwei Hocker (einen hat B5 ans Feuer gestellt) | `haus` |
| Katze „gefüttert (II–III)“ | **eine** Fütterung (`house.cat_fed`), kein Motiv in `motive.json` | `haus` |
| Weg von Akt II nach Akt III | **fehlt**: das Spiel endet mit Schwarz und Titel; das Tal hat keinen Ausgang in einen Wald; der Westweg ist nach dem Holz zu | `tal` |
| Sammelstücke: Nebenquests 0 von 2, Kuriositäten 0 von 6, Fragmente 0 von 3, Melodien 0 von 1 | – | – |

Was bleibt, wie es ist: der Antreiber-Weg (`weg`, die Signature-Begegnung des Slice; Plan 3: „bleibt die aus dem Slice“; die Nähte der Wegstücke sind Altlast, `KNOWN_ISSUES.md`), alle IDs der Akte I und II (nie umbenennen), das Ende von Akt II („Zum Meer.“, Schwarz, Titel, `Chapter.mark("act2")` vor `("slice")`), `look_wald` mit seinen Einträgen in `SMOKE` und `BENCHMARK` (der Leistungstest bleibt vergleichbar; neue Schlüssel statt Umbau), `slice_full.json`, `akt1_full.json`, `akt2_full.json`.

## Der Fluss von Akt III

| Segment | Inhalt | Ort | Neue Zeilen (geplant) | Pull Requests | Stand |
|---|---|---|---|---|---|
| V0 | Brief, Voreinstellungen, ADR-070, eingefrorener Stand `v2_akt2_end` | – | 0 | 1 | **gebaut** (dieser Pull Request) |
| W1 | Aufbruch: „Weiter“ beginnt den Morgen danach; Tal bei `morgen`, Mira ist fort; der Bach als Weg; Heldenquest `main_forest_way`; die Menüzeile | `tal`, `bachlauf` | 14 | 1 | geplant |
| W2 | Waldweg: erste Karte der Klasse M; die Wegzeichen des Antreibers; Rastplätze, die Fürsorge; Nebenquest A; Kuriositäten | `waldweg` (neu) | 44 | 1 | geplant |
| W3 | Hütte: der Einsiedler, drei Angebote, Bleiben, die Melodie | `waldweg` (Tür), `huette` (neu) | 52 | 1 | geplant |
| W4 | Flut: zweite Karte der Klasse M; das Warum des Antreibers als Ding; Nebenquest B | `flutlichtung` (neu) | 36 | 1 | geplant |
| W5 | Warten: der Nachtwald, das Echo des Kindes, der kurze Weg nach Hause | `nachtwald` (neu, S) | 14 | 1 | geplant |
| W6 | Heimkehr: Werkbank, der Einsiedler als erster Gast, die Katze, Kapitelmarke `act3` | `haus`, `tal` | 30 | 1 | geplant |
| W7 | Durchlauf: `akt3_full.json` aus `v2_akt2_end`, `calibrate.py --akt3`, Lesefassungen, Messung | – | 0 | 1 | geplant |
| **Summe** | | | **190** | **8** | |

**Budget.** 190 neue Zeilen sind 34 % der im Plan abgeleiteten 557 (Akt II: 121 gebaut von 162 geplanten, Akt I: 35 je Segment); alle Zeilen von Akt III stehen in `content/dialogue/akt3/` (auch die im Haus, als eigene Cues des Hauses, die `haus_scene.gd` aufruft), damit die Quellen der Kalibrierung sauber bleiben (`calibrate.act_sources("akt2")` zählt jede Datei in `slice/`). Rund 24 neue Tests je Segment, 8 Pull Requests (Akt II: 9; V1 entfällt, weil T6 und T7 getan sind und die Requisiten mit ihrem Segment entstehen).
**Auslöser für Cut-First:** mehr als 10 Pull Requests oder mehr als 260 neue Zeilen im Akt.

**Reihenfolge.** V0, W1, W2, W3, W4, W5, W6, W7. W3 und W4 sind die zwei schweren Begegnungen des Akts (Einsiedler, Antreiber): auf der Karte liegt zwischen ihnen die Nebenquest B, und W5 ist leise und unheimlich, nicht schwer (Bible §45: nie zwei schwere Momente direkt hintereinander).

**Speicher-Frage in jedem Segment:** Benennt oder ändert dieser Akt ein gespeichertes Feld? Vorgabe: nein (O9); Schema 2 bleibt, neue Werte sind Flags, die Voreinstellung `morgen` ist ein weiterer Wert des vorhandenen Textfelds `day_preset`.

## Vorgaben und Voreinstellungen (ADR-070)

Wo die Quellen sich widersprechen oder eine Weiche offen ist, gilt die Voreinstellung; jede ist umkehrbar und steht in Plan 11, Frage 8.

| Nr | Frage | Voreinstellung |
|---|---|---|
| O1 | Wie beginnt Akt III? | Das Ende von Akt II bleibt, wie es ist (Schwarz, Titel, Menü; ADR-030, Bible §56). **„Weiter“ setzt den Morgen danach fort**: `TalScene` erkennt `Chapter.reached("slice")` ohne den Beat `act3_morning` (das Tor ist `slice`, nicht `act2`: ältere Endstände tragen `act2` nicht), blendet auf, Voreinstellung `morgen`, Mira ist fort. Der Beat verhindert die Wiederholung. Ein Spiel, das direkt vom Titel in den Morgen läuft, wäre eine spätere Politur und ein ADR-030-Nachtrag. |
| O2 | Wohin führt der Weg? | Durch den Bachlauf nach Süden, am Wasser entlang („Zum Meer“ folgt dem Wasser): die Hecke im Tal ist seit B3 offen (`house.mira_visited`), im Süden des Bachlaufs liegt eine Tasche neben dem Bach (Reihe 62 bis 63, Zelle 44 bis 48; die Karte hat 66 Reihen), aus der eine Tür in die Wald-Karte führt. Der Rückweg ist derselbe; es gibt keine Schnellreise (Plan 3). |
| O3 | Tag oder Nacht? Welcher Stil? | **Tag**: Akt III hat Humor 4 bis 5 und Bible Risiko 10 („die Wirklichkeit wird schöner“). Eine neue Voreinstellung `morgen` (klares, kaltes Licht, dünner Dunst), die Hütte `abend`, das Warten `nacht` (die Palette des Prototyps). Stil `tal` mit einem neuen Modul `tools/art/akt3_props.py` (Hochwald, Hütte, Rastplatz, Wegzeichen; wie Akt II); kein neuer Bake-Stil, keine 12 Lichter im Wald (vertagt bis Akt IV, `OFFENE_PUNKTE.md`). |
| O4 | Karten | Zwei der Klasse M (`waldweg` bis 120 × 70, `flutlichtung`), ein Innenraum der Klasse S (`huette`, Zoom 1,5 wie das Haus) und eine kleine Nachtkarte (`nachtwald`, aus dem Prototyp). Jedes Layout landet in einem Pull Request (ADR-068), mit eigenem Generator `tools/art/layout_akt3_maps.py`. |
| O5 | Fürsorge | Die Facette `care`, ihre **neue Möglichkeit**: sich und andere versorgen. Am **Rastplatz** (Sitzstamm, Feuerstelle, Kessel) kann die Spielerin rasten und Tee machen; das erste Mal aus eigenem Willen setzt `care` und das Flag `forest.rested`. Leser: der Antreiber (Antwort „Setz dich. Es gibt Tee.“), der Einsiedler (die Antwort beim Gehen), das Haus (W6). Keine Zahl, kein Balken, keine Lebenspunkte, kein Zähler, kein Wert `value.care` (die Werte bleiben drei). Das Wort „Selbstfürsorge“ ist gesperrt, das Wort „Fürsorge“ erscheint nicht im Spieltext (Bible §16: sie ist eine Handlung: Tee, Feuer, Pause). **„Alternative Lösungen zu Durchhalten“:** der Hang im Waldweg wird mit Rast leichter als im Durchhalten (Entwurf im Brief von W2; Cut-First-Platz 3, falls er sich als Mühe ohne Wirkung zeigt). |
| O6 | Einsiedler | Eine Hütte (Innenraum `huette`), drei freiwillig ablehnbare Angebote (Tee vor der Tür, ein Platz drinnen, Bleiben); die Tür ist nie abgeschlossen und nie gesperrt, kein `Blocker`, kein `player.lock` ohne Grund. Bleiben ist erlaubt in **höchstens drei Stufen**, jede eine Antwort der Spielerin und nie eine Zeit (keine Uhr, kein Aussitzen; „Mehr Zeit lassen“ hat hier nichts zu verlängern); mit jeder Stufe wird das Bild ein Stück enger (Zoom 1,5 → 1,75 → 2,0, das Fenster zeigt immer dasselbe) und nichts Neues geschieht. Danach speichert das Spiel (Beat) und die Tür steht offen; es gibt kein Ende des Bleibens und keine Strafe, keine verlorenen Stunden (Bible §49). Er hält nie fest, lebt gern dort und wird nicht bewertet (Bible §51: Alleinsein ist nicht schlecht). Stimme `low`, Sprecher „Einsiedler“. |
| O7 | Das Warum des Antreibers | **Ein Ding, keine Erklärung** (Bible §14 und Risiko 8, §51, `STIL.md`: „Ding vor Gedanke“): eine Flutmarke auf der Lichtung, ein Lager, das das Wasser genommen hat, und seine Spur, die davonläuft. Es zeigt, warum seine Strategie sinnvoll entstand (Schnellsein hat jemanden gerettet), und nennt weder Ursache noch Täter, noch Wirkung auf die Spielerin. Danach sitzt er oder nicht (die Wahl der Spielerin; Tee ist eine Antwort mit `care`); in jedem Fall repariert er danach (Werkbank im Haus, W6) und plant seine Freizeit (der Gag steigt: ein Plan für das Nichtstun, Bible §42). Er ist kein Begleiter und geht nie mit. |
| O8 | Mira in Akt III | Kein Auftritt (Plan 3: ihre Wege kreuzen sich in II, IV, VI, VII). Der Morgen (W1) zeigt ihre Abwesenheit als Spur an einem Ding, ohne Gespräch und ohne Erinnerungsvariante. |
| O9 | Haus und Speicher | Die Werkbank ist ein Flag (`house.workbench`), jeder Gast ein Flag (`house.guest_<id>`, gezählt über das Präfix wie `Collection._flags_with`), ein Eintrag der Achse „Besucher“ in `motive.json`; **kein Schema 3** (additiv genügt, ADR-067; Plan T9 verschiebt sich auf den ersten Akt, der Zustand braucht, den ein Flag nicht trägt). Der „zweite Stuhl“ ist der Stuhl, den der Einsiedler selbst mitbringt. |
| O10 | Das Echo des Kindes | **Warten**, kein Fragment, keines der acht Bilder, kein Kind im Bild und kein Wort des Kindes: im Nachtwald steht eine kleine Laterne am Boden und brennt; man geht auf sie zu, sie bleibt, wo sie ist, und das Summen (`child_hum`) antwortet einmal, wenn die Spielerin sich dazusetzt. Kein Zähler, keine Auszeichnung, keine Erklärung; wer wegsieht, verliert nichts. Beat `act3_waiting`. Prüflinse wie in Akt I und II (Täter, Ursache, Einordnung, Bilder aus der Liste, Zählen, Zwang). |
| O11 | Katze | Sie bleibt im Haus; W6 gibt die zweite Fütterung („gefüttert II–III“) und die Katze schläft auf der neuen Werkbank statt auf dem Antreiber. Die Katze wird als Gag in `motive.json` eingetragen. |
| O12 | Zeilen und Humor | 190 neue Zeilen; Humor 4 bis 5 aus dem Antreiber-Gag (Wegzeichen, Freizeitplan), der Katze, dem trockenen Einsiedler und den Dingen (nicht aus Reflex nach einem schweren Moment, Bible §45). Mira, der Richter, die Ziege und die Kartoffel treten nicht auf. |
| O13 | Heldenquest | `main_forest_way` („Der Weg durch den Wald“) wächst je Segment um eine Stufe (`leave` W1, `brook` W1, `wood` W2 mit den Zielen `hermit` und `flood`, `night` W5, `home` W6, `done`); Einsiedler und Flut dürfen in beliebiger Reihenfolge besucht werden. |
| O14 | Menü nach dem Ende | `SaveSystem.slice_finished()` und die Zeile „Hier endet der Prototyp“ (`END_OF_SLICE`) hängen am neuesten Spielstand und am letzten Kapitel, das dieser Build kennt (`Chapter`), nicht an irgendeinem Spielstand mit `chapter.slice`; W1 baut es. |
| O15 | Kapitelmarke | `Chapter.mark("act3")` am Ende von W6, in einem Block mit dem Autosave; `chapter.act3` steht in `WRITE_ONLY_FLAGS`, bis Akt IV es liest. |

**Ohne Rückfrage entschieden:** alle Zeilen in `content/dialogue/akt3/` (auch die des Hauses); Segmentkürzel `W`; kein V1 (T6 und T7 sind getan); die Neuplanung nach dem Durchlauf von Akt II bleibt dem Projektinhaber überlassen (Plan 11, Fragen 3 bis 7 gelten weiter: nach Abschnitt 5 weiterbauen, keine Länge ändern); `look_wald` bleibt Prototyp und Messlatte des Leistungstests.

## Risiken und Kürzungen

- **Der Anschluss hängt an allem:** das Ende, der Schutz gegen doppeltes Enden, `slice_full.json`, die Prüfung „vertical slice finished“ in `check.sh`, das Startmenü und `test_slice_saves` (der heute „keine Szene nach dem Ende“ erwartet) gehen davon aus, dass der Slice endet. O1 lässt das Ende unberührt und ändert nur, was „Weiter“ danach tut; W1 trägt die geänderten Tests und die Menüzeile.
- **Alleinsein darf nicht falsch wirken** (Bible §51, `einsiedler.md`): kein Moralurteil, kein „Alleinsein ist gesund“, kein Festhalten mit Angst; der Einsiedler ist freundlich, die Hütte warm, und das Bleiben hat dieselbe Würde wie das Gehen.
- **Das Warum darf nichts erklären** (Bible §15, §51, `antreiber.md`): keine Ursache für die Spielerin, keine Kindheitsdiagnose, keine Therapiesprache; die Flut zeigt, warum Rennen einmal half, und sagt nicht, was es bedeutet.
- **Fürsorge ist ein Wort, das schnell nach Ratgeber klingt:** `vocabulary.json` sperrt „Selbstfürsorge“, „achtsam“, „Grenzen setzen“; die Handlung ist Tee, Feuer, Sitzen. Keine Zahl, kein Balken, kein Streak (Bible §52).
- **Zwei Karten der Klasse M in einem Akt:** jedes Layout in einem Pull Request, der Aufbau ist gemessen (ADR-068), die Bildrate auf dem Mac nicht; ohne Marker orientieren Weg, Wasser und das Journal (Plan 6, Brief B3).
- **Antreiber-Zustände aus Akt II:** er sitzt am Feuer (`house.antreiber_by_fire`, mit oder ohne `house.antreiber_refused`) oder steht beschäftigt im Tal (`house.antreiber_left`); `house.antreiber_postponed` kommt dazu. W2 und W4 müssen jeden Zustand tragen, ohne ihn vorauszusetzen.
- **Zählung der Akte:** `calibrate.act_sources("akt2")` nimmt jede Datei in `slice/`; Zeilen von Akt III dort würden Akt II zugerechnet. Darum alle in `akt3/`.
- **Prozess:** der Text der Akte I und II ist ungefroren, alle Lesefassungen unbeantwortet; Akt III zitiert damit ungefrorenen Text (das war in Akt II genauso). Die Stolpersteine in `check.sh` sind ungesperrte IDs, Flags ohne Eintrag in `motive.json`, fehlende `PLACE_`-Zeilen und Dialogdateien ohne Eintrag in der POT-Liste.

**Cut-First für Akt III:** 1. Nebenquest B (die Nebenquest A trägt den Antreiber-Gag), 2. Kuriositäten von 6 auf 4, 3. der Hang als „Alternative zu Durchhalten“ (die Rast bleibt), 4. W5 auf einen Cue, 5. Nebenvarianten des Antreibers.
**Nie streichen:** der Anschluss (O1, W1), der Einsiedler mit seinen drei Angeboten, das Warum als Ding, die Rast mit der Facette `care`, die Werkbank mit dem ersten Gast, das Warten, die Katze.

---

Die Briefe der Segmente W1 bis W7 entstehen mit ihren Pull Requests.
