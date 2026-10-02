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
