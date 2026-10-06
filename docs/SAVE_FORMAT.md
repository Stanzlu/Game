# Save-Format

**Status:** umgesetzt in Phase 2 (ADR-008, ADR-021). Schema-Version 1. Dieses Dokument ist die Referenz
für das tatsächliche Format. Code: `core/save/save_codec.gd` (Format), `core/state/game_state.gd`
(Inhalt), `core/save_system.gd` (Dateien, Slots, Laden).

## Ablage

`user://saves/`. Durch `application/config/custom_user_dir_name = "REAL"` liegt das unter:

| System | Pfad |
|--------|------|
| Windows | `%APPDATA%\REAL\saves\` |
| macOS | `~/Library/Application Support/REAL/saves/` |
| Linux | `~/.local/share/REAL/saves/` |

Hinweis: Ändert sich der Spielname, ändert sich auch dieser Ordner. Dann braucht es eine Migration der Pfade.

Automatische Läufe schreiben nie dorthin (ADR-018): Tests nutzen `user://profiles/test/`, Smoke-Runs
`user://profiles/smoke/`, Aufnahmen `user://profiles/capture/`. Einstellungen liegen in `settings.json`
im selben Ordner.

## Dateien

- `autosave.json`, `slot_1.json` bis `slot_3.json`
- je Datei eine Sicherung `*.json.bak` der vorherigen, lesbaren Version
- `*.json.tmp` existiert nur während des Schreibens

## Inhalt

```json
{
	"schema_version": 2,
	"game_version": "0.0.1",
	"saved_at": "2026-10-03T12:00:00Z",
	"world_state": {
		"flags": { "sandbox.garden_gate_open": true, "valley.mira_met": true },
		"quests": {
			"side_sandbox_gate": {
				"stage": "through_gate",
				"history": ["find_lever", "through_gate"],
				"objectives_done": []
			}
		},
		"relationships": { "mira": { "state": "cautious", "memories": ["door_silence"] } },
		"facets": { "courage": true },
		"house": { "fire_lit": true, "curiosity_slots": { "shelf_1": "curiosity_tiny_spoon" }, "cat_name": "Asche" },
		"inventory": { "item_stone": 1, "item_seed": 1 },
		"discovered": ["sandbox_garden"],
		"ui_mode": "REAL",
		"day_preset": "abend",
		"elysia": { "xp": 12500, "gold": 4200 },
		"player": { "name": "Alex", "preset": 1, "map": "sandbox", "x": 120.5, "y": 64 },
		"playtime_seconds": 1234.5
	}
}
```

| Feld | Bedeutung und Prüfung beim Laden |
|------|----------------------------------|
| `schema_version` | ganze Zahl ≥ 1, aktuell 2. Neuer als das Spiel: Laden wird abgelehnt. Älter: Migration. |
| `saved_at` | UTC, ISO 8601. Bestimmt „Fortsetzen“ (neuester lesbarer Slot). |
| `flags` | nur `true`-Werte; IDs mit Namensraum (`bereich.name`). Gelöschte Flags fehlen. |
| `quests` | nur bekannte Quests (`content/quests`) und deren Stufen. `history` enthält besuchte Stufen, die aktuelle zuletzt. Fertig ist eine Quest, wenn ihre Stufe kein `next` hat. |
| `relationships` | nur `mira`, `tess`, `orin`, `lio`. Zustand `stranger`, `cautious`, `familiar`, `close`, `strained`. Erinnerungen als IDs. |
| `facets` | die acht Facetten-IDs aus `GameState.FACETS`, im Slice nur Flags. |
| `house` | Feuer an/aus; Kuriositäten-Fächer (nur bekannte Items, die ins Regal dürfen); `cat_name`: Name der Katze (max. 24 Zeichen), leer = unbenannt. Fehlt `cat_name` (Stände vor ADR-042), gilt leer; kein neues Schema. |
| `inventory` | nur bekannte Items, Anzahl 1 bis Stapelgrenze. |
| `ui_mode` | `ELYSIA` oder `REAL`. |
| `day_preset` | Tageszeit der wirklichen Welt: `regentag`, `abend`, `nacht` oder leer (noch keine). Ausruhen auf der Bank schaltet weiter. Seit Schema 2, fehlt es, gilt leer. |
| `elysia` | XP und Gold (kosmetisch). Das Level wird aus XP berechnet: `1 + floor(sqrt(xp / 15))`. |
| `player` | Name (max. 24 Zeichen), Preset 0–7, Szenen-Schlüssel (`SceneRegistry`) und Position der Figur. Ein unbekannter Schlüssel macht den Stand unladbar (`unknown_map`). |
| `playtime_seconds` | Spielzeit ohne Pausen und Menüs. |

Migration 1 → 2: Stände aus Phase 2 enthielten immer `ELYSIA`, weil es den Übergang noch nicht gab.
`ui_mode` richtet sich danach nach der Szene des Stands (`SceneRegistry.start_mode`).

Unbekannte Felder werden ignoriert. Ungültige Einträge werden verworfen und als Warnung
(`SAVE: save data repaired`) geloggt; der Rest lädt trotzdem.

## Regeln

- **Atomar:** in `*.tmp` schreiben, flushen, die bisherige Datei nach `*.bak` verschieben (nur wenn sie lesbar ist), dann umbenennen. Eine beschädigte Datei verdrängt nie eine gute Sicherung.
- **Robust:** Größenlimit 1 MB, JSON-Parse mit Zeilenangabe, Schema-Version prüfen, jedes Feld typprüfen, unbekannte IDs melden. Bei Fehlern bietet das Lademenü die Sicherung an. Nie ein Absturz.
- **Sicher:** Kein `str_to_var`, keine Godot-Ressourcen aus dem Nutzerverzeichnis, kein Code aus Daten. Zahlen aus JSON werden auf Endlichkeit, Ganzzahligkeit und Bereich geprüft.
- **Migration:** `SaveCodec.migrations()`, ein Schritt pro Version (Eintrag *i* macht aus Version *i + 1* die Version *i + 2*). Getestet mit eingefrorenen Beispieldateien unter `tests/fixtures/saves/` (`v1_full.json` muss immer laden).
- **Wann gespeichert wird:** Autosave beim Betreten eines Bereichs (nicht direkt nach dem Laden) und bei jedem Quest-Schritt. Manuell über das Pause-Menü. Nie während eines Dialogs oder in Encountern; ein dort angefordertes Autosave folgt, sobald es geht.
- **Keine Bestrafung:** Keine Ironman-Struktur, kein Löschen von Ständen aus dem Spiel heraus.
- **Datenschutz:** Spielstände bleiben lokal. Keine psychologischen Profile, keine Telemetrie.

## Kennzahlen

Speichern dauert im Container 0,5 bis 1,5 ms (Autosave mit Prototyp-Zustand, siehe `PERFORMANCE.md`).
