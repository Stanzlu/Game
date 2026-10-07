# Offene Punkte

Stand 07.10. · Build v0.5.0 · Sammelliste aller ungelösten Probleme und offenen Entscheidungen, damit
im weiteren Spiel nichts verloren geht.

**Herkunft der Punkte:**
- [`KNOWN_ISSUES.md`](KNOWN_ISSUES.md) (Einzelheiten, Ursachen, Status)
- die Risiken und Anforderungen der Game Bible
- vorläufige ADRs und die Art Direction
- die Playtests vom 05. und 06.10.
- eine eigene Prüfung am 07.10.

**Pflege:** Wer einen Punkt löst, streicht ihn hier und setzt den Eintrag in `KNOWN_ISSUES.md` auf
„behoben“. Neue Probleme kommen zuerst in `KNOWN_ISSUES.md` und, wenn sie die Planung betreffen, hierher.

**Wann:**

| Kürzel | Zeitpunkt |
|---|---|
| **J** | jetzt, vor dem Playtest |
| **P** | klärt der Playtest; danach entscheiden |
| **F** | vor oder in der Full Production |

## 1. Vor dem Playtest

| | Punkt | Quelle | Nächster Schritt |
|---|---|---|---|
| J | Release-Entwurf „Playtest v0.5.0“ veröffentlichen | ADR-044 | Projektinhaber prüft und veröffentlicht unter Releases |
| J | Windows-Build wurde nie auf echter Hardware gestartet | #6 | ein Tester mit Windows, sonst vor dem Versand selbst starten |
| J | Leistung auf dem Mac mit v0.5.0 unbekannt (30-fps-Bremse, Zoom 1,25× mit linearer Abtastung, 12 Lichter im Wald) | #42, #12, #18, #31, `PERFORMANCE.md` | Startmenü → Prototypen → Leistungstest, Bericht `benchmark.txt` schicken |
| J | Rand-Rückmeldung vom 06./07.10. nicht ganz abgeschlossen: Haus in Schwarz, grauer Himmel über dem Nordrand im Regen | #44, ADR-045 | Projektinhaber sagt, ob einer davon gemeint war |

## 2. Klärt der Playtest

| | Punkt | Quelle | Entscheidung danach |
|---|---|---|---|
| P | Spielzeit vermutlich unter 45 Minuten | #43, `GATE_REPORT.md` | Median unter 35 Minuten: vertiefen (`PHASE4_PLAN.md`, „Vertiefen, falls zu kurz“) |
| P | Texte sind Entwürfe: Ton, Humor, Miras Stimme ungeprüft | #47, ADR-036 | Writing-Pass mit den Zeilen, die Tester zitieren oder stören |
| P | Wirkt Elysia anfangs wirklich attraktiv? | Bible Risiko 9, Pre-Review #2 | Elysia im Slice dauert nur 10–18 Minuten, die Bible will 30–60; Elysia-Dichte erhöhen |
| P | Antreiber: Werte (Wegwachstum, Ermüdung, 3 s Stillstand) sind vorläufig | ADR-015 | justieren nach Frage 7 |
| P | Mira spricht den Antreiber im Haus nie an | #49 | so lassen oder eine offene Erzählzeile |
| P | Frösche bei Stille werden nicht erklärt | #50 | so lassen, wenn sie entdeckt werden |
| P | Berge prozedural, nur in Aufnahmen geprüft | #51 | Farben in `backdrop.gd` |
| P | Zoom 1,25× überall: genug Überblick? | ADR-045 | `view_zoom` pro Szene |
| P | Kamera *Weich* wackelt um ±0,5 Spielpixel | #8, ADR-012 | Standard behalten oder *Pixelgenau* |
| P | Elysianer-Paar läuft nach dem Ansprechen versetzt | #38 | beide anhalten lassen? |
| P | Klänge und Musik synthetisch, von Claude nie angehört (Katze, Ziege, Tür, Loop-Wechsel) | #10, #29, #34, #37, #46 | Rückmeldung nach Gehör; sonst neu erzeugen |
| P | Controller auf echter Hardware, Vollbild, Lautstärken | #11, #28 | Fehlerberichte |
| P | Große Schrift: feste Breiten außerhalb der Theme-Typen | #40 | Fundstellen beheben |
| P | Einmaliger Hänger beim ersten Betreten eines Ortes (Shader) | #53 | wenn spürbar: Shader im Ladebildschirm vorwärmen |
| P | Ausreißer bis 240 ms im Leistungstest mit 1,25× (Elysia, Wald), Ursache offen | `PERFORMANCE.md` | auf dem Mac beobachten |

## 3. Technik und Pipeline

| | Punkt | Quelle | Vorschlag |
|---|---|---|---|
| F | **Kartenpipeline skaliert nicht auf 7 Regionen:** Textkarten, ein gebackener Boden pro Karte, Layout-Skripte | ADR-004, ADR-017, #13 | Karten-Editor (Tiled/LDtk, ADR-004 hält den Weg offen); Böden in Kacheln oder Chunks backen |
| F | Veraltete gebackene Böden fallen nur bei falscher Größe auf | #13 | Prüfsumme der Karte in den gebackenen Dateien und ein Test, der sie vergleicht |
| F | Elysia des Slice nutzte den Boden des Look-Prototyps (zwei Fackelschatten fehlten) | #57 (behoben) | Regel: jede Karte backt in eigene Dateien |
| F | 1000–1600 Streu-Sprites pro Karte | #20 | MultiMesh oder gebackene Chunks |
| F | Licht: 12 `PointLight2D` im Wald, Streu ohne Licht, Lampen auf Nachtgras grünlich | #18, #36, #17 | eigener Licht-Shader oder gemalte Lichtstimmungen |
| F | Regenspritzer auf Dächern und Kronen | #14 | auf eine Bodenmaske begrenzen |
| F | Ufer- und Waldkanten weichen einige Pixel von der Kachel-Kollision ab | #15, ADR-045 | mit finalen Karten feinere Kollision |
| F | Nähte auf dem Weg des Antreibers | #45 | horizontal periodisch backen |
| F | Spiegelungen nur für Dinge, die beim Laden am Wasser stehen | #21 | dynamisch zuweisen, wenn NPCs wandern |
| F | Dialogue Manager: ein Zeichen pro Frame, belegte Ressourcen beim Beenden, Schlüssel in Großbuchstaben | #27, #2, #7 | bei jedem Addon-Update prüfen (`DEPENDENCIES.md`) |
| F | Erster Import eines frischen Checkouts meldet Theme-Fehler | #1 | `check.sh` macht einen Aufwärm-Import; bei Godot-Update prüfen |
| F | Lineare, scharfe Abtastung kostet im Software-Rendering 25 % | `PERFORMANCE.md` 07.10. | auf Zielhardware messen; notfalls ganzzahligen Zoom erlauben |
| F | Prototyp-Szenen im Startmenü ersetzen das Autosave | #22 | Prototypen vor einer Veröffentlichung aus dem Menü nehmen |
| F | Look-Prototypen (`look_tal`, `look_wald`) haben die neue Baumgrenze nicht | ADR-045 | nur Prototypen; bei Bedarf `[meta] treeline` ergänzen |
| F | Cloud-Sitzungen: keine Tag-Pushes, Asset-Seiten gesperrt | ADR-044, #4 | Releases per manuellem CI-Start; Assets von Hand committen |

## 4. Grafik, Ton und Text

Alles ist projekt-eigen erzeugt; Liste aller Dateien in [`PLACEHOLDERS.md`](PLACEHOLDERS.md).

| | Punkt | Quelle | Vorschlag |
|---|---|---|---|
| F | Figuren: nur Grundposen und Umschauen, keine Anpassung | #16 | handgepixelte Spielfigur, Mira, Kind, Antreiber (ART_DIRECTION, nächste Schritte) |
| F | Böden, Bäume, Haus, Requisiten sind prozedural | ADR-017 (vorläufig) | Art-Pass nach dem Gate; ADR-017 dann abschließen |
| F | Key-Art und Startbilder aus Spiel-Sprites; Menü verdeckt den Weltenbaum | #35 | eigene Titelillustration |
| F | Musik, Klänge, Naturklänge synthetisch | #10, #29, #34, #46 | Komposition, Sounddesign, Field Recordings (CC0 oder beauftragt) |
| F | Texte Entwürfe | #47 | Writing-Pass, danach Lokalisierung (Englisch per CSV, ADR-002) |
| P | Art-Direction-Fragen 1–4 unbeantwortet (Elysia schön und unheimlich? Tal einladend? Titel? Was stört an Figur, Bäumen, Haus, Licht?) | `ART_DIRECTION.md` | in den Playtest-Antworten mitlesen |

## 5. Barrierefreiheit (Bible §50)

| Anforderung | Stand | | Offen |
|---|---|---|---|
| Skalierbare Textgröße | „Große Schrift“ | P | feste Breiten (#40) |
| Controller- und Tastatur-Umbelegung | nur per Datei | **F** | Menü zum Umbelegen (#25) |
| Untertitel | alle Dialoge und Erzählzeilen; „Es klopft.“ als Zeile | **F** | Geräusche ohne Text (Quaken, Riss, Ziege, Katze), #58 |
| Getrennte Lautstärken | sechs Regler | | – |
| Dialoggeschwindigkeit, Auto-Advance | ja | | – |
| Bildschirmwackeln, Blitzeffekte | einstellbar | F | wirkt nur beim Riss; jeder neue Effekt muss fragen (#24) |
| Halten/Umschalten | Rennen | | – |
| Puzzlehilfen | Mira gibt Hinweise nach dem ersten Fehlversuch (Steine, Ziege); der Riss öffnet sich von selbst | F | keine abrufbare Hilfe |
| Navigationshilfe | Elysia mit Markern; Wirklichkeit bewusst ohne | F | für größere Regionen ein leises Mittel finden (Journal, Mira) |
| Zeitfenster, Begegnungstempo | einstellbar | | – |
| Information nicht nur über Farbe | Trittsteine: Form und Farbe | P | ungeprüft mit Farbsehschwäche |
| Parallaxe | „Tiefenebenen bewegen sich mit“ | | – |
| Keine Bestrafung für Optionen | erfüllt | | – |

## 6. Design und Bible-Risiken

| | Risiko (Bible) | Stand im Slice | Für die Full Production |
|---|---|---|---|
| F | 1, 3, 10: Zu viel Metapher, Therapiespiel, Realität = Leiden | Suchtmetapher bleibt ungenannter Subtext (ADR-042); Wirklichkeit warm gemalt (ADR-041) | bei jedem Writing-Pass gegen §3.2, §4 und §51 prüfen |
| F | 2: Walking Simulator | drei Herausforderungen (Trittsteine, Antreiber, Ziege) | jede Region mit eigener Mechanik |
| F | 4: Scope-Explosion | Content-Budget §48 | Budget pro Region vor der Produktion festlegen |
| F | 5, 6: Art und Musik unterschätzt | Platzhalter | Budget-Entscheidung nach dem Gate (0-€-Regel bis dahin) |
| F | 7: Humor zerstört Emotion | Ziege, Kartoffel, Elysias Übertreibung | Playtest-Fragen 9 und 10 gegeneinander lesen |
| F | 8: Beschützer werden Karikaturen | nur der Antreiber, mit Warum und Ruhe am Feuer | jeder Beschützer mit eigenem Warum |
| F | 9: Elysia von Anfang an offensichtlich böse | Elysia kurz | siehe Abschnitt 2 |
| F | Spielzeit | geschätzt 30–50 statt 45–60 Minuten | siehe Abschnitt 2 |

## 7. Organisation und Recht

| | Punkt | Quelle | Nächster Schritt |
|---|---|---|---|
| F | Lizenz des Spiels nicht festgelegt | README | vor jeder Veröffentlichung entscheiden |
| F | Builds unsigniert (Windows SmartScreen, macOS Gatekeeper) | #5 | Signierung nach Budget-Entscheidung (Apple 99 $/Jahr) |
| F | Name „Nach Elysia“ nicht auf Marken und Shop-Namen geprüft | ADR-035 | vor einer Shop-Seite prüfen |
| F | Vorläufige ADRs: Darstellung (007), Antreiber-Werte (015), Look-Pipeline (017) | `DECISIONS.md` | nach dem Gate abschließen oder ersetzen |
| F | Mobile bewusst ausgeschlossen | ADR-005 | nach dem Gate neu entscheiden |
| J | Alte Branches der Phasen liegen noch auf GitHub | – | löschen nur mit Zustimmung des Projektinhabers |
