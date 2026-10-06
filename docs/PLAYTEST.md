# Playtest: Nach Elysia (Vertical Slice)

Danke, dass du testest! Du spielst die erste Stunde eines erzählerischen Pixel-Art-Rollenspiels
(Arbeitstitel REAL, im Spiel „Nach Elysia“). Wir wollen herausfinden, ob die Geschichte und das
Spielgefühl tragen, bevor das ganze Spiel entsteht.

**Bitte vorher wissen:**
- **Platzhalter:** Grafik, Musik und Klänge sind selbst erzeugte Platzhalter, die Texte Entwürfe.
  Achte bitte auf Gefühl, Geschichte und Spielbarkeit, nicht auf den Feinschliff.
- **Rahmen:** Plane **45–60 Minuten** ein, mit **Ton** (Kopfhörer sind ideal), am Stück und ohne Eile.
- **Keine Vorbereitung:** Lies vor dem Spielen nichts weiter als diesen Abschnitt und „Herunterladen
  und starten“. Die Fragen erst danach.

## Herunterladen und starten

Den Link zum Build bekommst du vom Projektinhaber (GitHub-Release „Playtest v…“). Lade die Datei für
dein System und entpacke sie. Die Builds sind nicht signiert, deshalb warnt dein System beim ersten
Start. Das ist bei kleinen Projekten normal.

| System | Datei | Start |
|--------|-------|-------|
| Windows | `REAL-v…-windows.zip` | `REAL.exe` starten. Bei „Der Computer wurde durch Windows geschützt“: **Weitere Informationen** → **Trotzdem ausführen**. |
| macOS | `REAL-v…-macos.zip` | Entpacken, `REAL.app` öffnen. Wenn macOS blockiert: **Systemeinstellungen → Datenschutz & Sicherheit → Dennoch öffnen**. Alternativ im Terminal: `xattr -dr com.apple.quarantine REAL.app` |
| Linux | `REAL-v…-linux.zip` | `REAL.x86_64` ausführen (bei Bedarf `chmod +x REAL.x86_64`). |

Im Startmenü: **Neues Spiel** → Namen wählen (tippen oder einen Vorschlag nehmen) → los.

## Steuerung

Tastatur und Controller funktionieren gleichermaßen.

| Aktion | Tastatur | Controller |
|--------|----------|------------|
| Gehen | WASD oder Pfeiltasten | linker Stick oder Steuerkreuz |
| Rennen | Shift halten | X / Viereck oder rechter Trigger |
| Ansehen, sprechen, bestätigen | E, Leertaste oder Enter | A / Kreuz |
| Zurück | Esc oder Rücktaste | B / Kreis |
| Pause-Menü (Speichern, Einstellungen) | Esc oder Tab | Start |
| Journal | J | Back / Select |

## Während du spielst

- **Mitschreiben ist nicht nötig.** Das Spiel notiert im Log, wann du welchen Abschnitt erreichst.
- **Speichern:** über das Pause-Menü; das Spiel speichert auch selbst. Im Startmenü geht es mit
  **Fortsetzen** weiter.
- **Einstellungen**, die helfen können:
  - Textgeschwindigkeit und „Automatisch weiter“
  - große Schrift
  - Bildschirmwackeln und Blitzeffekte reduzieren
  - „Tiefenebenen bewegen sich mit“ (aus, wenn dir Bewegung im Hintergrund unangenehm ist)
  - „Zeitfenster“ und „Begegnungstempo“ für mehr Geduld
- **Wenn du feststeckst:** Versuch es erst ein paar Minuten selbst. Hilft das nicht, steht unten unter
  „Hilfe“ ein Hinweis für jede Stelle.
- **macOS, ruckelt es mit genau 30 Bildern pro Sekunde?** Das ist meistens der Stromsparmodus im
  Vollbild. Netzteil anschließen oder unter **Einstellungen → Anzeige → Bildsynchronisierung (VSync)**
  ausschalten.

## Danach: Fragen

Bitte gleich nach dem Spielen beantworten, kurz und spontan. Es gibt keine falschen Antworten;
Stichworte oder eine Sprachnachricht reichen. Ehrliche Kritik hilft am meisten.

1. Was glaubst du, ist Elysia?
2. Wann hast du zum ersten Mal bemerkt, dass etwas nicht stimmt? Woran?
3. Wie hast du dich gefühlt, als die XP-Leiste verschwunden ist?
4. Was hältst du von Mira?
5. Was glaubst du, möchte sie?
6. Warum glaubst du, wiederholen sich die Leute in Elysia?
7. Wie hast du den Weg zum Schuppen geschafft? War die Lösung verständlich oder zufällig?
8. Wie hat sich das Laufen angefühlt (Tempo, Rennen, Steuerung)?
9. Hast du irgendwo gelacht oder geschmunzelt? Wo?
10. Welcher Moment ist dir am stärksten im Gedächtnis geblieben?
11. Gab es einen langweiligen Abschnitt? Fühlte sich etwas zu langsam an?
12. Wurde etwas zu offensichtlich erklärt?
13. Wo bist du hängen geblieben, und wie lange?
14. Was möchtest du als Nächstes sehen?
15. Würdest du freiwillig weiterspielen? Warum (nicht)?

Technik: Gab es Abstürze, Ruckler, Fehler im Bild oder Texte, die abgeschnitten waren?

## Was du zurückschickst

1. Deine Antworten.
2. Die **Log-Datei** `godot.log`. Hast du das Spiel mehrmals gestartet, schick bitte auch die
   älteren Logs mit Datum im Namen aus demselben Ordner:
   - Windows: `%APPDATA%\REAL\logs\` (in die Adresszeile des Explorers einfügen)
   - macOS: `~/Library/Application Support/REAL/logs/` (im Finder: **Gehe zu → Gehe zum Ordner**)
   - Linux: `~/.local/share/REAL/logs/`

Das Log enthält deine Spielzeiten je Abschnitt, die Version des Builds und technische Meldungen, keine
persönlichen Daten.

## Hilfe

Nur lesen, wenn du feststeckst. Jeder Punkt verrät ein wenig.

<details>
<summary>Elysia: Wie geht es weiter?</summary>

Sprich das Kind am Becken an und folge ihm. Wer nichts tut, dem öffnet sich nach einiger Zeit von selbst
etwas am rechten unteren Inselrand.
</details>

<details>
<summary>Der Bach</summary>

Erst mit der Frau am Feuer sprechen. Die flachen, bemoosten Steine halten, die runden, nassen kippen.
Weiter oben liegt ein umgestürzter Baum.
</details>

<details>
<summary>Holz</summary>

Der Zettel am Kamin. Der Pfad nach Westen öffnet sich erst danach.
</details>

<details>
<summary>Der Weg, der nicht endet</summary>

Wer rennt, kommt nicht an. Was tut man, wenn ein Weg nicht endet?
</details>

<details>
<summary>Das Feuer</summary>

Wenn es brennt, setz dich auf den Teppich davor.
</details>

<details>
<summary>Die Ziege</summary>

Sie ist bestechlich. Im Gemüsebeet am Haus.
</details>

---

Für den Projektinhaber: Detailfragen zu einzelnen Szenen stehen in `PLAYTEST_PHASE4.md`, die Auswertung
nach den Gates der Bible in `GATE_REPORT.md`.
