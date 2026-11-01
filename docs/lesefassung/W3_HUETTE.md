# W3 Hütte (Akt III)

<!-- Erzeugt mit `python3 tools/writing/readable.py`. Nicht von Hand ändern: Änderungen gehören in die .dialogue-Dateien. -->

Lesefassung: der Text in der Reihenfolge, in der das Spiel ihn zeigt. *Kursiv* ist Erzählung, **fett** sprechen die Figuren, ▸ sind deine Antworten. Eingerückt steht, was nur unter einer Bedingung oder nach einer Antwort kommt. Hinter jeder Zeile die ID in klein.

**So antwortest du:** je Szene (E3, T12 …) „OK“, „ändern: …“ oder „raus“. Was du nicht nennst, gilt als OK.


## huette


### W3-1 · `door_tea`

*wenn* `forest.hut_tea`
  - *Der Becher steht auf dem Stein, wo er stand. Er ist noch warm.* `[#draft]`  <sub>hu_door_5</sub>
  - *→ Ende des Szenenstücks*
- *Aus dem Schornstein der Hütte steigt dünner Rauch.* `[#draft]`  <sub>hu_door_1</sub>
- *Auf einem flachen Stein vor der Tür steht ein Becher. Der Tee darin ist noch warm.* `[#draft]`  <sub>hu_door_2</sub>
- *Niemand ist zu sehen. Der Becher steht da, als gehöre er dem, der vorbeikommt.* `[#draft]`  <sub>hu_door_3</sub>
- ▸ **Trinken.**
  - *Du trinkst. Der Tee schmeckt nach Holunder und nach Rauch.* `[#draft]`  <sub>hu_door_4</sub>
- ▸ **Stehen lassen.**
  - *Du lässt ihn stehen. Er wärmt den Stein weiter.* `[#draft]`  <sub>hu_door_6</sub>
- ▸ **…**
  - *Du siehst dem Rauch nach, der gerade nach oben geht.* `[#draft]`  <sub>hu_door_7</sub>

### W3-2 · `branches`

- *Auf dem Pfad zur Hütte liegen Zweige, einer über dem anderen.* `[#draft]`  <sub>hu_branch_1</sub>
- *Man sieht sie, und man steigt über sie. Gebunden sind sie nicht.* `[#draft]`  <sub>hu_branch_2</sub>

### W3-3 · `pebble`

- *Im Gras an der Hüttenwand liegt ein Kiesel, glatt, mittendurch ein Loch.* `[#draft]`  <sub>hu_pebble_1</sub>
- ▸ **Einstecken.**
  - *Du hältst ihn vors Auge. Der Wald ist rund und sehr nah.* `[#draft]`  <sub>hu_pebble_2</sub>
- ▸ **Liegen lassen.**
  - *Du lässt ihn liegen. Er sieht weiter durch sich hindurch.* `[#draft]`  <sub>hu_pebble_3</sub>

### W3-4 · `clothesline`

> Eine Spur der Welt (Fragment, kein Bild des Kindes, kein Grund): eine Leine ohne Wäsche, die für einen Atemzug nicht leer ist.

*wenn* `fragment.clothesline`
  - *Die Leine zwischen den zwei Pfosten, die Klammern in einer Reihe.* `[#draft]`  <sub>hu_line_5</sub>
*sonst*
  - *Zwischen zwei Pfosten ist eine Leine gespannt. Die Holzklammern sitzen in gleichen Abständen, grau vom Wetter.* `[#draft]`  <sub>hu_line_1</sub>
  - *Nichts hängt daran. Das Gras darunter ist platt getreten, eine Bahn entlang.* `[#draft]`  <sub>hu_line_2</sub>
  - *Für einen Atemzug hängt ein Tuch daran, noch nass, und es tropft. Dann ist es wieder nur eine Leine.* `[#draft]`  <sub>hu_line_3</sub>
  - *Wer sie gespannt hat, hat auf Wind gerechnet.* `[#draft]`  <sub>hu_line_4</sub>

### W3-5 · `bolt`

> --- Drinnen: die Dinge ---------------------------------------------------------------------------------------------------

- *Innen an der Tür hängt ein Riegel, das Eisen blank von einer einzigen Hand.* `[#draft]`  <sub>hu_bolt_1</sub>
- *Er hängt offen und pendelt ein wenig, wenn die Tür sich bewegt.* `[#draft]`  <sub>hu_bolt_2</sub>

### W3-6 · `cup_nail`

- *An einem Nagel neben dem Fenster hängt ein zweiter Becher.* `[#draft]`  <sub>hu_cup_1</sub>
- *Er ist glatt vom Abwischen. Benutzt sieht er nicht aus.* `[#draft]`  <sub>hu_cup_2</sub>

### W3-7 · `flute_shelf`

*wenn* `melody.hermit_flute`
  - *Die Flöte liegt wieder auf dem Brett. Das Holz ist an den Löchern dunkel gegriffen.* `[#draft]`  <sub>hu_shelf_3</sub>
*sonst*
  - *Auf einem Brett an der Wand liegt eine Flöte aus hellem Holz.* `[#draft]`  <sub>hu_shelf_1</sub>
  - *Auf dem Brett liegt Staub, nur um die Flöte herum nicht.* `[#draft]`  <sub>hu_shelf_2</sub>

### W3-8 · `window`

*wenn* `forest.pipe_taken`
  - *→ weiter bei* `window_view`
- *Das Fenster zeigt den Wald im Abendlicht, zwei Stämme und dazwischen Dämmerung. Es zeigt immer dasselbe.* `[#draft]`  <sub>hu_win_1</sub>
- *Auf dem Fensterbrett liegt eine Holunderpfeife, ein Stück Holz mit einem einzigen Loch.* `[#draft]`  <sub>hu_win_2</sub>
- ▸ **Einstecken.**
  - *Du pustest hinein. Ein Ton, ein guter, mehr hat sie nicht.* `[#draft]`  <sub>hu_win_3</sub>
- ▸ **Liegen lassen.**
  - *Du lässt sie liegen. Sie hat Zeit.* `[#draft]`  <sub>hu_win_4</sub>

### W3-9 · `window_view`

- *Das Fenster zeigt den Wald im Abendlicht, zwei Stämme und dazwischen Dämmerung. Es zeigt immer dasselbe.* `[#draft]`  <sub>hu_win_5</sub>

### W3-10 · `hermit`

> --- Er selbst ----------------------------------------------------------------------------------------------------------
> Er spricht in Angeboten, kurz und trocken, und stellt keine Frage. "Komm doch mal ins Tal." gibt es nur mit der Facette care
> (wer Tee machen kann, kann ihn auch anbieten); sein Becher ist dann gepackt. Wer geht, geht ohne Folge.

*wenn* `forest.hut_met oder melody.hermit_flute`
  - *→ weiter bei* `hermit_again`
- **Einsiedler:** Tee ist da. Sitz, wenn du magst. `[#draft]`  <sub>hu_h_1</sub>
*wenn* `forest.hut_tea`
  - **Einsiedler:** Der vor der Tür war für jeden. Heute du. `[#draft]`  <sub>hu_h_2</sub>
*sonst*
  - **Einsiedler:** Der Tee draußen wird kalt. Er mag das. `[#draft]`  <sub>hu_h_3</sub>
- *Er zeigt mit dem Kinn auf den Hocker. Mehr zeigt er nicht.* `[#draft]`  <sub>hu_h_4</sub>
- *→ weiter bei* `hermit_end`

### W3-11 · `hermit_again`

*wenn* `forest.hermit_invited`
  - **Einsiedler:** Der Becher ist gepackt. `[#draft]`  <sub>hu_h_6</sub>
*sonst*
  - **Einsiedler:** Der Hocker ist frei. `[#draft]`  <sub>hu_h_5</sub>
- *→ weiter bei* `hermit_end`

### W3-12 · `hermit_end`

- ▸ **Komm doch mal ins Tal. Ich hab Tee.** *(wenn `care und forest.hermit_invited nicht`)*
  - **Einsiedler:** Tee ist ein Grund. Becher bring ich mit. `[#draft]`  <sub>hu_h_7</sub>
- ▸ **Ich gehe weiter.**
  - **Einsiedler:** Geh, wenn du gehst. Der Tee verzeiht es. `[#draft]`  <sub>hu_h_8</sub>
- ▸ **…**
  - *Er nickt. Der Dampf aus dem Becher steht gerade.* `[#draft]`  <sub>hu_h_9</sub>

### W3-13 · `stay`

> --- Sitzen und Bleiben -------------------------------------------------------------------------------------------------
> Die Szene startet `stay`, sobald sie sich auf den Hocker setzt (einmal je Sitzen). Beim ersten Mal spielt er die Flöte.

*wenn* `forest.hut_stay_3`
  - *→ weiter bei* `stay_done`
*wenn* `melody.hermit_flute`
  - *→ weiter bei* `stay_ask`
- *→ weiter bei* `flute`

### W3-14 · `flute`

- *Der Einsiedler nimmt die Flöte vom Brett, ohne etwas zu sagen.* `[#draft]`  <sub>hu_flute_1</sub>
- *Er spielt eine kurze Weise, langsam, an den Rändern ein wenig schief. Sie steigt, hält und sinkt wieder.* `[#draft]`  <sub>hu_flute_2</sub>
- *Dann legt er die Flöte zurück aufs Brett. Der Tee dampft noch.* `[#draft]`  <sub>hu_flute_3</sub>
- *→ weiter bei* `stay_ask`

### W3-15 · `stay_ask`

- *Der Hocker ist bequem, der Tee heiß. Niemand sagt, wie lange.* `[#draft]`  <sub>hu_ask_1</sub>
- ▸ **Bleiben.**
  - *→ weiter bei* `stay_next`
- ▸ **Nur sitzen.**
  - *Du sitzt und hältst den Becher. Das Fenster zeigt den Wald, wie vorhin.* `[#draft]`  <sub>hu_ask_2</sub>
- ▸ **…**
  - *Es ist still. Nur der Ofen knackt.* `[#draft]`  <sub>hu_ask_3</sub>

### W3-16 · `stay_next`

*wenn* `forest.hut_stay_2`
  - *→ weiter bei* `stay_3`
*wenn* `forest.hut_stay_1`
  - *→ weiter bei* `stay_2`
- *→ weiter bei* `stay_1`

### W3-17 · `stay_1`

- *Du bleibst. Der Ofen knackt, und die Wände rücken ein wenig näher. Es ist gemütlich.* `[#draft]`  <sub>hu_s1_1</sub>
- **Einsiedler:** Draußen ist alles wie immer. Hier auch. `[#draft]`  <sub>hu_s1_2</sub>
- ▸ **Noch bleiben.**
  - *→ weiter bei* `stay_2`
- ▸ **Nur sitzen.**
  - *Du sitzt. Der Tee wird lauwarm, und du trinkst ihn trotzdem.* `[#draft]`  <sub>hu_s1_3</sub>
- ▸ **…**
  - *Das Fenster zeigt den Wald im Abendlicht. Es zeigt ihn weiter.* `[#draft]`  <sub>hu_s1_4</sub>

### W3-18 · `stay_2`

- *Du bleibst noch. Die Hütte ist warm und sehr klein geworden. Niemand drängt.* `[#draft]`  <sub>hu_s2_1</sub>
- **Einsiedler:** Ich frag nicht, wie lang. `[#draft]`  <sub>hu_s2_2</sub>
- ▸ **Noch bleiben.**
  - *→ weiter bei* `stay_3`
- ▸ **Nur sitzen.**
  - *Du sitzt. Der Becher in deinen Händen ist das Größte im Raum.* `[#draft]`  <sub>hu_s2_3</sub>
- ▸ **…**
  - *Der Dampf steigt auf und löst sich unter dem Dach.* `[#draft]`  <sub>hu_s2_4</sub>

### W3-19 · `stay_3`

- *Du bleibst. Es ist warm und still.* `[#draft]`  <sub>hu_s3_1</sub>
- *Die Tür geht von allein einen Spalt auf, wie sie es tut. Draußen ist es nicht dunkler geworden.* `[#draft]`  <sub>hu_s3_2</sub>

### W3-20 · `stay_done`

- *Die Tür steht offen. Der Tee ist warm. Niemand sagt etwas.* `[#draft]`  <sub>hu_done_1</sub>
- *→ weiter bei* `stay_more`

### W3-21 · `stay_more`

- ▸ **Bleiben.**
  - *→ weiter bei* `stay_calm`
- ▸ **Nur sitzen.**
  - *Du sitzt. Mehr ist nicht zu tun.* `[#draft]`  <sub>hu_done_2</sub>
- ▸ **…**
  - *Der Dampf aus dem Becher steht gerade nach oben.* `[#draft]`  <sub>hu_done_3</sub>

### W3-22 · `stay_calm`

- *Du bleibst. Es ist, wie es war.* `[#draft]`  <sub>hu_calm_1</sub>
- *Du bleibst. Der Ofen knackt leise.* `[#draft]`  <sub>hu_calm_2</sub>
- *Du bleibst. Das Fenster zeigt, was es zeigt.* `[#draft]`  <sub>hu_calm_3</sub>
- *→ weiter bei* `stay_more`
