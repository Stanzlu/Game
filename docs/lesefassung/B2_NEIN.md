# B2: Nein und Blick

<!-- Erzeugt mit `python3 tools/writing/readable.py`. Nicht von Hand ändern: Änderungen gehören in die .dialogue-Dateien. -->

Lesefassung: der Text in der Reihenfolge, in der das Spiel ihn zeigt. *Kursiv* ist Erzählung, **fett** sprechen die Figuren, ▸ sind deine Antworten. Eingerückt steht, was nur unter einer Bedingung oder nach einer Antwort kommt. Hinter jeder Zeile die ID in klein.

**So antwortest du:** je Szene (E3, T12 …) „OK“, „ändern: …“ oder „raus“. Was du nicht nennst, gilt als OK.


## nein


### N1 · `antreiber_ask`

- ▸ **Heute nicht.**
  - **Antreiber:** Heute nicht. `[#draft]`  <sub>nein_antr_1</sub>
  - *Er hebt einen Finger, für ein Zweitens. Es kommt keins.* `[#draft]`  <sub>nein_antr_2</sub>
- ▸ **Morgen.**
  - **Antreiber:** Morgen. Das ist ein Termin. `[#draft]`  <sub>nein_antr_3</sub>
  - *Er geht zur Tür, um nachzusehen, ob das Dach noch da ist.* `[#draft]`  <sub>nein_antr_4</sub>
- ▸ **…**
  - *Der Antreiber wartet. Er zählt etwas an den Fingern ab.* `[#draft]`  <sub>nein_antr_5</sub>

## haus


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
*wenn* `perception`
  - *Die Decke ist aus Quadraten genäht. Eins davon ist neuer als die anderen, der Faden dicker.*  <sub>haus_bed_6</sub>

### H14 · `antreiber_rest`

*wenn* `house.cat_fed`
  - *→ weiter bei* `cat_antreiber`
- *Der Antreiber sitzt am Feuer und sieht aus, als würde er gleich aufspringen. Er springt nicht.*  <sub>haus_antr_8</sub>
- **Antreiber:** Ich sitz nur kurz.  <sub>haus_antr_9</sub>
- **Antreiber:** Das Dach hat Zeit. Steht auf der Liste. Ganz unten. *(wenn `house.antreiber_refused`)*  <sub>haus_antr_10</sub>
- *Der Antreiber sitzt am Feuer und zählt nichts mehr an den Fingern.* *(wenn `house.antreiber_refused`)*  <sub>haus_antr_11</sub>

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
- ▸ **Das sag ich nicht.** *(wenn `boundaries`)*
  - **Mira:** Dann kommst du von hier.  <sub>haus_mira_39</sub>
  - **Mira:** Das spart Weg.  <sub>haus_mira_40</sub>
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
- **Mira:** Dein Kamin zieht schlecht.  <sub>haus_mira_41</sub>
- *Der Rauch steigt gerade nach oben. Sie wedelt ihn trotzdem weg.*  <sub>haus_mira_42</sub>
- **Mira:** Meiner raucht nie.  <sub>haus_mira_43</sub>
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

### H19 · `haus_prints`

> Nur wer genau hinsieht, findet diese Stelle (die Szene setzt house.looks_closely aus der Facette Wahrnehmung).

*wenn* `house.prints_seen`
  - *Die Abdrücke im Staub laufen noch ans Fenster und zurück.*  <sub>haus_prints_3</sub>
*sonst*
  - *Im Staub auf den Dielen sind Abdrücke. Klein, rund, vier Zehen.*  <sub>haus_prints_1</sub>
  - *Sie laufen ans Fenster und wieder zurück, mehrmals.*  <sub>haus_prints_2</sub>

## tal


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
- ▸ **Heute nicht mehr.** *(wenn `boundaries`)*
  - *Mira zieht das Netz näher ans Feuer. Das nasse Garn dampft.*  <sub>tal_eve_day_13</sub>
- ▸ **…**
  - *Mira schweigt eine Weile mit. Dann erzählt sie selbst.*  <sub>tal_eve_day_10</sub>
  - **Mira:** Ich hab heute zwei Löcher im Netz geflickt. Und ein neues gefunden.  <sub>tal_eve_day_11</sub>
  - **Mira:** Das ist ungefähr jeder Tag.  <sub>tal_eve_day_12</sub>

### T9 · `evening_elysia`

*wenn* `mira und kept_origin`
  - *Mira schaut ins Feuer. Nach Elysia fragt sie nicht.*  <sub>tal_eve_ely_12</sub>
  - *→ Ende des Szenenstücks*
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
