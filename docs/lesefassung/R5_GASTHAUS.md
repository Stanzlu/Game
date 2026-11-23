# R5 Das Gasthaus (Akt VI)

<!-- Erzeugt mit `python3 tools/writing/readable.py`. Nicht von Hand ändern: Änderungen gehören in die .dialogue-Dateien. -->

Lesefassung: der Text in der Reihenfolge, in der das Spiel ihn zeigt. *Kursiv* ist Erzählung, **fett** sprechen die Figuren, ▸ sind deine Antworten. Eingerückt steht, was nur unter einer Bedingung oder nach einer Antwort kommt. Hinter jeder Zeile die ID in klein.

**So antwortest du:** je Szene (E3, T12 …) „OK“, „ändern: …“ oder „raus“. Was du nicht nennst, gilt als OK.


## gasthaus


### R5-1 · `host_back`

- *Der Wirt hebt die Hand, kaum dass du an den Tresen trittst. Er winkt mit dem ganzen Arm, obwohl du direkt vor ihm stehst.* `[#draft]`  <sub>inn_host_1</sub>
- **Gastwirt:** Da bist du ja! Komm, komm. Der Tisch in der Mitte ist gedeckt, wie immer. Ein besserer Platz? Gibt es nicht. Ein schlechterer auch nicht. `[#draft]`  <sub>inn_host_2</sub>
- **Gastwirt:** Die Suppe kocht, ganz allein. Ich steh daneben und übernehme die Verantwortung. Das ist die halbe Arbeit eines Wirts. `[#draft]`  <sub>inn_host_3</sub>

### R5-2 · `hearth_back`

> --- Der Kamin: das Warum als Ding --------------------------------------------------------------------------------------------------
> Risiko 8: eine Szene, in der seine Strategie richtig war. Sie steht nur als Ding im Raum, nie als Erklärung: die Spuren einer einzigen langen Nacht, in der das Feuer, die Decke und eine Schale Suppe jemandem geholfen haben, und am Morgen ging es wieder.
> Gezeigt an einer Mulde, einer gefalteten Decke, einer Schale, die niemand abgeräumt hat (alles andere in der Halle räumt sich von selbst ab), und einem Zettel in der Schrift des Wirts, der das Ergebnis nennt, nie die Ursache. Wer da saß, ist ein anderer, nicht
> die Spielerin. Kein Name, kein Täter, kein Kind, keine Familie, keine Krankheit, keine Rückblende. Der Kamin ist Gastfreundschaft und keine Rechtfertigung: keine Zeile sagt, ob Betäubung gut oder schlecht ist. Das letzte Wort hat der Zettel. Keine Antwort.

- *Vor dem Kamin liegt ein Teppich mit einer Mulde, rund und tief, wie sie nur eine ganze Nacht Sitzen hinterlässt.* `[#draft]`  <sub>inn_hearth_1</sub>
- *Über der Sessellehne hängt eine Decke, sorgfältig gefaltet, die Ecken genau aufeinander, wie man sie am Morgen zusammenlegt.* `[#draft]`  <sub>inn_hearth_2</sub>
- *Auf dem Boden steht eine Schale, bis auf den Grund ausgelöffelt, mit einem trockenen Ring am Rand. Alles andere in der Halle räumt sich von selbst ab.* `[#draft]`  <sub>inn_hearth_3</sub>
- *Am Sims lehnt ein Zettel in der runden Schrift des Wirts, an den Rändern gelb. Er trägt nur zwei Wörter, »Hat geholfen.«* `[#draft]`  <sub>inn_hearth_4</sub>

### R5-3 · `stay`

> --- Sitzen und Bleiben -------------------------------------------------------------------------------------------------------------
> Die Szene startet stay, sobald sich die Spielerin an den Tisch in der Mitte setzt (einmal je Sitzen), genau wie die Hütte: der erste Besuch hat hier keinen Vorspann. Nach dem dritten Bleiben steht stay_done.

*wenn* `elysia.stay_3`
  - *→ weiter bei* `stay_done`
- *→ weiter bei* `stay_ask`

### R5-4 · `stay_ask`

> Die Frage: der Tisch ist gedeckt, die Bank warm, und niemand sagt, wie lange. Drei Antworten, jede mit eigenen Zeilen (keine Fake Choice); "Bleiben." bringt das nächste Angebot, die anderen beiden lassen die Spielerin sitzen, wie sie sitzt.

- *Die Bank ist warm, der Tisch gedeckt, die Löffel liegen gerade. Niemand sagt, wie lange.* `[#draft]`  <sub>inn_ask_1</sub>
- ▸ **Bleiben.**
  - *→ weiter bei* `stay_next`
- ▸ **Nur sitzen.**
  - *Du sitzt und siehst auf das Gedeck. Niemand räuspert sich, niemand rückt etwas näher.* `[#draft]`  <sub>inn_ask_2</sub>
- ▸ **…**
  - *Das Feuer im Kamin murmelt vor sich hin. Sonst ist nichts zu hören.* `[#draft]`  <sub>inn_ask_3</sub>

### R5-5 · `stay_next`

> Der Dispatcher liest die Flags (er setzt keines): jedes Angebot kommt einmal, in dieser Reihenfolge, auch über mehrere Sitzen verteilt.

*wenn* `elysia.stay_2`
  - *→ weiter bei* `stay_3`
*wenn* `elysia.stay_1`
  - *→ weiter bei* `stay_2`
- *→ weiter bei* `stay_1`

### R5-6 · `stay_1`

> --- Das erste Angebot: Essen ---------------------------------------------------------------------------------------------------------
> Die Suppe kommt, ohne dass sie jemand bringt, und der Wirt hat einen Witz darüber, nicht über die Spielerin: sie schmeckt nach Suppe, mehr verspricht sie nicht, und sie hält es jedes Mal (das Angebot als Vorzug, wie "Es ist dieselbe. Das ist ja das Schöne
> daran."). Kein Wort über sie als Trost oder als Ersatz. Frei abzulehnen: wer nur sitzt, wärmt sich die Hände am Dampf, und der Wirt nimmt es als Essen; wer schweigt, hört den Wirt leiser polieren.

- *Du bleibst. Auf dem Tisch steht eine Schale Suppe, und der Dampf steigt schon auf. Niemand hat sie gebracht.* `[#draft]`  <sub>inn_s1_1</sub>
- **Gastwirt:** Sie schmeckt nach Suppe. Mehr verspricht sie nicht, dafür hält sie es jedes Mal. Das nenn ich Charakter. `[#draft]`  <sub>inn_s1_2</sub>
- **Gastwirt:** Iss, wann du magst, oder lass sie dampfen. Die Suppe hat Geduld. `[#draft]`  <sub>inn_s1_3</sub>
- ▸ **Noch bleiben.**
  - *→ weiter bei* `stay_2`
- ▸ **Nur sitzen.**
  - *Du lässt den Löffel liegen und hältst die Hände über den Dampf.* `[#draft]`  <sub>inn_s1_4</sub>
  - **Gastwirt:** Auch recht! Wärmen ist auch ein Essen, und der Dampf gehört zum Haus. `[#draft]`  <sub>inn_s1_5</sub>
- ▸ **…**
  - *Der Dampf steigt auf, dreht sich einmal und steigt weiter.* `[#draft]`  <sub>inn_s1_6</sub>
  - *Der Wirt poliert am Tresen sein Glas, jetzt leiser, als täte er es auf Zehenspitzen.* `[#draft]`  <sub>inn_s1_7</sub>

### R5-7 · `stay_2`

> --- Das zweite Angebot: Musik --------------------------------------------------------------------------------------------------------
> Ein anderes Ding als die Suppe: die Musik, die hier spielt und immer dieselbe ist. Der Bau von el_host_again_3 ("Hier spielt immer gleich Musik."), neue Worte; sie ist schön und dieselbe, und der Wirt verkauft das als Vorzug (keiner verpasst den
> Anfang). Kein neuer Gedanke, nichts wird lauter. Frei abzulehnen: wer nur sitzt, lässt den Fuß einmal mitwippen; wer schweigt, hört die Musik die Halle bis zu den Balken füllen.

- *Du bleibst noch. Die Musik im Hintergrund hörst du erst jetzt, warm und langsam.* `[#draft]`  <sub>inn_s2_1</sub>
- **Gastwirt:** Hör, unsere Musik! Wir haben nur die eine. Dafür kennt sie jeder, und keiner verpasst den Anfang. `[#draft]`  <sub>inn_s2_2</sub>
- **Gastwirt:** Hör zu oder hör nicht zu. Sie spielt für beides. `[#draft]`  <sub>inn_s2_3</sub>
- ▸ **Noch bleiben.**
  - *→ weiter bei* `stay_3`
- ▸ **Nur sitzen.**
  - *Du sitzt. Dein Fuß wippt einmal mit, und du lässt ihn.* `[#draft]`  <sub>inn_s2_4</sub>
  - *Die Musik tut, als hätte sie es nicht gesehen.* `[#draft]`  <sub>inn_s2_5</sub>
- ▸ **…**
  - *Die Musik füllt die Halle bis zu den Balken und nicht weiter.* `[#draft]`  <sub>inn_s2_6</sub>

### R5-8 · `stay_3`

> --- Das dritte Angebot: Ruhe ---------------------------------------------------------------------------------------------------------
> Ein drittes, anderes Ding: das Feuer, das Fenster, das Licht, das Zimmer hinter der Tür. Es hat keine Antwort, weil es nichts zu fragen gibt: der Wirt sagt ruhig und ohne Hintersinn, dass sie jederzeit gehen kann (der Bau von "Du kannst jederzeit gehen.
> Das hab ich nie anders gesagt.", neue Worte), und dass es hier schön ist (der Bau von "Hier ist es schön. Das hab ich nicht erfunden, das ist es einfach.", neue Worte). Danach stehen alle drei Angebote hinter ihr. Die Erzählung endet ohne Folgerung:
> die Tür ist, wo sie war. Das Spiel speichert nach dieser Zeile einmal (die Szene, nicht der Cue).

- *Du bleibst noch einmal. Das Feuer brennt ruhig, und im Fenster steht der Garten. Unter einer der zwei Türen hinter dem Tresen liegt ein Streifen warmes Licht.* `[#draft]`  <sub>inn_s3_1</sub>
- **Gastwirt:** Gehen kannst du jederzeit. Etwas anderes hab ich nie behauptet. `[#draft]`  <sub>inn_s3_2</sub>
- **Gastwirt:** Schön ist es hier. Dafür kann ich nichts. Ich wische nur die Tische. `[#draft]`  <sub>inn_s3_3</sub>
- *Die Tür nach draußen ist, wo sie war, und das Licht liegt auf dem Tisch, wie es lag.* `[#draft]`  <sub>inn_s3_4</sub>

### R5-9 · `stay_done`

> --- Danach: Bleiben ohne Ende --------------------------------------------------------------------------------------------------------
> Jedes weitere Sitzen beginnt hier. Die Angebote kommen nicht wieder (kein viertes, nichts wiederholt sich in anderen Worten), die Wärme bleibt. Der Tisch ist gedeckt, die Bank warm, niemand sagt etwas.

- *Der Tisch ist gedeckt, die Bank warm, und das Feuer brennt. Niemand sagt etwas.* `[#draft]`  <sub>inn_done_1</sub>
- *→ weiter bei* `stay_more`

### R5-10 · `stay_more`

- ▸ **Bleiben.**
  - *→ weiter bei* `stay_calm`
- ▸ **Nur sitzen.**
  - *Du sitzt, und die Bank sagt nichts dazu.* `[#draft]`  <sub>inn_done_2</sub>
- ▸ **…**
  - *Der Löffel liegt neben dem Teller und hat keine Eile.* `[#draft]`  <sub>inn_done_3</sub>

### R5-11 · `stay_calm`

> Kurze, wechselnde Zeilen: nichts wird besser, nichts schlechter. Der Wirt wird nicht sinister, die Musik nicht lauter, das Essen nicht mehr, und niemand bietet etwas an. Bleiben bleibt erlaubt, unbegrenzt.

- *Du bleibst. Die Bank bleibt warm, und am Tresen klirrt leise ein Glas.* `[#draft]`  <sub>inn_calm_1</sub>
- *Du bleibst. Das Feuer brennt, wie es brennt.* `[#draft]`  <sub>inn_calm_2</sub>
- *Du bleibst. Der Wirt wischt einen Tisch, ohne aufzusehen, und es klingt nach Gesellschaft.* `[#draft]`  <sub>inn_calm_3</sub>
- *→ weiter bei* `stay_more`
