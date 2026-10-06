# Analyse: der Slice im Abgleich mit vier Referenzspielen

Stand 06.10. · Entscheidung: ADR-042 · Grundlage: Game Bible, alle Slice-Dialoge, Spielsysteme.

Maßstab des Projektinhabers:

- **Explorers of Sky:** emotionale, erzählerische und systemische Tiefe.
- **HeartGold/SoulSilver:** Reisegefühl, Atmosphäre, Bindung, Weltinteraktion.
- **Black/White:** klare Identität, Fokus, thematische Geschlossenheit.
- **Black 2/White 2:** Spieldichte, Vielfalt, Progression, Feinschliff.

Jede Änderung musste vier Fragen bestehen:

1. Verstärkt sie die Kernfantasie?
2. Erzeugt sie echte Entscheidungen?
3. Vertieft sie Bestehendes, statt neue Komplexität aufzusetzen?
4. Bleibt das Spiel intuitiv und unverkennbar es selbst?

Die Suchtmetapher bleibt dabei ungenannter Subtext (§3.2, §4). Siehe ADR-042.

## Befund

**Schon auf Referenzniveau**

- **Geschlossenheit (Black/White):** Elysia und die Wirklichkeit spiegeln sich gegenseitig:
  - geruchlose Blume gegen Wildblume
  - geschmacklose Suppe gegen Brombeeren
  - Elysianer, die nicht Nein sagen können, gegen Miras Nein
  - beim Übertritt verschwinden die Zahlen
- **Progression (Black 2/White 2):** Jeder Abschnitt bringt ein neues Verb: fangen, fallen, stehen bleiben, Feuer machen, sitzen, tauschen.
- **Atmosphäre (HeartGold/SoulSilver):** Die Tageszeiten verändern das Tal. Miras Lager verändert sich zwischen den Besuchen, und das Haus leuchtet, sobald das Feuer brennt.

**Lücken**

| Lücke | Beleg | Vorbild |
|---|---|---|
| Entscheidungen verpuffen | 23 Erinnerungen an Mira geschrieben, nur 3 wieder gelesen | Explorers of Sky: der Partner erinnert sich |
| Der Protagonist sagt nie selbst Nein | nur Mira und Elysianer | Bible §16, §17: Grenzen I/II |
| Die fehlende Spiegelung hat keine Auflösung | Spiegelung im Tal technisch da, aber nirgends gezeigt | Black/White: jedes Motiv schließt sich |
| Die Lösung des Antreibers kommt aus dem Nichts | Stehenbleiben vorher nie erfahrbar | Bible §46 |
| Stein und Samen sind unsichtbar | nach dem Übertritt ohne jeden Auftritt | Explorers of Sky: der Relikt-Splitter |
| Zu kurz | geschätzt 25–38 statt 45–60 Minuten | Black 2/White 2: Dichte statt Länge |

## Umgesetzt (ADR-042)

| Paket | Inhalt | Vorbild |
|---|---|---|
| Echo | Abendgespräch an Miras Feuer aus den Erinnerungen des Tages; eigenes Nein („Darüber will ich nicht reden.“ – „Gut.“); „Manchmal fehlt es mir.“ – „Klar.“; Muschel und „Zum Meer?“; das erste Spiegelbild in der Pfütze; der Stein im Regal; Echos (Fisch schmeckt nach etwas, die Suppe im kalten Haus) | Explorers of Sky, Black/White |
| Innehalten | Frösche kommen und quaken, wenn man still steht; der Antreiber geht hinter dir zurück und setzt sich an den Weg; am Kamin setzt er sich dazu, wenn du sitzen bleibst, und die Katze schläft auf ihm | HeartGold/SoulSilver, Bible §3.3, §28 |
| Bindung | Die Katze bekommt einen Namen, Mira fragt danach; das Journal der Wirklichkeit liest sich als Tagebuch, mit „Menschen“ statt Werten | HeartGold/SoulSilver (Spitznamen), Bible §23 |
| Elysia-Dichte | Die zweite Aufgabe löst sich unterwegs selbst, +10.000 XP | Black 2/White 2, Bible §8, §10 |

## Bewusst verworfen

- Sammel- und Prozentanzeigen, Medaillen und Erfolge: Das ist Elysias Logik, nicht die der Wirklichkeit.
- Tägliche oder wöchentliche Ereignisse: widersprechen der Retention-Ethik (§52).
- Persönlichkeitsquiz zu Beginn: Psychologie gleich am Anfang ist Therapie-Gefahr, und Werte kommen laut Bible erst später (§18).
- Mira als ständige Begleiterin: Sie braucht den Protagonisten nicht (§13).
- Mehr Nebenquests oder Hausbau: Content-Budget (§48), §4.
- Den Samen schon pflanzen: Die Entscheidung gehört ins Finale (§30).

## Für den Playtest

- **Elysias erste Minuten:** Wirken sie attraktiv oder schon zu ironisch (Risiko 9)?
- **Frösche:** Merkt man ohne jeden Hinweis, dass sie kommen, wenn man still steht?
- **Antreiber im Haus:** Wirkt er wie jemand, den nur du siehst? Mira spricht ihn nie an.
- **Abendgespräch:** Fühlt es sich an, als würde sie sich erinnern, oder wie eine Abfrage?
