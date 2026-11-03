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
| [S1_STRASSE.md](S1_STRASSE.md) | Akt IV: die Straße (Wegweiser, Spuren der Ziege, Feld, Meilenstein, Aussicht; das Seil am Westende ist seit S2 die Tür in die Stadt) | 8 | 22 | 796 |
| [S2_PLATZ.md](S2_PLATZ.md) | Akt IV: der Platz und das Rathaus (Tor und Torwächterin, Mira am Brunnen, Zettelbrett und Gefälliger, Lio, Brunnenrand, die drei Stationen von „Ein perfekter Tag“, die Ziege; Fundbüro und Plan der Beamtin; `lio_street` und `lio_again` springen seit S6 am Ende zur Einladung) | 26 | 76 | 2.395 |
| [S3_BLUMENLADEN.md](S3_BLUMENLADEN.md) | Akt IV: der Blumenladen (Orin hinter dem Bindetisch, die Bitte und die Ente vor der Tür, der Bericht und die Töpfe, der Brief und der Strauß, danach; Bindetisch, Regal, getrockneter Strauß) | 16 | 63 | 1.922 |
| [S4_WERKSTATT.md](S4_WERKSTATT.md) | Akt IV: die Werkstatt (Tess am Zollstock, das Angebot und das Sägen, das fertige Brett, Hobel und Leiter; draußen die Bank, „Nichts“ und die Zeile danach; Sägen, Leiter, Sägemehl, Brett) | 15 | 56 | 1.714 |
| [S5_LISTE.md](S5_LISTE.md) | Akt IV: die Liste (Mira am Rand, das Brett nach der Liste, der Gefällige mit siebzehn, achtzehn und neunzehn, die Wahl der Aufgaben, das Nein, das Brot, seine Küche und der verblasste Zettel; die Gänge der sechs Aufgaben und der durchgestrichene Zettel; `list_board` und `gef_again` stehen als geänderte Cues auch in S2) | 22 | 72 | 2.833 |
| [S6_KONZERT.md](S6_KONZERT.md) | Akt IV: das Konzert (Lios schlechtestes Konzert der Welt: Platz am Abend, Ankündigung, die Saite, die Lampe mit der Wahl, die Ziege und der Einsatz, der Wind, das Lied und die Menge, das stille Ende; danach Lio mit der Saite, Ziege, Orin, Gefälliger, Mira, das alte Brett, das Plakat; die Einladung `lio_invite` steht in `stadt.dialogue`, `lio_street` und `lio_again` als geänderte Cues auch in S2) | 23 | 70 | 2.678 |
| [S7_STREIT.md](S7_STREIT.md) | Akt IV: der Streit am Tor (der Richter stellt sich vor und verliest den Abend, Mira am Tor mit den drei Antworten: die Grenze, anschließen, schweigen; die Torwächterin in der Nacht; Miras letzte Zeile im Konzert) | 6 | 35 | 958 |
| [S8_HEIMKEHR.md](S8_HEIMKEHR.md) | Akt IV: die Heimkehr (auf der Straße wird es hell; im Haus der Antreiber an der Werkbank, Tess klopft und kommt mit Brettern, zwei Regale und eine Leiste, „Schief. Aber dicht.“, das Brot des Gefälligen, der Stuhl, der bleibt; die zwei Zeilen für die vier Plätze im Haus; `dawn` steht als neuer Cue am Ende von `strasse.dialogue`) | 9 | 21 | 1.147 |
| [G1_AUFSTIEG.md](G1_AUFSTIEG.md) | Akt V: der Aufstieg (der dritte Pfeil an der Straße, Steinmännchen, Miras Spur in drei Ausgängen, der Rauch der Anlage, Bohlen und Schild, das Schieferplättchen, der Eisenring, Geröll am Ende des Pfads; `ridge_wait` ist ein Platzhalter bis G2) | 11 | 28 | 1.234 |

„Zeilen mit ID“ zählt die Zeilen mit einer ID ohne die ▸ Antworten; die Kalibrierung (`calibrate.py`, 475 Zeilen für Akt II) zählt anders.

Akt I hat keine eigenen Dateien für A7 (Wiederholung) und A9 (Anschluss): ihre Zeilen stehen in `A3_MARKT.md`, `A2_GASTHAUS.md` (die Schleifen des Gastwirts) und `SLICE.md`. Akt II hat keine Datei für B7 (keine neuen Zeilen), Akt III keine für W7 und Akt IV keine für S9 (die Durchläufe schreiben nichts).

**Zur Nummerierung.** Die Nummer eines Cues ist seine Stelle in seiner Datei zum Zeitpunkt der Erzeugung (`T9`, `H20`). Weil Akt II Cues in die Dateien des Slice eingefügt hat,
tragen zwei Cues von `tal.dialogue` in verschiedenen Lesefassungen die Nummer T9 (`evening_elysia` in `SLICE.md` und `B2_NEIN.md`, `evening_values` in `B6_ABEND.md`); eine neue Erzeugung zählt `evening_elysia` als T10. Antworte darum mit dem Namen des Cues und der Datei („B6, `evening_values`: OK“), nicht nur mit der Nummer.
