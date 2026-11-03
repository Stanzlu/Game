# G5 Loslassen (Akt V)

<!-- Erzeugt mit `python3 tools/writing/readable.py`. Nicht von Hand ändern: Änderungen gehören in die .dialogue-Dateien. -->

Lesefassung: der Text in der Reihenfolge, in der das Spiel ihn zeigt. *Kursiv* ist Erzählung, **fett** sprechen die Figuren, ▸ sind deine Antworten. Eingerückt steht, was nur unter einer Bedingung oder nach einer Antwort kommt. Hinter jeder Zeile die ID in klein.

**So antwortest du:** je Szene (E3, T12 …) „OK“, „ändern: …“ oder „raus“. Was du nicht nennst, gilt als OK.


## anlage


### G3-3 · `waechter`

> --- Der Wächter: der Zustand wählt -----------------------------------------------------------------------------------------
> Das erste Mal (und jedes Mal vor der Probe): er schreibt, sieht nicht auf und zählt die Spielerin ("Eins. Du."). Weil er jeden Besuch von vorn zählt, darf der Cue vor der Probe
> so oft gespielt werden, wie die Spielerin will: die Wiederholung gehört zu seinem Verfahren. Er stellt die Halle in Fakten vor (zwölf Hebel, drei in Betrieb, neun stehen), stellt
> eine Kontrollfrage und beantwortet sie selbst, und bietet die Probe an. Die Antworten sind kurz; das Schweigen "…" ist eine volle Antwort und die letzte. Wer die Probe nie
> verlangt, kommt nie in Not (kein Flag, kein Druck, kein Zähler). Wer sie gemacht hat (plant.probe_done), liest "waechter_again"; seit G4 liest, wer den Betrieb aufgenommen hat (plant.load),
> "waechter_run", und wer den Lauf bis zum Ende gespielt hat (plant.overload, die Szene setzt es), "waechter_over"; seit G5 liest, wer vom Pult weggetreten ist und gewartet hat (plant.letgo, die Szene setzt
> es am Ende des Loslassens), "waechter_done". Der Cue liest die Flags und setzt keines; der späteste Zustand steht oben.

*wenn* `plant.letgo`
  - *→ weiter bei* `waechter_done`
*wenn* `plant.overload`
  - *→ weiter bei* `waechter_over`
*wenn* `plant.load`
  - *→ weiter bei* `waechter_run`
*wenn* `plant.probe_done`
  - *→ weiter bei* `waechter_again`
*wenn* `plant.probe`
  - *→ weiter bei* `waechter_wait`
- *Am Pult steht ein älterer Mann im langen Arbeitsmantel, bis zum Kragen geschlossen, die Mütze genau gerade. Er schreibt auf ein Klemmbrett und sieht nicht auf.* `[#draft]`  <sub>anl_w_1</sub>
- **Wächter:** Eins. Du. `[#draft]`  <sub>anl_w_2</sub>
- *Der Stift setzt einen Strich aufs Klemmbrett. Erst dann hebt er den Kopf. Seine Stiefel stehen Spitze an Spitze.* `[#draft]`  <sub>anl_w_3</sub>
- **Wächter:** Ich zähle jeden Besuch neu. Dann stimmt die Zahl. `[#draft]`  <sub>anl_w_4</sub>
- **Wächter:** Zwölf Hebel. Drei in Betrieb, neun stehen. `[#draft]`  <sub>anl_w_5</sub>
- **Wächter:** Kontrollfrage. Hast du den Dampf gesehen? `[#draft]`  <sub>anl_w_6</sub>
- **Wächter:** Ich trage Ja ein. Er ist kaum zu übersehen. `[#draft]`  <sub>anl_w_7</sub>
- **Wächter:** Ich zeige dir die drei. Eine Probe, keine Frist. `[#draft]`  <sub>anl_w_8</sub>
- ▸ **Zeig mir die Hebel.**
  - *→ weiter bei* `probe_offer`
- ▸ **Ich schaue mich um.**
  - **Wächter:** Umsehen ist vorgesehen. Punkt Vier der Ordnung. `[#draft]`  <sub>anl_w_9</sub>
  - **Wächter:** Zwei Hinweise. Erstens, nichts anfassen, was dampft. Zweitens, siehe erstens. `[#draft]`  <sub>anl_w_10</sub>
- ▸ **…**
  - *Du schweigst. Der Wächter wartet und zählt dabei lautlos, die Lippen bewegen sich.* `[#draft]`  <sub>anl_w_11</sub>
  - **Wächter:** Schweigen ist zulässig. Ich gebe ihm eine Nummer. `[#draft]`  <sub>anl_w_12</sub>

### G3-16 · `waechter_over`

> Nach dem Ende der vierten Welle (plant.overload, die Szene setzt es nach "load_over"): der Lauf ruht. Er zählt die offenen Hebel, trägt es ein, verlangt nichts und bietet nichts an (kein "Fang an."
> mehr). Die letzte Zeile ist sein Vorbehalt, kein Dank und keine Einsicht; er bleibt bei dem, was er eingetragen hat. Seit G5 hängen daran drei Antworten (Bible §50 "Puzzlehilfen", Brief O4): die
> abrufbare Hilfe "Und jetzt?", ohne Umschweife und ohne Lehre (das Verfahren kennt für diesen Stand keinen Schritt, zulässig ist, das Pult nicht zu bedienen und abzuwarten, er hat nachgesehen und rät
> nicht dazu; kein Wort "loslassen", kein Wort darüber, was es bringt), das unbedingte "Gut." und das Schweigen "…" als letzte Antwort. Der Cue liest und setzt nichts.

- *Der Lauf ruht. Der Wächter fährt die Hebel ab, die oben stehen, und zählt halblaut.* `[#draft]`  <sub>anl_over_1</sub>
- **Wächter:** Offene Hebel gezählt, Zahl eingetragen. Nicht erfüllt, wie vermerkt. `[#draft]`  <sub>anl_over_2</sub>
- **Wächter:** Alles vorbehaltlich einer Nachprüfung der Rechnung. `[#draft]`  <sub>anl_over_3</sub>
- ▸ **Und jetzt?**
  - **Wächter:** Für diesen Stand kennt das Verfahren keinen Schritt. `[#draft]`  <sub>anl_over_4</sub>
  - **Wächter:** Zulässig ist, das Pult nicht zu bedienen und abzuwarten. Ich habe nachgesehen. `[#draft]`  <sub>anl_over_5</sub>
  - **Wächter:** Ich rate nicht dazu. `[#draft]`  <sub>anl_over_6</sub>
- ▸ **Gut.**
  - **Wächter:** Gut ist als Eintrag nicht vorgesehen. Ich schreibe: zur Kenntnis genommen. `[#draft]`  <sub>anl_over_7</sub>
- ▸ **…**
  - *Du schweigst. Der Wächter zählt die offenen Hebel noch einmal und kommt auf dieselbe Zahl.* `[#draft]`  <sub>anl_over_8</sub>

### G3-17 · `waechter_done`

> --- Nach dem Loslassen (G5) -------------------------------------------------------------------------------------------------
> Die Hebel stehen unten, die Zeiger im Normalbereich, eine Lampe ist dunkel geblieben (die Szene hat alles gespielt, loslassen.dialogue). Der Wächter ist nicht geheilt: er prüft, zählt, trägt ein,
> nennt den Fall einen Einzelfall und hält am Verfahren fest. Die Lampe erwähnt er in seiner Form ("Lampe Eins: defekt, unbehoben. Die Halle steht trotzdem. Ich habe es nachgeprüft."), nicht in
> der des Defekts ("letgo_defect"). Der Gag ist die Seite der Einzelfälle, auf der nur dieser eine steht, und die Erwartung, die trotzdem eingetragen bleibt. Kein Dank, kein Lob, keine Einsicht, keine Lehre,
> kein Wort darüber, was das Wegtreten bedeutet hat; er sagt nie "Kind", nie "Tür", nie etwas über sein Warum. Vier Antworten: das unbedingte "Es steht noch alles.", die Facette trust (eine Antwort, die
> nichts verlangt; seine Antwort ist, dass das Feld "Ohne Eintrag" vorgesehen ist und er es noch nie benutzt hat, mehr nicht: kein Fortschritt, keine Heilung, der Facette-Setzer ist die Szene), die
> Kartoffel (nur solange sie bei der Spielerin ist und nicht eingetragen wurde: plant.potato_taken setzt die Karte, plant.potato_entered der Cue "potato_entry") und das Schweigen "…" als letzte.
> Die erste Antwort und das Schweigen stehen immer da (jede Gruppe braucht eine unbedingte Antwort); die Antwort der Facette und die der Kartoffel verschwinden, wenn ihre Bedingung nicht zutrifft. Der Cue setzt nichts.

- *Alle zwölf Hebel stehen unten. Der Wächter tippt jeden einmal mit dem Stift an und bewegt dabei die Lippen.* `[#draft]`  <sub>anl_done_1</sub>
- **Wächter:** Alle unten geblieben. Der zweite Zeiger von links zittert wie vorher. Vermerkt. `[#draft]`  <sub>anl_done_2</sub>
- **Wächter:** Lampe Eins: defekt, unbehoben. Die Halle steht trotzdem. Ich habe es nachgeprüft. `[#draft]`  <sub>anl_done_3</sub>
- **Wächter:** Der Fall steht auf Seite neun, unter Einzelfälle. `[#draft]`  <sub>anl_done_4</sub>
- **Wächter:** Sonst steht dort nichts. Das passt zu einem Einzelfall. `[#draft]`  <sub>anl_done_5</sub>
- ▸ **Es steht noch alles.**
  - **Wächter:** Ja. Erwartet hatte ich etwas anderes. `[#draft]`  <sub>anl_done_6</sub>
  - **Wächter:** Die Erwartung bleibt trotzdem eingetragen. `[#draft]`  <sub>anl_done_7</sub>
- ▸ **Nichts einzutragen ist zulässig.** *(wenn `trust`)*
  - **Wächter:** Ja. Das Feld »Ohne Eintrag« ist vorgesehen. Ich habe es noch nie benutzt. `[#draft]`  <sub>anl_done_8</sub>
  - **Wächter:** Es steht auf jedem Blatt, unten rechts. `[#draft]`  <sub>anl_done_9</sub>
- ▸ **Die kam aus dem Rohr.** *(wenn `plant.potato_taken und plant.potato_entered nicht`)*
  - *→ weiter bei* `potato_entry`
- ▸ **…**
  - *Du schweigst. Der Wächter blättert zu Seite neun und liest den einen Eintrag noch einmal.* `[#draft]`  <sub>anl_done_10</sub>

### G3-18 · `potato_entry`

> Die Kartoffel (Bible §33, O13): bemerkenswert durchschnittlich, nichts wird erklärt, kein Warum, kein Symbol, kein Witz über ihn. Sie kommt aus einem Rohr, das für Dampf vorgesehen ist und für nichts
> sonst; er trägt sie in der Form seiner Spalten ein (durchschnittlich in allem, Besonderheiten keine, und das findet er bemerkenswert) und vermerkt, dass sie bei der Spielerin bleibt. Zuletzt setzt der Cue
> plant.potato_entered (die Szene schließt die Nebenquest "side_plant_potato" daraus); der Cue endet danach, er springt nicht zurück in "waechter_done".

- *Du holst die Kartoffel aus der Tasche und hältst sie ihm hin. Er betrachtet sie, ohne sie zu berühren.* `[#draft]`  <sub>anl_potato_1</sub>
- **Wächter:** Kartoffel. Mittelgroß. Nicht eingetragen. `[#draft]`  <sub>anl_potato_2</sub>
- **Wächter:** Aus dem Rohr links. Das Rohr ist für Dampf vorgesehen, nicht dafür. `[#draft]`  <sub>anl_potato_3</sub>
- *Er schlägt eine leere Seite auf und schreibt oben ein einziges Wort.* `[#draft]`  <sub>anl_potato_4</sub>
- **Wächter:** Größe durchschnittlich, Gewicht durchschnittlich, Farbe durchschnittlich. `[#draft]`  <sub>anl_potato_5</sub>
- **Wächter:** Besonderheiten: keine. Das ist bemerkenswert. `[#draft]`  <sub>anl_potato_6</sub>
- **Wächter:** Verbleib: bei dir. Eingetragen. `[#draft]`  <sub>anl_potato_7</sub>

## loslassen


### G5-1 · `letgo_away`

- **Wächter:** Pult unbesetzt. Alle zwölf Hebel stehen oben, keiner wird bedient. `[#draft]`  <sub>los_away_1</sub>
- **Wächter:** Ich trage es ein. Dauer der Pause: laufend. `[#draft]`  <sub>los_away_2</sub>

### G5-2 · `letgo_first`

> --- Der erste Hebel ---------------------------------------------------------------------------------------------------------
> Hebel Drei fällt von selbst, mit dem Klacken, das danach ein Takt wird. Er sagt die Zeile aus der Probe ("Das war nicht eingeplant. Ich trage es ein.", anl_right_2, O13) und trägt in die
> Spalte, wer den Hebel gezogen hat, niemand ein. Kein Staunen, kein Ausruf; der Gag ist die Spalte.

- *Hebel Drei fällt mit einem Klacken. Niemand hat ihn berührt.* `[#draft]`  <sub>los_first_1</sub>
- **Wächter:** Das war nicht eingeplant. Ich trage es ein. `[#draft]`  <sub>los_first_2</sub>
- **Wächter:** Spalte »Gezogen von«: leer. Ich schreibe: niemand. `[#draft]`  <sub>los_first_3</sub>

### G5-3 · `letgo_mid`

> --- Mitten drin -------------------------------------------------------------------------------------------------------------
> Etwas geht schief: ein Stoß Dampf aus dem zischenden Rohr, ein Zeiger am Rand. Seine Hand liegt über einem Hebel und zieht nicht. Der Text kennt die Nummer des Hebels nicht (er ist statisch)
> und sagt kein Wort über Gefahr; er nennt, was das Verfahren hier verlangt, und trägt ein, dass er es nicht tut. Die letzte Zeile ist die Probezeile des Blatts, trocken und ohne Erklärung, was
> ihn zurückhält.

- *Aus dem Rohr links bricht ein Stoß Dampf, weiß und dicht. Ein Zeiger springt an den Rand und bleibt dort stehen.* `[#draft]`  <sub>los_mid_1</sub>
- *Die Hand des Wächters liegt über einem Hebel. Sie zieht nicht.* `[#draft]`  <sub>los_mid_2</sub>
- **Wächter:** Zeiger am Rand. Das Verfahren verlangt jetzt einen Zug. `[#draft]`  <sub>los_mid_3</sub>
- **Wächter:** Ich ziehe nicht. Ich trage ein, dass ich nicht ziehe. `[#draft]`  <sub>los_mid_4</sub>
- **Wächter:** Der Dampf kam von allein. Ich schaue nur hin. `[#draft]`  <sub>los_mid_5</sub>

### G5-4 · `letgo_defect`

> --- Der Defekt --------------------------------------------------------------------------------------------------------------
> Eine Lampe fällt aus, die linke am Träger, und bleibt dunkel (Defekt, den niemand repariert). Das Verfahren verlangt die Behebung; er trägt "Defekt. Offen." ein und behebt nichts, und niemand
> sonst tut es. Die Halle steht trotzdem: das sagt die Erzählung, nicht er (sein Satz dazu steht in anlage.dialogue, "waechter_done").

- *Die linke Lampe am Träger geht aus. Sie flackert nicht, sie ist einfach aus.* `[#draft]`  <sub>los_defect_1</sub>
- **Wächter:** Lampe Eins. Defekt. Das Verfahren verlangt Behebung. `[#draft]`  <sub>los_defect_2</sub>
- **Wächter:** Ich trage ein: Defekt. Offen. `[#draft]`  <sub>los_defect_3</sub>
- *Unter dem Träger wird es dämmrig, mehr nicht. Niemand geht zur Lampe, und die Hebel fallen weiter, im selben Abstand.* `[#draft]`  <sub>los_defect_4</sub>

### G5-5 · `letgo_end`

> --- Das Ende ----------------------------------------------------------------------------------------------------------------
> Der letzte Hebel fällt, die Zeiger gehen zurück, der Dampf wird dünn. Er trägt alles ein und bleibt skeptisch: alle Hebel unten, alle Anzeigen normal, die Last wurde nicht gehalten, das ist kein
> zulässiger Zustand (er trägt ihn trotzdem ein, die Form von "Das Verfahren verlangt es trotzdem", lst_over_9). Das Ergebnis ist ihm ein Einzelfall, das Verfahren bleibt richtig, und "Alles
> vorbehaltlich einer Nachprüfung" (anl_over_3) kommt nicht noch einmal. Der Hauch: sein Blatt hat unten rechts ein Feld "Ohne Eintrag", das er auslässt wie jedes Mal, nicht anders als sonst. Kein Dank,
> kein Trost, keine Einsicht, kein Satz darüber, was die Zeiger oder die Lampe bedeuten. Die letzte Zeile ist ein Vorbehalt.

- *Der letzte Hebel fällt. Die Zeiger gehen zurück, der Dampf wird dünn, und nur das Rohr links zischt wie zuvor.* `[#draft]`  <sub>los_end_1</sub>
- **Wächter:** Alle Hebel unten. Alle Anzeigen im Normalbereich. `[#draft]`  <sub>los_end_2</sub>
- **Wächter:** Die Last wurde nicht gehalten. Das ist kein zulässiger Zustand. `[#draft]`  <sub>los_end_3</sub>
- *Er füllt die Spalten aus, eine nach der anderen. Das Feld unten rechts, »Ohne Eintrag«, lässt er aus, wie jedes Mal.* `[#draft]`  <sub>los_end_4</sub>
- **Wächter:** Ich trage ihn trotzdem ein. Als Einzelfall. `[#draft]`  <sub>los_end_5</sub>
- *Der Stift kratzt, genau einmal.* `[#draft]`  <sub>los_end_6</sub>
- **Wächter:** Das Verfahren ist richtig. Dieser Fall ändert daran nichts. `[#draft]`  <sub>los_end_7</sub>
- **Wächter:** Wiederholt er sich, prüfe ich neu. Bis dahin gilt das Verfahren. `[#draft]`  <sub>los_end_8</sub>

### G5-6 · `letgo_potato`

> --- Die Kartoffel -----------------------------------------------------------------------------------------------------------
> Nach dem Ende, ohne ein Wort von ihm: etwas rollt aus dem zischenden Rohr links und bleibt liegen. Mehr nicht, kein Kommentar, keine Deutung (Bible §33, O13). Der Wächter sieht nicht hin; wer die
> Kartoffel aufhebt (die Karte setzt "plant.potato_taken"), kann sie ihm zeigen ("waechter_done", "potato_entry" in anlage.dialogue).

- *Aus dem zischenden Rohr links poltert etwas heraus, rollt ein Stück über den Boden und bleibt liegen.* `[#draft]`  <sub>los_potato_1</sub>
- *Eine Kartoffel.* `[#draft]`  <sub>los_potato_2</sub>
