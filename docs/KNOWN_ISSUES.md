# Bekannte Probleme

| # | Problem | Auswirkung | Umgang | Status |
|---|---------|------------|--------|--------|
| 1 | Der erste Import eines frischen Checkouts meldet Fehler zum Projekt-Theme, weil Godot das Theme vor der Schrift lädt. | Nur beim allerersten Import. | `tools/check.sh` macht einen Aufwärm-Import und prüft erst den zweiten streng. | akzeptiert |
| 2 | Beim Beenden meldet Godot zwei bis drei noch belegte Ressourcen, die der Dialogue Manager hält. | Nur beim Programmende, keine Auswirkung im Spiel. | Kein Eingriff ins Addon. `check.sh` und `smoke_export.sh` ignorieren genau diese Meldung. | akzeptiert |
| 3 | Der Cloud-Container hat keinen Vulkan-Treiber. | Forward+ ist dort nicht prüfbar. | Screenshots laufen über OpenGL3 (`tools/capture.sh`). Forward+ wird lokal und in Phase 3 geprüft. | akzeptiert |
| 4 | Asset-Seiten (kenney.nl, opengameart.org, freesound.org, itch.io, fonts.google.com) sind in der Cloud-Umgebung blockiert. | Claude kann CC0-Packs nicht selbst laden. | Domains in der Netzwerk-Allowlist freigeben oder Packs manuell committen. | offen |
| 5 | Builds sind nicht signiert bzw. nur ad-hoc signiert. | Windows SmartScreen und macOS Gatekeeper warnen. | Anleitung im README. Echte Signierung erst nach Budgetentscheidung. | akzeptiert |
| 6 | Windows- und macOS-Builds sind im Container gebaut, aber noch nicht auf echter Hardware gestartet. | Start auf Zielsystem unbestätigt. | Abnahme durch den Projektinhaber am Ende von Phase 0. Der Linux-Build wird in CI automatisch gestartet. | offen |
| 7 | Der Dialogue Manager speichert eine Einstellung unter einem Schlüssel in Großbuchstaben (`UPDATE_TRANSLATION_TEMPLATES_AUTOMATICALLY`). | Nur Kosmetik. | So übernommen, ein Test prüft den Wert. | akzeptiert |
| 8 | Im Kameramodus *Weich* wackelt die Figur um ±0,5 Spielpixel gegenüber dem Bildschirm, weil sie selbst pixelgenau bleibt. | Bei genauem Hinsehen sichtbar. | Gegenüberstellung mit *Pixelgenau* im Playtest (ADR-012). | offen |
| 9 | Testoptionen aus dem Pause-Menü werden nicht gespeichert. | Nach Neustart wieder Standard. | Settings-Autoload in Phase 2. | geplant |
| 10 | Alle Geräusche sind synthetische Platzhalter. | Footsteps klingen generisch. | CC0-Sounds bzw. Sounddesign in Phase 3. | geplant |
| 11 | Controller-Hotplug und Tastenbeschriftung auf echtem Gamepad sind nicht auf Hardware getestet. | Beschriftung könnte bei exotischen Pads „A“ zeigen. | Beim Playtest prüfen. | offen |
| 12 | Die Look-Szenen sind auf Zielhardware nicht gemessen (große Bodentexturen, Partikel, Lichter, Post-Process). Im Container gibt es nur Software-OpenGL. | Framerate auf schwachen Geräten unbekannt. | Beim Playtest Info-Anzeige (F3) prüfen; Messung in `PERFORMANCE.md` nachtragen. | offen |
| 13 | Gebackene Böden müssen nach jeder Kartenänderung neu erzeugt werden. Der Test erkennt nur eine falsche Größe, nicht veralteten Inhalt. | Grafik und Kollision könnten auseinanderlaufen. | Backen gehört zum Kartenändern (`CONTENT_GUIDE.md`). | akzeptiert |
| 14 | Regenspritzer erscheinen auch auf Dächern und Baumkronen. | Nur bei genauem Hinsehen. | Später Spritzer auf Bodenmaske begrenzen. | akzeptiert |
| 15 | Organische Ufer- und Wegkanten weichen um wenige Pixel von der Kachel-Kollision ab. | Füße können am Ufer minimal über Wasser stehen. | Wasser ist beim Backen leicht nach innen versetzt. Feinschliff mit finalen Karten. | akzeptiert |
| 16 | Die erzeugte Spielfigur hat nur Grundposen, keine Idle-Variationen und keine Anpassung. | Wirkt steifer als handgezeichnete Figuren. | Handgepixelte Figur nach Abnahme der Richtung (ART_DIRECTION, nächste Schritte). | geplant |
| 17 | Warmes Lampenlicht wirkt auf dem türkisgrünen Nachtgras leicht grünlich, weil 2D-Licht die Grundfarbe multipliziert. | Lichtkegel im Tal sind weniger warm als gewünscht. | Rötlicher Lichtton gewählt; endgültig mit handgemalter Palette oder eigenem Licht-Shader. | akzeptiert |
