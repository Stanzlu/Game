# Motivbuch

<!-- Erzeugt aus docs/writing/motive.json mit `python3 tools/writing/motifs.py --write`. Nicht von Hand ändern. -->

Wo Motive im Slice vorkommen, wohin sie führen und was das Spiel sich merkt. Die Tabellen entstehen aus `docs/writing/motive.json`; ein Prüfer (`tools/writing/motifs.py`, in `check.sh`) meldet verschwundene Zeilen-IDs und Flags und erinnert an Flags, die noch nicht im Register stehen. Gilt für den Slice; jedes neue Segment trägt seine Motive ein, bevor es geschrieben wird (Plan 9.4).

## Vorausdeutungen (Bible §46)

Früh sichtbar, später rückblickend sinnvoll. Keine Enthüllung darf nur auf Informationen beruhen, die unmittelbar vorher eingeführt wurden.

| Motiv | Bible | Im Slice | Auflösung |
|---|---|---|---|
| **Fehlende Spiegelung** | §46 | `el_basin_1`, `el_basin_2`, `el_basin_4`, `el_basin_5`, `elysia.mirror_seen`, `el_child_1`, `mk_fountain_1`, `mk_tailor_4`, `sh_mirror_3`, `sh_mirror_5`, `elysia.hall_mirror_seen` | Pfütze im Tal: zum ersten Mal ein Bild der Spielerin (`tal_puddle_2`, `tal_puddle_7`); Twist II (Elysia entstand aus einem Bedürfnis nach Schutz) liest die fehlende Spiegelung zurück. |
| **Identische Bewegungen und Sätze** | §46 | `el_loop_1`, `el_praise_1`, `mk_poet_2`, `mk_gate_4`, `mk_fountain_1`, `mk_guest_1`, `mk_fest_7`, `mk_gate_10`, `mk_gate_11`, `mk_fest_11`, `mk_baker_8`, `mk_tailor_9`, `mk_flower_6`, `mk_shop_8`, `gh_host_loop_1`, `gh_host_loop_2`, `el_gard_loop`, `ank_rings_1`, `elysia.loops`, Elysianer-Routen gespiegelt (ADR-031) | Die Wirklichkeit wiederholt sich nie wörtlich; in Akt VI (Rückkehr nach Elysia) erkennt die Spielerin die Schleife. |
| **Schnell loopende Musik** | §35, §46 | Elysia-Loop wird mit jedem Besuch kürzer (Musik-Arc), `el_loop_2`, `elysia.market_seen` | Im Finale erkennt die Spielerin, dass Fragmente des späteren Hauptthemas schon in Elysia vorhanden waren (§35). |
| **Menschen ohne echte Ablehnung** | §46 | `el_favor_2`, `el_favor_3`, `el_favor_5`, `el_favor_6`, `el_favor_r3`, `mk_poet_5`, `mk_shop_6`, `mk_fest_5`, `ank_fire_1`, `ank_fire_2`, `nein_antr_r1`, `nein_antr_1`, `nein_antr_2`, `haus_mira_r15`, `haus_mira_39`, `haus_mira_40`, `tal_eve_day_r7`, `tal_eve_day_13`, `tal_eve_ely_12`, `elysia.asked_for_no` | Miras erstes Nein (`tal_mira_7`) und der Satz, der danach hängen bleibt (`tal_mira_no_2`); das Haus, das einem geschenkt wird (`haus_bed_5`). |
| **Perfekte Natur** | §46 | `el_flower_1`, `el_flower_2`, `el_tree_1`, `el_tree_2`, `el_pillar_1`, `el_feast_1`, `sh_leaf_1`, `sh_feather_1`, `sh_hint_7`, `ank_ground_1`, `elysia.flower_smelled` | Dieselbe Geste in der Wirklichkeit riecht nach etwas: `tal_flower_2`, `tal_flower_4`, `tal_berry_2`, `haus_herbs_3`. |
| **Der Stein** | §46 | `el_stone_1`, `elysia.stone_taken`, `haus_rest_8`, `haus_shelf_6` | Der Stein liegt im Regal (`haus_shelf_9`) und bleibt ein Hausmotiv; seine Herkunft bleibt offen. |
| **Der Samen** | §30, §46 | `el_wake_seed`, `haus_rest_4` | Akt V: der Garten (Plan 5.4). Der Samen hat keinen Flag; die Spielfigur trägt ihn schon, und Elysia hält ihn für den ihren (`el_wake_seed`), das Haus widerspricht (`haus_rest_4`). |
| **Hausmotive** | §26, §46 | `haus_table_1`, `haus_table_2`, `haus_bucket_1`, `haus_fire_9`, `haus_shelf_1`, `haus_prints_1`, `haus_prints_2`, `haus_bed_6`, `haus_herbs_1`, `house.spoon_found`, `house.shelf_filled` | Das Haus wächst mit den Akten (Plan 5.4): Werkbank, zweiter Stuhl, Regale, Garten, Gäste. |
| **Der Betäuber (Gastwirt)** | §14, §46 | `el_host_3`, `el_host_11`, `haus_rest_7`, `elysia.soup_served`, `elysia.host_warned`, `gh_room_3`, `gh_slept_2`, `gh_slept_4`, `elysia.inn_declined`, `elysia.inn_stayed`, `mk_host_1`, `mk_host_6`, `mk_host_5` | Akt VI: derselbe Wirt, das freiwillige Aufstehen. `haus_rest_7` trägt den Satz schon zurück in die Wirklichkeit; im Gasthaus zum Immer (Akt I) sind es drei Angebote, jedes frei abzulehnen: das Essen, das Zimmer („Du musst heute nicht zurück.“, `gh_room_3`), die Nacht („Du kannst für immer bleiben.“, `gh_slept_2`). |
| **Wiederkehrende Formulierungen** | §46 | `el_host_3`, `haus_rest_7`, `tal_mira_8`, `tal_eve_tarp_1`, `tal_eve_tarp_2`, `haus_mira_8`, `tal_mira_again_1`, `tal_end_5`, `tal_south_sign_2`, `mk_baker_3`, `mk_baker_1`, `mk_tailor_5`, `mk_board_4`, `sh_keeper_2`, `sh_gate_2`, `mk_fest_3`, `mk_baker_7`, `mk_tailor_7`, `elysia.feast_noticed` | „Nirgends mehr hin“ wird von Elysia in die Wirklichkeit getragen; „Zum Meer.“ trägt das Ende (Akt VII). |
| **Fragmente späterer Melodien** | §31, §46 | `el_child_3`, `tal_shell_1`, `tal_eve_shell_2`, `valley.shell_seen`, `mk_music_1`, `mk_music_2`, `melody.elysia_perfect`, `melody.child_hum` | Das Kind summt das Motiv der Tal-Musik; im Finale erkennt die Spielerin es wieder (§35). Die Muschel mit dem Riss verweist auf das Meer (Akt VII). |
| **Spuren der Welt und der Vergangenheit** | §31 | `bl_hook_2`, `bl_table_4`, `bl_bed_4`, `bl_knot_2`, `haus_herbs_4`, `fragment.bank_table`, `fragment.dry_bed`, `fragment.beam_herbs` | Orte haben gedient, ohne einen Grund zu nennen: ein Pfosten, ein Brett, eine Rinne, ein Bündel Kräuter unter dem Balken (Akt II, drei Fragmente). Spuren der Welt sind 18 der 24 Fragmente (Plan 5.5); die sechs Bilder des Kindes (Bible §15) bleiben davon getrennt. |
| **Die Werte am Feuer** | §18 | `feu_3`, `feu_5`, `feu_7`, `value.freedom`, `value.closeness`, `value.calm` | Drei Handgriffe und ein Schweigen am Feuer, nie mit dem Wertwort genannt: Der Raum antwortet später an einem anderen Ort (`haus_fire_10`, `haus_table_5`, `haus_table_6`, `haus_bucket_3`), Mira liest es am Abend am Lagerfeuer, als Spur über das Wasser und nie als Wert (`tal_eve_val_2` bis `tal_eve_val_12`), das Ende liest die Achse Entscheidungen, nie eine Zahl (Plan 5.6). |

## Laufende Gags (Bible §33)

Jeder Gag hat Auftritte und eine Auflösung. Gags tragen einen Gegenstand, eine Figur oder ein Wetter; sie folgen einem schweren Moment nicht zwangsläufig.

| Motiv | Bible | Im Slice | Auflösung |
|---|---|---|---|
| **Die Ziege** | §33 | `haus_mira_19`, `tal_goat_1`, `tal_goat_8`, `tal_mira_eve_3`, `tal_fence_2`, `bl_goat_1`, `bl_goat_2`, `bl_goat_3`, `valley.goat_met`, `valley.goat_loose`, `valley.goat_traded` | Taucht zunehmend absurd auf (II, IV); Nachspiel: besetzt das Rathaus, niemand kennt die Forderungen. |
| **Die Kartoffel** | §33 | `tal_goat_4`, `tal_mira_eve_r1`, `valley.potato_taken` | Bemerkenswert durchschnittlich, möglicherweise bedeutungslos (II, V); Nachspiel: Belohnung. |
| **Die Ente** | §33 | noch nicht | Orins Erzfeind (Akt IV). Die Ente verhält sich vollkommen normal. Kein Auftritt im Slice. |
| **Der Antreiber optimiert Freizeit** | §33 | `tal_antr_2`, `tal_antr_busy_1`, `tal_antr_busy_3`, `nein_antr_3`, `nein_antr_4`, `haus_antr_10`, `haus_antr_11`, `valley.antreiber_rests`, `house.antreiber_by_fire` | Akt III und VI: er plant Freizeit; im Haus ist er repariert und plant weiter (Plan 5.2). |
| **Der Richter überdramatisiert** | §33 | noch nicht | Akt II, IV, VI: aus Drohung wird Aktenton, aus Aktenton Komik. Kein Auftritt im Slice. |

## Das Kind (Bible §15)

Die sechs Bilder des Kindes (Flur, Tür, leeres Zimmer in Akt I; Hand, Verstecken, ursprüngliches Haus in Akt V): Fragmente, keine Ursache, keine Diagnose, keine Tätergeschichte. Das Lied ist eine Melodie, Warten ein Echo, beides kein Fragment. Jedes Fragment, auch eine Spur der Welt, geht durch die Prüflinse Kind und Sensibilität.

| Motiv | Bible | Im Slice | Auflösung |
|---|---|---|---|
| **Lied und Summen** | §15 | `el_child_3`, `el_child_4`, `ank_hum_1`, `elysia.child_met`, `melody.child_hum` | Akt I: die Melodie des Kindes, danach nur noch als Summen im Dunst; Akt II: das Lied im Haus, hörbar und kein Fragment (`melody.house_hum`, Brief O5); Akt V: das Summen trägt die zentrale Szene, ohne ein Fragment zu sein. |
| **Warten und Verschwinden** | §15 | `el_child_1`, `el_child_2`, `elysia.child_vanished` | Akt III: ein Echo im Wald; Akt VI: ein Blick in Elysia. |
| **Flur, Tür, Hand, Verstecken, leeres Zimmer, ursprüngliches Haus** | §15 | `kd_hall_3`, `kd_door_3`, `kd_room_3`, `fragment.hallway`, `fragment.closed_door`, `fragment.empty_room` | Akt I zeigt drei der Bilder (Flur, geschlossene Tür, leeres Zimmer), unerklärt und leise. Akt V zeigt Hand, Verstecken und das ursprüngliche Haus und fügt alle sechs zur zentralen Szene „Ich bin da.“ Jedes Fragment geht durch die Prüflinse Kind und Sensibilität (§15, §51). Nur diese sechs sind Bilder des Kindes; die Fragmente der übrigen Akte sind Spuren der Welt (`spuren-der-welt`), und `Collection.fragments()` zählt beide. |

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
| `elysia.chest_tree_opened` | Gegenstände | `elysia.txt`, `look_elysia.txt` | `elysia.dialogue` | Die Truhe am Weltenbaum ist offen („Ein Kompliment“). |
| `elysia.flower_smelled` | Wahrnehmung | `elysia.dialogue` | `elysia.dialogue`, `tal.dialogue` | An der Blume gerochen (riecht nach nichts). |
| `elysia.fountain_seen` | Wahrnehmung | `elysia.dialogue` | `elysia.dialogue` | Das Becken angesehen. |
| `elysia.mirror_seen` | Wahrnehmung | `elysia.dialogue` | `elysia.dialogue`, `tal.dialogue` | Das fehlende Spiegelbild bemerkt. |
| `elysia.child_met` | Kind | `elysia.dialogue`, `elysia.txt` | `elysia.dialogue`, `elysia.txt` | Das Kind getroffen. |
| `elysia.child_vanished` | Kind | `elysia.dialogue`, `elysia.txt` | `elysia.txt` | Das Kind ist wieder verschwunden. |
| `elysia.stone_taken` | Gegenstände | `elysia.txt`, `look_elysia.txt`, `audio_director.gd` | `haus.dialogue`, `elysia.txt` | Den Stein mitgenommen (er liegt erst, wenn sich Elysia wiederholt, A9). |
| `elysia.crystal_touched` | Wahrnehmung | `elysia.dialogue` | `elysia.dialogue` | Den Kristall berührt. |
| `elysia.soup_served` | Beschützer | `elysia.dialogue` | `elysia.dialogue`, `haus.dialogue` | Der Gastwirt hat die Suppe serviert (Betäuber). |
| `elysia.soup_tasteless` | Beschützer | `elysia.dialogue` | `tal.dialogue` | Die Spielerin hat gemerkt, dass die Suppe nach nichts schmeckt. |
| `elysia.host_warned` | Beschützer | `elysia.dialogue` | `haus.dialogue` | Der Gastwirt wurde auf „Nirgends mehr hin“ angesprochen. |
| `elysia.loops_1` | Elysia | – | – | Elysias Musik-Schleife ist nur noch halb so lang (der Markt wurde betreten oder nach zwanzig Minuten; ElysiaDirector). |
| `elysia.loops_2` | Elysia | – | – | Nur noch ein Viertel (Stein genommen oder nach vierzig Minuten; ElysiaDirector). |
| `elysia.loops` | Elysia | `elysia.txt` | `gasthaus.dialogue`, `markt.dialogue`, `elysia.dialogue`, `elysia.txt`, `gasthaus.txt`, `markt.txt`, `spiegelhalle.txt` | Die Sätze wiederholen sich wortgleich: ab dem Hoch auf dem Fest (oder nach einer Stunde Spielzeit); ElysiaDirector, Stufe „repeat“ der Heldenquest. |
| `elysia.rift_open` | Fortschritt | `elysia_scene.gd` | `gasthaus.dialogue`, `markt.dialogue`, `elysia.dialogue`, `elysia.txt` | Der Riss ist offen. |
| `elysia.rift_crossed` | Fortschritt | `rift_sequence.gd` | – | Die Spielerin ist in die Wirklichkeit übergetreten. |
| `valley.arrived` | Fortschritt | `tal_scene.gd` | `tal_scene.gd` | Im Tal angekommen. |
| `valley.mira_met` | Mira | `tal.dialogue`, `mira_prototype.dialogue` | `tal.dialogue`, `tal.txt`, `world_state.gd`, `tal_scene.gd` | Mira kennengelernt (noch als „Die Frau“). |
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
| `house.antreiber_refused` | Beschützer | `nein.dialogue` | `haus.dialogue`, `haus_scene.gd` | Sie hat dem Antreiber am Feuer „Heute nicht.“ gesagt: er setzt sich, sein Zweitens fällt aus (Akt II, B2; setzt die Facette Grenzen). |
| `house.antreiber_postponed` | Beschützer | `nein.dialogue` | `haus_scene.gd` | Sie hat dem Antreiber am Feuer „Morgen.“ gesagt: für ihn ein Termin, er geht nachsehen, ob das Dach noch da ist (Akt II, B2). |
| `house.looks_closely` | Wahrnehmung | `haus_scene.gd` | `haus.txt` | Die Szene des Hauses leitet es aus der Facette Wahrnehmung ab; die Karte zeigt dann einen Punkt mehr im Raum (Akt II, B2). |
| `house.prints_seen` | Wahrnehmung | `haus.dialogue` | `haus.dialogue` | Sie hat die Abdrücke im Staub gesehen: klein, rund, vier Zehen, bis ans Fenster und zurück (nur mit der Facette Wahrnehmung). |
| `house.mira_knocked` | Mira | `haus_scene.gd` | – | Mira hat geklopft (Marke für Tests und Autopilot). |
| `house.mira_seated` | Mira | `haus_scene.gd` | `haus.txt` | Mira sitzt am Feuer. |
| `house.mira_visited` | Mira | `haus.dialogue` | `tal.dialogue`, `haus.txt`, `tal.txt`, `haus_scene.gd`, `tal_scene.gd` | Mira war zu Besuch. |
| `house.mira_left` | Mira | `haus_scene.gd` | `haus.txt` | Mira ist wieder gegangen. |
| `elysia.inn_met` | Fortschritt | `gasthaus.dialogue` | `gasthaus.dialogue`, `elysia_scene.gd` | Die Spielerin hat den Gastwirt im Gasthaus zum Immer getroffen (Stufe „inn“ der Heldenquest). |
| `elysia.inn_fed` | Fortschritt | `gasthaus.dialogue` | `gasthaus.dialogue` | Sie hat das Brot gegessen, das schon da war. |
| `elysia.inn_room` | Beschützer | `gasthaus.dialogue` | `gasthaus.dialogue`, `gasthaus.txt` | Sie hat das Zimmer angenommen; beide Türen stehen offen. |
| `elysia.inn_declined` | Beschützer | `gasthaus.dialogue` | `gasthaus.dialogue`, `ankunft.dialogue` | Sie hat das Zimmer abgelehnt („Ich muss weiter.“); der Gastwirt fragt freundlich noch einmal. |
| `elysia.inn_sleeping` | Fortschritt | `gasthaus.dialogue`, `gasthaus_scene.gd` | `gasthaus_scene.gd` | Auslöser der Nacht im Bett (die Szene blendet auf Weiß und zurück); danach gelöscht. |
| `elysia.inn_slept` | Beschützer | `gasthaus_scene.gd` | `gasthaus.dialogue` | Sie hat im Gasthaus geschlafen und denselben Morgen noch einmal erlebt. |
| `elysia.inn_stayed` | Beschützer | `gasthaus.dialogue` | `gasthaus.dialogue`, `ankunft.dialogue` | Sie hat dem Gastwirt gesagt, dass sie noch bleibt (das dritte Angebot, angenommen). |
| `elysia.inn_book_seen` | Wahrnehmung | `gasthaus.dialogue` | `gasthaus.dialogue` | Sie hat im Gästebuch gesehen, dass ihr Name auf jeder Seite steht, in fremder Schrift. |
| `elysia.inn_book_signed` | Entscheidungen | `gasthaus.dialogue` | `gasthaus.dialogue` | Sie hat sich unter ihren Namen eingetragen (die Nebenquest „Das Gästebuch“). |
| `elysia.market_seen` | Fortschritt | `audio_director.gd`, `markt_scene.gd` | `elysia_scene.gd` | Sie hat den Markt hinter der Treppe im Süden des Gartens betreten (Stufe „market“ der Heldenquest). |
| `elysia.market_greeted` | Fortschritt | `markt.dialogue` | `markt.dialogue` | Der Torwächter hat sie in der Stadt willkommen geheißen; die Halle der Spiegel öffnet „morgen“ (A5). |
| `elysia.market_shop_seen` | Gegenstände | `markt.dialogue` | `markt.dialogue` | Sie hat den Stand des Händlers gesehen; er verkauft für Gold, was nichts ändert. |
| `melody.elysia_perfect` | Elysia | `markt.dialogue` | `markt.dialogue` | Die erste Melodie: die perfekte der Musikerin im Markt, ohne Fehler (Bible §31). |
| `elysia.hall_seen` | Fortschritt | `spiegelhalle_scene.gd` | `elysia_scene.gd` | Sie hat die Halle der Spiegel betreten (Stufe „hall“ der Heldenquest). |
| `elysia.hall_open` | Entscheidungen | `markt.dialogue` | `markt.dialogue`, `markt.txt` | Sie hat gegen die Türen der Halle gedrückt; sie waren nie abgeschlossen, nur das Schild stand davor. |
| `elysia.hall_met` | Fortschritt | `spiegelhalle.dialogue` | `spiegelhalle.dialogue` | Sie hat den Hallenwächter gesprochen, der in der Mitte steht und darum nur einmal da ist. |
| `elysia.hall_room_1` | Wahrnehmung | `spiegelhalle.dialogue` | `spiegelhalle.dialogue`, `spiegelhalle.txt` | Sie hat das Blatt bemerkt, das nur links liegt; das erste Tor steht offen. |
| `elysia.hall_room_2` | Wahrnehmung | `spiegelhalle.dialogue` | `spiegelhalle.dialogue`, `spiegelhalle.txt` | Sie hat die Feder bemerkt, die nur rechts liegt; das zweite Tor steht offen. |
| `elysia.hall_leaf_taken` | Gegenstände | `spiegelhalle.dialogue` | `spiegelhalle.txt` | Sie hat das trockene Blatt eingesteckt (eine Kuriosität; sie bleibt beim Übergang in Elysia, ADR-064). |
| `elysia.hall_feather_taken` | Gegenstände | `spiegelhalle.dialogue` | `spiegelhalle.txt` | Sie hat die Feder eingesteckt (eine Kuriosität; sie bleibt beim Übergang in Elysia, ADR-064). |
| `elysia.hall_mirror_seen` | Wahrnehmung | `spiegelhalle.dialogue` | `spiegelhalle.dialogue`, `markt_scene.gd` | Sie hat im großen Spiegel bemerkt, dass er sie nicht zeigt (Facette „Wahrnehmung“). |
| `elysia.feast` | Fortschritt | `markt_scene.gd` | `markt.dialogue`, `markt.txt`, `markt_scene.gd` | Der Markt steht im Festzustand: ganz Elysia feiert, dass sie die Halle bemerkt hat. |
| `elysia.feast_invited` | Entscheidungen | `markt.dialogue` | `markt.dialogue` | Sie hat die Einladung des Gastwirts zum Fest angenommen. |
| `elysia.feast_noticed` | Wahrnehmung | `markt.dialogue` | `markt.dialogue`, `ankunft.dialogue` | Sie hat der Festmeisterin gesagt, dass es dasselbe Fest wie gestern ist; sie hat es bemerkt und gesagt. |
| `elysia.feast_toast` | Fortschritt | `markt.dialogue` | `markt.dialogue`, `markt_scene.gd`, `elysia_scene.gd` | Sie hat das Glas gehoben: das Hoch auf den Helden (rund 11.000 Erfahrung, Level 48 ist sicher). |
| `fragment.hallway` | Kind | `kind.dialogue` | `markt.txt` | Sie ist dem Kind auf dem Markt gefolgt und hat den Flur gesehen (Fragment 1 von 6, Bible §15). |
| `fragment.closed_door` | Kind | `kind.dialogue` | `gasthaus.txt` | Sie ist dem Kind im Gasthaus gefolgt und hat die geschlossene Tür gesehen (Fragment 2 von 6). |
| `fragment.empty_room` | Kind | `kind.dialogue` | `spiegelhalle.txt` | Sie ist dem Kind in der Halle der Spiegel gefolgt und hat das leere Zimmer gesehen (Fragment 3 von 6). |
| `melody.child_hum` | Musik | `elysia.dialogue` | `ankunft.dialogue`, `haus_scene.gd` | Sie kann das Summen des Kindes aus dem Garten: die zweite Melodie des ersten Aktes. |
| `valley.trap_hooked` | Fortschritt | `bachlauf.dialogue` | `bachlauf.dialogue`, `bachlauf.txt` | Sie hat am Pfosten mit dem leeren Haken die Nebenquest „Die Reuse“ begonnen (Akt II, B3). |
| `valley.trap_floated` | Fortschritt | `bachlauf.dialogue` | `bachlauf.dialogue`, `bachlauf.txt` | Sie hat den Schwimmer im Schilf gefunden, dessen Spitze bachabwärts zeigt (Akt II, B3). |
| `valley.trap_freed` | Fortschritt | `bachlauf.dialogue` | `bachlauf.dialogue`, `bachlauf.txt` | Sie hat die Reuse hinter dem Wehr gelöst; sie liegt frei im Strom, im Geflecht ein Kamm (Akt II, B3). |
| `valley.weight_taken` | Gegenstände | `bachlauf.dialogue` | `bachlauf.txt` | Sie hat das Senkblei am Fuß des Pfostens eingesteckt (Kuriosität, Akt II, B3). |
| `valley.glass_taken` | Gegenstände | `bachlauf.dialogue` | `bachlauf.txt` | Sie hat das blaue Glas aus dem Flachwasser geholt (Kuriosität, Akt II, B3). |
| `valley.looks_closely` | Wahrnehmung | `bachlauf_scene.gd` | `bachlauf.txt` | Die Szene des Bachlaufs leitet es aus der Facette Wahrnehmung ab; die Karte zeigt dann einen Punkt mehr am Pfosten (Akt II, B3). |
| `valley.knot_seen` | Wahrnehmung | `bachlauf.dialogue` | `bachlauf.dialogue` | Sie hat den aufgeknoteten Knoten am Haken gesehen, flach und sauber (nur mit der Facette Wahrnehmung). |
| `fragment.bank_table` | Wahrnehmung | `bachlauf.dialogue` | `bachlauf.dialogue` | Sie hat sich auf den Stumpf am Uferbrett gesetzt: zwei Ringe, zwei Becher, für einen Atemzug Dampf (Spur der Welt, Akt II, B3; kein Bild des Kindes). |
| `fragment.dry_bed` | Wahrnehmung | `bachlauf.dialogue` | `bachlauf.dialogue` | Sie hat die trockene Rinne neben dem Bach gesehen, die Kiesel alle gleich gedreht (Spur der Welt, Akt II, B3; kein Bild des Kindes). |
| `fragment.beam_herbs` | Wahrnehmung | `haus.dialogue` | `haus.dialogue` | Sie hat an den Kräuterbündeln unter dem Balken gerochen: für einen Atemzug riecht es nach Sommer (Spur der Welt, Akt II, B5; kein Bild des Kindes). |
| `melody.house_hum` | Musik | `feuer.dialogue` | – | Sie hat im Haus das Summen des Kindes im Zug des Kamins wiedererkannt: die eine Melodie von Akt II, hörbar, kein Fragment (B5; nur mit melody.child_hum). |
| `value.freedom` | Entscheidungen | `feuer.dialogue` | `haus.dialogue`, `tal.dialogue` | Am Feuer hat sie die Tür einen Spalt offen gelassen (Wert, Bible §18, Akt II, B5): die Tür und das Feuer im Haus zeigen es; Mira hat vom Lagerfeuer aus die Tür aufgehen sehen (Akt II, B6; Erinnerung `saw_door_ajar`). |
| `value.closeness` | Entscheidungen | `feuer.dialogue` | `haus.dialogue`, `tal.dialogue`, `haus.txt` | Am Feuer hat sie den zweiten Hocker zu sich gestellt (Wert, Bible §18, Akt II, B5): der Tisch hat einen Hocker weniger, einer steht am Feuer; Mira hat am Abend ein Poltern gehört und auf Möbel getippt (Akt II, B6; Erinnerung `heard_furniture`). |
| `value.calm` | Entscheidungen | `feuer.dialogue` | `haus.dialogue`, `tal.dialogue` | Am Feuer hat sie zugesehen, bis es dunkel wurde (Wert, Bible §18, Akt II, B5): der Abend fällt, der Regen ist vorbei; Mira hat zweimal nachgesehen, ob das Haus noch steht (Akt II, B6; Erinnerung `checked_house`). Das Schweigen setzt keinen Wert und bekommt in B6 den geraden Rauch. |
| `valley.goat_prints_seen` | Wahrnehmung | `bachlauf.dialogue` | `bachlauf.dialogue` | Sie hat die Hufabdrücke der Ziege auf dem Balken des Wehrs gesehen (Akt II, B3; rührt Quest und Stiefel der Ziege nicht an). |
| `valley.view_back_seen` | Wahrnehmung | `bachlauf.dialogue` | `bachlauf.dialogue` | Sie hat vom Aussichtsplatz im Bachlauf den Rauch des Hauses über den Bäumen gesehen (Akt II, B3). |
