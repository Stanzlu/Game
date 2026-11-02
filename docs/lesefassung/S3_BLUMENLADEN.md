# S3 Blumenladen (Akt IV)

<!-- Erzeugt mit `python3 tools/writing/readable.py`. Nicht von Hand ändern: Änderungen gehören in die .dialogue-Dateien. -->

Lesefassung: der Text in der Reihenfolge, in der das Spiel ihn zeigt. *Kursiv* ist Erzählung, **fett** sprechen die Figuren, ▸ sind deine Antworten. Eingerückt steht, was nur unter einer Bedingung oder nach einer Antwort kommt. Hinter jeder Zeile die ID in klein.

**So antwortest du:** je Szene (E3, T12 …) „OK“, „ändern: …“ oder „raus“. Was du nicht nennst, gilt als OK.


## blumenladen


### S3-1 · `orin`

*wenn* `side_city_letter`
  - *→ weiter bei* `orin_after_letter`
*wenn* `side_city_duck`
  - *→ weiter bei* `orin_after`
*wenn* `side_city_duck und city.duck_seen`
  - *→ weiter bei* `orin_report`
*wenn* `side_city_duck`
  - *→ weiter bei* `orin_wait`
*wenn* `city.orin_met`
  - *→ weiter bei* `orin_ask_again`
- *Hinter dem Bindetisch steht ein Mann, breit wie der Türrahmen. Schulterpanzer aus Leder, Bart, das Haar im Knoten.* `[#draft]`  <sub>flo_orin_1</sub>
- *Eine grüne Schürze, ein Schildchen »Orin«, Bast um beide Hände. Dein Blick geht vom Panzer zur Schürze und zurück.* `[#draft]`  <sub>flo_orin_2</sub>
- **Orin:** Ja, ich sehe aus wie jemand, der Drachen jagt. Ich jage Läuse an Rosen. `[#draft]`  <sub>flo_orin_3</sub>
- **Orin:** Willkommen. Pfingstrosen brauchen Wasser. Morgens. Nicht abends. Morgens. `[#draft]`  <sub>flo_orin_4</sub>
- *Er sieht zur Tür, dann zu den Rosen, dann wieder zur Tür.* `[#draft]`  <sub>flo_orin_5</sub>
*wenn* `main_city_way und town`
- *→ weiter bei* `orin_ask`

### S3-2 · `orin_ask`

> --- Die Bitte --------------------------------------------------------------------------------------------------------------
> Er bittet um eine Kleinigkeit und erklärt sie nicht. "Warum?" bekommt keine Erklärung, nur die Auskunft, dass es keine gäbe, die taugt; danach steht
> dieselbe Bitte noch einmal da, ohne das Warum. Das Schweigen nimmt er an, ohne dass etwas beginnt. Wer zurückkommt, ohne zugesagt zu haben, hört die
> Bitte noch einmal.

- **Orin:** Bitte sieh nach, ob draußen eine Ente ist. Ich schaue so lange zu den Rosen. `[#draft]`  <sub>flo_orin_6</sub>
- ▸ **Ich sehe nach.**
  - *→ weiter bei* `orin_take`
- ▸ **Warum?**
  - **Orin:** Weil ich es nicht weiß, wäre eine Antwort. Es ist keine gute. `[#draft]`  <sub>flo_orin_7</sub>
  - *→ weiter bei* `orin_ask_again`
- ▸ **…**
  - *→ weiter bei* `orin_decline`

### S3-3 · `orin_ask_again`

- **Orin:** Die Bitte bleibt. Sieh bitte nach, ob draußen eine Ente ist. `[#draft]`  <sub>flo_orin_8</sub>
- ▸ **Ich sehe nach.**
  - *→ weiter bei* `orin_take`
- ▸ **…**
  - *→ weiter bei* `orin_decline`

### S3-4 · `orin_take`

- **Orin:** Danke. Ich bin bei den Rosen. `[#draft]`  <sub>flo_orin_9</sub>
- *Er dreht dir den Rücken zu und beugt sich über einen Rosenstock, den er längst auf Läuse geprüft hat.* `[#draft]`  <sub>flo_orin_10</sub>

### S3-5 · `orin_decline`

- **Orin:** Nur, wenn es dir nichts ausmacht. Ich frage ungern. `[#draft]`  <sub>flo_orin_11</sub>

### S3-6 · `orin_wait`

> Die Aufgabe läuft, die Ente hast du noch nicht gesehen: eine Erinnerung, eine Zeile.

- **Orin:** Draußen, vor der Tür, bitte. Ich schaue weiter zu den Rosen. `[#draft]`  <sub>flo_orin_12</sub>

### S3-7 · `duck`

> --- Die Ente ---------------------------------------------------------------------------------------------------------------
> Sie steht vor der Ladentür und tut, was Enten tun. Sie ist keine Figur: ein Tier ohne Absicht. Kein "Quak", keine Pointe auf Orins Kosten, kein Wort über
> ihn. Die Feder gehört zur Ente und zu nichts sonst; wer sie nimmt, nimmt eine Kuriosität, sonst nichts. Das Betrachten setzt city.duck_seen (der Bericht
> bei Orin liest es); wer wiederkommt, bekommt eine kurze Zeile.

*wenn* `city.duck_seen`
  - *→ weiter bei* `duck_again`
- *Vor der Ladentür steht eine Ente. Weiß, orangefarbener Schnabel, ein Gesicht, das nichts vorhat.* `[#draft]`  <sub>flo_duck_1</sub>
- *Sie pickt zwischen den Pflastersteinen nach etwas, das nur sie sieht, und findet es offenbar.* `[#draft]`  <sub>flo_duck_2</sub>
- *Sie sieht dich mit einem Auge an, nicht lange. Der Laden hinter ihr ist ihr keine Bemerkung wert.* `[#draft]`  <sub>flo_duck_3</sub>
- *→ weiter bei* `duck_feather`

### S3-8 · `duck_again`

- *Die Ente steht noch vor der Tür und tut, was Enten tun.* `[#draft]`  <sub>flo_duck_4</sub>
- *→ weiter bei* `duck_feather`

### S3-9 · `duck_feather`

*wenn* `city.feather_taken`
  - *→ Ende des Szenenstücks*
- *Neben ihr auf dem Pflaster liegt eine Feder, noch ganz glatt.* `[#draft]`  <sub>flo_duck_5</sub>
- ▸ **Aufheben.**
  - *Du bückst dich. Die Ente sieht dir dabei zu, ohne Einwände.* `[#draft]`  <sub>flo_duck_6</sub>
- ▸ **Liegen lassen.**
  - *Du lässt sie liegen. Die Ente hat dazu keine Meinung.* `[#draft]`  <sub>flo_duck_7</sub>

### S3-10 · `orin_report`

> --- Der Bericht: die Töpfe -----------------------------------------------------------------------------------------------------
> Du sagst ihm, was du gesehen hast, und er sagt die eine Zeile, die er schon hatte. Dann die Entscheidung, und beide Ausgänge sind gleichwertig:
> du stehst neben ihm, und er trägt die Pfingstrosen hinaus ans Licht (city.duck_passed), oder du lässt sie drinnen, und er sagt "Dann morgen"
> (city.duck_stayed). Keiner ist besser, keiner schwächer, niemand wird gelobt und niemand beschämt; die Ente schaut in beiden Fällen unbeteiligt.
> Das Schweigen ist ein Aufschub: nichts wird gesetzt, die Aufgabe bleibt offen, und er fragt beim nächsten Mal wieder.

- **Orin:** Und? `[#draft]`  <sub>flo_rep_1</sub>
- *Du sagst ihm, was du gesehen hast. Die Ente hat gepickt und dich angesehen. Sonst nichts.* `[#draft]`  <sub>flo_rep_2</sub>
- **Orin:** Die Ente tut nichts. Das ist ja das Beunruhigende. `[#draft]`  <sub>flo_rep_3</sub>
- *An der Wand stehen die Töpfe, Pfingstrosen in Knospen. Seine Hand liegt auf dem ersten und rührt ihn nicht.* `[#draft]`  <sub>flo_rep_4</sub>
- **Orin:** Sie gehören hinaus ans Licht, wie jeden Morgen. `[#draft]`  <sub>flo_rep_5</sub>
- ▸ **Ich stehe neben dir.**
  - **Orin:** Danke. Dann langsam. Pfingstrosen mögen es nicht, wenn man sie hetzt. `[#draft]`  <sub>flo_rep_6</sub>
  - *Er trägt die Töpfe hinaus, einen nach dem anderen. Die Ente sieht zu, wie man dem Wetter zusieht.* `[#draft]`  <sub>flo_rep_7</sub>
  - *Am letzten Topf bleibt seine Hand länger liegen, als nötig wäre.* `[#draft]`  <sub>flo_rep_8</sub>
- ▸ **Lass sie drinnen.**
  - **Orin:** Dann morgen. Die Rosen sind geduldig. `[#draft]`  <sub>flo_rep_9</sub>
  - *Seine Schultern sinken um einen Fingerbreit. Draußen sieht die Ente nicht herein.* `[#draft]`  <sub>flo_rep_10</sub>
- ▸ **…**
  - *Er lässt die Hand auf dem Topf liegen und wartet, ohne zu drängen.* `[#draft]`  <sub>flo_rep_11</sub>

### S3-11 · `orin_after`

> --- Danach (die Ente ist erledigt, der Brief nicht) ------------------------------------------------------------------------------
> Eine Zeile, leicht, je nach Ausgang: die Pfingstrosen draußen, die Töpfe drinnen. Der Humor sitzt in den Blumen und in der Ordnung, nicht in Orin.
> Hat er den Strauß schon gezeigt und der Brief ist noch zu (die Spielerin ist gegangen), kommt kein Witz mehr: er steht wieder in der leisen Szene.
> Wer nach dem Strauß über dem Tisch fragt, kommt in den Brief; wer nichts sagt, nickt ihm zu und geht.

*wenn* `side_city_letter`
  - *→ weiter bei* `orin_letter`
*wenn* `city.duck_passed`
  - **Orin:** Die Pfingstrosen stehen draußen in der Sonne. Ich habe schon dreimal nachgesehen. Das macht sie nervös. `[#draft]`  <sub>flo_aft_1</sub>
*sonst wenn* `city.duck_stayed`
  - **Orin:** Die Töpfe stehen noch drinnen. Ich habe sie gedreht, für gleich viel Fensterlicht. Pfingstrosen halten nichts von Kompromissen. `[#draft]`  <sub>flo_aft_2</sub>
- ▸ **Der Strauß dort oben.**
  - *→ weiter bei* `orin_letter`
- ▸ **…**
  - *Du nickst ihm zu. Er nickt zurück und bindet weiter.* `[#draft]`  <sub>flo_aft_3</sub>

### S3-12 · `orin_letter`

> --- Der Brief ---------------------------------------------------------------------------------------------------------------
> Der getrocknete Strauß über dem Tisch, kopfüber, mit Bast gebunden, ohne Karte. Orin sagt Dinge, keine Gründe: Pfingstrosen, die er geschnitten hat,
> die Art, sie zu trocknen, einen Brief, der dazu gehört, einen Umschlag ohne Anschrift. Er nennt keinen Namen und keinen Anlass, er fragt nicht
> um Rat und er liest den Brief nicht vor ("Ich wollte nur, dass du weißt, dass es ihn gibt"). Drei Antworten, keine bessere: zuhören (er sagt noch ein
> paar Tatsachen, dann ist es still), den Strauß halten (er legt den Brief zwischen die Stiele), oder gehen (nichts wird gesetzt, die Aufgabe bleibt
> offen, er kann wieder angesprochen werden). Nach den ersten beiden endet der Cue leise, ohne Pointe. Das erste Mal beginnt die Aufgabe "Der Brief".

*wenn* `side_city_letter`
  - *Orin sieht nicht hinauf. Die Hand liegt auf dem Umschlag in der Schürzentasche.* `[#draft]`  <sub>flo_let_1</sub>
  - **Orin:** Er hängt noch. Der Brief ist noch zu. `[#draft]`  <sub>flo_let_2</sub>
*sonst*
  - *Du siehst hinauf zu dem Strauß über dem Tisch. Orin sieht nicht hinauf.* `[#draft]`  <sub>flo_let_3</sub>
  - **Orin:** Pfingstrosen. Ich habe sie geschnitten, an einem Morgen, an dem ich eigentlich gießen wollte. `[#draft]`  <sub>flo_let_4</sub>
  - **Orin:** Man trocknet sie kopfüber, dunkel, mit etwas Luft. Drei Wochen. Danach halten sie, solange man sie nicht anfasst. `[#draft]`  <sub>flo_let_5</sub>
  - *Aus der Schürzentasche schaut ein Umschlag, die Ecken weich vom Tragen. Er legt die Hand darauf.* `[#draft]`  <sub>flo_let_6</sub>
  - **Orin:** Ich habe einen Brief dazu geschrieben. Auf dem Umschlag steht keine Anschrift. Ich weiß sie nicht. Oder ich weiß sie, und der Umschlag nicht. `[#draft]`  <sub>flo_let_7</sub>
  - **Orin:** Ich lese ihn nicht vor. Ich wollte nur, dass du weißt, dass es ihn gibt. `[#draft]`  <sub>flo_let_8</sub>
- ▸ **Ich höre zu.**
  - **Orin:** Es wollte schon jemand den Strauß kaufen. Ich habe gesagt, er sei nicht zu haben. `[#draft]`  <sub>flo_let_9</sub>
  - **Orin:** Die zwei Stunden vor dem Öffnen gehören den Blumen. Eine halbe davon dem Strauß. Ich sehe ihn an. Mehr tue ich nicht. `[#draft]`  <sub>flo_let_10</sub>
  - *Du sagst nichts. Er auch nicht. Über euch dreht sich der Strauß ein wenig und steht still.* `[#draft]`  <sub>flo_let_11</sub>
- ▸ **Gib ihn mir.**
  - *Orin hält einen Atemzug lang still. Dann löst er den Bast vom Balken und legt dir den Strauß in die Arme.* `[#draft]`  <sub>flo_let_12</sub>
  - *Der Strauß ist leichter, als er aussieht.* `[#draft]`  <sub>flo_let_13</sub>
  - *Orin zieht den Umschlag aus der Tasche und schiebt ihn zwischen die Stiele, bis nur eine Ecke herausschaut.* `[#draft]`  <sub>flo_let_14</sub>
  - **Orin:** Danke. `[#draft]`  <sub>flo_let_15</sub>
  - *Er sieht auf seine leeren Hände. Du hältst den Strauß, bis er die Arme hebt, und gibst ihn zurück.* `[#draft]`  <sub>flo_let_16</sub>
- ▸ **…**
  - *Du nickst ihm zu. Er bindet weiter, langsamer als vorher.* `[#draft]`  <sub>flo_let_17</sub>

### S3-13 · `orin_after_letter`

> --- Nach dem Brief ------------------------------------------------------------------------------------------------------------
> Zwei ruhige Zeilen, kein Witz, keine Rückkehr zur Ente. Wer den Strauß gehalten hat, sieht eine Zeile mehr: er hängt wieder am Balken, und Orin
> rückt ihn gerade. Er sagt es nicht, er tut es.

- **Orin:** Ich binde gerade einen Strauß für morgen. Rittersporn, Gräser, etwas Salbei. Es ist kein besonderer Anlass. `[#draft]`  <sub>flo_afl_1</sub>
- *Er bindet weiter. Der Bast liegt ruhig in seinen großen Händen.* `[#draft]`  <sub>flo_afl_2</sub>
*wenn* `city.letter_held`
  - *Der Strauß hängt wieder am Balken. Orin rückt ihn mit einem Finger gerade und lässt die Hand dort.* `[#draft]`  <sub>flo_afl_3</sub>

### S3-14 · `dried`

> --- Die Dinge im Laden ----------------------------------------------------------------------------------------------------------
> Der getrocknete Strauß, der Bindetisch und das Regal: Dinge, kein Gespräch. Vor dem Brief sind die Zeilen leicht (das Regal darf ein wenig lachen),
> danach dieselbe Ordnung ohne Witz: ein Satz, der nichts erklärt. Die Blütenblätter unter dem Strauß liegen, wo sie lagen.

*wenn* `city.letter_told`
  - *Der Strauß hängt still, den Kopf nach unten. Die Blütenblätter darunter liegen, wo sie lagen.* `[#draft]`  <sub>flo_dried_3</sub>
  - *→ Ende des Szenenstücks*
- *Über dem Tisch hängt ein Strauß kopfüber am Balken, mit Bast gebunden. Pfingstrosen, getrocknet, papierdünn und dunkel an den Rändern.* `[#draft]`  <sub>flo_dried_1</sub>
- *Eine Karte hängt nicht daran. Am Boden darunter liegen ein paar Blütenblätter. Der Rest des Ladens ist gekehrt.* `[#draft]`  <sub>flo_dried_2</sub>

### S3-15 · `table`

*wenn* `city.letter_told`
  - *Der Bindetisch ist aufgeräumt. Schere, Bast und Papierrolle liegen gerade nebeneinander.* `[#draft]`  <sub>flo_table_3</sub>
  - *→ Ende des Szenenstücks*
- *Auf dem Bindetisch liegen Schere, Bast und Papierrolle im rechten Winkel zueinander. Quer darüber liegt eine Pfingstrose. Sie darf.* `[#draft]`  <sub>flo_table_1</sub>
- *Daneben liegt ein Quittungsblock, in Druckschrift beschrieben. Auf der obersten Quittung steht »Ein Strauß, nicht zu groß, ohne Anlass.«* `[#draft]`  <sub>flo_table_2</sub>

### S3-16 · `shelf`

*wenn* `city.letter_told`
  - *Im Regal stehen die Töpfe in Reihen, jeder mit einem Schild in Druckschrift. Die Erde ist überall feucht.* `[#draft]`  <sub>flo_shelf_4</sub>
  - *→ Ende des Szenenstücks*
- *Im Regal stehen Töpfe in Reihen, jeder mit einem Schild in sauberer Druckschrift. »Paeonia lactiflora«. »Rosa gallica«. »Lavandula, wartet noch«.* `[#draft]`  <sub>flo_shelf_1</sub>
- *An einem Rosenstock steckt ein Schild, »Läuse besiegt. Vorerst.«, zweimal unterstrichen.* `[#draft]`  <sub>flo_shelf_2</sub>
- *Auf einem Topf ohne Pflanze steht »Salvia, kommt noch«. Die Erde darin ist feucht.* `[#draft]`  <sub>flo_shelf_3</sub>
