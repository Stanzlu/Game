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

Automatische Läufe schreiben nie dorthin (ADR-018): Tests nutzen `user://profiles/test_<pid>/`, Smoke-Runs
`user://profiles/smoke/`, Aufnahmen `user://profiles/capture_<pid>/` (je Lauf eigen, danach gelöscht). Bei mehreren
`--profile=` gewinnt das letzte. Einstellungen liegen in `settings.json` **eine Ebene über `saves/`**, nicht darin
(Windows `%APPDATA%\REAL\settings.json`, macOS `~/Library/Application Support/REAL/settings.json`, Linux
`~/.local/share/REAL/settings.json`; Format: Abschnitt „Einstellungen“ unten).

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
| `flags` | nur `true`-Werte; IDs mit Namensraum (`bereich.name`). Gelöschte Flags fehlen. Seit ADR-047 neu: `house.mira_seated` (Mira sitzt am Feuer: die sitzende Mira der Karte erscheint damit und verschwindet mit `house.mira_left`), `elysia.crystal_touched`; `house.rested` setzt jetzt der Cue `fire_rest` selbst. `house.mira_knocked` gilt weiter und wird beim Öffnen der Tür für Mira gesetzt (nach dem Klopfen). |
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
- **Wann gespeichert wird:** Autosave beim Betreten eines Bereichs (nicht direkt nach dem Laden), bei jedem Quest-Schritt und jedem Beat (`beat.<id>`-Flag, ADR-047), beim Schließen des Fensters (`AppGuard`) und vor „Zum Startmenü“ und „Spiel beenden“. Manuell über das Pause-Menü. Nie während eines Dialogs oder in Encountern; ein dort angefordertes Autosave folgt, sobald es geht.
- **Keine Bestrafung:** Keine Ironman-Struktur, kein Löschen von Ständen aus dem Spiel heraus.
- **Datenschutz:** Spielstände bleiben lokal. Keine psychologischen Profile, keine Telemetrie.

## Kennzahlen

Speichern dauert im Container 0,5 bis 1,5 ms (Autosave mit Prototyp-Zustand, siehe `PERFORMANCE.md`).

## Einstellungen (`settings.json`)

Die Datei `user://settings.json` (Pfade siehe Ablage oben, mit `--profile=` im Ordner des Profils), geschrieben von `Settings` (ADR-018, ADR-048). Version 2:

```json
{
  "version": 2,
  "values": { "text.speed": 1 },
  "input": {
    "interact": [
      {"type": "key", "physical_keycode": 70}, {"type": "key", "physical_keycode": 32},
      {"type": "key", "physical_keycode": 4194309}, {"type": "key", "physical_keycode": 4194310},
      {"type": "joy_button", "button": 0}
    ],
    "sprint": [
      {"type": "key", "physical_keycode": 4194325},
      {"type": "joy_button", "button": 9}, {"type": "joy_axis", "axis": 5, "value": 1.0}
    ]
  }
}
```

- `values`: je Schlüssel ein Wert nach dem Schema in `core/settings.gd`; Ungültiges fällt auf den Standard zurück (Warnung `setting reset`).
- `input`: je umbelegbarer Aktion (`move_up`, `move_down`, `move_left`, `move_right`, `sprint`, `interact`, `cancel`, `menu`, `journal`) eine flache Liste von Ereignissen: `key` (`physical_keycode`), `joy_button` (`button` 0 bis 25) oder `joy_axis` (`axis` 4 oder 5, die Trigger, `value` 1.0). `device` steht nie darin, geladen wird immer mit `device = -1`. Bei den vier Geh-Aktionen steht, sobald die Tastatur überschrieben ist, auch das feste Controller-Gehen in der Liste (Stickachsen 0 bis 3 mit `value` ±1.0 und Steuerkreuz-Knöpfe 11 bis 14); der Lader behält diese Einträge nur, wenn sie den festen Ereignissen gleichen, jeden anderen Controller-Eintrag für das Gehen verwirft er.
- **Ein Gerät gilt als überschrieben, wenn die Liste Ereignisse dieses Geräts enthält.** Ist eine Aktion auf einem Gerät überschrieben, schreibt das Spiel die Ereignisse **beider** Geräte (Tastatur zuerst, feste Ereignisse wie Esc, Enter und Start eingeschlossen). Aktionen ohne Änderung werden nie geschrieben; eine Liste, die den Standard ergibt, zählt als nicht überschrieben (die Reihenfolge zählt: `[Leertaste, E]` ist eine Umbelegung, `[E, Leertaste]` nicht). Das Beispiel oben: `interact` hat auf der Tastatur F und Leertaste als Felder, dazu die festen Enter und Num-Enter, und auf dem Controller nur das feste A; bei `sprint` ist nur der Controller verändert (linke Schultertaste und rechter Trigger), die Tastatur schreibt ihren Standard (Umschalt) mit.
- Version 1 (nur `input` mit Tasten oder Knöpfen) lädt unverändert; eine Liste nur mit Tasten lässt die Controller-Standards der Aktion stehen. Eine neuere Version wird gelesen, soweit sie verstanden wird (Warnung `settings from a newer version`).
- Der Lader ist nachsichtig: Unbekannte Aktionen (auch `ui_accept`, `debug_*`, `scroll_*`), Einträge, die kein Ereignis sind, reservierte Tasten, Sticks, Trigger an anderen Aktionen als `sprint`, Knöpfe und Achsen für das Gehen am Controller (die festen Ereignisse selbst bleiben), mehr als zwei Felder und Tasten, die zwei Aktionen beanspruchen, werden verworfen, jedes mit einer Warnung `binding dropped`; bleibt einer Aktion nichts, gelten ihre Standardwerte.
- Eine Datei über 64 KiB oder mit ungültigem JSON wird als Ganzes ignoriert (Standardwerte) und vor dem nächsten Speichern als `settings.json.bad` kopiert; die Datei einer neueren Version bleibt als `settings.json.newer` erhalten.
- Notausgang: den Block `input` löschen (oder die Datei), dann gelten wieder alle Standardtasten.
