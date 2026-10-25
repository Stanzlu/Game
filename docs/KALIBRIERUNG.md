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
(`check.sh` spielt ihn bei jedem Lauf). Das Log gibt den Weg: 139 Sekunden Spielzeit, davon 55 mit offenem Gespräch,
106 geklickte Zeilen und 4.800 Pixel Luftlinie, die der Autopilot springt statt geht (zu 84 Pixeln je Sekunde zurückgerechnet).
Akt I hat 333 Zeilen (Segmente und Garten).

| Tempo | Akt I |
|---|---|
| langsam | 15,9 min |
| normal | 12,3 min |
| schnell | 9,9 min |
| Obergrenze (alles gesehen, langsam, Pause 2 s, Umweg ×2,5) | 30,6 min |

`python3 tools/writing/calibrate.py --akt1` zeigt die Tabelle, `--record-akt1 <Log>` schreibt `calibration_akt1.json` neu
(nach einem neuen Segment den Lauf wiederholen). Dazu drei Befunde:

- **Der Plan rechnet mit 100 Minuten für Akt I, das Modell mit 12 bis 31.** Die Briefe summieren rund 42 Minuten, aber ihre Wege
  (6 bis 9 Minuten je Segment) sind geschätzt, nicht gemessen. Die Lücke zu 100 Minuten ist größer als jede Annahme des Modells; es
  ersetzt keinen Playtest (Bible §61). Dein Durchlauf (P6.12) legt Anteil, Pause und Umweg fest und entscheidet, ob Akt I mehr Inhalt
  braucht (A4, Erkunden) oder kürzer bleibt.
- **Der Autopilot sieht 32 % der Zeilen.** Er nimmt in jedem Gespräch die erste Antwort und sucht nichts Freiwilliges; das Modell nimmt 60 %.
- **Die Textdichte liegt bei 27 Zeilen je Minute** (Plan 9.6: 6). Wie beim Slice trägt der Text allein keine 100 Minuten.

## Benutzen

```
python3 tools/writing/calibrate.py                                   den Slice bei jedem Tempo
python3 tools/writing/calibrate.py --akt1                            Akt I bei jedem Tempo (eigener Weg)
python3 tools/writing/calibrate.py --segment WÖRTER ZEILEN WEG_MIN   ein geplantes Segment
python3 tools/writing/calibrate.py --log durchlauf.log               Modell an einen echten Durchlauf anpassen
```

`--segment 1200 150 8` heißt: 1.200 Wörter in 150 Zeilen und 8 Minuten reiner Weg ergeben 15,5 bis 18,1 Minuten.
Jedes Akt-I-Segment nennt in seinem Regions-Brief diese drei Zahlen und vergleicht sie nach dem Bau mit der Messung
des Autopiloten (Beat-Zeiten im Log).

## Dein Durchlauf (nur wenn du magst)

Ein einziger echter Durchlauf des Slice legt Anteil, Pause und Umweg fest. Dafür genügt das Log (`Beat.mark`
schreibt die Spielminute jedes Beats): `python3 tools/writing/calibrate.py --log <Logdatei>` gibt den Umwegfaktor
aus, der das Modell auf deine Zeit bringt, und je Beat dein Tempo gegen das des Autopiloten. Der Faktor kommt dann
in `WANDER`. Ohne Durchlauf bleibt das Modell eine Rechnung mit drei ehrlichen Annahmen; es ersetzt keinen Playtest
(Bible §61).
