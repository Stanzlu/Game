# S1 Straße (Akt IV)

<!-- Erzeugt mit `python3 tools/writing/readable.py`. Nicht von Hand ändern: Änderungen gehören in die .dialogue-Dateien. -->

Lesefassung: der Text in der Reihenfolge, in der das Spiel ihn zeigt. *Kursiv* ist Erzählung, **fett** sprechen die Figuren, ▸ sind deine Antworten. Eingerückt steht, was nur unter einer Bedingung oder nach einer Antwort kommt. Hinter jeder Zeile die ID in klein.

**So antwortest du:** je Szene (E3, T12 …) „OK“, „ändern: …“ oder „raus“. Was du nicht nennst, gilt als OK.


## strasse


### S1-1 · `signpost_tal`

- *Am Westrand des Tals steht ein Wegweiser, als hätte er immer dort gestanden. Er riecht noch nach Farbe.* `[#draft]`  <sub>str_tal_1</sub>
- *Der Pfeil zeigt nach Westen. Darunter ein einziges Wort, »Stadt«, in Buchstaben, die nicht zweifeln.* `[#draft]`  <sub>str_tal_2</sub>

### S1-2 · `signpost`

- *Ein Wegweiser mit zwei Pfeilen. Der nach Osten heißt »Tal« und ist kurz. Mehr gab es dazu nicht zu sagen.* `[#draft]`  <sub>str_sign_1</sub>
- *Der nach Westen heißt »Stadt« und ist länger. Darunter steht klein, mit Bleistift, »Ohne Gewähr«.* `[#draft]`  <sub>str_sign_2</sub>

### S1-3 · `goat_prints`

> --- Die Spuren der Ziege ----------------------------------------------------------------------------------------------
> Hufabdrücke in der Mitte der Straße und ein Glöckchen am Zaunpfosten. Beides ist nur ein Hinweis; die Ziege selbst kommt in S2
> (auf einem Dach) und in S6 (auf der Bühne). Die Abdrücke tun nichts, das Glöckchen ist eine Kuriosität: Einstecken gibt den
> Gegenstand und das Flag, Hängen lassen gibt nichts und kostet nichts. Der Pfosten ohne Glöckchen ist ein anderes Bild der Karte.

- *Im Staub der Straße stehen Hufabdrücke, zweigeteilt, in einer Reihe nach Westen.* `[#draft]`  <sub>str_hoof_1</sub>
- *Sie gehen geradeaus, mitten auf der Straße, ohne einen Schritt zur Seite. Wer hier ging, hatte etwas vor.* `[#draft]`  <sub>str_hoof_2</sub>

### S1-4 · `goat_bell`

- *Am Zaunpfosten hängt ein Glöckchen, die angekaute Schnur ordentlich über den Nagel gelegt, so wie man einen Hut aufhängt.* `[#draft]`  <sub>str_bell_1</sub>
- ▸ **Einstecken.**
  - *Du steckst es ein. Es klingt einmal in der Tasche, fast höflich.* `[#draft]`  <sub>str_bell_2</sub>
- ▸ **Hängen lassen.**
  - *Du lässt es hängen. Es klingt hinter dir einmal, knapp, wie ein letztes Wort.* `[#draft]`  <sub>str_bell_3</sub>

### S1-5 · `scarecrow`

> --- Das Feld ----------------------------------------------------------------------------------------------------------
> Humor aus Dingen, nie auf Kosten einer Person: eine Vogelscheuche, die ihre Krähen duldet, und ein Schild, das eine Ausnahme
> für sie enthält. Nichts wird gesetzt, nichts gelehrt.

- *Mitten im Feld steht eine Vogelscheuche, die Arme weit ausgebreitet, als wolle sie gleich etwas Wichtiges verkünden.* `[#draft]`  <sub>str_crow_1</sub>
- *Auf jedem Arm sitzt eine Krähe und hört zu. Keine wirkt beunruhigt.* `[#draft]`  <sub>str_crow_2</sub>
- *Nur der Hut sitzt gerade und ist neu. Der Rest hat sich mit den Krähen abgefunden.* `[#draft]`  <sub>str_crow_3</sub>

### S1-6 · `field_notice`

- *Am Feldrand steht ein Schild in sorgfältiger Schrift. »Bitte nicht betreten. Auch nicht zum Nachsehen.«* `[#draft]`  <sub>str_note_1</sub>
- *Darunter hat jemand mit anderem Stift nachgetragen »Ausgenommen die Vogelscheuche«. Sie macht davon Gebrauch.* `[#draft]`  <sub>str_note_2</sub>

### S1-7 · `milestone`

> --- Der Meilenstein ---------------------------------------------------------------------------------------------------
> Ein Fragment, eine Spur der Welt (kein Bild des Kindes): ein Stein, der gezählt hat, ohne dass jemand danach fragte. Die Zahl
> darauf ist abgetragen, die Kante von Füßen blank geschliffen; kein Grund, keine Figur. Das erste Mal setzt das Flag, danach
> gibt es nur noch eine kurze Zeile.

*wenn* `fragment.milestone`
  - *Der Meilenstein, die Oberkante blank geschliffen. Er zählt weiter.* `[#draft]`  <sub>str_mile_4</sub>
*sonst*
  - *Am Straßenrand steht ein Meilenstein, hüfthoch, die Zahl so weit abgetragen, dass nur eine flache Mulde bleibt.* `[#draft]`  <sub>str_mile_1</sub>
  - *Die Oberkante ist rund und blank, an einer Stelle geschliffen, die genau zu einem Fuß passt.* `[#draft]`  <sub>str_mile_2</sub>
  - *Für einen Atemzug ist er neu, die Zahl scharf. Dann ist er wieder alt und zählt weiter, ohne dass jemand fragt.* `[#draft]`  <sub>str_mile_3</sub>

### S1-8 · `view_town`

> --- Die Aussicht und das Ende der Straße ------------------------------------------------------------------------------
> Der Blick am Westende: kein Haus, keine Figur, nur Rauch hinter einem Hügel, viele Fäden statt des einen über dem Haus
> (bl_back_1). Das Flag city.view_seen liest die Szene (Beat strasse_view). Der Blocker davor (town_wait) ist ein Platzhalter für
> die Tür der Stadt in S2 und verspricht nichts; S2 legt ihn still, wie W4 es mit south_wait tat.

*wenn* `city.view_seen`
  - *Hinter dem Hügel der Rauch, viele Fäden durcheinander.* `[#draft]`  <sub>str_view_4</sub>
*sonst*
  - *Von hier aus geht der Blick über die letzten Felder bis zu einem Hügel. Dahinter steigt Rauch auf.* `[#draft]`  <sub>str_view_1</sub>
  - *Nicht ein Faden, gerade nach oben, wie über dem Haus, sondern viele, die sich im Himmel nicht einig werden.* `[#draft]`  <sub>str_view_2</sub>
  - *Die Stadt selbst liegt noch hinter dem Hügel. Sie hat ihren Rauch vorgeschickt.* `[#draft]`  <sub>str_view_3</sub>

### S1-9 · `town_wait`

- *Quer über die Straße liegen Sand, Pflastersteine und eine Schnur zwischen zwei Stäben. Das Schild sagt »Pflasterarbeiten«, sonst nichts.* `[#draft]`  <sub>str_wait_1</sub>
- *Weiter geht es hier nicht. Die Steine liegen in ordentlichen Reihen und haben es nicht eilig.* `[#draft]`  <sub>str_wait_2</sub>
