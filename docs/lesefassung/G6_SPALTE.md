# G6 Spalte (Akt V)

<!-- Erzeugt mit `python3 tools/writing/readable.py`. Nicht von Hand ändern: Änderungen gehören in die .dialogue-Dateien. -->

Lesefassung: der Text in der Reihenfolge, in der das Spiel ihn zeigt. *Kursiv* ist Erzählung, **fett** sprechen die Figuren, ▸ sind deine Antworten. Eingerückt steht, was nur unter einer Bedingung oder nach einer Antwort kommt. Hinter jeder Zeile die ID in klein.

**So antwortest du:** je Szene (E3, T12 …) „OK“, „ändern: …“ oder „raus“. Was du nicht nennst, gilt als OK.


## spalte


### G6-1 · `ledge_view`

- *Der Absatz läuft an der Wand entlang nach Osten, so weit du siehst. Der Wind kommt von der Seite und bleibt.* `[#draft]`  <sub>spa_ledge_1</sub>
- *Tief unten liegt das Hochtal. Der See ist so klein, dass ein Daumen ihn zudeckt.* `[#draft]`  <sub>spa_ledge_2</sub>
- *Die Anlage steht grau in ihrer Nische. Ihr Rauch steigt als Faden vom Schornstein auf und endet weit unter dem Grat.* `[#draft]`  <sub>spa_ledge_3</sub>

### G6-2 · `fork_sign`

> --- Die Gabel ---------------------------------------------------------------------------------------------------------------
> Ein Brett auf einem Pfahl, zwei Pfeile aus Kohle, nach Norden und nach Süden. Neben dem nördlichen steht »Umweg«, neben dem südlichen »Spalte«. Beide Wörter sind mit derselben Kohle geschrieben, gleich groß und gleich
> dunkel; niemand hat dazugeschrieben, welcher Weg der bessere ist, und der Text sagt es auch nicht. Kein Urteil, kein Warnhinweis, kein Witz. Nichts wird gesetzt.

- *Auf einem Pfahl an der Gabel sitzt ein Brett. Zwei Pfeile sind mit Kohle daraufgemalt, einer nach Norden, einer nach Süden.* `[#draft]`  <sub>spa_fork_1</sub>
- *Neben dem Pfeil nach Norden steht »Umweg«, neben dem nach Süden »Spalte«.* `[#draft]`  <sub>spa_fork_2</sub>
- *Beide Wörter sind mit derselben Kohle geschrieben, gleich groß und gleich dunkel. Mehr steht nicht auf dem Brett.* `[#draft]`  <sub>spa_fork_3</sub>

### G6-3 · `cleft_mouth`

> --- Der Eingang der Spalte --------------------------------------------------------------------------------------------------
> Ein unsichtbarer Blick am Südzweig, vor dem Eingang: kalter Atem aus dem Fels, drei Schultern breit, das Licht gibt nach einem Stück auf, der Boden fällt zur Anlage hin ab, das Ende liegt im Schatten. Der Wind bleibt
> draußen. Keine Aufforderung und keine Warnung, kein Wort darüber, was drinnen ist oder ob es sich lohnt; wer hineingeht, tut es von selbst. Nichts wird gesetzt (die Facette setzt die Szene am Ende der Spalte).

- *Aus dem Fels kommt ein kalter Atem, der nach nassem Stein riecht. Hier beginnt die Spalte.* `[#draft]`  <sub>spa_cleft_1</sub>
- *Sie ist kaum drei Schultern breit. Das Licht reicht ein Stück hinein und hört dann auf.* `[#draft]`  <sub>spa_cleft_2</sub>
- *Der Boden fällt nach hinten ab, der Anlage entgegen. Das Ende liegt im Schatten.* `[#draft]`  <sub>spa_cleft_3</sub>
- *Der Wind geht über die Spalte hinweg und kommt nicht hinein.* `[#draft]`  <sub>spa_cleft_4</sub>

### G6-4 · `hiding_place`

> --- Das Verstecken (die zweite Rückblende, Bild des Kindes) -----------------------------------------------------------------
> Eine Mulde im Fels am Ende der Spalte, so niedrig, dass sie der Spielerin kaum bis zur Hüfte reicht; ein einziger Streifen Licht aus einem Riss, der bis an den Rand einer zusammengerollten Decke fällt; draußen geht
> etwas vorbei, ein Geräusch ohne Ursache; die Decke ist noch warm und bleibt es. Ein stehendes Bild (Brief O7, Bible §15), nach dem Muster der Hand (hoch_hand_1 bis _5): vier Zeilen Erzählung und nicht mehr, kein Wort des
> Kindes, kein Kind genannt, kein Erwachsener, keine Stimme, kein Schritt, kein Ort draußen, kein Anlass, keine Ursache, kein Gefühlswort, keine Erklärung, wofür der Ort gedient hat; kein Witz davor oder danach. Die
> Spielerin legt nur die Fingerspitzen auf die Decke, und das Bild lässt sie los, wie es ist. Das erste Mal setzt das Flag (Collection liest es, die Karte zeigt das Bild), danach gibt es nur noch eine Zeile.
> Nie Voraussetzung: wer die Spalte liegen lässt, kommt zur zentralen Szene wie jeder.

*wenn* `fragment.hiding`
  - *Die Mulde im Fels. Der Streifen Licht liegt, wo er lag, und die Decke ist noch warm.* `[#draft]`  <sub>spa_hiding_5</sub>
*sonst*
  - *Am Ende der Spalte weitet sich der Fels zu einer Mulde, die dir kaum bis zur Hüfte reicht.* `[#draft]`  <sub>spa_hiding_1</sub>
  - *Durch einen Riss fällt ein einziger Streifen Licht schräg auf den Boden und reicht bis an den Rand einer zusammengerollten Decke.* `[#draft]`  <sub>spa_hiding_2</sub>
  - *Draußen vor dem Riss wird der Streifen Licht einen Augenblick dunkler und kehrt zurück. Dann ist es still.* `[#draft]`  <sub>spa_hiding_3</sub>
  - *Du legst die Fingerspitzen auf die Decke. Sie ist noch warm, und sie bleibt es.* `[#draft]`  <sub>spa_hiding_4</sub>

### G6-5 · `candle`

> --- Kuriosität: der Kerzenstummel -------------------------------------------------------------------------------------
> Neben der Decke in der Mulde (Decor, "unless grat.candle_taken"). Wie der Bergkristall (hoch_quartz_*): Einstecken gibt den Gegenstand und das Flag, Liegen lassen gibt nichts und kostet nichts. Kaum zwei Finger
> hoch, das Wachs alt und hart, der Docht weiß: der Stummel ist nie angezündet worden, und der Text sagt es nicht. Keine Ursache, kein Gedanke, kein Witz; er gehört zur Mulde, ohne dass jemand es erklärt.

- *Neben der Decke steht ein Kerzenstummel, kaum zwei Finger hoch. Das Wachs ist alt und hart, und der Docht ist weiß.* `[#draft]`  <sub>spa_candle_1</sub>
- ▸ **Einstecken.**
  - *Du steckst ihn ein. Er ist glatt an den Kanten und wiegt fast nichts.* `[#draft]`  <sub>spa_candle_2</sub>
- ▸ **Liegen lassen.**
  - *Du lässt ihn stehen, wo der Streifen Licht nicht hinkommt.* `[#draft]`  <sub>spa_candle_3</sub>

### G6-6 · `plateau_edge`

> --- Der Rand des Plateaus ---------------------------------------------------------------------------------------------------
> Ein unsichtbarer Blick am Südrand der Hochfläche im Osten (freiwillig, immer von vorn): flach, weit, leer, der Wind ohne Widerstand, am Südrand viel Luft. Der Platz ist leer, und er sieht aus wie einer, den man frei
> gelassen hat; mehr sagt der Text nicht (was hier einmal steht, kommt später und wird hier nicht vorweggenommen: kein Haus, keine Tür, kein Kind). Drei Antworten: das unbedingte "Umsehen." (die Fläche ist überall
> gleich fest und leer), die Facette Mut als zusätzliche Antwort "Bis an den Rand gehen." (der Blick hinunter: die Anlage, der Rauch, der See; kein Lob, keine Lehre, kein Wort über das, was sie dafür getan hat; die
> Facette setzt die Szene am Ende der Spalte, nie dieser Cue) und das Schweigen "…" als letzte. Wer die Facette nicht hat, sieht die Antwort nicht und verpasst keine Szene. Keine der Antworten setzt etwas.

- *Der Grat läuft hier in eine Fläche aus, flach und weit, mit kurzem Gras bewachsen.* `[#draft]`  <sub>spa_plateau_1</sub>
- *Nichts Hohes steht darauf, und dein Schatten ist der einzige.* `[#draft]`  <sub>spa_plateau_2</sub>
- *Im Norden und im Osten steigt der Fels an, im Süden nicht. Dort ist Luft, und weit unten liegt das Tal.* `[#draft]`  <sub>spa_plateau_3</sub>
- *Der Wind geht flach über das Gras und macht hier kaum ein Geräusch.* `[#draft]`  <sub>spa_plateau_4</sub>
- *Die Fläche ist leer. Sie sieht aus wie ein Platz, den man frei gelassen hat.* `[#draft]`  <sub>spa_plateau_5</sub>
- ▸ **Umsehen.**
  - *Du gehst die Fläche ab, bis an die Wand und zurück. Der Boden ist überall gleich fest, und nirgends liegt etwas.* `[#draft]`  <sub>spa_plateau_6</sub>
  - *Am Ende stehst du wieder am Südrand, und die Fläche sieht aus wie vorher.* `[#draft]`  <sub>spa_plateau_7</sub>
- ▸ **Bis an den Rand gehen.** *(wenn `courage`)*
  - *Du gehst bis an die Kante, wo das Gras aufhört. Dahinter fällt der Fels senkrecht ab, bis zu den Matten.* `[#draft]`  <sub>spa_plateau_8</sub>
  - *Du bleibst dort stehen und siehst hinunter. Die Anlage ist ein graues Kästchen, ihr Rauch ein gerader Strich.* `[#draft]`  <sub>spa_plateau_9</sub>
  - *Der See liegt da wie ein Stück Himmel, das nicht oben geblieben ist.* `[#draft]`  <sub>spa_plateau_10</sub>
- ▸ **…**
  - *Du schweigst. Der Wind geht flach über das Gras, und sonst bewegt sich nichts.* `[#draft]`  <sub>spa_plateau_11</sub>
