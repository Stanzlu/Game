# REAL — Pre-Implementation Review & Vertical-Slice-Roadmap (v0.1)

Status: Zur Freigabe vorgelegt. Kein Code geschrieben. Nichts installiert. Datum: 2026-10-02.

## Context

- Repository `Stanzlu/Game` ist leer: kein Commit, kein Branch, kein Remote-Branch. Es gibt keine Patterns, Tools oder Altlasten zu übernehmen oder zu adaptieren. Wir starten auf der grünen Wiese.
- Cloud-Session (dieser Container): Ubuntu 24.04, Node 22, Python 3.11, Xvfb, ffmpeg, Mesa (Software-GL) vorhanden. Kein Godot, kein Unity, kein .NET.
- Netzwerk der Umgebung: `pypi.org` erreichbar. `github.com` (Release-Seiten), `godotengine.org` und `kenney.nl` werden von der Netzwerk-Policy abgelehnt. Folge: Claude kann Godot hier derzeit nicht herunterladen, also auch keine Headless-Tests oder Exporte in Cloud-Sessions ausführen, bis die Umgebung angepasst ist (siehe H).
- Ziel dieses Dokuments: Verständnis, kritische Prüfung, Engine-Empfehlung, High-Level-Architektur, Produktionsplan für den 45–60-Minuten-Vertical-Slice, Kostenprüfung, offene Fragen, Empfehlung.

---

## A. Verständnis der Produktvision

REAL ist ein narratives Singleplayer-Pixel-Art-Adventure-RPG ohne klassisches Kampfsystem. Der Spieler erwacht in Elysia, einer perfekten, adaptiven Schutzwelt, die wie ein klassisches RPG aussieht (XP, Level, Gold, Loot, Lob) und zunächst echt Spaß machen muss. Durch Wiederholungen, fehlende Gegenseitigkeit und eine fehlende Spiegelung entsteht Unbehagen, bis der Spieler einen Riss findet und in eine unkontrollierbare, wetterhafte, soziale Wirklichkeit tritt. Dort verschwinden die RPG-Systeme, das UI wird still, und das eigentliche Spiel beginnt: Exploration, Umweltpuzzles, individuelle Encounters mit inneren Beschützern (die verstanden, nicht besiegt werden), echte Beziehungen (Mira sagt Nein), ein Haus als emotionaler Mittelpunkt, acht unsichtbare Facetten statt Stats, wachsender Humor. Kernkonflikt: kontrollierte Sicherheit gegen lebendige Wirklichkeit. Die Metapher wird gezeigt, nie erklärt; keine Therapiesprache, keine Diagnosen, keine Moralpunkte.

Der Vertical Slice (45–60 Min) muss die Produktthese beweisen: Movement macht Spaß, Elysia ist attraktiv, das Unbehagen entsteht unerklärt, der Übertritt ist substanziell, Mira funktioniert, ein nicht-klassischer Encounter (Antreiber) ist verständlich, das Haus wirkt, der Humor trägt, und Tester wollen weiterspielen. Danach: STOP und Playtest-Gate.

---

## B. Critical Review

### B1. Widersprüche und Spannungen

| # | Spannung | Bewertung / Vorschlag |
|---|----------|-----------------------|
| 1 | **Qualitätsanspruch (High-End-Pixel-Art, tragende Musik) vs. Zero-Budget vs. Claude-Fähigkeiten.** Claude Code kann keine handgezeichnete Pixel-Art und keine Musik auf Produktniveau liefern. | Der Slice wird mit Placeholdern validiert. Die Success Gates vermischen Fragen, die mit Placeholdern testbar sind (Movement, Mystery, Mira, Encounter, Desire), mit Fragen, die es nicht sind (Elysia-Attraktivität, Art/Licht/Wetter/Audio-Zusammenspiel). Vorschlag: Gates in **Klasse M (Mechanik/Narrativ)** und **Klasse Ä (Ästhetik)** trennen; Klasse Ä erst nach einem Art-Pass bewerten oder ausdrücklich als "mit Placeholdern geschätzt" markieren. |
| 2 | **Risiko 9 (Elysia 30–60 Min attraktiv) vs. Slice gibt Elysia 18 Min.** | Akzeptabel für einen Proof, aber das Gate "Spieler mögen Elysia" muss relativ gelesen werden: "Hätten Spieler gern länger in Elysia verweilt, bevor es kippte?" Elysia im Slice auf ca. 15–20 Min dimensionieren, nicht kürzer. |
| 3 | **Antreiber im Slice (Tal) vs. Bible (Wald, Akt III).** | Explizit nicht-kanonisch, in Ordnung. Den Encounter als eigenständige Szene bauen, die ohne Tal-Abhängigkeiten in den Wald verschiebbar ist. |
| 4 | **Systemliste des Master-Prompts (~20 Systeme) vs. "so wenig Systeme wie möglich".** | Viele gelistete Systeme sind für den Slice nicht nötig. Klassifikation in B5: Slice-notwendig / Architektur-vorbereitet / nicht im Slice. |
| 5 | **"Keine Placeholder-Dialoge" + Localization-Readiness vs. Sprache des Slice nicht entschieden.** | Muss vor dem Schreiben entschieden werden (Frage G1). |
| 6 | **"Pixel-Art ist keine Sparmaßnahme" (Risiko 5) vs. 0 € bis zur Validierung.** | Die Bible löst das selbst (Budget nach Validierung). Konsequenz: Playtester müssen gebrieft werden, dass Grafik und Musik Platzhalter sind. Sonst wird das Gate "Desire" durch Placeholder-Optik verfälscht. |
| 7 | **Movement-Liste ("muss ohne Content Spaß machen") + Pixel-Perfect-Rendering.** | Smooth Camera vs. Pixel-Snapping erzeugt bekannten Jitter. Lösbar (Subpixel-Offset auf dem Viewport), aber Phase-1-Risiko, früh prüfen. |
| 8 | **Konsolenoption vs. Open-Source-Engine.** | Konsolen-Ports bei Godot nur über Drittanbieter (kostenpflichtig, NDA). Für V1 (Desktop, kostenlos) irrelevant. Architektur-Impact: keiner, solange Input, Save-Pfade und UI-Skalierung abstrahiert bleiben. |
| 9 | **"Keine Achievements deaktivieren" (Accessibility) vs. "keine Achievements" (Nicht implementieren).** | Kein Widerspruch, nur Klarstellung: Im Slice gibt es keine Achievements; die Regel gilt später. |
| 10 | **Foreshadowing-Matrix nennt den Betäuber als früh sichtbar; Slice-Plan nennt ihn nicht.** | Empfehlung: unbenannter, charmanter Gastwirt-NPC in Elysia (ein Dialog, "Du musst heute nicht weiter"). Kosten: ein NPC. Entscheidung: G7. |

### B2. Risiken (nach Schwere)

1. **Art/Audio-Lücke.** Höchstes Risiko für die Gates. Mitigation: Gate-Klassen (B1.1), konsistentes CC0-Placeholder-Set, saubere Austauschbarkeit, Art-Pass nach Validierung.
2. **Antreiber-Mechanik unverständlich oder zufällig gelöst.** Mitigation: Grey-Box-Prototyp bereits in Phase 1/2 (vor Content), zwei bis drei Umgebungs-Hinweise, Timing-Assist, Playtest-Frage "verständlich oder zufällig?".
3. **Riss-Entdeckung: zu versteckt (Frust) oder zu offensichtlich (Marker-Spam).** Mitigation: Entdeckung über Wahrnehmungs-Cues (Schmetterlingsrouten, Spiegelteich, Kind), plus stille Fallback-Guidance nach X Minuten (das Kind zeigt sich erneut).
4. **Writing-Qualität und Stimmen.** Claude-Entwürfe brauchen Voice-Sheets pro Figur und Redaktion durch dich. Mitigation: CONTENT_GUIDE mit Voice-Sheets vor der Dialogproduktion; Dialoge in kleinen Review-Paketen.
5. **Claude kann das Spiel nicht fühlen.** Movement-Feel und Pacing brauchen deine Playsessions. Mitigation: Screenshot-/Video-Pipeline (Xvfb + Godot Movie Maker + ffmpeg, alles vorhanden) für Sichtprüfung durch Claude; kurze Feedback-Schleifen mit dir pro Phase.
6. **Cloud-Umgebung ohne Godot.** Ohne Netzwerkfreigabe keine Headless-Tests/Exporte in Cloud-Sessions. Mitigation: siehe H (Allowlist oder Setup-Script).
7. **Scope Creep über die Systemliste.** Mitigation: B5-Klassifikation ist verbindlich; neue Systeme nur über DECISIONS.md.
8. **Handgeschriebene `.tscn`-Dateien sind fehleranfällig; TileMap-Zelldaten sind nicht sinnvoll handschreibbar.** Mitigation: Map-Workflow entscheiden (G3), kleine Szenen, Content-Validator in Dev-Builds.
9. **Save-Robustheit.** Mitigation: JSON statt `str_to_var` (Objekt-Instanziierung aus Dateien vermeiden), Schema-Version, atomare Writes, Backup, Tests.
10. **Pacing 45–60 Min ist erst spielbar messbar.** Mitigation: Content auf ca. 50 Min zielen, Puffer für Streichungen; Zeitstempel-Logging in Dev-Builds pro Beat.

### B3. Fehlende Entscheidungen

Sprache des Slice; Art-/Audio-Quelle; Map-Workflow; dein lokales Setup und Ziel-OS der Tester; Dependency-Freigabe (Dialogue-Tool, Testframework); Repo-Sichtbarkeit (CI-Minuten); Umfang der Charakter-Customization im Slice; Betäuber-Cameo; Antreiber-Konzept. Alle in G.

### B4. Technische Probleme (konkret, mit Lösungsvorschlag)

- **Fehlende Spiegelung des Protagonisten:** keine Viewport-Spiegelung der ganzen Welt. Stattdessen "Reflection-Child"-Sprites an reflektierbaren Entitäten (gespiegelt, getönt, Wellen-Shader); der Spieler hat schlicht kein solches Child. Präzise, billig, erklärt sich selbst.
- **Namenseingabe mit Controller:** Onscreen-Keyboard nötig (ca. ein Arbeitstag). Alternativ nur Tastatur im Slice. Vorschlag: einfaches Onscreen-Keyboard, Elysia-Stil.
- **Pixel-Perfect-Camera:** Rendering in Basisauflösung (Vorschlag 640×360), Integer-Scaling, Subpixel-Kamera-Offset für ruhiges Scrolling. Phase-1-Aufgabe mit Abnahme durch dich.
- **TileMap-Autoring:** Terrain-Autotiling über Godot-Terrain-Sets; Zellen aus textbasierten Kartendateien (ASCII mit Legende) oder externem Tool. Siehe G3.
- **Lizenz-Hygiene bei Placeholder-Audio:** nur CC0 (Kenney, freesound mit CC0-Filter). CC-BY nur mit gepflegter CREDITS-Datei.
- **Godot-Importcache:** `.godot/` ignorieren, `.uid`-Dateien committen, CI führt `--import` vor Tests aus.

### B5. Unnötiger Scope für den Slice (Klassifikation)

| System | Slice | Begründung |
|--------|-------|------------|
| Movement, Kamera, Kollision, Interaktion, Sprint, Footsteps nach Terrain | **notwendig** | Kern der Gates |
| Dialog mit Choices, Conditions, Schweigen, Skip, Textgeschwindigkeit | **notwendig** | Kern |
| World State (Flags, Quests, Relationship Mira, Haus, Inventar) | **notwendig** | Grundlage für Konsequenzen und Save |
| Save/Load (Autosave + 3 Slots, versioniert, atomar) | **notwendig** | Bible: von Anfang an robust |
| Elysia-Layer (XP, Level, Gold, Loot-Popups, Seltenheit als Anzeige) | **notwendig, minimal** | rein kosmetisch, keine Stats |
| UI-Modi ELYSIA / REAL | **notwendig** | Kern des Übertritts |
| Quest-System (Main/Side, Stages, Konsequenzen) | **notwendig, klein** | 1 Miniquest, 1 Main-Faden, 1 Sidequest |
| Journal | **notwendig, minimal** | eine Seite, zwei Skins |
| Wetter (Regen, Wind auf Gras), Licht (Elysia flach vs. Tal dynamisch, Abend) | **notwendig** | Übertritt muss spürbar sein |
| Audio-Direktor (Buses, Musikzustände, Crossfade, Elysia-Loop) | **notwendig** | Musiktransformation ist Identität |
| Antreiber-Encounter | **notwendig** | eigene Szene |
| Haus: Feuer, Kuriositäts-Slot, Gespräch; Katze draußen | **notwendig, minimal** | nur Phase "kalt → Feuer" |
| Settings/Accessibility-Basis (Textgröße, Dialoggeschwindigkeit, Auto-Advance, Screen Shake, Flash, Hold/Toggle, Lautstärken, Timing-Assist) | **notwendig** | Architektur, nicht Add-on; alle sind billig, wenn von Anfang an als Settings-Signale gebaut |
| Input-Abstraktion (Actions), Controller + Keyboard | **notwendig** | nativ in Godot |
| Rebinding-**UI** | **vorbereitet** | Actions sind rebindbar; UI erst nach dem Slice |
| Facetten | **vorbereitet** | im Slice nur 1–2 Momente → interne Flags, kein System |
| Collectibles (Erinnerungen, Melodien) | **nicht im Slice** | Kuriosität = 1 Item + 1 Slot |
| Relationship-System über Mira hinaus | **nicht im Slice** | Mira: 3–4 Zustände |
| Hausphasen über "Feuer" hinaus, Garten, Dekoration | **nicht im Slice** | |
| Character Look/Attention, Windreaktion am Spieler, Schnee/Spuren | **nicht im Slice** | Polish nach Validierung |
| Controller-Hotplug | **nativ** | kein Aufwand |
| Charakter-Customization | **minimal** | Name + 2–3 Presets (G8) |

### B6. Designrisiken

- **Elysia zu früh creepy.** Lob zuerst angenehm, Wiederholung erst ab Beat 2; Timing in Playtests messen ("Wann hast du erstmals gemerkt...").
- **Mira als Plot-Device.** Voice-Sheet, eigenes Ziel (Meer), eigene Beschäftigung in jeder Szene, ein Nein mit echtem Preis für den Spieler.
- **Fake Choices.** Jede Choice-ID muss im Content-Validator mindestens eine Konsequenz (State-Änderung oder konditionale Reaktion) referenzieren. Ein Dev-Check meldet Choices ohne Konsequenz. Billig, erzwingt die Regel.
- **Humor-Dichte.** Elysia 2/10, Tal 3/10: ein Running-Gag-Start (Ziege oder Kartoffel), kein Dauerwitz.
- **Antreiber als Karikatur.** Er muss im Slice einmal nützlich sein (er bringt den Spieler tatsächlich schnell voran, bevor es kippt).

---

## C. Engine Comparison

Kriterien aus dem Master-Prompt, bewertet für genau dieses Projekt (2D Pixel-Art, Licht/Wetter, kein Combat, Desktop zuerst, 0 €, Claude-Code-Workflow ohne GUI in der Cloud).

| Kriterium | Godot 4.x | Unity 6 | GameMaker | MonoGame/FNA | Defold | LÖVE | Phaser/Web |
|-----------|-----------|---------|-----------|--------------|--------|------|------------|
| 2D-Pixel-Workflow (TileMap, Autotile, Sprites, Pixel-Snap) | sehr gut, nativ | gut (2D-Pakete) | sehr gut | selbst bauen | gut | selbst bauen | gut |
| 2D-Licht, Schatten, Shader, Partikel | nativ (Light2D, Shader, GPUParticles2D) | nativ (URP 2D) | eingeschränkt | selbst bauen | eingeschränkt | selbst bauen | eingeschränkt |
| Audio (Buses, interaktive/layered Streams) | nativ (AudioStreamInteractive seit 4.3) | nativ | ok | selbst bauen | ok | ok | ok |
| Controller, Rebinding, Hotplug | nativ (InputMap) | nativ | ok | ok | ok | ok | eingeschränkt |
| UI/Theming, Textskalierung | nativ (Control, Theme) | nativ (UI Toolkit) | selbst bauen | selbst bauen | eingeschränkt | selbst bauen | HTML/DOM |
| Lokalisierung | nativ (CSV/PO, tr()) | Paket | ok | selbst bauen | ok | selbst bauen | selbst bauen |
| Save | selbst (einfach) | selbst | selbst | selbst | selbst | selbst | selbst |
| Desktop-Export (Win/mac/Linux) | nativ, CLI, kostenlos | nativ | kostenpflichtig (Pro) | ja | ja | ja | nur via Electron |
| Konsole später | Drittanbieter (kostenpflichtig) | nativ (Plattformfreigabe) | kostenpflichtig | NDA/Partner | Partner | nein | nein |
| Performance für 2D | mehr als ausreichend | ausreichend | gut | sehr gut | sehr gut | gut | mäßig (Licht) |
| Kosten/Lizenz | 0 €, MIT | 0 € < 200k $ Umsatz; Vertrauensverlust 2023; closed source | Free nicht-kommerziell; Export kostenpflichtig | 0 €, Ms-PL/MIT | 0 €, permissiv | 0 €, zlib | 0 €, MIT |
| Claude-Code-Workflow (Text-Dateien, Headless-CLI, Tests ohne GUI) | **sehr gut**: `.tscn/.tres` sind Text, `--headless` für Import/Tests/Export, GDScript ohne Build-Schritt | mäßig: Editor-zentriert, Batchmode schwerfällig, Lizenz-Login | mäßig: proprietäres Projektformat | sehr gut (alles Code), aber alles selbst bauen | gut (Text-Formate) | sehr gut, aber alles selbst bauen | sehr gut |
| Community/Plugins für 2D-Narrative | groß (Dialogue Manager, GUT, YATI) | sehr groß | mittel | klein | klein | mittel | groß (Web) |
| Build-Pipeline, CI | einfach, kostenlos | komplex (Lizenzaktivierung in CI) | eingeschränkt | einfach | einfach | einfach | einfach |
| Wartbarkeit langfristig | gut, offen | gut, aber Herstellerabhängig | Herstellerabhängig | gut | mittel | gut | Plattform-Mismatch |

**Empfehlung: Godot 4.x (neueste stabile 4.x beim Setup pinnen, mindestens 4.5) mit typisiertem GDScript.**

Begründung:
- Erfüllt alle Slice-Anforderungen nativ: 2D-Licht, Shader, Partikel, Wetter-Tauglichkeit, TileMap-Terrains mit Custom-Data (Footstep-Oberflächen), Audio-Buses und interaktive Musikstreams, InputMap mit Rebinding, Theme-basiertes UI, CSV-Lokalisierung, Integer-Scaling.
- 0 €, MIT, kein Umsatzanteil, keine späteren Kostenfallen. Passt exakt zu Abschnitt 51.
- Bester Claude-Code-Fit aller Editor-Engines: Szenen und Ressourcen sind diffbare Textdateien, GDScript braucht keinen Build-Schritt, `--headless` erlaubt Import, Tests und Exporte ohne GUI. Mit Xvfb und Software-GL (hier vorhanden) kann Claude Screenshots und Videos des laufenden Spiels erzeugen und selbst prüfen.
- Ausreichende Community-Werkzeuge ohne Kosten: Dialogue Manager (MIT), GUT (MIT), gdtoolkit für Lint/Format (MIT, via PyPI, hier erreichbar).

Ehrliche Nachteile:
- Konsolen-Ports nur über kostenpflichtige Partner. Für V1 irrelevant.
- GDScript-Tooling ist schwächer als C#. Mitigation: statische Typisierung erzwingen (Warnungen als Fehler), gdlint in CI, Tests für State/Save/Quest.
- `.tscn` per Hand ist bei großen Szenen unübersichtlich. Mitigation: kleine, komponierte Szenen; Maps aus Textdaten generieren.
- WorldEnvironment-Glow in 2D nur mit Forward+/Mobile-Renderer. Entscheidung Renderer in Phase 3 (Forward+ Standard, Compatibility als Fallback testen).

Warum nicht Unity: Editor-/Lizenz-zentrierter Workflow passt schlecht zur Cloud-Session ohne GUI, closed source, Vertrauensrisiko nach der Runtime-Fee-Episode, kein Vorteil für 2D-Pixel-Art. Warum nicht MonoGame/LÖVE: Licht, Partikel, UI, TileMaps, Lokalisierung komplett selbst bauen; das ist genau das Overengineering, das der Prompt verbietet. Warum nicht GameMaker: Export kostenpflichtig, proprietär. Warum nicht Web/Phaser: Desktop nur über Electron, keine Konsolen-Perspektive, Licht/Shader-Qualität schwächer.

---

## D. Technical Architecture Proposal (High-Level)

### D1. Prinzipien
Einfach, modular, datengetrieben, testbar, austauschbar. Autoloads nur für echte Querschnitte. Keine Questlogik in UI, kein Game-State in Rendering-Code. Kein Event-Bus-Wildwuchs: wenige typisierte Signale.

### D2. Schichten

```
core/        Autoloads: Game (Zustandsmaschine Boot/Menu/Play), WorldState, SaveSystem,
             Settings (Accessibility + Audio-Levels + Input-Overrides), AudioDirector,
             Log, DebugTools (nur Dev-Builds)
entities/    Player, NPC (Routen, Dialog-Hook, Reflection-Child), Interactables
             (Door, Lever, Fireplace, Pickup, Sit, CuriositySlot), Animal (Katze)
world/       Maps (Elysia, Riss-Übergang, Tal, Haus), Systems (Weather, DayLight,
             Water/Reflection, Footsteps)
encounters/  antreiber/ (eigenständige Szene mit eigener Mini-Zustandsmaschine)
ui/          hud/elysia, hud/real, dialogue_box (zwei Skins), journal, inventory,
             menus, settings, onscreen_keyboard
content/     dialogue/*.dialogue, quests/*.tres, items/*.tres, curiosities/*.tres,
             locale/*.csv, maps/*.txt (textbasierte Kartendaten, je nach G3)
assets/      placeholder/ (sprites, tiles, audio, fonts) + PLACEHOLDERS.md
tests/       unit/ (WorldState, Save, Quest, Dialog-Conditions, Inventory), smoke/
tools/       export.sh, screenshot.gd, validate_content.gd, map_build.gd
docs/        README, ARCHITECTURE, GAME_BIBLE, CONTENT_GUIDE, SAVE_FORMAT,
             DECISIONS (ADRs), PLACEHOLDERS, KNOWN_ISSUES, PLAYTEST
.github/     ci.yml (Import, Lint, Tests, Export Win/Linux)
```

### D3. State-Modell (kein Boolean-Haufen)
`WorldState` hält typisierte Teilmodelle: `StoryFlags` (namespaced IDs wie `elysia.mirror_noticed`), `Quests` (id → stage, objectives, outcome), `Relationships` (npc_id → State-Enum stranger/cautious/familiar/close/strained + Erinnerungs-Flags), `Facets` (facet_id → tier, im Slice nur Flags), `House` (fire_lit, curiosity_slots), `Inventory` (item_id → count), `Discovered` (locations), `Player` (name, preset, map, position), `UiMode` (ELYSIA/REAL), `ElysiaProgression` (xp, level, gold, kosmetisch). Änderungen nur über Methoden mit Logging-Kategorie WORLD_STATE.

### D4. Content-Formate

| Inhalt | Format | Warum |
|--------|--------|-------|
| Dialoge | Dialogue Manager `.dialogue` (Text) | lesbar/schreibbar für dich und Claude, Conditions/Mutations, Choices, statische Zeilen-IDs, POT-Export |
| Quests, Items, Kuriositäten | Godot-Resources `.tres` (Text) | typisiert, im Editor inspizierbar, Validator beim Laden |
| Maps | `.tscn` für Objekte/NPCs + Zelldaten aus Textkarte oder externem Tool (G3) | TileMap-Daten sind nicht handschreibbar |
| Lokalisierung | CSV → `.translation`, `tr()` überall | nativ, eine Sprache in V1, Struktur von Anfang an |
| Settings | `user://settings.cfg` (ConfigFile) | nativ |
| Saves | `user://saves/slotN.json` + `.bak`, Autosave-Slot | sicher (kein Code aus Dateien), versioniert, migrierbar |

### D5. Kernsysteme (knapp)
- **Dialog:** Dialogue Manager Runtime + eigene DialogueBox (Skin je UiMode). Choices tragen IDs; Konsequenzen als Mutations auf WorldState. "…" ist Standardoption, wo sinnvoll. Textgeschwindigkeit, Auto-Advance, Skip aus Settings.
- **Quest:** Quest-Resource mit Stages und Objectives; Übergänge nur über `WorldState.advance_quest()`; Journal rendert Stage-Texte (handschriftlich formuliert, lokalisiert). Marker: keine im Slice außer optional für die Elysia-Miniquest (Elysia darf Marker-Spam zeigen, das ist Teil der Täuschung).
- **Elysia-Layer:** `ElysiaProgression` + HUD-Popups (XP, Level-Up, Loot mit Seltenheitsfarbe + Text, Gold). Nach dem Riss: UiMode=REAL, Layer deaktiviert, Inventar auf Stein/Samen reduziert.
- **UI-Modi:** HUD-Szene wird je Modus getauscht; DialogueBox/Journal wechseln Theme. Übergang als eigene Sequenz (Elemente verschwinden einzeln).
- **Audio:** Buses Master/Music/Ambience/SFX/UI. AudioDirector mit Musikzuständen (ELYSIA_LOOP, SILENCE, VALLEY_AMBIENT, HOUSE_WARM, ANTREIBER) und Crossfades; später AudioStreamInteractive für Layer.
- **Wetter/Licht:** Weather-Node (Regen-Partikel, Wind-Uniform für Gras-Shader, Pfützen), DayLight (CanvasModulate-Kurve, Abend). Elysia: flach, hell, ohne Schatten. Tal: dynamisch.
- **Input/Accessibility:** Actions in InputMap; Settings-Autoload mit Signalen; Hold/Toggle für Sprint; Timing-Assist-Multiplikator für Encounters; Screen-Shake- und Flash-Flags an Kamera/Effekten.
- **Save:** Serialisierung von WorldState + Player; Schema-Version; Migrationsliste; Schreiben in Temp-Datei, dann Rename; Backup-Rotation; Ladefehler → klare Meldung, kein Absturz.
- **Debug:** Dev-Overlay (Teleport, Flags, Quests, Relationship, Items, UiMode, Save/Load), nur `OS.is_debug_build()`.
- **Tests:** GUT headless für State/Save/Quest/Dialog-Conditions/Inventory; Smoke-Test lädt jede Map. gdlint/gdformat in CI.

### D6. Pixel-Pipeline (Arbeitsstandard, bis Art-Produktion änderbar)
Basisauflösung 640×360 (×3 = 1080p, ×6 = 4K), Integer-Scaling, 16-px-Tiles, Charakterzellen 32×48 (Platz für Hüte und Frisuren später), Snap-2D-Transforms aktiv, Subpixel-Kamera-Offset. Renderer: Forward+ Standard; Compatibility in Phase 3 als Fallback prüfen.

### D7. Dependencies (alle 0 €, alle MIT)
Godot 4.x · Dialogue Manager · GUT · gdtoolkit (Lint/Format) · optional YATI oder LDtk-Importer (nur bei G3 = externes Tool). Fonts: OFL/CC0-Pixelfont mit Umlauten (z. B. Pixel Operator; Lizenz bei Auswahl prüfen). Alles andere nativ oder selbst gebaut. Jede Dependency bekommt einen ADR-Eintrag.

---

## E. Vertical Slice Production Plan

### E1. Phasen

| Phase | Ziel | Deliverables | Definition of Done | Aufwand (Claude-Arbeitstage) |
|-------|------|--------------|--------------------|------------------------------|
| **0 Tech Pre-Production** | Projekt steht, Pipeline läuft | Repo-Struktur, project.godot (Auflösung, Stretch, Input-Actions, Buses, Lokalisierung), Dependencies, CI (Import, Lint, Tests, Export Win/Linux), Docs-Skelett, ADR-001…006, Placeholder-Beschaffungsliste, Cloud-Setup (Godot-Download) | CI grün mit leerem Spiel; Export startet auf deinem Rechner; `docs/` vollständig als Skelett | 1–2 |
| **1 Movement Sandbox** | Movement macht ohne Content Spaß | Player-Controller (8-dir, Beschleunigung, Sprint Hold/Toggle), Pixel-Perfect-Kamera, Kollision, Interaktions-Prompt, Footsteps nach Terrain, Grey-Box-Map, Controller+Keyboard, **Antreiber-Grey-Box** (Mechanik ohne Art) | Du bestätigst Feel nach Playsession; Antreiber-Grey-Box von dir "verständlich" bewertet oder iteriert | 2–3 |
| **2 Narrative Systems** | Zustand, Dialog, Quest, Save tragen | WorldState, SaveSystem (Autosave + Slots, Migration, atomar), Dialogue-Integration + DialogueBox, Choice-Konsequenz-Validator, Quest-System + Journal, Relationship Mira, Settings/Accessibility-Basis, Debug-Overlay, Tests, Logging | Tests grün (State, Save-Roundtrip, Quest-Übergänge, Conditions); Save während Dialog/Encounter/Load geprüft; Controller-Navigation in allen UIs | 4–6 |
| **3 Art/Audio Prototype** | Elysia-Look vs. Tal-Look spürbar | Placeholder-Integration, Elysia-Licht, Tal-Licht + Abend, Regen, Wind-Gras, Pfützen, Spiegelteich ohne Spieler, Partikel, UI-Skins Elysia/Real, Audio-Buses, Musikzustände, Elysia-Loop, Renderer-Entscheidung, erster Performance-Check | Screenshot-/Video-Vergleich Elysia vs. Tal; stabil 60 fps auf deinem Rechner; Übergangssequenz UI-Verlust spielbar | 3–5 |
| **4 Slice Content** | 45–60 Min spielbar | Beats 1–7 (E2), Dialoge nach Voice-Sheets, Writing-Review-Pakete an dich, Pacing-Pass | Durchspielbar ohne Debug; Zeitmessung 45–60 Min; keine Placeholder-Dialoge; Save/Load an jedem Beat | 10–15 |
| **5 Playtest Gate** | STOP + Validierung | Build (Win/Linux, mac unsigniert), Testanleitung, Known Issues, Playtest-Fragen (Abschnitt 48 + Gate-Klassen), Risikobericht, Performance-Bericht, Placeholder-Liste, nächste Schritte | Alle Artefakte in `docs/`; Build an Tester verteilt | 1–2 |

Gesamt grob 21–33 Claude-Arbeitstage plus deine Zeit für Playsessions, Writing-Review und Entscheidungen. Realistisch 8–14 Kalenderwochen bei Teilzeit. Abhängigkeiten: 1 ← 0; 2 ← 0; 3 ← 1; 4 ← 1, 2, 3; 5 ← 4. Phasen 2 und 3 können parallel laufen.

### E2. Slice-Beats mit Systemen und Assets

| Beat | Minuten | Inhalt | Systeme | Placeholder-Assets |
|------|---------|--------|---------|--------------------|
| 1 Elysia | 0–10 | Erwachen, Name, Preset; Dorf; 5–6 NPCs mit Lob; Miniquest (Vorschlag: "Die goldenen Schmetterlinge", Routen fix = späteres Clue); Truhen, Loot mit Seltenheit, +XP, 2 Level-Ups, Gold; eine humorvolle Situation (z. B. Loot "Ein Kompliment, legendär"); optional Betäuber-Cameo als Gastwirt | Movement, Interaktion, Elysia-Layer, Dialog, Quest, Journal (Elysia-Skin) | Elysia-Tileset, Player, 6 NPCs, Elysia-UI, Elysia-Loop-Musik |
| 2 Irritation | 10–18 | NPCs wiederholen Sätze und Wege; Spiegelteich ohne Spieler-Reflexion; Stein (Loot-Popup stolpert: "Seltenheit: —"); Kind kurz sichtbar; Riss (versteckt; Fallback-Guidance nach Zeit) | Reflection-Children, NPC-Routen, Flags | Teich-Shader, Kind-Sprite, Riss-Effekt |
| 3 Übergang | 18–25 | Sequenz: UI-Elemente verschwinden einzeln, Musik → Stille → Regen; Real-UI; Mira (eigene Beschäftigung); erstes Nein mit Preis (sie nimmt ihn nicht mit; sie hat Eigenes vor) | UiMode-Wechsel, Weather, AudioDirector, Relationship Mira | Tal-Tileset, Regen, Mira-Sprite, Real-UI |
| 4 Tal | 25–35 | Exploration; Umweltpuzzle (z. B. Bachsteine/umgestürzter Baum, zwei Lösungswege); Wiederbegegnung: Mira widerspricht (Choice mit Konsequenz); Haus entdecken (leer, kalt) | Puzzle-Interactables, Choice-Konsequenz | Puzzle-Objekte, Haus-Außen/Innen |
| 5 Antreiber | 35–45 | Eigene Szene (Konzept E3) | Encounter-Zustandsmaschine, Timing-Assist | Antreiber-Sprite, Pfad-Segmente |
| 6 Haus | 45–52 | Feuer machen; Ruhe; Gespräch; Kuriosität in Slot platzieren; Katze draußen (füttern optional, keine Freischaltung) | House-State, CuriositySlot, Light-Warm | Feuer, Kuriosität ("Sehr kleiner Löffel"), Katze |
| 7 Abend | 52–60 | Kurze humorvolle Sidequest (Kandidaten: Ziege auf dem Dach; "Die Kartoffel"); Abendlicht; Mira: "Morgen gehe ich weiter." / "Wohin?" / Blick zu den Bergen / "Zum Meer." Schwarz. Titel. | Sidequest, DayLight, Ende-Sequenz | Ziege, Abend-Palette, Titelkarte |

### E3. Antreiber-Konzept (Vorschlag zur Bestätigung, G10)

"Der Weg, der nicht endet." Ein Pfad im Tal; der Antreiber begleitet als Stimme/Figur, zuerst nützlich (er bringt den Spieler wirklich schnell über eine lange Strecke). Mechanik: Sprint-Tempo steigt mit Tastendruck/Mash; je schneller, desto mehr Pfadsegmente entstehen, das Ziel rückt weiter, Lob-Popups im Elysia-Echo ("Fast! Noch ein Stück!"). Stehenbleiben (kein Input für ca. 3–4 s, per Timing-Assist einstellbar) beendet das Wachsen: Umgebung wird sichtbar (Bank, sitzender Vogel, später Mira oder das Kind), das Ziel liegt direkt daneben. Hinweise: Bänke am Weg, ein NPC, der sitzt, Antreiber-Dialog, der beim Stehen stockt. Kein Game Over; mehrere "Lösungsgeschwindigkeiten" statt Scheitern. Alternative B (Hebel-Rennen) ist weniger körperlich erfahrbar; A empfohlen.

### E4. Cut-first für den Slice (wenn Aufwand explodiert)
Onscreen-Keyboard (→ nur Tastatur), Presets (→ ein Look), Pfützen, Katze-Füttern, zweite Puzzle-Lösung, Betäuber-Cameo, Sidequest-Länge. Nicht streichen: Elysia/Real-Kontrast, Mira-Nein, Movement, Haus-Feuer, Antreiber, Musik-/Sound-Kontrast, Riss, Abend-Ende.

---

## F. Cost Check

| Posten | Kosten | Vermeidung / Entscheidung |
|--------|--------|---------------------------|
| Engine Godot | 0 € (MIT) | – |
| Dialogue Manager, GUT, gdtoolkit, YATI/LDtk-Importer | 0 € (MIT) | – |
| Placeholder-Art | 0 € (CC0: Kenney, OpenGameArt-CC0-Filter) | Lizenz je Asset in PLACEHOLDERS.md |
| Placeholder-Audio/Musik | 0 € (CC0: Kenney Audio, freesound CC0) | keine CC-BY ohne Credits-Pflege |
| Fonts | 0 € (OFL/CC0) | Umlaute prüfen |
| CI (GitHub Actions) | 0 € bei öffentlichem Repo; privat 2.000 Min/Monat | **Kostenfalle:** macOS-Runner zählen 10×; nur Ubuntu-Runner nutzen |
| Git LFS | 0 € bis 1 GB, danach kostenpflichtig | **vermeiden**; PNG/OGG klein halten |
| macOS-Signierung/Notarisierung | 99 $/Jahr Apple Developer | **vermeiden** im Slice; unsignierte Builds für Tester (Rechtsklick → Öffnen) |
| Playtest-Distribution | 0 € (GitHub Releases, itch.io passwortgeschützt) | – |
| Pixel-Art-Editor (falls du zeichnest) | Aseprite 20 $ einmalig **oder** 0 € (Aseprite aus Quellcode, LibreSprite, Pixelorama) | deine Wahl, nicht nötig |
| Map-Editor Tiled/LDtk | 0 € | – |
| Konsolen-Port | später, vierstellig | nicht jetzt |
| Professionelle Art, Musik, SFX, QA, Lokalisierung | nach Validierung, Budgetentscheidung | explizit später |
| Claude Code | bereits vorhanden | – |

Fazit: Der komplette Slice ist mit 0 € zusätzlichen Kosten machbar. Einzige echte Qualitätsgrenze: Art und Musik bleiben Placeholder.

---

## G. Fragen (priorisiert)

Blockierend vor Phase 0:
1. **Sprache des Slice:** Deutsch, Englisch oder beides? Empfehlung: Deutsch (Bible, Prompt und vermutlich Tester sind deutschsprachig; Englisch später per CSV).
2. **Art-/Audio-Quelle für den Slice:** CC0-Placeholder-Packs, eigene Pixel-Art/Musik von dir oder deinem Umfeld, oder rein programmatische Placeholder? Empfehlung: CC0-Packs für Tiles/Sprites/SFX, programmatisch nur wo nötig; Musik CC0 oder von dir.
3. **Map-Workflow:** Textkarten (ASCII mit Legende, Claude baut Level, du editierst im Texteditor), du im Godot-Editor, oder Tiled/LDtk (kostenlos) mit Importer? Empfehlung: Textkarten für den Slice, Objekte in `.tscn`; späterer Wechsel zu Tiled/LDtk möglich.
4. **Dein lokales Setup:** Betriebssystem, Godot lokal installiert oder installierbar, Betriebssysteme der Playtester? Bestimmt Export-Ziele und Testablauf.

Wichtig vor Phase 0, aber mit Standardannahme möglich:
5. **Cloud-Umgebung:** Freigabe von `github.com` + `objects.githubusercontent.com` (oder `godotengine.org`) in der Netzwerk-Policy, damit Claude Godot headless laden und Tests/Exporte in Cloud-Sessions ausführen kann. Alternativ Setup-Script der Umgebung. Ohne das: Tests laufen nur in CI und bei dir lokal.
6. **Dependency-Freigabe:** Dialogue Manager + GUT + gdtoolkit (alle MIT, 0 €). Alternative: eigenes Dialogsystem (ca. 3–5 Tage Mehraufwand, dafür null Lock-in). Empfehlung: Dialogue Manager mit dünner Adapter-Schicht.
7. **Betäuber-Cameo in Elysia:** ja (unbenannter Gastwirt) oder nein? Empfehlung: ja.
8. **Charakter-Customization im Slice:** nur Name, oder Name + 2–3 symmetrische Presets? Empfehlung: Name + 3 Presets (Palette-Swap).
9. **Repo-Sichtbarkeit:** öffentlich oder privat? Beeinflusst CI-Minuten und Tester-Zugang.
10. **Antreiber-Konzept E3:** bestätigen oder Richtung ändern?

Nicht jetzt nötig (Content-Brief zu Phase 4): Details des Mira-Neins, Puzzle-Variante, Sidequest-Wahl, Miniquest-Wahl, Kuriosität, Katzen-Interaktion.

### G-Antworten (bereits entschieden)

| Frage | Entscheidung | Konsequenzen für die Umsetzung |
|-------|--------------|--------------------------------|
| G1 Sprache | **Deutsch** | Quellsprache `de` in `content/locale/*.csv`; Pixelfont mit Umlauten und ß Pflicht (Auswahl in Phase 0 mit Lizenzprüfung); Dialogue-Manager-Zeilen mit statischen IDs, damit Englisch später ohne Logikänderung ergänzt werden kann. ADR-002. |
| G2 Art/Audio | **CC0-Placeholder-Packs** | Beschaffungsliste in Phase 0 (`docs/PLACEHOLDERS.md` mit Quelle, Lizenz, Austauschstatus). Hinweis: `kenney.nl` ist aus der Cloud-Session blockiert; Packs lädst du herunter und committest sie, oder du gibst die Domain frei. Bis Packs vorliegen, erzeugt Claude programmatische Minimal-Placeholder (einfarbige Tiles, Silhouetten), damit Phase 1 nicht blockiert. Playtester werden explizit gebrieft, dass Grafik und Musik Platzhalter sind. ADR-003. |
| G3 Maps | **Textkarten** | `content/maps/<map>.txt` (ASCII, ein Zeichen pro Tile) + Legende (`content/maps/legend.tres`: Zeichen → Terrain/Oberfläche/Kollision). `tools/map_build.gd` erzeugt daraus TileMapLayer-Zellen mit Terrain-Autotiling beim Laden. Objekte, NPCs, Trigger liegen in `.tscn` mit Rasterkoordinaten. Spätere Migration zu Tiled/LDtk bleibt möglich (gleiche Legende). ADR-004. |
| G4 Setup | **Windows + macOS** (Godot-Installation lokal: unbekannt, Annahme: noch nicht) | CI exportiert Windows (`.exe`) und macOS (unsigniertes `.zip`, Gatekeeper-Hinweis in der Testanleitung). Du brauchst für den Editor Godot lokal (kostenlos, Download ca. 100 MB); für reine Playsessions reichen die CI-Builds. **Handy/iPhone:** offen, siehe G11. |

11. **Handy/iPhone:** Entschieden: **Desktop-only für den Slice** (Bible-konform, 0 €). Tester spielen auf Windows/macOS mit Controller oder Tastatur. Mobile wird erst nach der Validierung bewusst entschieden. Architektur bleibt mobile-fähig (Input-Actions, UI-Skalierung, kein Hardcode auf Tastatur), aber es wird keine Touch-UI gebaut. ADR-005.

Offen mit Standardannahme (laufen mit Empfehlung, falls du nichts anderes sagst): G5 Netzwerkfreigabe (Annahme: du gibst `github.com` + `objects.githubusercontent.com` frei oder lädst Godot nicht in der Cloud; bis dahin Tests nur in CI/lokal), G6 Dialogue Manager + GUT + gdtoolkit, G7 Betäuber-Cameo ja, G8 Name + 3 Presets, G9 Repo privat angenommen (Ubuntu-Runner, 2.000 Min/Monat reichen), G10 Antreiber-Konzept A.

---

## H. Empfehlung und nächste Schritte

1. Du beantwortest G1–G4 (und was du von G5–G10 jetzt entscheiden willst; Rest läuft mit Empfehlung).
2. Freigabe dieses Plans = Freigabe für Godot 4.x + GDScript + genannte Dependencies + Architektur D + Roadmap E.
3. Phase 0 startet: Repo-Struktur, project.godot, CI, Docs-Skelett, ADRs, Placeholder-Beschaffungsliste. Erstes Ergebnis: ein leeres Spiel, das in CI baut und bei dir startet.
4. Phase 1 liefert dir einen Movement-Sandbox-Build inklusive Antreiber-Grey-Box zum Fühlen, bevor Content entsteht.
5. Nach jeder Phase: Zusammenfassung, Tests, offene Probleme, Entscheidungen in DECISIONS.md, nächster Schritt.
6. Nach Phase 5: STOP. Keine Full Production ohne Playtest-Ergebnisse.

## Verification (für die Umsetzung ab Phase 0)
- Phase 0: `godot --headless --import && godot --headless -s addons/gut/gut_cmdln.gd` grün in CI; Export-Artefakt startet auf deinem Rechner.
- Phase 1: Playsession von dir mit Feel-Checkliste (Beschleunigung, Stop, Kamera-Ruhe, Controller/Keyboard, Interaktionsprompt); Screenshot-/Video-Pipeline via Xvfb liefert Frames zur Sichtprüfung.
- Phase 2: GUT-Tests für Save-Roundtrip, Migration, Quest-Übergänge, Dialog-Conditions, Choice-Validator; manueller Smoke: Save während Dialog, Load, Abbruch, erneute Interaktion.
- Phase 3: Vergleichs-Screenshots Elysia vs. Tal; Performance-Zahlen (fps, Frame Time, Ladezeit, Save-Dauer) in docs/KNOWN_ISSUES oder PERFORMANCE.
- Phase 4: vollständiger Durchlauf mit Zeitstempeln pro Beat; Content-Validator ohne Fehler; keine Placeholder-Dialoge.
- Phase 5: Build + Testanleitung + Playtest-Fragen in `docs/PLAYTEST.md`.
