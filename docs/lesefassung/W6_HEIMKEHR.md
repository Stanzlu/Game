# W6 Heimkehr (Akt III)

<!-- Erzeugt mit `python3 tools/writing/readable.py`. Nicht von Hand ändern: Änderungen gehören in die .dialogue-Dateien. -->

Lesefassung: der Text in der Reihenfolge, in der das Spiel ihn zeigt. *Kursiv* ist Erzählung, **fett** sprechen die Figuren, ▸ sind deine Antworten. Eingerückt steht, was nur unter einer Bedingung oder nach einer Antwort kommt. Hinter jeder Zeile die ID in klein.

**So antwortest du:** je Szene (E3, T12 …) „OK“, „ändern: …“ oder „raus“. Was du nicht nennst, gilt als OK.


## heimkehr


### W6-1 · `home_in`

- *In der Ecke, in der nichts stand, steht jetzt eine Werkbank, und am Schraubstock sitzt der Antreiber.* `[#draft]`  <sub>hk_in_1</sub>
*wenn* `house.cat_fed`
  - *Die Katze liegt ihm quer über den Knien. Er sitzt wie jemand, der ein volles Glas trägt.* `[#draft]`  <sub>hk_in_2</sub>
- **Antreiber:** Ich hab nicht gewartet. Die Bank hat gedauert. `[#draft]`  <sub>hk_in_3</sub>

### W6-2 · `guest_enter`

> --- Die Szene: der Besuch (nur wer den Einsiedler eingeladen hat) -------------------------------------------------------------
> Der Einsiedler kommt zur Tür herein, geht zum Tischende und setzt sich; der Stuhl (Decor haus/guest_chair, eine hohe Lehne, flach unter
> ihm) steht dann da. Er spricht in Angeboten und stellt nichts in Frage: er hat den Stuhl mitgebracht, er passt ihm. Der Antreiber misst
> ihn und lässt ihn gelten. Der Becher ist der Becher der Hütte, der glatt am Nagel hing: er ist schon sauber, und er wischt ihn aus.
> Die zweite Fütterung der Katze: er wirft ihr etwas zu (sie liegt drei Zellen von ihm), sie nimmt es, ohne aufzustehen. Ohne gefütterte Katze sitzt sie draußen auf dem
> Sims (Decor haus/cat_window) und bleibt dort.

- **Einsiedler:** Stuhl hab ich mitgebracht. `[#draft]`  <sub>hk_guest_1</sub>
- **Antreiber:** Zwei Finger zu hoch für den Tisch. `[#draft]`  <sub>hk_guest_2</sub>
- **Einsiedler:** Er passt mir. `[#draft]`  <sub>hk_guest_3</sub>
- *Der Einsiedler wischt seinen Becher mit dem Ärmel aus, einmal rund herum. Der war schon sauber. Du füllst ihn aus der Flasche.* `[#draft]`  <sub>hk_guest_4</sub>
*wenn* `house.cat_fed`
  - *Der Einsiedler wirft der Katze ein Stück Räucherfisch zu. Sie frisst es, ohne die Augen zu öffnen, und bleibt, wo sie liegt.* `[#draft]`  <sub>hk_guest_5</sub>
*sonst*
  - *Auf dem Fensterbrett sitzt die Katze. Der Einsiedler nickt ihr durch die Scheibe zu. Sie bleibt, wo sie sitzt.* `[#draft]`  <sub>hk_guest_6</sub>

### W6-3 · `act3_close`

> --- Die Szene: der Schluss des Aktes -----------------------------------------------------------------------------------------------
> Die erste Zeile gibt es nur nach dem Besuch: der Einsiedler lässt den Stuhl da, er zieht nicht ein, und er kommt, wenn es einen Grund gibt
> (der Grund ist Tee, wie in der Hütte). Die zweite gilt für alle und ist ein Blick, kein Satz: der Antreiber sieht erst auf seine
> Sachen, dann nirgends hin. Danach steht der Einsiedler auf und geht; die Szene setzt, was der Akt setzt, ohne dass ein Cue es tut.

*wenn* `house.guest_hermit`
  - **Einsiedler:** Der Stuhl bleibt. Tee ist ein Grund. `[#draft]`  <sub>hk_close_1</sub>
- *Der Antreiber sieht zur Werkbank, zum Fenster, zum Blatt an der Wand. Dann nirgends hin.* `[#draft]`  <sub>hk_close_2</sub>

### W6-4 · `workbench`

> --- Die Werkbank -----------------------------------------------------------------------------------------------------------------
> Decor haus/workbench (Karte, Zelle B): eine dicke Platte auf zwei Böcken mit einer Strebe. Von links der Schraubstock mit einem Brett
> darin, ein Hammer hinter einem Lineal mit Strichen, ein Glas Nägel, ein Stapel Schindeln mit einer neuen Latte oben, in der zwei
> Nägel stecken; der dritte liegt vor dem Stapel. An der Vorderkante läuft ein roter Kreidestrich, von Ende zu Ende gezogen; am Boden
> liegen helle Späne. Nichts ragt über die Platte hinaus. Kein Wort über Wasser, Wald oder Gründe: die Bank ist eine Bank.

- *Auf der Werkbank sind ein Schraubstock mit einem Brett darin, ein Lineal, ein Hammer, ein Glas Nägel und ein Stapel Schindeln.* `[#draft]`  <sub>hk_bench_1</sub>
- *Auf den Schindeln liegt eine neue Latte. Zwei Nägel stecken schon, der dritte liegt vor dem Stapel.* `[#draft]`  <sub>hk_bench_2</sub>
- *An der Vorderkante läuft ein roter Kreidestrich, mit dem Lineal gezogen. Nichts ragt über den Strich hinaus.* `[#draft]`  <sub>hk_bench_3</sub>
- *Nur die Späne am Boden liegen, wie sie gefallen sind.* `[#draft]`  <sub>hk_bench_4</sub>

### W6-5 · `plan_board`

> --- Das Blatt an der Wand: der Freizeitplan --------------------------------------------------------------------------------------
> Decor haus/plan_board (Karte, Zelle Y, Wandzelle zwischen Regal und Fenster): ein Blatt mit einem roten Streifen oben und fünf Zeilen, links
> je ein roter Block (die Uhrzeit), daneben ein Text ohne Buchstaben (der Posten), am Ende jeder Zeile ein roter Strich. Was auf dem Blatt
> steht, sagt nur der Text; das Bild zeigt nichts Lesbares. Die fünf Posten: Tee, Aussicht, Pausen, Katze und Besuch. Die Katze und der
> Besuch hat er nicht in der Hand, und er schreibt es hin. Ein Posten fürs Nichtstun ist es nicht: das gehört dem Nachspiel (Bible §42).
> Gezählt werden nur die Minuten eines Tees, nie Besuche oder Tage (Bible §52). Die letzte Zeile gilt nach dem Besuch.

- *Zwischen Regal und Fenster hängt ein Blatt mit rotem Streifen oben. Links stehen Uhrzeiten, daneben Posten.* `[#draft]`  <sub>hk_plan_1</sub>
- *Um Viertel nach drei steht »Tee, sieben Minuten«, um Viertel vor vier »Aussicht, sieben Minuten, nur bei Sicht«.* `[#draft]`  <sub>hk_plan_2</sub>
- *Am Ende jeder Zeile steht ein Strich. Auch »Pausen« hat einen, und er ist nicht ausgewischt.* `[#draft]`  <sub>hk_plan_3</sub>
- *Bei »Katze« steht als Uhrzeit »wann sie will«, bei »Besuch« steht »unangemeldet«.* `[#draft]`  <sub>hk_plan_4</sub>
*wenn* `house.guest_hermit`
  - *Bei »Besuch« steht jetzt ein Name dazu, »Einsiedler«, und als Dauer »offen«.* `[#draft]`  <sub>hk_plan_5</sub>

### W6-6 · `antreiber_bench`

> --- Der Antreiber an der Werkbank ---------------------------------------------------------------------------------------------------
> Er sitzt am Schraubstock (Karte, Zelle A, Figur sitzt), in jedem Zustand und nirgends sonst. Er sagt, was er tut und plant, nie, was es
> bedeutet. Der Tee steht auf dem Blatt: wer ihn im Wald gesetzt hat, hört seine Dauer, sonst wartet der Tee auf jemanden. Die Katzenzeile
> gilt nur mit house.cat_fed (Bible §28: sie schläft auf ihm; er verschiebt, was er sonst täte; die Zeile klingt wie ein Eintrag auf dem Blatt). "Tee machen." ist der Leser der Facette
> care im Haus und gibt es nur mit ihr; "Helfen." und das Schweigen gibt es immer, und jede Antwort hat ihre eigene Folge an ihm.

*wenn* `forest.antreiber_sat oder forest.flood_sat`
  - **Antreiber:** Tee steht drauf. Sieben Minuten, zu zweit zehn. `[#draft]`  <sub>hk_antr_1</sub>
*sonst*
  - **Antreiber:** Tee steht drauf. Wenn jemand welchen macht. `[#draft]`  <sub>hk_antr_2</sub>
- **Antreiber:** Zaun erledigt, bis auf die Lücke. `[#draft]`  <sub>hk_antr_3</sub>
- **Antreiber:** Am Dach ist eine Reihe vorgesehen. `[#draft]`  <sub>hk_antr_9</sub>
*wenn* `house.cat_fed`
  - **Antreiber:** Aufstehen, vier Uhr. Verschoben. `[#draft]`  <sub>hk_antr_4</sub>
- *→ weiter bei* `antreiber_bench_ask`

### W6-7 · `antreiber_bench_ask`

- ▸ **Helfen.**
  - *Du hältst das Brett fest, obwohl der Schraubstock es hält. Der Antreiber lässt dich.* `[#draft]`  <sub>hk_antr_5</sub>
- ▸ **Tee machen.** *(wenn `care`)*
  - *Du stellst ihm Tee hin. Er sieht zum Blatt an der Wand und wieder zu dir.* `[#draft]`  <sub>hk_antr_6</sub>
  - **Antreiber:** Zu früh. Ich lass es gelten. `[#draft]`  <sub>hk_antr_7</sub>
- ▸ **…**
  - *Er nickt und dreht den Schraubstock eine Vierteldrehung nach.* `[#draft]`  <sub>hk_antr_8</sub>

### W6-8 · `cat_bench`

> --- Die Katze auf dem Antreiber ----------------------------------------------------------------------------------------------------
> Decor haus/cat_sleep, eine Zelle südlich von ihm und hochgesetzt (sie liegt ihm quer über den Knien), nur mit house.cat_fed. Die Katze hat keine
> Stimme und keinen Gedanken; "trocken" ist hier Untertreibung. Der Name steht nur als Paar (mit Namen / "Die Katze"). Wer sie noch nicht
> benannt hat, kann es hier tun (die Szene öffnet die Eingabe, wie am Feuer), denn auf diesem Weg gibt es sonst keinen Cue für sie.

*wenn* `cat_name() != ""`
  - *‹Katzenname› schläft auf dem Antreiber. Die Werkbank steht genau so nah, dass seine freie Hand drankommt.* `[#draft]`  <sub>hk_cat_1</sub>
  - *→ Ende des Szenenstücks*
- *Die Katze schläft auf dem Antreiber. Die Werkbank steht genau so nah, dass seine freie Hand drankommt.* `[#draft]`  <sub>hk_cat_2</sub>
- ▸ **Ihr einen Namen geben.**
- ▸ **…**
  - *Du streichst ihr einmal über den Rücken. Der Antreiber sieht zur Wand, als sei er nicht mitgemeint.* `[#draft]`  <sub>hk_cat_3</sub>
