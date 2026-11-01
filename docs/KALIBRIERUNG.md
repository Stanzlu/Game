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

## Benutzen

```
python3 tools/writing/calibrate.py                                   den Slice bei jedem Tempo
python3 tools/writing/calibrate.py --akt1                            Akt I bei jedem Tempo (eigener Weg)
python3 tools/writing/calibrate.py --akt2                            Akt II bei jedem Tempo (eigener Weg)
python3 tools/writing/calibrate.py --akt3                            Akt III bei jedem Tempo (eigener Weg)
python3 tools/writing/calibrate.py --record-akt1 run.log             den Lauf von Akt I als Messung festhalten (--record-akt2, --record-akt3 für Akt II, III)
python3 tools/writing/calibrate.py --segment WÖRTER ZEILEN WEG_MIN   ein geplantes Segment
python3 tools/writing/calibrate.py --log durchlauf.log               Modell an einen echten Durchlauf des Slice anpassen
python3 tools/writing/calibrate.py --akt1 --log durchlauf.log        dasselbe für einen echten Durchlauf von Akt I (--akt2, --akt3 für Akt II, III)
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
