# B3: Bachlauf

<!-- Erzeugt mit `python3 tools/writing/readable.py`. Nicht von Hand ändern: Änderungen gehören in die .dialogue-Dateien. -->

Lesefassung: der Text in der Reihenfolge, in der das Spiel ihn zeigt. *Kursiv* ist Erzählung, **fett** sprechen die Figuren, ▸ sind deine Antworten. Eingerückt steht, was nur unter einer Bedingung oder nach einer Antwort kommt. Hinter jeder Zeile die ID in klein.

**So antwortest du:** je Szene (E3, T12 …) „OK“, „ändern: …“ oder „raus“. Was du nicht nennst, gilt als OK.


## bachlauf


### BL1 · `hook`

*wenn* `valley.trap_hooked`
  - *Der leere Haken am Pfosten. Der helle Streifen im Holz darunter.* `[#draft]`  <sub>bl_hook_4</sub>
*sonst*
  - *Ein Pfosten am Ufer, oben ein eiserner Haken.* `[#draft]`  <sub>bl_hook_1</sub>
  - *Im Holz darunter ein heller Streifen, lang und rund. Dort hat etwas lange gehangen.* `[#draft]`  <sub>bl_hook_2</sub>
  - *Der Haken ist leer. Was daran hing, ist bachabwärts gegangen.* `[#draft]`  <sub>bl_hook_3</sub>

### BL2 · `weight`

- *Im Gras am Fuß des Pfostens liegt ein Senkblei, so groß wie ein Daumenglied. Eine Kerbe für die Schnur.* `[#draft]`  <sub>bl_weight_1</sub>
- ▸ **Einstecken.**
  - *Du steckst es ein. Es zieht die Tasche nach unten, genau wie vorgesehen.* `[#draft]`  <sub>bl_weight_2</sub>
- ▸ **Liegen lassen.**
  - *Du lässt es liegen. Es hält das Gras unten.* `[#draft]`  <sub>bl_weight_3</sub>

### BL3 · `knot`

*wenn* `valley.knot_seen`
  - *Der offene Knoten am Haken.* `[#draft]`  <sub>bl_knot_4</sub>
*sonst*
  - *Am Haken sitzt noch eine Schlinge Schnur, so dünn und so grau, dass man sie für Holz hält.* `[#draft]`  <sub>bl_knot_1</sub>
  - *Sie ist nicht gerissen. Sie ist aufgeknotet, flach und sauber, von jemandem, der das oft getan hat.* `[#draft]`  <sub>bl_knot_2</sub>
  - *Wer es abnahm, hat es nicht weit gelegt. Der Bach schon.* `[#draft]`  <sub>bl_knot_3</sub>

### BL4 · `float`

*wenn* `valley.trap_floated`
  - *Der Schwimmer im Schilf, die Spitze bachabwärts.* `[#draft]`  <sub>bl_float_3</sub>
*sonst*
  - *Im Schilf hängt ein Schwimmer aus Kork, rot und weiß, die Farbe schält sich.* `[#draft]`  <sub>bl_float_1</sub>
  - *Er zeigt mit seiner kleinen Spitze bachabwärts. Das Wasser zeigt dorthin auch, nur lauter.* `[#draft]`  <sub>bl_float_2</sub>

### BL5 · `trap`

*wenn* `valley.trap_freed`
  - *Die Reuse liegt frei im Strom, die Öffnung stromab.* `[#draft]`  <sub>bl_trap_9</sub>
  - *→ Ende des Szenenstücks*
*wenn* `side_valley_trap und float`
  - *Hinter dem Wehr klemmt ein Geflecht aus Weiden, lang wie ein Arm, halb unter Wasser. Eine Reuse.* `[#draft]`  <sub>bl_trap_1</sub>
*sonst*
  - *Die Reuse klemmt noch hinter dem Wehr.* `[#draft]`  <sub>bl_trap_2</sub>
- *→ weiter bei* `trap_free`

### BL6 · `trap_free`

- ▸ **Sie lösen.**
  - *Du ziehst, bis sie nachgibt. Sie dreht sich im Strom und liegt dann ruhig, die Öffnung stromab.* `[#draft]`  <sub>bl_trap_3</sub>
  - *Im Geflecht liegt etwas. Kein Fisch. Ein Kamm, dem bis auf einen Zahn alle fehlen.* `[#draft]`  <sub>bl_trap_4</sub>
- ▸ **Klemmen lassen.**
  - *Du lässt sie. Sie hat sich dort eingerichtet.* `[#draft]`  <sub>bl_trap_5</sub>

### BL7 · `glass`

- *Im Flachwasser liegt ein Stück Glas, blau, von der Strömung rund gerieben.* `[#draft]`  <sub>bl_glass_1</sub>
- ▸ **Herausholen.**
  - *Du fischst es heraus. Nass ist es noch blauer.* `[#draft]`  <sub>bl_glass_2</sub>
- ▸ **Liegen lassen.**
  - *Du lässt es liegen. Der Bach dreht es um, als wollte er nachsehen.* `[#draft]`  <sub>bl_glass_3</sub>

### BL8 · `table`

*wenn* `fragment.bank_table`
  - *Das Brett auf den zwei Stümpfen. Die zwei Ringe.* `[#draft]`  <sub>bl_table_5</sub>
*sonst*
  - *Zwei Baumstümpfe am Ufer, ein Brett darüber. Auf dem Brett zwei Ringe, wo Becher gestanden haben.* `[#draft]`  <sub>bl_table_1</sub>
  - *Beide Stümpfe sind glatt gesessen. Beide stehen zum Wasser hin.* `[#draft]`  <sub>bl_table_2</sub>
  - *Du setzt dich auf den einen. Das Brett wackelt nicht. Wer das gebaut hat, konnte das.* `[#draft]`  <sub>bl_table_3</sub>
  - *Für einen Atemzug stehen zwei Becher auf dem Brett, und es dampft aus ihnen. Dann ist da wieder nur Holz.* `[#draft]`  <sub>bl_table_4</sub>

### BL9 · `dry_bed`

*wenn* `fragment.dry_bed`
  - *Die trockene Rinne, die Kiesel alle gleich gedreht.* `[#draft]`  <sub>bl_bed_5</sub>
*sonst*
  - *Neben dem Bach läuft eine Rinne, so breit wie er, aber trocken. Kiesel liegen darin, alle in dieselbe Richtung gedreht.* `[#draft]`  <sub>bl_bed_1</sub>
  - *Hier ist er einmal geflossen. Irgendwann lag er ein Stück daneben.* `[#draft]`  <sub>bl_bed_2</sub>
  - *Du gehst ein paar Schritte in der Rinne. Es ist still darin. Das Rauschen kommt von nebenan.* `[#draft]`  <sub>bl_bed_3</sub>
  - *Für einen Atemzug liegt Wasser in der Rinne, glatt und leise. Dann sind es wieder Kiesel.* `[#draft]`  <sub>bl_bed_4</sub>

### BL10 · `goat_trace`

*wenn* `valley.goat_prints_seen`
  - *Die Hufabdrücke im Moos, in einer Reihe.* `[#draft]`  <sub>bl_goat_3</sub>
*sonst*
  - *Auf dem Balken, der das Wasser staut, stehen Hufabdrücke im Moos. Eine Reihe, genau hintereinander.* `[#draft]`  <sub>bl_goat_1</sub>
  - *Der Balken ist schmal. Das Wasser zu beiden Seiten ist tief. Das wurde der Ziege offenbar nicht gesagt.* `[#draft]`  <sub>bl_goat_2</sub>

### BL11 · `look_back`

*wenn* `valley.view_back_seen`
  - *Der Rauch über den Bäumen. Das Haus.* `[#draft]`  <sub>bl_back_3</sub>
*sonst*
  - *Über den Bäumen steht dünner Rauch, gerade nach oben. Das Haus.* `[#draft]`  <sub>bl_back_1</sub>
  - *Von hier aus zieht der Kamin ausgezeichnet.* `[#draft]`  <sub>bl_back_2</sub>

### BL12 · `bach_wait`

- *Hinter der Hecke geht ein Pfad am Bach entlang. Der Regen hat ihn zu Matsch gemacht.* `[#draft]`  <sub>bl_wait_1</sub>

## haus


### H6 · `window`

*wenn* `abend`
  - *Im Fenster spiegelt sich das Feuer. Dahinter wird das Tal golden.*  <sub>haus_window_3</sub>
  - *Weiter unten steigt vom Bach Nebel auf.* `[#draft]`  <sub>haus_window_4</sub>
*sonst wenn* `is_fire_lit()`
  - *Im Fenster spiegelt sich das Feuer. Dahinter regnet es auf das Tal.*  <sub>haus_window_2</sub>
*sonst*
  - *Draußen regnet es auf das Tal. Am anderen Ufer glimmt ein kleines Feuer.*  <sub>haus_window_1</sub>
