# G1 Aufstieg (Akt V)

<!-- Erzeugt mit `python3 tools/writing/readable.py`. Nicht von Hand ändern: Änderungen gehören in die .dialogue-Dateien. -->

Lesefassung: der Text in der Reihenfolge, in der das Spiel ihn zeigt. *Kursiv* ist Erzählung, **fett** sprechen die Figuren, ▸ sind deine Antworten. Eingerückt steht, was nur unter einer Bedingung oder nach einer Antwort kommt. Hinter jeder Zeile die ID in klein.

**So antwortest du:** je Szene (E3, T12 …) „OK“, „ändern: …“ oder „raus“. Was du nicht nennst, gilt als OK.


## aufstieg


### G1-1 · `signpost_third`

- *Neben dem Wegweiser ist ein dritter Pfeil dazugekommen, mit Kreide gemalt. Er zeigt nach oben.* `[#draft]`  <sub>auf_signpost_third_1</sub>
- *Kein Wort dabei, nicht einmal »Ohne Gewähr«. Oben liegen die Berge und der Himmel, und der Pfeil legt sich nicht fest.* `[#draft]`  <sub>auf_signpost_third_2</sub>

### G1-2 · `cairn_first`

> --- Die Steinmännchen -------------------------------------------------------------------------------------------------
> Das erste am Beginn des Pfads. Der Text erzählt nur, dass jemand sie gebaut hat und dass jedes dort steht, wo man das vorige noch
> sieht (ein Test der Karte rechnet es nach). Kein Satz über Wegweiser oder Hilfe, kein Name, kein Grund. Nichts wird gesetzt.

- *Am Anfang des Pfads steht ein Steinmännchen, drei Steine, flach, rund, flach. Der oberste sitzt, als hätte er nie etwas anderes vorgehabt.* `[#draft]`  <sub>auf_cairn_first_1</sub>
- *Weiter oben steht das nächste, dahinter, klein im Licht, das übernächste. Jedes steht dort, wo man das vorige noch sieht.* `[#draft]`  <sub>auf_cairn_first_2</sub>
- *Niemand hat seinen Namen dazugeschrieben. Die Steine sind einfach fertig.* `[#draft]`  <sub>auf_cairn_first_3</sub>

### G1-3 · `mira_trace_boundary`

> --- Miras Spur --------------------------------------------------------------------------------------------------------
> Akt V hat keine Mira (Brief O11): sie ist in jedem Ausgang des Streits (S7) vorausgegangen. Die Karte zeigt genau eine der drei
> Spuren, je nach city.mira_parted_boundary, _joined oder _silent (es gilt nie mehr als eines); jede ist ein eigenes Requisit mit
> eigenem Cue, die Cues lesen nichts und setzen nichts. Der Text kommentiert keine Spur: er sagt nicht, wessen sie ist, nicht, was sie
> bedeutet, und keine Zeile rechnet es der Spielerin an. Wiedererkennen tragen das Netz und der Knoten (flach und sauber, wie in
> bl_knot_2) und der flache Stein (nicht rund, wie tal_mira_16 es verlangt). Grenze: ordentlich und ein Stück vom Weg, man streift
> es nicht. Anschließen: auf der Seite der Spielerin, in Armhöhe, locker gebunden. Schweigen: ein Stein mitten auf dem Weg, kein
> Netz, nichts darunter; keine Strafe, keine Antwort, ein Ding.

- *An einem Pfosten, ein Stück vom Weg, hängt ein Streifen Netz, der Knoten flach und fest.* `[#draft]`  <sub>auf_mira_trace_boundary_1</sub>
- *Es hängt gerade. Wer auf dem Weg bleibt, streift es nicht.* `[#draft]`  <sub>auf_mira_trace_boundary_2</sub>

### G1-4 · `mira_trace_joined`

- *An einem niedrigen Ast, genau dort, wo du gehst, hängt ein Streifen Netz in Armhöhe.* `[#draft]`  <sub>auf_mira_trace_joined_1</sub>
- *Der Knoten sitzt locker. Ein Zug, und er ginge auf.* `[#draft]`  <sub>auf_mira_trace_joined_2</sub>

### G1-5 · `mira_trace_silent`

- *Mitten auf dem Weg liegt ein flacher Stein, nicht rund. Von allein ist er nicht dort.* `[#draft]`  <sub>auf_mira_trace_silent_1</sub>
- *Kein Netz, kein Faden, kein Knoten. Unter der Kante ist nur Erde.* `[#draft]`  <sub>auf_mira_trace_silent_2</sub>

### G1-6 · `view_smoke`

> --- Die Aussicht ------------------------------------------------------------------------------------------------------
> Vom Aussichtsfels in der oberen Hälfte: Hänge, ein ferner Grat, ganz oben rechts der Rauch der Anlage. In S1 hatte die Stadt viele
> Fäden, die sich nicht einig wurden; dieser ist einer, gerade wie der über dem Haus, nur dünner und genauer, ohne Wind. Der Text
> sagt nicht, was dort steht, nur dass jemand dort Feuer mit Vorsatz macht (ein Wink auf den Wächter, den die Spielerin noch nicht
> kennt; die Pedanterie ist der Gag, nie seine Angst). Das Flag mountain.view_seen liest die Szene (Beat pass_view). Das zweite Mal
> gibt es nur noch eine kurze Zeile.

*wenn* `mountain.view_seen`
  - *Oben rechts steht der dünne Faden, gerade wie vorhin. Er hat es sich nicht anders überlegt.* `[#draft]`  <sub>auf_view_smoke_4</sub>
*sonst*
  - *Vom Felsen aus reicht der Blick über die Hänge bis zu einem fernen Grat. Ganz oben rechts steigt Rauch auf.* `[#draft]`  <sub>auf_view_smoke_1</sub>
  - *Ein einziger Faden, gerade nach oben, wie über dem Haus, nur dünner. Er steht in der Luft wie mit dem Lineal gezogen.* `[#draft]`  <sub>auf_view_smoke_2</sub>
  - *Ein Lagerfeuer qualmt schiefer. Wer dort Holz auflegt, hat sich vorher überlegt, wohin der Rauch soll.* `[#draft]`  <sub>auf_view_smoke_3</sub>

### G1-7 · `plank_bridge`

> --- Der Bach und das Schild -------------------------------------------------------------------------------------------
> Zwei Dinge am Weg, nichts gesetzt. Der Bach kommt aus dem Norden, unter der Brücke der Straße her; hier ist er schmal und hat doch
> Bohlen. Das Schild ist ein Schild: es verspricht den Gipfel, eine zweite Hand hat unter ihm nachgetragen, wie lange schon (Humor,
> ohne Person; keine Ziffer, keine Meterzahl, kein Doppelpunkt im Wortlaut).

- *Der Bach ist hier kaum breiter als ein Schritt. Jemand hat trotzdem zwei Bohlen darübergelegt, Kante an Kante.* `[#draft]`  <sub>auf_plank_bridge_1</sub>
- *Sie halten. Der Bach murmelt darunter weiter, als hätte man ihn nicht gefragt.* `[#draft]`  <sub>auf_plank_bridge_2</sub>

### G1-8 · `trail_sign`

- *Am Wegrand steht ein Holzschild, die Buchstaben mit dem Pinsel gemalt und zum Ende hin blasser. Es sagt »Gipfel. Bald.«* `[#draft]`  <sub>auf_trail_sign_1</sub>
- *Darunter hat jemand mit Kohle nachgetragen »Seit Stunden.« Das Schild lässt es stehen.* `[#draft]`  <sub>auf_trail_sign_2</sub>

### G1-9 · `slate_chip`

> --- Das Schieferplättchen ---------------------------------------------------------------------------------------------
> Eine Kuriosität wie das Glöckchen der Ziege (str_bell): Einstecken gibt den Gegenstand und das Flag, Liegen lassen gibt nichts und
> kostet nichts. Der Pfeil darauf ist der zweite Gag über Pfeile (der Pfad hat keine): er zeigt, wohin man das Plättchen hält. Das
> Flag mountain.slate_taken liest die Karte (unless), der Stein ohne Plättchen ist ein anderes Bild.

- *Auf einem flachen Stein am Wegrand liegt ein Plättchen Schiefer, dünn wie ein Keks. Jemand hat einen Pfeil hineingeritzt, mit viel Nachdruck.* `[#draft]`  <sub>auf_slate_chip_1</sub>
- ▸ **Einstecken.**
  - *Du steckst es ein und drehst es noch einmal in der Hand. Der Pfeil zeigt jedes Mal dorthin, wohin du ihn hältst.* `[#draft]`  <sub>auf_slate_chip_2</sub>
- ▸ **Liegen lassen.**
  - *Du lässt es liegen. Der Pfeil zeigt jetzt auf niemanden, aber mit Nachdruck.* `[#draft]`  <sub>auf_slate_chip_3</sub>

### G1-10 · `iron_ring`

> --- Der Eisenring -----------------------------------------------------------------------------------------------------
> Ein Fragment, eine Spur der Welt (kein Bild des Kindes, keine Figur, kein Grund): ein Ring in der Felswand, innen blank von einem
> Seil, das hier oft lief. Wie bei den anderen Spuren der Welt ist er für einen Atemzug in Gebrauch, dann wieder leer. Das erste Mal
> setzt das Flag (Collection liest es), danach gibt es nur noch eine kurze Zeile.

*wenn* `fragment.iron_ring`
  - *Der Eisenring in der Felswand, innen blank. Er hält weiter, auch ohne Seil.* `[#draft]`  <sub>auf_iron_ring_4</sub>
*sonst*
  - *In der Felswand steckt ein Eisenring, faustgroß, außen rostig. Innen ist er blank und rund geschliffen.* `[#draft]`  <sub>auf_iron_ring_1</sub>
  - *Die Rille im Eisen stammt von einem Seil, das hier oft lief, immer in dieselbe Richtung.* `[#draft]`  <sub>auf_iron_ring_2</sub>
  - *Für einen Atemzug läuft ein Seil durch den Ring, straff, und zieht etwas Schweres hinauf. Dann ist der Ring wieder leer.* `[#draft]`  <sub>auf_iron_ring_3</sub>

### G1-11 · `ridge_wait`

> --- Das Ende des Pfads ------------------------------------------------------------------------------------------------
> Am Nordende liegt Geröll quer. Der Blocker ist ein Platzhalter bis G2 und verspricht nichts: weder, dass es hier weitergeht, noch,
> dass es nicht weitergeht. G2 ersetzt ihn durch die Tür in das Hochtal und legt den Cue still, wie S2 es mit town_wait tat.

- *Am Ende des Pfads liegt Geröll quer, Stein über Stein, die obersten mit dem Moos nach unten.* `[#draft]`  <sub>auf_ridge_wait_1</sub>
- *Dahinter verliert sich der Weg im Fels. Von hier aus ist nicht zu sehen, wie weit.* `[#draft]`  <sub>auf_ridge_wait_2</sub>
