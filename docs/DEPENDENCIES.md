# Dependencies

Jede neue Abhängigkeit braucht einen Eintrag hier und eine Prüfung nach Abschnitt 35 des Master-Prompts:
Nutzen, kann die Engine es selbst, Pflege, Lizenz, Lock-in, Performance, Build-Komplexität.

| Name | Version | Herkunft | Lizenz | Zweck | Wo |
|------|---------|----------|--------|-------|-----|
| Godot Engine | 4.7.2-stable | github.com/godotengine/godot (Release, SHA512 geprüft) | MIT | Engine, Editor, Export | `tools/setup_godot.sh` |
| Godot Export Templates | 4.7.2-stable | dieselbe Release (SHA512 geprüft) | MIT | Windows-, macOS-, Linux-Builds | `tools/setup_godot.sh --templates` |
| Dialogue Manager | 4.1.0 (`a719088aea342572f29b5559fd8726896c9519b2`) | github.com/nathanhoad/godot_dialogue_manager | MIT | Dialogformat, Compiler, Runtime | `addons/dialogue_manager/` |
| GUT | 9.7.1 (`aeb5d4f3f7f0a6c9b5e178876d6c99b791fda605`) | github.com/bitwes/Gut | MIT | Unit-Tests | `addons/gut/` (nicht im Export) |
| gdtoolkit | 4.5.0 | PyPI | MIT | `gdlint`, `gdformat` | `requirements-dev.txt` |
| Tiny5 | Stand google/fonts, 2026-10-02 | github.com/google/fonts (`ofl/tiny5`) | OFL 1.1 | kleine Beschriftungen | `assets/fonts/tiny5/` |
| Jersey 10 | Stand google/fonts, 2026-10-04 (SHA-256 `db9cbd09…`) | github.com/google/fonts (`ofl/jersey10`, Soft Type) | OFL 1.1, ohne reservierten Namen | Hauptschrift, 19 px (ADR-026) | `assets/fonts/jersey10/` |
| Jersey 15 | Stand google/fonts, 2026-10-04 (SHA-256 `dbe00479…`) | github.com/google/fonts (`ofl/jersey15`, Soft Type) | OFL 1.1, ohne reservierten Namen | Titel und Belohnungen, 27 px (ADR-026) | `assets/fonts/jersey15/` |
| numpy | 2.4.6 | PyPI | BSD-3-Clause | Rechnen in den Grafik- und Audio-Generatoren (ADR-017), nur Entwicklung | `requirements-art.txt` |
| Pillow | 12.3.0 | PyPI | MIT-CMU (HPND) | PNG lesen und schreiben in den Generatoren (ADR-017), nur Entwicklung | `requirements-art.txt` |

## Hinweise
- Addons sind **unverändert** übernommen. Anpassungen passieren über Projekteinstellungen oder eigene Wrapper, nicht im Addon-Code.
- Dialogue Manager bringt C#-Varianten mit (`*.cs`, `DialogueLabel.tscn`, `ExampleBalloon.tscn`, `SmallExampleBalloon.tscn`). Sie werden in `export_presets.cfg` ausgeschlossen. Wir nutzen die GDScript-Varianten.
- Update-Ablauf: Tag klonen, `addons/<name>/` ersetzen, `tools/check.sh`, Tabelle aktualisieren, eigener Commit.
- numpy und Pillow: Prüfung nach Abschnitt 35. Godot kann prozedurale Grafik zur Laufzeit erzeugen, aber nicht als reproduzierbare, eingecheckte Dateien mit Vorschau; reines Python wäre für Rauschen und Weichzeichnen zu langsam. Beide sind weit verbreitet, gepflegt, permissiv lizenziert, laufen nur auf Entwicklerrechnern und landen nicht im Build. Kein Lock-in: die Ausgabe sind normale PNG- und WAV-Dateien.
- CI nutzt GitHub Actions `checkout@v7`, `setup-python@v7`, `cache@v6`, `upload-artifact@v7`.
- Jersey 10/15: Prüfung nach Abschnitt 35. Pixelschriften mit ganzzahliger Pixelgröße (18,7 bzw. 27 px pro Geviert), deutsche Zeichen vollständig, OFL ohne reservierten Schriftnamen, nur als Schriftdatei im Build. Verglichen mit Pixelify Sans, Silkscreen, Micro 5, VT323, Press Start 2P und Jacquard (Fraktur bewusst nicht, wegen ihrer Wirkung im Deutschen).

