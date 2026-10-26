# W2 Waldweg (Akt III)

<!-- Erzeugt mit `python3 tools/writing/readable.py`. Nicht von Hand ändern: Änderungen gehören in die .dialogue-Dateien. -->

Lesefassung: der Text in der Reihenfolge, in der das Spiel ihn zeigt. *Kursiv* ist Erzählung, **fett** sprechen die Figuren, ▸ sind deine Antworten. Eingerückt steht, was nur unter einer Bedingung oder nach einer Antwort kommt. Hinter jeder Zeile die ID in klein.

**So antwortest du:** je Szene (E3, T12 …) „OK“, „ändern: …“ oder „raus“. Was du nicht nennst, gilt als OK.


## waldweg


### W2-1 · `mark_1`

- *Am Pfosten ein Brett, sauber gesägt, ein roter Pfeil nach Süden.* `[#draft]`  <sub>wd_m1_1</sub>
- *Darunter, in gerader Kreideschrift und mit dem Lineal unterstrichen, »Erstens gehen.«* `[#draft]`  <sub>wd_m1_2</sub>

### W2-2 · `mark_2`

- *Das zweite Brett, derselbe Pfeil. »Zweitens schneller gehen.«* `[#draft]`  <sub>wd_m2_1</sub>
- *Der Strich darunter ist doppelt gezogen, für den Fall, dass einer das Erste überliest.* `[#draft]`  <sub>wd_m2_2</sub>

### W2-3 · `mark_3`

- *Das dritte Brett hat zwei Spalten. Links steht »Pausen«, rechts »Schritte«.* `[#draft]`  <sub>wd_m3_1</sub>
- *Links ist ein einziger Strich, wieder ausgewischt. Das Holz ist an der Stelle heller geworden.* `[#draft]`  <sub>wd_m3_2</sub>
- *Rechts sind es Striche in Fünferbündeln, so viele, dass auf der Rückseite weitergezählt wurde.* `[#draft]`  <sub>wd_m3_3</sub>

### W2-4 · `mark_4`

- *Das vierte Brett. »Hang. Ohne Pause.«* `[#draft]`  <sub>wd_m4_1</sub>
- *Darunter stand ein zweiter Satz. Er ist so dick durchgestrichen, dass nur noch ein »aber« zu lesen ist.* `[#draft]`  <sub>wd_m4_2</sub>

### W2-5 · `mark_5`

- *Auf dem fünften Brett steht »Fast da.« Darunter noch einmal, kleiner, und noch einmal, bis die Schrift am Rand ausläuft.* `[#draft]`  <sub>wd_m5_1</sub>
- *Es hat keinen Pfeil mehr. Der Weg ist ja nicht zu verfehlen.* `[#draft]`  <sub>wd_m5_2</sub>

### W2-6 · `mark_6`

*wenn* `side_forest_marks und done`
  - *Das sechste Brett, leer. Das Holz ist noch hell, ohne einen einzigen Strich.* `[#draft]`  <sub>wd_m6_5</sub>
  - *→ Ende des Szenenstücks*
- *Das sechste Brett ist leer. Das Holz ist noch hell, frisch gesägt, ohne einen einzigen Strich.* `[#draft]`  <sub>wd_m6_1</sub>
- *Der Platz für das Wort, das nach »Fast da« kommt, ist frei geblieben.* `[#draft]`  <sub>wd_m6_2</sub>
- *Oben in einer Kerbe im Pfosten liegt ein Stummel rote Kreide.* `[#draft]`  <sub>wd_m6_3</sub>
*wenn* `side_forest_marks und follow`
- *→ weiter bei* `mark_6_chalk`

### W2-7 · `mark_6_chalk`

- ▸ **Einstecken.**
  - *Du steckst ihn ein. Er ist rau vom Reiben und fast aufgebraucht.* `[#draft]`  <sub>wd_m6_4</sub>
- ▸ **Liegen lassen.**
  - *Du lässt ihn in der Kerbe. Das Brett wartet.* `[#draft]`  <sub>wd_m6_6</sub>

### W2-8 · `antreiber_end`

> --- Der Antreiber am leeren Brett -------------------------------------------------------------------------------------
> Er steht, solange er nicht gebeten wurde zu sitzen (Karte: Figur A); danach sitzt er (Figur E). Wer ihn am Feuer im Haus
> gelassen hat (house.antreiber_by_fire), trifft ihn hier nicht: er sitzt dort (die Katze liegt auf ihm, sobald sie gefüttert ist). Alle anderen finden ihn vor sich,
> schneller, als es möglich ist. "Setz dich. Es gibt Tee." gibt es nur mit der Facette care: wer nicht gerastet hat, hat
> keinen Tee. Ob er sitzt, ist keine Auszeichnung und keine Strafe; die Kreide und die Nebenquest hängen nicht an ihm.

*wenn* `forest.antreiber_sat`
  - **Antreiber:** Der Tee ist gut. Ich sag das nicht oft. `[#draft]`  <sub>wd_antr_sat</sub>
  - *→ Ende des Szenenstücks*
*wenn* `forest.antreiber_met`
  - **Antreiber:** Noch nichts. Ich bin dran. `[#draft]`  <sub>wd_antr_again</sub>
  - *→ weiter bei* `antreiber_ask`
*wenn* `house.antreiber_postponed`
  - **Antreiber:** Du hast morgen gesagt. Es ist morgen. Ich bin pünktlich. `[#draft]`  <sub>wd_antr_0a</sub>
*sonst*
  - **Antreiber:** Ich bin schon mal vorgegangen. Das spart Zeit. `[#draft]`  <sub>wd_antr_0b</sub>
- **Antreiber:** Ich hab für alles ein Brett gesägt. Nur für das letzte fehlt mir das Wort. `[#draft]`  <sub>wd_antr_1</sub>
- *Er klappt einen Zollstock auf und wieder zu, als wäre er mitten in einer Rechnung.* `[#draft]`  <sub>wd_antr_2</sub>
- **Antreiber:** Ich hab es ausgerechnet. Es ging in den Zahlen auf. Nur das Wort nicht. `[#draft]`  <sub>wd_antr_3</sub>
- *→ weiter bei* `antreiber_ask`

### W2-9 · `antreiber_ask`

- ▸ **Setz dich. Es gibt Tee.** *(wenn `care`)*
  - **Antreiber:** Tee. `[#draft]`  <sub>wd_antr_4</sub>
  - *Er sieht auf das Brett, auf den Weg, auf die Flasche in deiner Hand. Dann lässt er sich neben dem Pfosten nieder, in Etappen.* `[#draft]`  <sub>wd_antr_5</sub>
  - **Antreiber:** Ich sitz nur kurz. `[#draft]`  <sub>wd_antr_6</sub>
  - *Er hält den Becher mit beiden Händen und weiß nicht, wohin mit den Daumen.* `[#draft]`  <sub>wd_antr_7</sub>
- ▸ **Wie weit ist es noch?**
  - **Antreiber:** Fast da. `[#draft]`  <sub>wd_antr_8</sub>
  - *Er hört selbst, wie das klingt, und sieht auf das leere Brett.* `[#draft]`  <sub>wd_antr_9</sub>
- ▸ **…**
  - *Er wartet, ob noch etwas kommt. Dann klappt er den Zollstock wieder zu.* `[#draft]`  <sub>wd_antr_10</sub>

### W2-10 · `rest_1`

> --- Die Rastplätze ----------------------------------------------------------------------------------------------------
> Ein Feuerring aus flachen Steinen, ein Kessel, trockenes Holz, ein Stamm zum Sitzen. Das erste Mal, gleich an welchem
> Platz, setzt care und das Flag forest.rested (der Hang geht danach leichter, die Karte zeigt das Feuer). Die Ergebnis-
> Zeilen kennen zwei Fassungen: die lange fürs erste Mal, die kurze, wenn die Facette schon da ist. "Weitergehen" lässt
> den Ring kalt; nichts geht verloren, der Hang ist nur steiler.

*wenn* `forest.fire_1`
  - *→ weiter bei* `embers`
- *Neben dem Weg ein Ring aus flachen Steinen, die Asche grau und kalt. Ein Kessel hängt an einem Haken darüber.* `[#draft]`  <sub>wd_rest1_1</sub>
- *Trockenes Holz liegt daneben, ordentlich geschichtet, und ein Stamm zum Sitzen. Jemand hat gedacht, dass hier wieder jemand rastet.* `[#draft]`  <sub>wd_rest1_2</sub>
- ▸ **Feuer machen.**
  *wenn* `care`
    - *Ein Dach aus Scheiten, ein Funke, der Kessel. Es geht schneller als beim ersten Mal.* `[#draft]`  <sub>wd_rest1_3</sub>
  *sonst*
    - *Du schichtest das Holz zu einem Dach, so wie man es zeigt, und das Feuer nimmt es an.* `[#draft]`  <sub>wd_rest1_4</sub>
    - *Der Kessel braucht lange, bis er singt. Du lässt ihn.* `[#draft]`  <sub>wd_rest1_5</sub>
    - *Der Tee schmeckt nach Harz und nach Rauch. Du hast nicht gewusst, dass du durstig bist.* `[#draft]`  <sub>wd_rest1_6</sub>
    - *Den Rest füllst du in die Flasche. Sie bleibt eine Weile warm.* `[#draft]`  <sub>wd_rest1_7</sub>
- ▸ **Weitergehen.**
  - *Der Stamm bleibt, wo er ist. Mehr hat er nicht zu tun.* `[#draft]`  <sub>wd_rest1_8</sub>

### W2-11 · `rest_2`

*wenn* `forest.fire_2`
  - *→ weiter bei* `embers`
- *Am Fuß des Hangs ein zweiter Ring, ein zweiter Kessel, ein zweiter Stamm. Wer das eingerichtet hat, kannte den Hang.* `[#draft]`  <sub>wd_rest2_1</sub>
- *Die Asche ist grau und kalt. Das Holz liegt bereit.* `[#draft]`  <sub>wd_rest2_2</sub>
- ▸ **Feuer machen.**
  *wenn* `care`
    - *Du weißt jetzt, wie das geht. Das Wasser singt, bevor du dich gesetzt hast.* `[#draft]`  <sub>wd_rest2_3</sub>
  *sonst*
    - *Du schichtest das Holz, das Feuer nimmt es an. Der Kessel braucht seine Zeit, und du gibst sie ihm.* `[#draft]`  <sub>wd_rest2_4</sub>
    - *Der Tee schmeckt nach Harz. Die Beine sagen jetzt, was sie den ganzen Hang lang gesagt haben.* `[#draft]`  <sub>wd_rest2_5</sub>
    - *Den Rest füllst du in die Flasche.* `[#draft]`  <sub>wd_rest2_6</sub>
- ▸ **Weitergehen.**
  - *Du gehst weiter. Der Ring wartet, ohne beleidigt zu sein.* `[#draft]`  <sub>wd_rest2_7</sub>

### W2-12 · `embers`

- *Unter dem Kessel liegt Glut. Der Stamm daneben ist noch warm.* `[#draft]`  <sub>wd_embers_1</sub>

### W2-13 · `hang_steps`

> --- Der Hang, die Hütte, der Zapfen, das Ende des Weges ----------------------------------------------------------------
> Der Hohlweg ist ein Fragment (Spur der Welt, kein Bild des Kindes): Stufen, jemand hat sie gestochen, kein Grund wird genannt.

*wenn* `fragment.hang_steps`
  - *Die Stufen im Hohlweg, die Kanten rund getreten.* `[#draft]`  <sub>wd_steps_5</sub>
*sonst*
  - *Im Hohlweg sind Stufen in die Erde gestochen, jede etwas schräg, damit das Wasser abläuft.* `[#draft]`  <sub>wd_steps_1</sub>
  - *Du gehst sie hinab. Die Kanten sind rund, von sehr vielen Schuhen.* `[#draft]`  <sub>wd_steps_2</sub>
  - *Für einen Atemzug sind sie neu, die Erde dunkel, jede Kante scharf, und es riecht nach frisch gestochener Erde. Dann sind sie wieder alt.* `[#draft]`  <sub>wd_steps_3</sub>
  - *Wer die Stufen gestochen hat, hat es für alle getan, die danach kamen.* `[#draft]`  <sub>wd_steps_4</sub>

### W2-14 · `cone`

- *Unter der Fichte liegt ein Zapfen, so groß wie eine Faust, die Schuppen halb offen.* `[#draft]`  <sub>wd_cone_1</sub>
- ▸ **Einstecken.**
  - *Du steckst ihn ein. Er riecht nach Harz und nach dem, was er noch werden wollte.* `[#draft]`  <sub>wd_cone_2</sub>
- ▸ **Liegen lassen.**
  - *Du lässt ihn liegen. Die Fichte hat noch viele.* `[#draft]`  <sub>wd_cone_3</sub>

### W2-15 · `bach_south_wait`

> Der Süden des Bachlaufs, solange der Morgen danach nicht begonnen hat (kein Beat act3_morning): die Lücke in der Hecke
> führt an den Rand der Karte, und der Abend von Akt II geht nicht in den Wald.

- *Im Süden verliert sich der Bach unter dichten Zweigen. Für heute geht es dort nicht weiter.* `[#draft]`  <sub>wd_bachwait_1</sub>

### W2-16 · `south_wait`

- *Hinter dem leeren Brett läuft der Weg in Brombeeren aus. Der Bach nimmt es dort allein mit dem Wald auf.* `[#draft]`  <sub>wd_south_1</sub>
