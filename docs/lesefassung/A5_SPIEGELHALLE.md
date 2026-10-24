# A5: Die Halle der Spiegel

<!-- Erzeugt mit `python3 tools/writing/readable.py`. Nicht von Hand ändern: Änderungen gehören in die .dialogue-Dateien. -->

Lesefassung: der Text in der Reihenfolge, in der das Spiel ihn zeigt. *Kursiv* ist Erzählung, **fett** sprechen die Figuren, ▸ sind deine Antworten. Eingerückt steht, was nur unter einer Bedingung oder nach einer Antwort kommt. Hinter jeder Zeile die ID in klein.

**So antwortest du:** je Szene (E3, T12 …) „OK“, „ändern: …“ oder „raus“. Was du nicht nennst, gilt als OK.


## spiegelhalle


### S1 · `keeper`

*wenn* `elysia.hall_mirror_seen`
  - **Hallenwächter:** Du hast es gesehen. Das ist selten. Es ist nicht schwer, es ist nur selten. `[#draft]`  <sub>sh_keeper_4</sub>
*sonst wenn* `elysia.hall_met nicht`
  - **Hallenwächter:** Willkommen in der Halle der Spiegel. Hier steht alles zweimal. `[#draft]`  <sub>sh_keeper_1</sub>
  - **Hallenwächter:** Links, rechts, genau gleich. Fast. `[#draft]`  <sub>sh_keeper_2</sub>
  - **Hallenwächter:** Ich stehe in der Mitte. Darum gibt es mich nur einmal. Das ist die einzige Ausnahme, die ich kenne. `[#draft]`  <sub>sh_keeper_3</sub>
*sonst*
  - **Hallenwächter:** Schau dich um. Ich habe Zeit. Die Halle hat sie auch. `[#draft]`  <sub>sh_keeper_5</sub>
- *→ weiter bei* `keeper_hints`

### S2 · `keeper_hints`

- ▸ **Ein Hinweis, bitte.**
  - *→ weiter bei* `keeper_hint_1`
- ▸ **Etwas genauer?**
  - *→ weiter bei* `keeper_hint_2`
- ▸ **Sag es mir.**
  - *→ weiter bei* `keeper_hint_3`
- ▸ **Ich schaue selbst.**
  - **Hallenwächter:** Gut. Schauen ist das Einzige, was hier verlangt wird. `[#draft]`  <sub>sh_keeper_6</sub>

### S3 · `keeper_hint_1`

*wenn* `elysia.hall_room_1 nicht`
  - **Hallenwächter:** Alles in diesem Raum hat auf der anderen Seite einen Zwilling. Such das, was keinen hat. `[#draft]`  <sub>sh_hint_1</sub>
*sonst wenn* `elysia.hall_room_2 nicht`
  - **Hallenwächter:** Der nächste Raum ist größer und nicht anders. Wieder liegt etwas nur auf einer Seite. `[#draft]`  <sub>sh_hint_2</sub>
*sonst*
  - **Hallenwächter:** Der letzte Raum hat nichts zu suchen. Er hat etwas zu zeigen. `[#draft]`  <sub>sh_hint_3</sub>
- *→ weiter bei* `keeper_hints`

### S4 · `keeper_hint_2`

*wenn* `elysia.hall_room_1 nicht`
  - **Hallenwächter:** Es liegt am Boden. Links, zwischen den beiden Säulen. `[#draft]`  <sub>sh_hint_4</sub>
*sonst wenn* `elysia.hall_room_2 nicht`
  - **Hallenwächter:** Es liegt am Boden. Rechts, zwischen den beiden Säulen. `[#draft]`  <sub>sh_hint_5</sub>
*sonst*
  - **Hallenwächter:** Geh bis ganz nach oben. Dort hängt ein Spiegel, und er ist groß. `[#draft]`  <sub>sh_hint_6</sub>
- *→ weiter bei* `keeper_hints`

### S5 · `keeper_hint_3`

*wenn* `elysia.hall_room_1 nicht`
  - **Hallenwächter:** Ein Blatt. Braun und trocken. Es ist das Einzige hier, das alt werden durfte. `[#draft]`  <sub>sh_hint_7</sub>
*sonst wenn* `elysia.hall_room_2 nicht`
  - **Hallenwächter:** Eine Feder. Blaugrau. Die Halle hat keine Vögel, und trotzdem. `[#draft]`  <sub>sh_hint_8</sub>
*sonst*
  - **Hallenwächter:** Stell dich vor den Spiegel und sieh hin. Mehr ist es nicht. `[#draft]`  <sub>sh_hint_9</sub>
- *→ weiter bei* `keeper_hints`

### S6 · `gate_shut`

- *Das Tor ist zu. Zwei Spiegel in einem Rahmen, beide zeigen dasselbe.* `[#draft]`  <sub>sh_gate_1</sub>
- *Es bleibt zu, bis dir etwas auffällt.* `[#draft]`  <sub>sh_gate_2</sub>

### S7 · `leaf`

*wenn* `elysia.hall_room_1`
  - *Das Blatt liegt noch da. Du hast es dir schon angesehen.* `[#draft]`  <sub>sh_leaf_5</sub>
*sonst*
  - *Ein Blatt liegt auf dem Marmor. Es ist braun, trocken, an den Rändern gewellt.* `[#draft]`  <sub>sh_leaf_1</sub>
  - *Auf der anderen Seite der Halle liegt keines.* `[#draft]`  <sub>sh_leaf_2</sub>
  - *Du hast es bemerkt. Weiter vorn macht das Tor ein Geräusch, das es noch nie gemacht hat.* `[#draft]`  <sub>sh_leaf_3</sub>
- ▸ **Es aufheben.**
  - *Es raschelt. In dieser Halle klingt sonst nichts, was nicht schon geklungen hat.* `[#draft]`  <sub>sh_leaf_4</sub>
- ▸ **Liegen lassen.**
  - *Du lässt es, wo es liegt. Es liegt gut.* `[#draft]`  <sub>sh_leaf_6</sub>

### S8 · `feather`

*wenn* `elysia.hall_room_2`
  - *Die Feder liegt noch da. Du hast sie dir schon angesehen.* `[#draft]`  <sub>sh_feather_5</sub>
*sonst*
  - *Eine Feder liegt am Boden, blaugrau, am Rand zerzaust. Die Halle hat keine Vögel.* `[#draft]`  <sub>sh_feather_1</sub>
  - *Auf der anderen Seite liegt keine.* `[#draft]`  <sub>sh_feather_2</sub>
  - *Du hast es bemerkt. Weiter oben bewegt sich das Tor.* `[#draft]`  <sub>sh_feather_3</sub>
- ▸ **Sie einstecken.**
  - *Sie wiegt nichts, und trotzdem merkst du es.* `[#draft]`  <sub>sh_feather_4</sub>
- ▸ **Liegen lassen.**
  - *Du lässt sie, wo sie liegt. Sie liegt gut.* `[#draft]`  <sub>sh_feather_6</sub>

### S9 · `mirror`

*wenn* `elysia.hall_mirror_seen`
  - *Der Spiegel zeigt die Halle, das Licht, den Staub in der Luft. Du weißt, wen er nicht zeigt.* `[#draft]`  <sub>sh_mirror_6</sub>
- *Der große Spiegel zeigt die Halle hinter dir. Die Säulen, beide Seiten, das Licht aus dem Nirgendwo.* `[#draft]`  <sub>sh_mirror_1</sub>
- *Du trittst näher. Er zeigt weiter die Halle.* `[#draft]`  <sub>sh_mirror_2</sub>
- *Dich zeigt er nicht.* `[#draft]`  <sub>sh_mirror_3</sub>
- ▸ **Weiter hinsehen.**
  - *Du siehst hin. Es fällt dir nicht schwer. Es fällt dir nur auf.* `[#draft]`  <sub>sh_mirror_4</sub>
  - *Das Becken im Garten hat dich auch nicht gezeigt. Du hast nicht hingesehen.* `[#draft]`  <sub>sh_mirror_5</sub>
- ▸ **Wegsehen.**
  - *Du siehst weg. Der Spiegel wartet. Er hat nichts anderes vor.* `[#draft]`  <sub>sh_mirror_7</sub>
