# R10 Sammelstücke (Akt VI)

<!-- Erzeugt mit `python3 tools/writing/readable.py`. Nicht von Hand ändern: Änderungen gehören in die .dialogue-Dateien. -->

Lesefassung: der Text in der Reihenfolge, in der das Spiel ihn zeigt. *Kursiv* ist Erzählung, **fett** sprechen die Figuren, ▸ sind deine Antworten. Eingerückt steht, was nur unter einer Bedingung oder nach einer Antwort kommt. Hinter jeder Zeile die ID in klein.

**So antwortest du:** je Szene (E3, T12 …) „OK“, „ändern: …“ oder „raus“. Was du nicht nennst, gilt als OK.


## sammlung


### R10-1 · `guestbook_back`

- *Das Gästebuch liegt auf seinem Pult, aufgeschlagen.* `[#draft]`  <sub>sam_book_1</sub>
*wenn* `elysia.pencil_taken`
  - *An der Schnur hängt nur noch ein loser Knoten, und das Buch sieht davon nicht ärmer aus.* `[#draft]`  <sub>sam_book_4</sub>
*sonst*
  - *An seiner Schnur hängt der Stift, bis auf einen Stummel heruntergeschrieben. Die Schnur dagegen ist so lang wie am ersten Tag.* `[#draft]`  <sub>sam_book_2</sub>
- ▸ **Den Stummel abbinden.** *(wenn `elysia.pencil_taken nicht`)*
  - *Der Knoten ist locker, als hätte ihn nie jemand fest gezogen. Der Stummel liegt in deiner Hand, mit einem Stück Schnur am Ende.* `[#draft]`  <sub>sam_book_3</sub>
- ▸ **Im Buch blättern.**
  - *Auf jeder Seite steht dein Name, und jedes Mal ist er genau gleich geschrieben.* `[#draft]`  <sub>sam_book_5</sub>

### R10-2 · `fountain_back`

> --- Der Brunnen auf dem Markt: die Münze vom Grund ---------------------------------------------------------------------------------
> Er ersetzt die Beschreibung von Akt I (mk_fountain_1) für den, der zurück ist, und behält ihre Münze für zehn Gold (andere Worte, derselbe Handel). Auf dem Grund liegen Münzen wie am ersten Tag; eine herauszufischen ist die Kuriosität.

- *Der Brunnen plätschert, und auf seinem Grund liegen Münzen, golden und frisch, als wäre jede erst vor einem Atemzug hineingefallen.* `[#draft]`  <sub>sam_fountain_1</sub>
- *Keine liegt schief, und keine liegt auf einer anderen.* `[#draft]`  <sub>sam_fountain_2</sub>
- ▸ **Eine Münze vom Grund fischen.** *(wenn `elysia.coin_taken nicht`)*
  - *Du angelst eine heraus. Sie ist glatt und kühl vom Wasser, und wo ein Wappen sein sollte, ist nichts.* `[#draft]`  <sub>sam_fountain_3</sub>
  - *Im Wasser schließt sich die Lücke so gleichmäßig, dass du nicht mehr weißt, welche fehlt.* `[#draft]`  <sub>sam_fountain_4</sub>
- ▸ **Eine Münze hineinwerfen, zehn Gold.** *(wenn `gold() >= 10`)*
  - *Die Münze sinkt und legt sich neben die anderen, ohne einen Fingerbreit zu rutschen.* `[#draft]`  <sub>sam_fountain_5</sub>
- ▸ **Weitergehen.**

### R10-3 · `pillar_back`

> --- Die Säule: der Schatten, der nicht rückt ---------------------------------------------------------------------------------------
> Spur der Welt, Schleife. Elysia ist makellos (Bible §8), und der Schatten der Säule liegt, wo er immer liegt. Keine Figur, keine Uhr, kein Satz darüber, was das heißt. Er ersetzt die eine Beschreibung von Akt I (el_pillar_1), die nichts trägt.

- *Die Säule ist makellos, an keiner Kante bestoßen, an keiner Stelle abgerieben.* `[#draft]`  <sub>sam_pillar_1</sub>
- *Ihr Schatten liegt ihr zu Füßen und reicht bis an dieselbe Fuge im Pflaster, an die er immer reicht.* `[#draft]`  <sub>sam_pillar_2</sub>
- *Du siehst eine Weile zu. Der Schatten rückt keinen Fingerbreit.* `[#draft]`  <sub>sam_pillar_3</sub>

### R10-4 · `table_look`

> --- Der Tisch im Gasthaus: die Ringe ----------------------------------------------------------------------------------------------
> Spur der Welt, der Tisch (R5). Der Tisch in der Mitte steht seit R5 für alle, die zurück sind; unter dem Gedeck sind die Ringe von Bechern geblieben, einer auf dem anderen. Nichts sagt, wer die Becher hinstellte und warum immer dorthin.

- *Der Tisch ist gedeckt, und unter dem Gedeck sind die Ringe von Bechern geblieben, dicht an dicht.* `[#draft]`  <sub>sam_table_1</sub>
- *Jeder Ring liegt genau auf dem vorigen, auf das Haar.* `[#draft]`  <sub>sam_table_2</sub>

## garten


### R3-7 · `basin_back`

> --- Das Becken ----------------------------------------------------------------------------------------------------------------
> Die Gärtnerin hat nichts mehr zu bitten; niemand sagt der Spielerin, was sie am Wasser tun soll. Die Erzählung zeigt das Becken, das Wasser und die Hand: der Rand ist gerade so hoch, dass die Hand von allein hineinfindet. Zwei
> unbedingte Antworten, jede mit eigenen Zeilen (keine Fake Choice, kein Schweigen nötig): Wasser spritzen (basin_play) oder Zusehen (zwei Zeilen: dasselbe Wasser, dasselbe Blütenblatt); dazwischen, solange er am Grund liegt, der Kiesel (R10, eine Kuriosität: nehmen ist nicht spielen). Weder Gesten noch Orte werden bewertet.

- *Das Becken plätschert, und niemand fragt dich, ob es zu leise ist.* `[#draft]`  <sub>gar_basin_1</sub>
- *Das Wasser steht klar bis knapp unter den Rand, und ein Blütenblatt dreht darauf seine Runde.* `[#draft]`  <sub>gar_basin_2</sub>
- *Der Rand ist breit und glatt und gerade so hoch, dass die Hand von allein ins Wasser findet.* `[#draft]`  <sub>gar_basin_3</sub>
- ▸ **Wasser spritzen.**
  - *→ weiter bei* `basin_play`
- ▸ **Einen Kiesel vom Grund holen.** *(wenn `elysia.pebble_taken nicht`)*
  - *Du krempelst den Ärmel hoch und greifst bis zum Grund. Dort liegen Kiesel, alle gleich rund und gleich grau.* `[#draft]`  <sub>gar_basin_6</sub>
  - *Du nimmst einen. Er ist kühl und liegt gut in der Hand, und die Lücke am Grund schließt sich, ohne dass einer rutscht.* `[#draft]`  <sub>gar_basin_7</sub>
- ▸ **Zusehen.**
  - *Das Wasser plätschert und plätschert, und es ist dasselbe Wasser.* `[#draft]`  <sub>gar_basin_4</sub>
  - *Das Blütenblatt kommt an, wo es losgefahren ist, und fährt los.* `[#draft]`  <sub>gar_basin_5</sub>

## leere


### R1-4 · `camp_empty`

> --- Das alte Lager danach -------------------------------------------------------------------------------------------------------
> Ein Ding am Lager (Decor mit Cue, freiwillig, jedes Mal von vorn), ohne Zeitangabe, damit es am selben Tag und später gilt. Nur was zu sehen ist: die Plane an ihren Pflöcken, eine Kuhle im Gras, der Ring aus schwarzer Erde, das
> Gestell des Netzes, der Geruch. Kein Kommentar zu Mira, kein Wort für das Fehlen.

- *Die Plane hängt noch an ihren Pflöcken, und darunter ist Platz für genau eine.* `[#draft]`  <sub>lee_camp_1</sub>
- *Im Gras ist eine Kuhle vom Liegen, das Gras darin etwas niedriger als ringsum.* `[#draft]`  <sub>lee_camp_2</sub>
- *Der Ring aus schwarzer Erde ist kalt, und über dem Gestell für das Netz hängt noch der Geruch von altem Rauch.* `[#draft]`  <sub>lee_camp_3</sub>
