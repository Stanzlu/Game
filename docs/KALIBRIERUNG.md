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

## Benutzen

```
python3 tools/writing/calibrate.py                                   den Slice bei jedem Tempo
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
