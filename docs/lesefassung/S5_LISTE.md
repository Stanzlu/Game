# S5 Liste (Akt IV)

<!-- Erzeugt mit `python3 tools/writing/readable.py`. Nicht von Hand ändern: Änderungen gehören in die .dialogue-Dateien. -->

Lesefassung: der Text in der Reihenfolge, in der das Spiel ihn zeigt. *Kursiv* ist Erzählung, **fett** sprechen die Figuren, ▸ sind deine Antworten. Eingerückt steht, was nur unter einer Bedingung oder nach einer Antwort kommt. Hinter jeder Zeile die ID in klein.

**So antwortest du:** je Szene (E3, T12 …) „OK“, „ändern: …“ oder „raus“. Was du nicht nennst, gilt als OK.


## stadt


### S2-3 · `list_board`

> --- Das Zettelbrett und der Gefällige ---------------------------------------------------------------------------------
> Sechzehn Zettel sind offen (S2); siebzehn, achtzehn und neunzehn wachsen in S5 dazu (gef_list). Das Brett ist das Gesicht, das zu allem nickt.
> Der Gefällige entschuldigt sich, bevor er bittet, reiht Sätze mit "und" und "noch eben" und bricht ab ("— also, nur falls"). Er fragt dich
> nichts Konkretes und hat beim ersten Treffen keine Aufgabe für dich (die Liste beginnt beim zweiten Besuch, S5). Der Text lacht nie über ihn; nicken darf nur das Brett.
> Das Flag city.gef_met setzt und liest dieser Cue.
> Ab list.opened (S5) zählt das Brett neunzehn und zeigt, was fehlt und was durchgestrichen ist; ohne das Flag bleibt der Wortlaut von S2, Zeichen für Zeichen.

*wenn* `list.opened`
  - *Neunzehn Zettel, nummeriert, nicht mehr alle offen. Wo einer fehlt, steckt die Nadel allein im Kork.* `[#draft]`  <sub>stadt_list_1</sub>
  - *Die durchgestrichenen hängen weiter, jeder mit dem kleinen runden »Tut mir leid« daneben.* `[#draft]`  <sub>stadt_list_2</sub>
  - *Zwei Zettel sind ganz leer und hängen trotzdem da.* `[#draft]`  <sub>stadt_list_3</sub>
  - *→ Ende des Szenenstücks*
- *Das Brett ist so voll, dass die Zettel einander halten, jeder in einer anderen Handschrift, manche mit Nadel, manche mit Wachs.* `[#draft]`  <sub>stadt_board_1</sub>
- *Sechzehn Zettel, nummeriert, alle offen. »Leiter halten.« »Strauß abholen.« »Bühne, wer kann.« »Irgendwas mit Brot.«* `[#draft]`  <sub>stadt_board_2</sub>
- *Andere sind durchgestrichen. Daneben steht in kleiner, runder Schrift immer dasselbe, »Tut mir leid«.* `[#draft]`  <sub>stadt_board_3</sub>
- *Ein Zettel ist ganz leer und hängt trotzdem da. Das Brett sieht aus wie ein Gesicht, das zu allem nickt.* `[#draft]`  <sub>stadt_board_4</sub>

### S2-6 · `gef_again`

*wenn* `list.closed`
  - *→ weiter bei* `gef_after`
- **Gefälliger:** Ach, du bist es! Entschuldige, ich bin noch dabei. Es ist gleich — es wird gleich. `[#draft]`  <sub>stadt_gef_9</sub>
- *→ weiter bei* `gef_list`

### S2-15 · `mira_list`

> =============================================================================================================================
> S5: die Liste (Akt IV, Segment S5; docs/akt4/REGIONSBRIEFE.md O5, O7, O11, O18). Die neuen Cues stehen am Ende der Datei, damit die Nummern der Cues von S2 in den
> Lesefassungen gleich bleiben. Sprünge aus S2 hierher: mira_square (bei list.opened), gef_again (zu gef_list, nach list.closed zu gef_after), list_board (Zweig bei list.opened).
> =============================================================================================================================
> Mira am Rand der Liste (O11, zweiter Beat): sobald der Gefällige die Liste geöffnet hat (list.opened), springt mira_square hierher. Ein Zettel steckt in ihrem
> Netz, sie liest ihn einmal und sagt Nein, ohne Mühe und ohne Grund. Ein Gegenbild, das der Text nie kommentiert: kein Trost, kein Lob, keine Frage an dich,
> kein Wort über den Gefälligen. Keine Erinnerung und kein Flag (die letzte Variante der Erinnerung gehört dem Streit in S7).

- *Zwischen den Maschen von Miras Netz steckt ein Zettel, den jemand im Vorbeigehen dort gelassen hat. Sie liest ihn einmal.* `[#draft]`  <sub>stadt_list_4</sub>
- **Mira:** Nein. `[#draft]`  <sub>stadt_list_5</sub>
- *Sie faltet ihn zweimal, schiebt ihn zurück zwischen die Maschen und knotet weiter.* `[#draft]`  <sub>stadt_list_6</sub>

### S2-16 · `gef_list`

> --- Die Liste (S5) -------------------------------------------------------------------------------------------------------------
> Die Signature-Begegnung des Gefälligen (Bible §14, O5): beim zweiten Besuch am Brett springt gef_again nach gef_list, solange die Liste nicht geschlossen ist.
> Er hängt siebzehn, achtzehn und neunzehn dazu, entschuldigt sich vor jedem und bittet nicht, er fragt nur. Drei Gruppen hintereinander (list_pick_1 bis 3) nennen
> die Zettel, die noch nicht genommen sind; bis zu drei nimmt die Spielerin. "Das reicht." (in der ersten Gruppe "Keine.") und das Schweigen führen zum Nein in
> list_close. Jede Aufgabe trägt einen Wert aus Akt II (Bible §18): Nähe (Strauß, Leiter), Freiheit (Bühne, Ziege), Ruhe (Brot, Fundbüro); die Reihenfolge der Antworten
> verrät es nicht, und kein Wert wird genannt oder bevorzugt. Wer den Wert hat, setzt mit der passenden Aufgabe die Facette integrity; list_close liest sie (die
> zusätzliche Antwort "Das sind meine." neben den unbedingten). Die Wahl steht nur in diesen Cues: ihre Folgen liest die Karte (ein frischer Zettel am Ort der
> genommenen, ein durchgestrichener am Ort der abgelehnten Aufgabe), nie dieser Cue. Kein Zeitlimit, kein Scheitern, niemand stirbt; das Nein tut ihm weh, er hält es aus
> und bleibt warm. Der Text lacht nie über ihn, nur über den Ablauf der Liste.

- *Auf dem Sims unter dem Brett liegen drei Zettel, die Tinte noch nass. Den ersten hält er vor die Brust, ohne ihn anzuheften.* `[#draft]`  <sub>stadt_list_7</sub>
- **Gefälliger:** Entschuldige. Der ist eben noch dazugekommen, ich konnte nicht — es sind jetzt siebzehn. `[#draft]`  <sub>stadt_list_8</sub>
- *Er heftet ihn ans Brett, »Ziege, vom Dach.«, und streicht ihn zweimal glatt.* `[#draft]`  <sub>stadt_list_9</sub>
- **Gefälliger:** Und der. Entschuldige. Achtzehn. Das Fundbüro hat gefragt, wohin damit, und ich habe gesagt, ich sehe nach. `[#draft]`  <sub>stadt_list_10</sub>
- *Die Nadel für »Fundbüro, wohin damit.« geht schief hinein. Er zieht sie heraus und steckt sie noch einmal.* `[#draft]`  <sub>stadt_list_11</sub>
- **Gefälliger:** Der neunzehnte ist noch leer. Falls etwas kommt. Entschuldige. `[#draft]`  <sub>stadt_list_12</sub>
- *Er hängt ihn neben den leeren, der schon da war. Das Brett nickt dazu, wie es zu allem nickt.* `[#draft]`  <sub>stadt_list_13</sub>
- *Dann zeigt er auf sechs Zettel, einen nach dem anderen, ohne einen zu berühren.* `[#draft]`  <sub>stadt_list_14</sub>
*wenn* `main_city_way und town`
*wenn* `main_city_way und help`
- *→ weiter bei* `list_pick_1`

### S2-17 · `list_pick_1`

> --- Die Wahl: drei Gruppen -------------------------------------------------------------------------------------------------------
> Jede Gruppe nennt, was noch nicht genommen ist; die Reihenfolge mischt die Werte. Eine genommene Aufgabe setzt (bei passendem Wert zuerst die Facette) ihr Flag
> list.take_<kennung> und führt zur nächsten Gruppe, nach der dritten zum Nein. Die Zeile des Gefälligen am Anfang der nächsten Gruppe ist seine Antwort auf die
> Wahl: er bedankt sich zu viel und entschuldigt sich dafür. Jede Gruppe hat eine unbedingte Antwort ("Das reicht.", in der ersten "Keine.") und das Schweigen zuletzt.

- **Gefälliger:** Ich bitte dich nicht. Ich frage nur. Falls etwas davon passt. Wenn nicht, ist das ganz — `[#draft]`  <sub>stadt_list_15</sub>
- ▸ **Den Strauß.** *(wenn `list.take_bouquet nicht`)*
  *wenn* `value.closeness`
  - *→ weiter bei* `list_pick_2`
- ▸ **Die Bühne.** *(wenn `list.take_stage nicht`)*
  *wenn* `value.freedom`
  - *→ weiter bei* `list_pick_2`
- ▸ **Das Brot.** *(wenn `list.take_bread nicht`)*
  *wenn* `value.calm`
  - *→ weiter bei* `list_pick_2`
- ▸ **Die Leiter.** *(wenn `list.take_ladder nicht`)*
  *wenn* `value.closeness`
  - *→ weiter bei* `list_pick_2`
- ▸ **Die Ziege.** *(wenn `list.take_goat nicht`)*
  *wenn* `value.freedom`
  - *→ weiter bei* `list_pick_2`
- ▸ **Das Fundbüro.** *(wenn `list.take_lost nicht`)*
  *wenn* `value.calm`
  - *→ weiter bei* `list_pick_2`
- ▸ **Keine.**
  - *→ weiter bei* `list_none`
- ▸ **…**
  - *→ weiter bei* `list_wait`

### S2-18 · `list_pick_2`

- **Gefälliger:** Danke. Danke, wirklich. Entschuldige, einmal hätte gereicht. Noch eine? Nur falls. `[#draft]`  <sub>stadt_list_16</sub>
- ▸ **Den Strauß.** *(wenn `list.take_bouquet nicht`)*
  *wenn* `value.closeness`
  - *→ weiter bei* `list_pick_3`
- ▸ **Die Bühne.** *(wenn `list.take_stage nicht`)*
  *wenn* `value.freedom`
  - *→ weiter bei* `list_pick_3`
- ▸ **Das Brot.** *(wenn `list.take_bread nicht`)*
  *wenn* `value.calm`
  - *→ weiter bei* `list_pick_3`
- ▸ **Die Leiter.** *(wenn `list.take_ladder nicht`)*
  *wenn* `value.closeness`
  - *→ weiter bei* `list_pick_3`
- ▸ **Die Ziege.** *(wenn `list.take_goat nicht`)*
  *wenn* `value.freedom`
  - *→ weiter bei* `list_pick_3`
- ▸ **Das Fundbüro.** *(wenn `list.take_lost nicht`)*
  *wenn* `value.calm`
  - *→ weiter bei* `list_pick_3`
- ▸ **Das reicht.**
  - *→ weiter bei* `list_enough`
- ▸ **…**
  - *→ weiter bei* `list_wait`

### S2-19 · `list_pick_3`

- **Gefälliger:** Danke. Das sind zwei. Eine noch, wenn du magst, und dann ist es genug. Wirklich. `[#draft]`  <sub>stadt_list_17</sub>
- ▸ **Den Strauß.** *(wenn `list.take_bouquet nicht`)*
  *wenn* `value.closeness`
  - *→ weiter bei* `list_close`
- ▸ **Die Bühne.** *(wenn `list.take_stage nicht`)*
  *wenn* `value.freedom`
  - *→ weiter bei* `list_close`
- ▸ **Das Brot.** *(wenn `list.take_bread nicht`)*
  *wenn* `value.calm`
  - *→ weiter bei* `list_close`
- ▸ **Die Leiter.** *(wenn `list.take_ladder nicht`)*
  *wenn* `value.closeness`
  - *→ weiter bei* `list_close`
- ▸ **Die Ziege.** *(wenn `list.take_goat nicht`)*
  *wenn* `value.freedom`
  - *→ weiter bei* `list_close`
- ▸ **Das Fundbüro.** *(wenn `list.take_lost nicht`)*
  *wenn* `value.calm`
  - *→ weiter bei* `list_close`
- ▸ **Das reicht.**
  - *→ weiter bei* `list_enough`
- ▸ **…**
  - *→ weiter bei* `list_wait`

### S2-20 · `list_none`

> Die drei Ausgänge ohne Aufgabe teilen ihre Zeile über alle Gruppen: "Keine." nimmt er an und entschuldigt sich nicht dafür, "Das reicht." nimmt er an, das Schweigen
> wartet er ab und füllt es nicht. Alle drei führen in das Nein.

- **Gefälliger:** Keine. Gut. Ja. Gut. `[#draft]`  <sub>stadt_list_18</sub>
- *→ weiter bei* `list_close`

### S2-21 · `list_enough`

- **Gefälliger:** Ja. Das reicht. Das reicht sogar sehr. `[#draft]`  <sub>stadt_list_19</sub>
- *→ weiter bei* `list_close`

### S2-22 · `list_wait`

- *Du sagst nichts. Er wartet, die Nadel still zwischen den Fingern, und fängt keinen Satz an.* `[#draft]`  <sub>stadt_list_20</sub>
- *→ weiter bei* `list_close`

### S2-23 · `list_close`

> --- Das Nein -----------------------------------------------------------------------------------------------------------------------
> "Die anderen nicht." ist die ganze Antwort, ohne Grund (Grenzen II). Er zuckt, entschuldigt sich einmal und hält es aus. Wer mit einem Wert gewählt hat (Facette integrity),
> hat daneben "Das sind meine."; das Schweigen bleibt die letzte Antwort. Jeder Ausgang schließt die Liste (Quest und Flag list.closed): ab hier hängen die nicht genommenen
> Zettel durchgestrichen an ihrem Ort. Die Folgen stehen nicht in diesem Cue, die Karte liest das Flag.

- **Gefälliger:** Und die übrigen Zettel? Ich frage nur, damit ich weiß, was ich sage, wenn jemand fragt. `[#draft]`  <sub>stadt_list_21</sub>
- ▸ **Die anderen nicht.**
  - *Er zuckt, kaum sichtbar, wie bei einem Geräusch hinter ihm. Die Nadel bleibt in der Luft stehen.* `[#draft]`  <sub>stadt_list_22</sub>
  - **Gefälliger:** Entschuldige. Das war — ich wollte nur — `[#draft]`  <sub>stadt_list_23</sub>
  - *Er hört auf. Er atmet aus, lässt die Hand sinken und sagt nichts mehr dazu.* `[#draft]`  <sub>stadt_list_24</sub>
  - *→ weiter bei* `list_sit`
- ▸ **Das sind meine.** *(wenn `integrity`)*
  - **Gefälliger:** Deine. Ja. `[#draft]`  <sub>stadt_list_25</sub>
  - *Er nickt langsam. Sein Blick geht zu den Zetteln, die du nicht genommen hast. Er lässt ihn dort.* `[#draft]`  <sub>stadt_list_26</sub>
  - *→ weiter bei* `list_sit`
- ▸ **…**
  - *Du schweigst. Er wartet, ob noch etwas kommt, und es kommt nichts.* `[#draft]`  <sub>stadt_list_27</sub>
  - **Gefälliger:** Dann bleiben sie hängen. Das ist — in Ordnung. Entschuldige. `[#draft]`  <sub>stadt_list_28</sub>
  - *→ weiter bei* `list_sit`

### S2-24 · `list_sit`

> --- Das Brot (Grenzen III) ---------------------------------------------------------------------------------------------------------
> Nach dem Nein setzt er sich zu dir (eine Erzählzeile, die Szene bewegt ihn nicht: er bleibt am Brett). Das Brot ist ein Geschenk, kein Handel: "Nehmen." führt in die
> Küche, "Nein, danke." und das Schweigen lässt er warm und ohne Kränkung stehen, er isst es selbst. Beide Wege sind gleichwertig; list.sat setzt sich beim Hinsetzen, gef_after (über gef_again) liest es.

- *Er setzt sich neben dich, die Taschen noch voll, und sagt eine Weile nichts. Die Stifte darin klappern, wenn er atmet.* `[#draft]`  <sub>stadt_list_29</sub>
- *Dann holt er ein Brot aus der Tasche, im Tuch, noch lauwarm, und hält es dir mit beiden Händen hin.* `[#draft]`  <sub>stadt_list_30</sub>
- **Gefälliger:** Ich habe zu viel gebacken. Immer. Du musst nicht. `[#draft]`  <sub>stadt_list_31</sub>
- ▸ **Nehmen.**
  - *Du nimmst es. Das Tuch ist warm, der Laib darin schwer.* `[#draft]`  <sub>stadt_list_32</sub>
  - **Gefälliger:** Ach. Es ist nur Brot. Es ist noch mehr da. Entschuldige die Küche, ich hatte nicht — komm. `[#draft]`  <sub>stadt_list_33</sub>
  - *→ weiter bei* `list_kitchen`
- ▸ **Nein, danke.**
  - **Gefälliger:** Gut. Ja. Dann esse ich es selbst. `[#draft]`  <sub>stadt_list_34</sub>
  - *Er bricht ein Stück ab und kaut langsam. Es ist das erste Mal, dass du ihn essen siehst.* `[#draft]`  <sub>stadt_list_35</sub>
- ▸ **…**
  - *Du sagst nichts. Er hält das Brot noch einen Atemzug hin, dann bricht er ein Stück ab und isst.* `[#draft]`  <sub>stadt_list_36</sub>

### S2-25 · `list_kitchen`

> --- Das Warum, als Ding ----------------------------------------------------------------------------------------------------------------
> Wer das Brot nimmt, folgt ihm in die Küche (Erzählung, kein Ort). Über dem Herd hängt eine Reihe Zettel in fremder Handschrift; der älteste ist verblasst und trägt keinen
> Namen. Keine Zeile erklärt etwas: kein Elternteil, kein Täter, keine Ursache, keine Wirkung auf dich (Bible §15, §51). Er sagt nur, dass sie schon lange da hängen, und gibt
> dir den blassesten mit, wie das Brot. Der Zettel ist eine Kuriosität.

- *Seine Küche ist eng und warm. Auf Tisch, Stuhl und Fensterbrett liegen Laibe unter Tüchern.* `[#draft]`  <sub>stadt_list_37</sub>
- *Über dem Herd hängt eine Schnur mit Zetteln, jeder in anderer Schrift. »Kein Salz.« »Nur das Weiche.« »Nicht vor acht.«* `[#draft]`  <sub>stadt_list_38</sub>
- *Der erste ganz links ist so blass, dass man ihn eher fühlt als liest. Einen Namen trägt er nicht.* `[#draft]`  <sub>stadt_list_39</sub>
- **Gefälliger:** Die hängen da schon lange. `[#draft]`  <sub>stadt_list_40</sub>
- *Er sieht nicht hinauf. Er schiebt ein Blech in den Ofen, und die Schnur schwingt ein wenig mit.* `[#draft]`  <sub>stadt_list_41</sub>
- *Als du gehst, nimmt er den blassen Zettel von der Schnur und hält ihn dir hin, wie vorhin das Brot.* `[#draft]`  <sub>stadt_list_42</sub>
- **Gefälliger:** Nimm den. Er liest sich eh nicht mehr. `[#draft]`  <sub>stadt_list_43</sub>
- *Wo er hing, hängt die Klammer leer an der Schnur.* `[#draft]`  <sub>stadt_list_44</sub>

### S2-26 · `gef_after`

> --- Danach -----------------------------------------------------------------------------------------------------------------------------------
> Wer ihn nach der Liste anspricht, hört eine kurze Zeile ohne Erklärung und ohne Lehre. Er entschuldigt sich weniger, aber nicht gar nicht; list.kitchen_seen und list.sat
> entscheiden, ob er vom Brot der Küche oder vom nächsten Backen spricht.

- *Er steht am Brett, die Nadel im Ärmel, und hängt nichts auf.* `[#draft]`  <sub>stadt_list_45</sub>
*wenn* `list.kitchen_seen`
  - **Gefälliger:** Ich habe wieder gebacken. Es riecht bis zum Brunnen, sagt jemand. Entschuldige. `[#draft]`  <sub>stadt_list_46</sub>
*sonst wenn* `list.sat`
  - **Gefälliger:** Ich backe morgen wieder. Es wird zu viel werden, wie immer. `[#draft]`  <sub>stadt_list_47</sub>

### S2-27 · `do_bouquet`

> --- Die Gänge --------------------------------------------------------------------------------------------------------------------------------
> Jede genommene Aufgabe hat am Ort einen frischen Zettel (die Karte liest list.take_<kennung>). Wer ihn liest, tut die Kleinigkeit: zwei oder drei Erzählzeilen, ohne Wert,
> ohne Lob, ohne dass jemand zusieht; am Ende steht list.done_<kennung>, das die Karte liest. Der Humor sitzt in den Dingen (der Hall, das Salz, die Spinne), nie im Gefälligen.

- *Vor der Ladentür steht ein Eimer mit einem Strauß, am Faden ein frischer Zettel, »Strauß abholen.«* `[#draft]`  <sub>stadt_list_48</sub>
- *Auf der Rückseite steht klein »Für den vom Brett.« Du hebst den Strauß heraus, das Wasser läuft dir in den Ärmel.* `[#draft]`  <sub>stadt_list_49</sub>
- *Am Brett legst du ihn auf den Sims. Er ist nass und riecht gegen die Tinte an.* `[#draft]`  <sub>stadt_list_50</sub>

### S2-28 · `do_ladder`

- *Vor der Werkstatt lehnt eine Leiter, am Holm ein frischer Zettel, »Leiter halten.« Oben klopft jemand, den du nicht siehst.* `[#draft]`  <sub>stadt_list_51</sub>
- *Bei jedem Schlag rutscht der Fuß. Du stellst den Schuh davor und hältst die Holme, und das Klopfen wird gleichmäßiger.* `[#draft]`  <sub>stadt_list_52</sub>
- *Irgendwann hört es auf, und die Leiter zieht sich dir aus den Händen, nach oben. Niemand ruft etwas herunter.* `[#draft]`  <sub>stadt_list_53</sub>

### S2-29 · `do_stage`

- *Am Rand des Platzes liegen Bretter auf Böcken, ein Hammer, eine Tasse voller Nägel und ein frischer Zettel, »Bühne, wer kann.«* `[#draft]`  <sub>stadt_list_54</sub>
- *Du schlägst zwei Nägel in die Fuge zwischen zwei Brettern. Das ist ein halber Meter Boden, mehr nicht.* `[#draft]`  <sub>stadt_list_55</sub>
- *Es hallt über den Platz, hohl und ziemlich laut. Niemand sieht her.* `[#draft]`  <sub>stadt_list_56</sub>

### S2-30 · `do_goat`

- *Am Fuß des Rathauses liegt ein Bündel Heu, darauf ein frischer Zettel, »Ziege, vom Dach.«* `[#draft]`  <sub>stadt_list_57</sub>
- *Oben auf dem First sieht die Ziege dir zu. Du rufst nicht, du legst das Heu in den Schatten der Traufe.* `[#draft]`  <sub>stadt_list_58</sub>
- *Sie kaut, ohne den Blick zu senken. Sie bleibt oben, das Heu bleibt unten, und keiner hat es eilig.* `[#draft]`  <sub>stadt_list_59</sub>

### S2-31 · `do_bread`

- *Auf dem Tisch am Platz liegt das Brot, noch unter Spatzen, am Rand ein frischer Zettel, »Irgendwas mit Brot.«* `[#draft]`  <sub>stadt_list_60</sub>
- *Du schneidest die Seite ab, auf der keiner sitzt, und legst sie neben das Salz. Den Rest lässt du ihnen.* `[#draft]`  <sub>stadt_list_61</sub>
- *Das Salz haben sie wieder nicht angerührt.* `[#draft]`  <sub>stadt_list_62</sub>

### S2-32 · `do_lost`

- *An der Rathaustür weht ein grauer Schal im Zug, am Knoten ein frischer Zettel, »Fundbüro, wohin damit.«* `[#draft]`  <sub>stadt_list_63</sub>
- *Du trägst den Schal hinein und legst ihn aufs unterste Brett der Fundstücke. Die Spinne dort rückt ein Stück zur Seite.* `[#draft]`  <sub>stadt_list_64</sub>

### S2-33 · `slip_struck`

> Alle durchgestrichenen Zettel (die nicht genommenen Aufgaben, ab list.closed) lesen sich gleich: ein Strich ohne Druck, daneben klein und rund die Entschuldigung. Er hängt noch,
> falls sich jemand umentscheidet; nichts geschieht, niemand wird gemahnt.

- *Der Zettel ist durchgestrichen, mit einem einzigen Strich, ohne Druck. Daneben steht, klein und rund, »Tut mir leid«.* `[#draft]`  <sub>stadt_list_65</sub>
- *Er hängt trotzdem noch da, falls sich jemand umentscheidet.* `[#draft]`  <sub>stadt_list_66</sub>
