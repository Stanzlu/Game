# R3 Elysia, wie sie war (Akt VI)

<!-- Erzeugt mit `python3 tools/writing/readable.py`. Nicht von Hand ändern: Änderungen gehören in die .dialogue-Dateien. -->

Lesefassung: der Text in der Reihenfolge, in der das Spiel ihn zeigt. *Kursiv* ist Erzählung, **fett** sprechen die Figuren, ▸ sind deine Antworten. Eingerückt steht, was nur unter einer Bedingung oder nach einer Antwort kommt. Hinter jeder Zeile die ID in klein.

**So antwortest du:** je Szene (E3, T12 …) „OK“, „ändern: …“ oder „raus“. Was du nicht nennst, gilt als OK.


## garten


### R3-1 · `gardener_back`

*wenn* `elysia.back_gift und side_elysia_butterflies und return nicht`
  - *→ weiter bei* `gardener_again`
- **Gärtnerin:** ‹Name›. Ich wusste es. Ich hab dich kommen sehen, bevor du da warst. `[#draft]`  <sub>gar_back_1</sub>
- **Gärtnerin:** Es gibt nichts zu erzählen. Die Schmetterlinge fliegen ihre Runden, und ich sehe ihnen zu. `[#draft]`  <sub>gar_back_2</sub>
- *Sie greift in die Tasche, ohne hinzusehen. Es liegt schon obenauf.* `[#draft]`  <sub>gar_back_3</sub>
- **Gärtnerin:** Hier. Das ist für dich. Ein Kompliment. Ein echtes. Legendär sogar. `[#draft]`  <sub>gar_back_4</sub>
- ▸ **Annehmen.**
  - *→ weiter bei* `gardener_gift`
- ▸ **Lass nur.**
  - *→ weiter bei* `gardener_keep`

### R3-2 · `gardener_gift`

> Annehmen: der Text beschreibt nur die Hand und die Sache. Die Karte, die Fanfare und die Zahl in der Ecke zeigt das Bild, nicht diese Zeilen. Sie freut sich in ihrer Form, ohne Dank im Voraus und ohne zu wissen, wie es um das Geschenk steht.
> Was gesetzt wird, steht nach der letzten Zeile, das Flag zuletzt (wie bei el_gard_ret_3 in Akt I).
> Wer Akt I mit den drei Schmetterlingen im Netz verlassen hat, ohne sie abzugeben (Nebenquest side_elysia_butterflies in der Stufe return), findet die Abgabe nicht mehr: die Karte ersetzt den Cue gardener für alle, die zurück sind. Dasselbe Kompliment ist
> ihr Lohn, also schließt das Annehmen diese Quest wie in Akt I (Stufe done, die Truhe als Hinweis für die Heldenquest, der Brunnen als nächste Aufgabe) und gardener_back bietet es dann auch nach einem früheren Geschenk noch einmal an. Es gibt keine Zeile dafür: die Gärtnerin gibt, was sie gibt.

- *Sie legt es dir mit beiden Händen in die Hand, wie ein Ei. Es ist warm und funkelt wie immer.* `[#draft]`  <sub>gar_gift_1</sub>
- **Gärtnerin:** Golden. Und komplimentig. Es leuchtet so gern. `[#draft]`  <sub>gar_gift_2</sub>
- **Gärtnerin:** Ich hab genau gesehen, wie es leuchtete, als es in deiner Hand lag. `[#draft]`  <sub>gar_gift_3</sub>
*wenn* `side_elysia_butterflies und return`
  *wenn* `elysia.chest_tree_opened nicht`

### R3-3 · `gardener_keep`

> Lass nur: sie nickt und legt es wieder weg. Nichts wird bedauert, nichts gelobt, es gibt keine Frage, ob die Spielerin sicher ist. Kein Flag, kein Gegenstand, nichts in der Ecke des Bildes. Was liegen bleibt, bleibt liegen (O8).

- *Sie nickt, schließt die Hand um das Kompliment und steckt es wieder in die Tasche, vorsichtig, mit zwei Fingern.* `[#draft]`  <sub>gar_keep_1</sub>
- **Gärtnerin:** Es hält. Es läuft nicht weg. `[#draft]`  <sub>gar_keep_2</sub>
- **Gärtnerin:** Es liegt immer genau da, wo ich es hingelegt hab. `[#draft]`  <sub>gar_keep_3</sub>

### R3-4 · `gardener_again`

> --- Die Gärtnerin, danach -----------------------------------------------------------------------------------------------------
> Wer das Geschenk genommen hat, bekommt kein zweites; sie sagt etwas Kleines und lässt die Spielerin sprechen. Drei Antworten mit je zwei Zeilen: das Unbedingte (ein Besuch ohne Anlass), die Antwort für den, der am Brunnen war (der Leser der
> Facette; sie wusste es schon, ohne zu loben, und sagt einen Satz über das Wasser, nicht über die Spielerin) und das Schweigen zuletzt (sie wartet mit). Sie nennt nicht, was am Brunnen geschah, und kein Wort für das, was es war.

- **Gärtnerin:** Die Schmetterlinge sind alle da. Ich seh sie, ohne hinzusehen. `[#draft]`  <sub>gar_again_1</sub>
- **Gärtnerin:** Es ist ein Garten. Immer derselbe Garten. `[#draft]`  <sub>gar_again_2</sub>
- **Gärtnerin:** Und du? Sag nur, was du magst. Ich weiß es sowieso. `[#draft]`  <sub>gar_again_3</sub>
- ▸ **Nur vorbeigekommen.**
  - **Gärtnerin:** Ich wusste es. Ich hab dich vorbeikommen sehen, bevor du losgegangen bist. `[#draft]`  <sub>gar_again_4</sub>
  - **Gärtnerin:** Vorbeikommen ist ein Weg. Er kommt immer bei mir vorbei. `[#draft]`  <sub>gar_again_5</sub>
- ▸ **Ich war am Brunnen. Das Wasser ist nass.** *(wenn `aliveness`)*
  - **Gärtnerin:** Ich wusste es, bevor du es gesagt hast. `[#draft]`  <sub>gar_again_6</sub>
  - **Gärtnerin:** Nass. Und wässerig. Das kann es besonders gut. `[#draft]`  <sub>gar_again_7</sub>
- ▸ **…**
  - *Sie wartet mit dir und sieht den Schmetterlingen zu, bis sie abbiegen.* `[#draft]`  <sub>gar_again_8</sub>
  - **Gärtnerin:** So still. Du schweigst, und der Garten hört zu. `[#draft]`  <sub>gar_again_9</sub>

### R3-5 · `favor_back`

> --- Die Elysianer -------------------------------------------------------------------------------------------------------------
> favor_back: die Elysianer der Begrüßung, im Bau der Zeilen aus favor (Akt I): sie bieten an, bevor gefragt wird, "natürlich", "wir", "alle", kein Nein, kein Zweifel, kein Wetter, keine Zeit. Neue Sätze, derselbe Bau; die Karte spielt in beiden
> Fassungen dieselben Zeilen, es gibt keine Antwort. Sie wissen nicht, dass die Spielerin fort war, und sagen es nicht.
> elysian_back: die Elysianer auf ihren Wegen, die gespiegelten Paare, kürzer. Sie sind gleich geblieben; die erste Zeile ist wortgleich mit der Schleife von Akt I (el_loop_1), das ist der Witz, und die dritte lobt so, dass sie sich
> selbst klein macht, wie el_praise_5.

- **Elysianer:** ‹Name›! Du brauchst nichts zu sagen. Wir wissen es schon. `[#draft]`  <sub>gar_favor_1</sub>
- **Elysianer:** Mein Stuhl ist dein Stuhl. Ich sitze davor, auf dem Gras. Sehr gern sogar. `[#draft]`  <sub>gar_favor_2</sub>
- **Elysianer:** Alle haben etwas für dich bereitgelegt. Du musst nur nehmen. Das kannst du. `[#draft]`  <sub>gar_favor_3</sub>

### R3-6 · `elysian_back`

- **Elysianer:** ‹Name›! Schön, dich zu sehen. Wirklich schön. `[#draft]`  <sub>gar_elys_1</sub>
- **Elysianer:** Alle freuen sich. Der da drüben auch, ganz genauso wie ich. `[#draft]`  <sub>gar_elys_2</sub>
- **Elysianer:** Du stehst so schön da. Wir anderen machen es nur nach. `[#draft]`  <sub>gar_elys_3</sub>

### R3-7 · `basin_back`

> --- Das Becken ----------------------------------------------------------------------------------------------------------------
> Die Gärtnerin hat nichts mehr zu bitten; niemand sagt der Spielerin, was sie am Wasser tun soll. Die Erzählung zeigt das Becken, das Wasser und die Hand: der Rand ist gerade so hoch, dass die Hand von allein hineinfindet. Zwei
> unbedingte Antworten, jede mit eigenen Zeilen (keine Fake Choice, kein Schweigen nötig): Wasser spritzen (basin_play) oder Zusehen (zwei Zeilen: dasselbe Wasser, dasselbe Blütenblatt). Weder Gesten noch Orte werden bewertet.

- *Das Becken plätschert, und niemand fragt dich, ob es zu leise ist.* `[#draft]`  <sub>gar_basin_1</sub>
- *Das Wasser steht klar bis knapp unter den Rand, und ein Blütenblatt dreht darauf seine Runde.* `[#draft]`  <sub>gar_basin_2</sub>
- *Der Rand ist breit und glatt und gerade so hoch, dass die Hand von allein ins Wasser findet.* `[#draft]`  <sub>gar_basin_3</sub>
- ▸ **Wasser spritzen.**
  - *→ weiter bei* `basin_play`
- ▸ **Zusehen.**
  - *Das Wasser plätschert und plätschert, und es ist dasselbe Wasser.* `[#draft]`  <sub>gar_basin_4</sub>
  - *Das Blütenblatt kommt an, wo es losgefahren ist, und fährt los.* `[#draft]`  <sub>gar_basin_5</sub>

### R3-8 · `basin_play`

> Das Erste in Elysia, das nichts gibt (Bible §16, O7): die Hand im Wasser, ein Schwall, Tropfen im Licht, ein Platschen, das keiner bemerkt. In der Ecke ändert sich nichts, und der Text sagt es als Ding, nicht als Satz über Lohn
> oder Zweck. Die letzte Zeile ist leicht und nicht feierlich. Keine Zeile nennt, was es ist. Gesetzt wird nur die Facette, nach der letzten Zeile (kein XP, kein Gold, kein Gegenstand, kein Flag): die Gärtnerin liest sie in
> gardener_again, und der Cue, der sie setzt, liest sie nie.

- *Du tauchst die Hand ein und schlägst flach auf das Wasser.* `[#draft]`  <sub>gar_play_1</sub>
- *Ein Schwall springt auf, die Tropfen hängen einen Atemzug lang im Licht, und das Platschen bemerkt niemand.* `[#draft]`  <sub>gar_play_2</sub>
- *Die Zahl in der Ecke bleibt, wo sie ist, und der Balken daneben auch.* `[#draft]`  <sub>gar_play_3</sub>
- *Das Wasser gibt keine Antwort, es läuft dir nur den Ärmel hinunter.* `[#draft]`  <sub>gar_play_4</sub>
