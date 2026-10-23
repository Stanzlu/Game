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

Im Startmenü: **Neues Spiel** → Namen wählen (tippen oder einen Vorschlag nehmen) → los. Unter
**Mitwirkende** steht, wer das Spiel gemacht hat und welche Lizenzen darin stecken. Die Tasten für
dein Gerät stehen als Zeile am unteren Rand des Startbilds.

## Steuerung

Tastatur und Controller funktionieren gleichermaßen. Die Tabelle zeigt die Standardbelegung; sie
lässt sich im Spiel ändern (siehe unten).

| Aktion | Tastatur | Controller |
|--------|----------|------------|
| Gehen | WASD oder Pfeiltasten | linker Stick oder Steuerkreuz |
| Rennen | Shift halten | X / Quadrat oder rechter Trigger |
| Ansehen, Sprechen, Bestätigen | E, Leertaste oder Enter | A / Kreuz |
| Zurück | Esc oder Backspace | B / Kreis |
| Pause-Menü (Speichern, Einstellungen) | Esc oder Tab | Start |
| Journal | J | Back / Select |
| Lange Journal-Einträge blättern | Bild auf / Bild ab | rechter Stick |
| Gespräch schnell durchblättern | Bestätigen halten (hält an Antworten an) | Bestätigen halten |

Im Gespräch bringt Bestätigen den Text weiter, ein Linksklick auf die Textbox ebenfalls; gedrücktes
Bestätigen blättert schnell weiter und hält an Antworten an.

**Tasten umbelegen:** Im **Pause-Menü** („Tastenbelegung“) oder unter **Einstellungen → Steuerung →
Tastenbelegung** (auch vom Startmenü aus) steht jede Aktion mit zwei Feldern für die Tastatur und für
den Controller. Mit Links / Rechts ein Feld wählen, mit Enter, Leertaste, E oder A drücken und dann die
neue Taste (oder den neuen Knopf) drücken; Entf oder Y leert das Feld (auch während man auf die neue
Taste wartet). Gehört die Taste schon einer anderen Aktion, fragt das Spiel, ob getauscht oder die Taste
hier verwendet werden soll, oder erklärt, warum beides nicht geht. Enter, Esc, Start und A (am
Controller) bleiben immer belegt, damit niemand sich aussperren kann; Pfeile, WASD und das Steuerkreuz bewegen in Menüs immer
den Cursor und gehören nur dem Gehen; am Controller gehen immer Stick und Steuerkreuz. „Weitere Tasten“
zeigt, was fest ist. **Alles auf Standard** holt die ursprüngliche Belegung zurück.

Notausgang, falls doch etwas hakt: im Spiel Esc (oder Start), „Tastenbelegung“, „Alles auf Standard“; ist
das Spiel gar nicht mehr zu bedienen, in der Datei `settings.json` den Block `input` löschen und neu
starten (Windows: `%APPDATA%\REAL\settings.json`, macOS:
`~/Library/Application Support/REAL/settings.json`, Linux: `~/.local/share/REAL/settings.json`; die Datei
liegt neben dem Ordner `saves`, nicht darin). Eine Datei, die das Spiel nicht lesen konnte, bleibt als
`settings.json.bad` daneben liegen.

## Während du spielst

- **Mitschreiben ist nicht nötig.** Das Spiel notiert im Log, wann du welchen Abschnitt erreichst.
- **Speichern:** über das Pause-Menü; das Spiel speichert auch selbst (an jedem Abschnitt und wenn du
  das Fenster schließt). Die Slots zeigen Name, Ort, Spielminuten und Datum. Im Startmenü geht es mit
  **Fortsetzen** weiter. Verliert das Fenster den Fokus (Alt+Tab), pausiert das Spiel.
- **Einstellungen**, die helfen können:
  - Ton: sechs Regler (Gesamt, Musik, Umgebung, Effekte, Menüs, Stimmen); bei „Effekte“ und „Stimmen“
    hörst du beim Ändern einen Probeklang
  - Textgeschwindigkeit und „Automatisch weiter“
  - „Große Schrift“
  - „Geräusche als Text“: wichtige Geräusche erscheinen als Zeile am unteren Rand
  - „Bildschirmwackeln“ und „Blitzeffekte reduzieren“ (dann entfallen auch die Bewegungseffekte im
    Dialogtext)
  - „Tiefenebenen bewegen sich mit“ (aus, wenn dir Bewegung im Hintergrund unangenehm ist)
  - „Mehr Zeit lassen“ und „Begegnungstempo“ für mehr Geduld
  - „Kamera“ (Weich oder Pixelgenau): Probier gern beide aus und sag uns, welche dir besser gefällt
- **Wenn du feststeckst:** Versuch es erst ein paar Minuten selbst. Hilft das nicht, steht unten unter
  „Hilfe“ ein Hinweis für jede Stelle.
- **macOS, ruckelt es von Anfang an, besonders in Elysia?** Schalte unter **Einstellungen → Anzeige →
  Bildsynchronisierung (VSync)** aus (bei „VSync bremst“ im Leistungstest gibt es dafür einen Knopf).
  Läuft es danach flüssig, schreib uns das bitte, mit dem Bericht `benchmark.txt`.
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

Zusätzlich (keine Gate-Fragen):
- Hast du die Einstellung „Kamera“ probiert? Weich oder Pixelgenau, was fühlte sich besser an?
- War im Ton etwas zu laut, zu leise oder zu dicht (der Bach, die Belohnungen in Elysia, der Abend)?
- macOS: Hast du das Vollbild benutzt? Blieb ein schwarzer Rand?
- Hast du Tasten umbelegt? Was fehlte oder war unklar? (Auf dem Mac: Fn+Löschen leert ein Feld, stimmt die Beschriftung deiner Tasten?)

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
etwas am rechten unteren Inselrand; ein fernes Grollen kündigt es an.
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

Erst ein gutes Stück mitgehen, ruhig auch rennen. Wer rennt, kommt trotzdem nicht an. Was tut man, wenn
ein Weg nicht endet? Sobald es stimmt, hört die Musik auf.
</details>

<details>
<summary>Das Feuer</summary>

Das Holz legst du am Kamin ab. Wenn es brennt, setz dich auf den Teppich davor.
</details>

<details>
<summary>Die Ziege</summary>

Sie ist bestechlich. Im Gemüsebeet am Haus.
</details>

---

Für den Projektinhaber: Detailfragen zu einzelnen Szenen stehen in `PLAYTEST_PHASE4.md`, die Auswertung
nach den Gates der Bible in `GATE_REPORT.md`.
