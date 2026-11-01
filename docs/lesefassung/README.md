# Lesefassungen

Der Text des Spiels als Drehbuch, in der Reihenfolge, in der das Spiel ihn zeigt, für dich als einzigen Leser (ADR-049, ADR-056).
Jede Datei erzeugt `python3 tools/writing/readable.py TITEL AUS.md [DATEI.dialogue[#cue,cue] ...]` aus den `.dialogue`-Dateien; geändert wird
dort, nie hier. Kursiv ist Erzählung, fett sprechen die Figuren, ▸ sind deine Antworten, eingerückt steht, was nur unter einer Bedingung oder nach einer
Antwort kommt. Hinter jeder Zeile steht ihre ID klein.

**So antwortest du:** je Cue (E3, T12, B3 …) „OK“, „ändern: …“ oder „raus“. Was du nicht nennst, gilt als OK. Nach deinem „OK“ bekommen die Zeilen
`[#ok]` und `id_lock.py --update` sperrt sie (`docs/CONTENT_GUIDE.md`). **Stand:** nichts ist beantwortet, keine Zeile ist `[#ok]`; alles blockiert nichts.

| Datei | Inhalt | Cues | Zeilen mit ID | Wörter (Datei) |
|---|---|---|---|---|
| [SLICE.md](SLICE.md) | der Vertical Slice: Elysia, Tal, Antreiber, Haus (Stand von Akt I; die späteren Zeilen von Akt II stehen unten) | 75 | 379 | 6.087 |
| [A2_GASTHAUS.md](A2_GASTHAUS.md) | Akt I: Das Gasthaus zum Immer | 17 | 55 | 1.244 |
| [A3_MARKT.md](A3_MARKT.md) | Akt I: der Markt und das Fest (A3 und A6) | 16 | 90 | 1.841 |
| [A5_SPIEGELHALLE.md](A5_SPIEGELHALLE.md) | Akt I: die Halle der Spiegel | 9 | 36 | 772 |
| [A8_KIND_SPUR.md](A8_KIND_SPUR.md) | Akt I: die Spur des Kindes | 3 | 12 | 247 |
| [B1_ANKUNFT.md](B1_ANKUNFT.md) | Akt II: die Ankunft im Tal | 1 | 6 | 190 |
| [B2_NEIN.md](B2_NEIN.md) | Akt II: Nein und Blick (Antreiber am Feuer, Miras Fragen, die Funde im Haus) | 7 | 86 | 1.324 |
| [B3_BACHLAUF.md](B3_BACHLAUF.md) | Akt II: der Bachlauf | 13 | 44 | 875 |
| [B4_RICHTER.md](B4_RICHTER.md) | Akt II: die Stimme nach dem zweiten Sturz | 1 | 8 | 164 |
| [B5_FEUER.md](B5_FEUER.md) | Akt II: Feuer, Wahl, Lied und Kräuter im Haus | 6 | 35 | 730 |
| [B6_ABEND.md](B6_ABEND.md) | Akt II: Miras Lesung am Abend | 1 | 13 | 320 |
| [W1_AUFBRUCH.md](W1_AUFBRUCH.md) | Akt III: der Morgen nach dem Ende von Akt II | 1 | 5 | 162 |
| [W2_WALDWEG.md](W2_WALDWEG.md) | Akt III: der Waldweg (Wegzeichen, Rast, Antreiber am leeren Brett, Stufen, Zapfen) | 15 | 56 | 1.441 |
| [W3_HUETTE.md](W3_HUETTE.md) | Akt III: die Hütte des Einsiedlers (Becher, Hocker, Bleiben in drei Stufen, die Flöte, Leine, Pfeife, Kiesel) | 22 | 60 | 1.414 |
| [W4_FLUTLICHTUNG.md](W4_FLUTLICHTUNG.md) | Akt III: die Flutlichtung (Marke, Lager und Spur, der Antreiber an der Marke, das Nest, Treibholz, Trittsteine) | 12 | 46 | 1.772 |
| [W5_NACHTWALD.md](W5_NACHTWALD.md) | Akt III: der Nachtwald (das ferne Licht, ein Leuchtbaum, die Laterne und das Summen, das Leuchtholz, der Heimweg) | 6 | 18 | 919 |
| [W6_HEIMKEHR.md](W6_HEIMKEHR.md) | Akt III: die Heimkehr (die Ankunft am Schraubstock, der Besuch des Einsiedlers, der Schluss, die Werkbank, der Plan, der Antreiber an der Bank, die Katze) | 8 | 32 | 1.567 |
| [S1_STRASSE.md](S1_STRASSE.md) | Akt IV: die Straße (Wegweiser, Spuren der Ziege, Feld, Meilenstein, Aussicht, Seil über der Straße) | 9 | 24 | 845 |

„Zeilen mit ID“ zählt die Zeilen mit einer ID ohne die ▸ Antworten; die Kalibrierung (`calibrate.py`, 475 Zeilen für Akt II) zählt anders.

Akt I hat keine eigenen Dateien für A7 (Wiederholung) und A9 (Anschluss): ihre Zeilen stehen in `A3_MARKT.md`, `A2_GASTHAUS.md` (die Schleifen des Gastwirts) und `SLICE.md`. Akt II hat keine Datei für B7 (keine neuen Zeilen), Akt III keine für W7 (der Durchlauf schreibt nichts).

**Zur Nummerierung.** Die Nummer eines Cues ist seine Stelle in seiner Datei zum Zeitpunkt der Erzeugung (`T9`, `H20`). Weil Akt II Cues in die Dateien des Slice eingefügt hat,
tragen zwei Cues von `tal.dialogue` in verschiedenen Lesefassungen die Nummer T9 (`evening_elysia` in `SLICE.md` und `B2_NEIN.md`, `evening_values` in `B6_ABEND.md`); eine neue Erzeugung zählt `evening_elysia` als T10. Antworte darum mit dem Namen des Cues und der Datei („B6, `evening_values`: OK“), nicht nur mit der Nummer.
