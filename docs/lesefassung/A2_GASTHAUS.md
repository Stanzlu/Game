# A2: Das Gasthaus zum Immer

<!-- Erzeugt mit `python3 tools/writing/readable.py`. Nicht von Hand ändern: Änderungen gehören in die .dialogue-Dateien. -->

Lesefassung: der Text in der Reihenfolge, in der das Spiel ihn zeigt. *Kursiv* ist Erzählung, **fett** sprechen die Figuren, ▸ sind deine Antworten. Eingerückt steht, was nur unter einer Bedingung oder nach einer Antwort kommt. Hinter jeder Zeile die ID in klein.

**So antwortest du:** je Szene (E3, T12 …) „OK“, „ändern: …“ oder „raus“. Was du nicht nennst, gilt als OK.


## gasthaus


### G1 · `host`

*wenn* `elysia.inn_met nicht`
  - *→ weiter bei* `host_first`
*sonst wenn* `elysia.loops`
  - *→ weiter bei* `host_loop`
*sonst wenn* `elysia.inn_fed nicht`
  - *→ weiter bei* `host_meal`
*sonst wenn* `elysia.inn_slept`
  - *→ weiter bei* `host_slept`
*sonst wenn* `elysia.inn_room`
  - *→ weiter bei* `host_upstairs`
- *→ weiter bei* `host_room`

### G2 · `host_loop`

> The repetition (A7, ADR-062): the host says his first sentences again, word for word, whatever was offered.

- **Gastwirt:** Da ist er ja! Komm rein, komm rein. Die Tür macht sich von selbst zu. `[#draft]`  <sub>gh_host_loop_1</sub>
- **Gastwirt:** Das Gasthaus zum Immer. Wir haben geöffnet. Wir hatten immer geöffnet. `[#draft]`  <sub>gh_host_loop_2</sub>

### G3 · `host_first`

- **Gastwirt:** Da ist er ja! Komm rein, komm rein. Die Tür macht sich von selbst zu. `[#draft]`  <sub>gh_host_1</sub>
- **Gastwirt:** Das Gasthaus zum Immer. Wir haben geöffnet. Wir hatten immer geöffnet. `[#draft]`  <sub>gh_host_2</sub>
- **Gastwirt:** Ich hab dir den besten Platz freigehalten. Hier sind alle Plätze die besten. `[#draft]`  <sub>gh_host_3</sub>
- **Gastwirt:** Und trag dich ins Buch ein, ja? Du stehst schon drin. Aber sicher ist sicher. `[#draft]`  <sub>gh_host_6</sub>
- ▸ **Danke. Ich setz mich gern.**
  - *→ weiter bei* `host_meal`
- ▸ **Ich schau mich nur um.**
  - **Gastwirt:** Schau nur, schau nur. Schau, so viel du willst. Es sieht immer gleich gut aus. `[#draft]`  <sub>gh_host_4</sub>
- ▸ **…**
  - **Gastwirt:** Ein stiller Gast. Ein Kenner. Die besten Gäste sagen nichts und essen alles. `[#draft]`  <sub>gh_host_5</sub>

### G4 · `host_meal`

- **Gastwirt:** Setz dich, setz dich. Das Brot kommt gleich. Es ist schon da. `[#draft]`  <sub>gh_meal_1</sub>
- *Auf dem Tisch steht ein Korb. Du hast niemanden kommen sehen.* `[#draft]`  <sub>gh_meal_2</sub>
- *Das Brot ist warm, die Kruste knackt, wie sie knacken soll. Es schmeckt, wie Brot schmeckt, wenn man an Brot denkt.* `[#draft]`  <sub>gh_meal_3</sub>
- **Gastwirt:** Na? Na? Wie schmeckt es? `[#draft]`  <sub>gh_meal_4</sub>
- ▸ **Fantastisch.**
  - **Gastwirt:** Sag ich doch! Das Rezept ist von gestern. Gestern war es von vorgestern. `[#draft]`  <sub>gh_meal_5</sub>
- ▸ **Nach … Brot.**
  - **Gastwirt:** Nach Brot! Ha! Der war gut. Nach Brot. `[#draft]`  <sub>gh_meal_6</sub>
- ▸ **…**
  - **Gastwirt:** Sprachlos. Das sind sie alle. Ich nehm das als Lob. `[#draft]`  <sub>gh_meal_7</sub>

### G5 · `host_room`

> The second talk, and the most dangerous line of the Betäuber (Bible §14); free to refuse, asked again.

*wenn* `elysia.inn_declined`
  - **Gastwirt:** Das Zimmer, das Zimmer! Es fragt schon nach dir. Es fragt nicht. Es freut sich nur. `[#draft]`  <sub>gh_room_8</sub>
*sonst*
  - **Gastwirt:** Dein Zimmer ist fertig. Links. Oder rechts. Beide sind deins, sie sind genau gleich. `[#draft]`  <sub>gh_room_1</sub>
  - **Gastwirt:** Frisch bezogen. Frisch bezogen ist es hier immer. `[#draft]`  <sub>gh_room_2</sub>
- **Gastwirt:** Du musst heute nicht zurück. `[#draft]`  <sub>gh_room_3</sub>
- ▸ **Danke. Ich seh es mir an.**
  - **Gastwirt:** Geh nur, geh nur. Die Türen gehen für dich auf. Sie haben schon geübt. `[#draft]`  <sub>gh_room_4</sub>
- ▸ **Ich muss weiter.**
  - **Gastwirt:** Musst du? Wirklich? `[#draft]`  <sub>gh_room_5</sub>
  - **Gastwirt:** Das Zimmer bleibt, wo es ist. Es wartet gern. Es hat nichts anderes vor. `[#draft]`  <sub>gh_room_6</sub>
- ▸ **…**
  - **Gastwirt:** Du überlegst. Ich warte. Ich hab Zeit. Wir haben hier alle Zeit. `[#draft]`  <sub>gh_room_7</sub>

### G6 · `host_upstairs`

- **Gastwirt:** Dein Zimmer ist offen. Beide Türen. Such dir die aus, die dir besser gefällt. `[#draft]`  <sub>gh_up_1</sub>
- **Gastwirt:** Das Bett ist schon warm. Das Kissen liegt in der Mitte, wie es soll. `[#draft]`  <sub>gh_up_2</sub>
- **Gastwirt:** Falls du was brauchst, sag es einfach. Ich hab es schon gebracht. `[#draft]`  <sub>gh_up_3</sub>

### G7 · `host_slept`

> The third talk, after the night (Bible §14: leaving must be the player's own act).

*wenn* `elysia.inn_stayed`
  - **Gastwirt:** Du bist ja noch da! Das freut mich jedes Mal wieder. `[#draft]`  <sub>gh_slept_5</sub>
*sonst*
  - **Gastwirt:** Gut geschlafen? Natürlich hast du. `[#draft]`  <sub>gh_slept_1</sub>
  - **Gastwirt:** Du kannst für immer bleiben. Das sag ich jedem. Ich sag es sehr gern. `[#draft]`  <sub>gh_slept_2</sub>
- ▸ **Ich bleib noch ein bisschen.**
  - **Gastwirt:** Natürlich! Ein bisschen ist hier immer ein bisschen länger. `[#draft]`  <sub>gh_slept_3</sub>
- ▸ **Ich geh gleich.**
  - **Gastwirt:** Sicher, sicher. Geh nur. Ich halte dir den Platz frei. Er ist ja nie besetzt. `[#draft]`  <sub>gh_slept_4</sub>
- ▸ **…**
  - **Gastwirt:** Ein Schweigen zum Mitnehmen. Hier, ein Brot dazu. `[#draft]`  <sub>gh_slept_6</sub>

### G8 · `guest`

*wenn* `elysia.loops`
  - **Elysianer:** Das Brot hier! Ich komme jeden Tag. Es ist jeden Tag das beste. `[#draft]`  <sub>gh_guest_loop</sub>
*sonst*
  - **Elysianer:** Das Brot hier! Ich komme jeden Tag. Es ist jeden Tag das beste. `[#draft]`  <sub>gh_guest_1</sub>
  - **Elysianer:** Du setzt dich so schön. Ich würde mich auch gern so setzen. Ich übe. `[#draft]`  <sub>gh_guest_2</sub>
  - **Elysianer:** Der Wirt hat gesagt, du bleibst. Ich hab gesagt, natürlich bleibt er. `[#draft]`  <sub>gh_guest_3</sub>

### G9 · `guestbook`

*wenn* `elysia.inn_book_signed`
  - *Das Gästebuch liegt offen. Unter deiner Zeile ist Platz für die nächste.* `[#draft]`  <sub>gh_book_3</sub>
*sonst wenn* `elysia.inn_book_seen`
  - *Dein Name steht auf jeder Seite. Die letzte Zeile ist noch frei.* `[#draft]`  <sub>gh_book_6</sub>
  - *→ weiter bei* `guestbook_sign`
*sonst*
  - *Das Gästebuch liegt aufgeschlagen auf einem Pult. Auf jeder Seite steht dein Name, von oben bis unten, in schöner Schrift.* `[#draft]`  <sub>gh_book_1</sub>
  - *Es ist nicht deine.* `[#draft]`  <sub>gh_book_2</sub>
  - *→ weiter bei* `guestbook_sign`

### G10 · `guestbook_sign`

*wenn* `side_elysia_guestbook`
  - ▸ **Dich noch einmal eintragen.**
    - *Du schreibst deinen Namen unter deinen Namen. Die Feder kratzt nicht.* `[#draft]`  <sub>gh_book_4</sub>
  - ▸ **Lieber nicht.**
    - *Du lässt die Feder, wo sie ist. Sie sieht nicht enttäuscht aus. Nichts hier sieht enttäuscht aus.* `[#draft]`  <sub>gh_book_5</sub>

### G11 · `clock`

- *Eine Uhr an der Wand, ohne Zeiger und ohne Ziffern. Auf dem Zifferblatt steht in goldenen Buchstaben ein Wort. Jetzt.* `[#draft]`  <sub>gh_clock_1</sub>

### G12 · `window`

- *Durch das Fenster siehst du den Garten. Durch das gegenüber auch.* `[#draft]`  <sub>gh_window_1</sub>
- *Du suchst den Unterschied. Es gibt keinen.* `[#draft]`  <sub>gh_window_2</sub>

### G13 · `back_door`

- *Zwei Türen hinter dem Tresen, ohne Schild, genau gleich. Beide sind zu. Dahinter ist nichts zu hören.* `[#draft]`  <sub>gh_back_1</sub>

### G14 · `room_locked`

- *Die Tür ist zu. Sie sieht aus, als würde sie sich gleich für dich öffnen.* `[#draft]`  <sub>gh_door_1</sub>

### G15 · `hearth`

- *Das Feuer brennt, seit es das Haus gibt. Es hat noch nie Holz gebraucht.* `[#draft]`  <sub>gh_hearth_1</sub>

### G16 · `bed`

*wenn* `elysia.inn_slept`
  - *Das Bett ist gemacht. Schon wieder.* `[#draft]`  <sub>gh_bed_6</sub>
  - *Die Decke ist glatt, das Kissen liegt in der Mitte. Es hat auf dich gewartet.* `[#draft]`  <sub>gh_bed_7</sub>
*sonst*
  - *Ein Bett. Frisch bezogen, die Decke glatt, das Kissen genau in der Mitte.* `[#draft]`  <sub>gh_bed_1</sub>
  - ▸ **Dich hinlegen.**
    - *Du legst dich hin. Die Decke ist warm, bevor du sie berührst.* `[#draft]`  <sub>gh_bed_2</sub>
  - ▸ **Stehen bleiben.**
    - *Du bleibst stehen. Das Bett nimmt es nicht übel. Es hat Zeit.* `[#draft]`  <sub>gh_bed_3</sub>

### G17 · `woke`

> After the night: the same waking as the first one (el_wake_0), and nobody finds that strange.

- *Licht. Warm, von überall. Du hast die Augen gerade erst aufgemacht.* `[#draft]`  <sub>gh_woke_1</sub>
- *Es ist derselbe Morgen.* `[#draft]`  <sub>gh_woke_2</sub>
