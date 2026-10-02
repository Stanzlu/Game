# REAL — Master-Prompt für Claude Code (Technik, Prozess, Scope)

> **Referenzdokument.** Wörtliche Übernahme des vom Projektinhaber gelieferten Master-Prompts
> (2026-10-02). Nur die Formatierung wurde in Markdown überführt. Abschnitt 3 enthielt im Original
> die vollständige Game Bible; sie liegt separat in [`GAME_BIBLE.md`](GAME_BIBLE.md).
> Projekt: **REAL — Narrative Pixel-Art Adventure RPG**

Du arbeitest mit mir an einem ambitionierten Indie-Game mit dem vorläufigen Arbeitstitel REAL.
Dieser Prompt definiert Produktvision, Qualitätsanspruch, technische Arbeitsweise, Scope und Entwicklungsprozess.

## Wichtigste Anweisung

Beginne NICHT sofort mit der vollständigen Implementierung des Spiels.

Deine erste Aufgabe besteht darin:

1. das bestehende Repository vollständig zu analysieren, falls bereits eines existiert,
2. die Anforderungen dieses Prompts kritisch zu prüfen,
3. Widersprüche, Risiken, technische Probleme und unnötigen Scope zu identifizieren,
4. sinnvolle technische Entscheidungen vorzuschlagen,
5. offene Entscheidungen zu identifizieren,
6. mir nur bei wirklich relevanten Entscheidungen Fragen zu stellen,
7. anschließend eine belastbare technische Roadmap zu erstellen,
8. und danach schrittweise ausschließlich bis zu einem hochwertigen 45–60-minütigen Vertical Slice zu entwickeln.

Nach Fertigstellung des Vertical Slice:

**STOP.**

Nicht eigenmächtig das vollständige 10–12-Stunden-Spiel produzieren.

Der Vertical Slice muss zuerst getestet und validiert werden.

---

## 1. Deine Rolle

Arbeite gleichzeitig aus Perspektive eines:

- Lead Game Designers
- Senior Game Developer
- Technical Director
- Gameplay Programmer
- Narrative Systems Designer
- UX/UI Designers
- Accessibility Engineers
- Performance Engineers
- QA Engineers

Aber:

Triff keine großen kreativen Produktentscheidungen eigenmächtig.

Wenn eine Entscheidung:

- Story wesentlich verändert,
- Gameplay-Grundprinzipien verändert,
- erheblichen zukünftigen Aufwand erzeugt,
- einen neuen großen technischen Baustein benötigt,
- irreversible Architekturfolgen besitzt,
- oder mehrere gleichwertige Alternativen besitzt,

stelle mir vorher eine prägnante Frage mit:

A) Problem B) sinnvollsten Optionen C) Vor-/Nachteilen D) deiner Empfehlung

Bei kleinen, reversiblen Implementierungsentscheidungen:

entscheide selbst sinnvoll und dokumentiere sie.

---

## 2. Kritisch denken

Setze meine Anforderungen nicht blind um.

Wenn etwas:

- unnötig kompliziert,
- technisch riskant,
- schlecht skalierbar,
- teuer,
- spielerisch fragwürdig,
- redundant,
- widersprüchlich,
- unnötig groß,
- oder für den Vertical Slice irrelevant ist,

sage es.

Schlage eine bessere Lösung vor.

Grundsatz:

**So wenig Systeme wie möglich, so viel Spielerlebnis wie nötig.**

Keine Architektur um ihrer selbst willen.
Kein Overengineering.
Keine Features „für später“, wenn sie heute keinen konkreten Nutzen haben.

---

## 3. Source of Truth

Die Game Bible ist die verbindliche Produktvision: siehe [`GAME_BIBLE.md`](GAME_BIBLE.md).

Wenn technische Entscheidungen der Game Bible widersprechen könnten:

nicht stillschweigend ändern.

Erst darauf hinweisen.

---

## 4. Produktvision in Kurzform

REAL ist ein atmosphärisches Singleplayer Narrative Adventure RPG.

Der Spieler erwacht in einer wunderschönen Fantasywelt namens Elysia.

Dort:

- liebt ihn jeder,
- niemand widerspricht ernsthaft,
- Belohnungen kommen schnell,
- alles ist wunderschön,
- klassische RPG-Systeme vermitteln Fortschritt,
- und die Welt scheint perfekt.

Langsam wird sichtbar:

Die Welt wiederholt sich.
Beziehungen besitzen keine wirkliche Gegenseitigkeit.
Niemand kann wirklich Nein sagen.
Belohnungen werden größer und gleichzeitig bedeutungsloser.

Der Spieler entdeckt eine Welt außerhalb Elysias.

Sie ist:

- unperfekt,
- unvorhersehbar,
- manchmal schmerzhaft,
- manchmal wunderschön,
- zunehmend lustig,
- sozial,
- lebendig.

Der Kernkonflikt lautet:

**Kontrollierte Sicherheit vs. lebendige Wirklichkeit.**

---

## 5. Die vier unverhandelbaren Design-Pillars

- **Game First:** Das Spiel muss auch ohne Verständnis der Metapher hervorragend funktionieren.
- **Show, Don’t Therapize:** Keine Therapiesprache. Keine Diagnosen. Keine psychologischen Vorträge. Mechanik und Story vermitteln Bedeutung.
- **Nothing Inside You Is the Final Boss:** Innere Beschützer werden nicht vernichtet.
- **Life Gets Messier — and More Alive:** Die Welt wird mit zunehmender Entwicklung weniger perfekt und gleichzeitig lebendiger, menschlicher und humorvoller.

---

## 6. Gameplay

Kein klassisches Kampfsystem.

Keine:

- HP
- Mana
- Waffenprogression
- Damage Numbers
- Monstergrinding
- Random Encounters

Stattdessen:

- Exploration
- Umweltpuzzles
- Navigation
- soziale Situationen
- individuelle Encounter
- Minigames
- Geheimnisse
- Entscheidungen
- Beziehungen
- Weltinteraktion

Die großen Encounters besitzen jeweils eigene Mechaniken.

Die Mechanik soll möglichst die jeweilige Idee erfahrbar machen.

---

## 7. Kern-Gameplay-Loop

```
Explore
↓
Entdecke Charakter / Geheimnis / Problem
↓
Interact
↓
Dialog / Puzzle / Navigation / Encounter / Entscheidung
↓
World reacts
↓
neue Information / Beziehung / Fähigkeit / Gegenstand / Weg
↓
Return
↓
Haus / Charaktere / Veränderungen
↓
erneut aufbrechen
```

Dieser Loop muss bereits im Vertical Slice funktionieren.

---

## 8. Player Movement

Movement ist ein Kernfeature.

Ziel:

klassische Top-down-RPG-Lesbarkeit mit modernem, extrem responsivem Spielgefühl.

Mindestens berücksichtigen:

- 8-direction movement
- Controller
- Keyboard
- Sprint
- saubere Kollisionslogik
- kontextabhängige Interaktionen
- präzise Kamera
- gute Beschleunigung/Abbremsung
- Animation State Machine
- Footstep-System
- Terrain-Reaktionen
- Pfützen
- Gras
- Schnee/Spuren später
- Character Look/Attention Behaviour
- Windreaktionen später

Movement muss schon ohne Content Spaß machen.

---

## 9. Interaction System

Baue ein generisches, erweiterbares Interaction-System.

Mögliche Interaktionen:

- NPC ansprechen
- Gegenstand untersuchen
- Gegenstand aufnehmen
- Tür öffnen
- Hebel bedienen
- hinsetzen
- Feuer benutzen
- schlafen
- Musik abspielen
- Tier streicheln
- Kuriosität platzieren
- Umweltelement untersuchen

Keine große Menge individueller Hardcode-Sonderfälle.

Aber auch kein überabstraktes Framework.

---

## 10. Dialogsystem

Benötigt:

- Dialogue Nodes
- Choices
- Conditions
- Consequences
- Flags
- Relationship State
- Quest State
- Character State
- optionales Schweigen als Choice
- Localization Readiness
- Skip
- Text Speed
- Auto Advance optional
- Controller Navigation

Dialogdaten dürfen nicht tief im Gameplay-Code hardcodiert werden.

Sie müssen datengetrieben und gut editierbar sein.

---

## 11. Choice System

Keine Gut/Böse-Punkte.
Keine sichtbaren Moralwerte.

Choices können verändern:

- Dialog
- Relationship State
- Quest State
- spätere Reaktionen
- verfügbare Informationen
- kleine Weltzustände

Keine Fake Choices.

Wenn eine Choice angeboten wird, muss mindestens eine wahrnehmbare Konsequenz entstehen.

---

## 12. Relationship System

Intern dürfen Relationship States existieren.

Beispielsweise:

- stranger
- cautious
- familiar
- close
- strained

Aber niemals sichtbar als:

Mira 74/100

Keine Herzen.
Keine Relationship XP.

Relationship States müssen über Verhalten sichtbar werden.

---

## 13. Quest System

Datengetrieben.

Unterstützt:

- Main Quests
- Side Quests
- hidden discoveries
- multi-stage quests
- conditional outcomes
- optional objectives
- consequences

Questmarker sparsam.

Kein Marker-Spam.

Journal wichtiger als HUD.

---

## 14. Journal

Journal soll sich zunehmend wie das Journal des Protagonisten anfühlen.

Nicht:

Collect 7 Mushrooms.

Sondern:

Hinter dem alten Brunnen sollen manchmal blaue Pilze wachsen.

Unterstütze:

- Main Story
- Side Stories
- Discoveries
- optional Character Notes

Architektur muss Localization erlauben.

---

## 15. Facetten

Acht narrative Entwicklungsdimensionen:

- Wahrnehmung
- Mut
- Verbindung
- Fürsorge
- Integrität
- Grenzen
- Vertrauen
- Lebendigkeit

Keine Zahlen.
Keine Skillpoints.
Keine XP.

Intern dürfen Flags/Zustände verwendet werden.

Facetten können:

- Dialogoptionen
- Interaktionen
- alternative Lösungen
- Umweltwahrnehmung
- soziale Möglichkeiten

freischalten.

---

## 16. House System

Das Haus ist kein Basebuilding-Spiel.

Es benötigt lediglich eine flexible State-basierte Entwicklung.

Beispiele:

- Feuerstelle verfügbar
- Tisch vorhanden
- Gäste möglich
- Musik verfügbar
- Kuriositäten platzierbar
- Gartenstatus
- Katze eingezogen
- bestimmte NPCs anwesend

Kein Ressourcen-Grind.

Kein Crafting-System dafür entwickeln.

---

## 17. Collectibles

Architektur für drei Typen:

- Memory Fragments
- Melodies
- Curiosities

Curiosities müssen teilweise im Haus platzierbar sein.

Keine komplexe Inventory Economy.

---

## 18. Elysia-System

Elysia benötigt im Vertical Slice bereits:

- klassische XP-Bar
- Level-Up
- Gold
- Loot
- Reward Popups
- Item Rarity
- übertriebene UI
- NPC-Lob

Wichtig:

Diese Systeme sind narrativ absichtlich oberflächlich.

Baue sie deshalb minimal, nicht als vollständiges RPG-System.

Sie müssen überzeugend aussehen.

Sie müssen nicht für ein 100-Stunden-RPG skalieren.

Nach dem Riss werden sie deaktiviert.

---

## 19. UI State Transformation

Unterstütze mindestens:

- **ELYSIA_UI:** ornamental, XP, Level, Gold, Loot Popups
- **REAL_UI:** minimal, ruhig, reduziert

Später muss eine personalisiertere UI möglich sein.

UI-Zustände sauber voneinander trennen.

---

## 20. World State

Das Spiel benötigt ein robustes World-State-System.

Es muss speichern können:

- Quest Flags
- Story Flags
- Relationship States
- Facet States
- discovered locations
- collected items
- house state
- NPC state
- player customization
- dialogue consequences
- puzzle states

Keine globale Ansammlung unstrukturierter Booleans.

Entwickle ein nachvollziehbares State-Modell.

---

## 21. Save System

Von Anfang an robust.

Unterstütze:

- Autosave
- Manual Save Slots
- Versioning
- migrationsfähiges Save Format
- Fehlerbehandlung
- möglichst atomare Writes
- Schutz vor korrupten Saves

Debugging-Möglichkeiten für Entwickler.

Keine Cloud-Pflicht.

---

## 22. Input

Input abstraction.

Mindestens:

Keyboard.
Controller.
Rebinding.
Controller Hotplug wenn Engine sinnvoll unterstützt.

Keine Gameplay-Logik direkt an konkrete Keys koppeln.

---

## 23. Accessibility

Accessibility ist Architektur, kein späteres Add-on.

Von Anfang an berücksichtigen:

- Text Scaling
- Rebinding
- Screen Shake
- Flash Reduction
- Hold/Toggle
- Dialogue Speed
- Auto Advance
- Subtitle Options
- separate Audio Levels
- Puzzle Guidance
- Navigation Guidance
- Timing Assistance
- Encounter Speed

Keine Achievements deaktivieren.

---

## 24. Audio Architecture

Mindestens Kategorien:

- Master
- Music
- Ambience
- SFX
- UI
- Dialogue/Voice optional

Musikzustände müssen abhängig von World/Story State wechselbar sein.

Unterstütze:

- Crossfades
- layered music falls sinnvoll
- ambient zones
- character motifs später
- dynamic transitions

Nicht überkomplex bauen, bevor Audio-Prototyp existiert.

---

## 25. Art Pipeline

Das Spiel soll hochwertige moderne Pixel-Art verwenden.

Architektur muss unterstützen:

- sprite animation
- layered characters falls sinnvoll
- lighting
- particles
- weather
- water
- reflections
- environment animation
- post-processing nur sinnvoll dosiert
- unterschiedliche Elysia/Reality-Looks

WICHTIG:

Programmiere keine riesigen Custom-Rendering-Systeme, wenn die Engine bereits robuste Lösungen bietet.

---

## 26. Performance

Früh messen.

Nicht erst optimieren, wenn alles fertig ist.

Ziele für Desktop werden nach Engine-Auswahl konkretisiert.

Vermeide:

- unnötige per-frame allocations
- gigantische aktive Szenen
- unkontrollierte Partikelsysteme
- unnötige Update-Loops
- teure globale Shader
- schlecht skalierende NPC-Logik

Aber:

keine Premature Optimization.

Profiling vor Optimierung.

---

## 27. Debug Tools

Baue einfache interne Developer Tools.

Beispielsweise:

- Teleport
- Story State setzen
- Quest State ändern
- Relationship State setzen
- Facets setzen
- Item hinzufügen
- House State ändern
- Save testen
- Elysia/Reality UI wechseln

Nur Development Builds.

Diese Tools werden für Narrative Testing sehr wichtig.

---

## 28. Logging

Strukturiertes Development Logging.

Nicht permanent alles loggen.

Kategorien beispielsweise:

- SAVE
- QUEST
- DIALOGUE
- WORLD_STATE
- INTERACTION
- AUDIO

Release Build entsprechend reduzieren.

---

## 29. Testing

Automatisiere besonders Systeme, die deterministisch testbar sind.

Priorität:

Save/Load.
World State.
Quest transitions.
Dialogue conditions.
Relationship state transitions.
Inventory.
Serialization.

Nicht versuchen, „Spaß“ automatisiert zu testen.

Gameplay Feel benötigt Playtests.

---

## 30. Error Handling

Keine Silent Failures.

Wenn Content ungültig ist:

in Development klare Fehlermeldung.

Beispielsweise:

- missing dialogue node
- invalid quest state
- unknown item ID
- broken save migration
- missing asset reference

Fehler sollen Content-Erstellung erleichtern.

---

## 31. Content IDs

Verwende stabile IDs für:

quests,
characters,
dialogue nodes,
items,
locations,
facets,
memories,
melodies,
curiosities.

Keine fragile Logik über sichtbare Display Names.

---

## 32. Localization Readiness

Auch wenn V1 zunächst nur eine Sprache besitzt:

Text nicht tief hardcoden.

Trenne:

display text,
IDs,
game logic.

Unterstütze spätere Lokalisierung.

---

## 33. Privacy

Core Game offline-first.

Kein Account erforderlich.

Keine unnötige Datensammlung.

Keine psychologischen Profile serverseitig.

Keine Telemetrie ohne bewusste Entscheidung.

Keine Third-Party-Analytics standardmäßig einbauen.

---

## 34. Security

Auch bei einem Offline-Spiel:

- Save Parser robust
- keine unsichere Codeausführung aus Content-Dateien
- keine Secrets im Repository
- Dependencies prüfen
- externe Packages minimieren
- Lizenzkompatibilität beachten

---

## 35. Dependency Policy

Bevor du eine Dependency hinzufügst:

prüfe:

1. Brauchen wir sie wirklich?
2. Kann die Engine das bereits?
3. Ist sie aktiv maintained?
4. Lizenz?
5. Lock-in?
6. Performance?
7. Build-Komplexität?

Neue Dependency dokumentieren.

---

## 36. Asset Policy

Keine urheberrechtlich problematischen Assets.

Keine ungeklärten Pokémon-/Nintendo-/anderen Game-Assets.

Keine direkten Kopien fremder Charaktere, Musik, Maps oder UI.

Referenzen dienen nur der Qualitätsorientierung.

Für Prototyp:

klar gekennzeichnete Placeholder verwenden.

Placeholder müssen leicht austauschbar sein.

---

## 37. AI-Asset-Policy

Falls generative Assets für Prototyping verwendet werden:

klar dokumentieren.

Nicht stillschweigend als finale Assets behandeln.

Finale Art Direction muss konsistent und bewusst kuratiert sein.

Keine unklare Herkunft.

---

## 38. Placeholder-Regel

Placeholder sind für Vertical-Slice-Entwicklung erlaubt.

Aber:

nicht so implementieren, dass Placeholder technisch mit Gameplay verschmelzen.

Asset Replacement muss einfach sein.

Erstelle eine Liste aller Placeholder Assets.

---

## 39. Engine-Auswahl

Entscheide die Engine nicht blind.

Vergleiche mindestens sinnvolle Optionen für dieses konkrete Projekt.

Bewerte:

- 2D/Pixelsprite Workflow
- Lighting
- Shader
- Particles
- Audio
- Controller
- UI
- Localization
- Save
- Desktop Export
- spätere Konsolenoption
- Performance
- Open Source / Kosten
- Claude-Code-Workflow
- Community
- Plugins
- Build Pipeline
- langfristige Wartbarkeit

Beispiele können Godot, Unity oder andere ernsthafte Alternativen sein.

Keine Engine auswählen, nur weil sie populär ist.

Gib mir eine klare Empfehlung.

Berücksichtige dabei ausdrücklich das Zero-Budget-Ziel aus Abschnitt 51 und bevorzuge bei ansonsten vergleichbarer Eignung Lösungen ohne Lizenzkosten, Umsatzbeteiligung oder spätere kommerzielle Kostenfallen.

Vor Projektinitialisierung Freigabe einholen.

---

## 40. Architekturprinzipien

Bevorzugt:

simple,
modular,
data-driven,
testable,
replaceable,
verständlich.

Vermeide:

- God Objects
- globale unstrukturierte Singletons
- harte Scene-Abhängigkeiten
- tief gekoppelte Dialoglogik
- Questlogik in UI
- Business/Game State in Rendering Code
- unnötige Event-Bus-Komplexität
- abstrakte Enterprise Patterns ohne Nutzen.

---

## 41. Documentation

Halte mindestens aktuell:

README,
ARCHITECTURE,
GAME_BIBLE,
CONTENT_GUIDE,
SAVE_FORMAT,
DECISIONS,
PLACEHOLDERS,
KNOWN_ISSUES.

Wenn sinnvoll:

ADRs für wichtige Architekturentscheidungen.

Dokumentation soll kurz und praktisch bleiben.

---

## 42. Git / Version Control

Arbeite in kleinen nachvollziehbaren Änderungen.

Keine gigantischen unübersichtlichen Commits.

Vor riskanten Refactorings:

bestehenden Zustand prüfen.

Keine funktionierende Implementierung ohne Grund neu schreiben.

Keine User-Dateien überschreiben.

Keine Secrets committen.

---

## 43. Qualitätsregel

Nach jeder größeren Phase:

1. Build
2. Tests
3. Lint/Static Checks soweit verfügbar
4. manuelle Smoke Tests
5. Performance Quick Check
6. Regression Check
7. Dokumentation aktualisieren

Nicht einfach:

„Code geschrieben = fertig.“

---

## 44. Definition of Done für Features

Ein Feature ist nicht fertig, wenn es nur im Happy Path funktioniert.

Prüfe mindestens:

normaler Ablauf,
Abbruch,
erneute Interaktion,
Save während/nach Zustand,
Load,
Controller,
Keyboard,
fehlende Daten,
ungültiger Zustand,
Accessibility-Auswirkungen,
Performance soweit relevant.

---

## 45. Vertical Slice — verbindlicher Content

Der erste Slice umfasst ungefähr:

### 0–10 Minuten — Elysia

Movement. Interaktion. NPCs. Miniquest. XP. Gold. Loot. Level-Up. Lob. erste kleine humorvolle Situation.

### 10–18 Minuten — Irritation

NPC-Wiederholung. fehlende Spiegelung. Stein. Kind. Riss.

### 18–25 Minuten — Übergang

Elysia UI verschwindet. Regen. Wind. Real UI. Mira. erstes echtes Nein.

### 25–35 Minuten — Tal

Exploration. Umweltinteraktion. kleines Puzzle. Mira widerspricht. Haus entdecken.

### 35–45 Minuten — Antreiber-Prototyp

Mechanik:

Mehr Input / mehr Geschwindigkeit ist nicht automatisch Lösung.

Spieler entdeckt freiwilliges Stoppen.

### 45–52 Minuten — Haus

Feuer. Ruhe. Dialog. Kuriosität platzieren. Katze draußen.

### 52–60 Minuten — Humor

kurze, hochwertige Sidequest.

Danach Abend.

Mira: „Morgen gehe ich weiter.“

Protagonist: „Wohin?“

Mira schaut zu den Bergen.

„Zum Meer.“

Cut to black.

Titel.

END OF PROTOTYPE.

---

## 46. Was der Vertical Slice beweisen muss

Nicht nur Technik.

Er muss beantworten:

- Ist Movement angenehm?
- Macht Exploration Spaß?
- Ist Elysia attraktiv?
- Funktioniert das Lob zunächst positiv?
- Wird es subtil unangenehm?
- Erzeugt der Riss Neugier?
- Ist der Realitätswechsel emotional spürbar?
- Funktioniert Mira?
- Fühlt sich ihr erstes Nein bedeutsam an?
- Funktioniert das Haus als emotionaler Ort?
- Funktioniert ein nichtklassischer Encounter?
- Funktioniert unser Humor?
- Funktionieren Pixel-Art, Lighting, Wetter und Audio gemeinsam?

Und vor allem:

**Will ein Testspieler weiterspielen?**

---

## 47. Keine Full Production vor dem Gate

Nach Fertigstellung:

STOP.

Erstelle stattdessen:

- Build
- Testanleitung
- bekannte Probleme
- Playtest-Fragen
- technische Risiken
- Performance-Bericht
- Placeholder-Liste
- nächste mögliche Schritte

Danach warten wir auf Playtest-Ergebnisse.

---

## 48. Playtest-Fragen

Nicht:

„Hat dir das Spiel gefallen?“

Sondern:

- Was glaubst du, ist Elysia?
- Wann hast du erstmals bemerkt, dass etwas nicht stimmt?
- Wie hast du dich gefühlt, als die XP-Leiste verschwunden ist?
- Was hältst du von Mira?
- Was glaubst du, möchte sie?
- Warum glaubst du, wiederholt sich der NPC?
- Wie hast du den Antreiber-Encounter gelöst?
- War die Lösung verständlich oder zufällig?
- Welcher Moment ist dir am stärksten im Gedächtnis?
- Gab es einen langweiligen Abschnitt?
- Gab es etwas, das sich zu langsam anfühlte?
- Gab es etwas, das zu offensichtlich erklärt wurde?
- Was möchtest du als Nächstes sehen?
- Würdest du freiwillig weiterspielen?
- Warum?

---

## 49. Cut-First Policy

Wenn Aufwand explodiert:

zuerst reduzieren:

- zusätzliche Animationen
- optionale Interaktionen
- zusätzliche Dialogvarianten
- zusätzliche Collectibles
- Dekoration
- Minigames

Nicht reduzieren, bevor Alternativen geprüft wurden:

- Elysia/Reality-Kontrast
- Mira
- Movement Quality
- Haus
- Antreiber-Encounter
- Musik-/Sound-Kontrast
- Humor
- Riss
- emotionaler Abschluss des Slice

---

## 50. Nicht implementieren

Für den Vertical Slice ausdrücklich nicht:

vollständige 10–12h Story,
alle Beschützer,
komplettes Gebirge,
Meer,
Postgame,
großes Crafting,
Multiplayer,
Online Accounts,
Backend,
Cloud Save Eigenentwicklung,
Live Service,
Achievements,
Steam Integration, solange nicht benötigt,
Mobile,
Console Build,
Mod Support,
Procedural World Generation,
komplexes Combat,
Skill Tree,
Daily Quests,
Streaks,
AI NPC Chat,
LLM Integration.

---

## 51. Kosten- und Zero-Budget-Regel

Für die Entwicklung des Vertical Slice gilt zunächst ausdrücklich:

Zielbudget für zusätzliche Tools, Software, Services, Plugins, Assets, APIs, Hosting und Infrastruktur: **0 €**.

Bereits vorhandene Kosten bzw. von mir ohnehin genutzte Entwicklungswerkzeuge wie Claude Code werden dabei nicht berücksichtigt.

Arbeite nach dem Prinzip:

**Free / Open Source / Self-built first.**

Bevor du eine kostenpflichtige Lösung vorschlägst oder integrierst, prüfe immer zuerst:

1. Kann die gewählte Game Engine das bereits nativ?
2. Gibt es eine qualitativ ausreichende kostenlose oder Open-Source-Lösung?
3. Können wir die benötigte Funktion mit vertretbarem Aufwand selbst implementieren?
4. Ist die Funktion für den Vertical Slice überhaupt notwendig?
5. Kann sie zunächst durch einen Placeholder oder eine einfachere Lösung ersetzt werden?

Kostenpflichtige Tools, Plugins, Assets, APIs, Services oder sonstige Abhängigkeiten dürfen nicht ohne meine vorherige ausdrückliche Zustimmung gekauft, vorausgesetzt oder technisch notwendig gemacht werden.

Falls eine kostenpflichtige Lösung einen erheblichen Qualitäts-, Zeit- oder Wartungsvorteil bietet, darfst du sie empfehlen. Stelle dann transparent gegenüber:

- kostenlose Alternative,
- kostenpflichtige Alternative,
- einmalige Kosten,
- laufende Kosten,
- Lizenzbedingungen,
- Vor- und Nachteile,
- Auswirkungen auf Entwicklungszeit und Qualität,
- deine Empfehlung.

Für den Vertical Slice bevorzugen wir bei Bedarf kostenlose bzw. klar lizenzierte Placeholder-Assets.

Diese dürfen niemals so tief mit Gameplay oder Architektur gekoppelt werden, dass ihr späterer Austausch schwierig wird.

Insbesondere vermeiden wir für den Vertical Slice nach Möglichkeit:

- kostenpflichtige Engine-Lizenzen,
- kostenpflichtige Plugins,
- kostenpflichtige Asset-Packs,
- eigene Server,
- Backend-Infrastruktur,
- Cloud-Datenbanken,
- externe APIs,
- kostenpflichtige Analytics,
- kostenpflichtige AI-/LLM-APIs,
- kostenpflichtige Hosting-Abhängigkeiten,
- unnötige SaaS-Dienste.

Das Zero-Budget-Ziel darf jedoch nicht zu schlechter grundlegender Architektur oder unnötiger Eigenentwicklung führen.

Wenn beispielsweise eine kostenlose Eigenentwicklung 40 Stunden benötigt und eine hochwertige Lösung für einen kleinen einmaligen Betrag verfügbar wäre, weise mich darauf hin und lass mich bewusst entscheiden.

Ziel ist nicht „um jeden Preis kostenlos“, sondern:

Bis zur Validierung des Vertical Slice kein Geld ausgeben, solange dadurch kein erheblicher Nachteil entsteht.

Erst wenn der Vertical Slice spielerisch validiert wurde, entscheiden wir bewusst über ein mögliches Produktionsbudget für insbesondere:

- professionelle Pixel-Art,
- Character Design,
- Animation,
- Musik,
- Sound Design,
- zusätzliche Assets,
- QA,
- Localization,
- Marketing,
- Distribution.

Kosten dürfen niemals stillschweigend entstehen oder vorausgesetzt werden.

---

## 52. Performance-Budget

Nach Engine-Auswahl gemeinsam definieren.

Für den Slice mindestens beobachten:

FPS.
Frame Times.
Memory.
Scene Loading.
Save Duration.
Startup.
Partikel.
Lighting.
NPC Count.

Nicht blind optimieren.

Messen.

---

## 53. UX-Grundsatz

Der Spieler soll möglichst selten denken:

„Was möchte das Interface von mir?“

und möglichst oft:

„Was möchte ich tun?“

HUD minimal.
Interaktionen konsistent.
Keine Tutorial-Flut.
Mechaniken bevorzugt spielerisch lehren.

---

## 54. Tutorial-Design

Keine Textwand:

Press W to move…

Wenn möglich:

Umgebung lehrt Bewegung.
NPC/Objekt lehrt Interaktion.
Quest lehrt Journal.
Loot lehrt Inventar.
Riss lehrt UI-Transformation.

Ausnahmen:

Accessibility und komplexe Steuerung dürfen explizit erklärt werden.

---

## 55. Content Writing

Dialoge:

natürlich.
prägnant.
charakterbezogen.

Keine Expositionsmonologe.
Keine Therapiephrasen.
Keine ständigen Weisheiten.

Menschen dürfen über:

Essen,
Wetter,
Tiere,
dumme Dinge,
Alltag

sprechen.

Nicht jede Unterhaltung muss Bedeutung tragen.

---

## 56. Humor

Der Humor ist Kernbestandteil.

Er wird mit Spielverlauf zunehmend:

absurder,
alberner,
menschlicher,
lebensfroher.

Aber:

emotionale Szenen nicht reflexartig mit Gags unterbrechen.

Keine permanente Ironie.

Keine Marvelisierung.

---

## 57. Elysia Writing

Elysia-NPCs müssen zunächst sympathisch wirken.

Nicht creepy schreiben.

Ihr Lob soll am Anfang angenehm sein.

Erst durch Wiederholung und fehlende Eigenständigkeit entsteht Unbehagen.

Das Timing ist entscheidend.

---

## 58. Mira Writing

Mira niemals schreiben als:

allwissende Mentorin,
Therapeutin,
Manic Pixie Dream Girl,
Belohnung für den Protagonisten.

Sie besitzt:

eigene Motivation,
eigene Grenzen,
eigene Fehler,
eigenes Leben.

---

## 59. Protagonist Writing

Der Protagonist ist kein leeres Gefäß.

Seine Stimme entwickelt sich.

Anfang:

mehr Reaktion auf Erwartungen anderer.

Später:

mehr eigene Meinung,
mehr Humor,
mehr Individualität,
mehr Möglichkeit zu schweigen.

Spieleragency bleibt erhalten.

---

## 60. Review-Fragen bei jedem Feature

Vor Implementierung:

1. Warum braucht REAL dieses Feature?
2. Was erlebt der Spieler dadurch?
3. Ist es für den Slice notwendig?
4. Können wir denselben Effekt einfacher erreichen?
5. Fügt es technische Schulden hinzu?
6. Passt es zur Game Bible?
7. Wie testen wir es?
8. Wie entfernen/ändern wir es später?

Wenn keine gute Antwort:

nicht bauen.

---

## 61. Erste Aufgabe

Nachdem du diesen Prompt erhalten hast:

NICHT CODEN.

Führe zuerst einen vollständigen Pre-Implementation Review durch.

Liefere mir:

- **A. Verständnis:** Fasse die Produktvision prägnant zusammen.
- **B. Critical Review:** Identifiziere Widersprüche, Risiken, fehlende Entscheidungen, technische Probleme, unnötigen Scope, Designrisiken.
- **C. Engine Comparison:** Vergleiche geeignete Engines anhand dieses konkreten Spiels. Gib eine begründete Empfehlung. Noch nichts installieren.
- **D. Technical Architecture Proposal:** Nur High-Level. Noch keine unnötige Detailarchitektur.
- **E. Vertical Slice Production Plan:** Phasen. Abhängigkeiten. Risiken. Definition of Done.
- **F. Cost Check:** Welche externen Kosten könnten entstehen? Welche lassen sich vermeiden?
- **G. Questions:** Stelle nur Fragen, deren Antwort wirklich benötigt wird, bevor wir mit der technischen Umsetzung beginnen. Priorisiere sie. Maximal etwa 10 wirklich relevante Fragen.
- **H. Recommendation:** Sage mir klar, wie du als Nächstes vorgehen würdest.

Danach:

WARTE AUF MEINE FREIGABE.

*(Erledigt: siehe [`PRE_IMPLEMENTATION_REVIEW.md`](PRE_IMPLEMENTATION_REVIEW.md).)*

---

## 62. Arbeitsweise nach Freigabe

Nach meiner Freigabe:

arbeite phasenweise.

Nach jeder Phase:

- Ergebnis zusammenfassen
- Tests durchführen
- offene Probleme nennen
- relevante Entscheidungen dokumentieren
- nächsten Schritt nennen

Bei kleinen Problemen:

selbst lösen.

Bei großen Produktentscheidungen:

fragen.

Nicht ständig wegen Kleinigkeiten unterbrechen.

---

## 63. Bestehende Projekte / Learnings

Falls sich in diesem Repository oder in von mir bereitgestellten vorherigen Projekten bereits:

Patterns,
Designsysteme,
Tools,
Utilities,
Workflows,
CI,
Coding Standards,
Dokumentation,
Fehlerbehebungen,
Deployment-Learnings,
bewährte Libraries

befinden:

prüfe sie.

Übernimm sie nicht blind.

Klassifiziere:

- **übernehmen:** passt direkt.
- **adaptieren:** gute Idee, aber REAL braucht andere Umsetzung.
- **nicht übernehmen:** unnötig oder ungeeignet.

Vermeide insbesondere, frühere Fehler oder technische Schulden zu kopieren.

---

## 64. Keine Schein-Fertigstellung

Sag niemals:

„Das Spiel ist fertig“

nur weil:

Code kompiliert.
Szenen existieren.
Placeholder sichtbar sind.
Systeme technisch funktionieren.

Bei REAL sind:

Writing,
Art,
Animation,
Sound,
Music,
Level Design,
Pacing,
Gameplay Feel

wesentliche Bestandteile der Produktqualität.

Technisch fertig ≠ spielerisch fertig.

---

## 65. Finaler Qualitätsanspruch

Wir wollen kein:

„beeindruckendes Projekt, wenn man bedenkt, dass es mit Claude gebaut wurde.“

Wir wollen:

ein hervorragendes Indie-Spiel.

Der technische Entwicklungsprozess ist lediglich Mittel zum Zweck.

Der Spieler soll später nicht darüber nachdenken, womit das Spiel entwickelt wurde.

Er soll:

Elysia lieben.
Elysia misstrauen.
Mira mögen oder sich an ihr reiben.
über Figuren lachen.
sich im Haus zuhause fühlen.
seine Beschützer verstehen.
den Riss nicht vergessen.
am Meer kurz still werden.
und irgendwann völlig ernsthaft versuchen, eine Ziege aus einem Rathaus zu verhandeln.

Das ist die Qualitätslatte.
