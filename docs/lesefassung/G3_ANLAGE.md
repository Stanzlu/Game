# G3 Anlage (Akt V)

<!-- Erzeugt mit `python3 tools/writing/readable.py`. Nicht von Hand ändern: Änderungen gehören in die .dialogue-Dateien. -->

Lesefassung: der Text in der Reihenfolge, in der das Spiel ihn zeigt. *Kursiv* ist Erzählung, **fett** sprechen die Figuren, ▸ sind deine Antworten. Eingerückt steht, was nur unter einer Bedingung oder nach einer Antwort kommt. Hinter jeder Zeile die ID in klein.

**So antwortest du:** je Szene (E3, T12 …) „OK“, „ändern: …“ oder „raus“. Was du nicht nennst, gilt als OK.


## anlage


### G3-1 · `gate`

- *Am Tor hängt ein Messingschild, »Wächter im Dienst. Eintritt nach Eintrag.« Eine Klinke gibt es nicht, eine Klingel auch nicht.* `[#draft]`  <sub>anl_gate_1</sub>
- *Abgeschlossen ist es nicht, nur sehr genau zugemacht. Dahinter geht das Ticken weiter, ob du klopfst oder nicht.* `[#draft]`  <sub>anl_gate_2</sub>
- ▸ **Klopfen.**
  - *→ weiter bei* `gate_knock`
- ▸ **Weitergehen.**
  - *→ Ende des Szenenstücks*

### G3-2 · `gate_knock`

> --- Die Stimme hinter dem Zaun ----------------------------------------------------------------------------------------------
> Er zählt Schrauben, wird unterbrochen und merkt sich die Stelle, bevor er sich um den Besuch kümmert. Die Pedanterie ist der Gag: der Besuch steht nicht in der Ordnung, aber
> nichts in der Ordnung verbietet ihn. Das Tor geht mit der Zeile "Eintritt." auf (das Flag steht davor); danach steht an seiner Stelle die Tür in die Halle.

- *Du klopfst einmal an das Tor. Dahinter zählt eine Stimme halblaut Schrauben und lässt sich nicht stören.* `[#draft]`  <sub>anl_knock_1</sub>
- **Wächter:** …zehn. Elf. Zwölf. Moment. `[#draft]`  <sub>anl_knock_2</sub>
- *Das Zählen bricht ab. Papier raschelt, ein Stift kratzt, genau einmal.* `[#draft]`  <sub>anl_knock_3</sub>
- **Wächter:** Stelle vermerkt. Besuch, einer, unangemeldet. `[#draft]`  <sub>anl_knock_4</sub>
- **Wächter:** Nicht vorgesehen. Aber auch nicht verboten. Ich habe nachgesehen. `[#draft]`  <sub>anl_knock_5</sub>
- **Wächter:** Eintritt. `[#draft]`  <sub>anl_knock_6</sub>

### G3-3 · `waechter`

> --- Der Wächter: der Zustand wählt -----------------------------------------------------------------------------------------
> Das erste Mal (und jedes Mal vor der Probe): er schreibt, sieht nicht auf und zählt die Spielerin ("Eins. Du."). Weil er jeden Besuch von vorn zählt, darf der Cue vor der Probe
> so oft gespielt werden, wie die Spielerin will: die Wiederholung gehört zu seinem Verfahren. Er stellt die Halle in Fakten vor (zwölf Hebel, drei in Betrieb, neun stehen), stellt
> eine Kontrollfrage und beantwortet sie selbst, und bietet die Probe an. Die Antworten sind kurz; das Schweigen "…" ist eine volle Antwort und die letzte. Wer die Probe nie
> verlangt, kommt nie in Not (kein Flag, kein Druck, kein Zähler). Wer sie gemacht hat (plant.probe_done), liest "waechter_again".

*wenn* `plant.probe_done`
  - *→ weiter bei* `waechter_again`
*wenn* `plant.probe`
  - *→ weiter bei* `waechter_wait`
- *Am Pult steht ein älterer Mann im langen Arbeitsmantel, die Messingknöpfe bis zum Kragen geschlossen, die Mütze genau gerade. Er schreibt und sieht nicht auf.* `[#draft]`  <sub>anl_w_1</sub>
- **Wächter:** Eins. Du. `[#draft]`  <sub>anl_w_2</sub>
- *Der Stift setzt einen Strich ins Notizbuch. Erst dann hebt er den Kopf. Seine Stiefel stehen Spitze an Spitze.* `[#draft]`  <sub>anl_w_3</sub>
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

### G3-4 · `probe_offer`

> --- Die Probe: das Angebot --------------------------------------------------------------------------------------------------
> Die drei Hebel in Betrieb, von links nach rechts Eins, Zwei, Drei, und die Reihenfolge, die er ausruft: Erst Drei, dann Eins, dann Zwei (die Szene prüft sie im Code, dieser Text
> muss sie genau so nennen). Keine Frist, keine Strafe; wer sie vergisst, fragt noch einmal (der Cue ist über "Zeig mir die Hebel." jederzeit wieder zu erreichen). In der letzten Zeile
> tritt er vom Pult zurück; danach setzt der Cue plant.probe, und die Szene startet die Probe. Kein Wort darüber, was die anderen Hebel tun oder was sie bewachen.

- **Wächter:** Von links nach rechts Eins, Zwei, Drei. Diese drei laufen. `[#draft]`  <sub>anl_probe_1</sub>
- **Wächter:** Ich rufe eine Reihenfolge aus. Du ziehst in dieser Reihenfolge. `[#draft]`  <sub>anl_probe_2</sub>
- **Wächter:** Keine Frist, keine Strafe. Das Verfahren kennt beides nicht. `[#draft]`  <sub>anl_probe_3</sub>
- **Wächter:** Ich sage es einmal. Eine Wiederholung trage ich ein. `[#draft]`  <sub>anl_probe_4</sub>
- **Wächter:** Erst Drei, dann Eins, dann Zwei. `[#draft]`  <sub>anl_probe_5</sub>
- *Er klappt das Notizbuch zu und tritt einen Schritt vom Pult zurück, genau einen.* `[#draft]`  <sub>anl_probe_6</sub>

### G3-5 · `waechter_wait`

> --- Zwischen Angebot und Probe ----------------------------------------------------------------------------------------------
> Wer das Angebot angenommen hat (plant.probe, gesetzt von "probe_offer", gelesen hier) und den Wächter noch einmal anspricht, bekommt keine zweite Vorstellung: er trägt die
> Wiederholung ein, wie er es angekündigt hat, und sagt die Reihenfolge noch einmal, genau so. Ohne Antwort, ohne Frist.

- *Der Wächter steht einen Schritt vom Pult, das Notizbuch zu, den Blick auf den Hebeln.* `[#draft]`  <sub>anl_wait_1</sub>
- **Wächter:** Wiederholung. Ich trage sie ein. `[#draft]`  <sub>anl_wait_2</sub>
- **Wächter:** Erst Drei, dann Eins, dann Zwei. `[#draft]`  <sub>anl_wait_3</sub>
- *Der Stift macht einen Strich, ohne dass er das Notizbuch aufschlägt.* `[#draft]`  <sub>anl_wait_4</sub>

### G3-6 · `waechter_again`

> --- Nach der Probe ----------------------------------------------------------------------------------------------------------
> Er zählt weiter und trägt etwas ein; er lobt nicht, er kündigt nichts an und er erklärt nichts. Der Gag ist das Eintragen des Eintragens (er hat nachgesehen, es ist nicht
> nötig) und die Schrauben, die jedes Mal gleich viele sind: das ist der Sinn von Schrauben. Kein Wort über die anderen Hebel.

- *Der Wächter steht am Pult, den Stift in der Faust. Auf seiner Seite ist eine Zeile dazugekommen, kleiner geschrieben als die anderen.* `[#draft]`  <sub>anl_again_1</sub>
- **Wächter:** Rubrik Unvorhergesehenes, für Dinge, die nicht passieren. Heute ein Eintrag. `[#draft]`  <sub>anl_again_2</sub>
- **Wächter:** Muss ich das Eintragen auch eintragen? Nein. Ich habe nachgesehen. `[#draft]`  <sub>anl_again_3</sub>
- **Wächter:** Die Schrauben sind gleich viele wie vorhin. Das ist der Sinn von Schrauben. `[#draft]`  <sub>anl_again_4</sub>

### G3-7 · `lever_wrong`

> --- Die Probe: die Szene spielt die Zeilen ---------------------------------------------------------------------------------
> "lever_wrong" nach jeder falschen Reihenfolge (die Hebel gehen zurück, nichts wird gesperrt), "lever_right" nach dem dritten richtigen Zug. Die Reihenfolge wird in "lever_wrong"
> nicht noch einmal verraten (die Spielerin hat sie gehört und kann nachfragen); der Cue setzt und liest nichts, die Szene setzt plant.probe_done und die Beats.
> "Nein." bleibt trocken und ohne Witz davor; der Gag von "lever_right" ist das Unvorhergesehene, nie Wärme.

- **Wächter:** Nein. `[#draft]`  <sub>anl_wrong_1</sub>
- **Wächter:** Richtige Hebel, falsche Reihenfolge. Sie gehen zurück. Von vorn. `[#draft]`  <sub>anl_wrong_2</sub>

### G3-8 · `lever_right`

- **Wächter:** Eingetragen. `[#draft]`  <sub>anl_right_1</sub>
- **Wächter:** Dass es klappt, war nicht eingeplant. Ich trage es ein. `[#draft]`  <sub>anl_right_2</sub>
- *Er schreibt es hin und liest es sich einmal leise vor, mit dem Finger unter den Wörtern.* `[#draft]`  <sub>anl_right_3</sub>

### G3-9 · `lever_idle`

> --- Die Dinge der Halle -----------------------------------------------------------------------------------------------------
> Alles Erzählung, nichts wird gesetzt außer dem Fragment. Die neun stillen Hebel tragen je ein Tuch; der Text sagt, dass sie stehen, und verspricht nichts. Die kleine Tür wird
> gesehen und nicht besprochen: Dinge, keine Erklärung, kein Wort darüber, wem sie gehört oder warum (Brief O6, Bible §51); ihre Größe sagt nur der Vergleich mit der Spielerin.

- *Du ziehst am Hebel unter dem Tuch. Er gibt keinen Fingerbreit nach.* `[#draft]`  <sub>anl_idle_1</sub>
- *Auf das Tuch ist ein Schild genäht, mit einer einzigen Zeile, »Steht.«* `[#draft]`  <sub>anl_idle_2</sub>

### G3-10 · `small_door`

- *An der Rückwand, hinter dem Pult, sitzt eine Tür, die dir kaum bis zur Brust reicht. Das Holz ist grau, die Scharniere glänzen von Öl.* `[#draft]`  <sub>anl_door_1</sub>
- *An ihr sitzt ein schwerer Riegel, und von ihm laufen Stangen zum Pult, eine zu jedem der zwölf Hebel. Zusammen halten sie ihn, und keine ist locker.* `[#draft]`  <sub>anl_door_2</sub>
- *Die Tür ist zu. Du klopfst nicht.* `[#draft]`  <sub>anl_door_3</sub>

### G3-11 · `gauges`

- *An der Seitenwand hängen vier runde Zeiger in einer Reihe, beschriftet in Druckbuchstaben. Alle vier stehen auf »Normal«.* `[#draft]`  <sub>anl_gauge_1</sub>
- *Der dritte zittert ein wenig, so leise, als wolle er nicht auffallen. Er steht trotzdem auf »Normal«.* `[#draft]`  <sub>anl_gauge_2</sub>

### G3-12 · `worn_dial`

> --- Eine Spur der Welt: das Zifferblatt -------------------------------------------------------------------------------------
> Ein Fragment (Spur der Welt, kein Bild des Kindes, keine Figur, keine Ursache): ein Zeiger am Pult hat über die Jahre eine Rille in das Glas gerieben, immer an derselben Stelle.
> Wie der Eisenring: für einen Atemzug liegt ein Zeiger über dem anderen, alle auf derselben Stelle, dann ist es wieder einer. Das erste Mal setzt das Flag (Collection liest es),
> danach gibt es nur noch eine Zeile.

*wenn* `fragment.worn_dial`
  - *Das Zifferblatt am Pult mit der Rille im Glas. Der Zeiger steht auf »Normal«, wie in jedem Jahr.* `[#draft]`  <sub>anl_dial_4</sub>
*sonst*
  - *Ein Zeiger am Pult sitzt dicht über dem Glas seines Zifferblatts und hat es berührt, Jahr um Jahr. Dort ist es abgewetzt, eine Rille, fein und rund.* `[#draft]`  <sub>anl_dial_1</sub>
  - *Die Rille liegt immer an derselben Stelle, genau unter der Spitze, wenn der Zeiger auf »Normal« steht.* `[#draft]`  <sub>anl_dial_2</sub>
  - *Für einen Atemzug liegt ein Zeiger über dem anderen, hundert, tausend, jeder auf derselben Stelle. Dann ist es wieder einer.* `[#draft]`  <sub>anl_dial_3</sub>

### G3-13 · `steam_pipe`

> --- Das Rohr -----------------------------------------------------------------------------------------------------------------
> Humor aus einem Ding: das Rohr zischt in genau dem Takt des Tickens vom Tor. Nichts wird erklärt, niemand klärt, wer von wem lernt.

- *Ein Rohr an der Wand zischt in gleichen Abständen, jedes Mal gleich lang und mit derselben kleinen Wolke.* `[#draft]`  <sub>anl_pipe_1</sub>
- *Das Zischen fällt auf das Ticken, das du vom Tor kennst, Schlag auf Schlag. Es ist nicht klar, wer von wem abschreibt.* `[#draft]`  <sub>anl_pipe_2</sub>
