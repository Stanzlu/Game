# Offene Punkte

Stand 23.10. · Build v0.8.4 · Sammelliste aller ungelösten Probleme und offenen Entscheidungen, damit
im weiteren Spiel nichts verloren geht.

**Herkunft der Punkte:**
- [`KNOWN_ISSUES.md`](KNOWN_ISSUES.md) (Einzelheiten, Ursachen, Status)
- die Risiken und Anforderungen der Game Bible
- vorläufige ADRs und die Art Direction
- die Playtests vom 05. und 06.10.
- eine eigene Prüfung am 07.10.
- die fünf Prüfungen der Polish-Runde am 10./11.10. (ADR-046)
- die zweite Prüfung in acht Linsen am 22.10. und die Entscheidungen dazu (ADR-047)

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
| J | Windows-Build wurde nie auf echter Hardware gestartet; der Projektinhaber kann es nicht prüfen (23.10.), das Risiko ist akzeptiert | #6, ADR-049 | ein Tester mit Windows, wenn sich einer findet |
| J | Leistung auf dem Mac (M1 Pro, 120 Hz): Der Leistungstest zeigt mit VSync an 36 bis 108 fps, ohne VSync 145 bis 474. Im Spiel fühlt es sich für den Projektinhaber gleich an, ob VSync aus oder an ist, und läuft gut (Maus, Bild, VSync; 23.10., Version 0.8.2). Der Standard bleibt VSync an. Ob die gemessenen fps echte Bilder waren, zeigt erst der Bericht von 0.8.3 (gezeichnete Bilder, fps je Sekunde); Godot hat im OpenGL-Pfad von macOS ein offenes VSync-Problem (Issue 79646) | #78, #79, `PERFORMANCE.md` | Optional: Leistungstest mit 0.8.3 und `benchmark.txt` schicken. Spürt ein Tester Ruckeln, hilft VSync aus (Einstellung oder Knopf im Leistungstest) |
| J | Möglicher Ausweg für den Mac: Godots ANGLE-Treiber (OpenGL über Metal, `rendering/gl_compatibility/driver.macos=opengl3_angle`) stellt VSync über Metal statt über Apples OpenGL ein. Der Export von Linux aus legt die ANGLE-Bibliotheken nicht bei (geprüft: `application/export_angle=1` ändert das Zip nicht); sie müssten aus dem offiziellen macOS-Editor kommen, signiert werden und brauchen ADR und Eintrag in `DEPENDENCIES.md` | `PERFORMANCE.md` (Recherche) | Erst entscheiden, wenn „VSync aus“ nicht reicht |
| F | **Externe Playtests vor einer Veröffentlichung:** Bible §61 verlangt mehrere vollständige externe Playtests; ADR-049 verzichtet nur auf den Slice-Test. Ohne Tester sind Ton, Humor, Verständlichkeit und Barrierefreiheit nur teilweise geprüft | ADR-049, ADR-050, `PRODUKTIONSPLAN.md` | vor einem Release Tester suchen; `PLAYTEST*.md` bleiben gültig |
| J | **Tastenbelegung am Controller ausprobieren** (am Mac passt sie, 23.10.): Erfasst die Seite Trigger und Knöpfe, ohne dass etwas hängt? | #76, ADR-048 | Seite „Tastenbelegung“ öffnen, Felder belegen, Ergebnis in KNOWN_ISSUES #76 eintragen |
| J | Von Hand prüfen, was der Container nicht kann: Fenster-X speichert, Fokusverlust öffnet das Pause-Menü, Controller abziehen, PlayStation-Beschriftung, Rumble | #63, #64, #11 | Liste in KNOWN_ISSUES #63; Ergebnis dort eintragen |

**Entschieden am 22.10. und umgesetzt** (der Projektinhaber antwortete „Weiter“ auf die Empfehlungen, ADR-047):

| Punkt | Entscheidung | Wo |
|---|---|---|
| Endkarte | Keine Zeile auf der Karte (Bible §56: Schwarz, dann der Titel). „Hier endet der Prototyp. Danke fürs Spielen.“ steht als Untertitel unter dem „Nach Elysia“-Logo im Startmenü, sobald der neueste Stand das letzte Kapitel des Builds trägt (`Chapter.LAST`; seit Akt III, W1, ist das Ende von Akt II nicht mehr das Ende: „Weiter“ beginnt den Morgen danach, ADR-070; seit Akt III, W6, endet der Build mit der Heimkehr im Haus: still, ohne Schwarz und ohne Titel, offene Frage an den Projektinhaber). Kein Abspann im Slice; Lizenzen und Mitwirkende im Startmenü und im Build. | ADR-030, Nachtrag 22.10. |
| Kamera | *Weich* bleibt Standard und ist straffer eingestellt, *Pixelgenau* bleibt Option, der Playtest fragt. „Bewegungsgefühl“ und „Richtungen“ sind nur noch in Debug-Builds wählbar. | ADR-012, Nachtrag 22.10. |
| Zoom | 1,25× überall, im Haus 1,5× (Ausnahme Innenräume); in der Hütte des Einsiedlers beim Bleiben 1,75× und 2,0× (ein Schritt je Antwort, nur solange sie sitzt). | ADR-045, Nachtrag 22.10.; ADR-070 Nachtrag W3. |
| Mischpixel | Unverändert bis zum Playtest; keine Option „Pixelraster exakt“, keine Vollbild-Rand-Option, solange niemand es nennt. | ADR-045, Nachtrag 22.10. |
| Elysias erste Zeilen | Wärmer und ernster geschrieben; die unheimlich-aufrichtigen Sätze bleiben. | ADR-047 |
| Tastenumbelegung | gebaut, ADR-048 (Seite „Tastenbelegung“ im Pause-Menü und unter Einstellungen). | ADR-048, ADR-011 und ADR-018, Nachträge |

**Entschieden am 23.10.** (der Projektinhaber, nach dem Test von v0.8.3, ADR-049):

| Punkt | Entscheidung | Wo |
|---|---|---|
| Playtest-Gate | Ohne Tester abgenommen; Vorproduktion für Full Production freigegeben (Content-Plan Akt I, Writing-Pass, Karten-Pipeline, Art und Audio ohne Kosten). | ADR-049, `PRODUKTIONSPLAN.md` |
| Vollbild-Rand | Der Rand ist bestätigt; Einstellung „Bild füllen (schmalere Ränder)“ gebaut, vorab aus. | ADR-045, Nachtrag 23.10. |
| Mitwirkende | „Idee, Geschichte und Umsetzung: Luca Stanzl.“ | `CREDITS_TEXT` |
| Release-Entwurf | Muss nicht veröffentlicht werden; die Entwürfe unter Releases dürfen gelöscht werden. | – |
| VSync | Fühlt sich an und aus gleich an; der Standard bleibt an. | `PERFORMANCE.md` |

## 2. Klärt der Playtest

| | Punkt | Quelle | Entscheidung danach |
|---|---|---|---|
| P | Spielzeit vermutlich unter 45 Minuten | #43, `GATE_REPORT.md` | Median unter 35 Minuten: vertiefen (`PHASE4_PLAN.md`, „Vertiefen, falls zu kurz“) Stand 25.10.: Modell 20,7 Minuten für den Slice (`calibrate.py`), noch kein Mensch gemessen (ADR-065, Plan 10.1) |
| P | Texte sind Entwürfe: Ton, Humor, Miras Stimme ungeprüft | #47, ADR-036 | Writing-Pass mit den Zeilen, die Tester zitieren oder stören |
| P | Wirkt Elysia anfangs wirklich attraktiv? | Bible Risiko 9, Pre-Review #2 | Elysia im Slice dauert nur 10–18 Minuten, die Bible will 30–60; Elysia-Dichte erhöhen Stand 25.10.: Akt I gebaut, im Modell rund 14 Minuten (11,5 bis 17,5, Obergrenze 33) gegen 105 geplant; die Entscheidung über mehr Elysia (A4, Erkunden) liegt bei deinem Durchlauf (Plan 11, Fragen 3 und 5, ADR-066). Stand 26.10.: Akt II gebaut und durchgespielt (`akt2_full.json`, ADR-069), im Modell rund 18 Minuten (15 bis 23, Obergrenze 44) gegen 90 geplant, 475 Zeilen, noch kein Mensch gemessen |
| P | Antreiber: Werte (Wegwachstum, Ermüdung, 3 s Stillstand) sind vorläufig | ADR-015 | justieren nach Frage 7 |
| P | Mira spricht den Antreiber im Haus nie an | #49 | so lassen oder eine offene Erzählzeile |
| P | Frösche bei Stille werden nicht erklärt | #50 | so lassen, wenn sie entdeckt werden |
| P | Berge prozedural, nur in Aufnahmen geprüft | #51 | Farben in `backdrop.gd` |
| P | Zoom 1,25× überall: genug Überblick? | ADR-045 | `view_zoom` pro Szene |
| P | Kamera: *Weich* (Standard, straffer eingestellt, rutscht nach dem Stopp noch rund 2 px) gegen *Pixelgenau* (steht still, scrollt in ganzen Spielpixeln); Vergleichsaufnahmen mit 60 und 30 fps hat das Paket „feel“ im Arbeitsverzeichnis der Sitzung erzeugt (nicht im Repository) | #8, ADR-012 | Tester fragen; Standard behalten oder *Pixelgenau* |
| P | Zoom 1,25×: einzelne Spielpixel sind bei genauem Hinsehen ungleich breit (bei 1280×720 jede fünfte Bildspalte) | ADR-045, Nachtrag 22.10. | so lassen, wenn es niemandem auffällt; sonst die Option „Pixelraster exakt“ (rundet den Zoom je Fenster auf ganze Faktoren, Sichtfeld schwankt um ±8 %) |
| P | Elysianer-Paar läuft nach dem Ansprechen versetzt | #38 | beide anhalten lassen? |
| P | Klänge und Musik synthetisch, von Claude nie angehört (Katze, Ziege, Tür, Loop-Wechsel); Mischung und Lautheit sind in zwei Polish-Runden nur gemessen und eingestellt (`check_levels.py`) | #10, #29, #34, #37, #46, ADR-046, ADR-047 | Rückmeldung nach Gehör; sonst neu erzeugen |
| P | Controller auf echter Hardware (Hotplug, Beschriftung, Rumble), Vollbild, Lautstärken | #11, #28, #63, #64 | Fehlerberichte |
| P | Große Schrift: feste Breiten außerhalb der Theme-Typen | #40 | Fundstellen beheben |
| P | Einmaliger Hänger beim ersten Betreten eines Ortes (Shader) | #53 | wenn spürbar: Shader im Ladebildschirm vorwärmen |
| P | Ausreißer bis 240 ms im Leistungstest mit 1,25× (Elysia, Wald), Ursache offen | `PERFORMANCE.md` | auf dem Mac beobachten |
| P | **Ton:** Ist der Bach am Netz und an den Trittsteinen laut genug, nicht zu laut (gemessen +2,9 dB über dem Bett, 5 Emitter, Reichweite 220 px)? | #29, #68, ADR-034 | `STREAM_DB`, `STREAM_REACH` in `map_view.gd` |
| P | **Ton:** Sind Elysias Belohnungen jetzt zu zahm? Sie sind etwa so laut wie die Musik (Kurzzeit −17 LUFS, Spitzen −4,5 dBFS) statt sie zu überdecken; 2 bis 3 dB Luft sind noch da | #34, ADR-046 | Gains in `check_levels.py` und an den Aufrufen anheben |
| P | **Ton:** Sind die Menüklänge der Wirklichkeit zu leise (Bettpegel, Aufrufgain −4)? Passen Türen und Klopfen, 5 bis 9 dB über dem Bett? Ist der Abend (so voll wie der Tag: Grillen, Bach, Laub, Amsel häufiger) zu dicht? Ist das Rasten der Tal-Musik (25 bis 50 s) angenehm? Sind Frösche, Ziege, Vogel und Ruf mit Entfernung zu leise (−4 dB bei 100 px)? | #29, #34, #46, #68 | Gains, `TRACK_REST`, `content/audio/*.tres` |
| P | **Text:** Klingt „Und wenn's eilig ist, hilft Umschalt. Helden rennen.“ natürlich, und fällt der Sprint-Hinweis auf? Ist der Weltenbaum (unsichtbarer Punkt am Südufer, „Ansehen“ über dem Wasser) auffindbar? Ist die Zeile der Elysianer über das Flimmern „ganz unten rechts“ zu deutlich ein Wegweiser? | #47 | Writing-Pass |
| P | **Text:** Antworten Spieler auf Miras Namensfrage mit dem Namen, dem Titel oder Schweigen, und trägt die Namenszeile am Feuer? Ist der Name zweimal kurz hintereinander (im Haus „Hm.“, am Feuer wieder) einmal zu viel? | #47 | Writing-Pass |
| P | **Bild:** Ist der Regen sichtbar genug, ohne zu rauschen (320 Tropfen, 1×8 px, Alpha 0,75)? Ist der Regentag mit Sättigung 1,14 und Helligkeit 0,07 noch bedeckt genug (95. Perzentil 0,57, geplant waren 0,65)? Lesen sich die Abendstrahlen (Alpha 0,18)? Ist das Fensterglas im Haus heller und bläulicher als geplant? | #51, ADR-041 | `DayLight`, `rain_fx.gd`, `sun_rays.gd`, `RAIN_GLASS` in `slice_props.py` |
| P | **Bild:** Passt der Rhythmus des Endes (4 s Schwenk, 2,5 s Halt, „Zum Meer.“, 2,5 s Halt, 2,5 s Abblende)? | ADR-030, Nachtrag | `MOUNTAIN_PAN_SECONDS`, `MOUNTAIN_HOLD_SECONDS`, `SEA_HOLD_SECONDS` in `tal_scene.gd` |
| P | **Bild:** Liest sich das Haus mit 1,5×, Vignette 0,5 und dunklem Ring als Nacht draußen, oder ist der Ring zu dunkel? Fällt der Lichtstoß am Fenster beim Öffnen der Tür auf, oder soll ein Licht an der Tür her? | #44, ADR-045 | `haus.tscn`, `haus_scene.gd` (`NIGHT_ALPHA`, `DOOR_GLARE`) |
| P | **Gefühl:** Ist der Sturz in den Bach kräftig genug (Wackeln 1,5 px, 30 Spritzer, blaugraue Blende)? Ist das Antippen zum Umdrehen leise genug (Schritt erst ab 9 px Weg)? Klingt das Ausblenden der Antreiber-Musik (2,5 s) beim Stehenbleiben richtig? | #8, #50 | `FALL_SHAKE`, `FIRST_STEP_DISTANCE` |
| P | **Elysia:** Wirkt das Weiß des Erwachens (0,4 s Halt, 2,6 s Aufblende) wie warmes Licht, oder ist es zu lang? Überstrahlt das Glühen am Riss die Figur (rund 1,5 s nach der Berührung)? Ist die Beute-Karte mit Zeile (3,4 s) bei drei Gegenständen aus der Truhe zu lang? | #70 | `WAKE_*` in `elysia_scene.gd`, `SWELL_*` in `rift.gd`, `LOOT_CARD_SECONDS_WITH_DESC` |
| P | **Haus und Figuren:** Stimmt der Takt von Miras Besuch (herein mit 40 px/s, hinaus mit 45 px/s)? Summt das Kind jetzt zu oft (alle 4 bis 8 s), wenn man am Becken verweilt? Reicht Miras Arbeitspose am Netz (Kopfnicken 1 px, Hände 2 px)? | #71 | `MIRA_SPEED_*`, `ChildGuide.HUM_PAUSE`, `make_character.py` |
| P | **Start:** Verdeckt das Elysia-Menü die Insel zu sehr (soll sie kleiner oder höher sitzen)? Ist die goldene Tagline (27 px) zu groß, die Fußzeile mit dem Tastenhinweis zu auffällig? Verwirrt der Hinweis „blättern“ im leeren Journal? Ist es in Ordnung, dass im Pause-Menü „Hier kann nicht gespeichert werden“ den Tastenhinweis ersetzt? | #35 | Layout in `boot.gd`, `JOURNAL_HINT`, `PAUSE_HINT` |

## 3. Technik und Pipeline

| | Punkt | Quelle | Vorschlag |
|---|---|---|---|
| F | **Kartenpipeline skaliert nicht auf 7 Regionen:** Textkarten, ein gebackener Boden pro Karte, Layout-Skripte | ADR-004, ADR-017, #13 | Karten-Editor (Tiled/LDtk, ADR-004 hält den Weg offen); Böden in Kacheln oder Chunks backen |
| F | **Größere Karten:** Der Projektinhaber stellt sich die Orte im ganzen Spiel größer vor (Playtest 10.10.); das Tal misst heute 68 × 38 Kacheln | ADR-045, Nachtrag 10.10. | Größe pro Region im Content-Budget (§48) festlegen; braucht die Pipeline oben (Chunks, Streaming der Streu) |
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
| F | Look-Prototypen (`look_tal`, `look_wald`) haben die neue Baumgrenze nicht | ADR-045 | nur Prototypen; bei Bedarf `[meta] treeline` ergänzen |
| F | Cloud-Sitzungen: keine Tag-Pushes, Asset-Seiten gesperrt | ADR-044, #4 | Releases per manuellem CI-Start; Assets von Hand committen |
| F | Objekte, die beim Beenden nicht freigegeben werden: Audio-Wiedergaben laufen noch | #2 | Audio einige Frames vor `get_tree().quit()` anhalten (`PauseMenu._quit`, `Boot._quit`, `AppGuard`) |
| F | Pegel-Check ausbauen: Platzhalter-Klänge (`gate`, `lever`, `splash`, UI-Töne) nach Lautheit, `goat_munch` angleichen, numpy in CI | #65, #66 | bei der nächsten Klangarbeit |
| F | `MapData` behält `paint` nicht; `FootstepFx` liest die Legende der Karte selbst (kleines Duplikat) | – | `paint` in `MapData.tiles` halten, dann entfällt `_find_mud_symbols` |
| F | Antreiber-Sprechblasen (`$Bark`) liegen noch im Weltraum; `GuestWalker` und `AntreiberActor` bauen Ähnliches | – | wie der Prompt in eine UI-Schicht über `world_to_ui` heben; beide Figuren zusammenlegen |
| F | Blende nach dem Riss erst nach dem ersten gezeichneten Bild starten (ruckelfreie Ankunft) | #69 | `GameScene` und `SceneTravel` |
| F | Godot schreibt bei jedem Import oder Testlauf eine `uid` in `default_bus_layout.tres` (laut Bericht des Pakets menus; im Arbeitsbaum zurückgesetzt) | – | die `uid` einmal einchecken, dann entfällt die Änderung |

## 4. Grafik, Ton und Text

Alles ist projekt-eigen erzeugt; Liste aller Dateien in [`PLACEHOLDERS.md`](PLACEHOLDERS.md).

| | Punkt | Quelle | Vorschlag |
|---|---|---|---|
| F | Figuren: Grundposen, Umschauen und Miras Arbeitspose, keine Anpassung | #16 | handgepixelte Spielfigur, Mira, Kind, Antreiber (ART_DIRECTION, nächste Schritte) |
| F | Böden, Bäume, Haus, Requisiten sind prozedural | ADR-017, ADR-057 | erledigt 24.10.: „erzeugt und kuratiert“ gilt, Abnahme je Region, Budgetfrage vor einer Veröffentlichung |
| F | Key-Art und Startbilder aus Spiel-Sprites; Menü verdeckt den Weltenbaum | #35 | eigene Titelillustration |
| F | Musik, Klänge, Naturklänge synthetisch | #10, #29, #34, #46 | Komposition, Sounddesign, Field Recordings (CC0 oder beauftragt) |
| F | Texte Entwürfe | #47 | Writing-Pass, danach Lokalisierung (Englisch per CSV, ADR-002) |
| P | Art-Direction-Fragen 1–4 unbeantwortet (Elysia schön und unheimlich? Tal einladend? Titel? Was stört an Figur, Bäumen, Haus, Licht?) | `ART_DIRECTION.md` | in den Playtest-Antworten mitlesen |

## 5. Barrierefreiheit (Bible §50)

| Anforderung | Stand | | Offen |
|---|---|---|---|
| Skalierbare Textgröße | „Große Schrift“ | P | feste Breiten (#40) |
| Controller- und Tastatur-Umbelegung | Menü „Tastenbelegung“ (Tastatur und Controller, Konflikte, Standard; ADR-048) | **J** | Beschriftung und Controller auf echter Hardware prüfen (#75, #76) |
| Untertitel | alle Dialoge und Erzählzeilen; „Es klopft.“ als Zeile; „Geräusche als Text“ (Einstellung, #58; auch Katze und Schnurren) | | – |
| Getrennte Lautstärken | sechs Regler | | – |
| Dialoggeschwindigkeit, Auto-Advance | ja | | – |
| Bildschirmwackeln, Blitzeffekte | einstellbar | F | wirkt beim Riss, Sturz, Feuer, Erwachen und im Dialogtext; jeder neue Effekt muss fragen (#24) |
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
| F | 9: Elysia von Anfang an offensichtlich böse | Elysia kurz; die ersten Zeilen sind seit 22.10. wärmer | siehe Abschnitt 2 |
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
