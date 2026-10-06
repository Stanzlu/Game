# Phase 5: Playtest-Gate

Stand 06.10. · Build **v0.5.0** · Bible §57 (Success Gates), Master-Prompt §47 und §48, ADR-044.

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

1. **Build:** Ein Tag `v0.5.0` auf `main` lässt CI Windows, macOS und Linux bauen und einen
   **Release-Entwurf** anlegen. Dazu packt `tools/release.sh` je System ein Zip mit `LIESMICH.txt`.
   Ein Entwurf ist nur für dich sichtbar. Du prüfst ihn und veröffentlichst ihn mit einem Klick.
   Erst dann kann jeder mit dem Link herunterladen; das Repository ist öffentlich.
2. **Tester:** Vorschlag: **du und drei bis fünf Menschen**, die das Projekt nicht kennen, am besten
   gemischt (spielt viel / spielt selten). Sie bekommen den Release-Link und `PLAYTEST.md`, sonst nichts.
3. **Zurück kommen:** Antworten auf die 15 Fragen und die Log-Datei. Das Log enthält die Minute jedes
   Abschnitts, jetzt auch in Release-Builds (`Log.record`, ADR-044). Vorher fehlten diese Zeilen ohne
   `--log-debug` (KNOWN_ISSUES #54).
4. **Auswertung:** Gate-Matrix unten. Danach entscheiden wir gemeinsam (nächste mögliche Schritte).

## Gate-Matrix

Klasse **M** (Mechanik, Erzählung) ist mit Platzhaltern aussagekräftig. Klasse **Ä** (Ästhetik) hängt an
Grafik und Ton und wird mit Platzhaltern nur geschätzt (Pre-Implementation Review, B1.1).
Die Schwellen sind ein **Vorschlag**; du entscheidest sie vor der Auswertung.

| Gate (Bible §57) | Klasse | Fragen in `PLAYTEST.md` | Erfüllt, wenn (Vorschlag) | Was der Slice dafür tut |
|---|---|---|---|---|
| **Movement:** gern unterwegs | M | 8, Technik | Mehrheit beschreibt das Laufen positiv oder neutral, niemand nennt die Steuerung als Hindernis | Beschleunigung, Rennen, Ecken-Ausweichen, weiche Kamera, Schritte je Untergrund |
| **Elysia:** zunächst attraktiv | Ä | 1, 10 | Mehrheit fand die ersten Minuten angenehm, bevor es kippte | Belohnungen, Level-ups, Lob, Gold, Musik, Symmetrie |
| **Mystery:** etwas stimmt nicht, unerklärt | M | 2, 6, 12 | Mehrheit nennt einen konkreten Auslöser vor dem Riss, niemand empfindet es als erklärt | Wiederholungen, kein Spiegelbild, Stein ohne Zwilling, das Kind |
| **Mira:** mehr über sie wissen | M | 4, 5, 14 | Mehrheit beschreibt sie als eigene Person und hat eine Vermutung, was sie will | eigenes Nein, eigene Ziele, Abendgespräch mit Erinnerungen |
| **Transition:** substanzieller Wechsel | M/Ä | 3, 10 | Mehrheit beschreibt den Verlust der Anzeigen als spürbar (nicht nur bemerkt) | UI zerfällt einzeln, Stille, Regen, Zoom und Tiefe (ADR-043) |
| **Encounter:** Optimierung ist nicht alles | M | 7 | Mehrheit nennt „stehen bleiben“ oder Ähnliches als verstanden, nicht als Zufall | Weg wächst beim Rennen, Hinweise (Bänke, Frösche, Stocken) |
| **Emotion:** ein Moment bleibt | M/Ä | 10 | Mehrheit nennt spontan einen Moment | Feuer, Abend an Miras Feuer, Blick zu den Bergen, Katze |
| **Humor:** ein wiederkehrendes Element trägt | M | 9 | Mindestens ein Element wird von mehreren genannt | Elysias Übertreibung, Ziege, Kartoffel, „Ein Kompliment, legendär“ |
| **Desire:** „Ich möchte wissen, wie es weitergeht“ | M | 14, 15 | **Pflicht:** Mehrheit würde freiwillig weiterspielen und kann sagen, warum | der ganze Bogen, offenes Ende „Zum Meer.“ |

Zusätzlich gemessen: **Spielzeit** aus dem Log (Ziel 45–60 Minuten, geschätzt 30–50; KNOWN_ISSUES #43)
und **Hänger** (Frage 13): Wo brauchten Tester länger als drei Minuten oder die Hilfe?

**Lesart nach Bible §57:** Fehlt Desire, wird nicht einfach Content produziert, sondern der Slice
verbessert. Bestehen die M-Gates und wackeln nur die Ä-Gates, ist das eine Frage an Art und Ton, also
an Budget und Zeit, nicht an die Struktur.

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

Mit dem Zoom (ADR-043) ist weniger Welt im Bild (Tal: 78 Draw Calls). Berge und Kronen zeichnen nur
neu, wenn sie zu sehen sind.

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
| 51, 52 | Berge, Kronen, Zoom | zu hell, zu blass oder zu wenig Überblick |
| 53 | Shader-Kompilierung | ein kurzer Hänger beim ersten Betreten eines Ortes |

## Nächste mögliche Schritte

Nichts davon beginnt vor den Ergebnissen. Welcher Weg, entscheidest du nach der Auswertung.

| Ergebnis | Weg | Inhalt |
|---|---|---|
| Desire und die meisten M-Gates erfüllt | **Vorproduktion Full Production** | Budget- und Art-Entscheidung (handgepixelte Figuren, Tilesets, Musik), Writing-Pass mit den Playtest-Zeilen, Karten-Editor statt Textkarten, Content-Plan Akt I nach Bible §48 |
| Desire erfüllt, Ä-Gates schwach | **Art-Pass vor Full Production** | ein Ort (Tal) mit finaler Grafik und Ton als Prüfstein, dann erneuter Kurz-Playtest |
| Desire fehlt | **Slice verbessern** | die schwächsten Gates gezielt angehen (z. B. Mira, Übergang, Antreiber), erneuter Playtest |
| unabhängig davon | **Fehler aus dem Playtest** | Abstürze, Hänger, Texte; Spielzeit gegen 45–60 Minuten abgleichen |
