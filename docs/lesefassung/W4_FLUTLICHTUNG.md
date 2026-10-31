# W4 Flutlichtung (Akt III)

<!-- Erzeugt mit `python3 tools/writing/readable.py`. Nicht von Hand ändern: Änderungen gehören in die .dialogue-Dateien. -->

Lesefassung: der Text in der Reihenfolge, in der das Spiel ihn zeigt. *Kursiv* ist Erzählung, **fett** sprechen die Figuren, ▸ sind deine Antworten. Eingerückt steht, was nur unter einer Bedingung oder nach einer Antwort kommt. Hinter jeder Zeile die ID in klein.

**So antwortest du:** je Szene (E3, T12 …) „OK“, „ändern: …“ oder „raus“. Was du nicht nennst, gilt als OK.


## flutlichtung


### W4-1 · `flood_trail`

- *Im trockenen Schlick sind Abdrücke eines einzelnen Läufers, links, rechts, links, jeder ein Ballen mit der Ferse dahinter.* `[#draft]`  <sub>fl_trail_1</sub>
- *Der Schritt ist lang. Hinter jedem Abdruck ist Schlick nach hinten geworfen. Hier ist gerannt worden.* `[#draft]`  <sub>fl_trail_2</sub>
- *Sie laufen nach Norden, den Weg zurück, den du gekommen bist.* `[#draft]`  <sub>fl_trail_3</sub>
- *Die ersten sind tief, die nächsten flacher, die letzten kaum noch da.* `[#draft]`  <sub>fl_trail_4</sub>

### W4-2 · `flood_camp`

> --- Das Lager: Ring, Kessel, Decke -----------------------------------------------------------------------------------------
> Decor tal/wd_flood_ring und daneben tal/wd_flood_blanket (ohne eigenen Cue): ein Feuerring aus Steinen (zwei davon weit abseits) mit
> getrocknetem, in Platten gerissenem Schlick statt Asche; vom Dreibein zwei Stäbe schief, am Kreuz ein leerer Haken, der dritte quer;
> der Kessel auf der Seite, halb im Schlick, der Deckel daneben; an einem Pfahl eine steife Decke, unterhalb der Schlickkante voll Schlick,
> darüber noch hell; am Saum ein einziger roter Strich. Eine Decke, ein Ring, ein Kessel.

- *Ein Feuerring aus Steinen, bis zum Rand voll Schlick. Der ist trocken und in Platten gerissen.* `[#draft]`  <sub>fl_camp_1</sub>
- *Vom Dreibein stehen zwei Stäbe schief, der dritte liegt quer, am Haken hängt nichts. Der Kessel liegt auf der Seite, der Deckel daneben.* `[#draft]`  <sub>fl_camp_2</sub>
- *An einem Pfahl hängt eine Decke. Sie ist bis zur Höhe des Schlicks an den Stämmen steif, darüber noch hell.* `[#draft]`  <sub>fl_camp_3</sub>
- *Am Saum läuft ein einziger Strich in roter Kreide, gerade, mit dem Lineal gezogen.* `[#draft]`  <sub>fl_camp_4</sub>

### W4-3 · `flood_mark`

> --- Die Marke: der bleiche Stamm ------------------------------------------------------------------------------------------
> Decor tal/wd_flood_mark: ein Stamm ohne Krone, bleich, oben in drei Zacken abgebrochen, ein Aststumpf, von der Wurzel bis zur Linie
> Schlick mit heller Kruste oben und darin ein einziger waagerechter Schnitt mit hellem Span darunter; die Buchen um die Lichtung
> tragen den Schlick bis zu derselben Höhe (tal/wd_flood_beech). Die Linie liegt über dem Kopf der Spielerin. Keine Zahl, kein Datum,
> kein Brett (alles andere hat der Antreiber beschriftet). Am Ende, nach den Zeilen, setzt der Cue forest.flood_seen: die Szene liest
> es und erfüllt das Ziel der Heldenquest.

*wenn* `forest.flood_seen`
  - *Der bleiche Stamm, die Kruste über deinem Kopf, der eine Schnitt.* `[#draft]`  <sub>fl_mark_6</sub>
  - *→ Ende des Szenenstücks*
- *Der Stamm ist bleich, hat keine Krone und bricht oben in Zacken ab.* `[#draft]`  <sub>fl_mark_1</sub>
- *Von der Wurzel bis über deinen Kopf klebt Schlick an ihm, oben mit einer hellen Kruste.* `[#draft]`  <sub>fl_mark_2</sub>
- *An jeder Buche um die Lichtung endet der Schlick auf derselben Höhe.* `[#draft]`  <sub>fl_mark_3</sub>
- *In der Kruste sitzt ein einziger Schnitt, waagerecht, darunter ein heller Span. Daneben hängt kein Brett.* `[#draft]`  <sub>fl_mark_4</sub>
- *Mit ausgestrecktem Arm kommst du nicht an die Kruste.* `[#draft]`  <sub>fl_mark_5</sub>

### W4-4 · `antreiber_flood`

> --- Der Antreiber an der Marke ---------------------------------------------------------------------------------------------
> Er steht an der Marke und misst, sofern er nicht am Feuer im Haus sitzt (Karte: Figur A); mit Tee sitzt er auf dem Boden gleich
> daneben (Figur E, es gibt dort keinen Stumpf). Er sagt, was er tut, nie, was es bedeutet: kein Wort über Wasser, Menschen oder
> Gründe, kein Wort über die Spielerin, kein Ausruf. Seine Füße gehen auf der Stelle, auf den Ballen, wie die Abdrücke; sitzt er,
> stehen sie still. Die Antwort "Ich bleibe hier." und das Schweigen verändern nichts, was bleibt; nur der Tee (mit der Facette
> care) setzt ihn.

*wenn* `forest.flood_sat`
  - *→ weiter bei* `antreiber_flood_again`
- *Der Antreiber steht am bleichen Stamm und hält einen Zollstock daran, vom Boden bis hinauf zum Schnitt.* `[#draft]`  <sub>fl_antr_1</sub>
- **Antreiber:** Ich messe nur nach. Es stimmt noch. `[#draft]`  <sub>fl_antr_2</sub>
- *Seine Füße gehen auf der Stelle, auf den Ballen, leise und gleichmäßig. Er sieht nicht hinunter.* `[#draft]`  <sub>fl_antr_3</sub>
- *→ weiter bei* `antreiber_flood_ask`

### W4-5 · `antreiber_flood_ask`

- ▸ **Setz dich. Es gibt Tee.** *(wenn `care und forest.flood_sat nicht`)*
  - *Du hältst ihm die Flasche hin. Er prüft erst den Boden mit der Schuhspitze, einmal und noch einmal.* `[#draft]`  <sub>fl_ask_1</sub>
  - **Antreiber:** Trocken. `[#draft]`  <sub>fl_ask_2</sub>
  - *Er setzt sich neben dem Stamm auf den Boden und nimmt die Flasche. Seine Füße stehen still.* `[#draft]`  <sub>fl_ask_3</sub>
- ▸ **Ich bleibe hier.**
  - *Er lässt den Zollstock sinken, bis er neben seinem Bein hängt.* `[#draft]`  <sub>fl_ask_4</sub>
- ▸ **…**
  - *Er nickt. Die Füße gehen weiter.* `[#draft]`  <sub>fl_ask_5</sub>

### W4-6 · `antreiber_flood_again`

> Er sitzt (forest.flood_sat): die Eröffnung wird nicht noch einmal gesagt, nur das, was schon da ist.

- *Er sitzt auf dem Boden, den Zollstock quer über den Knien. Seine Füße stehen still.* `[#draft]`  <sub>fl_again_1</sub>
- **Antreiber:** Der Boden hält. `[#draft]`  <sub>fl_again_2</sub>
- ▸ **Bleib sitzen.**
  - *Er bleibt, wo er ist. Der Zollstock liegt, wie er lag.* `[#draft]`  <sub>fl_again_3</sub>
- ▸ **…**
  - *Er nickt, ohne aufzusehen.* `[#draft]`  <sub>fl_again_4</sub>

### W4-7 · `south_wait`

> --- Der Südausgang (hält zurück, bis der Weg in die Nacht offen ist) ---------------------------------------------------------------------------------------
> Ein Blocker in der Lücke im Südrand: der Pfad geht dort zwischen die Kronen weiter, und noch ist es hell. Er hält zurück, solange forest.night_way fehlt (das
> setzen die Szenen, wenn die Heldenquest in night steht); dahinter liegt die Tür in den Nachtwald (W5). Der Cue bleibt für alle, die noch nicht so weit sind.

- *Im Süden geht der Pfad zwischen die Kronen, schmal und im Schatten.* `[#draft]`  <sub>fl_south_1</sub>
- *Es ist noch hell genug, um umzukehren.* `[#draft]`  <sub>fl_south_2</sub>

### W4-8 · `nest`

> --- Nebenquest B: das Nest (Natur, leise, ohne Uhr) --------------------------------------------------------------------------
> Ein leeres Nest im Gras am Westrand der Lichtung (Decor tal/wd_nest, "unless forest.nest_taken"): geflochten aus trockenen Halmen,
> ein paar Enden stehen ab, unten wächst grünes Moos daran, die Mulde ist dunkel und leer. Eine Astgabel am Ufer (ein grauer Ast, der
> aufrecht aus dem Boden steht, unten bemoost, oben zu einer weiten Gabel gespalten: tal/wd_fork, mit dem Nest darin
> tal/wd_fork_nest nach forest.nest_placed). Aufheben und Hinlegen sind Antworten, nie eine Pflicht; wer das Nest liegen lässt, verpasst
> nichts. Der Cue nest startet die Quest, der Cue fork schließt sie.

- *Im Gras liegt ein Nest aus trockenen Halmen, einzelne Enden stehen ab. Unten wächst Moos daran, noch grün. In der Mulde liegt nichts.* `[#draft]`  <sub>fl_nest_1</sub>
- ▸ **Aufheben.**
  - *Du hebst es auf. Es wiegt fast nichts und behält in deinen Händen seine Form.* `[#draft]`  <sub>fl_nest_2</sub>
- ▸ **Liegen lassen.**
  - *Du lässt es im Gras liegen. Das Moos bleibt noch eine Weile grün.* `[#draft]`  <sub>fl_nest_3</sub>
- ▸ **…**
  - *Du beugst dich darüber. Es riecht nach Moos und nach nichts sonst.* `[#draft]`  <sub>fl_nest_4</sub>

### W4-9 · `fork`

*wenn* `forest.nest_placed`
  - *Das Nest liegt in der Gabel, als wäre es immer dort gewesen.* `[#draft]`  <sub>fl_fork_5</sub>
  - *→ Ende des Szenenstücks*
- *Am Ufer steht ein Ast aufrecht im Boden, grau vom Wetter, unten bemoost, oben zu einer weiten Gabel gespalten.* `[#draft]`  <sub>fl_fork_1</sub>
*wenn* `forest.nest_taken`
  - *→ weiter bei* `fork_nest`

### W4-10 · `fork_nest`

- ▸ **Das Nest in die Gabel legen.**
  - *Du legst es in die Gabel und nimmst die Hände weg. Es rutscht nicht und kippt nicht, es bleibt.* `[#draft]`  <sub>fl_fork_2</sub>
- ▸ **Noch nicht.**
  - *Du behältst es in der Hand. Der Ast bleibt, wie er ist.* `[#draft]`  <sub>fl_fork_3</sub>
- ▸ **…**
  - *Du siehst auf das Wasser neben dem Ast. Es zieht langsam und klar vorbei.* `[#draft]`  <sub>fl_fork_4</sub>

### W4-11 · `driftwood`

> --- Kuriosität: das Treibholz ---------------------------------------------------------------------------------------------
> Decor tal/wd_driftwood am Ufer ("unless forest.driftwood_taken"): silbergrau, vom Wasser glatt geschliffen, ein kurzer Seitenast, ein
> Knoten mit Ringen, das eine Ende heller, dort ist es gebrochen.

- *Am Ufer liegt ein Stück Treibholz, silbergrau, vom Wasser glatt geschliffen.* `[#draft]`  <sub>fl_drift_1</sub>
- *Es hat einen kurzen Seitenast und, nicht weit davon, einen Knoten mit Ringen. Das eine Ende ist heller, dort ist es gebrochen.* `[#draft]`  <sub>fl_drift_2</sub>
- ▸ **Einstecken.**
  - *Du steckst es ein. Es ist leichter, als es aussieht, und trocken bis in die Mitte.* `[#draft]`  <sub>fl_drift_3</sub>
- ▸ **Liegen lassen.**
  - *Du lässt es am Ufer liegen, wo das Wasser es abgesetzt hat.* `[#draft]`  <sub>fl_drift_4</sub>
- ▸ **…**
  - *Du streichst mit der flachen Hand über das Holz. Es ist glatt, und die Maserung läuft in eine Richtung.* `[#draft]`  <sub>fl_drift_5</sub>

### W4-12 · `stones`

> --- Fragment: die Trittsteine (eine Spur der Welt, kein Bild des Kindes, nicht die Marke) --------------------------------------
> Decor tal/wd_stones, flach, im Bach: vier flache Steine quer durch das Wasser, einer hinter dem anderen, jeder eine Schrittlänge vom
> nächsten, auf dem dritten schon Moos, das Wasser teilt sich um sie. Sie sind nicht gefallen, jemand hat sie getragen und gelegt, und sie
> tragen noch. Das Fragment steht zuletzt; danach nur eine kurze Zeile.

*wenn* `fragment.stepping_stones`
  - *Die flachen Steine quer durch den Bach, einer hinter dem anderen.* `[#draft]`  <sub>fl_stones_5</sub>
  - *→ Ende des Szenenstücks*
- *Quer durch den Bach liegen flache Steine, einer hinter dem anderen, jeder eine Schrittlänge vom nächsten.* `[#draft]`  <sub>fl_stones_1</sub>
- *Gefallen sind sie nicht. Jemand hat sie hergetragen und einzeln gelegt, und auf dem dritten wächst schon Moos.* `[#draft]`  <sub>fl_stones_2</sub>
- *Du setzt einen Fuß auf den ersten. Er wackelt nicht, und das Wasser teilt sich um ihn. Sie tragen noch.* `[#draft]`  <sub>fl_stones_3</sub>
