# G2 Hochtal (Akt V)

<!-- Erzeugt mit `python3 tools/writing/readable.py`. Nicht von Hand ändern: Änderungen gehören in die .dialogue-Dateien. -->

Lesefassung: der Text in der Reihenfolge, in der das Spiel ihn zeigt. *Kursiv* ist Erzählung, **fett** sprechen die Figuren, ▸ sind deine Antworten. Eingerückt steht, was nur unter einer Bedingung oder nach einer Antwort kommt. Hinter jeder Zeile die ID in klein.

**So antwortest du:** je Szene (E3, T12 …) „OK“, „ändern: …“ oder „raus“. Was du nicht nennst, gilt als OK.


## hochtal


### G2-1 · `valley_sign`

- *Am Eingang des Tals steht ein handgemaltes Schild, die Buchstaben ungleich groß. Es sagt »Aussicht«, und der Pfeil darunter zeigt auf eine Felswand.* `[#draft]`  <sub>hoch_valley_sign_1</sub>
- *Die Wand ist grau, nah und von oben bis unten Fels. Als Aussicht ist sie nicht falsch.* `[#draft]`  <sub>hoch_valley_sign_2</sub>

### G2-2 · `hand_stone`

> --- Die Hand (die erste Rückblende, Bild des Kindes) ------------------------------------------------------------------
> Ein flacher grauer Stein am Ufer, darauf der Abdruck einer kleinen Hand, Wasser statt Staub, noch nicht getrocknet. Ein stehendes
> Bild (Brief O7, Bible §15): vier Zeilen Erzählung und nicht mehr, kein Wort des Kindes, kein Kind genannt, kein Erwachsener, keine
> zweite Hand, kein Ort, kein Anlass, keine Ursache, kein Gefühlswort; kein Witz davor oder danach, auch nicht an den Dingen am Ufer.
> Die Spielerin beugt sich nur darüber. Das erste Mal setzt das Flag (Collection liest es), danach gibt es nur noch eine Zeile.
> Nie Voraussetzung: wer den Stein liegen lässt, kommt zur zentralen Szene wie jeder.

*wenn* `fragment.hand`
  - *Der flache Stein am Ufer. Der Abdruck darauf glänzt noch, und der Tropfen am Rand steht, wo er stand.* `[#draft]`  <sub>hoch_hand_5</sub>
*sonst*
  - *Am Ufer liegt ein flacher grauer Stein, trocken, bis auf eine Stelle in der Mitte.* `[#draft]`  <sub>hoch_hand_1</sub>
  - *Du beugst dich darüber. Dort ist der Abdruck einer Hand, klein und flach, die Finger gespreizt.* `[#draft]`  <sub>hoch_hand_2</sub>
  - *Wasser statt Staub. Der Abdruck glänzt noch, am Rand ist ein Tropfen herabgelaufen und stehen geblieben.* `[#draft]`  <sub>hoch_hand_3</sub>
  - *Das Licht wandert über den See. Der Abdruck bleibt, wie er ist, und trocknet nicht.* `[#draft]`  <sub>hoch_hand_4</sub>

### G2-3 · `stone_pick`

> --- Der Stein, der nicht liegen bleibt (Nebenquest, Humor und Welt) ---------------------------------------------------
> Ein kleiner runder Stein am Fuß des ersten Steinmännchens (Decor, "unless grat.stone_taken"): aufzuheben oder liegen zu lassen,
> beides kostet nichts. Das Einstecken setzt das Flag und gibt den Gegenstand; die Szene startet daraus die Quest side_grat_stone.
> Jedes der drei Steinmännchen des Tals bietet, solange der Stein in der Tasche ist, die Wahl "Den Stein obenauf legen." oder
> "Weitergehen." (der Cue cairn_N_offer); ohne Stein endet das Gespräch nach der Beschreibung, ohne eine einzelne Antwort. Die Versuche sind eigene Cues, damit Setzer und Leser
> eines Flags nie im selben Cue stehen: der erste lässt den Stein rollen, der zweite kippen, der dritte nimmt der Wind. Kein
> Lob, keine Lehre, kein Satz darüber, wohin ein Stein gehört; nach dem dritten hat man ihn eben in der Tasche, nichts ist gelöst
> und nichts gesperrt. Die Szene schließt die Quest, wenn alle drei Versuche gemacht sind.

- *Am Fuß des ersten Steinmännchens liegt ein kleiner runder Stein, so groß wie ein Ei. Er liegt, wie jemand sitzt, der gleich wieder aufsteht.* `[#draft]`  <sub>hoch_stone_1</sub>
- ▸ **Einstecken.**
  - *Du steckst ihn ein. In der Tasche rollt er nach links, zurück nach rechts und noch einmal nach links, bis die Naht ihn aufhält.* `[#draft]`  <sub>hoch_stone_2</sub>
- ▸ **Liegen lassen.**
  - *Du lässt ihn, wo er ist. Er hat die Haltung eines Steins, der es sich noch anders überlegen kann.* `[#draft]`  <sub>hoch_stone_3</sub>

### G2-4 · `cairn_1`

- *Das erste Steinmännchen im Hochtal ist unten breit und oben schmal, Stein auf Stein, ohne Mörtel und ohne Zweifel.* `[#draft]`  <sub>hoch_cairn_1_1</sub>
- *Auf dem obersten Stein ist eine kleine Mulde, gerade groß genug für etwas Rundes.* `[#draft]`  <sub>hoch_cairn_1_2</sub>
*wenn* `grat.stone_taken`
  - *→ weiter bei* `cairn_1_offer`

### G2-5 · `cairn_1_offer`

- ▸ **Den Stein obenauf legen.**
  - *→ weiter bei* `cairn_1_try`
- ▸ **Weitergehen.**
  - *→ Ende des Szenenstücks*

### G2-6 · `cairn_1_try`

- *Du legst den Stein obenauf. Er rollt über die Kante, hüpft zweimal und bleibt am Fuß des Steinmännchens liegen, ohne Eile.* `[#draft]`  <sub>hoch_cairn_1_try_1</sub>
- *Du hebst ihn auf. Er ist von der Sonne ein wenig warm, sonst unverändert.* `[#draft]`  <sub>hoch_cairn_1_try_2</sub>

### G2-7 · `cairn_2`

- *Das zweite Steinmännchen ist schmal und steht ein wenig schräg, wie jemand, der aufmerksam zuhört.* `[#draft]`  <sub>hoch_cairn_2_1</sub>
- *Obenauf fehlt eine Spitze. Dort wäre Platz.* `[#draft]`  <sub>hoch_cairn_2_2</sub>
*wenn* `grat.stone_taken`
  - *→ weiter bei* `cairn_2_offer`

### G2-8 · `cairn_2_offer`

- ▸ **Den Stein obenauf legen.**
  - *→ weiter bei* `cairn_2_try`
- ▸ **Weitergehen.**
  - *→ Ende des Szenenstücks*

### G2-9 · `cairn_2_try`

- *Du legst ihn obenauf und nimmst die Finger langsam weg. Er hält. Dann neigt er sich, so gemächlich wie mit Absicht, und fällt ins Gras.* `[#draft]`  <sub>hoch_cairn_2_try_1</sub>
- *Du hebst ihn auf. Das Steinmännchen steht da wie vorher und tut, als sei nichts geschehen.* `[#draft]`  <sub>hoch_cairn_2_try_2</sub>

### G2-10 · `cairn_3`

- *Das dritte Steinmännchen ist niedrig und breit. Man sieht ihm an, dass der Wind hier öfter vorbeikommt.* `[#draft]`  <sub>hoch_cairn_3_1</sub>
- *Der oberste Stein ist flach und breit, wie für Besuch eingerichtet.* `[#draft]`  <sub>hoch_cairn_3_2</sub>
*wenn* `grat.stone_taken`
  - *→ weiter bei* `cairn_3_offer`

### G2-11 · `cairn_3_offer`

- ▸ **Den Stein obenauf legen.**
  - *→ weiter bei* `cairn_3_try`
- ▸ **Weitergehen.**
  - *→ Ende des Szenenstücks*

### G2-12 · `cairn_3_try`

- *Du legst ihn obenauf. Ein Windstoß kommt die Wand herunter, schiebt ihn über die Kante und ist schon weiter.* `[#draft]`  <sub>hoch_cairn_3_try_1</sub>
- *Du hebst ihn aus dem Gras und steckst ihn ein. Die Tasche stellt keine Fragen.* `[#draft]`  <sub>hoch_cairn_3_try_2</sub>

### G2-13 · `quartz`

> --- Kuriosität: der Bergkristall --------------------------------------------------------------------------------------
> Decor im Geröll ("unless grat.quartz_taken"). Wie das Schieferplättchen: Einstecken gibt den Gegenstand und das Flag, Liegen
> lassen gibt nichts und kostet nichts.

- *Im Geröll steckt ein Bergkristall, fingerlang, an einem Ende abgebrochen. Er ist das Einzige hier, das dem Licht etwas zu antworten weiß.* `[#draft]`  <sub>hoch_quartz_1</sub>
- ▸ **Einstecken.**
  - *Du steckst ihn ein. Er wiegt mehr, als ein so kleiner Berg sollte.* `[#draft]`  <sub>hoch_quartz_2</sub>
- ▸ **Liegen lassen.**
  - *Du lässt ihn, wo er ist. Er funkelt weiter, auch ohne Zuschauer.* `[#draft]`  <sub>hoch_quartz_3</sub>

### G2-14 · `marmot_den`

> --- Kuriosität: der Hort des Murmeltiers ------------------------------------------------------------------------------
> Der Bau am Hang und davor ein Häufchen Dinge, die ein Murmeltier für wichtig hält (Decor, der Fingerhut liegt obenauf und fehlt
> mit "grat.thimble_taken"). Das Murmeltier ist nie zu sehen und tritt nie auf; es ist eine Spur, und die Ordnung des Häufchens ist
> der Gag. Nichts wird erklärt, nichts gesperrt.

- *Am Hang führt ein rundes Loch unter einen Felsen. Zu sehen ist kein Murmeltier, aber hier wohnt eins.* `[#draft]`  <sub>hoch_marmot_1</sub>
- *Davor liegt ein Häufchen, nach Wichtigkeit geordnet. Ein Löffelstiel, ein Knopf ohne Hose, ein Hut aus Pappe, und ganz oben ein Fingerhut.* `[#draft]`  <sub>hoch_marmot_2</sub>
- ▸ **Den Fingerhut nehmen.**
  - *Du nimmst den Fingerhut. Im Loch rührt sich nichts, aber der Hut aus Pappe sitzt jetzt ganz oben, als hätte er die Stelle immer gewollt.* `[#draft]`  <sub>hoch_marmot_3</sub>
- ▸ **Liegen lassen.**
  - *Du lässt alles, wie es liegt. Das Häufchen ist fertig und wüsste nicht, was man daran verbessern sollte.* `[#draft]`  <sub>hoch_marmot_4</sub>

### G2-15 · `plant_gate`

> --- Das Tor der Anlage ------------------------------------------------------------------------------------------------
> Ein Blocker bis G3 (dort steht an seiner Stelle die Tür in die Maschine, der Cue wird stillgelegt). Die Anlage ist zu, und hinter
> dem Zaun tickt etwas im Takt: nur ein Ton als Bild. Noch kein Wächter, kein Wort von Zählen und keine Zahl; die Pedanterie zeigen
> die Pfosten im gleichen Abstand und die Pausen von immer derselben Länge.

- *Das Tor der Anlage ist zu. Der Zaun links und rechts steht gerade, Pfosten für Pfosten im gleichen Abstand.* `[#draft]`  <sub>hoch_plant_gate_1</sub>
- *Dahinter tickt etwas, gleichmäßig, mit Pausen von immer derselben Länge. Es hat sich nicht ein einziges Mal geirrt, seit du lauschst.* `[#draft]`  <sub>hoch_plant_gate_2</sub>

### G2-16 · `ramp_wait`

> --- Der Aufgang zum Grat ----------------------------------------------------------------------------------------------
> Ein Blocker bis G6 (dort öffnet sich der Aufgang). Hinter dem Geröll liegt der Weg nach oben, aber nichts verspricht ein
> Weiterkommen: weder, dass es geht, noch, dass es nicht geht.

- *Der Weg nach oben beginnt hinter einem Hang aus losem Geröll, der schon beim Hinsehen ein Stück nachgibt.* `[#draft]`  <sub>hoch_ramp_wait_1</sub>
- *Weiter oben läuft ein Grat am Himmel entlang. Wie man dort hinaufkommt, steht nirgends.* `[#draft]`  <sub>hoch_ramp_wait_2</sub>
