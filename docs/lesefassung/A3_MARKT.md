# A3: Der Markt

<!-- Erzeugt mit `python3 tools/writing/readable.py`. Nicht von Hand ändern: Änderungen gehören in die .dialogue-Dateien. -->

Lesefassung: der Text in der Reihenfolge, in der das Spiel ihn zeigt. *Kursiv* ist Erzählung, **fett** sprechen die Figuren, ▸ sind deine Antworten. Eingerückt steht, was nur unter einer Bedingung oder nach einer Antwort kommt. Hinter jeder Zeile die ID in klein.

**So antwortest du:** je Szene (E3, T12 …) „OK“, „ändern: …“ oder „raus“. Was du nicht nennst, gilt als OK.


## markt


### M1 · `gatekeeper`

*wenn* `elysia.market_greeted nicht`
  - **Torwächter:** Willkommen in der Stadt! Das Tor steht offen. Es stand immer offen. `[#draft]`  <sub>mk_gate_1</sub>
  - **Torwächter:** Ich bin der Torwächter. Ich passe darauf auf, dass es offen bleibt. Es ist eine ruhige Arbeit. `[#draft]`  <sub>mk_gate_2</sub>
  - **Torwächter:** Der Markt liegt vor dir. Die Halle der Spiegel öffnet morgen. Morgen ist bald. `[#draft]`  <sub>mk_gate_3</sub>
*sonst*
  - **Torwächter:** Das Tor ist offen. Wie immer. `[#draft]`  <sub>mk_gate_4</sub>
  - **Torwächter:** Zurück zum Garten geht es die Treppe hinauf. Du kennst sie. `[#draft]`  <sub>mk_gate_5</sub>
  - **Torwächter:** Gutes Wetter heute. Heute ist hier jeden Tag gutes Wetter. `[#draft]`  <sub>mk_gate_6</sub>

### M2 · `baker`

*wenn* `side_elysia_board und bread`
  - **Bäckerin:** Das Brot für die Schneiderin! Es ist fertig. Es ist immer fertig, wenn jemand danach fragt. `[#draft]`  <sub>mk_baker_1</sub>
  - *Du bekommst einen Laib. Er ist noch warm. Du wirst ihn tragen, und er bleibt es.* `[#draft]`  <sub>mk_baker_2</sub>
*sonst*
  - **Bäckerin:** Frisch gebacken. Von gestern. `[#draft]`  <sub>mk_baker_3</sub>
  - **Bäckerin:** Mein Brot hat noch niemand zurückgebracht. Sie essen es auf. Alle. `[#draft]`  <sub>mk_baker_4</sub>
  - **Bäckerin:** Der Teig geht von selbst auf. Ich schaue ihm nur zu. `[#draft]`  <sub>mk_baker_5</sub>

### M3 · `tailor`

*wenn* `side_elysia_board und deliver und item_loaf`
  - *→ weiter bei* `tailor_bread`
*sonst wenn* `side_elysia_board und bread`
  - **Schneiderin:** Ich warte auf Brot. Ich warte gern. Das Warten sitzt mir wie angegossen. `[#draft]`  <sub>mk_tailor_1</sub>
*sonst*
  - **Schneiderin:** Ich nähe, was dir passt. Es passt immer. Ich messe nur zur Höflichkeit. `[#draft]`  <sub>mk_tailor_2</sub>
  - **Schneiderin:** Rot steht dir. Blau steht dir. Alles steht dir. Das ist das Schwierige an meiner Arbeit. `[#draft]`  <sub>mk_tailor_3</sub>
  - **Schneiderin:** Zwei Ärmel, zwei Beine, zwei Taschen. Ich mache nie etwas allein. `[#draft]`  <sub>mk_tailor_4</sub>

### M4 · `tailor_bread`

- **Schneiderin:** Mein Brot! Das habe ich gestern schon bekommen. Danke trotzdem. Zweimal schmeckt es besser. `[#draft]`  <sub>mk_tailor_5</sub>
- **Schneiderin:** Hier ist dein Lohn. Er war schon für dich abgezählt. `[#draft]`  <sub>mk_tailor_6</sub>

### M5 · `merchant`

*wenn* `elysia.market_shop_seen`
  - **Händler:** Na? Wieder da? Schau dir an, was da ist. Es ist immer da. `[#draft]`  <sub>mk_shop_2</sub>
*sonst*
  - **Händler:** Kommt näher, kommt näher! Alles, was du brauchst, und noch ein bisschen mehr. `[#draft]`  <sub>mk_shop_1</sub>
  - **Händler:** Es kostet nicht viel. Es kostet nur Gold, und davon hast du reichlich. `[#draft]`  <sub>mk_shop_3</sub>
- *→ weiter bei* `merchant_wares`

### M6 · `merchant_wares`

- ▸ **Ein Kompliment, zehn Gold.** *(wenn `item_compliment nicht`)*
  - **Händler:** Ein Kompliment! Das Schönste, was ich habe. Ich habe nur das eine, aber das ist sehr schön. `[#draft]`  <sub>mk_shop_4</sub>
- ▸ **Den Glücksbringer, hundertfünfzig Gold.** *(wenn `item_trinket nicht`)*
  - **Händler:** Der Glücksbringer! Er bringt Glück. Welches, steht nicht drauf. `[#draft]`  <sub>mk_shop_5</sub>
- ▸ **Ich schaue nur.**
  - **Händler:** Schau nur, schau nur. Schauen ist bei mir umsonst. Alles andere auch, aber das sage ich nicht laut. `[#draft]`  <sub>mk_shop_6</sub>

### M7 · `florist`

- **Blumenfrau:** Nimm eine! Sie kosten nichts. Das ist der Preis. `[#draft]`  <sub>mk_flower_1</sub>
- **Blumenfrau:** Ich binde jeden Morgen einen Strauß. Am Abend ist er noch frisch. Am nächsten Morgen auch. `[#draft]`  <sub>mk_flower_2</sub>
- **Blumenfrau:** Meine Rosen duften nach Rosen. Ich habe lange geübt, dass sie nach nichts anderem duften. `[#draft]`  <sub>mk_flower_3</sub>

### M8 · `poet`

- **Dichter:** Hör zu, ich habe es gerade fertig. `[#draft]`  <sub>mk_poet_1</sub>
- **Dichter:** Der Tag ist schön, der Himmel blau, der Brunnen klar, die Luft ist lau. `[#draft]`  <sub>mk_poet_2</sub>
- ▸ **Wunderbar.**
  - **Dichter:** Nicht wahr? Morgen schreibe ich es noch einmal. Dann wird es noch besser. `[#draft]`  <sub>mk_poet_3</sub>
- ▸ **Gibt es auch eines über etwas anderes?**
  - **Dichter:** Über etwas anderes? … `[#draft]`  <sub>mk_poet_4</sub>
  - **Dichter:** Der Tag ist schön, der Himmel blau. Nein. Das war es schon. Das reicht doch auch. `[#draft]`  <sub>mk_poet_5</sub>
- ▸ **…**
  - **Dichter:** Du bist sprachlos. Das ist das beste Reimwort, das es gibt. `[#draft]`  <sub>mk_poet_6</sub>

### M9 · `musician`

*wenn* `melody.elysia_perfect`
  - **Musikerin:** Gefällt sie dir noch? Ich spiele sie, bis du gehst. Und danach. `[#draft]`  <sub>mk_music_5</sub>
- **Musikerin:** Hör zu. Das ist die schönste Melodie der Stadt. Sie ist auch die einzige. `[#draft]`  <sub>mk_music_1</sub>
- **Musikerin:** Sie hat keine Fehler. Ich habe nachgezählt. Es sind keine da. `[#draft]`  <sub>mk_music_2</sub>
- ▸ **Zuhören.**
  - *Du hörst zu. Sie geht auf, sie geht zu, sie geht wieder auf. Genau so, wie sie soll.* `[#draft]`  <sub>mk_music_3</sub>
  - **Musikerin:** Siehst du? Perfekt. Ich bringe sie dir bei, wenn du willst. Du kannst sie schon. `[#draft]`  <sub>mk_music_4</sub>
- ▸ **Weitergehen.**
  - **Musikerin:** Sie spielt auch, wenn du gehst. `[#draft]`  <sub>mk_music_6</sub>
- ▸ **…**
  - **Musikerin:** Ein Kenner. Er hört mit dem ganzen Gesicht. `[#draft]`  <sub>mk_music_7</sub>

### M10 · `board`

*wenn* `side_elysia_board`
  - *Alle Zettel sind abgehakt. Darunter hängen neue, genau wie die alten.* `[#draft]`  <sub>mk_board_8</sub>
*sonst wenn* `side_elysia_board`
  - *Der Auftrag hängt noch. Brot, Bäckerin, Schneiderin. Der Rest ist Weg.* `[#draft]`  <sub>mk_board_7</sub>
- *Eine Tafel voller Zettel in schöner Schrift.* `[#draft]`  <sub>mk_board_1</sub>
- *Zu verschenken, ein Nachmittag. Einer von vielen.* `[#draft]`  <sub>mk_board_2</sub>
- *Der Chor probt heute Abend. Er probt jeden Abend. Er ist sehr gut.* `[#draft]`  <sub>mk_board_3</sub>
- *Hinweis, das Fest findet statt. Es ist das Fest von gestern. Es ist das Fest von morgen.* `[#draft]`  <sub>mk_board_4</sub>
- *Gesucht, ein Held. Aufgabe, Brot von der Bäckerin zur Schneiderin tragen. Lohn, Ruhm. Und mehr.* `[#draft]`  <sub>mk_board_5</sub>
- ▸ **Den Auftrag annehmen.**
  - *Du nimmst den Zettel ab. Er hängt sofort wieder da.* `[#draft]`  <sub>mk_board_6</sub>
- ▸ **Später.**

### M11 · `fountain`

- *Der Brunnen plätschert. Das Wasser im Becken rechts ist dasselbe Wasser wie links. Es fließt nur in zwei Richtungen.* `[#draft]`  <sub>mk_fountain_1</sub>
- ▸ **Eine Münze hineinwerfen, zehn Gold.** *(wenn `gold() >= 10`)*
  - *Die Münze sinkt. Du wünschst dir etwas. Es geht in Erfüllung, noch bevor du fertig bist.* `[#draft]`  <sub>mk_fountain_2</sub>
- ▸ **Weitergehen.**

### M12 · `hall_door`

- *Die Türen der Halle der Spiegel sind verschlossen. Auf einem Schild steht in goldener Schrift, geöffnet ab morgen.* `[#draft]`  <sub>mk_hall_1</sub>
- *Das Schild sieht aus, als stünde es schon sehr lange da.* `[#draft]`  <sub>mk_hall_2</sub>
