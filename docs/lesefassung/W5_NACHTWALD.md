# W5 Nachtwald (Akt III)

<!-- Erzeugt mit `python3 tools/writing/readable.py`. Nicht von Hand ändern: Änderungen gehören in die .dialogue-Dateien. -->

Lesefassung: der Text in der Reihenfolge, in der das Spiel ihn zeigt. *Kursiv* ist Erzählung, **fett** sprechen die Figuren, ▸ sind deine Antworten. Eingerückt steht, was nur unter einer Bedingung oder nach einer Antwort kommt. Hinter jeder Zeile die ID in klein.

**So antwortest du:** je Szene (E3, T12 …) „OK“, „ändern: …“ oder „raus“. Was du nicht nennst, gilt als OK.


## nachtwald


### W5-1 · `wait`

*wenn* `forest.waited`
  - *→ weiter bei* `wait_again`
- *Du setzt dich neben die Laterne auf den Boden.* `[#draft]`  <sub>nw_wait_1</sub>
- *Sie steht dort, wo sie von Weitem stand. Die Flamme biegt sich nicht.* `[#draft]`  <sub>nw_wait_2</sub>
- *Nichts raschelt, kein Ast knackt.* `[#draft]`  <sub>nw_wait_3</sub>
- *Dann summt es, nur ein paar Töne, so leise, dass du nicht sagen kannst, woher.* `[#draft]`  <sub>nw_wait_4</sub>
- *Es hört auf. Die Flamme steht wie vorher.* `[#draft]`  <sub>nw_wait_5</sub>

### W5-2 · `wait_again`

- *Du sitzt neben der Laterne. Die Flamme steht ruhig, und im Wald rührt sich nichts.* `[#draft]`  <sub>nw_again_1</sub>

### W5-3 · `lantern_far`

> --- Die Laterne von weitem -------------------------------------------------------------------------------------------------
> Ein Ding vor der Lichtung, einige Zellen vor der Laterne, nur zum Sehen: zwischen den Stämmen ein kleines orangefarbenes Licht auf dem Boden, das sich
> nicht bewegt, in einem Wald, der sonst grün glimmt (Decor tal/wd_lantern: eine kleine Eisenlaterne mit Glas, darin eine ruhige Flamme, ein Bild ohne Flackern).

- *Zwischen den Stämmen brennt etwas am Boden, ein kleines orangefarbenes Licht.* `[#draft]`  <sub>nw_far_1</sub>
- *Es zuckt nicht und wandert nicht. Alles andere im Wald glimmt grün oder gar nicht.* `[#draft]`  <sub>nw_far_2</sub>

### W5-4 · `glow_tree`

> --- Ein Leuchtbaum ---------------------------------------------------------------------------------------------------------
> Decor tal/wd_glow_tree: eine Buche mit dunkler Rinde, an Stamm und Ästen laufen lange Streifen, die matt grün glimmen (dazu ein paar Blätter der
> Krone). Das Glimmen sitzt gebacken im Bild und fällt nicht auf den Boden.

- *Die Rinde ist dunkel. In langen Streifen glimmt sie matt grün, so wie Pilze glimmen.* `[#draft]`  <sub>nw_glow_1</sub>
- *Das Glimmen bleibt am Baum. Auf dem Boden darunter liegt es nicht.* `[#draft]`  <sub>nw_glow_2</sub>

### W5-5 · `foxfire`

> --- Kuriosität: das Leuchtholz ---------------------------------------------------------------------------------------------
> Decor tal/wd_foxfire_log: ein morscher Stamm im Gras, oben ein Streifen Moos, links glatt durchtrennt (eine Schnittfläche mit Ring und Riss), rechts abgebrochen; in der unteren Hälfte und in
> den Rissen glimmt das Holz matt grün. Mit dem Einstecken bricht sie ein Stück heraus, und das Bild ist danach der dunkle Stamm mit einer hellen
> Kerbe (sprite_when) oder weg (unless): die erste Zeile des Cues gilt für den Stamm, der noch glimmt, die letzte für den, der dunkel liegt.

*wenn* `forest.foxfire_taken`
  - *Der Stamm liegt dunkel im Gras. Wo ein Stück fehlt, zeigt das Holz hell.* `[#draft]`  <sub>nw_fox_6</sub>
  - *→ Ende des Szenenstücks*
- *Ein morscher Stamm liegt im Gras, oben mit Moos, an einem Ende glatt durchtrennt, am anderen abgebrochen.* `[#draft]`  <sub>nw_fox_1</sub>
- *In der unteren Hälfte und in den Rissen glimmt das Holz matt grün.* `[#draft]`  <sub>nw_fox_2</sub>
- ▸ **Einstecken.**
  - *Du brichst ein Stück heraus, weich wie nasses Brot, und steckst es ein. Durch den Stoff glimmt es weiter.* `[#draft]`  <sub>nw_fox_3</sub>
- ▸ **Liegen lassen.**
  - *Du lässt den Stamm, wie er liegt. Er glimmt an seiner Stelle weiter.* `[#draft]`  <sub>nw_fox_4</sub>
- ▸ **…**
  - *Du beugst dich darüber. Es riecht nach Pilz und nach feuchter Erde.* `[#draft]`  <sub>nw_fox_5</sub>

### W5-6 · `home_way`

> --- Der Weg nach Hause: gezeigt, nicht gesagt ---------------------------------------------------------------------------------
> Ein Ding kurz vor der Tür ins Tal (Südwesten). Der Wald lichtet sich, der Pfad wird breit, und es riecht nach dem Bach, den sie kennt.
> Das Wort für den Ort steht nirgends.

- *Die Stämme stehen hier weiter auseinander, und der Pfad wird breit und eben.* `[#draft]`  <sub>nw_home_1</sub>
- *Zwischen den letzten riecht es nach dem Bach, den du kennst.* `[#draft]`  <sub>nw_home_2</sub>
