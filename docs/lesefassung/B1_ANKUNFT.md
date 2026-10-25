# B1: Die Ankunft im Tal

<!-- Erzeugt mit `python3 tools/writing/readable.py`. Nicht von Hand ändern: Änderungen gehören in die .dialogue-Dateien. -->

Lesefassung: der Text in der Reihenfolge, in der das Spiel ihn zeigt. *Kursiv* ist Erzählung, **fett** sprechen die Figuren, ▸ sind deine Antworten. Eingerückt steht, was nur unter einer Bedingung oder nach einer Antwort kommt. Hinter jeder Zeile die ID in klein.

**So antwortest du:** je Szene (E3, T12 …) „OK“, „ändern: …“ oder „raus“. Was du nicht nennst, gilt als OK.


## ankunft


### AN1 · `arrival_echo`

- *Eine Böe fährt durch das nasse Laub und ist wieder weg.* `[#draft]`  <sub>ank_gust_1</sub>
- *Der Boden gibt unter deinen Füßen nach und behält den Abdruck.* `[#draft]`  <sub>ank_ground_1</sub>
*wenn* `elysia.inn_stayed`
  - *Unter der Plane brennt ein Feuer. Niemand ruft, dass du bleiben kannst.* `[#draft]`  <sub>ank_fire_1</sub>
*sonst wenn* `elysia.inn_declined`
  - *Unter der Plane brennt ein Feuer. Niemand fragt ein zweites Mal.* `[#draft]`  <sub>ank_fire_2</sub>
*wenn* `elysia.feast_noticed`
  - *Auf der Pfütze am Weg gehen Ringe auf. Keiner gleicht dem davor.* `[#draft]`  <sub>ank_rings_1</sub>
*wenn* `melody.child_hum`
  - *Der Regen auf dem Laub klingt einen Atemzug lang wie ein Summen. Dann ist es wieder Regen.* `[#draft]`  <sub>ank_hum_1</sub>
