# Kalibrierung der Spielzeit (T11)

Wie lang ein Stück Spiel dauert, wird gerechnet und nicht geschätzt: `python3 tools/writing/calibrate.py`
(nur Standardbibliothek, ADR-055). Das Modell hat drei Teile:

| Teil | Quelle | Stand |
|---|---|---|
| **Lesen** | gesehene Zeichen × Sekunden je Zeichen (die Textgeschwindigkeiten aus `core/settings.gd`) plus eine Pause je gesehener Zeile zum Lesen und Weiterdrücken | Annahme: 60 % der Zeilen gesehen (Antworten verzweigen, Bedingungen wählen eine Fassung), 1,2 s Pause |
| **Weg** | die Zeit, die der Autopilot (`slice_full.json`, Text sofort) für Wege, Wartezeiten und Szenen braucht: `calibration_baseline.json`, 372 s, davon 91 s in Elysia | gemessen |
| **Umweg** | Faktor auf den Weg für eine Spielerin, die zum ersten Mal schaut, abbiegt und stehen bleibt | Annahme: 1,6 |

Gemessen sind der Weg und die Textmenge. Angenommen sind Anteil, Pause und Umweg, bis ein echter Durchlauf sie
festlegt (unten).

## Der Slice nach dem Modell

| Tempo | Elysia | Tal usw. | gesamt |
|---|---|---|---|
| langsam | 5,6 | 19,3 | 25,0 min |
| normal | 4,7 | 16,0 | 20,6 min |
| schnell | 4,1 | 13,8 | 17,8 min |

Das deckt sich mit der Schätzung vom Härtungs-Durchgang (20–30 Minuten), liegt aber unter dem Ziel von 45–60 Minuten
des Vertical Slice aus der Bible. Der Slice ist also kürzer als sein Name, wenn man ihn zügig spielt; er trägt
die Zeit, die die Spielerin sich nimmt.

## Was das für Akt I heißt

Der Slice hat **21,5 Zeilen je Minute**. Der Plan (Abschnitt 9.6) rechnet für Akt I mit 6 Zeilen je Minute und
kommt so auf rund 4.100 Zeilen für 11 Stunden. Beides stimmt nur zusammen, wenn Akt I deutlich mehr Spielzeit
aus **Spiel** zieht (Erkunden, Minispiel, Dungeon, Händler) und nicht aus Text:

- 650 Zeilen und 4.900 Wörter mit 20 Minuten Weg ergeben nach dem Modell rund 48 Minuten, nicht 100.
- Für 100 Minuten braucht Akt I bei der Textdichte des Slice entweder rund dreimal so viele Zeilen oder
  rund 50 Minuten Spielzeit, die kein Text trägt.

Die Entscheidung gehört in P6.12 (Akt-I-Durchlauf), wenn die Segmente gebaut sind und gemessen werden können; bis dahin
bleiben „Akt I rund 100 Minuten“ und „6 Zeilen je Minute“ Annahmen [P].

## Akt I nach dem Lauf des Autopiloten (P6.12c, ADR-065)

`tools/autopilot/akt1_full.json` spielt Akt I vom Erwachen bis zur Ankunft im Tal mit echten Türen und echtem Fortschritt
(`check.sh` spielt ihn bei jedem Lauf). Das Log gibt den Weg: 141 Sekunden Spielzeit, davon 55 mit offenem Gespräch,
110 geklickte Zeilen und 10.016 Pixel Luftlinie, die der Autopilot springt statt geht (jeder Sprung, jede Tür, jeder Weg vom Ankunftspunkt;
zu 88 Pixeln je Sekunde, dem Tempo „direkt“, zurückgerechnet).
Akt I hat 333 Zeilen (Segmente und Garten).

| Tempo | Akt I |
|---|---|
| langsam | 17,5 min |
| normal | 13,9 min |
| schnell | 11,5 min |
| Obergrenze (alles gesehen, langsam, Pause 2 s, Umweg ×2,5) | 33,0 min |

`python3 tools/writing/calibrate.py --akt1` zeigt die Tabelle, `--record-akt1 <Log>` schreibt `calibration_akt1.json` neu
(nach einem neuen Segment den Lauf wiederholen). Dazu drei Befunde:

- **Der Plan rechnet mit 100 Minuten für Akt I, das Modell mit 14 bis 33.** Die Briefe summieren rund 42 Minuten, aber ihre Wege
  (2 bis 5 Minuten je Segment, mit dem Lesen 6 bis 9) sind geschätzt, nicht gemessen. Die Lücke zu 100 Minuten ist größer als jede Annahme des Modells; es
  ersetzt keinen Playtest (Bible §61). Dein Durchlauf (P6.12) legt Anteil, Pause und Umweg fest und entscheidet, ob Akt I mehr Inhalt
  braucht (A4, Erkunden) oder kürzer bleibt.
- **Der Autopilot sieht 33 % der Zeilen.** Er nimmt in jedem Gespräch die erste Antwort und sucht nichts Freiwilliges; das Modell nimmt 60 %.
- **Die Textdichte liegt bei 24 Zeilen je Minute** (Plan 9.6: 6). Wie beim Slice trägt der Text allein keine 100 Minuten.

## Akt II nach dem Lauf des Autopiloten (P6.14, B7, ADR-069)

`tools/autopilot/akt2_full.json` spielt Akt II vom Tal nach dem Riss bis zum Ende des Abends: Ankunft, Miras Nein, zwei Stürze und die Stimme,
das Westufer, das kalte Haus, der Schuppenweg mit Antreiber und Holz, Feuer, Ausruhen, Lied, Antreiber, Mira, die Wahl am Feuer, die Kräuter,
der Bachlauf, die Ziege und das Ende mit den Kapitelmarken `act2` und `slice`. Er setzt kein Flag und gibt keinen Gegenstand;
er beginnt dort, wo `akt1_full.json` endet, nämlich im eingefrorenen Stand `tests/fixtures/saves/v2_akt1_end.json` (`check.sh`:
eine Szene mit `@` vor dem Namen kopiert den Stand als Autosave des Probeprofils und startet mit `--continue`). Der Stand trägt 139 Sekunden Spielzeit, die
`--record-akt2` abzieht. `check.sh` spielt den Lauf bei jedem Durchgang (rund 9 Sekunden) und verlangt 62 Marken (22 Beats, 40 Flags).

Das Log gibt den Weg: **240 Sekunden** Spielzeit, davon 97 mit offenem Gespräch, 197 geklickte Zeilen (**41 %** der 475 Zeilen von Akt II; die Zeilen von
`tal`, `haus` und `antreiber` aus dem Slice zählen dazu: die Segmente erweitern `tal` und `haus`, und der Lauf spielt auch die Begegnung mit dem Antreiber) und 9.915 Pixel Luftlinie, die der Autopilot springt statt geht.
Der Weg ohne Lesen ist damit 143 Sekunden plus 113 für die Sprünge, **4,3 Minuten**. Die Sekunden schwanken um bis zu vier, weil der Böen-Auftakt der Ankunft (`ECHO_GUST_SECONDS`) zufällig ist.

| Tempo | Akt II |
|---|---|
| langsam | 23,0 min |
| normal | 18,3 min |
| schnell | 15,3 min |
| Obergrenze (alles gesehen, langsam, Pause 2 s, Umweg ×2,5) | 43,9 min |

`python3 tools/writing/calibrate.py --akt2` zeigt die Tabelle, `--record-akt2 <Log>` schreibt `calibration_akt2.json` neu (nach einem neuen Segment den Lauf wiederholen),
`--akt2 --log <Log>` passt das Modell an einen echten Durchlauf an (gezählt ab dem Beat `valley_arrival`). Dazu vier Befunde:

- **Der Plan rechnet mit 90 Minuten für Akt II, das Modell mit 15 bis 23.** Die laufende Summe der Briefe (rund 28 Minuten) rechnete die Wege der sechs gebauten Segmente mit 5,2 Minuten (8,3 mit dem Umweg ×1,6 des Modells) zu den 281 Sekunden Weg des Slice-Laufs, zusammen 9,9 Minuten ohne Umweg,
  und die 354 vorhandenen Zeilen mit 16 Minuten aus dem Slice-Lauf; der gemessene Weg von Akt II ist 4,3 Minuten ohne Umweg (6,9 mit). Gemessen ist kleiner als geschätzt. Die Lücke zu 90 Minuten ist
  wie bei Akt I größer als jede Annahme des Modells (der äußerste Eckfall, Obergrenze, gibt 44); dein Durchlauf legt Anteil, Pause und Umweg fest.
- **Der Autopilot sieht 41 % der Zeilen** (Akt I: 33 %). Er nimmt in jedem Gespräch die erste Antwort; die Zweige der Wahl am Feuer, Miras vier Lesungen,
  Antreiber-Antworten, Fragen nach Elysia, „Zum Meer?“ und die zweite Fensterzeile im Haus bleiben dem Lauf unbekannt und stehen unter GUT-Tests.
- **Die Textdichte liegt bei 25,9 Zeilen je Minute** (Akt I: 24,0; Plan 9.6: 6). Auch Akt II trägt seine Länge nicht aus Text.
- **Der Slice-Wert (`calibrate.py` ohne Schalter) zählt seit Akt II die 38 Zeilen von Akt II in den Slice-Dateien mit:** 484 statt 446 Zeilen, 21,7 statt 20,7 Minuten bei normalem Tempo. Die Tabelle
  „Der Slice nach dem Modell“ oben bleibt der Stand von P6.6; die Akt-Werte zählen jede Zeile genau einmal (ein Test prüft, dass keine Story-Datei zu keinem Akt gehört).

## Akt III nach dem Lauf des Autopiloten (P6.15, W7, ADR-070)

`tools/autopilot/akt3_full.json` spielt Akt III vom Morgen nach dem Ende von Akt II bis zum Ende des Weges nach Hause: der Morgen im Tal, der Bachlauf, der Waldweg
(die Wegzeichen, die Rasten, der Zapfen, die Stufen im Hohlweg, das leere Brett), die Hütte (Tee, Kiesel, Leine, Hocker, Flöte, das Bleiben in drei Stufen), die
Flutlichtung (Marke, Lager, Nest, Treibholz, Trittsteine), der Nachtwald (das ferne Licht, ein Leuchtbaum, das Leuchtholz, die Laterne und das Summen) und die Heimkehr
(das Tal, das Haus mit der Werkbank, der Besuch des Einsiedlers, das stille Ende mit der Kapitelmarke `act3`). Er setzt kein Flag und gibt keinen Gegenstand (die Quest
läuft von selbst durch ihre Stufen: der Morgen beginnt sie, die Türen, die Marke und die Hütte schalten sie weiter); er beginnt im eingefrorenen Stand
`tests/fixtures/saves/v2_akt2_end.json` (der Antreiber sitzt dort am Feuer: seine Plätze im Wald bleiben leer, die Segmentskripte spielen sie von einem frischen Profil)
und endet im Haus, nach dem Ende des Aktes. `check.sh` spielt den Lauf bei jedem Durchgang (rund 8 Sekunden) und verlangt 38 Marken (11 Beats, 27 Flags).

Das Log gibt den Weg: **130 Sekunden** Spielzeit (der Stand trägt 374 davon schon), 62 mit offenem Gespräch, 120 geklickte Zeilen (**44 %** der 272 Zeilen von Akt III, wie
`calibrate.py` zählt: auch Zweige, die der Lauf nicht nimmt) und 7.143 Pixel Luftlinie, die der Autopilot springt statt geht. Der Weg ohne Lesen ist damit 68 Sekunden plus 81 für die Sprünge,
**2,5 Minuten**.

| Tempo | Akt III |
|---|---|
| langsam | 14,3 min |
| normal | 11,2 min |
| schnell | 9,1 min |
| Obergrenze (alles gesehen, langsam, Pause 2 s, Umweg ×2,5) | 27,0 min |

`python3 tools/writing/calibrate.py --akt3` zeigt die Tabelle, `--record-akt3 <Log>` schreibt `calibration_akt3.json` neu (nach einem neuen Segment den Lauf wiederholen),
`--akt3 --log <Log>` passt das Modell an einen echten Durchlauf an (gezählt ab dem Beat `act3_morning`). Dazu vier Befunde:

- **Der Plan rechnet mit 90 Minuten für Akt III, das Modell mit 9 bis 14.** Der Weg ist mit 2,5 Minuten kürzer als der von Akt II (4,3): die Karten sind groß, aber
  der Autopilot springt von Ding zu Ding, und das Gehen eines Menschen ist der Umweg (×1,6), den das Modell erst im Schätzen zugibt. Die Lücke zu 90 Minuten ist wie bei den Akten davor größer als jede Annahme des Modells
  (der äußerste Eckfall gibt 27); dein Durchlauf legt Anteil, Pause und Umweg fest.
- **Der Autopilot sieht 44 % der Zeilen** (Akt I: 33 %, Akt II: 41 %). Er nimmt in jedem Gespräch die erste Antwort; was der Lauf nicht sieht, steht unter GUT-Tests: der Antreiber an den Brettern und an der Marke
  (er sitzt im Stand am Feuer und fehlt im Wald), seine Tee-Antworten, die Zweige ohne `care`, der Besuch ohne Einladung, die Katze mit und ohne Namen.
- **Die Textdichte liegt bei 24,4 Zeilen je Minute** (Akt I: 24,0; Akt II: 25,9; Plan 9.6: 6). Auch Akt III trägt seine Länge nicht aus Text: wer das Bleiben in der Hütte, das Sitzen an der Laterne und das Warten
  nicht abkürzt, braucht länger als der Autopilot, der nichts davon tut als klicken.
- **Der Lauf ist der eingefrorene Stand `v2_akt3_end.json`:** sein letzter Autosave, im Haus nach dem Ende (`chapter.act3`, Quest `done`, Facette `care`, 180 Flags, zehn Gegenstände). Der Stand wird nie von Hand
  geändert; `test_save_policy` prüft, dass er ohne Reparatur lädt und seine Geschichte erzählt, `test_save_system`, dass das Menü ihn als Ende zählt, und Akt IV beginnt in ihm.

## Akt IV nach dem Lauf des Autopiloten (P6.16, S9, ADR-071)

`tools/autopilot/akt4_full.json` spielt Akt IV vom eingefrorenen Ende von Akt III (still im Haus) bis zum Ende des Weges nach Hause: die Straße (Wegweiser, Hufabdrücke, Glöckchen,
Meilenstein, die Aussicht), der Platz und das Rathaus (das Tor, Mira am Brunnen, das Zettelbrett, Lio, das Fundbüro, „Ein perfekter Tag“), der Blumenladen (Orin, die Ente, der Brief),
die Werkstatt (Tess, das Brett, „Hilfe erbitten“) und die Bank („Nichts“), die Liste des Gefälligen (drei Aufgaben, das Nein, das Brot, die Küche) mit den Gängen, das Konzert, der Richter und der
Streit am Tor, der Morgen auf der Straße und die Heimkehr (Tess, die Regale, das Brot, der Stuhl, das stille Ende mit der Kapitelmarke `act4`, ein Gegenstand auf einem Regalbrett).
Er setzt kein Flag und gibt keinen Gegenstand; er nimmt in jedem Gespräch die erste Antwort (bei Mira am Tor ist das die Grenze) und beginnt in `tests/fixtures/saves/v2_akt3_end.json`.
`check.sh` spielt den Lauf bei jedem Durchgang (rund 9 Sekunden) und verlangt 63 Marken (18 Beats, 45 Flags).

Das Log gibt den Weg: **264 Sekunden** Spielzeit (der Stand trägt 503 davon schon), 134 mit offenem Gespräch, 279 geklickte Zeilen (**58 %** der 479 Zeilen von Akt IV, wie
`calibrate.py` zählt: auch Zweige, die der Lauf nicht nimmt) und 14.861 Pixel Luftlinie, die der Autopilot springt statt geht. Der Weg ohne Lesen ist damit 130 Sekunden plus 169 für die Sprünge,
**5,0 Minuten**.

| Tempo | Akt IV |
|---|---|
| langsam | 29,2 min |
| normal | 22,3 min |
| schnell | 17,8 min |
| Obergrenze (alles gesehen, langsam, Pause 2 s, Umweg ×2,5) | 54,2 min |

`python3 tools/writing/calibrate.py --akt4` zeigt die Tabelle, `--record-akt4 <Log>` schreibt `calibration_akt4.json` neu (nach einem neuen Segment den Lauf wiederholen),
`--akt4 --log <Log>` passt das Modell an einen echten Durchlauf an (gezählt ab dem Beat `strasse_enter`). Dazu vier Befunde:

- **Der Plan rechnet mit 120 Minuten für Akt IV, das Modell mit 18 bis 29.** Der Akt hat den längsten Weg bisher (5,0 Minuten gegen 3,3 in Akt I, 4,3 in Akt II und 2,5 in Akt III) und die meiste Schrift
  (479 Zeilen gegen 272 in Akt III); die Lücke zu den 120 Minuten ist mit rund 5-fach so klein wie bei Akt II (Akt I rund 7-fach, Akt III rund 8-fach).
  Der äußerste Eckfall gibt 54; dein Durchlauf legt Anteil, Pause und Umweg fest.
- **Der Autopilot sieht 58 % der Zeilen** (Akt I: 33 %, Akt II: 41 %, Akt III: 44 %). Er nimmt in jedem Gespräch die erste Antwort; was der Lauf nicht sieht, steht unter GUT-Tests: die zwei anderen
  Ausgänge des Streits (anschließen, schweigen), die Aufgaben der Liste, die er nicht nimmt, ihre Folgen, die Antworten der Facetten `connection` und `integrity`, die Töpfe der Ente, das Konzert ohne Tess
  und ohne Orin, die Heimkehr ohne vorherige Begegnung mit Tess.
- **Die Textdichte liegt bei 21,5 Zeilen je Minute** (Akt I: 24,0; Akt II: 25,9; Akt III: 24,4; Plan 9.6: 6): die Stadt hat mehr Weg je Zeile als die Akte davor (5,0 Minuten für 479 Zeilen, in Akt III 2,5 für 272). Auch Akt IV trägt seine Länge nicht aus Text: wer die Bank, die Regale und den Abend nicht abkürzt, braucht länger als der Autopilot.
- **Der Lauf ist der eingefrorene Stand `v2_akt4_end.json`:** sein letzter Autosave, im Haus nach dem Ende (`chapter.act4`, Quest `done`, die fünf Facetten, 245 Flags, 21 Gegenstände, vier Beziehungen: Tess `close`,
  Mira, Orin und Lio `familiar`). Der Stand wird nie von Hand geändert; `test_save_policy` prüft, dass er ohne Reparatur lädt und seine Geschichte erzählt, `test_save_system`, dass das Menü ihn seit Akt V, G1, nicht mehr
  als Ende zählt (das letzte Kapitel des Baus ist `act5`), und Akt V beginnt in ihm.

## Akt V nach dem Lauf des Autopiloten (P6.17, G10, ADR-073)

`tools/autopilot/akt5_full.json` spielt Akt V vom eingefrorenen Ende von Akt IV (still im Haus) bis zum stillen Ende im Haus: den Aufstieg durch den Pass (die Steinmännchen, der Eisenring, die
Aussicht, der Schiefer), das Hochtal (der Stein und seine drei Steinmännchen, die Hand, der Murmeltierbau, der Kristall), die Anlage (das Klopfen am Tor, die Halle, die Probe der drei Hebel, das
Zifferblatt), die Last in vier Wellen, das Loslassen (Wegtreten, die Hebel fallen, die Lampe, die Kartoffel), den Grat (der Wegweiser, die Spalte mit dem Verstecken, die Kerze, der Rand), das Kind, das
ursprüngliche Haus auf der Fläche (das Buch, die sechs Ringe, die Kreide, das Bett mit der dritten Rückblende) und den Weg hinunter ins Haus (der Pass, das Beet, die Heimkehr mit dem Wächter am Kamin und
dem stillen Ende mit der Kapitelmarke `act5`). **Der Lauf setzt nichts voraus:** kein Flag, keine Facette und keine Quest-Stufe wird gesetzt, alles kommt aus dem Spiel (der Wächter wird am Pult losgelassen,
darum kommt er am Ende an den Kamin). Er nimmt in jedem Gespräch die erste Antwort und beginnt in `tests/fixtures/saves/v2_akt4_end.json`. `check.sh` spielt den Lauf bei jedem Durchgang (rund 11 Sekunden)
und verlangt 49 Marken.

Das Log gibt den Weg: **424 Sekunden** Spielzeit (der Stand trägt 765 davon schon), 127 mit offenem Gespräch, 256 geklickte Zeilen (**68 %** der 378 Zeilen von Akt V, wie `calibrate.py` zählt: auch
Zweige, die der Lauf nicht nimmt) und 14.863 Pixel Luftlinie, die der Autopilot springt statt geht. Der Weg ohne Lesen ist damit 297 Sekunden plus 169 für die Sprünge, **7,8 Minuten**.

| Tempo | Akt V |
|---|---|
| langsam | 29,1 min |
| normal | 23,7 min |
| schnell | 20,2 min |
| Obergrenze (alles gesehen, langsam, Pause 2 s, Umweg ×2,5) | 52,2 min |

`python3 tools/writing/calibrate.py --akt5` zeigt die Tabelle, `--record-akt5 <Log>` schreibt `calibration_akt5.json` neu (nach einem neuen Segment den Lauf wiederholen), `--akt5 --log <Log>`
passt das Modell an einen echten Durchlauf an (gezählt ab dem Beat `pass_enter`). Dazu vier Befunde:

- **Der Plan rechnet mit 90 Minuten für Akt V, das Modell mit 20 bis 29.** Der Akt hat den längsten Weg bisher (7,8 Minuten gegen 5,0 in Akt IV) bei weniger Schrift (378 Zeilen gegen 479);
  die Lücke zu den 90 Minuten ist mit rund 4-fach die kleinste bisher (Akt IV rund 5-fach, Akt II rund 5-fach, Akt I rund 7-fach, Akt III rund 8-fach). Der äußerste Eckfall gibt 52; dein Durchlauf
  legt Anteil, Pause und Umweg fest.
- **Der Autopilot sieht 68 % der Zeilen** (Akt IV: 58 %): er hat in diesem Akt kaum Zweige, die Gespräche sind kurz und gehen meist geradeaus. Was der Lauf nicht sieht, steht unter GUT-Tests: die
  Antworten der Facetten (`trust` beim Kind, `courage` am Fenster), die Wege ohne das Haus auf der Fläche, die Heimkehr ohne den Wächter, die anderen Antworten des Kindes, der Eintrag im Buch, die
  Kartoffel beim Wächter, die Wellen der Last bei jeder Einstellung von „Mehr Zeit“ und „Begegnungstempo“.
- **Die Textdichte liegt bei 16,0 Zeilen je Minute** (Akt IV: 21,5; Plan 9.6: 6): Akt V ist der Akt mit dem meisten Weg und Warten je Zeile. Das Loslassen allein (25,6 Sekunden Stehen) und die vier
  Wellen der Last (rund 40 Sekunden Zug und Frist) tragen Zeit ohne eine Zeile; ein Spieler, der sich nicht abkürzt, braucht dort länger als der Autopilot, der jedes Warten genau so lang wartet,
  wie das Spiel verlangt.
- **Der Lauf ist der eingefrorene Stand `v2_akt5_end.json`:** sein letzter Autosave, im Haus nach dem Ende (`chapter.act5`, Quest `done` mit zehn Stufen, die sieben Facetten, 295 Flags, vier
  Beziehungen: Tess `close`, Mira, Orin und Lio `familiar`, der Wächter am Kamin). Der Stand wird nie von Hand geändert; `test_save_policy` prüft, dass er ohne Reparatur lädt und seine Geschichte
  erzählt, `test_save_system`, dass er als Ende des Spiels zählt (`Chapter.LAST` ist `act5`: das Menü zeigt „fertig“, „Neues Spiel“ fragt zurück). Bis Akt VI (R1) endete in ihm dieser Bau; Akt VI beginnt in ihm.

## Akt VI nach dem Lauf des Autopiloten (P6.18, R9, ADR-074)

`tools/autopilot/akt6_full.json` spielt Akt VI vom eingefrorenen Ende von Akt V (still im Haus) bis zum stillen Ende im Haus: den Tag danach (die wenigen Zeilen von Dingen, Miras Abschied am alten Lager,
das Haus mit dem Licht, das nicht von hier ist), den Spalt im Tal und den Schritt zurück nach Elysia, den Garten (das Kompliment der Gärtnerin, das Becken, die Elysianer, die vorausbieten), den Markt
(Dichter, Festmeisterin, Torwächter), die Spiegelhalle mit der Stimme des Richters (der erste Satz, den die Spielerin im Gehen abbricht, und der eine leise beim nächsten Besuch), das Gasthaus (der Wirt, der Kamin, der Tisch mit den drei Angeboten und das
Aufstehen mit der Suppe), den Riss am Rand des Bildes, der nichts fragt, und den Weg nach Hause (der Wirt klopft und setzt sich ans Feuer, Elysias Lied, das stille Ende mit der Kapitelmarke `act6`).
**Der Lauf setzt nichts voraus:** kein Flag, kein Gegenstand, keine Facette und keine Quest-Stufe wird gesetzt, alles kommt aus dem Spiel (das Licht im Tal aus dem Haus, die Suppe vom Wirt, die Facette
`aliveness` aus dem Wasser des Beckens, `elysia.stood_up` aus dem Aufstehen vom Tisch, darum klopft der Wirt am Ende). Er nimmt in jedem Gespräch die erste Antwort und beginnt in
`tests/fixtures/saves/v2_akt5_end.json`. `check.sh` spielt den Lauf bei jedem Durchgang (rund 8 Sekunden) und verlangt 25 Marken.

Das Log gibt den Weg: **174 Sekunden** Spielzeit (der Stand trägt 1.187 davon schon), 67 mit offenem Gespräch, 135 geklickte Zeilen (**58 %** der 232 Zeilen von Akt VI zur Zeit von R9, wie `calibrate.py` zählt: auch
Zweige, die der Lauf nicht nimmt, und die Antworten) und 8.524 Pixel Luftlinie, die der Autopilot springt statt geht. Der Weg ohne Lesen ist damit 107 Sekunden plus 97 für die Sprünge, **3,4 Minuten**.

| Tempo | Akt VI |
|---|---|
| langsam | 16,3 min |
| normal | 12,8 min |
| schnell | 10,6 min |
| Obergrenze (alles gesehen, langsam, Pause 2 s, Umweg ×2,5) | 30,0 min |

(Stand R9: 232 Zeilen, 15,3 / 12,1 / 10,1 / 28,0 Minuten. Seit R10 zählt das Modell die 23 Zeilen der Sammelstücke mit (255 Zeilen); der Lauf `akt6_full.json` spielt sie nicht, darum bleiben Weg und Messung des Laufs unverändert, und nur die Spalte der Zeilen wächst. Der Autopilot sah 135 von 255 Zeilen, **53 %**; die Dichte liegt bei 19,9 Zeilen je Minute.)

`python3 tools/writing/calibrate.py --akt6` zeigt die Tabelle, `--record-akt6 <Log>` schreibt `calibration_akt6.json` neu (nach einem neuen Segment den Lauf wiederholen), `--akt6 --log <Log>`
passt das Modell an einen echten Durchlauf an (gezählt ab dem Beat `act6_morning`). Dazu vier Befunde:

- **Der Plan rechnet mit 75 Minuten für Akt VI, das Modell mit 10 bis 15.** Akt VI hat die wenigsten Zeilen (255 mit den Sammelstücken von R10, Akt III: 272) und nach Akt III das kürzeste Modell (keine neue Karte, ein Weg von 3,4 Minuten
  gegen 7,8 in Akt V; kürzer sind nur der Weg von Akt III mit 2,5 und der von Akt I mit 3,3 Minuten). Die Lücke zu den 75 Minuten ist mit rund 6-fach die mittlere (Akt V rund 4-fach, Akt IV und II rund 5-fach, Akt I rund 7-fach, Akt III rund 8-fach). Der äußerste Eckfall gibt 28;
  dein Durchlauf legt Anteil, Pause und Umweg fest. Dass Akt VI leicht ist, gehört zum Bogen (Bible §45: die Rückkehr ist die Erholung, nicht der Höhepunkt); die Minuten, die der Plan darüber hinaus
  nennt, sind Warten und Bleiben, die das Spiel nicht zählt (das Sitzen am Tisch ist unbegrenzt, `stay_calm`).
- **Der Autopilot sieht 58 % der Zeilen** (Akt V: 68 %): die Gärtnerin, der Wirt und der Dichter haben Antworten und Zustände, die der Lauf nicht nimmt (das Annehmen und das Ablehnen des Kompliments, das
  Tanzen, das Schweigen, die Antworten der Facetten). Was der Lauf nicht sieht, steht unter den GUT-Tests der Segmente (`DialogueWalk`, `BoxAnswers.pick`): die anderen Antworten
  der Gärtnerin und des Wirts, das Ablehnen des Kompliments, die Heimkehr ohne den Wirt, der Ausgang ohne Aufstehen.
- **Die Textdichte liegt bei 19,1 Zeilen je Minute** (Akt V: 16,0; Akt IV: 21,5; Plan 9.6: 6): Die Dichte liegt unter den Akten I bis IV (21,5 bis 25,9) und über Akt V: Akt VI hat wenig Weg, aber auch Zeit ohne Zeile. Sie tragen
  die Heimkehr (der Wirt kommt und setzt sich, Elysias Lied von gut zehn Sekunden) und das Sitzen am Tisch, das der Lauf nach drei Angeboten beendet und ein Spieler nicht muss.
- **Der Lauf ist der eingefrorene Stand `v2_akt6_end.json`:** sein letzter Autosave, im Haus nach dem Ende (`chapter.act6`, Quest `done` mit acht Stufen, die acht Facetten, 321 Flags, vier
  Beziehungen: Tess `close`, Mira, Orin und Lio `familiar`, der Wirt am Kamin, die Suppe in der Tasche). Der Stand wird nie von Hand geändert; `test_save_policy` prüft, dass er ohne Reparatur lädt
  und seine Geschichte erzählt, `test_save_system`, dass er als Ende des Spiels zählt (`Chapter.LAST` ist `act6`: das Menü zeigt „fertig“, „Neues Spiel“ fragt zurück). In ihm endet dieser Bau;
  Akt VII beginnt, wenn er gebaut wird, in ihm.

## Benutzen

```
python3 tools/writing/calibrate.py                                   den Slice bei jedem Tempo
python3 tools/writing/calibrate.py --akt1                            Akt I bei jedem Tempo (eigener Weg)
python3 tools/writing/calibrate.py --akt2                            Akt II bei jedem Tempo (eigener Weg)
python3 tools/writing/calibrate.py --akt3                            Akt III bei jedem Tempo (eigener Weg)
python3 tools/writing/calibrate.py --akt4                            Akt IV bei jedem Tempo (eigener Weg)
python3 tools/writing/calibrate.py --akt5                            Akt V bei jedem Tempo (eigener Weg)
python3 tools/writing/calibrate.py --akt6                            Akt VI bei jedem Tempo (eigener Weg)
python3 tools/writing/calibrate.py --record-akt1 run.log             den Lauf von Akt I als Messung festhalten (--record-akt2 bis --record-akt6 für Akt II bis VI)
python3 tools/writing/calibrate.py --segment WÖRTER ZEILEN WEG_MIN   ein geplantes Segment
python3 tools/writing/calibrate.py --log durchlauf.log               Modell an einen echten Durchlauf des Slice anpassen
python3 tools/writing/calibrate.py --akt1 --log durchlauf.log        dasselbe für einen echten Durchlauf von Akt I (--akt2 bis --akt6 für Akt II bis VI)
```

`--segment 1200 150 8` heißt: 1.200 Wörter in 150 Zeilen und 8 Minuten reiner Weg ergeben 15,5 bis 18,1 Minuten.
Jedes Segment nennt in seinem Regions-Brief diese drei Zahlen und vergleicht sie nach dem Bau mit der Messung
des Autopiloten (Beat-Zeiten im Log).

## Dein Durchlauf (nur wenn du magst)

Ein einziger echter Durchlauf des Slice legt Anteil, Pause und Umweg fest. Dafür genügt das Log (`Beat.mark`
schreibt die Spielminute jedes Beats): `python3 tools/writing/calibrate.py --log <Logdatei>` gibt den Umwegfaktor
aus, der das Modell auf deine Zeit bringt, und je Beat dein Tempo gegen das des Autopiloten. Der Faktor kommt dann
in `WANDER`. Ohne Durchlauf bleibt das Modell eine Rechnung mit drei ehrlichen Annahmen; es ersetzt keinen Playtest
(Bible §61).
