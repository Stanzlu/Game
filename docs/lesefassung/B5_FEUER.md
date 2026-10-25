# B5: Feuer

<!-- Erzeugt mit `python3 tools/writing/readable.py`. Nicht von Hand ändern: Änderungen gehören in die .dialogue-Dateien. -->

Lesefassung: der Text in der Reihenfolge, in der das Spiel ihn zeigt. *Kursiv* ist Erzählung, **fett** sprechen die Figuren, ▸ sind deine Antworten. Eingerückt steht, was nur unter einer Bedingung oder nach einer Antwort kommt. Hinter jeder Zeile die ID in klein.

**So antwortest du:** je Szene (E3, T12 …) „OK“, „ändern: …“ oder „raus“. Was du nicht nennst, gilt als OK.


## feuer


### F1 · `house_hum`

- *Im Kamin zieht es. Der Zug klingt wie ein Summen, das einen Satz zu Ende bringt.* `[#draft]`  <sub>feu_hum_1</sub>
- *Dann knackt ein Scheit.* `[#draft]`  <sub>feu_hum_2</sub>

### F2 · `fire_values`

- *Die Tür ist zu, und das Feuer hält.* `[#draft]`  <sub>feu_1</sub>
- *Für eine Kleinigkeit ist noch Zeit.* `[#draft]`  <sub>feu_2</sub>
- ▸ **Die Tür einen Spalt offen lassen**
  - *Du schiebst die Tür eine Hand breit auf. Es zieht.* `[#draft]`  <sub>feu_3</sub>
  - *Das Feuer legt sich schräg, dem Spalt zu. Dann steht es wieder.* `[#draft]`  <sub>feu_4</sub>
- ▸ **Den zweiten Hocker ans Feuer stellen**
  - *Du trägst den zweiten Hocker vom Tisch ans Feuer.* `[#draft]`  <sub>feu_5</sub>
  - *Er wackelt hier weniger. Am Tisch fehlt er nicht.* `[#draft]`  <sub>feu_6</sub>
- ▸ **Dem Feuer zusehen, bis es dunkel wird**
  - *Das Licht im Fenster wird gelb, dann dünn.* `[#draft]`  <sub>feu_7</sub>
  - *Der Regen hat aufgehört. Im Eimer tropft es noch eine Weile weiter.* `[#draft]`  <sub>feu_8</sub>
- ▸ **…**
  - *Du lässt alles, wie es ist.* `[#draft]`  <sub>feu_9</sub>

## haus


### H1 · `fireplace`

*wenn* `is_fire_lit()`
  - *Das Feuer brennt. Manchmal knackt es, wenn das Harz aufplatzt.*  <sub>haus_fire_1</sub>
  - *Wärme. Erst an den Händen, dann überall.*  <sub>haus_fire_2</sub>
  - *Du legst nichts nach. Es brennt auch so.*  <sub>haus_fire_3</sub>
  *wenn* `value.freedom`
    - *Aus dem Türspalt zieht es. Das Feuer neigt sich ihm zu.* `[#draft]`  <sub>haus_fire_10</sub>
*sonst wenn* `item_dry_wood`
  - *Du schichtest das Holz in den Kamin, die Rinde nach unten, wie man es irgendwann mal gelernt hat.*  <sub>haus_fire_4</sub>
  - *Ein Streichholz. Noch eins. Dann fängt die Rinde.*  <sub>haus_fire_5</sub>
*sonst wenn* `valley.wood_needed`
  - *Der Kamin ist kalt. Der Zettel steckt noch am Sims. »Nicht trödeln.«*  <sub>haus_fire_6</sub>
*sonst*
  - *Der Kamin ist kalt. Asche von einem anderen Winter.*  <sub>haus_fire_7</sub>
  - *Im Korb daneben liegt nur Rinde. Das Holz draußen ist nass.*  <sub>haus_fire_8</sub>
  - *Am Sims steckt ein Zettel, krakelig beschrieben. »Trockenes Holz im Schuppen. Weg nach Westen. Nicht trödeln.«*  <sub>haus_fire_9</sub>
  *wenn* `main_valley_shelter und house`

### H2 · `table`

*wenn* `house.spoon_found`
  - *Der Tisch wackelt. Unter einem Bein klemmt ein gefaltetes Stück Papier, das nicht hilft.*  <sub>haus_table_3</sub>
  - *Ein Becher, den niemand abgewaschen hat. Seit dem Frühjahr nicht.*  <sub>haus_table_4</sub>
*sonst*
  - *Ein Tisch, zwei Hocker, ein Becher. In der Schublade liegt ein Löffel.*  <sub>haus_table_1</sub>
  - *Ein sehr kleiner Löffel. Du nimmst ihn mit, ohne genau zu wissen, warum.*  <sub>haus_table_2</sub>
*wenn* `value.closeness`
  - *Am Tisch steht nur noch ein Hocker. Der andere hat es warm.* `[#draft]`  <sub>haus_table_5</sub>

### H5 · `bucket`

*wenn* `is_fire_lit()`
  - *Es tropft in den Eimer. Plink. Lange nichts. Plink.*  <sub>haus_bucket_2</sub>
*sonst*
  - *Ein Eimer unter einer undichten Stelle im Dach. Halb voll. Jemand hat ihn hingestellt, bevor er gegangen ist.*  <sub>haus_bucket_1</sub>
*wenn* `value.calm`
  - *Der Regen ist vorbei. Der Eimer hat es noch nicht gehört.* `[#draft]`  <sub>haus_bucket_3</sub>

### H20 · `herbs`

> Das dritte Fragment von Akt II (B5): eine Spur der Welt, kein Bild des Kindes (Brief O5). Die Kräuter hängen
> schon in der Hülle des Raums unter dem Balken; der Punkt an der Wand gibt ihnen den Duft, sobald das Feuer brennt.
> Nichts wird erklärt: nicht, wer sie band, nicht, warum sie hängen blieben.

*wenn* `fragment.beam_herbs`
  - *Die Bündel unter dem Balken. Sie riechen nach Staub und ein wenig nach mehr.* `[#draft]`  <sub>haus_herbs_5</sub>
*sonst*
  - *Unter dem Balken hängen Bündel an Fäden, ein grünes und ein violettes. Die Kräuter sind steif geworden wie Papier.* `[#draft]`  <sub>haus_herbs_1</sub>
  - *Seit das Feuer brennt, steigt etwas von ihnen auf. Du hältst die Nase an das grüne.* `[#draft]`  <sub>haus_herbs_2</sub>
  - *Erst Staub, dann etwas Bitteres, dann etwas Warmes darunter. Wer sie gebunden hat, wusste, wie viel in eine Suppe gehört.* `[#draft]`  <sub>haus_herbs_3</sub>
  - *Für einen Atemzug riecht es grün und warm, als hinge der Sommer noch am Balken. Dann riecht es nach Rauch.* `[#draft]`  <sub>haus_herbs_4</sub>
