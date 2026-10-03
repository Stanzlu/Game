# Playtest Phase 2 — Systeme

Ziel: Tragen Zustand, Dialog, Quests, Journal und Speichern? Funktionieren alle Menüs mit Tastatur und
Controller? Texte und Grafik sind Platzhalter. Bitte achte auf Bedienung und Verlässlichkeit, nicht auf
Inhalt. Etwa 15 Minuten.

## Steuerung

| Aktion | Tastatur | Controller |
|--------|----------|------------|
| Bewegen | WASD oder Pfeiltasten | linker Stick oder Steuerkreuz |
| Sprinten | Shift | X / Viereck oder rechter Trigger |
| Interagieren, bestätigen | E, Leertaste oder Enter | A / Kreuz |
| Zurück | Esc oder Rücktaste | B / Kreis |
| Pause-Menü | Esc oder Tab | Start |
| Journal | J | Back / Select |
| Wert ändern (Einstellungen) | Links / Rechts | Steuerkreuz links / rechts |

## Teil 1: Sandbox-Quest (ca. 5 Minuten)

Startmenü → **Bewegungs-Sandbox**.

1. Lies das Schild „Garten“ (rechts unter der Straße). Öffne danach das Journal (J). Steht dort „Das
   Gartentor“?
2. Zieh den Hebel südöstlich davon und geh durchs Tor in den Garten.
3. Öffne das Journal noch einmal. Ist die Quest unter „Abgeschlossen“ und zeigt sie alle drei Einträge?
4. Pause-Menü → **Speichern** → Slot 1. Geh ein Stück weg, dann Pause-Menü → **Laden** → Slot 1.
   Stehst du wieder am alten Ort? Ist das Tor noch offen?
5. Pause-Menü → **Zum Startmenü** → **Fortsetzen**. Landest du am zuletzt gespeicherten Ort?

## Teil 2: Mira im Tal (ca. 5 Minuten)

Startmenü → **Look: Tal im Regen**. Mira steht vor dem Haus.

1. Sprich sie an (E bzw. A). Wähle eine Antwort mit Hoch/Runter.
2. Sprich sie ein zweites Mal an. Reagiert sie anders, je nachdem, was du geantwortet hast?
3. Versuch während des Gesprächs das Pause-Menü (Esc) oder das Journal (J) zu öffnen. Beides sollte
   gesperrt sein, bis das Gespräch vorbei ist.

## Teil 3: Einstellungen (ca. 3 Minuten)

Pause-Menü → **Einstellungen**. Bitte mit Tastatur und, falls vorhanden, mit Controller.

- Ändere Lautstärken. Hörst du den Unterschied (Regen = „Umgebung“, Schritte = „Effekte“)?
- **Textgeschwindigkeit**, **Automatisch weiter** und **Große Dialogschrift** ausprobieren und mit Mira
  reden.
- **Vollbild** an und aus.
- Spiel beenden und neu starten. Sind die Einstellungen noch da?

## Teil 4: Antreiber (ca. 2 Minuten)

Startmenü → **Antreiber-Prototyp**. Pause-Menü öffnen: **Speichern** ist hier ausgegraut, mit Hinweis.
Unter **Einstellungen → Barrierefreiheit** gibt es jetzt „Zeitfenster“ und „Begegnungstempo“.

## Fragen

- Gab es eine Stelle, an der du nicht wusstest, wie es weitergeht oder wie du zurückkommst?
- Hat Laden oder Fortsetzen dich an einen Ort gesetzt, den du nicht erwartet hast?
- Ist das Journal verständlich? Fehlt dir dort etwas?
- Sind die Menüs mit dem Controller vollständig bedienbar?
- Ist dir ein Text aufgefallen, der zu klein oder schlecht lesbar ist?

## Für Entwickler

Debug-Builds haben ein Entwicklungs-Panel (F4) mit Zustandsanzeige, Schnellspeichern in einen eigenen
Debug-Slot, Quest- und Beziehungsabkürzungen und „Inhalte prüfen“. Im Release-Build ist es nicht aktiv.
