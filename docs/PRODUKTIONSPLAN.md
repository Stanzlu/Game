# Produktionsplan (Vorproduktion Full Production)

Stand 23.10. · Basis: Build v0.8.4 · Freigabe: ADR-049 (Playtest-Gate ohne Tester abgenommen, Vorproduktion
freigegeben) · Annahmen: ADR-050

Dieser Plan ordnet die Arbeit nach dem Gate. Er ist kein Terminplan: Aufwände sind Größenordnungen, belastbar
werden sie erst mit den Messungen aus P6.1 und dem Akt-I-Durchlauf. Entstanden ist er aus vier Analysen (Bible,
Technik, Grafik und Ton, Schreiben), einer Synthese und zwei Gegenprüfungen (Vollständigkeit, Machbarkeit); deren
Einwände sind eingearbeitet.

**Marker:** **[V]** im Repo gelesen, gezählt oder hier gemessen · **[B]** aus [V] gerechnet · **[S]** Schätzung ·
**[P]** Vorschlag, kein Bible-Text. **Größen** (immer [S]): **S** bis etwa eine Arbeitssitzung, **M** 2–4 Sitzungen,
**L** mehr oder dein Urteil über Aussehen oder Klang nötig.

## Kurzfassung

- **Zuerst** (ohne Rückfrage, nichts im Spiel ändert sich sichtbar): schnellere Prüfschleife, Validator und
  Speicherregeln, Schreibwerkzeuge (P6.1–P6.3).
- **Dann** Stilbuch, Stimmenblätter und ein kurzer Writing-Pass auf den Slice (P6.4–P6.5); dafür liest du rund
  eine Stunde.
- **Danach Akt I (Elysia)** von rund 15 auf rund 100 geplante Minuten (gebaut und im Modell: rund 14, Abschnitt 10.1), Segment für Segment, je Segment ein Pull Request mit
  Lesefassung für dich (P6.6–P6.12). Die große Kartenarbeit (Großkarten, Kartenformat v2, neuer Baker) kommt erst
  vor der ersten großen Region der Wirklichkeit, nicht vorher.
- **Von dir gebraucht:** zwei Entscheidungen (Abschnitt 11, am 24.10. nach Empfehlung entschieden) und seit P6.13 vier Fragen (Abschnitt 11, 3 bis 6). Ohne Antwort oder mit „Weiter“ gilt die Empfehlung
  (wie bei ADR-047), und sie bleibt umkehrbar.

## 1. Ausgangslage

1. **Slice** [V]: 4 Orte (Elysia 65×40, Tal 68×38, Haus 40×24 Zellen, der Weg aus zwei Wegstücken), 75
   Dialog-Cues, 444 Zeilen-IDs (205 gesprochen, 172 Erzählung, 67 Antworten), rund 3.840 Wörter. Die Spielzeit ist
   nie gemessen (Schätzungen 20–50 Minuten).
2. **Inhalt** [V]: 7 Quests (5 im Slice verdrahtet), 10 Items (1 Kuriosität), 79 Journalzeilen (41 davon Miras
   Erinnerungen). Nur Mira hat Beziehungsinhalt; Tess, Orin und Lio sind IDs in `GameState.NPCS`.
3. **Code** [V]: 189 GDScript-Dateien (rund 18.900 Zeilen) plus rund 12.900 Zeilen Tests, 691 Tests.
4. **Grafik und Klang** [V]: alles aus Skripten (`tools/art`, `tools/audio`): 106 Prop-Typen, 6 Figurensheets, 4
   Musikstücke (102,5 s, 17,9 MB WAV), 58 SFX-Namen. Fremd sind nur 3 Schriften (OFL).
5. **Prüfschleife** [V]: `tools/check.sh` braucht in dieser Umgebung 15–20 Minuten, davon GUT rund 10 Minuten (594 s
   für 691 Tests). Laut Analyse gehen davon rund 380 s auf 14 Story-Tests, die in Spielzeit warten [S, nicht
   nachgemessen]. Wie `local-ci` konfiguriert ist, steht nicht im Repo.
6. **Karten** [V]: Textformat mit einer Legende je Karte; Tal belegt 66 Zeichen, 43 davon für einzelne
   Platzierungen. Der Parser existiert zweimal (GDScript, Python). Tal backen: 13,7 s; eine geänderte Heckenzelle
   verändert 17,4 % aller Bodenpixel, weil der Baker aus einem einzigen Zufallsstrom zeichnet.
7. **Im Modell nicht vorhanden** [V]: 24 Erinnerungsfragmente, 12 Melodien, 30–40 Kuriositäten (1 vorhanden),
   Facettenstufen (Facetten sind Booleans, vergeben wird nur „Grenzen“), Werte, Garten, Zustand der Beschützer,
   Erscheinungsbild der Spielfigur, Melodien im Haus.
8. **Umfang** [B]: Bible §37 plant 11,0 h Hauptpfad (13–16 h mit Nebeninhalt), rund 13- bis 22-mal der Slice. Der
   Slice entstand im Kern an einem Tag; danach kamen rund 60 % der Commits als Vertiefung und Rückmeldung. Der
   Engpass war nicht das Schreiben, sondern Prüfen und Nachbessern [V, `git log`].

## 2. Leitplanken

- **Kosten:** Master-Prompt §51 setzt 0 € für den Slice und verlangt danach eine bewusste Budget-Entscheidung mit
  Gegenüberstellung. Bis du entscheidest (Abschnitt 11, Entscheidung 1), gilt weiter: nichts Kostenpflichtiges.
  Neue Werkzeuge nur mit Prüfung, ADR und Eintrag in `docs/DEPENDENCIES.md`. Fremde Assets nur CC0, Schriften OFL
  (ADR-003).
- **Bible und ADR:** Abweichungen nur mit ADR und Rückfrage. Annahmen, die keine Abweichung sind, stehen gesammelt in
  ADR-050 (Abschnitt 3).
- **Ablauf:** ein Branch und ein Pull Request je Segment oder Arbeitspaket, kleine thematische Commits,
  `tools/check.sh` grün vor jedem Push.
- **Qualität:** keine Fake Choices, keine Therapiesprache, keine sichtbaren Zahlen für Beziehungen oder Facetten,
  Inhalte auf Deutsch. Sensibilität nach §51 (das Kind: kein Täter, keine Traumaerklärung). Retention-Ethik nach §52:
  keine Dailys, Streaks oder künstliche Endlosigkeit; Elysias Belohnungsschleifen bleiben endlich und parodieren
  nur. Offline und ohne Datensammlung (§54, §55): Messmarken bleiben im lokalen Log.
- **Barrierefreiheit und Speichern** sind feste Prüfpunkte jedes Segments (Abschnitt 6).
- **Messen statt schätzen:** Jedes Segment bekommt Messmarken (`Log.record`, ohne Autosave) und Story-Marken
  (`Beat.mark`, mit Autosave) mit festen Namen.
- **Offene Schuld bis zum Release:** Bible §61 verlangt mehrere vollständige externe Playtests vor einer
  Veröffentlichung. ADR-049 verzichtet nur auf den Slice-Test; diese Schuld steht in `OFFENE_PUNKTE.md`.

## 3. Annahmen (ADR-050)

Keine Bible-Abweichung, sondern Lesart oder Arbeitsregel. Du kannst jede kippen.

| Annahme | Begründung |
|---|---|
| **Twist I ist der Riss**, bei rund 16 % statt „ca. 20–25 %“ | §38: „Elysia ist nicht die gesamte Welt“ – genau das zeigt der Riss. Bei 11 h liegt er rechnerisch bei 15,9 %; „ca.“ ist weich. Kein zusätzlicher Story-Beat |
| **Die Signature-Begegnung des Antreibers bleibt die aus dem Slice** (Rennen ohne Ende, §14) | Akt III vertieft ihn: sein „Warum“ (§59 Risiko 8) und die Freizeit-Optimierung als Running Gag; die neue Begegnung in Akt III gehört dem Einsiedler |
| **Mira reist nicht dauerhaft mit** | Bible §13 und §37 (Akt VI: „geht ihren eigenen Weg“), ADR-042. Die Wege kreuzen sich in II, IV, VI und VII |
| **Der Richter beginnt in Akt II**, Bogen über drei Akte (bedrohlich, durchschaubar, unfreiwillig komisch) | Elysia kritisiert nie; §14 |
| **Elysias Mini-Quests** (Schmetterlinge, Brunnen, Auftragstafel) zählen nicht zu den 15–20 Nebenquests | Sie sind die RPG-Täuschung des Hauptpfads (§10) |
| **Humor:** Elysia bleibt so komisch wie im Slice (Überbestätigung) | §59 Risiko 9 will Elysia „wirklich attraktiv und spaßig“; die 2/10 aus §32 messen den Humor der Figuren, nicht Elysias Übertreibung |
| **Erscheinungsbild (§6):** wenige symmetrische Startvarianten beim neuen Spiel, später Kleidung, Hüte, Narben als Überlagerungen über das Haus | §6 verlangt es; Zusätze sind Cut-First („zusätzliche Charakteranpassung“, §62), die Startwahl nicht |
| **Haus als Rückkehrort:** Das Haus bleibt im Tal; jeder Akt endet mit einem Besuch dort, Reisen zwischen Regionen über Wege, keine Schnellreise | §19 (Zurückkehren), §26–27. Klärt die Größe der Regionen mit |
| **Spielstände aus Slice-Builds müssen nicht überleben**; dafür ein eingefrorenes v2-Fixture und eine Alias-Tabelle für Szenen | Gate-Bericht; billig jetzt, teuer nach dem ersten Schema-Bruch |
| **Textkarten bleiben** (kein Tiled oder LDtk); Prototyp-Szenen (`look_*`, `sandbox`) bleiben, bis eine echte Szene sie ersetzt | Ich baue Karten ohne Oberfläche; der Leistungstest nutzt `look_elysia` und `look_wald` und soll vergleichbar bleiben |
| **Englisch ist nicht Teil dieses Plans** | Erst nach allen Textpässen (ADR-020: der deutsche Text ist der Schlüssel) |
| **Kuriositäten-Ziel 36**, Porträts erst nach einem Pilot | §31 und §48; Porträts sind kein Bible-Muss |
| **Offene vorläufige ADRs:** ADR-007 (Darstellung) und ADR-015 (Antreiber-Werte) gelten als angenommen; ADR-017 (Look-Pipeline) entscheidet Entscheidung 1 | `OFFENE_PUNKTE.md`, Abschnitt 7 |
| **Ohne Tester:** Der Desire-Test aus §57 ist dein Urteil; die P-Zeilen aus `OFFENE_PUNKTE.md` gelten mit den heutigen Werten, bis du beim Akt-I-Durchlauf etwas anders siehst | ADR-049 |

## 4. Content-Plan Akt I (Elysia)

### 4.1 Rahmen

- Bible §37: Akt I dauert 1:45 h. §10 nennt als RPG-Hülle XP, Level, Gold, Loot, Seltenheiten, Truhen, Popups,
  Quests, kleine Dungeons, Minispiele, Händler, Feste. Der Slice hat XP bis Popups und 3 Elysia-Quests;
  Dungeon, Minispiel, Händler und Fest fehlen [V].
- Elysia dauert im Slice rund 10–15 Minuten [S]. 11 von 12 Vorausdeutungen aus §46 sind als Keim vorhanden [V]. Es
  fehlt die Raumschichtung Zimmer–Mauer–Garten–Straße–Stadt–Welt, die Twist II (§38) später rückwirkend lesbar
  macht; sie muss jetzt in die Karten, nicht nachträglich.
- §59 Risiko 2 verlangt eine mechanische Herausforderung je Region. In Elysia ist sie die Wahrnehmung (die
  Spiegelhalle), alles andere bleibt bewusst mühelos.

### 4.2 Segmente

| Nr | Segment | Stand | Min [P] | Inhalt |
|---|---|---|---|---|
| A1 | Erwachen und Garten | vorhanden | 14 | Auslöser auf die neuen Quests umstellen (4.6) |
| A2 | Gasthaus innen | neu | 9 | Gastwirt als Gesicht des Betäubers, Ebene „Zimmer“, drei Begegnungen |
| A3 | Marktplatz und Straße | neu | 14 | Händler mit Spiegelzwilling, Auftragstafel, 6–8 Elysianer-Typen |
| A5 | Spiegelhalle (kleiner Beobachtungs-Dungeon) | neu | 12 | Wahrnehmung als Mechanik, erste Facette „Wahrnehmung“ |
| A6 | Das Fest | Markt im Festzustand | 14 | rund +11.000 XP, Level 48; Einladung des Gastwirts |
| A7 | Wiederholung | alle Orte im Schleifenzustand | 9 | Schleifen-Flags, Musikstufen, wortgleiche Sätze |
| A8 | Kind-Spur | neu | 12 | drei Stationen, drei Fragmente, die Melodie des Kindes |
| A9 | Stein, Samen, Riss | vorhanden | 5 | Anschluss anpassen |
| A4 | Minispiel, das man nicht verlieren kann | neu | 5 | nur wenn Zeit bleibt (Cut-First, Platz 1) |

- **Summe** [B]: 89 Minuten geschrieben plus rund 11 Minuten Erkunden ergibt rund 100 Minuten; mit A4 rund 105.
- **Karten** [P]: Garten (vorhanden), Gasthaus innen (rund 40×24), Marktplatz und Straße (rund 60×40, Fest- und
  Schleifenzustand per Flags, ADR-037), Stadtmauer und Tor, Spiegelhalle (drei Räume in einer Karte): 4 neue
  Karten, alle im heutigen Format und nicht größer als das Tal. Alle Karten sind zustandsgesteuert, weil Akt VI nach
  Elysia zurückkehrt (§37, §62: nie zuerst streichen).
- **Raumschichtung** [P]: Zimmer (Gasthaus), Mauer und Tor, Garten, Straße, Stadt (Markt), Welt (Weltenbaum),
  unbeschriftet. Die Bilder des Hauses kommen nur über die Fragmente des Kindes und werden nie erklärt (§15, §38).

### 4.3 Bestand und Neues

| | Slice [V] | Akt I Ziel [P] |
|---|---|---|
| Karten | 1 | 5 |
| Cues | 14 | rund 100 (80–115) |
| Zeilen-IDs | 89 | rund 650 (550–780), davon rund 560 neu (rund 4.900 Wörter) |
| Sprechende Rollen | 4 | rund 10 in 18–22 Platzierungen mit Spiegelzwillingen |
| Quests | 3 | 2 Haupt, 5 Mini, 1 Neben |
| Items | 5 | rund 12 |
| Fragmente, Melodien, Facetten | 0, 0, 0 | 3, 2, 1 |
| Musik | 1 Stück in 3 Stufen | plus 3–4 Varianten (Gasthaus, Halle, Fest, weitere Stufen) |
| Props, SFX | 31 Prop-Typen | plus 25–40 Props, plus 10–15 SFX [S] |

### 4.4 Figuren, Quests, Folgen

- **Gastwirt** [P]: drei Begegnungen mit steigendem „Du musst heute nicht zurück“, jedes Mal frei abzulehnen; nie
  ein Schurke (§14). Das bereitet das freiwillige Aufstehen in Akt VI vor.
- **Neue Rollen** [P]: Händler, Festmeisterin, drei benannte Elysianer-Typen mit Beruf, ein Hallenwächter. Jeder
  Typ in drei wortgleichen Varianten (normal, Schleife 1, Schleife 2); das trägt das Unbehagen. **Stand A9 (ADR-064):** Schleife 2 gibt es nur dort, wo ein halb so langer, schon gesagter Satz da ist (Torwächter, Festmeisterin, Gastwirt); die übrigen bleiben bei Schleife 1.
- **Hauptquests** [P]: `main_elysia_hero` von 4 auf rund 8 Stufen, dazu die Kind-Spur mit rund 4 Stufen; jede gegen
  §47 geprüft.
- **Mini-Quests** [P]: 5 mit steigender Belohnung bei sinkender Leistung; Truhe und Fest dazu; eine echte, komische
  Nebenquest (§43). Level 48 ist sicher: `level_for_xp = 1 + int(sqrt(xp/15))`, der Slice garantiert 22.600 XP,
  das Fest bringt rund 11.000 [V/B].
- **Folgen** [P]: Antworten in Elysia wirken später in der Wirklichkeit (Flags wie `elysia.asked_for_no`); sie
  gehen ins Konsequenzen-Register (Abschnitt 5.7).
- **Fragmente und Melodien** [P]: drei Fragmente aus den Bildern von §15 (Flur, geschlossene Tür, leeres Zimmer),
  zwei Melodien (Summen des Kindes, die „perfekte“ Elysia-Fassung des Motivs). Hand, Verstecken und das
  ursprüngliche Haus bleiben für Akt V und bilden mit den dreien die sechs Bilder der zentralen Szene. Das Lied ist
  die Melodie des Kindes (in II im Haus hörbar, kein Fragment, O5), Warten kehrt als Echo (III) und als Blick (VI)
  wieder, auch das kein Fragment. Die Fragmente der übrigen Akte sind Spuren der Welt (5.5).

### 4.5 Segment-Regeln

Jedes Segment hat im Regions-Brief: Beat-Tabelle, Flags, anwesende Figuren, Humor-Ziel, Gewicht (§45: nie drei
schwere Hauptquests hintereinander), Motive, Scheitern und Speichern, Barrierefreiheit, und ob es endlich bleibt (§52).

### 4.6 Elysias Reizbogen

**Stand (A7, ADR-062):** Die Schleifen beginnen mit dem Hoch auf dem Fest (`elysia.feast_toast`, Heldenquest-Stufe `repeat`);
der Regler `ElysiaDirector` gilt für alle Elysia-Szenen. Die Musikstufen folgen dem Fortschritt (`elysia.market_seen`
→ `elysia.loops_1`, `elysia.stone_taken` → `elysia.loops_2`); Uhr-Rückfälle gegen Hängenbleiben: Musikstufen nach 20 und
40 Minuten, die Sätze nach 60 Minuten, der Riss 15 Minuten nach dem Beginn der Sätze. Wortgleiche Zeilen wählt allein
`elysia.loops`. (Davor, im Slice: Truhe und Schmetterlinge als Auslöser, Rückfälle 720 s und 150 s.) Größe S–M.

## 5. Die sieben Akte

Alle Tabellen hier sind Entwurf [P]; jeder Akt bekommt vor seinem Bau einen Regions-Brief, der sie verbindlich macht.

### 5.1 Überblick

| Akt | Min | Humor | Inhalt (Bible §37) | Slice-Stand | Größenklasse [S] | Aufwand [S] |
|---|---|---|---|---|---|---|
| I Elysia | 105 | 2 | Paradies, RPG-Täuschung, Wiederholungen, Kind, Riss | rund 15 Min | 5 Karten bis Tal-Größe | Text M, Karten L, Systeme M |
| II Riss und Tal | 90 | 3 | UI-Verlust, Wetter, Mira, erstes Nein, Haus, Wahrnehmung | rund 25–35 Min | Tal plus 1–2 M-Karten | Text M, Karten M, Systeme M–L (Haus, Richter) |
| III Wald | 90 | 4–5 | Antreiber (Warum), Einsiedler, Fürsorge, Natur | Nachtwald-Prototyp | 2 M-Karten | Text M, Karten M–L |
| IV Stadt | 120 | 7–8 | Gefälliger, Lio, Orin, Tess, Grenzen, Mira-Konflikt | 0 | 1 L-Karte plus Innenräume | Text L, Karten L, Beziehungen Tess, Orin, Lio |
| V Gebirge | 90 | 5–6 | Wächter, Kontrolle, Vertrauen, Rückblenden, Kind, Twist II | 0 | 2 M-Karten | Text M, Kunst L (Wächter-Maschine) |
| VI Rückkehr | 75 | 4 | Mira geht ihren Weg, Leere, Elysia, Betäuber, alte Systeme | 0 | Akt-I-Karten per Flags | Text M, Systeme M |
| VII Meer | 90 | 6–7 | Mira wiedersehen, Navigation, Loslassen, Finale, Samen | „Zum Meer.“ | 1 L-Küste plus Meer | Kunst L (Meer, Boot), Musikfinale L |
| Nachspiel | kompakt | 13 | Ziege im Rathaus, Antreiber plant Nichtstun, Ente, Katze (§42) | 0 | bestehende Karten | M |

- **Größenklassen** [P] nach Spielminuten, nicht nach Zellen: S bis 15 Minuten (Tal-Größe, 68×38), M 15–30 Minuten,
  L 30–60 Minuten. Querung [B] bei 88 px/s Gehen (Tuning „direkt“): Tal rund 12 s, 120×70 rund 22 s, 200×120 rund
  36 s. Die Zellengröße einer Klasse legt der Großkarten-Spike fest (T6), bevor die erste M-Karte entsteht.
- **Twist II** (60–70 %) fällt rechnerisch auf Minute 396–462, also Ende Akt IV und erste Stunde von Akt V [B].
- **Akt VI** [P]: Die Rückkehr schaltet `ui_mode` zurück auf Elysia, XP und Level bleiben, der verlorene Loot kommt
  nicht zurück; die Begegnung ist das freiwillige Aufstehen beim Gastwirt.

### 5.2 Beschützer

| Beschützer | Akt | Mechanik (Bible §14) | Warum-Szene | Scheitern | Danach im Haus (§64) |
|---|---|---|---|---|---|
| Antreiber | II, III | Rennen ohne Ende (Slice) | Akt III: woher das Rennen kommt | keins: Stehenbleiben löst | repariert, plant Freizeit |
| Einsiedler | III | Rückzug, der bleiben lässt | warum Alleinsein sicher war | man darf bleiben; das Spiel speichert und lässt gehen | kommt manchmal zu Besuch |
| Gefälliger | IV | Aufgaben 17, 18, 19: priorisieren und ablehnen | wem er gefallen musste | Aufgaben bleiben liegen, niemand stirbt | kocht zu viel |
| Wächter | V | Hebel und Systeme, mathematisch unmöglich | was er bewachen musste | Dinge gehen schief, die Welt endet nicht | prüft den Herd nicht mehr ganz |
| Betäuber | I (Gastwirt), VI | Bequemlichkeit, freiwillig aufstehen | warum Betäubung half | keins: Bleiben ist erlaubt, nur ohne Fortschritt | sitzt am Feuer |
| Richter | II, IV, VI | kommentiert Peinlichkeiten | wird unfreiwillig komisch | – | verschwindet nie ganz |

### 5.3 Laufende Gags, Kind, Facetten

- **Laufende Gags** (§33) [P]: Ziege (II, IV, Nachspiel: Rathaus), Kartoffel (`item_potato` existiert; II, V,
  Nachspiel: Belohnung), Ente (IV mit Orin, Nachspiel), Antreiber-Freizeit (III, VI, Nachspiel), Richter (II, IV, VI).
  Jeder Gag hat im Motivbuch Auftritte und Auflösung.
- **Das Kind** (§15) [P]: I Kind-Spur und Summen; II das Lied im Haus (hörbar, kein Fragment); III ein Echo im Wald;
  IV kein Auftritt; V die zentrale Szene „Ich bin da.“ mit den sechs Bildern des Kindes; VI ein Blick in Elysia; VII im
  Finale. Prüflinse §15/§51 für jedes Fragment, auch für die Spuren der Welt.
- **Facetten** (§16–17) [P]: je Akt eine Hauptfacette mit einer neuen Möglichkeit, nie als Zahl: I Wahrnehmung
  (verborgene Details sehen), II Grenzen (das Nein als Antwort, vorhanden), III Fürsorge, IV Verbindung und
  Integrität, V Vertrauen und Mut, VI Lebendigkeit, VII alle zusammen beim Navigieren. Werte (§18) wählt der Spieler
  in Akt II beim ersten Abend am Feuer; sie kehren in IV und VII wieder.

### 5.4 Haus und Garten

| Phase (§27) | Akt | Auslöser | Sichtbar | System |
|---|---|---|---|---|
| leer und kalt, Feuer | II | Slice | Kamin, Plane | vorhanden |
| Tisch und Werkstatt | III | der Antreiber repariert | Werkbank | Haus-Zustand |
| erste Gäste | III, IV | Einsiedler, Tess | zweiter Stuhl, Besuch | Besucherliste |
| persönliche Gegenstände | IV | Kuriositäten | Regale, Wände | allgemeine Platzierung für Kuriositäten |
| Garten | V | der Samen | Beet wächst mit der Geschichte | Gartenzustand |
| lebendiges Zuhause | VII, Nachspiel | Ende | Gäste, Musik, Katze | Melodien abspielbar |

Kochen, Schlafen und Kleidung (§26) [P]: Schlafen beendet den Tag (vorhanden als Abend), Kleidung trägt das
Erscheinungsbild (Abschnitt 3), Kochen erst, wenn der Gefällige es braucht (Akt IV). Die Katze: erscheint (II),
gefüttert (II–III), schläft auf dem Antreiber (ab II; im Slice vorhanden).

### 5.5 Sammelstücke

| | I | II | III | IV | V | VI | VII | Nachspiel | Summe |
|---|---|---|---|---|---|---|---|---|---|
| Nebenquests | 1 | 2 | 2 | 6 | 3 | 1 | 2 | – | 17 |
| Kuriositäten | 0 | 6 | 6 | 10 | 5 | 3 | 4 | 2 | 36 |
| Fragmente | 3 | 3 | 3 | 3 | 6 | 3 | 3 | – | 24 |
| Melodien | 2 | 1 | 1 | 3 | 1 | 1 | 3 | – | 12 |

**Zu den Fragmenten** (Bible §31: „Vertiefen Vergangenheit und Welt“): Von den 24 sind sechs Bilder des Kindes (§15):
Akt I Flur, geschlossene Tür, leeres Zimmer; Akt V Hand, Verstecken, ursprüngliches Haus, zusammen die zentrale Szene
„Ich bin da.“. Die übrigen 18 (II, III, IV, VI, VII je drei, V drei neben den drei Bildern des Kindes) sind Spuren der
Welt und der Vergangenheit: ein Ding oder ein Ort, der gedient hat, ohne einen Grund zu nennen; kein Kind, keine
Figur, keine Ursache, nie eines der acht Bilder (ADR-067, O5). Akt II: Uferbrett, trockene Rinne, Kräuterbündel im Haus.
`Collection.fragments()` zählt beide Arten; die zentrale Szene liest die sechs Kind-Flags einzeln.

### 5.6 Ende und Nachspiel

- **Ende** (§41, §64): kein gutes oder schlechtes Ende. Die Achsen Beziehungen, Haus, Garten, Besucher, Beschützer,
  Musik, Gegenstände, Samen, Mira und Entscheidungen lesen Flags aus dem Konsequenzen-Register; die Schlussszene
  zeigt die Figuren aus §64, jede in dem Akt angelegt, in dem sie auftritt.
- **Nachspiel** (§42): spielbar nach dem Abspann, bewusst endlich, mindestens Ziege im Rathaus mit Kartoffel,
  Antreiber und Nichtstun, Orin und die Ente, die Katze. Es wird verkleinert, nicht gestrichen (Humorbogen, §62).

### 5.7 Konsequenzen-Register

Eine Tabelle (Flag, wo gesetzt, wo gelesen, Ende-Achse) wächst mit jedem Segment; der Validator meldet Flags, die
gesetzt, aber nie gelesen werden (T2). So gilt „keine Fake Choices“ auch über Akte hinweg.

## 6. Barrierefreiheit, Speichern und Scheitern

**Barrierefreiheit** (§50; Prüfpunkt jedes Segments):

- Jedes neue Rätsel hat eine abrufbare Hilfe; jede zeitkritische Mechanik (Minispiel, Wächter, Boot) folgt „Mehr Zeit
  lassen“ und „Begegnungstempo“.
- Jeder neue Effekt (Fest, Wächter-Dampf, Brandung) liest „Bildschirmwackeln“ und „Blitzeffekte reduzieren“; ein
  Test oder eine Validator-Regel prüft das (T2).
- Informationen nie nur über Farbe; Rätselbilder bekommen eine Farbsehschwäche-Simulation im Aufnahme-Werkzeug.
- Große Schrift: neue Oberflächen nur über Theme-Typen; der Vollbild-Rand und „Bild füllen“ bleiben geprüft.
- Navigation in größeren Regionen: ein leises Mittel ohne Marker (Wege, Licht, Mira oder das Journal), festgelegt im
  Regions-Brief der ersten M-Karte.
- Ohne Tester ist „Accessibility getestet“ (§61) nur teilweise automatisch prüfbar; der Rest bleibt externe Schuld.

**Speichern und Scheitern** (§49):

- Höchstens 2 Minuten ohne Speichermöglichkeit am Stück [P]; ein Test misst die Sperrzeit jedes Segments.
- Jede Story-Marke speichert automatisch; der Autopilot speichert und lädt an jeder Marke (wie die Härtung im Slice).
- Jede Begegnung hat einen Ausgang statt eines Game Over; der Einsiedler lässt bleiben, ohne dass der Spielstand
  festhängt.

## 7. Technische Vorarbeit

Reihenfolge nach Nutzen: Was jede spätere Phase bei jedem Push bezahlt, zuerst; was erst große Regionen brauchen,
kurz davor.

| Nr | Arbeit | Größe | Wann |
|---|---|---|---|
| T1 | **Prüfschleife:** Zeit je Schritt in `check.sh`, Zeit je Testdatei; dann Story-Tests mit fester Bildrate, wo kein Audio wartet (der Dummy-Audiotreiber läuft auf der Wanduhr, KNOWN_ISSUES #67); Aufteilung auf mehrere Prozesse (4 Kerne); eine schnelle Stufe `check.sh --quick` für Zwischenpushes, die volle vor jedem Merge (ADR) | S Messung, M Umbau | P6.1 · **erledigt**: feste Bildrate genügt, GUT 592 → 70 s, `check.sh` 12 → 3 Min (ADR-051); Aufteilung und `--quick` bewusst nicht gebaut, erst über 6 Min wieder prüfen |
| T2 | **Validator:** Türziele und Spawn-Marker, `cut.say`-Cues, Quest-Stufen ohne Auslöser, gesetzte und nie gelesene Flags, doppelte Marken, Effekte ohne Einstellungsabfrage | S je Regel | P6.2 · **erledigt** (`StoryLint`, ADR-052); drei echte Funde behoben (Lampenflackern, XP-Leiste, Falter-Quest lesbar) |
| T3 | **Speicher-Politik und Kartenstempel:** ADR, eingefrorenes v2-Fixture, Alias-Tabelle in `SceneRegistry`, Kapitelmarken statt `slice.finished`; Prüfsumme je gebackener Karte | S | P6.2 · **erledigt** (ADR-052): `v2_slice_end.json`, `SceneRegistry.aliases`, `Chapter`, Stempel je gebackener Karte |
| T4 | **Karten-Linter im heutigen Format:** Erreichbarkeit ab den Spawns, Platzierung auf festen Zellen, Spiegelsymmetrie für Elysia (ADR-031, außer Stein und Riss), Übersichtsbild je Karte | S–M | P6.6 · **erledigt** (`MapLint`, ADR-055): keine ausgelieferte Karte musste sich ändern; Übersichtsbild `tools/art/map_overview.py` |
| T5 | **Elysia-Regler und Konventionen:** Reizbogen (4.6), Fragment-, Melodie- und Kuriositäten-Flags, Facette Wahrnehmung, Mess- und Story-Marken; Smoke-, Leistungstest- und Exportlisten aus `SceneRegistry`, neue Akt-I-Karten im Leistungstest | M | P6.6 · **erledigt** (ADR-055): `ElysiaDirector` (Uhr und Stufen-Flags für alle Elysia-Szenen), `Collection`, Facette `perception`, `SceneRegistry.SMOKE`/`BENCHMARK`; neue Karten tragen sich dort ein |
| T6 | **Großkarten-Spike:** synthetische Karte 200×120 backen und laden (Ladezeit, Knoten, Bildzeit, Speicher); Streu flach, gebacken oder in Blöcken. Zuerst prüfen, ob Zeichen außerhalb ASCII durch beide Parser gehen; nur wenn nicht, Kartenformat v2 mit `[objects]` | S, dann M | vor der ersten M-Karte (Akt II) · **erledigt** (ADR-068, `docs/PERFORMANCE.md`): Zeichen außerhalb von ASCII laufen durch beide Parser (Kartenformat v2 entfällt), Aufbau rund 85 ms plus 47 µs je Zelle, Klasse M bis 120 × 70 (Zeichnen ungemessen) |
| T7 | **Baker lokal:** eigener Zufallsstrom je Durchgang, Blöcke mit Rand, Vergleichsbild alt/neu; vorher `git gc` messen (die 108 MB sind unverpackt) und gebackene Bilder nur beim Einfrieren einer Region committen | S Spike, L Umsetzung | vor der ersten M-Karte · **Stand 25.10. (ADR-067):** vor der ersten Karte der Klasse M nur der kleine Teil (Messtabelle, Regel „Layout einer Karte in einem Pull Request“); der große Baker kommt mit der ersten Karte der Klasse L (Akt IV) · Messtabelle des Bakers in `docs/PERFORMANCE.md` (20 s und rund 50 MB plus 147 MB je Megapixel) |
| T8 | **Autopilot v2:** relative Zeiten, `until_flag`, `goto_marker`, Start aus Spielstand, ein Skript je Akt | M | vor dem Akt-I-Durchlauf · **erledigt** (ADR-065): `wait_for`, Makros `talk`/`use`/`enter`, relative Zeiten, Messung im Lauf; `goto_marker` und Start aus Spielstand nachrüsten, wenn ein Akt sie braucht |
| T9 | **Zustandsmodell je Akt, wenn er es braucht:** Haus-Zustand, Besucher, Garten, Werte, Beschützer, Erscheinungsbild; `world_state.gd` nach Bereichen teilen; Schema 3 einmal mit Migrationstest | M je Bereich | mit dem Akt |
| T10 | **Doku und CI:** `.github/workflows/ci.yml` angleichen oder entfernen, `local-ci` beschreiben, alte Testzahlen korrigieren, eine Kurzfassung der Regeln vor `DECISIONS.md` | S | P6.1 · **erledigt**: Workflow bleibt (prüft jeden Push mit `check.sh`, ADR-009), `CLAUDE.md` und `GATE_REPORT.md` aktuell, ADR-Index oben in `DECISIONS.md` (`tools/adr_index.py`, Schritt in `check.sh`) |
| T11 | **Kalibrierung:** Modell aus Wörtern mal Textgeschwindigkeit plus Wegen; dein Durchlauf-Log nur, wenn du magst | S | P6.6 · **erledigt** (`calibrate.py`, `docs/KALIBRIERUNG.md`): Slice 20,7 min bei normalem Tempo, 21,5 Zeilen je Minute gegen 6 im Plan; seit P6.12c auch Akt I (`--akt1`, rund 14 min); die Entscheidung über die Länge fällt bei deinem Durchlauf (Abschnitt 10.1) |

**Bewusst vertagt, mit Auslöser** (`OFFENE_PUNKTE.md`, Abschnitt 3): Licht (12 Lichtquellen im Wald, Lampen auf
Nachtgras) vor der ersten Nachtkarte in Akt IV; Regenspritzer auf Dächern vor der Stadt; feinere Ufer-Kollision vor
der Küste; Spiegelungen für wandernde Figuren vor Stadt und Hafen; Nähte des Antreiber-Wegs vor Akt III; Shader-Hänger
beim ersten Betreten und die Ausreißer bis 240 ms mit jeder neuen Region im Leistungstest; Leistung des Dialogue
Manager bei siebenfachem Text mit Akt I gemessen.

## 8. Grafik und Ton

**Grundsatz** [P]: Die prozeduralen Werkzeuge bleiben die Quelle (Paletten, Licht, Wind, Symmetrie, gemessene
Lautheit), darüber eine dünne, von Hand geschriebene Datenschicht. Ob das der endgültige Look und Klang ist,
entscheidest du (Entscheidung 1).

| Bereich | Weg ohne Kosten | Grenze | Größe | Wann |
|---|---|---|---|---|
| Böden, Umgebung | eigene Palette je Region, neue Baker-Materialien (Kopfstein, Schnee, Geröll, Sand, Meer); Wetter als Farbkorrektur | gleichmäßiger als von Hand | M je Region | vor dem Akt |
| Props | dieselben Generatoren mit neuem Stil, dazu 10–25 Spezialprops je Region | über rund 32×32 ohne Sichtkontrolle fehleranfällig | L gesamt | vor dem Akt |
| Kleine Bilder von Hand | Pixelraster mit Palettenschlüssel; der Lader schreibt PNG, ein Test prüft Farben, Größe, Umriss; für Kuriositäten, Fragmente, Schilder | gut für 16×16 | S je 10 | ab Akt I |
| Figuren | Rig erweitern (Frisuren, Outfits, Statur, Hüte, Brillen, Narben als Überlagerung), auch für das Erscheinungsbild der Spielfigur | lesbar, wenig Mimik (24×32) | M je 3–4 Designs | vor dem Akt |
| Tiere | kleines Rig für Katze, Ziege, Ente | einfach | M | Akt II |
| Porträts | keine; Pilot mit 2 Sprechern, dann entscheidest du | Gefühl über Text und Pose | M–L | nach Akt I |
| Titel, Schlüsselbild | aus Spielgrafik komponiert | Illustrationsniveau nicht erreichbar | S–M | vor einer Veröffentlichung |
| Wächter-Maschine, Meer und Boot | eigene Prototypen | die zwei schwersten Posten, stilisiert | L je | vor Akt V und VII |
| Musik | Themenbuch (Motiv 3-5-6-5-3-2), datengetriebene Schichten, Akt für Akt; synthetisch | charmanter Synth; Claude hört nicht | L | je Akt |
| Musik mit Samples | nur CC0; zuerst Erreichbarkeit, Größe und Lizenz der Quelle prüfen, einen Renderer per ADR wählen; Hörprobe des Tal-Stücks | bis gutes Indie-Kammerstück | M | nach Entscheidung 1 |
| Musik-Format | OGG statt WAV im Repo (17,9 MB für 102 s heute); Encoder per ADR (`ffmpeg` oder `soundfile`) | – | S | P6.7 |
| Ambience, SFX | `make_nature.py` je Region, Platzhalter ersetzen (KNOWN_ISSUES #65), Gruppen in `GROUPS`, `CLASSES`, `CAPTIONS` | Möwen, Menge, Glocken schwer | M je Familie | je Akt |
| Stimmen | nur Blips; `voices.json` als Parametertabelle für 15+ Sprecher | unterscheidbar, nicht ausdrucksstark | S–M | Akt I |
| UI | Skins Elysia und Real; dritter Skin „persönlich“ (§34) mit Schrift-Spike für große Schrift | Schrift ungeprüft | M | Akt IV |

**Lizenzen** [S]: Welche Sample-Bibliotheken wirklich CC0 sind, ist nicht geprüft; vor jeder Nutzung kommen Quelle,
Datum und Lizenztext in `DEPENDENCIES.md` oder `PLACEHOLDERS.md`. CC-BY, CC-BY-SA, NC und GPL sind ausgeschlossen
(ADR-003). Die Rechtslage KI-gestützt erzeugter Werke ist ungeprüft und gehört vor eine kommerzielle Veröffentlichung.

**Prüfwege:** Jedes neue Bild bekommt einen vergrößerten Kontaktbogen, jeder Klang `check_levels.py` und eine
Hörprobe für dich. `PLACEHOLDERS.md` markiert ein Asset erst nach deiner Abnahme der Region als endgültig.

## 9. Schreiben

### 9.1 Befund [V]

Stimmenblätter, Glossar, Motivbuch und eine lesbare Fassung des Texts gibt es nicht. Der Slice-Text ist ein
ungeprüfter Entwurf (ADR-036). Der Validator prüft Struktur, nicht Stimme oder Ton. Du bist der einzige Leser
(ADR-049), also muss das Prüfen für dich billig sein.

### 9.2 Writing-Pass auf den Slice (P6.5)

- `haus_rest_5` streichen (tote Zeile, KNOWN_ISSUES #74).
- `el_wake_8` (Sprint-Hinweis) und `el_loop_2` (Wegweiser) prüfen; den Namen zweimal kurz hintereinander
  (`haus_mira_36`, `tal_end_12`) entscheiden; Spruchartiges in der Wirklichkeit auf „keine ständigen Weisheiten“
  prüfen.
- Miras Ansprache des Antreibers im Haus (KNOWN_ISSUES #49).
- Nicht anfassen: das erste „Nein.“ und „Zum Meer.“.
- Tests, die Wortlaut festnageln, auf IDs umstellen (mindestens 7 Testdateien).

### 9.3 Stilbuch, Stimmenblätter, Motivbuch (P6.4)

- **Stilbuch** (`docs/writing/STIL.md`, rund eine Seite) aus Messwerten des Slice: kurze Sätze (im Mittel 4,4 Wörter),
  Erzählung in 2. Person Präsens ohne Doppelpunkt, „…“ statt „...“, » « für Schilder, Gefühl durch Geste statt
  Aussage, Humor-Mittel je Welt, eine „Nie“-Liste.
- **Stimmenblätter** (`docs/writing/stimmen/`): 7 aus Slice-Belegen (Elysianer, Gärtnerin, Gastwirt, Mira, Antreiber,
  Kind, Antworten der Spielfigur), 8 aus der Bible und als „ohne Beleg“ markiert (Tess, Orin, Lio, Richter,
  Gefälliger, Einsiedler, Wächter, Betäuber). Je Blatt Funktion, Messsignatur, Verlauf, 10–15 Goldzeilen, 5
  Gegenbeispiele.
- **Motivbuch:** Vorausdeutungen (§46), laufende Gags (§33), Kind-Bilder (§15), Konsequenzen-Register; ein Prüfer
  meldet verschwundene IDs oder Flags.

### 9.4 Ablauf je Segment

1. Regions-Brief (4.5). 2. Entwurf mit Kopfkommentar je Cue. 3. Automatische Prüfungen. 4. Prüflinsen: Stimme,
Bible-Risiken, Kind und Sensibilität (§15, §51), Kontinuität, Humor und Takt, Antwortqualität, Barrierefreiheit,
Kürzen. 5. **Lesefassung** für dich: das Delta als lesbares Skript; wenn dein Konto es erlaubt als private Seite, auf
der du je Cue „OK“, „ändern“ oder „raus“ anklickst, sonst eine nummerierte Liste, die du in einer Nachricht
beantwortest. 6. Einfrieren.

### 9.5 Werkzeuge (P6.3)

- **S:** Statistik je Sprecher, Vokabel-Lint (Therapiesprache, mit Ausnahmeliste), Zahlen-Lint, Status-Tags
  `[#draft]`/`[#ok]`, ID-Sperre gegen stilles Umbenennen, Bericht ungenutzter Cues, gesetzt-aber-nie-gelesen.
- **M:** Generator der Lesefassung, Echo-Bericht je Antwort, Sprecherregeln im Validator.

### 9.6 Menge

Bei der Dichte von Akt I (rund 6 Zeilen je Minute) ergeben 11 Stunden rund 4.100 Zeilen-IDs, rund 35.000 Wörter
[B]. **Stand 25.10.:** gemessen sind 24 Zeilen je Modellminute (Abschnitt 10.1); die 6 sind kein Planungswert mehr. Vor Tess, Orin und Lio bekommt jede Figur ein Erinnerungsbudget (Mira hat nach einem Tag 41).

## 10. Phasen

Jede Zeile ist mindestens ein Pull Request; die Akt-I-Segmente je ein eigener. „Deine Zeit“ ist [S].

| Phase | Inhalt | Prüfung | Deine Zeit |
|---|---|---|---|
| **P6.0** | dieser Plan, ADR-050 (Annahmen), Schuld aus §61 in `OFFENE_PUNKTE.md` | Doku | Plan lesen, 2 Entscheidungen (rund 20 Min) |
| **P6.1** | T1 Prüfschleife, T10 Doku und CI | gleiche Zahl Tests, Zeit vorher/nachher, 10 Läufe ohne Flackern | – |
| **P6.2** | T2 Validator, T3 Speicher-Politik | je Regel ein roter Test-Fixture, v2-Fixture lädt | – |
| **P6.3** | Schreibwerkzeuge S (9.5) · **erledigt** (ADR-053) | Lints als `note:`, ID-Sperre aktiv | – |
| **P6.4** | Stilbuch, Stimmenblätter, Motivbuch · **geschrieben** (ADR-054), wartet auf deine Lektüre | Prüfer `motifs.py` grün | Blätter lesen (rund 45 Min) |
| **P6.5** | Writing-Pass auf den Slice, Tests auf IDs · **erledigt** (ADR-056); Lesefassung `docs/lesefassung/SLICE.md`, Einfrieren wartet auf dein „OK“ | `slice_full.json` grün | Lesefassung des Slice (rund 60 Min) |
| **P6.6** | T4 Karten-Linter, T5 Elysia-Regler und Konventionen, T11 Kalibrierung · **erledigt** (ADR-055) | der Slice spielt sich unverändert | – |
| **P6.7** | **(Entscheidungen 1 und 2, OGG, kleine Bilder: erledigt, ADR-057; Props, Figuren und Klänge je Segment)** Grafik und Ton für Akt I: Props im Elysia-Stil für Gasthaus und Markt, OGG, Pixel-Format für kleine Bilder; Sample-Hörprobe nur nach Entscheidung 1 | Kontaktbogen, `check_levels.py` | Kontaktbogen (rund 15 Min) |
| **P6.8** | A2 Gasthaus · **gebaut** (ADR-058, Brief in `docs/akt1/REGIONSBRIEFE.md`; rund 6 statt 9 Minuten, das Fest füllt die Lücke) | Smoke, Autopilot-Segment, Marken im Log | Lesefassung (rund 20 Min) |
| **P6.9** | A3 Markt und Straße · **gebaut** (ADR-059, Brief in `docs/akt1/REGIONSBRIEFE.md`; rund 9 statt 14 Minuten, Halle und Fest füllen die Lücke) | wie P6.8, Leistungstest mit der Menge | Lesefassung, ein Leistungstest |
| **P6.10** | A5 Spiegelhalle · **gebaut** (ADR-060, Brief in `docs/akt1/REGIONSBRIEFE.md`; rund 8 statt 12 Minuten) | wie P6.8, Hilfe abrufbar | Lesefassung, kurz spielen |
| **P6.11** | A6 Fest · **gebaut** (ADR-061, Brief in `docs/akt1/REGIONSBRIEFE.md`; rund 6 statt 14 Minuten); A7 Wiederholung · **gebaut** (ADR-062; rund 2 statt 9 Minuten, die Schleifen sind Zustand, kein Ort) | XP-Test Level 48, Schleifentexte wortgleich | Lesefassung |
| **P6.12** | A8 Kind-Spur · **gebaut** (ADR-063, Brief in `docs/akt1/REGIONSBRIEFE.md`; rund 8 statt 12 Minuten); A9 Anschluss an den Riss · **gebaut** (ADR-064; Stein nach dem Hoch, Samen-Zeile, Schleife 2 für Torwächter, Festmeisterin und Gastwirt; rund 1 statt 5 Minuten neu) | Akt-I-Durchlauf per Autopilot · **gebaut** (ADR-065, `akt1_full.json`: 141 s, Modell 14 bis 33 min gegen 100 geplant) | **Akt I spielen (rund 100 Min)** |
| **P6.13** | Neuplanung mit gemessenen Minuten; A4 nur, wenn du mehr Elysia willst · **erledigt** (Abschnitt 10.1, ADR-066): Minuten bleiben Modell, geplant wird in Zeilen und Pull Requests, die Länge entscheidet dein Durchlauf | Plan aktualisiert | Rückmeldung (Fragen in Abschnitt 11) |
| **P6.14** | Akt II: V0 Brief und Anschluss · **gebaut** (ADR-067, `docs/akt2/REGIONSBRIEFE.md`: 9 Pull Requests, 129 neue Zeilen (geplant 162, B1 baut 6 statt 15, B2 23 statt 25, B3 47 statt 62, B5 23 statt 30), im Modell rund 28 Minuten gegen 90); V1 T6/T7 klein · **gebaut** (ADR-068), B1 Ankunft · **gebaut** (6 Zeilen), B2 Nein und Blick · **gebaut** (23 Zeilen), B3 Bachlauf · **gebaut** (47 Zeilen statt 62, die erste Karte der Klasse M, 84 × 66; Quest „Die Reuse“, drei Kuriositäten, zwei Fragmente), B5 Feuer · **gebaut** (23 Zeilen statt 30: Werte am Feuer als drei Handgriffe und ein Schweigen, das Lied im Haus hörbar ohne Fragment, das dritte Fragment, Beat `act2_safe`), B4, B6, B7 | Smoke, Segmentskript und Marken je Segment, `akt2_full.json` | Fragen 7 (Voreinstellungen), Lesefassungen |
| **P6.15 ff.** | je Akt: Regions-Brief, Vorarbeit (T6, T7, T9 nach Bedarf), Karten, Text, Lesefassung, Durchlauf (`tools/autopilot/akt<N>_full.json`, `calibrate.py`); Reihenfolge II bis VII, Segmente wie in Akt I | – | je Akt Lesefassungen und ein Durchlauf |

**Abnahmeregel:** Ein Prüfpaket je Phase, höchstens 10 Fragen. Was unbeantwortet bleibt, setze ich nach meiner
Empfehlung um und markiere es als „vorläufig“; es bleibt umkehrbar.

**Aufwand:** Statt „Arbeitstagen“ zähle ich Pull Requests. Vor P6 waren es rund 25 Pull Requests in 22
Kalendertagen, die meisten davon Vertiefung und Rückmeldung [V]. Akt I (P6.6 bis P6.12c) hat sieben Segment-Pull-Requests (A2, A3, A5 bis A9)
und drei weitere gebraucht (P6.6 Karten-Linter und Kalibrierung, P6.7 Grafik und Ton, P6.12c Autopilot und Messung), zusammen zehn (geplant: 12–15 [S]); die übrigen Akte rechnet Abschnitt 10.1 mit diesen Werten.

### 10.1 Neuplanung nach Akt I (P6.13, Stand 25.10., ADR-066)

**Gemessen** [V] (ADR-065, `docs/KALIBRIERUNG.md`): Akt I hat 333 Zeilen. Der Autopilot spielt ihn in 141 Sekunden (55 mit offenem Gespräch,
110 Klicks, 10.016 Pixel übersprungene Wege). Das Modell (`calibrate.py --akt1`) gibt **rund 14 Minuten** bei normalem Tempo (11,5 bis 17,5),
als Obergrenze 33. Der Slice (446 Zeilen) liegt im Modell bei 20,7 Minuten (Bible-Ziel 45–60). Geplant waren 105 Minuten für Akt I.
Zuverlässigkeit: Zeilen, Wörter und Läufe sind gezählt; Anteil (60 %), Pause (1,2 s) und Umweg (×1,6) sind Annahmen, und es liegt keine gemessene Spielzeit eines Menschen vor
(du hast den Slice in mehreren Builds gespielt, aber nicht mit der Uhr, ADR-049; Akt I kennst du als Lesefassung). Keine zulässige Einstellung bringt Akt I auf 105 Minuten:
bei den Annahmen des Modells wäre ein Umweg von ×28 bis ×30 nötig, selbst bei „langsam, alles gesehen, Pause 2 s“ ×24; der äußerste geprüfte Eckfall
(langsam, alles gesehen, Pause 3 s, Umweg ×3) gibt 40 Minuten, die 33 Minuten oben sind die großzügige Obergrenze des Modells. Das Modell ist ein Maßstab, kein Urteil.

**Plan gegen Modell je Akt** (geplante Zeilen abgeleitet mit dem Verhältnis von Akt I, 650 Zeilen für 105 Minuten; Modell mit der Dichte von Akt I, 24 Zeilen je Minute):

| Akt | geplant (Min) | geplante Zeilen | Modell bei diesen Zeilen (Min) | Zeilen für die geplanten Minuten |
|---|---|---|---|---|
| I | 105 | 650 | 27 | 2.520 |
| II | 90 | 557 | 23 | 2.160 |
| III | 90 | 557 | 23 | 2.160 |
| IV | 120 | 743 | 31 | 2.880 |
| V | 90 | 557 | 23 | 2.160 |
| VI | 75 | 464 | 19 | 1.800 |
| VII | 90 | 557 | 23 | 2.160 |
| **I bis VII** | **660 (11 h)** | **4.085** | **170 (141 bis 215)** | **15.840** |

Lesen füllt bei den geplanten Zeilen nur rund 16 % der geplanten Minuten; die übrigen 84 % (rund 555 Minuten über sieben Akte) müssten Gehen, Rätsel, Minispiele und Erkunden tragen.
Das Minispiel A4 (5 Minuten) wäre 1 % davon. Zwei Hochrechnungen der Gesamtlänge widersprechen sich, weil sie verschieden viel Text annehmen: 87 Minuten
(Verhältnis von Akt I auf alle Akte) gegen 170 (alle geplanten Zeilen).

**Tempo der Fertigung** [V] (Git, `docs/akt1/REGIONSBRIEFE.md`):

| Segment | geplant (Min) | Zeilen neu | Wörter | Cues | PR |
|---|---|---|---|---|---|
| A2 Gasthaus | 9 | 69 | 675 | 16 | #34 |
| A3 Markt | 14 | 64 | 662 | 12 | #35 |
| A5 Spiegelhalle | 12 | 53 | 493 | 9 | #36 |
| A6 Fest | 14 | 35 | 370 | 4 | #37 |
| A7 Wiederholung | 9 | 7 | 86 | 1 | #38 |
| A8 Kind-Spur | 12 | 13 | 123 | 3 | #39 |
| A9 Anschluss | 5 | 3 | 29 | 0 | #40 |

Im Mittel 35 neue Zeilen und 14 neue Tests je Segment. Zwei Sorten: Segmente mit Karten, Requisiten und Figuren (A2, A3, A5: im Mittel 62 Zeilen) und Segmente mit Zustand und Anschluss
(A6 bis A9: im Mittel 15 Zeilen). Rund die Hälfte aller eingefügten Zeilen des Zeitraums lag vor dem ersten Segment (Werkzeug, Prüfer, Doku). Akt I liegt mit sieben
Segment-Pull-Requests und drei weiteren (P6.6, P6.7, P6.12c), zusammen zehn, unter den 12–15 geplanten, also unter der Cut-First-Schwelle (Abschnitt 12). Angeliefert gegen Plan 4.3:
51 % der Zeilen, 59 % der Cues, vier von fünf Karten, 25 Requisiten, keine neue Musik und keine neuen Effekte.

**Rest in Pull Requests** (abgeleitet): Die Akte II bis VII mit den geplanten 3.436 Zeilen sind bei 62 Zeilen je Pull Request rund 55, bei 35 rund 98 Segment-Pull-Requests; dazu kommt Vorarbeit
(Brief je Akt, T6, T7, T9), rund ein Pull Request je Akt. Wollte man 555 Minuten allein mit Text füllen (13.335 Zeilen), wären es 215 bis 382. Mit Spielzeit aus Mechanik statt Text
(Wächter-Maschine, Boot, Minispiele) wächst der Aufwand an den Systemen, den dieses Maß nicht erfasst.

**Was die Bible bindet** (Änderung nur nach Rückfrage und ADR, `CLAUDE.md`): 10–12 Stunden Hauptspiel (13–16 mit Nebeninhalt), Akt-Längen „ca.“ 1:45 / 1:30 / 1:30 / 2:00 / 1:30 / 1:15 / 1:30 (Summe 660 Minuten), „nicht gestreckt“
als Fertigdefinition, kein künstliches Dehnen, kein Spaziergangssimulator, „Lieber weniger Inhalte auf außergewöhnlichem Niveau als große Mengen mittelmäßiger Inhalte“, die Mengen aus §48 (rund sieben Regionen, 15–20 Nebenquests, 24 Erinnerungen, 12 Melodien, 30–40 Kuriositäten)
und der Slice mit 45–60 Minuten. Als Planungsannahme [P] sind dagegen die Zeilenzahlen (6 Zeilen je Minute, 4.100 Zeilen), die 12–15 Pull Requests für Akt I und die Größenklassen nach Minuten.

**Optionen für Länge und Dichte** (alle vorläufig; die Wahl hängt an deinem Durchlauf):

| | Weg | Folge | Bible |
|---|---|---|---|
| A | 660 Minuten mit Text füllen | rund 15.800 Zeilen, 3,9× der Planmenge | keine Abweichung, belastet „lieber weniger Inhalte auf außergewöhnlichem Niveau“ (§48) |
| B | 660 Minuten und die Planzeilen, Rest Spiel | 555 Minuten Mechanik und Erkunden; Großkarten, Minispiele, Boot, Wächter | keine Abweichung, belastet „nicht gestreckt“ und „kein Spaziergangssimulator“ |
| C | Planzeilen und Länge, wie das Modell sie ergibt | Spiel von rund 3 Stunden statt 11; die Twist-Zeiten rücken | **Abweichung** von Länge und Akt-Längen: ADR und deine Antwort |
| D | ein Textanteil t von 30 bis 50 % und der Rest Spiel | 4.800 bis 7.900 Zeilen plus Mechanik | keine Abweichung, wenn t so gewählt ist, dass 660 Minuten herauskommen |

**Empfehlung** (vorläufig, mit einem Satz von dir umkehrbar; ADR-066):

1. **Weiterbauen wie geplant** (Abschnitt 5): jeder Akt mit Brief, Segmenten, Lesefassung und Durchlauf, an den Mengen der Bible (§48) und der Reihenfolge II bis VII. Keine Abweichung von der Bible, kein Streichen.
2. **Minuten sind Modell, nicht Ziel.** Gebaut und berichtet wird in Zeilen, Karten, Requisiten, Cues und Pull Requests; jeder Brief nennt die Modellminuten neben der geplanten Zahl.
3. **6 Zeilen je Minute fallen als Planungswert.** Das Maß ist die gemessene Dichte, 24 Zeilen je Modellminute, als benannte Annahme.
4. **Die Länge entscheidet dein Durchlauf von Akt I** (mit dem Beat-Log, `calibrate.py --akt1 --log`): fühlen sich 14–18 Minuten an, trägt der Text allein nicht, und B oder D wird nötig; liegt es bei 30–40, stimmt der Slice-Faktor; bei rund 100 stimmt der Plan.
5. **A4 nicht ungefragt bauen.** Es bringt 1 % der fehlenden Minuten; wenn Elysia mehr braucht, ist Erkunden (T6 Großkarten) der größere Hebel.
6. **Messen in jedem Segment:** neue Zeilen, Wörter, Cues, Requisiten, Tests, Commits und die Autopilot-Sekunden der Beats; ein Lauf `akt<N>_full.json` je Akt.

**Fragen an dich** (Abschnitt 11, 3 bis 6): Wie lang fühlt sich Akt I an? Gilt die Bible-Länge (10–12 Stunden) als Ziel oder die Menge aus §48 als Umfang? Mehr Elysia (A4 oder Erkunden)? Wenn die Minuten bleiben: akzeptierst du, dass die meisten aus Spiel kommen? Wie lang ist das Nachspiel?

## 11. Entscheidungen für dich

Nur echte Weichen. Ohne Antwort oder mit „Weiter“ gilt die Empfehlung. **Stand 24.10.:** beide nach Empfehlung entschieden (ADR-057), nachdem der Projektinhaber den Plan mit „bau alles“ freigegeben hat; umkehrbar. **Stand 25.10. (P6.13):** die Fragen 3 bis 6 sind neu und offen; ohne Antwort gilt die Empfehlung (ADR-066).

**1. Budget und endgültiger Look und Klang**
- Frage: Bleibt es für Full Production bei 0 €, und ist „erzeugt und von Hand nachbearbeitet“ damit der endgültige
  Look und Klang? Das wäre eine Abweichung von Bible §36 („handgezeichnete Pixel-Art“) und §61 („keine
  Placeholder-Assets“) und schließt ADR-017 per ADR. Dürfen Instrumentenklänge aus CC0-Sample-Bibliotheken in die
  Musik gerendert werden?
- Am schwächsten wären ohne Geld: Titel- und Schlüsselbild, 5–8 Schlüsselstücke der Musik, Porträts. Preise habe ich
  nicht recherchiert; eine Gegenüberstellung nach Master-Prompt §51 liefere ich, wenn du Geld für einzelne Posten
  erwägst.
- **Empfehlung:** 0 € beibehalten und den Look als „erzeugt und kuratiert“ festschreiben; Samples nur CC0 und erst
  nach einer Hörprobe; die Budgetfrage vor einer Veröffentlichung neu stellen.
- Kosten der falschen Wahl: Später umzusteigen heißt Musik neu rendern und Figuren neu zeichnen; früh Geld
  auszugeben, bevor Akt I steht, kann in Stilen landen, die sich noch ändern.

**2. Länge von Akt I**
- Frage: Rund 100 Minuten wie geplant (Bible: 105), oder kürzer?
- **Empfehlung:** wie geplant bauen und nach deinem Durchlauf (P6.12) entscheiden: Wirkt es zu lang, kürzen wir per
  ADR; fehlt Elysia, kommt das Minispiel A4 dazu.
- Kosten der falschen Wahl: zu kurz: weniger Elysia, auf das Akt VI zurückgreifen kann; zu lang:
  „Spaziergangssimulator“ (§59 Risiko 2).
- **Stand 25.10. (P6.13):** Gebaut ist Akt I mit 333 Zeilen; das Modell gibt rund 14 Minuten (11,5 bis 17,5, Obergrenze 33), geplant waren 105. Die Empfehlung bleibt „wie geplant weiterbauen und nach deinem Durchlauf entscheiden“, jetzt mit den Zahlen aus Abschnitt 10.1.

**3. Wie lang fühlt sich Akt I an?** (nur du kannst es messen)
- Frage: Spiel Akt I einmal (das Spiel schreibt die Beat-Zeiten ins Log, `calibrate.py --akt1 --log <Log>` wertet sie aus) und sag mir die gefühlten Minuten. Erst dann wissen wir, welches Ende der Lücke stimmt (14–18, 30–40 oder 100 Minuten).
- **Empfehlung:** ohne Antwort baue ich Akt II bis VII weiter nach Abschnitt 5, ohne die Länge zu ändern.

**4. Gilt die Länge (10–12 Stunden) oder die Menge (§48)?**
- Frage: Ist die Spielzeit der Bible ein Ziel, das bleibt (dann tragen Spiel und Erkunden den Großteil der Minuten), oder gelten die Mengen aus §48 als Umfang und die Länge ist das, was herauskommt (Abweichung von der Bible, ADR und deine Antwort)?
- **Empfehlung:** vorerst die Länge als Ziel und die Mengen als Umfang beibehalten; ich lege keine Abweichung fest, bevor dein Durchlauf da ist.

**5. Mehr Elysia?** A4 (Minispiel, 5 Minuten) oder mehr Erkunden (T6). **Empfehlung:** erst nach deinem Durchlauf; A4 bleibt Cut-First-Platz 1.

**6. Nachspiel:** Wie lang soll es sein? Es gibt keine Zahl in Bible und Plan. **Empfehlung:** kompakt, rund 10 Minuten, wenn es so weit ist.

**7. Akt II: Voreinstellungen** (Stand 25.10., ADR-067; Tabelle O1 bis O9 im Brief `docs/akt2/REGIONSBRIEFE.md`)
- Frage: Neun Weichen sind mit Voreinstellung entschieden und bleiben umkehrbar: O1 das Ende des Slice bleibt der Schluss von Akt II; O2 der Richter nur als Text ab dem zweiten Sturz; O3 Werte als konkrete Wahlen am Feuer; O4 eine Karte der Klasse M; O5 das Lied im Haus ist hörbar und kein Fragment (und von den 24 Fragmenten sind sechs Bilder des Kindes, 18 Spuren der Welt, siehe 5.5); O6 die neue Karte liegt südlich am Bach; O7 dein „OK“ auf die Lesefassung des Slice als Einfrieren; O8 Blatt und Feder bleiben in Elysia; O9 die Fragen 3 bis 6 gelten weiter (nach Abschnitt 5 bauen, keine Länge ändern).
- **Empfehlung:** die Voreinstellungen; sag, welche du anders willst.

## 12. Risiken

| Risiko | Wirkung | Gegenmaßnahme |
|---|---|---|
| Prüfschleife wächst mit dem Inhalt | bei siebenfachem Inhalt grob eine Stunde je Prüfung [S] | P6.1 erledigt: 3 Min bei 691 Tests (ADR-051) |
| Alle Minutenzahlen sind Schätzungen | Spielzeit von Slice und Akt I nur gerechnet (Slice 20,7, Akt I 14 Minuten gegen 45–60 und 105 geplant) | Messmarken, Kalibrierung (`--akt1`), dein Durchlauf; Abschnitt 10.1 |
| Ohne Tester | Ton, Humor, Miras Stimme und Verständlichkeit prüft nur, wer sie geschrieben hat | Stimmenblätter, Prüflinsen, Lesefassung; externe Tests vor dem Release (§61) |
| Claude hört nicht | Lautheit gemessen, Schönheit nie gehört | Hörproben für dich, Themenbuch |
| Wächter-Maschine, Meer und Boot | nichts davon ist vorhanden | Prototypen vor Akt V und VII; notfalls stilisieren |
| Zustandsmodell fehlt | späte Migration teuer | Konventionen in P6.6, Schema 3 einmal |
| Repo- und Build-Größe | WAV wächst linear; gebackene Böden je Änderung neu | OGG (P6.7), Bakes erst beim Einfrieren committen |
| Hardware | Windows, Controller (KNOWN_ISSUES #76), PlayStation-Beschriftung und Rumble ungeprüft | akzeptiert (ADR-049); vor einer Veröffentlichung neu bewerten |
| Rechtliches | Herkunft erzeugter Assets und Spielelizenz offen | vor einer kommerziellen Veröffentlichung klären |
| Aufwand höher als gedacht | Akt I brauchte sieben Segment-Pull-Requests und drei weitere, zusammen zehn (unter der Schwelle von 15); die Akte II bis VII schätzt Abschnitt 10.1 auf 55 bis 98 plus Vorarbeit | je Akt Brief mit Zeilenbudget; liegt ein Akt klar über seinem Budget, gilt Cut-First |

**Cut-First** (§62) aus dem, was wirklich geplant ist, mit Ersparnis [S]:

| Platz | Streichung | Spart | Bricht |
|---|---|---|---|
| 1 | A4 Minispiel | 5 Min Spielzeit, 1–2 PRs | nichts |
| 2 | Kuriositäten von 36 auf 30 | 6 Bilder, 6 Texte | nichts |
| 3 | Nebenquests von 17 auf 15 | 2 PRs | nichts (Bible: 15–20) |
| 4 | Zusätze des Erscheinungsbilds (Hüte, Narben) | 1 PR | nichts; die Startwahl bleibt |
| 5 | dritter UI-Skin „persönlich“ | 1–2 PRs | schwächt das Ende des UI-Bogens (§34), braucht ADR |
| 6 | Porträts (nur wenn der Pilot sie einführt) | M–L | nichts |

Nie zuerst streichen (§62): Mira, der Kontrast zu Elysia, das Haus, die Kernbegegnungen der Beschützer, die
Verwandlung der Musik, der Humorbogen samt Nachspiel, der Samen, die Rückkehr nach Elysia, das Meer-Finale.
