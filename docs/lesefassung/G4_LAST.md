# G4 Last (Akt V)

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

### G3-6 · `waechter_again`

> --- Nach der Probe ----------------------------------------------------------------------------------------------------------
> Er zählt weiter und trägt etwas ein; er lobt nicht, er kündigt nichts an und er erklärt nichts. Der Gag ist das Eintragen des Eintragens (er hat nachgesehen, es ist nicht
> nötig) und die Schrauben, die jedes Mal gleich viele sind: das ist der Sinn von Schrauben. Kein Wort über die anderen Hebel.
> Seit G4 hängen an den vier Zeilen drei Antworten: "Fang an." springt in "load_offer" (nur solange plant.load fehlt; der Zustand "waechter" schickt Spieler mit Betrieb ohnehin nach "waechter_run"),
> "Noch nicht." kostet nichts und bekommt einen trockenen Satz (der Gag: er legt eine Rubrik an), das Schweigen "…" ist die letzte Antwort. Der Betrieb ist nie Voraussetzung: wer nie "Fang an." sagt,
> bleibt bei diesen Zeilen und kommt an ihm vorbei wie jeder. Kein Lob für die Probe, keine Ankündigung der Last, kein Wort über die anderen Hebel.

- *Der Wächter steht am Pult, den Stift in der Faust. Auf seinem Blatt ist eine Zeile dazugekommen, kleiner geschrieben als die anderen.* `[#draft]`  <sub>anl_again_1</sub>
- **Wächter:** Rubrik Unvorhergesehenes, für Dinge, die nicht passieren. Heute ein Eintrag. `[#draft]`  <sub>anl_again_2</sub>
- **Wächter:** Muss ich das Eintragen auch eintragen? Nein. Ich habe nachgesehen. `[#draft]`  <sub>anl_again_3</sub>
- **Wächter:** Die Schrauben sind gleich viele wie vorhin. Das ist der Sinn von Schrauben. `[#draft]`  <sub>anl_again_4</sub>
- ▸ **Fang an.**
  - *→ weiter bei* `load_offer`
- ▸ **Noch nicht.**
  - **Wächter:** Noch nicht. Dafür gibt es keine Rubrik. Ich lege eine an. `[#draft]`  <sub>anl_again_5</sub>
- ▸ **…**
  - **Wächter:** Schweigen. Nummer vergeben. Es waren noch welche frei. `[#draft]`  <sub>anl_again_6</sub>

### G3-14 · `load_offer`

> --- Der Betrieb (G4, Die Last) ----------------------------------------------------------------------------------------------
> Die drei Cues, in die der Wächter springt, liegen hier, weil ihre Aufrufer ("waechter", "waechter_again") hier liegen; was die Szene während des Laufs spielt (die Wellen, die Pause, das Ende
> der vierten Welle), steht in last.dialogue. Er spricht wie in G3: kurz, zählend, trocken; er trägt ein, er lobt nicht, er tröstet nicht, er sagt nie "Kind", nie "Tür", nie etwas über sein
> Warum und nie etwas über die Spielerin als Person. Der Humor ist Pedanterie (Pausen, die er einträgt, Rubriken, Zahlen), nie seine Angst. Hebelnummern sind Wörter.
> Das Angebot: "Fang an." nach der Probe. Er stellt den Betrieb als Verfahren vor (oben verlangt, unten erledigt; nach einer Frist steht der Hebel wieder oben), nennt die Pausenregel und kündigt
> vier Stufen an, ohne zu sagen, wohin sie führen. Die Pausenregel ist hier ein Verfahren, keine Hilfe. plant.load steht zuletzt (nach der letzten Zeile): die Szene startet daraus den Lauf mit
> den drei Hebeln der Probe. Kein Wort über Zeitdruck oder Folgen.

- *Er schlägt auf dem Klemmbrett ein neues Blatt auf, schreibt »Betrieb« darüber und unterstreicht es zweimal.* `[#draft]`  <sub>anl_load_1</sub>
- **Wächter:** Jeder Hebel, der oben steht, verlangt Bedienung. Unten ist erledigt. `[#draft]`  <sub>anl_load_2</sub>
- **Wächter:** Nach einer Frist steht er wieder oben. Dann ziehst du ihn wieder herunter. `[#draft]`  <sub>anl_load_3</sub>
- **Wächter:** Es kommen Hebel dazu, in vier Stufen. Ich rufe jede aus. `[#draft]`  <sub>anl_load_4</sub>
- **Wächter:** Wer das Pult verlässt, hält den Betrieb an. Ich trage die Pause ein. `[#draft]`  <sub>anl_load_5</sub>
- **Wächter:** Eins, Zwei, Drei in Betrieb. Beginn. `[#draft]`  <sub>anl_load_6</sub>

### G3-15 · `waechter_run`

> Während des Betriebs: wer ihn anspricht, bekommt keine zweite Vorstellung. "Weiter." ist die Antwort für den, der einfach weitermacht: er sagt seinen Satz, während er zählt, und der Text kommentiert nicht,
> dass es währenddessen schiefgeht. "Wie schaffe ich das?" ist die abrufbare Hilfe (Bible §50 "Puzzlehilfen", Brief O4), ohne Umschweife: zwölf Hebel sind für zwei Hände zu viele, er hat es berechnet, und vom
> Pult zu treten ist zulässig (die Form von "Nicht vorgesehen. Aber auch nicht verboten."). Keine Lehre, kein Wort dafür, was das Wegtreten bedeutet, keine Aufforderung: er rät nicht dazu und bleibt selbst
> am Pult. Das Schweigen "…" ist die letzte Antwort. Der Cue liest und setzt nichts.

- *Der Wächter zählt die Hebel mit dem Stift durch, eine Hand fest auf dem Pult.* `[#draft]`  <sub>anl_run_1</sub>
- **Wächter:** Betrieb. Oben ist offen, unten ist erledigt. Ich zähle mit. `[#draft]`  <sub>anl_run_2</sub>
- ▸ **Weiter.**
  - **Wächter:** Solange ich zähle, passiert nichts. `[#draft]`  <sub>anl_run_3</sub>
- ▸ **Wie schaffe ich das?**
  - **Wächter:** Zwölf Hebel sind für zwei Hände zu viele. Ich habe es berechnet. `[#draft]`  <sub>anl_run_4</sub>
  - **Wächter:** Vom Pult zu treten ist zulässig. Ich habe nachgesehen. `[#draft]`  <sub>anl_run_5</sub>
  - **Wächter:** Ich rate nicht dazu. Ich bleibe am Pult. `[#draft]`  <sub>anl_run_6</sub>
- ▸ **…**
  - *Du schweigst. Der Wächter macht einen Strich und zählt weiter.* `[#draft]`  <sub>anl_run_7</sub>

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

## last


### G4-1 · `wave_two`

- **Wächter:** Vier bis Sechs in Betrieb. Erst Sechs, dann Fünf, dann Vier. `[#draft]`  <sub>lst_wave2_1</sub>
- *Er zählt die Hebel mit dem Stift nach, einmal, und schreibt die Zahl daneben.* `[#draft]`  <sub>lst_wave2_2</sub>
- **Wächter:** Die Fristen sind kürzer. So steht es im Verfahren. `[#draft]`  <sub>lst_wave2_3</sub>

### G4-2 · `wave_three`

- **Wächter:** Sieben bis Neun in Betrieb. Erst Neun, dann Acht, dann Sieben. `[#draft]`  <sub>lst_wave3_1</sub>
- *Er zählt nach, zweimal, und schreibt die Zahl erst hin, als sie beide Male dieselbe ist.* `[#draft]`  <sub>lst_wave3_2</sub>
- **Wächter:** Neun. Drei mal drei. Eine ordentliche Zahl. `[#draft]`  <sub>lst_wave3_3</sub>

### G4-3 · `wave_four`

- **Wächter:** Zehn bis Zwölf in Betrieb. Das sind alle. `[#draft]`  <sub>lst_wave4_1</sub>
- **Wächter:** Erst Zwölf, dann Elf, dann Zehn. `[#draft]`  <sub>lst_wave4_2</sub>
- **Wächter:** Ab hier rechne ich in Atemzügen. Sekunden sind zu grob. `[#draft]`  <sub>lst_wave4_3</sub>

### G4-4 · `load_wait`

> --- Die Pause ---------------------------------------------------------------------------------------------------------------
> Wer das Pult verlässt, hält den Lauf an: nichts geht verloren, nichts wird gesperrt. "load_wait" spielt die Szene einmal je Lauf, wenn sie vom Pult wegtritt, "load_back" bei der Rückkehr, nachdem
> der Lauf wartete. Trocken, ohne Vorwurf und ohne Lob; er trägt die Pause ein, wie er es angekündigt hat. Der Text kennt die Nummer des Hebels nicht (er ist statisch) und nennt keine.

- **Wächter:** Du verlässt das Pult. Ich halte an. Vorläufig. `[#draft]`  <sub>lst_wait_1</sub>
- **Wächter:** Pause eingetragen. Die Hebel bleiben, wie sie sind. `[#draft]`  <sub>lst_wait_2</sub>

### G4-5 · `load_back`

- *Der Stift des Wächters setzt wieder an, kaum dass du am Pult stehst.* `[#draft]`  <sub>lst_back_1</sub>
- **Wächter:** Pausendauer eingetragen, ich habe mitgezählt. Stand wie vor der Pause. `[#draft]`  <sub>lst_back_2</sub>

### G4-6 · `load_over`

> --- Das Ende der vierten Welle ----------------------------------------------------------------------------------------------
> Nach einer festen Zeit hält der Lauf (die Szene setzt danach plant.overload), und er rechnet es vor: zwölf Hebel, jeder verlangt in kurzen Abständen einen Zug, zwei Hände, eine Rechnung, die nicht
> aufgeht. Er trägt "nicht erfüllt" ein, mit dem Kreuz in der Mitte des Kästchens, und er bleibt dabei: "Das Verfahren verlangt es trotzdem." Die Zeile über die Abweichungen sagt nicht, welche (Zeiger,
> Dampf, Lampe sind Sache des Bildes). Kein Dank, kein Trost, keine Einsicht, keine Lehre, kein Wort für das, was in G5 geschieht; er steht noch am Pult, die andere Hand blättert. Die Rechnung gilt
> bei jedem Tempo der Einstellungen (sie nennt nur "in kurzen Abständen", keine Zahl). Der Gag ist die Gründlichkeit: zweimal gerechnet, dasselbe Ergebnis, dafür sind Rechnungen da.

- *Der Lauf hält. Der Wächter blättert um und nimmt die andere Hand nicht vom Pult.* `[#draft]`  <sub>lst_over_1</sub>
- **Wächter:** Ich halte an und rechne. Laut, damit man es nachprüfen kann. `[#draft]`  <sub>lst_over_2</sub>
- **Wächter:** Zwölf Hebel. Jeder verlangt in kurzen Abständen einen Zug. `[#draft]`  <sub>lst_over_3</sub>
- **Wächter:** Zwei Hände. Bis sie beim zwölften sind, steht der erste wieder oben. `[#draft]`  <sub>lst_over_4</sub>
- **Wächter:** Ich habe zweimal gerechnet. Zweimal dasselbe Ergebnis. Dafür sind Rechnungen da. `[#draft]`  <sub>lst_over_5</sub>
- **Wächter:** Die Rechnung geht nicht auf. Ich trage ein: nicht erfüllt. `[#draft]`  <sub>lst_over_6</sub>
- *Er setzt ein Kreuz in die letzte Spalte, genau in die Mitte des Kästchens.* `[#draft]`  <sub>lst_over_7</sub>
- **Wächter:** Abweichungen von Normal sind eingetragen, alle. `[#draft]`  <sub>lst_over_8</sub>
- **Wächter:** Ich bleibe dabei. Das Verfahren verlangt es trotzdem. `[#draft]`  <sub>lst_over_9</sub>
