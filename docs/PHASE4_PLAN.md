# Phase 4 – Vertical Slice (Plan und Content-Brief)

Ziel (Game Bible §56, Master-Prompt §45): 45–60 Minuten am Stück spielbar, von „Neues Spiel“ bis
„Schwarz. Titel.“ Danach STOP und Playtest-Gate (Phase 5). Kein Inhalt über den Slice hinaus.

Freigabe: Der Projektinhaber hat am 06.10. die Arbeit an allem freigegeben („alles angehen und
weiterentwickeln“). Inhaltliche Entscheidungen, die hier getroffen werden, sind als Vorschlag markiert und
lassen sich ändern; jede größere steht als ADR in `DECISIONS.md`.

**Stand 06.10.: umgesetzt.** Alle sieben Beats sind spielbar und laufen per Autopilot am Stück
(`tools/autopilot/slice_full.json`, Hauptmenü bis Titelkarte). Abweichungen vom Plan:
- Der Antreiber-Ort heißt `weg` (die Grey-Box `antreiber` bleibt Prototyp, ADR-038).
- Mira legt nach ihrem Besuch Bretter über die Brücke; danach führt der kurze Weg zu ihrem Lager.
- Den Fisch für die Katze bringt Mira mit („Ich hab Fisch. Du hast Feuer.“).
- Kind und Riss hängen am Beginn der Wiederholungen, nicht an der Truhe: niemand bleibt in Elysia hängen.
- Über den Bach geht es erst nach Miras Nein (eine Erzählzeile am Ufer zeigt auf sie), und solange das
  Feuer brennt, Mira aber noch nicht da war, bleibt die Haustür zu: Beide Kernmomente lassen sich nicht
  verpassen.
Testanleitung: `PLAYTEST_PHASE4.md`.

## Ablauf und Orte

| Beat | Minuten | Ort (Szene) | Inhalt |
|------|---------|-------------|--------|
| 0 | 0–1 | Startmenü „Elysia“ | „Neues Spiel“: Name wählen (Vorschläge oder tippen), eine von drei makellosen Varianten |
| 1 | 1–10 | Elysia (`elysia`) | Erwachen auf perfektem Rasen, Begrüßung, Lob. Miniquest „Die goldenen Schmetterlinge“, Truhe am Baum, XP, Gold, Beute, zwei Level-ups. Humor: Beute „Ein Kompliment“ (legendär), ein Elysianer bewundert, wie du Türen öffnest. Der Gastwirt (Betäuber-Cameo) bietet Essen, Musik und Ruhe an. |
| 2 | 10–18 | Elysia | Elysianer wiederholen sich wortgleich, gespiegelt. Das Becken spiegelt alles außer dir. Der Stein am Rand („Seltenheit: —“). Das Kind: anders gekleidet, lobt nicht, hat ein Spiegelbild. Es führt zum versteckten Riss. Nach Zeit hilft ein Summen. |
| 3 | 18–25 | Riss → Tal (`tal`) | Übergang (vorhanden): HUD zerfällt, Bandstopp, Stille, Schwarz, Regen. Mira am Bach mit eigener Arbeit. **Erstes Nein:** Er bittet um Unterschlupf, sie lehnt ab, zeigt aber auf das leere Haus. |
| 4 | 25–35 | Tal | Erkunden im Regen. **Umweltpuzzle:** Der Weg zum Haus führt über den Bach; Trittsteine (manche kippeln, man fällt ins Wasser) oder der lange Weg über den umgestürzten Baum. **Mira widerspricht** (Wahl mit Folge). Das leere, kalte Haus. |
| 5 | 35–45 | Antreiber (`antreiber`) | Für Feuer braucht es trockenes Holz aus dem Schuppen am Ende des Weges. Der Antreiber „hilft“: Der Weg endet nicht, bis man stehen bleibt. Danach liegt das Holz direkt neben einem. |
| 6 | 45–52 | Haus (`haus`) | Feuer machen, Ruhe, Musik kehrt leise zurück. Mira klopft (nass), wärmt sich, Gespräch. Kuriosität ins Regal stellen („Sehr kleiner Löffel“). Die Katze draußen am Fenster, man kann sie füttern. |
| 7 | 52–60 | Tal am Abend | **Humor-Sidequest „Die Ziege“:** Eine Ziege hat Miras Stiefel. Sie tauscht ihn nur gegen die Kartoffel (bemerkenswert durchschnittlich). Danach Abend an Miras Feuer: „Morgen gehe ich weiter.“ / „Wohin?“ / Blick zu den Bergen / „Zum Meer.“ Schwarz. Titel „Nach Elysia“. Ende des Prototyps. |

## Szenen und Übergänge

- `elysia`: Elysias Garten, aufgebaut auf der Look-Karte, mit Gasthaus-Pavillon, Kind, Schmetterlingen,
  Stein, verstecktem Riss. Spiegelsymmetrisch (ADR-031).
- `tal`: das Tal aus dem Feedback-Umbau, mit Miras Lager am Bach, Trittsteinen, umgestürztem Baum,
  dem leeren Haus, Schuppenpfad (Eingang zum Antreiber) und der Ziege.
- `haus`: Innenraum des Hauses (Kamin, Tisch, Bett, Regal mit Kuriositäten-Platz, Fenster, Tür).
- `antreiber`: der vorhandene Encounter; am Ende liegt das trockene Holz neben dem Spieler, ein Pfad
  führt zurück ins Tal.
- Türen und Kartenausgänge: Requisit `door` mit `{"target": "<szene>", "spawn": "<marker>"}`.
  Die Zielszene setzt den Spieler auf den Marker `spawn_<name>`.

## Zustände (Flags, Quests, Items)

| ID | Art | Bedeutung |
|----|-----|-----------|
| `main_elysia_hero` | Quest | „Der Held von Elysia“: alles gelingt (Stufen: begrüßt → Schmetterlinge → gefeiert) |
| `side_elysia_butterflies` | Quest | Miniquest der drei goldenen Schmetterlinge |
| `main_valley_shelter` | Quest | „Ein Dach“: Unterschlupf finden → Haus → Holz → Feuer |
| `side_valley_goat` | Quest | „Der Stiefel“: Ziege, Kartoffel, Tausch |
| `item_dry_wood`, `item_potato`, `item_boot`, `curiosity_tiny_spoon` | Items | Holz, Kartoffel, Miras Stiefel, Kuriosität |
| `elysia.*`, `valley.*`, `house.*` | Flags | Beats und einmalige Ereignisse |
| `mira` | Beziehung | stranger → cautious (Nein) → familiar (Feuer); Erinnerungen aus den Wahlen |

## Neue Bausteine

- Namenswahl beim neuen Spiel; der Name steht in Dialogen (`{{WorldState.player_name()}}`).
- `door`, `inspect` (Requisit mit Dialog), Kamin, Kuriositäten-Regal, Trittstein, Katze, Ziege,
  Kind, goldener Schmetterling.
- Szenen-Skripte je Ort für die Beats (`world/levels/slice/*.gd`), Endsequenz mit Titelkarte.
- Zeitstempel je Beat im Log (Dev-Builds), damit der Playtest die Minuten belegt.

## Schreibregeln (Bible §55–59)

- Elysianer zuerst sympathisch, nicht creepy; das Unbehagen entsteht nur aus Wiederholung.
- Mira: pragmatisch, trocken, warm ohne Sentimentalität, eigene Ziele; nie Mentorin oder Belohnung.
- Protagonist: anfangs reagierend, später eigener; „…“ ist eine echte Antwort.
- Keine Therapiesprache, keine Erklärung der Metapher. Menschen reden auch über Wetter und Essen.
- Jede Wahl hat eine wahrnehmbare Folge (ContentValidator, keine Fake Choices).

## Vertiefen, falls zu kurz

Geschätzt dauert der Slice beim ersten Spielen 20–30 statt 45–60 Minuten (KNOWN_ISSUES #43). Nach dem
Bible-Abgleich vom 06.10. ist ein erster Teil umgesetzt (ADR-040): Elysianer sagen zu allem Ja, das Kind
summt das spätere Hauptmotiv, Mira hat einen Tagesablauf und sitzt abends am Feuer, im Tal gibt es mehr
zu riechen, schmecken und entdecken, der Antreiber zeigt sein Warum, am Feuer gibt es einen ruhigen
Moment, die Ziege steht am Ende auf dem Holzstapel. Weitere Ideen, ohne neue Systeme, entscheidet der
Playtest:
- Elysia (0–18): ein Händler, der dir alles schenkt (mit Spiegelzwilling), eine zweite mühelose Aufgabe
  mit noch größerer Belohnung, mehr Elysianer mit eigenen wortgleichen Schleifen.
- Tal (25–35): mehr Stellen zum Ansehen (Zaun, Wegweiser, Miras Lager), ein zweites kurzes Gespräch mit
  Mira über Wetter und Essen, der Bach mit einer zweiten Stelle zum Ausprobieren.
- Antreiber (35–45): mehr Zurufe, Wegstücke mit wechselnden Dingen am Rand, ein spürbarer Verlauf bis zur
  Lösung; die Bible gibt dem Beat zehn Minuten.
- Haus (45–52): mehr zum Ansehen, ein ruhiger Moment am Feuer (sich setzen, Musik, Zeit vergeht).
- Abend (52–60): die Ziege läuft ein paarmal davon, mehr Zeilen an Miras Feuer vor dem Ende.

## Kürzen, falls nötig (Cut-First, Master-Prompt §49)

Zuerst: Varianten bei der Namenswahl, Katze füttern, zweite Puzzle-Lösung, Gastwirt, Länge der
Ziegen-Quest. Nie: Elysia/Wirklichkeit-Kontrast, Miras Nein, Haus mit Feuer, Antreiber, Riss, Abend-Ende.
