# R6 Das Aufstehen (Akt VI)

<!-- Erzeugt mit `python3 tools/writing/readable.py`. Nicht von Hand ändern: Änderungen gehören in die .dialogue-Dateien. -->

Lesefassung: der Text in der Reihenfolge, in der das Spiel ihn zeigt. *Kursiv* ist Erzählung, **fett** sprechen die Figuren, ▸ sind deine Antworten. Eingerückt steht, was nur unter einer Bedingung oder nach einer Antwort kommt. Hinter jeder Zeile die ID in klein.

**So antwortest du:** je Szene (E3, T12 …) „OK“, „ändern: …“ oder „raus“. Was du nicht nennst, gilt als OK.


## aufstehen


### R6-1 · `stand_first`

- *Du stehst auf. Die Bank knarrt einmal und hält dann still.* `[#draft]`  <sub>up_1</sub>
- *Die Musik spielt genau dort weiter, wo sie war. Niemand hat sie leiser gemacht, und niemand lauter.* `[#draft]`  <sub>up_2</sub>
- **Gastwirt:** Musst du? Wirklich? `[#draft]`  <sub>up_3</sub>
- *Er fragt es leicht, so wie man fragt, ob noch Salz fehlt. Sein Tuch bleibt mitten auf dem Glas stehen.* `[#draft]`  <sub>up_4</sub>
- **Gastwirt:** … Na gut. `[#draft]`  <sub>up_5</sub>
- **Gastwirt:** Aber nimm die Suppe mit. Sie kocht ohnehin für zu viele. `[#draft]`  <sub>up_6</sub>
- *Die Schale auf dem Tisch trägt jetzt einen Teller als Deckel, den vorhin niemand gebracht hat. Du nimmst sie mit beiden Händen, sie ist noch warm.* `[#draft]`  <sub>up_7</sub>
- **Gastwirt:** Sie schmeckt dort, wo du hingehst, genauso nach Suppe. Mehr verspricht sie nicht. `[#draft]`  <sub>up_8</sub>
- *Der Wirt wischt den Tisch, an dem du gesessen hast. Er ist schon sauber.* `[#draft]`  <sub>up_9</sub>

### R6-2 · `host_after`

> --- Der Wirt danach --------------------------------------------------------------------------------------------------------------------
> Wer nach dem Aufstehen mit ihm spricht (die Karte wählt host_after mit elysia.stood_up), findet denselben Wirt: ohne Angebot, ohne Frage nach dem Bleiben, mit dem Witz über seine Arbeit (ein Bau von inn_host_3, "die halbe Arbeit eines Wirts": die andere Hälfte ist das Wischen).
> Drei Antworten mit eigenen Zeilen: "Tanzen?" nur mit der Facette aliveness (das Spielen ist hier eine Idee der Spielerin, und er freut sich, ohne etwas daraus zu machen), "Danke für die Suppe." (er schiebt den Dank der Suppe zu),
> das Schweigen zuletzt (er nimmt es, als hättest du etwas gesagt). Nichts davon setzt etwas.

- **Gastwirt:** Na? Ich wisch hier nur noch kurz. Das ist die andere Hälfte der Arbeit eines Wirts. `[#draft]`  <sub>up_h1</sub>
- ▸ **Tanzen?** *(wenn `aliveness`)*
  - **Gastwirt:** Tanzen! Hier? Warte, die Bänke gehen von selbst zur Seite. `[#draft]`  <sub>up_h2</sub>
  - **Gastwirt:** Wir haben nur die eine Musik, aber getanzt hat noch nie jemand zu ihr. Sie wird ganz nervös. `[#draft]`  <sub>up_h3</sub>
  - *Er stellt sein Glas ab, so behutsam, als könnte es die Idee zerbrechen.* `[#draft]`  <sub>up_h4</sub>
- ▸ **Danke für die Suppe.**
  - **Gastwirt:** Danke der Suppe. Sie hat gekocht, ich hab nur zugesehen. `[#draft]`  <sub>up_h5</sub>
- ▸ **…**
  - *Der Wirt nickt, als hättest du etwas gesagt, und nimmt sein Tuch wieder auf.* `[#draft]`  <sub>up_h6</sub>
