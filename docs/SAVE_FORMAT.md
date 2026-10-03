# Save-Format

**Status:** Konzept (ADR-008). Umsetzung in Phase 2. Dieses Dokument wird dann zur Referenz des tatsächlichen Formats.

## Ablage

`user://saves/`. Durch `application/config/custom_user_dir_name = "REAL"` liegt das unter:

| System | Pfad |
|--------|------|
| Windows | `%APPDATA%\REAL\saves\` |
| macOS | `~/Library/Application Support/REAL/saves/` |
| Linux | `~/.local/share/REAL/saves/` |

Hinweis: Ändert sich der Spielname, ändert sich auch dieser Ordner. Dann braucht es eine Migration der Pfade.

## Dateien

- `autosave.json`, `slot_1.json` bis `slot_3.json`
- je Datei ein Backup `*.bak` der vorherigen Version

## Inhalt (Entwurf)

```json
{
  "schema_version": 1,
  "game_version": "0.0.1",
  "saved_at": "2026-10-02T14:00:00Z",
  "playtime_seconds": 1234,
  "location": { "map": "valley", "x": 120, "y": 64 },
  "world_state": {
    "flags": { "elysia.mirror_noticed": true },
    "quests": { "main_elysia_butterflies": { "stage": "done" } },
    "relationships": { "mira": { "state": "cautious", "memories": ["first_no"] } },
    "facets": {},
    "house": { "fire_lit": true, "curiosity_slots": { "shelf_1": "curiosity_tiny_spoon" } },
    "inventory": { "item_stone": 1, "item_seed": 1 },
    "discovered": ["elysia_square", "valley_bridge"],
    "ui_mode": "REAL",
    "elysia": { "xp": 12500, "level": 29, "gold": 4200 },
    "player": { "name": "…", "preset": 1 }
  }
}
```

## Regeln

- **Atomar:** in `*.tmp` schreiben, flushen, vorherige Datei nach `*.bak` verschieben, dann umbenennen.
- **Robust:** Beim Laden JSON parsen, Schema-Version prüfen, Pflichtfelder validieren, unbekannte IDs melden. Bei Fehlern das Backup anbieten, nie abstürzen.
- **Sicher:** Kein `str_to_var`, keine Godot-Ressourcen aus dem Nutzerverzeichnis, kein Code aus Daten.
- **Migration:** eine Funktion pro Schritt (`migrate_1_to_2`), getestet mit eingefrorenen Beispieldateien unter `tests/fixtures/saves/`.
- **Keine Bestrafung:** Autosave an Story-Beats und beim Betreten von Bereichen. Keine Ironman-Struktur.
- **Datenschutz:** Spielstände bleiben lokal. Keine psychologischen Profile, keine Telemetrie.
