# Phase 5: Playtest-Gate

Stand 06.10. · Build **v0.5.0** · Bible §57 (Success Gates), Master-Prompt §47 und §48, ADR-044, ADR-045.

Der Vertical Slice ist technisch fertig. Ab hier gilt: **STOP.** Kein Inhalt über den Slice hinaus,
bis Playtest-Ergebnisse vorliegen (Bible §57, Master-Prompt §47). Dieses Dokument bündelt alles, was
das Gate braucht.

| Gate-Artefakt (Master-Prompt §47) | Wo |
|---|---|
| Build | GitHub-Release „Playtest v0.5.0“ (Entwurf, siehe unten) |
| Testanleitung | [`PLAYTEST.md`](PLAYTEST.md) für alle Tester; Detailfragen für dich in [`PLAYTEST_PHASE4.md`](PLAYTEST_PHASE4.md) |
| Bekannte Probleme | [`KNOWN_ISSUES.md`](KNOWN_ISSUES.md), Auszug unten |
| Playtest-Fragen | [`PLAYTEST.md`](PLAYTEST.md), Abschnitt „Danach: Fragen“ (§48 und Gates) |
| Technische Risiken | unten |
| Performance-Bericht | unten und [`PERFORMANCE.md`](PERFORMANCE.md) |
| Placeholder-Liste | [`PLACEHOLDERS.md`](PLACEHOLDERS.md), Zusammenfassung unten |
| Nächste mögliche Schritte | unten |

## Build und Ablauf

1. **Build:** Ein manueller CI-Lauf auf `main` mit „Release“ (oder ein Tag `v0.5.0`) lässt CI
   Windows, macOS und Linux bauen und einen **Release-Entwurf** anlegen. Dazu packt `tools/release.sh` je System ein Zip mit `LIESMICH.txt`.
   Ein Entwurf ist nur für dich sichtbar. Du prüfst ihn und veröffentlichst ihn mit einem Klick.
   Erst dann kann jeder mit dem Link herunterladen; das Repository ist öffentlich.
2. **Tester:** du und **mindestens vier Menschen**, die das Projekt nicht kennen, am besten gemischt
   (spielt viel / spielt selten). Sie bekommen den Release-Link und `PLAYTEST.md`, sonst nichts.
3. **Zurück kommen:** Antworten auf die 15 Fragen und die Log-Datei. Das Log enthält die Minute jedes
   Abschnitts, jetzt auch in Release-Builds (`Log.record`, ADR-044). Vorher fehlten diese Zeilen ohne
   `--log-debug` (KNOWN_ISSUES #54).
4. **Auswertung:** Gate-Matrix unten. Danach entscheiden wir gemeinsam (nächste mögliche Schritte).

## Gate-Matrix

Klasse **M** (Mechanik, Erzählung) ist mit Platzhaltern aussagekräftig. Klasse **Ä** (Ästhetik) hängt an
Grafik und Ton und wird mit Platzhaltern nur geschätzt (Pre-Implementation Review, B1.1).
Die Schwellen sind **festgelegt** (vom Projektinhaber an Claude übertragen, 06.10., ADR-045) und
gelten vor jeder Auswertung, damit das Ergebnis nicht nachträglich zurechtgelegt wird.

**Zählweise:** Für jeden Tester wird jedes Gate aus seinen Antworten mit **ja**, **teils** oder
**nein** bewertet. Maßgeblich ist die Regel in der Spalte „Ja, wenn“. Gezählt werden die Tester, die das
Projekt nicht kennen; die eigene Runde des Projektinhabers wird getrennt notiert (Autorenblick).

| Gate (Bible §57) | Klasse | Fragen in `PLAYTEST.md` | Ja, wenn der Tester … | Was der Slice dafür tut |
|---|---|---|---|---|
| **Movement:** gern unterwegs | M | 8, Technik | das Laufen positiv oder neutral beschreibt und die Steuerung nicht als Hindernis nennt | Beschleunigung, Rennen, Ecken-Ausweichen, weiche Kamera, Schritte je Untergrund |
| **Elysia:** zunächst attraktiv | Ä | 1, 10 | die ersten Minuten in Elysia als angenehm oder verlockend beschreibt, bevor es kippte | Belohnungen, Level-ups, Lob, Gold, Musik, Symmetrie |
| **Mystery:** etwas stimmt nicht, unerklärt | M | 2, 6, 12 | einen konkreten Auslöser vor dem Riss nennt und es nicht als „erklärt“ empfand | Wiederholungen, kein Spiegelbild, Stein ohne Zwilling, das Kind |
| **Mira:** mehr über sie wissen | M | 4, 5, 14 | sie als eigene Person beschreibt und eine Vermutung hat, was sie will | eigenes Nein, eigene Ziele, Abendgespräch mit Erinnerungen |
| **Transition:** substanzieller Wechsel | M/Ä | 3, 10 | den Verlust der Anzeigen als Gefühl beschreibt (nicht nur „ist weg“) | UI zerfällt einzeln, Stille, Regen, Dunst und Berge (ADR-043) |
| **Encounter:** Optimierung ist nicht alles | M | 7 | „stehen bleiben“ (oder Ähnliches) als Lösung nennt und sie verständlich fand | Weg wächst beim Rennen, Hinweise (Bänke, Frösche, Stocken) |
| **Emotion:** ein Moment bleibt | M/Ä | 10 | spontan einen bestimmten Moment nennt | Feuer, Abend an Miras Feuer, Blick zu den Bergen, Katze |
| **Humor:** ein wiederkehrendes Element trägt | M | 9 | etwas Lustiges nennt; das Gate ist erfüllt, wenn mindestens ein Element von zwei oder mehr Testern genannt wird | Elysias Übertreibung, Ziege, Kartoffel, „Ein Kompliment, legendär“ |
| **Desire:** „Ich möchte wissen, wie es weitergeht“ | M | 14, 15 | freiwillig weiterspielen würde und einen Grund aus der Geschichte oder Welt nennt (nicht nur „sieht gut aus“) | der ganze Bogen, offenes Ende „Zum Meer.“ |

**Ein Gate ist**
- **erfüllt**, wenn mindestens zwei Drittel der Tester **ja** sagen (bei 4 Testern: 3, bei 5: 4,
  bei 6: 4)
- **verfehlt**, wenn weniger als ein Drittel **ja** sagt
- dazwischen **wackelt** es

**Gesamturteil:**

| Urteil | Bedingung | Folge |
|---|---|---|
| **Bestanden** | Desire erfüllt; Movement, Mystery, Mira und Encounter erfüllt (höchstens eines wackelt); kein M-Gate verfehlt | Vorproduktion (nächste Schritte) |
| **Verbessern** | Desire wackelt, oder ein M-Gate ist verfehlt | die betroffenen Gates gezielt verbessern, dann Kurz-Playtest mit neuen Testern |
| **Nicht bestanden** | Desire verfehlt | kein neuer Inhalt; der Slice wird überarbeitet (Bible §57) |

Die Ä-Gates (Elysia, Anteile von Transition und Emotion) dürfen mit Platzhaltern wackeln. Verfehlt
eines, ist das ein Auftrag an Art und Ton (Art-Pass), nicht an die Struktur.

**Zusätzlich gemessen:**
- **Spielzeit** aus dem Log: Ziel 45–60 Minuten, geschätzt 30–50 (KNOWN_ISSUES #43). Liegt der Median
  unter 35 Minuten, wird vertieft (`PHASE4_PLAN.md`, „Vertiefen, falls zu kurz“), auch wenn alles
  andere besteht.
- **Hänger** (Frage 13): Jede Stelle, an der zwei oder mehr Tester länger als drei Minuten brauchten
  oder die Hilfe öffneten, wird vor dem nächsten Test entschärft.
- **Technik:** Jeder Absturz wird vor dem nächsten Test behoben.
- **Tester:** mindestens vier Menschen, die das Projekt nicht kennen, gemischt (spielt viel / spielt
  selten). Weniger als vier ergeben kein Urteil, nur Hinweise.

## Technische Risiken

| Risiko | Wahrscheinlichkeit | Auswirkung | Gegenmaßnahme |
|---|---|---|---|
| Platzhalter-Grafik und -Ton verfälschen die Ä-Gates | hoch | hoch | Gate-Klassen M/Ä; Tester-Briefing in `PLAYTEST.md`; Art-Pass erst nach Validierung |
| Slice kürzer als 45 Minuten | mittel | mittel | Zeit pro Abschnitt aus dem Log; gezielt vertiefen (`PHASE4_PLAN.md`, „Vertiefen, falls zu kurz“) |
| Bildrate auf schwacher oder gedrosselter Hardware (Mac im Stromsparmodus: 30 fps) | mittel | mittel | Einstellung VSync, Leistungstest im Spiel, Hinweis in `PLAYTEST.md`; Messung mit v0.5.0 offen |
| Einmalige Hänger beim ersten Laden einer Szene (Shader-Kompilierung) | hoch beim ersten Start | gering | danach im Shader-Cache; bei Bedarf Vorwärmen im Ladebildschirm (KNOWN_ISSUES #53) |
| Unsignierte Builds schrecken Tester ab | mittel | gering | Schritt-für-Schritt-Anleitung; Signierung erst nach Budgetentscheidung (KNOWN_ISSUES #5) |
| Texte sind Entwürfe (Ton, Humor, Miras Stimme) | mittel | hoch | Playtest-Fragen; Writing-Pass nach dem Gate (KNOWN_ISSUES #47) |
| Windows-Build nie auf echter Hardware gestartet | mittel | hoch | Linux-Build startet in CI; Windows im Playtest bestätigen (KNOWN_ISSUES #6) |
| Controller auf echter Hardware ungetestet | mittel | gering | Tastatur geht immer; Rückmeldung im Playtest (KNOWN_ISSUES #11) |
| Prozedurale Pipeline (Textkarten, gebackene Böden, generierte Sprites) skaliert nicht auf 7 Regionen | hoch für Full Production | hoch | nach dem Gate entscheiden: Karten-Editor (Tiled/LDtk, ADR-004) und handgemalte Assets |
| Abhängigkeit von Godot 4.7.2 und Dialogue Manager 4.1.0 | gering | mittel | Version gepinnt, dünne Adapter, 290 automatische Tests; Updates nur bewusst |
| Spielstände über Versionen hinweg | gering | mittel | `schema_version` und Migrationen (ADR-021, `SAVE_FORMAT.md`); Playtest-Stände müssen nicht in Full Production überleben |
| Kostenfallen (CI-Minuten, Artefakt-Speicher, Signierung, Assets) | gering | mittel | öffentliches Repository, Releases statt Artefakte, 0-€-Regel |

## Performance-Bericht

| Messgröße | Budget (Vorschlag, `PERFORMANCE.md`) | Stand v0.5.0 |
|---|---|---|
| Bildrate | stabil 60 fps | Zielrechner (Mac) zuletzt 30 fps durch Drosselung; mit v0.5.0 neu messen (Startmenü → Prototypen → Leistungstest) |
| Frame-Zeit CPU | 95 % unter 16,6 ms | headless rund 7 ms pro Frame, langsamste 8–10 ms |
| Container (Software-Rendering, kein Maßstab) | – | 38–48 fps in allen Szenen, 11–186 Draw Calls |
| Erster Start einer Szene | ohne spürbaren Hänger | einmalig bis 255 ms (Shader-Kompilierung, Software-Rendering), danach max. 37–44 ms |
| Speichern | unter 100 ms | 0,5–1,5 ms |
| Build-Größe | unter 200 MB | Windows rund 50 MB (Zip), macOS rund 71 MB (Zip) |

Die Tabelle ist mit Zoom 1,5× gemessen. Für 1,25× (ADR-045) gibt es am 07.10. einen Vergleich in
derselben Umgebung (`PERFORMANCE.md`):
- Tal, Haus und Weg bleiben gleich.
- Elysia und Wald (vorher 1×) sind im Software-Rendering rund 25 % langsamer, weil die Welt jetzt
  linear und scharf abgetastet wird.
- Auf Grafikkarten ist das erfahrungsgemäß vernachlässigbar. Die Messung auf dem Mac steht aus.

Die Berge zeichnen nur neu, wenn sie zu sehen sind.

## Platzhalter

Alle 479 Asset-Dateien sind projekt-eigen und programmatisch erzeugt, bis auf drei Schriften (OFL 1.1).
CC0-Packs wurden nicht verwendet, weil die Asset-Seiten aus der Cloud-Umgebung gesperrt sind.
Alles ist reproduzierbar (`tools/art`, `tools/audio`, `tools/placeholders`).

Für Full Production zu ersetzen:
- Figuren (Spieler, Mira, Kind, Antreiber, Elysianer)
- Tilesets und Böden
- Requisiten
- Musik (Motiv bleibt) und Soundeffekte
- Naturklänge (Field Recordings)
- Key-Art und Titel
- UI-Rahmen und Icons

Jede Datei mit Quelle und Lizenz steht in [`PLACEHOLDERS.md`](PLACEHOLDERS.md).

## Bekannte Probleme für den Playtest (Auszug)

| # | Problem | Was Tester merken könnten |
|---|---|---|
| 5 | Builds unsigniert | Warnung beim ersten Start (Anleitung in `PLAYTEST.md`) |
| 42 | Mac im Stromsparmodus mit VSync | genau 30 fps; Einstellung VSync aus |
| 43 | Spielzeit ungemessen | möglicherweise unter 45 Minuten |
| 47 | Texte sind Entwürfe | einzelne Zeilen klingen falsch |
| 46, 34, 29 | Klänge synthetisch | Katze, Ziege und Tür können künstlich wirken |
| 51 | Berge prozedural | am Abend zu hell oder zu glatt |
| 53 | Shader-Kompilierung | ein kurzer Hänger beim ersten Betreten eines Ortes |

## Nächste mögliche Schritte

Nichts davon beginnt vor den Ergebnissen. Welcher Weg, entscheidest du nach der Auswertung.
Alle ungelösten Punkte, die ein Weg mitnehmen muss, stehen gesammelt in `OFFENE_PUNKTE.md`.

| Ergebnis | Weg | Inhalt |
|---|---|---|
| Desire und die meisten M-Gates erfüllt | **Vorproduktion Full Production** | Budget- und Art-Entscheidung (handgepixelte Figuren, Tilesets, Musik), Writing-Pass mit den Playtest-Zeilen, Karten-Editor statt Textkarten, Content-Plan Akt I nach Bible §48 |
| Desire erfüllt, Ä-Gates schwach | **Art-Pass vor Full Production** | ein Ort (Tal) mit finaler Grafik und Ton als Prüfstein, dann erneuter Kurz-Playtest |
| Desire fehlt | **Slice verbessern** | die schwächsten Gates gezielt angehen (z. B. Mira, Übergang, Antreiber), erneuter Playtest |
| unabhängig davon | **Fehler aus dem Playtest** | Abstürze, Hänger, Texte; Spielzeit gegen 45–60 Minuten abgleichen |
