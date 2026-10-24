# Motivbuch

<!-- Erzeugt aus docs/writing/motive.json mit `python3 tools/writing/motifs.py --write`. Nicht von Hand ändern. -->

Wo Motive im Slice vorkommen, wohin sie führen und was das Spiel sich merkt. Die Tabellen entstehen aus `docs/writing/motive.json`; ein Prüfer (`tools/writing/motifs.py`, in `check.sh`) meldet verschwundene Zeilen-IDs und Flags und erinnert an Flags, die noch nicht im Register stehen. Gilt für den Slice; jedes neue Segment trägt seine Motive ein, bevor es geschrieben wird (Plan 9.4).

## Vorausdeutungen (Bible §46)

Früh sichtbar, später rückblickend sinnvoll. Keine Enthüllung darf nur auf Informationen beruhen, die unmittelbar vorher eingeführt wurden.

| Motiv | Bible | Im Slice | Auflösung |
|---|---|---|---|
| **Fehlende Spiegelung** | §46 | `el_basin_1`, `el_basin_2`, `el_basin_4`, `el_basin_5`, `elysia.mirror_seen`, `el_child_1`, `mk_fountain_1`, `mk_tailor_4` | Pfütze im Tal: zum ersten Mal ein Bild der Spielerin (`tal_puddle_2`, `tal_puddle_7`); Twist II (Elysia entstand aus einem Bedürfnis nach Schutz) liest die fehlende Spiegelung zurück. |
| **Identische Bewegungen und Sätze** | §46 | `el_loop_1`, `el_praise_1`, `elysia.loops`, Elysianer-Routen gespiegelt (ADR-031), `mk_poet_2`, `mk_gate_4`, `mk_fountain_1` | Die Wirklichkeit wiederholt sich nie wörtlich; in Akt VI (Rückkehr nach Elysia) erkennt die Spielerin die Schleife. |
| **Schnell loopende Musik** | §35, §46 | Elysia-Loop wird mit jedem Besuch kürzer (Musik-Arc), `el_loop_2` | Im Finale erkennt die Spielerin, dass Fragmente des späteren Hauptthemas schon in Elysia vorhanden waren (§35). |
| **Menschen ohne echte Ablehnung** | §46 | `el_favor_2`, `el_favor_3`, `el_favor_5`, `el_favor_6`, `el_favor_r3`, `elysia.asked_for_no`, `mk_poet_5`, `mk_shop_6` | Miras erstes Nein (`tal_mira_7`) und der Satz, der danach hängen bleibt (`tal_mira_no_2`); das Haus, das einem geschenkt wird (`haus_bed_5`). |
| **Perfekte Natur** | §46 | `el_flower_1`, `el_flower_2`, `el_tree_1`, `el_tree_2`, `el_pillar_1`, `el_feast_1`, `elysia.flower_smelled` | Dieselbe Geste in der Wirklichkeit riecht nach etwas: `tal_flower_2`, `tal_flower_4`, `tal_berry_2`. |
| **Der Stein** | §46 | `el_stone_1`, `elysia.stone_taken`, `haus_rest_8`, `haus_shelf_6` | Der Stein liegt im Regal (`haus_shelf_9`) und bleibt ein Hausmotiv; seine Herkunft bleibt offen. |
| **Der Samen** | §30, §46 | `haus_rest_4` | Akt V: der Garten (Plan 5.4). Der Samen hat im Slice keinen Flag; die Spielfigur trägt ihn schon. |
| **Hausmotive** | §26, §46 | `haus_table_1`, `haus_table_2`, `haus_bucket_1`, `haus_fire_9`, `haus_shelf_1`, `house.spoon_found`, `house.shelf_filled` | Das Haus wächst mit den Akten (Plan 5.4): Werkbank, zweiter Stuhl, Regale, Garten, Gäste. |
| **Der Betäuber (Gastwirt)** | §14, §46 | `el_host_3`, `el_host_11`, `haus_rest_7`, `elysia.soup_served`, `elysia.host_warned`, `gh_room_3`, `gh_slept_2`, `gh_slept_4`, `elysia.inn_declined`, `elysia.inn_stayed` | Akt VI: derselbe Wirt, das freiwillige Aufstehen. `haus_rest_7` trägt den Satz schon zurück in die Wirklichkeit; im Gasthaus zum Immer (Akt I) sind es drei Angebote, jedes frei abzulehnen: das Essen, das Zimmer („Du musst heute nicht zurück.“, `gh_room_3`), die Nacht („Du kannst für immer bleiben.“, `gh_slept_2`). |
| **Wiederkehrende Formulierungen** | §46 | `el_host_3`, `haus_rest_7`, `tal_mira_8`, `tal_eve_tarp_1`, `tal_eve_tarp_2`, `haus_mira_8`, `tal_mira_again_1`, `tal_end_5`, `tal_south_sign_2`, `mk_baker_3`, `mk_baker_1`, `mk_tailor_5`, `mk_board_4` | „Nirgends mehr hin“ wird von Elysia in die Wirklichkeit getragen; „Zum Meer.“ trägt das Ende (Akt VII). |
| **Fragmente späterer Melodien** | §31, §46 | `el_child_3`, `tal_shell_1`, `tal_eve_shell_2`, `valley.shell_seen`, `mk_music_1`, `mk_music_2`, `melody.elysia_perfect` | Das Kind summt das Motiv der Tal-Musik; im Finale erkennt die Spielerin es wieder (§35). Die Muschel mit dem Riss verweist auf das Meer (Akt VII). |

## Laufende Gags (Bible §33)

Jeder Gag hat Auftritte und eine Auflösung. Gags tragen einen Gegenstand, eine Figur oder ein Wetter; sie folgen einem schweren Moment nicht zwangsläufig.

| Motiv | Bible | Im Slice | Auflösung |
|---|---|---|---|
| **Die Ziege** | §33 | `haus_mira_19`, `tal_goat_1`, `tal_goat_8`, `tal_mira_eve_3`, `tal_fence_2`, `valley.goat_met`, `valley.goat_loose`, `valley.goat_traded` | Taucht zunehmend absurd auf (II, IV); Nachspiel: besetzt das Rathaus, niemand kennt die Forderungen. |
| **Die Kartoffel** | §33 | `tal_goat_4`, `tal_mira_eve_r1`, `valley.potato_taken` | Bemerkenswert durchschnittlich, möglicherweise bedeutungslos (II, V); Nachspiel: Belohnung. |
| **Die Ente** | §33 | noch nicht | Orins Erzfeind (Akt IV). Die Ente verhält sich vollkommen normal. Kein Auftritt im Slice. |
| **Der Antreiber optimiert Freizeit** | §33 | `tal_antr_2`, `tal_antr_busy_1`, `tal_antr_busy_3`, `valley.antreiber_rests`, `house.antreiber_by_fire` | Akt III und VI: er plant Freizeit; im Haus ist er repariert und plant weiter (Plan 5.2). |
| **Der Richter überdramatisiert** | §33 | noch nicht | Akt II, IV, VI: aus Drohung wird Aktenton, aus Aktenton Komik. Kein Auftritt im Slice. |

## Das Kind (Bible §15)

Fragmente, keine Ursache, keine Diagnose, keine Tätergeschichte. Jedes Fragment geht durch die Prüflinse Kind und Sensibilität.

| Motiv | Bible | Im Slice | Auflösung |
|---|---|---|---|
| **Lied und Summen** | §15 | `el_child_3`, `elysia.child_met` | Akt II: das Lied im Haus; Akt V: eines der sechs Fragmente. |
| **Warten und Verschwinden** | §15 | `el_child_1`, `el_child_2`, `elysia.child_vanished` | Akt III: ein Echo im Wald; Akt VI: ein Blick in Elysia. |
| **Flur, Tür, Hand, Verstecken, leeres Zimmer, ursprüngliches Haus** | §15 | noch nicht | Noch nicht im Slice. Akt V: sechs Fragmente und die zentrale Szene „Ich bin da.“ Jedes Fragment geht durch die Prüflinse Kind und Sensibilität (§15, §51). |

## Konsequenzen-Register

Jedes Flag, das die Geschichte setzt, steht hier mit seiner Achse (Plan 5.6: Beziehungen, Haus, Garten, Besucher, Beschützer, Musik, Gegenstände, Samen, Mira, Entscheidungen; dazu Fortschritt, Wahrnehmung, Elysia, Kind, Gag). Das Ende liest die Achsen, nie eine Zahl. Neue Flags tragen sich hier ein, sonst meldet der Prüfer sie. Flags nur für Fortschritt haben keinen Bezug zum Ende.

| Flag | Achse | Gesetzt in | Gelesen in | Bedeutung |
|---|---|---|---|---|
| `elysia.woke` | Fortschritt | `elysia.dialogue` | `elysia_scene.gd` | Die Spielerin ist in Elysia aufgewacht. |
| `elysia.asked_for_no` | Entscheidungen | `elysia.dialogue` | `tal.dialogue` | Sie hat die Elysianer gebeten, einmal Nein zu sagen. |
| `elysia.offered_bed` | Elysia | `elysia.dialogue` | `tal.dialogue` | Der Elysianer hat sein Bett angeboten. |
| `elysia.offered_house` | Elysia | `elysia.dialogue` | `haus.dialogue` | Der Elysianer hat sein Haus angeboten. |
| `elysia.butterflies_asked` | Fortschritt | `elysia.dialogue`, `elysia.txt` | `elysia.txt` | Die Gärtnerin hat um die Schmetterlinge gebeten. |
| `elysia.butterfly_first` | Fortschritt | `elysia.txt` | `elysia.txt` | Erster Schmetterling gefangen. |
| `elysia.butterfly_second` | Fortschritt | `elysia.txt` | `elysia.txt` | Zweiter Schmetterling gefangen. |
| `elysia.butterfly_third` | Fortschritt | `elysia.txt` | `elysia.txt` | Dritter Schmetterling gefangen. |
| `elysia.chest_tree_opened` | Gegenstände | `elysia.txt`, `look_elysia.txt`, `audio_director.gd` | `elysia.dialogue`, `elysia_scene.gd` | Die Truhe am Weltenbaum ist offen („Ein Kompliment“). |
| `elysia.flower_smelled` | Wahrnehmung | `elysia.dialogue` | `elysia.dialogue`, `tal.dialogue` | An der Blume gerochen (riecht nach nichts). |
| `elysia.fountain_seen` | Wahrnehmung | `elysia.dialogue` | `elysia.dialogue` | Das Becken angesehen. |
| `elysia.mirror_seen` | Wahrnehmung | `elysia.dialogue` | `elysia.dialogue`, `tal.dialogue` | Das fehlende Spiegelbild bemerkt. |
| `elysia.child_met` | Kind | `elysia.dialogue`, `elysia.txt` | `elysia.dialogue`, `elysia.txt` | Das Kind getroffen. |
| `elysia.child_vanished` | Kind | `elysia.dialogue`, `elysia.txt` | `elysia.txt` | Das Kind ist wieder verschwunden. |
| `elysia.stone_taken` | Gegenstände | `elysia.txt`, `look_elysia.txt`, `audio_director.gd` | `haus.dialogue`, `elysia.txt` | Den Stein mitgenommen. |
| `elysia.crystal_touched` | Wahrnehmung | `elysia.dialogue` | `elysia.dialogue` | Den Kristall berührt. |
| `elysia.soup_served` | Beschützer | `elysia.dialogue` | `elysia.dialogue`, `haus.dialogue` | Der Gastwirt hat die Suppe serviert (Betäuber). |
| `elysia.soup_tasteless` | Beschützer | `elysia.dialogue` | `tal.dialogue` | Die Spielerin hat gemerkt, dass die Suppe nach nichts schmeckt. |
| `elysia.host_warned` | Beschützer | `elysia.dialogue` | `haus.dialogue` | Der Gastwirt wurde auf „Nirgends mehr hin“ angesprochen. |
| `elysia.loops_1` | Elysia | – | – | Elysias Musik-Schleife ist nur noch halb so lang (Truhe offen oder fünf Minuten; ElysiaDirector). |
| `elysia.loops_2` | Elysia | – | – | Nur noch ein Viertel (Stein genommen oder zehn Minuten; ElysiaDirector). |
| `elysia.loops` | Elysia | `elysia.txt` | `gasthaus.dialogue`, `elysia.dialogue`, `elysia.txt`, `elysia_scene.gd` | Die Schleife ist hörbar geworden (wiederholte Sätze). |
| `elysia.rift_open` | Fortschritt | `elysia_scene.gd` | `elysia.dialogue`, `elysia.txt` | Der Riss ist offen. |
| `elysia.rift_crossed` | Fortschritt | `rift_sequence.gd` | – | Die Spielerin ist in die Wirklichkeit übergetreten. |
| `valley.arrived` | Fortschritt | `tal_scene.gd` | `tal_scene.gd` | Im Tal angekommen. |
| `valley.mira_met` | Mira | `tal.dialogue`, `mira_prototype.dialogue` | `tal.dialogue`, `tal.txt`, `world_state.gd` | Mira kennengelernt (noch als „Die Frau“). |
| `valley.mountains_seen` | Fortschritt | `tal.dialogue` | `tal_scene.gd` | Die Berge gesehen. |
| `valley.reflection_seen` | Wahrnehmung | `tal.dialogue` | `tal.dialogue` | Das eigene Spiegelbild in der Pfütze gesehen. |
| `valley.shell_seen` | Wahrnehmung | `tal.dialogue` | `tal.dialogue` | Die Muschel an Miras Plane gesehen. |
| `valley.shed_sign_read` | Wahrnehmung | `antreiber.dialogue` | `antreiber.dialogue` | Das Schild zum Schuppen gelesen. |
| `valley.berries_eaten` | Wahrnehmung | `tal.dialogue` | `tal.dialogue` | Brombeeren gegessen. |
| `valley.flower_smelled` | Wahrnehmung | `tal.dialogue` | `tal.dialogue` | An der Blume im Tal gerochen. |
| `valley.crossed` | Fortschritt | `tal_scene.gd` | `tal.dialogue`, `tal_scene.gd` | Den Bach überquert. |
| `valley.fell_in` | Entscheidungen | `stepping_stone.gd` | `haus.dialogue`, `tal.dialogue`, `stepping_stone.gd` | In den Bach gefallen (nur der Weg über die runden Steine). |
| `valley.fell_twice` | Gag | `stepping_stone.gd` | `tal.dialogue` | Ein zweites Mal in den Bach gefallen. |
| `valley.bridge_fixed` | Mira | `haus.dialogue` | `tal.dialogue`, `tal.txt` | Mira hat ein Brett über die Brücke gelegt. |
| `valley.wood_needed` | Fortschritt | `haus.dialogue` | `haus.dialogue`, `tal.txt` | Trockenes Holz wird gebraucht. |
| `valley.wood_taken` | Beschützer | – | `tal.dialogue`, `tal.txt`, `haus_scene.gd`, `tal_scene.gd` | Das Holz wurde geholt (Ende des Antreiber-Weges). |
| `valley.antreiber_rests` | Beschützer | `tal_scene.gd` | `tal.txt`, `tal_scene.gd` | Der Antreiber sitzt, statt zu laufen. |
| `valley.goat_met` | Gag | `tal.dialogue`, `tal.txt` | `tal.dialogue`, `tal.txt` | Der Ziege begegnet. |
| `valley.goat_loose` | Gag | `haus.dialogue` | `tal.dialogue`, `tal.txt` | Die Ziege ist los (Lücke im Zaun). |
| `valley.goat_traded` | Gag | `tal.dialogue` | `tal.dialogue`, `tal.txt` | Kartoffel gegen Stiefel getauscht. |
| `valley.potato_taken` | Gag | `tal.txt` | `tal.txt` | Die Kartoffel genommen. |
| `valley.ending` | Fortschritt | `tal.dialogue` | `tal_scene.gd` | Das Ende des Slice läuft („Zum Meer.“). |
| `encounter.antreiber_resolved` | Beschützer | `antreiber_encounter.gd` | – | Der Weg des Antreibers ist durch Stehenbleiben aufgelöst. |
| `house.fire_lit` | Haus | `haus_scene.gd` | `haus.txt`, `tal.txt`, `haus_scene.gd` | Das Feuer brennt. |
| `house.rested` | Haus | `haus.dialogue` | `haus_scene.gd` | Am Feuer ausgeruht (Abend). |
| `house.spoon_found` | Haus | `haus.dialogue` | `haus.dialogue` | Den kleinen Löffel gefunden. |
| `house.shelf_filled` | Haus | `haus.dialogue` | `haus.txt` | Der Löffel steht im Regal. |
| `house.shelf_stone` | Haus | `haus.dialogue` | `haus.txt` | Der Stein liegt im Regal. |
| `house.shelf_both` | Haus | `haus.dialogue` | `haus.txt` | Löffel und Stein stehen im Regal. |
| `house.cat_fed` | Haus | `haus.dialogue` | `haus.dialogue`, `tal.dialogue`, `haus.txt` | Die Katze ist gefüttert und im Haus. |
| `house.cat_naming` | Haus | `haus.dialogue`, `haus_scene.gd` | `haus_scene.gd` | Die Katze wird benannt. |
| `house.antreiber_by_fire` | Beschützer | `haus_scene.gd` | `haus.dialogue`, `haus.txt`, `tal.txt`, `haus_scene.gd` | Der Antreiber sitzt am Feuer des Hauses. |
| `house.antreiber_left` | Beschützer | `haus_scene.gd` | `tal.txt`, `haus_scene.gd` | Der Antreiber hat das Haus wieder verlassen. |
| `house.mira_knocked` | Mira | `haus_scene.gd` | – | Mira hat geklopft (Marke für Tests und Autopilot). |
| `house.mira_seated` | Mira | `haus_scene.gd` | `haus.txt` | Mira sitzt am Feuer. |
| `house.mira_visited` | Mira | `haus.dialogue` | `tal.dialogue`, `haus.txt`, `tal.txt`, `haus_scene.gd`, `tal_scene.gd` | Mira war zu Besuch. |
| `house.mira_left` | Mira | `haus_scene.gd` | `haus.txt` | Mira ist wieder gegangen. |
| `elysia.inn_met` | Fortschritt | `gasthaus.dialogue` | `gasthaus.dialogue`, `elysia_scene.gd` | Die Spielerin hat den Gastwirt im Gasthaus zum Immer getroffen (Stufe „inn“ der Heldenquest). |
| `elysia.inn_fed` | Fortschritt | `gasthaus.dialogue` | `gasthaus.dialogue` | Sie hat das Brot gegessen, das schon da war. |
| `elysia.inn_room` | Beschützer | `gasthaus.dialogue` | `gasthaus.dialogue`, `gasthaus.txt` | Sie hat das Zimmer angenommen; beide Türen stehen offen. |
| `elysia.inn_declined` | Beschützer | `gasthaus.dialogue` | `gasthaus.dialogue` | Sie hat das Zimmer abgelehnt („Ich muss weiter.“); der Gastwirt fragt freundlich noch einmal. |
| `elysia.inn_sleeping` | Fortschritt | `gasthaus.dialogue`, `gasthaus_scene.gd` | `gasthaus_scene.gd` | Auslöser der Nacht im Bett (die Szene blendet auf Weiß und zurück); danach gelöscht. |
| `elysia.inn_slept` | Beschützer | `gasthaus_scene.gd` | `gasthaus.dialogue` | Sie hat im Gasthaus geschlafen und denselben Morgen noch einmal erlebt. |
| `elysia.inn_stayed` | Beschützer | `gasthaus.dialogue` | `gasthaus.dialogue` | Sie hat dem Gastwirt gesagt, dass sie noch bleibt (das dritte Angebot, angenommen). |
| `elysia.inn_book_seen` | Wahrnehmung | `gasthaus.dialogue` | `gasthaus.dialogue` | Sie hat im Gästebuch gesehen, dass ihr Name auf jeder Seite steht, in fremder Schrift. |
| `elysia.inn_book_signed` | Entscheidungen | `gasthaus.dialogue` | `gasthaus.dialogue` | Sie hat sich unter ihren Namen eingetragen (die Nebenquest „Das Gästebuch“). |
| `elysia.market_seen` | Fortschritt | `markt_scene.gd` | `elysia_scene.gd` | Sie hat den Markt hinter der Treppe im Süden des Gartens betreten (Stufe „market“ der Heldenquest). |
| `elysia.market_greeted` | Fortschritt | `markt.dialogue` | `markt.dialogue` | Der Torwächter hat sie in der Stadt willkommen geheißen; die Halle der Spiegel öffnet „morgen“ (A5). |
| `elysia.market_shop_seen` | Gegenstände | `markt.dialogue` | `markt.dialogue` | Sie hat den Stand des Händlers gesehen; er verkauft für Gold, was nichts ändert. |
| `melody.elysia_perfect` | Elysia | `markt.dialogue` | `markt.dialogue` | Die erste Melodie: die perfekte der Musikerin im Markt, ohne Fehler (Bible §31). |
