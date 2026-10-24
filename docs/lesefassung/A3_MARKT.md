# A3 und A6: Der Markt

<!-- Erzeugt mit `python3 tools/writing/readable.py`. Nicht von Hand ändern: Änderungen gehören in die .dialogue-Dateien. -->

Lesefassung: der Text in der Reihenfolge, in der das Spiel ihn zeigt. *Kursiv* ist Erzählung, **fett** sprechen die Figuren, ▸ sind deine Antworten. Eingerückt steht, was nur unter einer Bedingung oder nach einer Antwort kommt. Hinter jeder Zeile die ID in klein.

**So antwortest du:** je Szene (E3, T12 …) „OK“, „ändern: …“ oder „raus“. Was du nicht nennst, gilt als OK.


## markt


### M1 · `gatekeeper`

*wenn* `elysia.loops`
  - **Torwächter:** Willkommen in der Stadt! Das Tor steht offen. Es stand immer offen. `[#draft]`  <sub>mk_gate_10</sub>
*wenn* `elysia.feast`
  - **Torwächter:** Heute feiern wir. Das Tor feiert mit. Es steht noch offener als sonst. `[#draft]`  <sub>mk_gate_7</sub>
  - **Torwächter:** Geh nur zum Fest. Ich passe darauf auf, dass es stattfindet. `[#draft]`  <sub>mk_gate_8</sub>
  - **Torwächter:** Das Fest ist vom Tor aus am schönsten. Man sieht es zweimal. `[#draft]`  <sub>mk_gate_9</sub>
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
*sonst wenn* `elysia.loops`
  - **Bäckerin:** Frisch gebacken. Von gestern. `[#draft]`  <sub>mk_baker_8</sub>
*sonst wenn* `elysia.feast`
  - **Bäckerin:** Für das Fest backe ich alles zweimal. Gegessen wird es trotzdem nur einmal. `[#draft]`  <sub>mk_baker_6</sub>
  - **Bäckerin:** Heute gibt es Brot. Wie jeden Tag. Aber festlich. `[#draft]`  <sub>mk_baker_7</sub>
*sonst*
  - **Bäckerin:** Frisch gebacken. Von gestern. `[#draft]`  <sub>mk_baker_3</sub>
  - **Bäckerin:** Mein Brot hat noch niemand zurückgebracht. Sie essen es auf. Alle. `[#draft]`  <sub>mk_baker_4</sub>
  - **Bäckerin:** Der Teig geht von selbst auf. Ich schaue ihm nur zu. `[#draft]`  <sub>mk_baker_5</sub>

### M3 · `tailor`

*wenn* `side_elysia_board und deliver und item_loaf`
  - *→ weiter bei* `tailor_bread`
*sonst wenn* `side_elysia_board und bread`
  - **Schneiderin:** Ich warte auf Brot. Ich warte gern. Das Warten sitzt mir wie angegossen. `[#draft]`  <sub>mk_tailor_1</sub>
*sonst wenn* `elysia.loops`
  - **Schneiderin:** Ich nähe, was dir passt. Es passt immer. Ich messe nur zur Höflichkeit. `[#draft]`  <sub>mk_tailor_9</sub>
*sonst wenn* `elysia.feast`
  - **Schneiderin:** Für das Fest habe ich allen dasselbe genäht. Es steht allen. `[#draft]`  <sub>mk_tailor_7</sub>
  - **Schneiderin:** Ein Fest ist wie ein Anzug. Es passt, ohne dass man es anprobiert hat. `[#draft]`  <sub>mk_tailor_8</sub>
*sonst*
  - **Schneiderin:** Ich nähe, was dir passt. Es passt immer. Ich messe nur zur Höflichkeit. `[#draft]`  <sub>mk_tailor_2</sub>
  - **Schneiderin:** Rot steht dir. Blau steht dir. Alles steht dir. Das ist das Schwierige an meiner Arbeit. `[#draft]`  <sub>mk_tailor_3</sub>
  - **Schneiderin:** Zwei Ärmel, zwei Beine, zwei Taschen. Ich mache nie etwas allein. `[#draft]`  <sub>mk_tailor_4</sub>

### M4 · `tailor_bread`

- **Schneiderin:** Mein Brot! Das habe ich gestern schon bekommen. Danke trotzdem. Zweimal schmeckt es besser. `[#draft]`  <sub>mk_tailor_5</sub>
- **Schneiderin:** Hier ist dein Lohn. Er war schon für dich abgezählt. `[#draft]`  <sub>mk_tailor_6</sub>

### M5 · `merchant`

*wenn* `elysia.loops`
  - **Händler:** Kommt näher, kommt näher! Alles, was du brauchst, und noch ein bisschen mehr. `[#draft]`  <sub>mk_shop_8</sub>
*sonst wenn* `elysia.market_shop_seen`
  - **Händler:** Na? Wieder da? Schau dir an, was da ist. Es ist immer da. `[#draft]`  <sub>mk_shop_2</sub>
*sonst*
  - **Händler:** Kommt näher, kommt näher! Alles, was du brauchst, und noch ein bisschen mehr. `[#draft]`  <sub>mk_shop_1</sub>
  - **Händler:** Es kostet nicht viel. Es kostet nur Gold, und davon hast du reichlich. `[#draft]`  <sub>mk_shop_3</sub>
*wenn* `elysia.feast und elysia.loops nicht`
  - **Händler:** Und heute ist alles festlich. Zum selben Preis, aber festlich. `[#draft]`  <sub>mk_shop_7</sub>
- *→ weiter bei* `merchant_wares`

### M6 · `merchant_wares`

- ▸ **Ein Kompliment, zehn Gold.** *(wenn `item_compliment nicht`)*
  - **Händler:** Ein Kompliment! Das Schönste, was ich habe. Ich habe nur das eine, aber das ist sehr schön. `[#draft]`  <sub>mk_shop_4</sub>
- ▸ **Den Glücksbringer, hundertfünfzig Gold.** *(wenn `item_trinket nicht`)*
  - **Händler:** Der Glücksbringer! Er bringt Glück. Welches, steht nicht drauf. `[#draft]`  <sub>mk_shop_5</sub>
- ▸ **Ich schaue nur.**
  - **Händler:** Schau nur, schau nur. Schauen ist bei mir umsonst. Alles andere auch, aber das sage ich nicht laut. `[#draft]`  <sub>mk_shop_6</sub>

### M7 · `florist`

*wenn* `elysia.loops`
  - **Blumenfrau:** Nimm eine! Sie kosten nichts. Das ist der Preis. `[#draft]`  <sub>mk_flower_6</sub>
*wenn* `elysia.feast`
  - **Blumenfrau:** Heute binde ich Kränze. Für alle, für jeden dasselbe. `[#draft]`  <sub>mk_flower_4</sub>
  - **Blumenfrau:** Ein Fest ohne Blumen ist ein Fest. Mit Blumen ist es meins. `[#draft]`  <sub>mk_flower_5</sub>
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
  - **Dichter:** Der Tag ist schön, der Himmel blau. Das war es schon. Das reicht doch auch. `[#draft]`  <sub>mk_poet_5</sub>
- ▸ **…**
  - **Dichter:** Du bist sprachlos. Das ist das beste Reimwort, das es gibt. `[#draft]`  <sub>mk_poet_6</sub>
- ▸ **Das hast du gestern auch gesagt.** *(wenn `perception`)*
  - **Dichter:** Gestern? Gestern hat es sich auch gereimt. Das ist ja das Schöne. `[#draft]`  <sub>mk_poet_7</sub>

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

*wenn* `elysia.hall_open`
  - *Die Türen der Halle der Spiegel stehen offen. Dahinter ist es hell.* `[#draft]`  <sub>mk_hall_5</sub>
- *Die Türen der Halle der Spiegel sind zu. Auf einem Schild steht in goldener Schrift, geöffnet ab morgen.* `[#draft]`  <sub>mk_hall_1</sub>
- *Das Schild sieht aus, als stünde es schon sehr lange da.* `[#draft]`  <sub>mk_hall_2</sub>
- ▸ **Gegen die Türen drücken.**
  - *Die Türen geben nach. Sie waren nie abgeschlossen. Nur das Schild steht davor.* `[#draft]`  <sub>mk_hall_3</sub>
- ▸ **Morgen wiederkommen.**
  - *Du gehst. Morgen ist bald. Es ist hier immer bald.* `[#draft]`  <sub>mk_hall_4</sub>

### M13 · `host_feast`

> Das Fest (A6): der Markt im Festzustand. Der Gastwirt lädt ein, die Festmeisterin hat ein Hoch; das Hoch bringt rund
> elftausend Erfahrung für das Heben eines Glases (Bible §10: die Belohnung wächst, die Tat schrumpft).

*wenn* `elysia.feast_toast`
  *wenn* `elysia.feast_noticed`
    - **Gastwirt:** Du hast es bemerkt. Das macht nichts. Hier darf man bemerken, so viel man will. `[#draft]`  <sub>mk_host_5</sub>
  *sonst*
    - **Gastwirt:** Na, wie ist das Fest? Es ist das beste. Es ist immer das beste. `[#draft]`  <sub>mk_host_4</sub>
  - **Gastwirt:** Du musst heute nicht zurück. Das Fest hat keinen Abend. `[#draft]`  <sub>mk_host_6</sub>
- **Gastwirt:** Da ist er! Der Held des Tages! Jedes Tages! Komm, komm zum Fest. Ein Platz ist frei. Es ist immer ein Platz frei. `[#draft]`  <sub>mk_host_1</sub>
- **Gastwirt:** Die Festmeisterin wartet am Brunnen. Sie hat ein Hoch für dich. Sie hat jedes Mal ein Hoch. `[#draft]`  <sub>mk_host_2</sub>
- ▸ **Ich komme.**
  - **Gastwirt:** Wunderbar! Ich sag ihr Bescheid. Ich hab ihr schon Bescheid gesagt. `[#draft]`  <sub>mk_host_3</sub>
- ▸ **Ich schau mich nur um.**
  - **Gastwirt:** Schau nur, schau nur. Das Fest läuft von selbst. Es läuft schon immer. `[#draft]`  <sub>mk_host_7</sub>
- ▸ **…**
  - **Gastwirt:** Ein stiller Gast. Die besten Feste haben welche. `[#draft]`  <sub>mk_host_8</sub>

### M14 · `festmaster`

*wenn* `elysia.feast_toast`
  - **Festmeisterin:** Da ist er! Der Held des Festes! Wir haben alles für dich vorbereitet. Wir haben alles immer für dich vorbereitet. `[#draft]`  <sub>mk_fest_9</sub>
*wenn* `elysia.feast_invited`
  - **Festmeisterin:** Der Gastwirt hat dich angekündigt. Er ist sehr zuverlässig. Er sagt immer vorher, was ich nachher sage. `[#draft]`  <sub>mk_fest_1</sub>
*sonst*
  - **Festmeisterin:** Da ist er! Der Held des Festes! Wir haben alles für dich vorbereitet. Wir haben alles immer für dich vorbereitet. `[#draft]`  <sub>mk_fest_2</sub>
- **Festmeisterin:** Es fehlt nur noch ein Hoch. Du musst dafür nichts tun. Du hebst das Glas, wir machen den Rest. `[#draft]`  <sub>mk_fest_3</sub>
- ▸ **Das Glas heben.**
  - *→ weiter bei* `festmaster_toast`
- ▸ **Das ist dasselbe Fest wie gestern.** *(wenn `perception`)*
  - **Festmeisterin:** Dasselbe? Gestern war es kleiner. Heute ist es größer. `[#draft]`  <sub>mk_fest_4</sub>
  - *→ weiter bei* `festmaster_toast`
- ▸ **Später.**
  - **Festmeisterin:** Später ist gut. Später ist hier immer genau jetzt. `[#draft]`  <sub>mk_fest_5</sub>

### M15 · `festmaster_toast`

- *Du hebst das Glas. Ganz Elysia hebt seines, im selben Augenblick.* `[#draft]`  <sub>mk_fest_6</sub>
- **Festmeisterin:** Auf den Helden! Auf den Helden! Auf den Helden! `[#draft]`  <sub>mk_fest_7</sub>
- *Es klingt dreimal gleich. Die Gläser klingen mit.* `[#draft]`  <sub>mk_fest_8</sub>

### M16 · `feast_guest`

- **Elysianer:** Auf den Helden! `[#draft]`  <sub>mk_guest_1</sub>
