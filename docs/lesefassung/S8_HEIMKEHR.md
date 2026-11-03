# S8 Heimkehr (Akt IV)

<!-- Erzeugt mit `python3 tools/writing/readable.py`. Nicht von Hand ändern: Änderungen gehören in die .dialogue-Dateien. -->

Lesefassung: der Text in der Reihenfolge, in der das Spiel ihn zeigt. *Kursiv* ist Erzählung, **fett** sprechen die Figuren, ▸ sind deine Antworten. Eingerückt steht, was nur unter einer Bedingung oder nach einer Antwort kommt. Hinter jeder Zeile die ID in klein.

**So antwortest du:** je Szene (E3, T12 …) „OK“, „ändern: …“ oder „raus“. Was du nicht nennst, gilt als OK.


## strasse


### S1-9 · `dawn`

> =============================================================================================================================
> S8: die Heimkehr (Akt IV, Segment S8; docs/akt4/REGIONSBRIEFE.md O15). Wer nach dem Streit aus der Stadt auf die Straße tritt, in der Stufe home der Heldenquest, sieht es hell werden: ohne Ereignis,
> ohne ein Wort über Mira, die Stadt oder die Nacht davor. Die Szene spielt den Cue einmal, beim ersten Betreten von der Stadt aus; die Straße ist dieselbe wie auf dem Hinweg, nur der Tag ist neu (die
> Krähe auf der Vogelscheuche, str_crow_2, ist wieder da). Nichts wird gesetzt. Zeilen-IDs str_dawn_*.
> =============================================================================================================================

- *Auf der Straße wird es hell, ohne dass etwas Besonderes geschieht.* `[#draft]`  <sub>str_dawn_1</sub>
- *Der Himmel über den Feldern wird erst grau, dann heller, dann einfach Tag. Die Krähe sitzt schon wieder auf der Vogelscheuche.* `[#draft]`  <sub>str_dawn_2</sub>

## heimkehr


### S8-1 · `home_in`

- *Im Haus riecht es nach Holz und nach kaltem Tee.* `[#draft]`  <sub>hk4_in_1</sub>
- *Der Antreiber sitzt an der Werkbank und sieht nicht auf. Sein Hobel geht über ein Brett, von dem nichts mehr abfällt.* `[#draft]`  <sub>hk4_in_2</sub>

### S8-2 · `tess_in`

> --- Tess kommt -----------------------------------------------------------------------------------------------------------------
> Sie steht schon im Raum (die Tür ist offen, sie ist bis vor den Tisch gegangen). Geklopft hat sie mit dem Ende eines Bretts: ein Ding, das sie nicht erklärt. Wer sie nie getroffen hat, liest ihren
> Namen auf dem Zollstock, wie in der Werkstatt (wer_tess_2); wer sie kennt, liest die Zeile nicht. Sie ist nicht zufällig hier, und sie sagt es, ohne zu sagen, warum. "Ich zeig's dir einmal. Dann bist
> du dran." ist ihr Satz aus der Werkstatt (wer_offer_1), das Haus wird gebaut, nicht geschenkt; "Halt mal." führt in die Arbeit.

- *Geklopft hat sie mit dem Ende eines Bretts. Jetzt steht sie mitten im Raum, ein Bündel Bretter auf der Schulter.* `[#draft]`  <sub>hk4_tess_1</sub>
*wenn* `city.tess_met nicht`
  - *Am Gürtel hängt ein Zollstock, in dessen Kante ein Wort geritzt ist, »Tess«.* `[#draft]`  <sub>hk4_tess_2</sub>
- **Tess:** Ich bin nicht zufällig hier. `[#draft]`  <sub>hk4_tess_3</sub>
- **Tess:** Zwei Regale, eine Leiste. Die Wand verträgt das. `[#draft]`  <sub>hk4_tess_4</sub>
- **Tess:** Ich zeig's dir einmal. Dann bist du dran. `[#draft]`  <sub>hk4_tess_5</sub>
- **Tess:** Halt mal. `[#draft]`  <sub>hk4_tess_6</sub>

### S8-3 · `build`

> --- Die Regale ----------------------------------------------------------------------------------------------------------------
> Das Flag steht vor der ersten Zeile: die Karte hängt die Regale und die Leiste in dem Augenblick auf, in dem der Text von ihnen spricht (eine Mutation läuft, wenn ihre Zeile verlangt wird). Darum
> beginnt die erste Zeile mit dem, was dann an der Wand hängt, und erzählt erst danach, wie der erste Nagel kam. Sie zeigt es einmal und gibt den Hammer weiter; sie sieht zu, die Daumen in der
> Schürze (wie am Bock, wer_saw_4), und hilft nicht ungefragt. Kein Lob für die Nägel, keine Wertung.

- *Zwei Regale und eine Leiste mit zwei Haken hängen an der Wand. Der erste Nagel steckt schräg, so hat Tess ihn geschlagen.* `[#draft]`  <sub>hk4_build_1</sub>
- *Alle anderen Nägel sind deine. Tess hat zugesehen, die Daumen in der Schürze.* `[#draft]`  <sub>hk4_build_2</sub>

### S8-4 · `bench`

> --- Die Werkbank --------------------------------------------------------------------------------------------------------------
> Sie prüft die Fugen mit dem Daumen, und der Antreiber hält den Hobel still: ein Bild, kein Satz über ihn (er sagt nichts, sie fragt nichts). "Dicht" hat damit einen Gegenstand, die Fuge der Platte.
> Das Urteil ist ihre Art zu sagen, dass es hält, und kein Lob. Danach geht es sofort weiter: kein Nachsatz, kein Witz, keine Antwort von ihm.

- *Tess beugt sich über die Werkbank und fährt mit dem Daumen über jede Fuge. Der Antreiber hält den Hobel still.* `[#draft]`  <sub>hk4_bench_1</sub>
- **Tess:** Schief. Aber dicht. `[#draft]`  <sub>hk4_bench_2</sub>

### S8-5 · `bread`

> --- Das Brot --------------------------------------------------------------------------------------------------------------------
> Das Brot des Gefälligen aus S5 (item_loaf, Brief O18): "Er kocht zu viel." Der Humor sitzt im Brot und in der Tasche, in der sonst der Zollstock steckt, nie im Gefälligen, über den sie ohne ein
> Urteil spricht ("der mit den Zetteln" ist ein Bild, kein Name; wer ihn nie getroffen hat, kennt die Zettel vom Brett auf dem Platz). Das Flag steht vor der ersten Zeile: das Brot liegt auf dem Tisch,
> wenn sie es hinlegt. Es ist das Brot auf dem Leinentuch, nichts Neues im Inventar.

- *Aus der Schürzentasche, in der sonst der Zollstock steckt, kommt ein Brot in einem Leinentuch. Tess legt es auf den Tisch.* `[#draft]`  <sub>hk4_bread_1</sub>
- **Tess:** Der mit den Zetteln hat mir das mitgegeben. Er kocht zu viel. `[#draft]`  <sub>hk4_bread_2</sub>

### S8-6 · `home_close`

> --- Der Stuhl bleibt ----------------------------------------------------------------------------------------------------------
> Sie sitzt (die Szene setzt house.guest_tess, der Stuhl steht dann da) und bricht das Brot, ohne zu fragen, ob jemand will: die Wärme ist die Hand, nicht das Wort. Der letzte Satz handelt von Holz,
> nicht von der Nacht und nicht von der Stadt; er ist ein Handgriff, keine Lebensregel ("Kiefer arbeitet" meint, dass Holz sich bewegt). Das letzte Wort hat das Haus: der Stuhl, der Geruch, der Tee,
> der noch genauso kalt ist wie zu Beginn. Die Szene lässt sie nach der letzten Zeile aufstehen und gehen; die Zeile steht davor und sagt, was dann bleibt. Die Erinnerung und die Beziehung stehen vor
> der ersten Zeile (sie war da und hat es gezeigt), kein Fazit, kein Zähler.

- *Tess setzt sich, bricht ein Stück vom Brot ab und schiebt es dir hin, ohne zu fragen, ob du willst.* `[#draft]`  <sub>hk4_close_1</sub>
- **Tess:** Kiefer arbeitet noch. Nach dem ersten Regen sitzen die Nägel fester. `[#draft]`  <sub>hk4_close_2</sub>
- *Wenn sie geht, bleibt der Stuhl. Im Haus riecht es nach Harz und frischem Brot, und der Tee ist immer noch kalt.* `[#draft]`  <sub>hk4_close_3</sub>

### S8-7 · `slot_nothing`

> --- Die vier Plätze -------------------------------------------------------------------------------------------------------------
> Zwei Regalbretter und zwei Haken an der Leiste (shelf_3, shelf_4, wall_1, wall_2; Props CuriositySlot). Wer einen Platz untersucht und etwas Passendes bei sich trägt, wählt es aus einem Menü und stellt
> es dorthin; trägt sie nichts, sagt eine Zeile, dass hier nichts steht und nichts zum Hinstellen da ist. Beide Zeilen gelten für alle vier Plätze, Brett wie Haken: kein Lob, keine Wertung, kein Zähler,
> kein "noch nicht", keine Aufforderung zu suchen. Die Dinge sind teils bedeutsam, teils Unsinn (Bible §31), und das Haus fragt nicht danach.

- *Der Platz ist leer. In deinen Taschen liegt nichts, das hierher passt.* `[#draft]`  <sub>hk4_slot_1</sub>

### S8-8 · `slot_placed`

- *Du rückst es ein Stück zurecht und nimmst die Hand weg. Es bleibt.* `[#draft]`  <sub>hk4_slot_2</sub>
