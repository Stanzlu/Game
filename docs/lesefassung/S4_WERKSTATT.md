# S4 Werkstatt (Akt IV)

<!-- Erzeugt mit `python3 tools/writing/readable.py`. Nicht von Hand ändern: Änderungen gehören in die .dialogue-Dateien. -->

Lesefassung: der Text in der Reihenfolge, in der das Spiel ihn zeigt. *Kursiv* ist Erzählung, **fett** sprechen die Figuren, ▸ sind deine Antworten. Eingerückt steht, was nur unter einer Bedingung oder nach einer Antwort kommt. Hinter jeder Zeile die ID in klein.

**So antwortest du:** je Szene (E3, T12 …) „OK“, „ändern: …“ oder „raus“. Was du nicht nennst, gilt als OK.


## werkstatt


### S4-1 · `tess`

*wenn* `city.sat_with_tess`
  - *→ weiter bei* `tess_after`
*wenn* `city.board_done`
  - *→ weiter bei* `tess_again`
*wenn* `city.tess_met`
  - *→ weiter bei* `tess_offer_again`
- *Hinter der Werkbank misst eine Frau ein Brett, das graue Haar unter einem Tuch, die Ärmel hochgekrempelt. Sie sieht nicht auf.* `[#draft]`  <sub>wer_tess_1</sub>
- *In die Kante ihres Zollstocks ist ein Wort geritzt, »Tess«, tief genug, dass man es mit dem Daumen liest.* `[#draft]`  <sub>wer_tess_2</sub>
- **Tess:** Halt mal. `[#draft]`  <sub>wer_tess_3</sub>
- *Sie streckt dir das Ende hin, ohne den Kopf zu heben. Du nimmst es. Sie schiebt deine Hand zwei Fingerbreit weiter.* `[#draft]`  <sub>wer_tess_4</sub>
- **Tess:** Nein, hier. Gut. `[#draft]`  <sub>wer_tess_5</sub>
- *Sie liest das Maß ab und pfeift dabei, schief, ein paar Töne abwärts und am Ende ein Zittern.* `[#draft]`  <sub>wer_tess_6</sub>
- **Tess:** Zweiundachtzig und ein Strich. `[#draft]`  <sub>wer_tess_7</sub>
- *Der Bleistift kommt hinter dem Ohr hervor, ein Strich, zurück. Erst dann sieht sie dich an.* `[#draft]`  <sub>wer_tess_8</sub>
- **Tess:** Du hast das Haus im Tal. `[#draft]`  <sub>wer_tess_9</sub>
- **Tess:** Dach, Regal, Leiter. In der Reihenfolge nicht. `[#draft]`  <sub>wer_tess_10</sub>
- *→ weiter bei* `tess_offer`

### S4-2 · `tess_offer`

> --- Das Angebot ---------------------------------------------------------------------------------------------------------------
> Ein Brett fürs Haus, und sie zeigt es einmal. "Warum ein Brett?" bekommt Material und Verwendung, keinen Sinn; danach steht das Angebot noch einmal da. Das Schweigen
> nimmt sie hin, ohne zu drängen: das Brett wartet, sie nicht auf dich. Wer wiederkommt, ohne gesägt zu haben, hört dasselbe Angebot kürzer.

- **Tess:** Ein Brett fürs Haus. Ich zeig's dir einmal. Dann bist du dran. `[#draft]`  <sub>wer_offer_1</sub>
- ▸ **Zeig's mir.**
  - *→ weiter bei* `tess_saw`
- ▸ **Warum ein Brett?**
  - **Tess:** Kiefer, trocken, kein Ast in der Mitte. Wird ein Regalboden. `[#draft]`  <sub>wer_offer_2</sub>
  - *→ weiter bei* `tess_offer_again`
- ▸ **…**
  - *→ weiter bei* `tess_quiet`

### S4-3 · `tess_offer_again`

- **Tess:** Also. Ich zeig's dir einmal. `[#draft]`  <sub>wer_offer_3</sub>
- ▸ **Zeig's mir.**
  - *→ weiter bei* `tess_saw`
- ▸ **…**
  - *→ weiter bei* `tess_quiet`

### S4-4 · `tess_quiet`

- *Tess misst weiter. Auf dem Bock liegt das Brett mit seiner Bleistiftlinie und läuft nicht weg.* `[#draft]`  <sub>wer_quiet_1</sub>

### S4-5 · `tess_saw`

> --- Das Sägen -------------------------------------------------------------------------------------------------------------------
> Kein Minispiel, nur Zeilen. Sie sägt bis zur Mitte vor (die Linie nachziehen, die Kerbe weiterführen: es geht auch beim zweiten Mal), dann ist die Spielerin dran, und das Brett
> rutscht. Niemand bietet eine Hand an. Hier bittet die Spielerin zum ersten Mal aus eigenem Willen um Hilfe (Facette; der Leser steht in "tess_again"): Tess hält, wortlos,
> oder sie tritt einen Schritt zurück und lässt es der Spielerin allein. Beide Wege ergeben dasselbe krumme Brett und dieselbe Zeile (Probezeile in tess.md); keiner wird gelobt,
> der Unterschied sind ihre Hände und ihre Kürze. Das Schweigen lässt das Brett halb durchgesägt liegen, sie sägt nicht für dich und sagt nichts dazu.

- *Tess tritt an den Bock, setzt die Säge in die Bleistiftlinie und zieht sie in langen Zügen bis zur Mitte.* `[#draft]`  <sub>wer_saw_1</sub>
- *Die Späne fallen in einer Reihe, als hätte sie sie gezählt.* `[#draft]`  <sub>wer_saw_2</sub>
- **Tess:** Daumen als Führung. Nicht drücken, ziehen. Jetzt du. `[#draft]`  <sub>wer_saw_3</sub>
- *Du nimmst die Säge. Das Brett rutscht schon, wenn du es nur ansiehst. Tess steckt die Daumen in die Schürze.* `[#draft]`  <sub>wer_saw_4</sub>
- ▸ **Hältst du das Brett?**
  - *Tess tritt neben dich und legt beide Hände flach auf das Brett, rechts und links der Linie. Sie sagt nichts.* `[#draft]`  <sub>wer_saw_5</sub>
  - *Das Brett steht unter ihren Händen wie festgewachsen. Die Säge wandert trotzdem aus der Linie, nach rechts, und du merkst es zu spät.* `[#draft]`  <sub>wer_saw_6</sub>
  - *→ weiter bei* `tess_done`
- ▸ **Ich halte es selbst.**
  - *Du klemmst das Brett mit dem Knie auf den Bock. Tess tritt einen Schritt zurück.* `[#draft]`  <sub>wer_saw_7</sub>
  - *Die Säge springt, fängt sich, springt. Mitten im Brett biegt die Kante nach links ab und kommt nicht mehr zurück.* `[#draft]`  <sub>wer_saw_8</sub>
  - **Tess:** Knie weiter vor, dann springt sie nicht. `[#draft]`  <sub>wer_saw_9</sub>
  - *→ weiter bei* `tess_done`
- ▸ **…**
  - *Du legst die Säge zurück. Tess hängt sie an ihren Nagel. Das Brett bleibt halb durchgesägt auf dem Bock.* `[#draft]`  <sub>wer_saw_10</sub>

### S4-6 · `tess_done`

> Das Ende beider Wege: dasselbe Brett, dieselbe Zeile. Sie schenkt es nicht, sie gibt es dir mit, weil du es gesägt hast; ein Gegenstand (Kuriosität), eine Erinnerung, und das
> Brett ist fertig (die Karte und die Szene lesen es: Tess sitzt von jetzt an draußen).

- *Das Brett fällt in zwei Stücke. Die Kante des größeren hat eine Biegung, die auf keiner Linie steht.* `[#draft]`  <sub>wer_done_1</sub>
- **Tess:** Das ist krumm. Bleibt aber stehen. Nimm's. `[#draft]`  <sub>wer_done_2</sub>
- *Du nimmst das größere Stück. Tess klopft dir das Sägemehl von der Schulter und geht zurück an den Tisch.* `[#draft]`  <sub>wer_done_3</sub>

### S4-7 · `tess_again`

> --- Das Brett ist fertig ---------------------------------------------------------------------------------------------------------
> Kurze Zeilen über Arbeit: der Rest vom Brett, der Hobel, der Geruch von Kiefer, die Leiter. Wer um Hilfe gebeten hat (city.asked_help), bekommt ihre kürzere Zeile, sie spart
> sich die Erklärung; wer es allein gesägt hat, bekommt die längere. Beide sind Arbeit, keine Wertung. Die Facette zeigt sich als zusätzliche Antwort neben den unbedingten:
> "Hältst du mir die Leiter?" Sie hält die Leiter an der Wand, du holst ein Maßband vom Balken; sie lobt nicht und fragt nicht, was dich dazu bringt. Das Schweigen bleibt die letzte.

*wenn* `city.asked_help`
  - **Tess:** Den Rest vom Brett. Zwei Züge. `[#draft]`  <sub>wer_again_1</sub>
*sonst*
  - **Tess:** Den Rest vom Brett hobel ich glatt. Kiefer fusselt gegen die Faser, also von der anderen Seite. Zwei Züge, dann ist es gut. `[#draft]`  <sub>wer_again_2</sub>
- ▸ **Was ist das für Holz?**
  - **Tess:** Kiefer. Riech mal. `[#draft]`  <sub>wer_again_3</sub>
  - *Du hältst die Nase an die Schnittkante. Harz, scharf und sauber. Tess hobelt schon weiter.* `[#draft]`  <sub>wer_again_4</sub>
- ▸ **Kann ich zusehen?**
  - **Tess:** Steh nicht im Licht. `[#draft]`  <sub>wer_again_5</sub>
  - *Der Span kommt in einem Stück und rollt sich auf dem Boden ein. Tess sieht nicht hin. Es ist der dritte heute.* `[#draft]`  <sub>wer_again_6</sub>
- ▸ **Hältst du mir die Leiter?** *(wenn `connection`)*
  - *Tess stellt den Fuß auf den untersten Holm und packt beide Seiten. Die Leiter hat vier Sprossen und sonst nur die Löcher dafür.* `[#draft]`  <sub>wer_again_7</sub>
  - **Tess:** Halt dich an den Holmen. `[#draft]`  <sub>wer_again_8</sub>
  - *Du steigst die Sprossen hinauf und holst ein Maßband vom Balken, grau von Staub.* `[#draft]`  <sub>wer_again_9</sub>
  - *Tess lässt erst los, als beide Füße wieder auf dem Boden stehen.* `[#draft]`  <sub>wer_again_10</sub>
  - **Tess:** Da ist es ja. Seit gestern such ich's. `[#draft]`  <sub>wer_again_11</sub>
- ▸ **…**
  - *Tess hobelt weiter, und der Span rollt sich auf dem Boden ein.* `[#draft]`  <sub>wer_again_12</sub>

### S4-8 · `bench`

> --- Draußen: die Bank und "Nichts" ----------------------------------------------------------------------------------------------
> Ist das Brett fertig, sitzt sie auf der Kiste neben der Bank vor der Werkstatt (in der Werkstatt steht sie dann nicht mehr: sie ist nie an zwei Orten). Wer sie anspricht,
> hört genau eine Zeile, "Setz dich." (Bible §44), und sonst nichts. Setzt sich die Spielerin auf die Bank, spielt "nothing" einmal je Sitzen: zwei oder drei Erzählzeilen, kein
> Dialog, keine Lehre, keine Sache über Ruhe, Pausen oder Gefühle; die Dinge reichen (Licht auf dem Holzstapel, ein Spatz). Der Cue setzt nichts: die Szene (stadt_scene.gd)
> startet die Quest beim Sitzen und beendet sie beim Aufstehen, dann fällt city.sat_with_tess. Danach kein Beat, kein Lob, kein Zähler. Wer Tess nach dem Sitzen anspricht,
> hört eine Zeile, die nichts erklärt; wer sich noch einmal setzt, bekommt die kürzere Fassung.

*wenn* `city.sat_with_tess`
  - *→ weiter bei* `tess_after`
- **Tess:** Setz dich. `[#draft]`  <sub>wer_bench_1</sub>

### S4-9 · `tess_after`

- **Tess:** Die Kiste ist zu niedrig. Ich sitze trotzdem drauf. `[#draft]`  <sub>wer_after_1</sub>

### S4-10 · `nothing`

*wenn* `city.sat_with_tess`
  - *→ weiter bei* `nothing_again`
- *Die Bank ist gerade breit genug. Tess sitzt auf ihrer Kiste daneben, die Hände auf den Knien, ohne Werkzeug darin.* `[#draft]`  <sub>wer_nothing_1</sub>
- *Auf dem Holzstapel liegt ein Streifen Licht. Siehst du hin, steht er still. Siehst du weg, ist er ein Stück weiter.* `[#draft]`  <sub>wer_nothing_2</sub>
- *Ein Spatz landet auf dem Sägebock, sieht sich die Späne an und lässt sie liegen.* `[#draft]`  <sub>wer_nothing_3</sub>

### S4-11 · `nothing_again`

- *Die Bank, die Kiste, der Holzstapel. Das Licht liegt an einer anderen Stelle als vorhin.* `[#draft]`  <sub>wer_nothing_4</sub>
- *Der Spatz ist fort. Die Späne liegen noch.* `[#draft]`  <sub>wer_nothing_5</sub>

### S4-12 · `saws`

> --- Die Dinge in der Werkstatt -------------------------------------------------------------------------------------------------
> Sägen und Zwingen, die halbfertige Leiter, das Sägemehl, das Brett auf dem Bock: Dinge, kein Gespräch. Der Humor sitzt in der Ordnung und im Gebrauch; keine Zeile erklärt
> Tess. Das Brett kennt zwei Zustände: vor dem Sägen ein angezeichnetes Brett, danach nur noch die Späne.

- *Die Sägen hängen der Größe nach an der Wand, jede vor ihrem Umriss in Kreide. Nur bei der größten ist der Umriss leer.* `[#draft]`  <sub>wer_saws_1</sub>
- *Darunter hängen die Zwingen, jede in ihrem eigenen Umriss. Die leere Stelle der großen Säge ist die einzige Unordnung in der Reihe.* `[#draft]`  <sub>wer_saws_2</sub>

### S4-13 · `ladder`

- *Eine Leiter lehnt an der Wand, zwei Holme aus hellem Holz, unten vier Sprossen, oben nur zwei leere Löcher dafür.* `[#draft]`  <sub>wer_ladder_1</sub>
- *Auf beiden Holmen stehen Bleistiftstriche, genau dort, wo die nächsten Sprossen hinkommen.* `[#draft]`  <sub>wer_ladder_2</sub>

### S4-14 · `dust`

- *Sägemehl liegt fein wie Mehl auf den Dielen, und zwei Reihen Fußspuren führen hindurch.* `[#draft]`  <sub>wer_dust_1</sub>
- *Die breiten laufen so oft zwischen Tür, Werkbank und Wand, dass sie einen Weg ergeben. Die schmalen enden dort, wo du stehst.* `[#draft]`  <sub>wer_dust_2</sub>

### S4-15 · `board`

*wenn* `city.board_done`
  - *Auf dem Bock liegen nur noch Späne, hell und gekräuselt.* `[#draft]`  <sub>wer_board_3</sub>
  - *Auf einem davon steht noch ein Stück Bleistiftlinie.* `[#draft]`  <sub>wer_board_4</sub>
  - *→ Ende des Szenenstücks*
- *Auf dem Bock liegt ein Brett aus Kiefer, quer darüber ein Bleistiftstrich.* `[#draft]`  <sub>wer_board_1</sub>
- *Auf der einen Seite des Strichs steht ein Haken, für den Teil, der bleibt. Der Rest wird Abfall.* `[#draft]`  <sub>wer_board_2</sub>
