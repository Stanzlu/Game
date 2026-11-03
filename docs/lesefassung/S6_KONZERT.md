# S6 Konzert (Akt IV)

<!-- Erzeugt mit `python3 tools/writing/readable.py`. Nicht von Hand ändern: Änderungen gehören in die .dialogue-Dateien. -->

Lesefassung: der Text in der Reihenfolge, in der das Spiel ihn zeigt. *Kursiv* ist Erzählung, **fett** sprechen die Figuren, ▸ sind deine Antworten. Eingerückt steht, was nur unter einer Bedingung oder nach einer Antwort kommt. Hinter jeder Zeile die ID in klein.

**So antwortest du:** je Szene (E3, T12 …) „OK“, „ändern: …“ oder „raus“. Was du nicht nennst, gilt als OK.


## konzert


### S6-1 · `arrive`

- *Der Platz am Abend. An den Pfosten brennen Laternen, irgendwo raucht ein Ofen, und es riecht nach Brot, das nicht mehr heiß ist.* `[#draft]`  <sub>kon_arr_1</sub>
*wenn* `list.done_stage`
  - *Die Bühne steht. Wo sie wackelt, sind es deine Nägel, und die wackeln wenigstens aufrichtig.* `[#draft]`  <sub>kon_arr_2</sub>
*sonst*
  - *Die Bühne steht schief. Wer sie gebaut hat, hat bei den Nägeln gespart.* `[#draft]`  <sub>kon_arr_3</sub>

### S6-2 · `intro`

> --- Die Ankündigung ---------------------------------------------------------------------------------------------------------------------
> Lio steht an der Bühnenkante, die Ziege schon neben ihm. Er kündigt an, setzt neu an und liefert den eigentlichen Satz spät; zuletzt verspricht er, dass jeder Fehler Absicht war,
> und verschiebt die Auskunft, welcher, auf hinterher.

- *Lio sitzt mitten auf der Bühne, die Laute vor der Brust. Neben ihm steht die Ziege, als stünde sie im Programm.* `[#draft]`  <sub>kon_intro_1</sub>
- **Lio:** Willkommen! Heute Abend hört ihr — nein. Heute Abend hören wir. Alle zusammen. So ist es geplant. `[#draft]`  <sub>kon_intro_2</sub>
- **Lio:** Das erste Stück heißt »Der Teil, an dem es gut wird«. Der Teil kommt gleich. Erst kommt der Teil davor, und der ist auch gut. In seiner Art. `[#draft]`  <sub>kon_intro_3</sub>
- **Lio:** Falls etwas schiefgeht, war das Absicht. Ich sage hinterher, was. `[#draft]`  <sub>kon_intro_4</sub>

### S6-3 · `snap`

> --- Die Saite -------------------------------------------------------------------------------------------------------------------------------
> Beim ersten Akkord reißt die tiefste Saite. Das Flag steht vor der Zeile, die es erzählt (eine Mutation läuft, wenn ihre Zeile verlangt wird), die Szene spielt in demselben Augenblick den Klang (string_snap); davor steht kein Wort
> über den Klang, danach spielt Lio auf den übrigen weiter. Der Witz zielt auf den Ablauf (die Tiefe), nicht auf ihn.

- *Lio setzt die Finger auf die Saiten, holt Luft und schlägt den ersten Akkord an.* `[#draft]`  <sub>kon_snap_1</sub>
- *Die tiefste Saite reißt, schnellt ihm über die Hand und hängt schief von der Brücke.* `[#draft]`  <sub>kon_snap_2</sub>
- *Er sieht sie an, sieht auf den Platz und spielt auf den übrigen weiter, eine Lage höher als geplant.* `[#draft]`  <sub>kon_snap_3</sub>
- **Lio:** Die Tiefe streichen wir. Heute gibt es nur Höhe, dafür reichlich. `[#draft]`  <sub>kon_snap_4</sub>

### S6-4 · `hold`

> --- Die Lampe -------------------------------------------------------------------------------------------------------------------------------
> Die Bühnenlampe kippt, und Lio fragt nicht, er stellt fest, dass jemand müsse. Drei Antworten, alle ergeben dieselbe Lampe (ein wenig schief, sie steht): "Ich halte sie." (unbedingt),
> "Orin! Hältst du die Lampe?" (nur mit der Facette connection: die Spielerin bittet um Hilfe, und Orin hält, mit etwas Konkretem; er steht danach am Pfosten, city.stage_orin) und das
> Schweigen (Lio hält den Pfosten mit dem Fuß, nichts wird gesetzt). Keiner wird gelobt. Das Schweigen bleibt die letzte Antwort. Die Folge liest con_orin, nicht dieser Cue.

- *Am rechten Rand der Bühne neigt sich die Lampe auf ihrem Pfosten, langsam, wie jemand, der im Stehen einschläft.* `[#draft]`  <sub>kon_hold_1</sub>
- **Lio:** Das ist Licht von der Seite. Sehr künstlerisch. Es muss nur jemand — also. Jemand muss sie halten. `[#draft]`  <sub>kon_hold_2</sub>
- ▸ **Ich halte sie.**
  - *Du steigst auf die Bretter und fasst den Pfosten. Die Lampe kippt noch einen Fingerbreit und steht dann, ein wenig schief.* `[#draft]`  <sub>kon_hold_3</sub>
- ▸ **Orin! Hältst du die Lampe?** *(wenn `connection und city.orin_met`)*
  - *Orin kommt durch die erste Reihe, ohne jemanden zu streifen, und fasst den Pfosten mit beiden Händen. Die Lampe steht, ein wenig schief.* `[#draft]`  <sub>kon_hold_4</sub>
  - **Orin:** Mit Bast ginge es besser. Ich habe immer Bast. Bis dahin halte ich. `[#draft]`  <sub>kon_hold_5</sub>
- ▸ **…**
  - *Lio rückt in kleinen Schritten zum Pfosten, klemmt ihn mit dem Fuß fest und spielt weiter. Die Lampe steht, ein wenig schief.* `[#draft]`  <sub>kon_hold_6</sub>

### S6-5 · `goat`

> --- Die Ziege -------------------------------------------------------------------------------------------------------------------------------
> Sie steht neben Lio auf der Bühne und setzt sich auf den Taktschlag, auf den sonst keiner wartet. Sie sagt nichts Verständliches, und niemand, auch der Text nicht, erklärt, was sie will.

- *Die Ziege neben Lio setzt die Hufe nebeneinander, als sei dort ihr Platz eingezeichnet.* `[#draft]`  <sub>kon_goat_1</sub>
- **Ziege:** Mäh-äh. Mäh. Mäh-äh. `[#draft]`  <sub>kon_goat_2</sub>

### S6-6 · `entry`

> --- Der Einsatz -------------------------------------------------------------------------------------------------------------------------------
> Lio zählt für eine Band ein, die es nicht gibt, und niemand kommt, weil niemand da ist. Die Ziege hat den Einsatz, auf der Eins. Das Lachen gilt dem Ablauf; Lio rettet die Lage mit der
> Behauptung, es sei ihr Einsatz gewesen.

- **Lio:** Und eins, und zwei, und drei, und jetzt die anderen! `[#draft]`  <sub>kon_entry_1</sub>
- *Er nickt nach hinten, zu einer Band, die nicht da ist. Nur die Ziege meckert, genau auf der Eins, und der Platz lacht auf.* `[#draft]`  <sub>kon_entry_2</sub>
- **Lio:** Das war ihr Einsatz. Ich wollte ihn nur nicht vorwegnehmen. `[#draft]`  <sub>kon_entry_3</sub>

### S6-7 · `wind`

> --- Der Wind -------------------------------------------------------------------------------------------------------------------------------------
> Er nimmt das Notenblatt vom Ständer, die Laternen schwanken, und mit ihnen die Schatten der Leute. Zwei Zeilen, nur Dinge.

- *Ein Windstoß fährt über den Platz, nimmt Lio das Notenblatt vom Ständer und trägt es über die Köpfe davon, Richtung Brunnen.* `[#draft]`  <sub>kon_wind_1</sub>
- *Die Laternen schwanken an ihren Pfosten, und die Schatten der Leute gehen mit, alle ein Stück nach links, als hätten sie sich verabredet.* `[#draft]`  <sub>kon_wind_2</sub>

### S6-8 · `song`

> --- Das Lied -------------------------------------------------------------------------------------------------------------------------------------
> Die dritte Melodie der Stadt, melody.lio_concert (die Szene spielt den Klang mit dem Flag, rund neunzehn Sekunden). Lio spielt ohne Noten auf den Saiten, die ihm bleiben, und der Platz bleibt:
> die Bürgerin singt den falschen Text, der Gefällige sitzt ohne Zettel in der Hand (ein Bild, kein Satz über ihn), Tess klatscht neben dem Takt (nur mit city.board_done, sonst steht sie nicht in der
> Menge), die Beamtin sieht auf die Uhr und hört dann auf, es zu tun, und der Refrain kommt beim zweiten Mal richtig an. Keine Zeile sagt, ob es gut war. Setzt die Erinnerung lio.concert
> und macht die Beziehung zu Lio vertraut.

- *Lio sieht dem Blatt nach und lässt es gehen. Dann fängt er von vorn an, ohne Noten, auf den Saiten, die ihm bleiben.* `[#draft]`  <sub>kon_song_1</sub>
- *Die Bürgerin mit dem schweren Korb singt mit, laut und mit vollem Text. Es ist der Text eines anderen Liedes. Er passt trotzdem.* `[#draft]`  <sub>kon_song_2</sub>
- *Der Gefällige sitzt am Rand der Menge auf dem Pflaster. In seinen Händen ist kein Zettel. Du siehst es erst jetzt, und er auch.* `[#draft]`  <sub>kon_song_3</sub>
*wenn* `city.board_done`
  - *Hinten klatscht Tess, einen halben Schlag neben dem Takt, und bleibt dabei, gleichmäßig wie bei einer Säge.* `[#draft]`  <sub>kon_song_4</sub>
- *Die Beamtin sieht auf ihre Uhr, dann auf die Bühne, dann steckt sie die Uhr weg. In der Tasche geht ihre Hand im Takt.* `[#draft]`  <sub>kon_song_5</sub>
- *Der Refrain kommt ein zweites Mal. Diesmal trifft Lio jeden Ton, und der Platz trifft mit, auf ein langes, offenes O.* `[#draft]`  <sub>kon_song_6</sub>

### S6-9 · `finale`

> --- Das Ende der Zwischensequenz --------------------------------------------------------------------------------------------------------
> Ein stilles Bild: der letzte Akkord steht, die Menge löst sich nicht auf, Lio verbeugt sich vor der Ziege. Kein Schwarz, kein Titel, kein Elysia-Ende; hier endet die Zwischensequenz
> und die Spielerin geht frei.

- *Der letzte Akkord steht lange über dem Platz. Dann ist es still, und keiner geht, die Hände noch halb erhoben.* `[#draft]`  <sub>kon_fin_1</sub>
- *Lio nimmt den Hut ab und verbeugt sich, tief und ohne Eile, vor der Ziege. Sie nimmt es hin.* `[#draft]`  <sub>kon_fin_2</sub>

### S6-10 · `con_lio`

> --- Danach: Lio und die Saite -----------------------------------------------------------------------------------------------------------
> Lio sitzt auf den Brettern, die Laute auf dem Knie, und schenkt ihr die gerissene Saite ("Sie hat ihr Bestes gegeben"). Beide Antworten sind gleichwertig, nichts wird gezählt: einstecken
> (Kuriosität, city.string_taken) oder liegen lassen (er legt sie auf die Bühne, city.string_left). Der Router con_lio liest nur und springt; das Setzen steht in con_lio_gift, die Wiederkehr in
> con_lio_again, die beide Wege kennt und nichts fragt.

*wenn* `city.string_taken oder city.string_left`
  - *→ weiter bei* `con_lio_again`
- *→ weiter bei* `con_lio_gift`

### S6-11 · `con_lio_gift`

- *Lio sitzt auf den Brettern, die Laute auf dem Knie, und wickelt die gerissene Saite um zwei Finger.* `[#draft]`  <sub>kon_lio_1</sub>
- **Lio:** Die ist heute gerissen. Behalt sie. Sie hat ihr Bestes gegeben. `[#draft]`  <sub>kon_lio_2</sub>
- ▸ **Einstecken.**
  - *Du steckst sie ein. Sie federt noch, ganz leise, in der Tasche.* `[#draft]`  <sub>kon_lio_3</sub>
- ▸ **Lass nur.**
  - *Lio legt sie neben sich auf die Bretter, schön gerade, als brauche er sie morgen noch.* `[#draft]`  <sub>kon_lio_4</sub>

### S6-12 · `con_lio_again`

*wenn* `city.string_taken`
  - **Lio:** Du hast die Saite? Gut. Sie hat als Erste Feierabend gemacht, das verdient Aufbewahrung. `[#draft]`  <sub>kon_lioa_1</sub>
*sonst*
  - **Lio:** Die Saite bleibt liegen, wo sie liegt. Sie hat sich den Platz verdient. `[#draft]`  <sub>kon_lioa_2</sub>

### S6-13 · `con_goat`

> --- Danach: die Ziege, Orin, der Gefällige, Mira ---------------------------------------------------------------------------------------
> Kurze Gespräche und Bilder, jedes wiederholbar ohne Wirkung (außer Miras letzter Zeile: sie geht ans Tor, der Streit folgt in streit.dialogue, S7). Die Ziege sagt nichts Verständliches (O13). Orin steht am Pfosten, wenn die Spielerin ihn gebeten hat (city.stage_orin), und erzählt
> etwas Konkretes vom Halten, ohne Gefühlswort und ohne Lehre; sonst steht er in der Menge und sagt etwas Konkretes über den Abend, die Ente fehlt nicht, sie ist nur nicht eingeladen (nach dem Brief, city.letter_told, ohne Witz: der Geruch der Laternen). Der Gefällige
> entschuldigt sich nicht, ein Satz. Mira steht im Dunkel hinter dem Brunnen, trocken, sie sieht zum Tor; keine Erinnerung, kein Flag, kein Wort über die Liste (46 von 47 gehört dem Streit in S7).

- *Die Ziege steht noch auf der Bühne und sieht hinauf zum First des Rathauses, als rechne sie etwas nach.* `[#draft]`  <sub>kon_cgoat_1</sub>
- **Ziege:** Mäh. Mäh-äh. `[#draft]`  <sub>kon_cgoat_2</sub>

### S6-14 · `con_orin`

*wenn* `city.stage_orin`
  - *Orin steht noch am Pfosten, beide Hände um das Holz, den Rücken gerade wie ein Türrahmen.* `[#draft]`  <sub>kon_orin_1</sub>
  - **Orin:** Als die Ziege einsetzte, hat der Pfosten in meinen Händen gezuckt. Jetzt liegt er ruhig. Esche, glaube ich. `[#draft]`  <sub>kon_orin_2</sub>
  - *→ Ende des Szenenstücks*
- *Orin steht am Rand der Menge, die Arme verschränkt, und sieht den Platz an, zweimal von links nach rechts.* `[#draft]`  <sub>kon_orin_3</sub>
*wenn* `city.letter_told`
  - **Orin:** Die Laternen riechen nach Öl und ein wenig nach Wachs. Ich bleibe noch, solange es riecht. `[#draft]`  <sub>kon_orin_5</sub>
  - *→ Ende des Szenenstücks*
- **Orin:** Ich habe nachgesehen. Keine Ente. Sie fehlt nicht, sie ist nur nicht eingeladen. Den Unterschied mache ich gern. `[#draft]`  <sub>kon_orin_4</sub>

### S6-15 · `con_gef`

- *Der Gefällige sitzt noch auf dem Pflaster, die Hände leer auf den Knien.* `[#draft]`  <sub>kon_gef_1</sub>
- **Gefälliger:** Ich sitze. Das ist alles, was ich gerade tue. `[#draft]`  <sub>kon_gef_2</sub>

### S6-16 · `con_mira`

- *Mira lehnt am Rand der Menge, im Dunkel zwischen zwei Laternen, das Netz über der Schulter. Sie sieht dich an und gleich darauf an dir vorbei, zum Tor.* `[#draft]`  <sub>kon_mira_1</sub>
- **Mira:** Die mit dem Korb hat einen anderen Text gesungen und ihn durchgezogen. Immerhin. `[#draft]`  <sub>kon_mira_2</sub>
- **Mira:** Ich stell mich ans Tor. Ich geh noch heute Nacht weiter. `[#draft]`  <sub>kon_mira_3</sub>
*wenn* `main_city_way und evening`

### S6-17 · `con_scratch`

> --- Das Fragment: das alte Brett ------------------------------------------------------------------------------------------------------------
> Eine Spur der Welt (kein Bild des Kindes, keine Figur, kein lesbares Wort): an der Bühnenecke lehnt das älteste Brett, das nicht neu ist, mit Kerben, die einmal Buchstaben waren, und zwei
> halben Herzen übereinander, von jemandem angefangen und aufgegeben. Das erste Mal setzt das Flag, danach gibt es nur noch eine kurze Zeile ohne Wirkung. Die Worte sind die der Erzählung.

*wenn* `fragment.stage_scratch`
  - *Das graue Brett an der Bühnenecke. Die zwei halben Herzen hören an derselben Stelle auf.* `[#draft]`  <sub>kon_scr_4</sub>
  - *→ Ende des Szenenstücks*
- *An der Bühnenecke lehnt ein Brett, das älter ist als die Bühne, grau wie Regen. Kerben laufen darüber, Buchstaben, die man nicht mehr liest.* `[#draft]`  <sub>kon_scr_1</sub>
- *Dazwischen ein Herz, auf halbem Weg liegen gelassen, und darüber ein zweites, das an derselben Stelle aufhört.* `[#draft]`  <sub>kon_scr_2</sub>
- *Für einen Atemzug stehen die Kerben hell im Holz, frisch, mit Spänen in den Rillen. Dann sind sie wieder grau, und die Laternen schwanken.* `[#draft]`  <sub>kon_scr_3</sub>

### S6-18 · `con_poster`

> --- Das Plakat ------------------------------------------------------------------------------------------------------------------------------------------
> Am Pfosten hängt Lios Plakat, mit Kohle geschrieben, die Buchstaben kippen nach rechts, als liefen sie dem nächsten Satz voraus. Kuriosität: "Abnehmen." (city.poster_taken) oder "Hängen lassen."
> (city.poster_left), gleichwertig, nichts gezählt. Der Router con_poster liest nur; das Setzen steht in con_poster_pick, die Wiederkehr in con_poster_again (der Pfeil bei "Ausstieg auch" zeigt
> zum Tor, ein Ding, das keiner erklärt). Keine Ziffern auf dem Plakat.

*wenn* `city.poster_taken oder city.poster_left`
  - *→ weiter bei* `con_poster_again`
- *→ weiter bei* `con_poster_pick`

### S6-19 · `con_poster_pick`

- *Am Pfosten hängt ein Plakat, gelblich, mit Kohle beschrieben, die Buchstaben kippen nach rechts, als liefen sie dem nächsten Satz voraus.* `[#draft]`  <sub>kon_post_1</sub>
- *Es heißt »Das schlechteste Konzert der Welt«. Darunter steht »Eintritt frei«, und noch kleiner, mit einem Pfeil, »Ausstieg auch«.* `[#draft]`  <sub>kon_post_2</sub>
- ▸ **Abnehmen.**
  - *Du ziehst die Nägel heraus, einen nach dem anderen. Das Plakat rollt sich in deiner Hand sofort ein, als hätte es nichts dagegen.* `[#draft]`  <sub>kon_post_3</sub>
- ▸ **Hängen lassen.**
  - *Du lässt es hängen. Der Wind hebt eine Ecke und legt sie wieder hin.* `[#draft]`  <sub>kon_post_4</sub>

### S6-20 · `con_poster_again`

*wenn* `city.poster_taken`
  - *Das Plakat hängt noch, dasselbe noch einmal. Lio hat mehr davon gemalt, als es Pfosten gibt.* `[#draft]`  <sub>kon_posta_1</sub>
*sonst*
  - *Das Plakat hängt noch. Der Pfeil bei »Ausstieg auch« zeigt zum Tor.* `[#draft]`  <sub>kon_posta_2</sub>

## stadt


### S2-8 · `lio_street`

> --- Lio -----------------------------------------------------------------------------------------------------------------
> Straßenmusik: er kündigt an und liefert mit Verspätung (die Szene spielt den Klang, sobald melody.lio_street gesetzt ist, also nach der
> Ankündigung), ein Ton geht daneben, und er lacht über den Ablauf, nicht über sich. Kein Selbsthass, kein Elysia-Lob. Wer wiederkommt,
> bekommt eine von zwei kurzen Zeilen.

*wenn* `melody.lio_street`
  - *→ weiter bei* `lio_again`
- *Auf einer Kiste sitzt ein Mann mit Laute, Hut und Feder. Die Haltung gehört einem, vor dem gleich alle stehen bleiben.* `[#draft]`  <sub>stadt_lio_1</sub>
- **Lio:** Gleich! Gleich kommt der Teil, an dem es gut wird. Das Stück heißt »Ankunft«. Oder »Anlauf«, das entscheidet sich beim Spielen. `[#draft]`  <sub>stadt_lio_2</sub>
- *Er stimmt die Laute, stimmt noch einmal und legt los. Sie klingt wie ein Bach, der noch nicht weiß, wohin.* `[#draft]`  <sub>stadt_lio_3</sub>
- **Lio:** Den Ton habe ich nicht verfehlt. Den hat's woandershin gezogen. `[#draft]`  <sub>stadt_lio_4</sub>
- **Lio:** Aber der Rest war gut, oder? Sag Ja. Oder klatsch. Ich bin da flexibel. `[#draft]`  <sub>stadt_lio_5</sub>
*wenn* `list.closed`
  *wenn* `city.concert_invited nicht`
    - *→ weiter bei* `lio_invite`

### S2-9 · `lio_again`

- **Lio:** Der Ton von vorhin ist übrigens noch unterwegs. Wenn du ihn siehst, sag ihm, wir fangen gleich an. `[#draft]`  <sub>stadt_lio_6</sub>
- **Lio:** Ich lege eine Pause ein. Das ist Teil des Stücks. Das Stück heißt »Pause«. `[#draft]`  <sub>stadt_lio_7</sub>
*wenn* `list.closed`
  *wenn* `city.concert_invited nicht`
    - *→ weiter bei* `lio_invite`

### S2-35 · `lio_invite`

> =============================================================================================================================
> S6: das Konzert (Akt IV, Segment S6; docs/akt4/REGIONSBRIEFE.md O3, O10). Der Abend selbst steht in konzert.dialogue; hier steht nur die Einladung. Sprünge aus S2 hierher: lio_street und
> lio_again springen am Ende zu lio_invite, wenn die Liste geschlossen ist (list.closed) und die Einladung nicht angenommen wurde (city.concert_invited); ohne diese Flags bleibt der
> Wortlaut von S2, Zeichen für Zeichen. Zeilen-IDs stadt_inv_*.
> =============================================================================================================================
> --- Die Einladung -----------------------------------------------------------------------------------------------------------------------------------
> Lio kennt die Liste nicht und fragt nicht nach ihr. Er lädt ein, wie er alles ankündigt: erst die Hauptsache, dann die Bühne, von der er nicht weiß, wer sie gebaut hat. Zwei Antworten, beide
> echt: "Ich komme." setzt city.concert_invited und rückt die Heldenquest von list auf evening (die Szene liest das Flag und blendet in den Abend über); "Später." setzt nichts, der Tag bleibt, und die
> Einladung steht beim nächsten Ansprechen wieder da.

- *Lio steht von seiner Kiste auf, die Laute an der Hüfte, und räuspert sich lange, als müsste er erst eine Rede finden.* `[#draft]`  <sub>stadt_inv_1</sub>
- **Lio:** Heute Abend. Auf dem Platz. Das schlechteste Konzert der Welt. `[#draft]`  <sub>stadt_inv_2</sub>
- **Lio:** Ich habe sogar eine Bühne. Ich weiß nur nicht, wer sie gebaut hat. Sie steht jedenfalls, das ist ein Anfang. `[#draft]`  <sub>stadt_inv_3</sub>
- ▸ **Ich komme.**
  - **Lio:** Gut! Dann fehlt nur noch alles andere. `[#draft]`  <sub>stadt_inv_4</sub>
  *wenn* `main_city_way und list`
- ▸ **Später.**
  - **Lio:** Später ist gut. Ich fange eh nie pünktlich an, nur zuverlässig. `[#draft]`  <sub>stadt_inv_5</sub>
