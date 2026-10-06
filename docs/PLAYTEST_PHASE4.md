# Playtest Phase 4 — der Vertical Slice am Stück

Ziel (Game Bible §56, Master-Prompt §45): Trägt der Bogen von Elysia bis zu Miras Feuer? Ist der
Kontrast spürbar, ist Mira glaubwürdig, ist der Antreiber verständlich, wie lange dauert es? Danach
entscheiden wir gemeinsam, was bleibt, was geht und was als Nächstes kommt (Phase 5: Playtest-Gate).

Grafik, Musik und Klänge sind selbst erzeugte Platzhalter, die Texte sind Entwürfe. Plane 45–60
Minuten ein, bitte mit Ton und ohne Eile. Spiel einfach; die Fragen unten erst danach.

## Start

Startmenü → **Neues Spiel** → Namen wählen (tippen oder einen Vorschlag nehmen) → **Das Abenteuer
beginnt**. Du kannst jederzeit über das Pause-Menü speichern und später mit **Fortsetzen** weiterspielen.

Wer einzelne Orte ansehen will (ohne den Rest): `--start=elysia`, `--start=tal`, `--start=haus`,
`--start=weg`. Für den richtigen Eindruck bitte am Stück spielen.

## Was dich erwartet (ohne Lösungen)

1. **Elysia.** Du wachst auf, alle freuen sich. Die Gärtnerin hat eine Aufgabe für dich. Alles gelingt.
2. **Elysia, später.** Achte auf Wiederholungen, auf das Wasser, auf das, was keinen Zwilling hat.
3. **Der Riss und das Tal.** Regen. Eine Frau am Bach, die mit etwas anderem beschäftigt ist.
4. **Das Tal.** Ein Haus auf der anderen Seite des Bachs. Die Brücke ist kaputt.
5. **Der Weg zum Schuppen.** Jemand hilft dir. Sehr.
6. **Das Haus.** Feuer.
7. **Der Abend.** Eine Ziege. Ein Stiefel. Miras Feuer.

## Wenn du feststeckst

- **Elysia:** Sprich das Kind am Becken an und folge ihm. Wer nichts tut, dem öffnet sich der Riss nach
  einiger Zeit von selbst (rechts unten am Inselrand).
- **Bach:** Erst mit der Frau am Feuer sprechen. Die flachen, bemoosten Steine halten, die runden,
  nassen kippen. Weiter oben liegt ein umgestürzter Baum über dem Bach.
- **Holz:** Der Zettel am Kamin. Der Pfad nach Westen öffnet sich erst danach.
- **Der Weg:** Wer rennt, kommt nicht an. Was tut man, wenn ein Weg nicht endet?
- **Feuer:** Wenn es brennt, setz dich auf den Teppich davor.
- **Die Ziege:** Sie ist bestechlich. Im Gemüsebeet am Haus.

## Fragen

Kurze Antworten genügen; Stichworte oder Sprachnachricht sind völlig in Ordnung.

**Gesamtbogen**
- Wann hast du gemerkt, dass mit Elysia etwas nicht stimmt? Woran?
- Hat dich der Übertritt ins Tal berührt, irritiert, gelangweilt?
- Wo wolltest du schneller weiter, wo länger bleiben?
- Wie lange hast du gebraucht (grob)? Das Log zeigt es auch genau (siehe unten).

**Elysia**
- Waren die Elysianer am Anfang sympathisch oder gleich unheimlich?
- Waren die Belohnungen (Level-ups, „Ewiger Ruhm“, das Kompliment) witzig oder zu viel?
- Ist dir das Becken aufgefallen? Das Kind?

**Mira**
- Wirkt ihr „Nein“ ehrlich oder unfreundlich? Hast du in Elysia jemanden gebeten, Nein zu sagen?
- Fühlt sie sich lebendig an (sie geht zwischen Netz, Feuer und Bach hin und her)?
- Ist sie eine eigene Person mit eigenen Zielen, oder eine Funktion der Geschichte?
- Hat sie sich an deine Antworten erinnert (Bach, Steine)? Wie fühlte sich das an?

**Rätsel und Antreiber**
- Waren die Trittsteine lesbar (welche halten, welche kippen)? War das Hineinfallen eher lustig oder
  frustrierend?
- Antreiber: verständlich oder zufällig? Wann hast du begriffen, was zu tun ist?

**Haus und Abend**
- Hat das Feuer etwas verändert (Bild, Ton, Gefühl)? Hast du dich davor gesetzt?
- Die Ziege: Humor angekommen?
- Das Ende („Zum Meer.“): zu abrupt, genau richtig, zu lang?
- Das Gespräch an Miras Feuer: Fühlte es sich an, als würde sie sich an deinen Tag erinnern, oder
  wie eine Abfrage? Hast du ihr gesagt, dass du nicht über Elysia reden willst, und wie war ihre
  Antwort für dich?
- Hast du am Abend die Pfütze am Lager angesehen?
- Der Antreiber im Haus: Bist du sitzen geblieben oder aufgestanden? Wirkte er wie jemand, den nur
  du siehst? Wo lag die Katze am Ende?
- Hast du der Katze einen Namen gegeben? Welchen?

**Die Wirklichkeit**
- Hast du Dinge angesehen, gerochen, probiert (Blumen, Beeren, Muschel)? Wirkte das Tal dadurch echter?
- Ist dir das Summen des Kindes aufgefallen, und hast du die Melodie später wiedererkannt?
- Bist du irgendwo am Bach eine Weile still gestanden? Ist dir aufgefallen, was dann passiert?
- Das Journal in der Wirklichkeit (Taste J): Wie liest sich der Teil „Menschen“?

**Elysia (zweite Aufgabe)**
- Der stille Brunnen erledigt sich, bevor du ankommst. Witzig, irritierend, oder hast du es kaum bemerkt?

**Technik**
- Ruckler, Hänger, Stellen, an denen du nicht weiterkamst?
- Texte, die falsch klingen oder zu lang sind?
- Klänge, die stören (Katze, Ziege, Tür, Wasser)?

## Das Log mit den Minuten

Das Spiel schreibt bei jedem Beat eine Zeile mit Spielminute ins Log (`beat`, zum Beispiel
`{"beat":"first_no","minute":21.5}`). Auf dem Mac liegt es unter
`~/Library/Application Support/REAL/logs/godot.log`. Schick mir die Datei nach dem Spielen;
dann sehe ich, wie lange jeder Teil gedauert hat, ohne dass du mitschreiben musst.

| Beat im Log | Bedeutung |
|-------------|-----------|
| `elysia_start` | Erwachen |
| `butterflies_caught` | alle drei Schmetterlinge |
| `irritation` | Truhe geöffnet, Elysia wiederholt sich |
| `mirror`, `child` | Becken angesehen, Kind getroffen |
| `rift_found` | der Riss öffnet sich |
| `valley_arrival` | Ankunft im Tal |
| `first_no` | Miras Nein |
| `crossed` | über den Bach |
| `house_entered` | im Haus |
| `shed_path`, `wood` | Weg zum Schuppen, Holz |
| `fire`, `mira_visit` | Feuer, Miras Besuch |
| `evening` | Abend im Tal |
| `ending` | an Miras Feuer |

## Einstellungen, die hier wirken

- „Automatisch weiter“ und „Textgeschwindigkeit“: wenn dir das Lesen zu langsam oder zu schnell ist.
- „Große Schrift“, „Bildschirmwackeln“, „Blitzeffekte reduzieren“ wie in Phase 3.
- „Zeitfenster“ und „Begegnungstempo“ machen den Antreiber geduldiger.
