# Stilbuch

Wie REAL klingt, aus den Messwerten des Slice (444 Zeilen, 3.826 Wörter) und aus der Game Bible (§3.2, §22, §32, §51,
§59). Es beschreibt, was der Text schon tut, und fügt nur hinzu, was die Bible verlangt. Neue Segmente schreiben
dagegen; der Writing-Pass (P6.5) misst den Slice dagegen. **Entwurf, bis du ihn liest.**

Messwerte frisch holen: `python3 tools/writing/report.py`. Prüfen: `python3 tools/writing/lint.py` (in `check.sh`).

## Messwerte

| Stimme | Zeilen | Ø Wörter | Zeilen mit „!“ | höchstens 4 Wörter |
|---|---|---|---|---|
| Erzählung | 172 | 11,3 (längste 21) | 0 | 4 |
| Mira (und „Die Frau“) | 106 | 7,2 und 7,5 | 0 | 32 |
| Spielfigur (Antworten) | 67 | 3,2 (längste 10) | 0 | 48 |
| Antreiber | 44 | 7,1 | 4 | 11 |
| Elysianer, Gastwirt, Gärtnerin | 53 | 10,5 / 10,6 / 12,0 | 21 | 3 |

Elysia redet in Schleifen (Sätze je Zeile: Gärtnerin 3,2, Gastwirt 3,1, Elysianer 2,9), die Wirklichkeit in Stücken
(Mira 1,8). „!“ steht in 21 von 89 Elysia-Zeilen und in 4 von 355 der Wirklichkeit, alle vier beim Antreiber, solange
er antreibt. Auslassungspunkte: 25 mal „…“, nie „...“. Schilder und Zettel stehen in » «, „ “ kommt nicht vor.
13 von 67 Antworten der Spielfigur sind „…“: Schweigen ist eine volle Antwort (Bible §22).

## Regeln

1. **Kurz.** Eine Zeile sagt eine Sache. Figuren der Wirklichkeit sprechen im Mittel unter acht Wörtern, die Spielfigur
   unter vier. Länger wird es nur in Elysia, und dann aus Wiederholung, nicht aus Inhalt.
2. **Erzählung in der zweiten Person, Präsens.** 49 von 172 Erzählzeilen sprechen „du“ an, der Rest beschreibt von
   außen. Erzählung hat **keinen Doppelpunkt, kein „!“, kein „?“, kein „…“**. Zeilen ohne Sprecher sind Erzählung.
3. **Gefühl durch Geste, nie durch Aussage.** Niemand ist traurig, wütend oder erleichtert; er nickt „sehr schnell,
   dann noch einmal, langsamer“ (`sl_antr_why_6`), legt die Hände „auf die Knie, dann in den Schoß, dann wieder auf die
   Knie“ (`haus_antr_4`), „fragt nicht, warum“ (`tal_eve_ely_4`). Die Spielfigur bekommt kein Gefühl zugeschrieben, das
   die Spielerin nicht gewählt hat.
4. **Sprechername folgt dem Wissen der Spielfigur.** „Die Frau“, bis sie sich vorstellt (`tal_mira_24`), dann „Mira“.
5. **Ding vor Gedanke.** Ein Satz fängt beim Gegenstand an: Stiefel, Ziege, Netz, Eimer, Suppe. Gedanken kommen als
   Handlung (`haus_shelf_4`: „Du behältst den Löffel. Für sehr kleine Suppen, vielleicht.“).
6. **Zahlen ausgeschrieben.** Ausnahmen: Schilder und Größen, mit Grund in `vocabulary.json`.
7. **„…“ ist ein Zeichen, kein Platzhalter.** Es steht als eigene Antwort oder als Zögern am Zeilenanfang
   (`tal_mira_eve_5`: „… Danke.“), nie am Ende, um eine Zeile weicher zu machen.

## Humor-Mittel je Welt

- **Elysia (2/10):** Lob und Vollkommenheit, die sich selbst widersprechen. Mittel: Wiederholung („Dieselbe wie
  immer“), „natürlich“ als Tick, Übertreibung, ein „sehr schönes Nichts“ (`el_flower_2`). Die Figuren meinen es gut,
  niemand sagt Nein.
- **Wirklichkeit, Tal (3/10):** Untertreibung und Trockenheit, die Pointe am Zeilenende. Mittel: Dinge mit eigenem
  Willen (die Ziege hat „keine Fragen“, `tal_goat_8`), Gegensatzpaare („Nass warst du vorher schon. Jetzt bist du es
  richtig.“, `tal_fell_2`), die Reihenfolge („Regen, Erde, Honig. In dieser Reihenfolge.“, `tal_flower_4`), das
  Wort „bemerkenswert“ für das Durchschnittliche (`tal_goat_4`).
- **Antreiber:** Arbeit als Rhetorik („Ich atme nur schneller, um Zeit zu sparen.“, `sl_antr_tired_4`). Er ist komisch,
  weil er es ernst meint; der Text lacht nicht über ihn (Bible Risiko 8).
- Humor folgt einem schweren Moment nicht zwangsläufig (Risiko 7). Auf „Zum Meer.“ und auf das erste „Nein.“ folgt
  kein Witz. Schmerz darf stehen bleiben.

## Nie

1. Keine Therapie-, Diagnose- oder Suchtsprache (Bible §3.2; Lint). Keine konkrete Sucht, keine Selbstverletzung als
   Bild, kein Trauma mit Ursache (§15, §51).
2. **Keine ständigen Weisheiten in der Wirklichkeit.** Wirkt ein Satz wie ein Kalenderspruch, fliegt er raus. Das Äußerste
   ist `tal_eve_day_4`: „Manche Wege sind so.“ Lehren zieht die Spielerin selbst.
3. Mira ist nie Mentorin: sie erklärt nicht, was die Spielfigur fühlt, lobt nicht, tröstet nicht mit Worten. Sie
   widerspricht, hilft ein Stück und geht wieder an ihre Arbeit.
4. Lob ist Elysias Sprache. In der Wirklichkeit gibt es keinen Beifall für Selbstverständliches.
5. Keine Beschämung nach Fehlern (§51): der Sturz in den Bach (`tal_fell_*`) ist kalt und komisch, nie ein Urteil.
6. Keine „Du musst nur wollen“-Sätze, kein „Schmerz macht stark“.
7. Keine Antwort „gut, neutral, böse“. Antworten unterscheiden sich in dem, was danach geschieht (Fake Choices sind
   ein Validator-Fehler).
8. Keine Zahlen für Beziehungen, Facetten oder Fortschritt im Text.
9. Keine Erklärung der Beschützer von außen. Der Antreiber sagt, was er glaubt („Wer schnell genug ist, den holt nichts
   ein“, `sl_antr_why_2`), niemand sagt, was es bedeutet.
10. Keine Zeile, die nur dem Gag dient: jeder Gag trägt auch einen Gegenstand, eine Figur oder ein Wetter.

## Beim Schreiben

Zeile für Zeile: Erst die Funktion der Figur (ihr Blatt in `stimmen/`), dann der Kopfkommentar je Cue, dann die
Zeilen mit `[#draft]`. Eingefroren wird per `[#ok]` und `id_lock.py --update`. Die Motive des Segments stehen im
Motivbuch (`MOTIVE.md`), bevor sie im Text vorkommen.
