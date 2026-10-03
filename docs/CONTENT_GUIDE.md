# Content Guide

Regeln für alles, was Spielerinnen und Spieler lesen, hören oder anklicken. Verbindlich sind
[`GAME_BIBLE.md`](GAME_BIBLE.md) und die Writing-Abschnitte 55–59 in [`TECH_MASTER_PROMPT.md`](TECH_MASTER_PROMPT.md).

## IDs

- Stabile IDs in `snake_case`, nie Anzeigenamen in Logik: `mira`, `tess`, `antreiber`, `item_stone`, `curiosity_tiny_spoon`.
- Story-Flags mit Namensraum: `elysia.mirror_noticed`, `valley.mira_first_no`, `house.fire_lit`.
- Quests: `main_<ort>_<thema>` bzw. `side_<thema>`, z. B. `main_elysia_butterflies`, `side_goat_roof`.
- UI-Schlüssel in `content/locale/ui.csv`: `UPPER_SNAKE_CASE` mit Bereichspräfix (`BOOT_`, `MENU_`, `JOURNAL_`, `HUD_`).
- Eine ID wird nie umbenannt, sobald Spielstände sie enthalten können. Stattdessen Migration (siehe `SAVE_FORMAT.md`).

## Dateien

| Inhalt | Ort | Format |
|--------|-----|--------|
| UI-Texte | `content/locale/ui.csv` | Spalten `keys,de` |
| Dialoge | `content/dialogue/<bereich>/<szene>.dialogue` | Dialogue Manager 4 |
| Quests, Items, Kuriositäten | `content/quests/`, `content/items/` | `.tres` (ab Phase 2) |
| Karten | `content/maps/<map>.txt` | Textkarte (ab Phase 1) |

Neue Dialogdateien werden ab Phase 2 bewusst in die Übersetzungsvorlagen eingetragen. Die automatische
Eintragung des Dialogue Managers ist aus (ADR-006). Testdateien liegen nur unter `tests/`.

## Dialogformat (Dialogue Manager 4)

```
~ valley_first_meeting
Mira: Du stehst im Regen.
- …
	Mira: Gut. Dann stehen wir beide hier.
- Ich weiß nicht, wo ich bin.
	Mira: Im Tal. Hilft dir wahrscheinlich nicht.
=> END
```

- Cues (`~ name`) in `snake_case`.
- „…“ ist eine vollwertige Antwort und bekommt eine eigene Reaktion.
- Keine Fake Choices: Jede Antwortgruppe braucht mindestens eine wahrnehmbare Konsequenz (andere Reaktion, Zustand, spätere Erinnerung). Ab Phase 2 prüft ein Validator das.
- Platzhalterzeilen werden mit dem Tag `[#ph]` markiert. Vor dem Playtest darf keine solche Zeile übrig sein.
- Statische Zeilen-IDs für Übersetzungen werden in Phase 2 eingeführt.

## Schreibregeln

- Natürlich, knapp, figurenbezogen. Keine Expositionsmonologe, keine ständigen Weisheiten.
- Keine Therapiesprache, keine Diagnosen, keine Suchtbegriffe, keine Lebensweisheiten auf Ladebildschirmen.
- Menschen dürfen über Essen, Wetter, Tiere, Unsinn und Alltag reden.
- Humor folgt emotionalen Momenten nicht reflexartig. Stille darf stehen bleiben.
- Fehler werden nie beschämt. Kein „Du bist schlecht“, keine Punktabzüge.
- Keine relevante Information nur über Farbe.

## Figurenstimmen

Kurzprofile als Arbeitsgrundlage. Ausführliche Voice-Sheets mit Beispielzeilen entstehen vor der
Dialogproduktion in Phase 4 und werden vom Projektinhaber abgenommen.

| Figur | Kern | Nie |
|-------|------|-----|
| Protagonist | neugierig, humorvoll, unsicher, anfangs reaktiv, später eigene Meinung | leeres Gefäß, allwissend |
| Elysia-NPCs | sympathisch, lobend, angenehm; Unbehagen erst durch Wiederholung | creepy von Anfang an |
| Mira | pragmatisch, trocken, warm ohne Sentimentalität, stur, neugierig, witzig, eigenes Ziel (Meer) | Mentorin, Therapeutin, Belohnung, Manic Pixie Dream Girl |
| Tess | direkt, warm, praktisch, verlangt Beteiligung | Weisheitsautomat |
| Antreiber | effizient, hilfreich, zunehmend erschöpfend | Monster, Bösewicht |
| Betäuber | charmant, warm, lustig, bequem | sinister |
| Richter | wiederkehrende Stimme, anfangs bedrohlich, später durchschaubar und komisch | verschwindet ganz |
