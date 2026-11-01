# Lesefassung des Slice

<!-- Erzeugt mit `python3 tools/writing/readable.py`. Nicht von Hand ändern: Änderungen gehören in die .dialogue-Dateien. -->

Lesefassung: der Text in der Reihenfolge, in der das Spiel ihn zeigt. *Kursiv* ist Erzählung, **fett** sprechen die Figuren, ▸ sind deine Antworten. Eingerückt steht, was nur unter einer Bedingung oder nach einer Antwort kommt. Hinter jeder Zeile die ID in klein.

**So antwortest du:** je Szene (E3, T12 …) „OK“, „ändern: …“ oder „raus“. Was du nicht nennst, gilt als OK.


## elysia


### E1 · `wake`

- *Licht. Warm, von überall. Du hast die Augen gerade erst aufgemacht, und schon ist jemand da.*  <sub>el_wake_0</sub>
- **Elysianer:** Da bist du ja, ‹Name›!  <sub>el_wake_1</sub>
- **Elysianer:** Alle freuen sich so, dass du wach bist. Der ganze Garten hat auf dich gewartet.  <sub>el_wake_2</sub>
- ▸ **Wo bin ich?**
  - **Elysianer:** In Elysia natürlich! Dem schönsten Ort der Welt.  <sub>el_wake_3</sub>
- ▸ **Hallo.**
  - **Elysianer:** Hallo! Was für ein Hallo. So warm. So entschlossen.  <sub>el_wake_5</sub>
- ▸ **…**
  - **Elysianer:** Ganz der Held. Wortkarg und geheimnisvoll. Wir lieben das.  <sub>el_wake_6</sub>
*wenn* `item_seed`
  - **Elysianer:** Und einen Samen hast du dabei! Aus unserem Garten, natürlich. Du denkst an alles. `[#draft]`  <sub>el_wake_seed</sub>
- **Elysianer:** Die Gärtnerin sucht dich, drüben bei den Blumen. Sie hat ein Problem, und ich glaube, du kannst ihr helfen. Du kannst das.  <sub>el_wake_7</sub>
- **Elysianer:** Und wenn's eilig ist, hilft ‹Taste: sprint›. Helden rennen.  <sub>el_wake_8</sub>

### E2 · `elysian`

*wenn* `elysia.loops und elysia.rift_open`
  - **Elysianer:** Ganz unten rechts, am Rand, da flimmert seit vorhin was. Nichts Wichtiges. Bleib lieber hier bei uns.  <sub>el_loop_2</sub>
*sonst wenn* `elysia.loops`
  - **Elysianer:** ‹Name›! Schön, dich zu sehen. Wirklich schön.  <sub>el_loop_1</sub>
*sonst*
  - **Elysianer:** ‹Name›! Schön, dich zu sehen. Wirklich schön.  <sub>el_praise_1</sub>
  - **Elysianer:** Hast du schon gehört? Du bist toll. Das sagen alle. Ich auch.  <sub>el_praise_2</sub>
  - **Elysianer:** Wie du da stehst. Wie ein Denkmal. Eins, das man gern besucht.  <sub>el_praise_3</sub>
  - **Elysianer:** Ich hab vorhin gesehen, wie du um die Ecke gegangen bist. Sehr elegant.  <sub>el_praise_4</sub>
  - **Elysianer:** Ein Held! Hier! Bei uns! Und ich steh einfach so daneben.  <sub>el_praise_5</sub>
  - **Elysianer:** Der Brunnen! Du hast ihn gerichtet, ohne hinzugehen! Das kannst nur du. *(wenn `side_elysia_fountain`)*  <sub>el_praise_6</sub>

### E3 · `gardener`

*wenn* `side_elysia_butterflies`
  - **Gärtnerin:** ‹Name›! Meine drei goldenen Schmetterlinge sind ent…  <sub>el_gard_done_1</sub>
  - **Gärtnerin:** Ach nein. Du hast sie ja gefangen. Natürlich hast du das. Du fängst immer alles.  <sub>el_gard_done_2</sub>
*sonst wenn* `side_elysia_butterflies und return`
  - **Gärtnerin:** Alle drei! Und so schnell!  <sub>el_gard_ret_1</sub>
  - **Gärtnerin:** Hörst du, wie zufrieden sie flattern? Sie fliegen wieder ihre Runden. Genau dieselben wie vorher.  <sub>el_gard_ret_2</sub>
  - **Gärtnerin:** Hier. Das ist für dich. Ein Kompliment. Ein echtes. Legendär sogar.  <sub>el_gard_ret_3</sub>
  *wenn* `elysia.chest_tree_opened`
    - **Gärtnerin:** Die Truhe am Weltenbaum hast du ja schon geöffnet. Natürlich hast du das. Sie war für dich.  <sub>el_gard_ret_5</sub>
  *sonst*
    - **Gärtnerin:** Und am Weltenbaum wartet eine Truhe. Nur auf dich. Sie wartet schon ganz lange.  <sub>el_gard_ret_4</sub>
  - **Gärtnerin:** Ach, und der Brunnen am Becken. Er plätschert ein kleines bisschen zu leise. Schaust du nach?  <sub>el_gard_ret_6</sub>
*sonst wenn* `side_elysia_butterflies`
  *wenn* `elysia.loops`
    - **Gärtnerin:** Hast du sie schon? Nein? Macht nichts. Du schaffst das. Du schaffst alles. `[#draft]`  <sub>el_gard_loop</sub>
  *sonst*
    - **Gärtnerin:** Hast du sie schon? Nein? Macht nichts. Du schaffst das. Du schaffst alles.  <sub>el_gard_wait_1</sub>
    - **Gärtnerin:** Sie fliegen über dem Garten. Immer im Kreis. Immer im selben.  <sub>el_gard_wait_2</sub>
*sonst*
  - **Gärtnerin:** ‹Name›! Dem Himmel sei Dank. Oder dir. Eher dir.  <sub>el_gard_1</sub>
  - **Gärtnerin:** Meine drei goldenen Schmetterlinge sind entwischt. Sie fliegen immer dieselben Runden, weißt du. Nur jetzt eben woanders.  <sub>el_gard_2</sub>
  - ▸ **Ich fang sie dir ein.**
    - **Gärtnerin:** Ich wusste es! Ich wusste es, bevor du es gesagt hast.  <sub>el_gard_3</sub>
  - ▸ **Wie sehen sie aus?**
    - **Gärtnerin:** Golden. Und schmetterlingig. Du wirst sie erkennen. Du erkennst alles.  <sub>el_gard_4</sub>
  - ▸ **…**
    - **Gärtnerin:** Du nickst! Ich hab genau gesehen, wie du innerlich genickt hast.  <sub>el_gard_5</sub>
  *wenn* `main_elysia_hero und greet`

### E4 · `host`

*wenn* `elysia.soup_served und elysia.loops`
  - **Gastwirt:** Da ist er ja! Komm, komm. Setz dich. Hier ist Suppe.  <sub>el_host_loop_1</sub>
  - **Gastwirt:** Die beste Suppe von Elysia. Ich mach sie jeden Tag. Jeden Tag dieselbe. Perfektion ändert man nicht.  <sub>el_host_loop_2</sub>
  - **Gastwirt:** Du musst heute nirgends mehr hin.  <sub>el_host_loop_3</sub>
*sonst wenn* `elysia.soup_served`
  - **Gastwirt:** Noch eine Suppe? Es ist dieselbe. Das ist ja das Schöne daran.  <sub>el_host_again_1</sub>
  - **Gastwirt:** Setz dich doch. Bleib ein bisschen. Bleib länger.  <sub>el_host_again_2</sub>
  - **Gastwirt:** Hier spielt gleich Musik. Hier spielt immer gleich Musik.  <sub>el_host_again_3</sub>
*sonst*
  - **Gastwirt:** Da ist er ja! Komm, komm. Setz dich. Hier ist Suppe.  <sub>el_host_1</sub>
  - **Gastwirt:** Die beste Suppe von Elysia. Ich mach sie jeden Tag. Jeden Tag dieselbe. Perfektion ändert man nicht.  <sub>el_host_2</sub>
  - ▸ **Danke, gern.**
    - **Gastwirt:** Na? Na? Wie schmeckt sie?  <sub>el_host_3</sub>
    - ▸ **Fantastisch.**
      - **Gastwirt:** Sag ich doch! Hier, nimm noch eine mit. Für unterwegs. Nicht, dass du unterwegs sein musst.  <sub>el_host_4</sub>
    - ▸ **Nach … nichts?**
      - **Gastwirt:** Nach nichts! Ha! Der war gut. Nach nichts.  <sub>el_host_5</sub>
      - **Gastwirt:** Nimm noch eine mit. Die zweite schmeckt nach mehr.  <sub>el_host_6</sub>
    - ▸ **…**
      - **Gastwirt:** Sprachlos. Das sind alle. Hier, die nächste ist für unterwegs.  <sub>el_host_7</sub>
  - ▸ **Ich hab keinen Hunger.**
    - **Gastwirt:** Hunger? Wer redet denn von Hunger? Hier geht es ums Genießen.  <sub>el_host_8</sub>
    - **Gastwirt:** Ich geb dir eine mit. Für später. Später ist hier immer.  <sub>el_host_9</sub>
  - ▸ **Ich muss weiter.**
    - **Gastwirt:** Musst du? Wirklich?  <sub>el_host_10</sub>
    - **Gastwirt:** Du musst heute nirgends mehr hin. Glaub mir. Hier ist alles, was du brauchst. Und eine Suppe.  <sub>el_host_11</sub>

### E5 · `basin`

*wenn* `elysia.mirror_seen nicht`
  - *Das Wasser im Becken ist klar und vollkommen still.*  <sub>el_basin_1</sub>
  - *Es zeigt den Himmel. Die Säulen. Den Baum. Eine Wolke, die vorhin schon einmal vorbeigezogen ist.*  <sub>el_basin_2</sub>
  - *Du beugst dich weiter vor.*  <sub>el_basin_3</sub>
  - *Der Himmel. Die Säulen. Der Baum.*  <sub>el_basin_4</sub>
*sonst wenn* `side_elysia_fountain und elysia.fountain_seen nicht`
  - *Das Becken plätschert. Genau richtig laut. Es hat, wenn man ehrlich ist, nie anders geplätschert.*  <sub>el_basin_5</sub>
*sonst*
  - *Das Wasser ist still wie Glas. Es zeigt alles.*  <sub>el_basin_again</sub>

### E6 · `flower`

*wenn* `elysia.flower_smelled`
  - *Die Blüte leuchtet von innen. Du riechst daran. Nichts. Ein sehr schönes Nichts.*  <sub>el_flower_2</sub>
  - *Du riechst noch einmal daran. Wieder nichts. Aber Elysia ist stolz auf dich.*  <sub>el_flower_3</sub>
*sonst*
  - *Eine Blume, so schön, dass es fast wehtut. Du riechst daran. Sie riecht nach nichts.*  <sub>el_flower_1</sub>

### E7 · `feast`

> The feast tables (cue only, both twins): everything shines, nothing has been eaten.

- *Eine Tafel voller Speisen. Alles glänzt. Nichts ist angebissen.*  <sub>el_feast_1</sub>

### E8 · `favor`

- **Elysianer:** ‹Name›! Kann ich irgendwas für dich tun? Irgendwas?  <sub>el_favor_1</sub>
- ▸ **Kann ich heute Nacht bei dir schlafen?**
  - **Elysianer:** Natürlich! Mein Bett ist dein Bett. Ich schlafe davor, auf dem Boden. Sehr gern sogar.  <sub>el_favor_2</sub>
- ▸ **Schenk mir dein Haus.**
  - **Elysianer:** Es gehört dir! Eigentlich gehört es dir schon immer. Ich wohne nur zur Probe darin.  <sub>el_favor_3</sub>
- ▸ **Sag einmal Nein.**
  - **Elysianer:** N…  <sub>el_favor_4</sub>
  - **Elysianer:** Ja! Ich meine, ja. Natürlich. Alles, was du willst.  <sub>el_favor_5</sub>
- ▸ **Nichts, danke.**
  - **Elysianer:** Nichts! So bescheiden. Wir bewundern das. Wir bewundern alles an dir.  <sub>el_favor_6</sub>

### E9 · `child`

*wenn* `elysia.child_met`
  - **Kind:** Hörst du das?  <sub>el_child_3</sub>
  - *Es ist die Melodie, der du gefolgt bist. Du kannst sie jetzt.* `[#draft]`  <sub>el_child_4</sub>
*sonst*
  - *Das Kind schaut ins Wasser. Aus dem Wasser schaut ein Kind zurück.*  <sub>el_child_1</sub>
  - **Kind:** …  <sub>el_child_2</sub>

### E10 · `stone`

> Things to look at (Game Bible §57: Elysia must be attractive first). Spoken in Elysia's own
> voice; the tree and the water repeat the way everything here does once the loops begin.

- *Ein Stein. Grau. Das Einzige hier, das nicht glänzt.*  <sub>el_stone_1</sub>

### E11 · `sacred_tree`

*wenn* `elysia.loops`
  - *Der Weltenbaum. Dieselbe Blüte wie vorhin. Dieselbe wie immer.*  <sub>el_tree_2</sub>
*sonst*
  - *Der Weltenbaum. Nicht ein Blatt liegt darunter. Er blüht, seit es ihn gibt.*  <sub>el_tree_1</sub>

### E12 · `pillar`

- *Eine Säule, makellos. Drüben steht genau dieselbe.*  <sub>el_pillar_1</sub>

### E13 · `crystal`

- *Ein Kristall. Er leuchtet, wenn du näher kommst. Für dich.*  <sub>el_crystal_1</sub>
*wenn* `elysia.crystal_touched nicht`

### E14 · `splash`

- *Das Wasser fällt und fällt. Unten wird es nicht mehr.*  <sub>el_splash_1</sub>

## tal


### T1 · `mira`

*wenn* `side_valley_goat`
  - *→ weiter bei* `mira_end_again`
*sonst wenn* `house.mira_visited`
  - *→ weiter bei* `mira_evening`
*sonst wenn* `valley.mira_met`
  - *→ weiter bei* `mira_again`
- *→ weiter bei* `mira_first`

### T2 · `mira_first`

- *Die Frau hat ein Stück Netz in den Händen und knotet eine Masche. Sie schaut nicht auf.*  <sub>tal_mira_1</sub>
- ▸ **Hallo.**
  - **Die Frau:** Hallo.  <sub>tal_mira_2</sub>
  - **Die Frau:** Du stehst im Regen. Nur falls dir das keiner gesagt hat.  <sub>tal_mira_3</sub>
- ▸ **Wo bin ich hier?**
  - **Die Frau:** Am Bach. Im Tal. Im Regen. Such dir was aus.  <sub>tal_mira_4</sub>
- ▸ **Ich bin der Held von Elysia.**
  - **Die Frau:** Aha.  <sub>tal_mira_22</sub>
  - **Die Frau:** Ich bin die, die hier ein Netz flickt. Jetzt kennen wir uns.  <sub>tal_mira_23</sub>
- ▸ **…**
  - **Die Frau:** …  <sub>tal_mira_5</sub>
  - **Die Frau:** Gut. Dann sind wir uns einig.  <sub>tal_mira_6</sub>
- **Die Frau:** Brauchst du was?  <sub>tal_mira_21</sub>
- ▸ **Kann ich bei dir unterkommen? Nur bis der Regen aufhört.**
  - **Die Frau:** Nein.  <sub>tal_mira_7</sub>
  - **Die Frau:** Ich kenn dich nicht. Und unter die Plane passt genau eine.  <sub>tal_mira_8</sub>
- ▸ **Weißt du, wo ich heute Nacht schlafen kann?**
  - **Die Frau:** Nicht hier.  <sub>tal_mira_9</sub>
  - **Die Frau:** Das ist kein Gasthaus. Das ist mein Lager.  <sub>tal_mira_10</sub>
- ▸ **Mir ist kalt.**
  - **Die Frau:** Mir auch. Deswegen hab ich ein Feuer.  <sub>tal_mira_11</sub>
  - **Die Frau:** Meins. Nein, du kannst dich nicht dazusetzen.  <sub>tal_mira_12</sub>
*wenn* `elysia.asked_for_no`
  - *Das Wort bleibt im Regen hängen.*  <sub>tal_mira_no_1</sub>
*sonst wenn* `elysia.offered_bed`
  - *Für einen Moment denkst du an ein Bett, vor dem jemand auf dem Boden schlafen wollte.*  <sub>tal_mira_no_2</sub>
- *Die Frau zieht den Knoten fest und nickt über den Bach.*  <sub>tal_mira_13</sub>
- **Die Frau:** Da drüben steht ein Haus. Leer, seit dem Frühjahr. Die Leute sind weg.  <sub>tal_mira_14</sub>
- **Die Frau:** Die Brücke ist auch weg, jedenfalls die Mitte. Über die Steine kommst du rüber. Oder oben über den Baum, der liegt seit dem Sturm.  <sub>tal_mira_15</sub>
- ▸ **Ich nehm die Steine.**
  - **Die Frau:** Nicht die runden. Die sehen fest aus und sind es nicht.  <sub>tal_mira_16</sub>
- ▸ **Ich geh oben über den Baum.**
  - **Die Frau:** Dauert länger. Dafür kommst du trocken an. Halbwegs.  <sub>tal_mira_17</sub>
- ▸ **Ich warte lieber, bis der Regen aufhört.**
  - **Die Frau:** Dann wartest du bis Donnerstag.  <sub>tal_mira_18</sub>
  - **Die Frau:** Geh. Das Haus läuft nicht weg. Der Regen auch nicht.  <sub>tal_mira_19</sub>
- **Mira:** Mira, übrigens. Falls du noch mal rüberrufen musst.  <sub>tal_mira_24</sub>
- *Mira wendet sich wieder ihrem Netz zu.*  <sub>tal_mira_20</sub>

### T3 · `mira_again`

*wenn* `valley.fell_in und valley.crossed nicht`
  *wenn* `mira und stones_warned`
    - **Mira:** Die runden, hab ich gesagt.  <sub>tal_mira_again_1</sub>
  *sonst*
    - **Mira:** Ja. Die runden kippen. Hätte ich vielleicht sagen sollen.  <sub>tal_mira_again_2</sub>
  - **Mira:** Die flachen mit dem Moos drauf. Da ist schon mal jemand drübergegangen.  <sub>tal_mira_again_3</sub>
*sonst wenn* `main_valley_shelter und wood`
  - **Mira:** Trockenes Holz? Im alten Schuppen. Am Ende vom Weg nach Westen.  <sub>tal_mira_again_4</sub>
  - **Mira:** Der Weg ist länger, als er aussieht. Sagt man.  <sub>tal_mira_again_5</sub>
*sonst wenn* `main_valley_shelter und fire`
  - **Mira:** Trockenes Holz. Hm. Dann mach Feuer, bevor es wieder nass ist.  <sub>tal_mira_again_9</sub>
*sonst*
  - **Mira:** Ich hab heute schon einen Stiefel verloren. Lass mich wenigstens in Ruhe flicken.  <sub>tal_mira_again_6</sub>
  - **Mira:** Ich flick das Netz. Du kannst zusehen. Schneller wird es dadurch nicht.  <sub>tal_mira_again_7</sub>
  - **Mira:** Die Steine oder der Baum. Ich sag's nicht noch mal. *(wenn `valley.crossed nicht`)*  <sub>tal_mira_again_8</sub>

### T4 · `mira_evening`

*wenn* `item_boot`
  - **Mira:** Mein Stiefel.  <sub>tal_mira_eve_1</sub>
  - *Mira dreht ihn in der Hand. Ein Rand ist angeknabbert.*  <sub>tal_mira_eve_2</sub>
  - ▸ **Die Ziege wollte eine Kartoffel dafür.**
    - **Mira:** Natürlich wollte sie das. Sie ist eine Ziege, keine Heilige.  <sub>tal_mira_eve_3</sub>
  - ▸ **Gern geschehen.**
    - **Mira:** Ich hab noch gar nicht danke gesagt.  <sub>tal_mira_eve_4</sub>
    - **Mira:** … Danke.  <sub>tal_mira_eve_5</sub>
  - ▸ **…**
    - **Mira:** Ja. Genau so ein Tag war das.  <sub>tal_mira_eve_6</sub>
  - **Mira:** Die Ziege steht übrigens auf dem Holzstapel am Haus. Ich frag nicht, wie.  <sub>tal_mira_eve_9b</sub>
  - *Mira zieht den Stiefel an, ohne aufzustehen. Nach einer Weile rückt sie ein Stück zur Seite.*  <sub>tal_mira_eve_7</sub>
*sonst wenn* `side_valley_goat und trade`
  - **Mira:** Die Ziege will was dafür? Dann gib ihr was. So funktioniert das mit Ziegen.  <sub>tal_mira_eve_8</sub>
*sonst*
  - **Mira:** Ein Stiefel. Mit einem kommt man nicht weit. Die Ziege treibt sich drüben beim Haus rum.  <sub>tal_mira_eve_9</sub>
  - **Mira:** Einen Stiefel hab ich noch. Den anderen hat die Ziege. Das ist der Stand.  <sub>tal_mira_eve_10</sub>

### T5 · `ending`

- *Das Feuer knackt. Der Regen hat aufgehört. Irgendwo tropft es noch von den Bäumen.*  <sub>tal_end_1</sub>
- *→ dazwischen* `evening_first`
- *→ dazwischen* `evening_day`
- *Ein Scheit bricht in der Glut zusammen. Funken steigen auf und gehen aus.*  <sub>tal_end_11</sub>
- *→ dazwischen* `evening_elysia`
*wenn* `valley.shell_seen`
  - *→ dazwischen* `evening_shell`
*wenn* `mira und said_name`
  - **Mira:** ‹Name›.  <sub>tal_end_12</sub>
- **Mira:** Morgen gehe ich weiter.  <sub>tal_end_2</sub>
- ▸ **Wohin?**
  - *Mira schaut zu den Bergen. Lange.*  <sub>tal_end_4</sub>
- ▸ **Zum Meer?** *(wenn `mira und asked_shell`)*
  - *Mira schaut dich an. Dann zu den Bergen.*  <sub>tal_end_7</sub>
- ▸ **…**
  - **Mira:** Du willst wissen, wohin. Das seh ich dir an.  <sub>tal_end_3</sub>
  - *Mira schaut zu den Bergen. Lange.*  <sub>tal_end_9</sub>

### T6 · `ending_sea`

> Her answer comes after the long look at the mountains (the scene calls this cue once the
> camera has arrived there): the words only mean something with the mountains in view.

*wenn* `mira und guessed_sea`
  - **Mira:** … Ja. Zum Meer.  <sub>tal_end_8</sub>
*sonst wenn* `mira und end_silence`
  - **Mira:** Zum Meer.  <sub>tal_end_10</sub>
*sonst*
  - **Mira:** Zum Meer.  <sub>tal_end_5</sub>

### T7 · `evening_first`

> The evening at Mira's fire (ADR-042): she remembers how the day went, from what the
> player said and did. Like the first no, it is never a reward: she talks because the fire
> burns a while longer.

*wenn* `mira und said_hero`
  - **Mira:** Der Held von Elysia an meinem Feuer. Ich hätt's mir größer vorgestellt.  <sub>tal_eve_hero</sub>
*sonst wenn* `mira und first_silence`
  - **Mira:** Du redest immer noch nicht viel. Ist mir recht. Das Feuer redet genug.  <sub>tal_eve_quiet</sub>
*wenn* `mira und asked_shelter`
  - **Mira:** Unter die Plane passt immer noch nur eine.  <sub>tal_eve_tarp_1</sub>
  - **Mira:** Ans Feuer passen zwei.  <sub>tal_eve_tarp_2</sub>
*sonst wenn* `mira und asked_sleep`
  - **Mira:** Heute Mittag wusstest du nicht, wo du schlafen kannst. Jetzt hast du ein Haus.  <sub>tal_eve_sleep_1</sub>
  - **Mira:** Ich hab eine Plane. So kann's gehen.  <sub>tal_eve_sleep_2</sub>
*sonst wenn* `mira und said_cold`
  - **Mira:** Mein Feuer, übrigens.  <sub>tal_eve_cold_1</sub>
  - **Mira:** Du darfst trotzdem sitzen bleiben.  <sub>tal_eve_cold_2</sub>
*wenn* `mira und wanted_to_wait`
  - **Mira:** Der Regen hat aufgehört. Ist aber nicht Donnerstag. Du warst schneller.  <sub>tal_eve_wait_1</sub>
*sonst wenn* `mira und chose_tree`
  - **Mira:** Oben über den Baum, und trotzdem nass. Halbwegs hab ich gesagt.  <sub>tal_eve_tree_1</sub>

### T8 · `evening_day`

- **Mira:** Erzähl was. Irgendwas. Das Feuer brennt noch eine Weile.  <sub>tal_eve_day_1</sub>
- ▸ **Die erste Brombeere war sauer.** *(wenn `valley.berries_eaten`)*
  - **Mira:** Die erste ist immer sauer. Deswegen isst man die zweite.  <sub>tal_eve_day_2</sub>
- ▸ **Die Blumen am Weg riechen nach Honig.** *(wenn `valley.flower_smelled und valley.berries_eaten nicht`)*
  - **Mira:** Bei Regen mehr. Keiner weiß, warum.  <sub>tal_eve_day_3</sub>
- ▸ **Der Weg zum Schuppen wollte nicht aufhören.** *(wenn `valley.wood_taken`)*
  - **Mira:** Manche Wege sind so.  <sub>tal_eve_day_4</sub>
  - **Mira:** Den lauf ich nicht mehr.  <sub>tal_eve_day_5</sub>
- ▸ **‹Katzenname› wohnt jetzt bei mir.** *(wenn `cat_name() != ""`)*
  - **Mira:** ‹Katzenname›. Hm.  <sub>tal_eve_day_6</sub>
  - **Mira:** Die hat da schon gewohnt, bevor du kamst. Sie hat sich nur nicht vorgestellt.  <sub>tal_eve_day_7</sub>
- ▸ **Eine Katze wohnt jetzt bei mir.** *(wenn `house.cat_fed`)*
  - **Mira:** Wie heißt sie?  <sub>tal_eve_day_8</sub>
  - *Du weißt es nicht. Sie hat es dir nicht gesagt.*  <sub>tal_eve_day_9</sub>
- ▸ **…**
  - *Mira schweigt eine Weile mit. Dann erzählt sie selbst.*  <sub>tal_eve_day_10</sub>
  - **Mira:** Ich hab heute zwei Löcher im Netz geflickt. Und ein neues gefunden.  <sub>tal_eve_day_11</sub>
  - **Mira:** Das ist ungefähr jeder Tag.  <sub>tal_eve_day_12</sub>

### T9 · `evening_elysia`

*wenn* `mira und said_elsewhere`
  - **Mira:** Dieses Woanders. Wie war's da?  <sub>tal_eve_ely_10</sub>
*sonst wenn* `mira und said_dont_know`
  - **Mira:** Du weißt nicht mehr, wo du herkommst. Weißt du noch, wie es da war?  <sub>tal_eve_ely_11</sub>
*sonst wenn* `mira und said_elysia oder mira und said_hero`
  - **Mira:** Dieses Elysia. Wie war's da?  <sub>tal_eve_ely_1</sub>
*sonst*
  - **Mira:** Und wo warst du, bevor du hier im Regen standest?  <sub>tal_eve_ely_2</sub>
- ▸ **Schön. Alles war leicht.**
  - **Mira:** Und trotzdem sitzt du jetzt hier. Im Nassen.  <sub>tal_eve_ely_3</sub>
  - *Sie fragt nicht, warum.*  <sub>tal_eve_ely_4</sub>
- ▸ **Manchmal fehlt es mir.**
  - **Mira:** Klar.  <sub>tal_eve_ely_5</sub>
  - **Mira:** Hier regnet's ja auch dauernd.  <sub>tal_eve_ely_6</sub>
- ▸ **Darüber will ich nicht reden.**
  - **Mira:** Gut.  <sub>tal_eve_ely_7</sub>
  - *Sie fragt nicht noch mal.*  <sub>tal_eve_ely_8</sub>
- ▸ **…**
  - **Mira:** Auch eine Antwort.  <sub>tal_eve_ely_9</sub>

### T10 · `evening_shell`

- *An der Plane bewegt sich die Muschel an ihrer Schnur.*  <sub>tal_eve_shell_1</sub>
- ▸ **Woher hast du die Muschel?**
  - **Mira:** Vom Meer.  <sub>tal_eve_shell_2</sub>
  - **Mira:** Ich war noch nie da.  <sub>tal_eve_shell_3</sub>
- ▸ **…**
  - *Du lässt die Muschel Muschel sein. Mira auch.*  <sub>tal_eve_shell_4</sub>

### T11 · `mira_end_again`

- *Mira schaut ins Feuer. Sie hat dir einen Platz gelassen.*  <sub>tal_mira_end_1</sub>

### T12 · `net`

*wenn* `house.mira_visited`
  - *Das Netz hängt wieder auf dem Gestell. Das eine Loch ist zu. Ein neues ist schon da.*  <sub>tal_net_2</sub>
*sonst*
  - *Miras Netz hängt über dem Gestell. Trocken wird es heute nicht mehr. Ein Loch ist frisch geflickt, ein anderes wartet noch.*  <sub>tal_net_1</sub>

### T13 · `shell`

- *An der Plane hängt eine Muschel an einer Schnur. Weiß, mit einem feinen Riss.*  <sub>tal_shell_1</sub>
- *Hier, mitten im Tal, weit weg von jedem Meer.*  <sub>tal_shell_2</sub>

### T14 · `boot_print`

*wenn* `side_valley_goat`
  - *Der Stein ist leer. Der Stiefel ist wieder da, wo er hingehört.*  <sub>tal_boot_3</sub>
*sonst wenn* `house.mira_visited`
  - *Hier hat der Stiefel zum Trocknen gestanden. Bis die Ziege andere Pläne hatte.*  <sub>tal_boot_2</sub>
*sonst*
  - *Ein flacher Stein am Feuer, noch warm. Darauf der nasse Abdruck einer Stiefelsohle. Der Stiefel dazu ist nirgends.*  <sub>tal_boot_1</sub>

### T15 · `wildflower`

*wenn* `valley.flower_smelled`
  - *Du riechst noch einmal. Es ist immer noch da.*  <sub>tal_flower_3</sub>
  - *Regen, Erde, Honig. In dieser Reihenfolge.*  <sub>tal_flower_4</sub>
*sonst*
  - *Wilde Blumen am Wegrand, vom Regen niedergedrückt. Auf der größten sitzt eine Schnecke und hat keine Eile.*  <sub>tal_flower_1</sub>
  - *Du riechst daran. Regen. Erde. Ganz schwach Honig.*  <sub>tal_flower_2</sub>
  *wenn* `elysia.flower_smelled`
    - *Du riechst noch einmal, um sicherzugehen. Es riecht immer noch.*  <sub>tal_flower_5</sub>

### T16 · `berries`

*wenn* `valley.berries_eaten`
  - *Du nimmst noch eine. Sauer. Du nimmst trotzdem noch eine.*  <sub>tal_berry_4</sub>
  - *Die guten hängen zu weit drin, zwischen den Dornen. Natürlich.*  <sub>tal_berry_5</sub>
*sonst*
  - *Ein Brombeerstrauch, nass vom Regen.*  <sub>tal_berry_1</sub>
  - *Die erste Beere ist sauer. Die zweite ist süß. Die dritte ist wieder sauer, aber anders.*  <sub>tal_berry_2</sub>
  *wenn* `elysia.soup_tasteless`
    - *Du merkst, dass du langsam kaust. Damit es länger dauert.*  <sub>tal_berry_6</sub>
  - *Ein Dorn hat dich am Handrücken erwischt. Ein kleiner roter Strich.*  <sub>tal_berry_3</sub>

### T17 · `crooked_tree`

- *Ein Baum, der schief gewachsen ist. Irgendwann hat er sich nach dem Licht gestreckt und ist dabei geblieben.*  <sub>tal_tree_1</sub>

### T18 · `stones`

> The stepping stones seen from the east bank: the rule is in the moss, for everyone who looks.

- *Steine im Bach. Auf den flachen wächst Moos, die runden glänzen nass.*  <sub>tal_stones_1</sub>
- *Auf den runden hält sich nichts. Nicht mal Moos.*  <sub>tal_stones_2</sub>

### T19 · `rift_gone`

- *Wo eben noch der Riss war, hängt nur Regen in der Luft.*  <sub>tal_rift_gone_1</sub>
- *Du streckst die Hand aus. Nass. Sonst nichts.*  <sub>tal_rift_gone_2</sub>

### T20 · `south_sign`

> At the end of the faint track south; it sets up Mira's last words.

- *Ein Wegweiser. Die Schrift ist abgeblättert, bis auf ein Wort.*  <sub>tal_south_sign_1</sub>
- *»Zum«*  <sub>tal_south_sign_2</sub>

### T21 · `garden_bed`

- *Ein Gemüsebeet, seit dem Frühjahr verwildert. Unter dem Unkraut wächst trotzdem noch was.*  <sub>tal_bed_1</sub>

### T22 · `rain_barrel`

- *Eine Regentonne, randvoll. Wenigstens einer hier freut sich über das Wetter.*  <sub>tal_barrel_1</sub>

### T23 · `fence_gap`

*wenn* `valley.goat_loose`
  - *Die Lücke im Zaun. Gerade breit genug für etwas Entschlossenes mit Hörnern.*  <sub>tal_fence_2</sub>
*sonst*
  - *Ein Zaun mit einer Lücke. Wer hier durchwollte, wollte es sehr.*  <sub>tal_fence_1</sub>

### T24 · `woodpile`

*wenn* `item_dry_wood`
  - *Das Holz hier ist immer noch nass. Deins nicht.*  <sub>tal_wood_3</sub>
*sonst*
  - *Holz, unter dem Vordach gestapelt. Durchnässt bis in den Kern.*  <sub>tal_wood_1</sub>
  - *Damit brennt kein Feuer. Nur Rauch.*  <sub>tal_wood_2</sub>

### T25 · `bridge`

*wenn* `valley.bridge_fixed`
  - *Über der Lücke liegt ein neues Brett, mit Draht festgebunden. Es hält.*  <sub>tal_bridge_3</sub>
*sonst*
  - *Die Brücke ist in der Mitte gebrochen. Was fehlt, liegt irgendwo weiter unten im Bach.*  <sub>tal_bridge_1</sub>
  - *Zu weit zum Springen. Zu kalt zum Schwimmen.*  <sub>tal_bridge_2</sub>

### T26 · `west_path`

- *Der Pfad verschwindet zwischen den Bäumen nach Westen.*  <sub>tal_west_1</sub>
- *Erst mal ein Dach über dem Kopf.*  <sub>tal_west_2</sub>

### T27 · `stream_wait`

- *Der Bach ist schnell und kalt. Ein Stück weiter am Ufer brennt ein kleines Feuer. Eine Frau arbeitet dort.*  <sub>tal_stream_1</sub>
- *Vielleicht weiß sie, wie man hier rüberkommt.*  <sub>tal_stream_2</sub>

### T28 · `west_path_done`

- *Der Weg zum Schuppen. Das Holz hast du schon. Der Weg wird dich nicht vermissen.*  <sub>tal_west_3</sub>

### T29 · `fell_in`

*wenn* `valley.fell_twice`
  - *Wieder der Bach. Er ist nicht wärmer geworden.*  <sub>tal_fell_3</sub>
  - *Der Stein kippt, das Wasser ist da. Ihr kennt euch inzwischen.*  <sub>tal_fell_4</sub>
*sonst*
  - *Der Stein kippt. Dann ist da nur noch Wasser, eiskalt, bis zur Hüfte.*  <sub>tal_fell_1</sub>
  - *Du ziehst dich ans Ufer. Nass warst du vorher schon. Jetzt bist du es richtig.*  <sub>tal_fell_2</sub>
  - *Hinter dir schaukelt der Stein noch. Rund und glatt. Die flachen daneben haben sich nicht gerührt.*  <sub>tal_fell_5</sub>

### T30 · `goat`

*wenn* `valley.goat_traded`
  - *Die Ziege steht oben auf dem Holzstapel und kaut die Kartoffel. Wie sie da hochgekommen ist, verrät sie nicht.*  <sub>tal_goat_7</sub>
  - *Die Ziege schaut von oben auf dich herab. Sie hat keine Fragen.*  <sub>tal_goat_8</sub>
*sonst wenn* `item_potato`
  - *Du hältst der Ziege die Kartoffel hin. Eine bemerkenswert durchschnittliche Kartoffel.*  <sub>tal_goat_4</sub>
  - *Die Ziege betrachtet die Kartoffel. Dann den Stiefel. Dann wieder die Kartoffel.*  <sub>tal_goat_5</sub>
  - *Sie lässt den Stiefel fallen.*  <sub>tal_goat_6</sub>
*sonst wenn* `valley.goat_met`
  - *Die Ziege kaut am Stiefel. Zwischendurch schielt sie zum Gemüsebeet.*  <sub>tal_goat_3</sub>
*sonst*
  - *Eine Ziege. Sie hat einen Stiefel im Maul und kaut darauf, als hätte sie ihn sich verdient.*  <sub>tal_goat_1</sub>
  - *Du greifst nach dem Stiefel. Die Ziege dreht den Kopf weg. Sie will etwas anderes.*  <sub>tal_goat_2</sub>

### T31 · `puddle`

> The first reflection (ADR-042): in Elysia the water showed everything except you. After
> the rain the puddle by Mira's camp is smooth enough.

*wenn* `valley.reflection_seen`
  - *Die Pfütze ist still. Du bist noch da.*  <sub>tal_puddle_4</sub>
  - *Ein Blatt treibt über dein Spiegelbild und weiter.*  <sub>tal_puddle_5</sub>
*sonst*
  - *Der Regen hat aufgehört. Die Pfütze am Weg ist glatt geworden.*  <sub>tal_puddle_1</sub>
  - *Darin der Himmel, ein Ast. Und jemand mit nassen Haaren.*  <sub>tal_puddle_2</sub>
  *wenn* `valley.berries_eaten`
    - *Auf dem Handrücken ein kleiner roter Strich.*  <sub>tal_puddle_6</sub>
  *wenn* `elysia.mirror_seen`
    - *Du hebst die Hand. Das Wasser hebt sie mit.*  <sub>tal_puddle_7</sub>
  - *Du schaust länger hin, als man in eine Pfütze schaut.*  <sub>tal_puddle_3</sub>

### T32 · `antreiber_west`

> The Antreiber after the shed (ADR-042): he followed you back and sits by the path. He is
> not beaten, only out of breath (Game Bible §3.3).

- **Antreiber:** Ich sitz nur kurz. Sehr kurz.  <sub>tal_antr_1</sub>
- **Antreiber:** Ich hab ausgerechnet, wie lange man sitzen darf. Ich hab's vergessen.  <sub>tal_antr_2</sub>
- *Der Antreiber sitzt am Weg und schaut dahin, wo ihr hergekommen seid.*  <sub>tal_antr_3</sub>

### T33 · `antreiber_busy`

> The Antreiber after he left the house (ADR-042): back out in the rain, busy with things that
> are already done. Outside he stands; he only sits where he is tired.

- **Antreiber:** Ich hab das Dach angeschaut. Von außen. Es ist ein Dach.  <sub>tal_antr_busy_1</sub>
- **Antreiber:** Ich hab den Zaun gezählt. Es ist einer.  <sub>tal_antr_busy_2</sub>
- **Antreiber:** Ich hab das Holz umgestapelt. Nass ist es immer noch. Aber ordentlich.  <sub>tal_antr_busy_3</sub>

## antreiber


### A1 · `start`

- **Antreiber:** Holz! Gute Idee. Ich hab den Weg schon geplant.  <sub>sl_antr_start_1</sub>
- **Antreiber:** Schuppen, Holz, Feuer. Vor dem Dunkelwerden.  <sub>sl_antr_start_2</sub>
- **Antreiber:** Meine Liste: Erstens gehen. Zweitens schneller gehen.  <sub>sl_antr_start_3</sub>

### A2 · `urging`

- **Antreiber:** Gut. Weiter so.  <sub>sl_antr_urge_1</sub>
- **Antreiber:** Schritt, Schritt, Schritt. Sehr effizient.  <sub>sl_antr_urge_2</sub>
- **Antreiber:** Da vorne. Siehst du? Gleich.  <sub>sl_antr_urge_3</sub>
- **Antreiber:** Du machst das gut. Noch ein bisschen besser, dann reicht es.  <sub>sl_antr_urge_4</sub>
- **Antreiber:** Ich hab mitgezählt. Wir liegen gut.  <sub>sl_antr_urge_5</sub>
- **Antreiber:** Nicht zur Seite schauen, da ist nichts. Nach vorne.  <sub>sl_antr_urge_6</sub>
- **Antreiber:** Pausen machen wir, wenn wir da sind. Dann gleich eine lange.  <sub>sl_antr_urge_7</sub>

### A3 · `cheering`

- **Antreiber:** Ja! So kommen wir voran!  <sub>sl_antr_cheer_1</sub>
- **Antreiber:** Schneller ist besser. Das weiß jeder.  <sub>sl_antr_cheer_2</sub>
- **Antreiber:** Perfekt. Fast perfekt.  <sub>sl_antr_cheer_3</sub>
- **Antreiber:** So geht das! Wer rennt, friert nicht.  <sub>sl_antr_cheer_4</sub>

### A4 · `tired`

- **Antreiber:** Nicht anhalten. Wer anhält, verliert.  <sub>sl_antr_tired_1</sub>
- **Antreiber:** Wir sind fast da. Wir sind immer fast da.  <sub>sl_antr_tired_2</sub>
- **Antreiber:** Müde ist nur ein Gefühl. Das geht weg, wenn wir ankommen.  <sub>sl_antr_tired_3</sub>
- **Antreiber:** Ich bin nicht außer Atem. Ich atme nur schneller, um Zeit zu sparen.  <sub>sl_antr_tired_4</sub>
- **Antreiber:** Der Schuppen ist bestimmt gleich da. Er muss gleich da sein.  <sub>sl_antr_tired_5</sub>

### A5 · `worried`

- **Antreiber:** Warum wirst du langsamer?  <sub>sl_antr_worry_1</sub>
- **Antreiber:** Hey. Der Schuppen läuft uns nicht weg. Trotzdem.  <sub>sl_antr_worry_2</sub>

### A6 · `puzzled`

- **Antreiber:** Was machst du da?  <sub>sl_antr_puzzle_1</sub>
- **Antreiber:** Das ist kein Plan. Das ist Stehen.  <sub>sl_antr_puzzle_2</sub>
- **Antreiber:** Wir verlieren Zeit. Ich kann sie hören.  <sub>sl_antr_puzzle_3</sub>

### A7 · `puzzled_early`

> Stopped before the race really began (AntreiberModel.is_engaged): it does not count yet.

- **Antreiber:** Pause? Wir haben doch noch gar nicht angefangen.  <sub>sl_antr_early_1</sub>
- **Antreiber:** Jetzt schon? Wir sind doch eben erst los.  <sub>sl_antr_early_2</sub>

### A8 · `silent`

- **Antreiber:** …  <sub>sl_antr_silent_1</sub>

### A9 · `sign`

*wenn* `valley.shed_sign_read`
  - *Noch ein Wegweiser. »Schuppen 200 m«. Wie der letzte.*  <sub>sl_antr_sign_2</sub>
*sonst*
  - *Ein Wegweiser. »Schuppen 200 m«.*  <sub>sl_antr_sign_1</sub>

### A10 · `wood`

- *Das Holz liegt da. Trocken, gespalten, zusammengebunden. Es lag die ganze Zeit hier.*  <sub>sl_antr_wood_1</sub>
- *Der Antreiber sitzt auf dem Boden und weiß nicht genau, wohin mit seinen Händen.*  <sub>sl_antr_wood_2</sub>
- **Antreiber:** Ich wollte nur, dass wir ankommen, bevor es dunkel wird.  <sub>sl_antr_why_1</sub>
- **Antreiber:** Wer schnell genug ist, den holt nichts ein. Nicht die Kälte, nicht das Dunkel. Das hat immer funktioniert.  <sub>sl_antr_why_2</sub>
- ▸ **Wir sind angekommen.**
  - **Antreiber:** … Ja. Sind wir.  <sub>sl_antr_why_3</sub>
  - **Antreiber:** Hab ich gar nicht gemerkt.  <sub>sl_antr_why_4</sub>
- ▸ **Ohne dich wär ich noch nicht mal los.**
  - **Antreiber:** Stimmt.  <sub>sl_antr_why_5</sub>
  - *Er nickt, sehr schnell. Dann noch einmal, langsamer, als müsste er es nachprüfen.*  <sub>sl_antr_why_6</sub>
- ▸ **…**
  - *Der Antreiber sagt auch nichts. Es ist das erste Mal, dass er nichts sagt, ohne dass es ihn Mühe kostet.*  <sub>sl_antr_why_7</sub>

## haus


### H1 · `fireplace`

*wenn* `is_fire_lit()`
  - *Das Feuer brennt. Manchmal knackt es, wenn das Harz aufplatzt.*  <sub>haus_fire_1</sub>
  - *Wärme. Erst an den Händen, dann überall.*  <sub>haus_fire_2</sub>
  - *Du legst nichts nach. Es brennt auch so.*  <sub>haus_fire_3</sub>
*sonst wenn* `item_dry_wood`
  - *Du schichtest das Holz in den Kamin, die Rinde nach unten, wie man es irgendwann mal gelernt hat.*  <sub>haus_fire_4</sub>
  - *Ein Streichholz. Noch eins. Dann fängt die Rinde.*  <sub>haus_fire_5</sub>
*sonst wenn* `valley.wood_needed`
  - *Der Kamin ist kalt. Der Zettel steckt noch am Sims. »Nicht trödeln.«*  <sub>haus_fire_6</sub>
*sonst*
  - *Der Kamin ist kalt. Asche von einem anderen Winter.*  <sub>haus_fire_7</sub>
  - *Im Korb daneben liegt nur Rinde. Das Holz draußen ist nass.*  <sub>haus_fire_8</sub>
  - *Am Sims steckt ein Zettel, krakelig beschrieben. »Trockenes Holz im Schuppen. Weg nach Westen. Nicht trödeln.«*  <sub>haus_fire_9</sub>
  *wenn* `main_valley_shelter und house`

### H2 · `table`

*wenn* `house.spoon_found`
  - *Der Tisch wackelt. Unter einem Bein klemmt ein gefaltetes Stück Papier, das nicht hilft.*  <sub>haus_table_3</sub>
  - *Ein Becher, den niemand abgewaschen hat. Seit dem Frühjahr nicht.*  <sub>haus_table_4</sub>
*sonst*
  - *Ein Tisch, zwei Hocker, ein Becher. In der Schublade liegt ein Löffel.*  <sub>haus_table_1</sub>
  - *Ein sehr kleiner Löffel. Du nimmst ihn mit, ohne genau zu wissen, warum.*  <sub>haus_table_2</sub>

### H3 · `shelf`

*wenn* `shelf_1 und shelf_2`
  - *Ein Regal. Ein paar leere Gläser, ein Buch ohne Umschlag. Zwei Fächer sind ganz leer.*  <sub>haus_shelf_5</sub>
*wenn* `shelf_1 nicht`
  - *Der sehr kleine Löffel steht im Regal. Er sieht aus, als hätte er dort immer gestanden.*  <sub>haus_shelf_1</sub>
*wenn* `shelf_2 nicht`
  *wenn* `shelf_1 nicht`
    - *Daneben der Stein. Er glänzt nicht. Er liegt einfach gut da.*  <sub>haus_shelf_6</sub>
  *sonst*
    - *Im Regal liegt der Stein. Er glänzt nicht. Er liegt einfach gut da.*  <sub>haus_shelf_9</sub>
*wenn* `curiosity_tiny_spoon oder item_stone`
  *wenn* `shelf_1 und shelf_2`
    - *Beide gerade groß genug für etwas Kleines.*  <sub>haus_shelf_8</sub>
  *sonst*
    - *Ein Fach ist noch frei, gerade groß genug für etwas Kleines.*  <sub>haus_shelf_2</sub>
  - ▸ **Den Löffel hineinstellen** *(wenn `curiosity_tiny_spoon`)*
    - *Du stellst den Löffel ins Fach. Er passt genau.*  <sub>haus_shelf_3</sub>
  - ▸ **Den Stein hineinlegen** *(wenn `item_stone`)*
    - *Du legst den Stein ins Fach. Er wiegt fast nichts. Das Fach sieht trotzdem voller aus.*  <sub>haus_shelf_7</sub>
  - ▸ **Nichts hineinlegen**
    *wenn* `curiosity_tiny_spoon`
      - *Du behältst den Löffel. Für sehr kleine Suppen, vielleicht.*  <sub>haus_shelf_4</sub>
    *sonst*
      - *Du behältst den Stein. Das Fach kann warten.*  <sub>haus_shelf_10</sub>
  *wenn* `shelf_1 und shelf_2 nicht`

### H4 · `bed`

*wenn* `is_fire_lit()`
  - *Ein Bett. Die Decke ist warm geworden vom Feuer. Fast wie eine Einladung.*  <sub>haus_bed_2</sub>
*sonst*
  - *Ein Bett. Die Decke riecht nach Staub und ein bisschen nach jemand anderem.*  <sub>haus_bed_1</sub>
  *wenn* `elysia.offered_house`
    - *Drüben hat dir jemand sein Haus geschenkt, einfach so. Dieses hier schenkt dir niemand. Es steht nur da.*  <sub>haus_bed_5</sub>
  *sonst wenn* `elysia.soup_served`
    - *Für einen Moment denkst du an das Gasthaus drüben. An die Suppe, die immer warm war.*  <sub>haus_bed_3</sub>
    - *Dann ist der Moment vorbei. Das Bett ist immer noch kalt.*  <sub>haus_bed_4</sub>

### H5 · `bucket`

*wenn* `is_fire_lit()`
  - *Es tropft in den Eimer. Plink. Lange nichts. Plink.*  <sub>haus_bucket_2</sub>
*sonst*
  - *Ein Eimer unter einer undichten Stelle im Dach. Halb voll. Jemand hat ihn hingestellt, bevor er gegangen ist.*  <sub>haus_bucket_1</sub>

### H6 · `window`

*wenn* `abend`
  - *Im Fenster spiegelt sich das Feuer. Dahinter wird das Tal golden.*  <sub>haus_window_3</sub>
*sonst wenn* `is_fire_lit()`
  - *Im Fenster spiegelt sich das Feuer. Dahinter regnet es auf das Tal.*  <sub>haus_window_2</sub>
*sonst*
  - *Draußen regnet es auf das Tal. Am anderen Ufer glimmt ein kleines Feuer.*  <sub>haus_window_1</sub>

### H7 · `cat`

*wenn* `house.cat_fed`
  *wenn* `cat_name() != ""`
    - *‹Katzenname› schläft am Feuer. Ein Ohr hört trotzdem zu.*  <sub>haus_cat_6</sub>
    - *‹Katzenname› schnurrt, ohne aufzuwachen.*  <sub>haus_cat_7</sub>
  *sonst*
    - *Die Katze schläft am Feuer. Ein Ohr hört trotzdem zu.*  <sub>haus_cat_4</sub>
    - ▸ **Ihr einen Namen geben**
    - ▸ **Sie einfach Katze nennen**
      - *Katze. Sie hat schon Schlimmeres gehört.*  <sub>haus_cat_8</sub>
    - ▸ **Sie schlafen lassen**
      - *Du lässt sie schlafen. Namen haben Zeit.*  <sub>haus_cat_9</sub>
*sonst wenn* `item_fish`
  - *Du öffnest das Fenster einen Spalt und hältst den Fisch hinaus.*  <sub>haus_cat_2</sub>
  - *Die Katze überlegt nicht lange. Dann kommt sie herein, als wäre es ihre Idee gewesen.*  <sub>haus_cat_3</sub>
*sonst*
  - *Draußen auf dem Fensterbrett sitzt eine Katze und schaut herein. Nicht zu dir. Zum Feuer.*  <sub>haus_cat_1</sub>

### H8 · `cat_named`

- *‹Katzenname›. Die Katze öffnet ein Auge und schließt es wieder. Einverstanden, vermutlich.*  <sub>haus_cat_10</sub>

### H9 · `cat_antreiber`

> Later the cat sleeps on the Antreiber, and he does not dare get up (Game Bible §28).

*wenn* `cat_name() != ""`
  - *‹Katzenname› hat sich auf den Antreiber gelegt.*  <sub>haus_cat_antr_1</sub>
*sonst*
  - *Die Katze hat sich auf den Antreiber gelegt.*  <sub>haus_cat_antr_2</sub>
- **Antreiber:** Ich müsste eigentlich …  <sub>haus_cat_antr_3</sub>
- **Antreiber:** Das Dach. Das Holz für morgen. Der …  <sub>haus_cat_antr_4</sub>
- *Er bleibt sitzen. Er wagt nicht, sich zu bewegen.*  <sub>haus_cat_antr_5</sub>

### H10 · `fire_rest`

- *Du sitzt am Feuer. Die Wärme kommt erst an den Knien an, dann im Gesicht.*  <sub>haus_rest_1</sub>
*wenn* `abend`
  - *Draußen ist es still geworden. Der Regen ist vorbei.*  <sub>haus_rest_6</sub>
*sonst*
  - *Draußen regnet es weiter. Nur nicht mehr auf dich.*  <sub>haus_rest_2</sub>
*wenn* `elysia.host_warned`
  - *Du musst heute nirgends mehr hin, hat der Wirt gesagt. Heute musstest du ziemlich weit.*  <sub>haus_rest_7</sub>
*wenn* `item_stone und elysia.stone_taken nicht`
  - *In deiner Tasche ein Stein. Grau, glatt. Du kannst dich nicht erinnern, ihn aufgehoben zu haben.*  <sub>haus_rest_8</sub>
*sonst wenn* `item_stone`
  - *Der Stein in deiner Tasche ist warm geworden.*  <sub>haus_rest_3</sub>
*wenn* `item_seed`
  - *In der anderen Tasche der Samen. Du weißt nicht, seit wann er da ist.*  <sub>haus_rest_4</sub>

### H11 · `antreiber_fire`

- **Antreiber:** Wir könnten noch Holz für morgen holen. Nur vorsorglich.  <sub>haus_antr_1</sub>
- **Antreiber:** Oder das Dach. Das Dach tropft. Hast du den Eimer gesehen?  <sub>haus_antr_2</sub>

### H12 · `antreiber_sits`

- *Der Antreiber schaut dich an. Dann das Feuer.*  <sub>haus_antr_3</sub>
- *Er setzt sich. Die Hände legt er auf die Knie, dann in den Schoß, dann wieder auf die Knie.*  <sub>haus_antr_4</sub>

### H13 · `antreiber_cheers`

- **Antreiber:** Ja! Los!  <sub>haus_antr_5</sub>
- **Antreiber:** … Wohin eigentlich?  <sub>haus_antr_6</sub>
- *Er geht zur Tür. Draußen findet er bestimmt etwas.*  <sub>haus_antr_7</sub>

### H14 · `antreiber_rest`

*wenn* `house.cat_fed`
  - *→ weiter bei* `cat_antreiber`
- *Der Antreiber sitzt am Feuer und sieht aus, als würde er gleich aufspringen. Er springt nicht.*  <sub>haus_antr_8</sub>
- **Antreiber:** Ich sitz nur kurz.  <sub>haus_antr_9</sub>

### H15 · `knock`

- *Es klopft.*  <sub>haus_knock_1</sub>

### H16 · `stay`

- *Das Feuer brennt gerade erst richtig, und draußen regnet es. Der Teppich davor sieht warm aus.*  <sub>haus_stay_1</sub>

### H17 · `mira`

- *Mira wärmt sich die Hände am Feuer. Sie scheint gerade nicht reden zu wollen.*  <sub>haus_mira_idle_1</sub>

### H18 · `mira_visit`

- *Mira sitzt am Feuer, nass bis auf die Haut. Sie trägt nur einen Stiefel.*  <sub>haus_mira_1</sub>
- **Mira:** Ich hab den Rauch gesehen.  <sub>haus_mira_2</sub>
- **Mira:** Ich hab Fisch. Du hast Feuer.  <sub>haus_mira_3</sub>
- ▸ **Komm rein.**
  - **Mira:** Bin ich schon.  <sub>haus_mira_4</sub>
- ▸ **Wolltest du nicht lieber allein sein?**
  - **Mira:** Allein ja. Nass nein.  <sub>haus_mira_5</sub>
- ▸ **…**
  - **Mira:** Ich nehm das als Ja.  <sub>haus_mira_6</sub>
*wenn* `house.antreiber_by_fire`
  - *Der Antreiber ist ein Stück zur Seite gerückt. Mira sitzt auf dem freien Platz, als wäre er immer frei gewesen.*  <sub>haus_mira_29</sub>
  - *Sie legt den Fisch auf einen Stein und hält die Hände an die Flammen. Eine Weile sagt keiner etwas.*  <sub>haus_mira_30</sub>
*sonst*
  - *Mira legt den Fisch auf einen Stein und hält die Hände an die Flammen. Eine Weile sagt keiner etwas.*  <sub>haus_mira_7</sub>
*wenn* `valley.fell_in`
  *wenn* `mira und stones_warned`
    - **Mira:** Die runden. Ich hab's gesagt.  <sub>haus_mira_8</sub>
  *sonst wenn* `mira und chose_tree`
    - **Mira:** Ich dachte, du nimmst den Baum.  <sub>haus_mira_9</sub>
  *sonst*
    - **Mira:** Du bist in den Bach gefallen. Das hört man bis zu mir.  <sub>haus_mira_10</sub>
*sonst*
  - **Mira:** Trocken rübergekommen. Immerhin.  <sub>haus_mira_11</sub>
- **Mira:** Wo kommst du eigentlich her?  <sub>haus_mira_12</sub>
- ▸ **Von woanders.**
  - **Mira:** Woanders ist groß.  <sub>haus_mira_13</sub>
- ▸ **Aus Elysia.**
  *wenn* `mira und said_hero`
    - **Mira:** Ach ja. Wo du der Held bist.  <sub>haus_mira_27</sub>
  *sonst*
    - **Mira:** Nie gehört.  <sub>haus_mira_14</sub>
  - **Mira:** Klingt nach einem Ort, an dem es nicht regnet.  <sub>haus_mira_15</sub>
- ▸ **Ich weiß es nicht mehr genau.**
  - **Mira:** Das kenn ich.  <sub>haus_mira_16</sub>
  - *Mira schaut ins Feuer und sagt nichts mehr dazu.*  <sub>haus_mira_17</sub>
- **Mira:** Und du? Wie heißt du?  <sub>haus_mira_35</sub>
- ▸ **‹Name›.**
  - **Mira:** ‹Name›. Hm.  <sub>haus_mira_36</sub>
- ▸ **Der Held von Elysia.** *(wenn `mira und said_hero nicht`)*
  - **Mira:** Das ist kein Name. Das ist ein Beruf.  <sub>haus_mira_37</sub>
- ▸ **…**
  - **Mira:** Dann eben nicht. Ich ruf einfach rüber.  <sub>haus_mira_38</sub>
- **Mira:** Der Fisch ist gut. Nichts Besonderes. Aber gut.  <sub>haus_mira_18</sub>
- ▸ **Der beste Fisch, den ich je gegessen hab.**
  - **Mira:** Nein. Der war zu lang im Feuer.  <sub>haus_mira_31</sub>
  - **Mira:** Aber gut, ja.  <sub>haus_mira_32</sub>
- ▸ **Ja. Gut.**
  - **Mira:** Eben.  <sub>haus_mira_33</sub>
- ▸ **…**
  - *Ihr esst. Der Regen trommelt aufs Dach.*  <sub>haus_mira_34</sub>
*wenn* `elysia.soup_served`
  - *Der Fisch schmeckt nach Rauch und ein bisschen nach Bach. Und hat Gräten. Viele.*  <sub>haus_mira_28</sub>
- **Mira:** Die Leute, die hier gewohnt haben, hatten eine Ziege. Die läuft noch rum.  <sub>haus_mira_19</sub>
- **Mira:** Sie hat meinen Stiefel.  <sub>haus_mira_20</sub>
- ▸ **Deinen Stiefel?**
  - **Mira:** Ich hab ihn zum Trocknen hingestellt. Sie hat ihn zum Essen mitgenommen. Wir hatten unterschiedliche Pläne.  <sub>haus_mira_21</sub>
- ▸ **Soll ich ihn dir holen?**
  - **Mira:** Wenn du sie siehst. Ich renn keiner Ziege hinterher.  <sub>haus_mira_22</sub>
- **Mira:** Sie ist bestechlich. Nur damit du's weißt.  <sub>haus_mira_23</sub>
- *Mira streckt sich und sieht zur Tür.*  <sub>haus_mira_24</sub>
- **Mira:** Ich hab ein Brett über die Brücke gelegt. Damit ich zurückkomme. Und du auch, falls.  <sub>haus_mira_25</sub>
- **Mira:** Den Rest vom Fisch kannst du der Katze geben. Die sitzt schon die ganze Zeit am Fenster.  <sub>haus_mira_26</sub>
