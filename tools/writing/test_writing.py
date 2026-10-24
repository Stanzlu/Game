"""Tests of the writing tools (standard library only): python3 -m unittest discover -s tools/writing."""
import os
import tempfile
import unittest

import calibrate
import dialogue
import id_lock
import lint
import motifs
import readable
import report
import texts

SAMPLE = """# a comment
~ start
if WorldState.has_flag("a.b")
	=> later
Ein Hund bellt. [ID:s_1]
Mira: [wait=0.5]Nein. [ID:s_2] [#ok]
- Gut. [ID:s_r1]
	Mira: Dann nicht. [ID:s_3] [#draft]
	do WorldState.set_flag("a.c")
% Gärtnerin: Blumen {{name}}. [ID:s_4]
% [if WorldState.has_flag("a.b") /] Mira: Die Steine. [ID:s_6]
- [if WorldState.has_flag("a.b") /] Doch. [ID:s_r2]
=> END

~ later
Ein Vogel. [ID:s_5] [#ph]
"""


def make_source(text):
    handle, path = tempfile.mkstemp(suffix=".dialogue")
    with os.fdopen(handle, "w", encoding="utf-8") as f:
        f.write(text)
    try:
        return dialogue.parse(path)
    finally:
        os.remove(path)


def item(key, text, tags=(), kind="speech"):
    return texts.Text("x.dialogue:1", key, kind, "Mira", text, list(tags))


class ParserTests(unittest.TestCase):
    def setUp(self):
        self.source = make_source(SAMPLE)
        self.by_id = {line.id: line for line in self.source.lines}

    def test_lines_are_classified(self):
        self.assertEqual(self.by_id["s_1"].kind, "narration")
        self.assertEqual(self.by_id["s_2"].kind, "speech")
        self.assertEqual(self.by_id["s_r1"].kind, "response")
        self.assertEqual(self.by_id["s_4"].speaker, "Gärtnerin", "the random-line mark is not the name")

    def test_code_and_comments_are_skipped(self):
        self.assertEqual(sorted(self.by_id), ["s_1", "s_2", "s_3", "s_4", "s_5", "s_6", "s_r1", "s_r2"])

    def test_an_inline_condition_is_not_part_of_the_line(self):
        self.assertEqual(self.by_id["s_6"].speaker, "Mira")
        self.assertEqual(self.by_id["s_6"].kind, "speech")
        self.assertEqual(self.by_id["s_r2"].kind, "response")
        self.assertEqual(self.by_id["s_r2"].text, "Doch.")

    def test_text_is_the_visible_text(self):
        self.assertEqual(self.by_id["s_2"].text, "Nein.")
        self.assertEqual(self.by_id["s_4"].text, "Blumen .")

    def test_tags_cues_and_jumps(self):
        self.assertEqual(self.by_id["s_2"].tags, ["ok"])
        self.assertEqual(self.by_id["s_5"].tags, ["ph"])
        self.assertEqual(list(self.source.cues), ["start", "later"])
        self.assertEqual(self.by_id["s_3"].cue, "start")
        self.assertIn("later", self.source.jumps)

    def test_words_are_counted(self):
        self.assertEqual(self.by_id["s_1"].words, 3)


class VocabularyTests(unittest.TestCase):
    def setUp(self):
        self.terms, _ = lint.load_vocabulary()

    def check(self, items, excepted=()):
        return lint.vocabulary_problems(items, self.terms, set(excepted))

    def test_therapy_language_is_a_note_in_a_draft(self):
        problems = self.check([item("a_1", "Das ist dein Trauma, nicht meins.")])
        self.assertEqual([level for level, _ in problems], ["note"])
        self.assertIn("trauma", problems[0][1])

    def test_it_is_an_error_in_a_frozen_line(self):
        problems = self.check([item("a_1", "Du brauchst Selbstfürsorge.", ["ok"])])
        self.assertEqual([level for level, _ in problems], ["error"])

    def test_every_term_catches_its_own_word(self):
        samples = {
            "trauma": "Ein Trauma.", "therapy": "Eine Therapie.", "diagnosis": "Die Diagnose.",
            "disorder": "Eine Angststörung.", "psychology": "Die Psyche.",
            "depression": "Depressiv.", "attacks": "Eine Panikattacke.",
            "addiction": "Ein Rückfall.", "self_help": "Sei achtsam.",
            "jargon": "Grenzen setzen.", "english": "Healing.",
        }
        self.assertEqual(sorted(samples), sorted(self.terms), "a sample for every term")
        for name, text in samples.items():
            hits = [n for n, pattern in self.terms.items() if pattern.search(text)]
            self.assertIn(name, hits, text)

    def test_ordinary_words_pass(self):
        for text in ["Mira sucht ihr Netz.", "Entschuldige die Störung.", "Es ist nüchtern betrachtet kalt.",
                     "Das Tal heilt nichts.", "Sie suchten den Weg."]:
            self.assertEqual(self.check([item("a_1", text)]), [], text)

    def test_an_exception_with_its_term_is_accepted(self):
        text = "Das ist ein Trauma."
        self.assertEqual(self.check([item("a_1", text)], [("a_1", "trauma")]), [])
        self.assertEqual(len(self.check([item("a_2", text)], [("a_1", "trauma")])), 1)


class NumberAndTagTests(unittest.TestCase):
    def test_digits_are_found_and_exceptions_work(self):
        self.assertEqual(len(lint.number_problems([item("a_1", "Es sind 3 Steine.")], set())), 1)
        self.assertEqual(lint.number_problems([item("a_1", "Es sind drei Steine.")], set()), [])
        self.assertEqual(lint.number_problems([item("a_1", "Weg 200 m.")], {("a_1", "number")}), [])

    def test_digits_in_a_frozen_line_are_an_error(self):
        problems = lint.number_problems([item("a_1", "Es sind 3 Steine.", ["ok"])], set())
        self.assertEqual(problems[0][0], "error")

    def test_two_status_tags_are_an_error(self):
        problems = lint.tag_problems([item("a_1", "Hm.", ["ok", "draft"])])
        self.assertEqual(len(problems), 1)
        self.assertEqual(lint.tag_problems([item("a_1", "Hm.", ["ok"])]), [])


class IdLockTests(unittest.TestCase):
    def now(self, text):
        return id_lock.current([make_source(text)])

    def test_a_vanished_id_is_an_error_until_it_is_retired(self):
        locked = {"s_1": ("slice/a.dialogue", "-"), "gone_1": ("slice/a.dialogue", "-")}
        found = id_lock.compare(self.now(SAMPLE), locked, {})
        self.assertEqual([m for level, m in found if level == "error"].__len__(), 1)
        self.assertIn("gone_1", found[0][1])
        self.assertEqual([l for l, _ in id_lock.compare(self.now(SAMPLE), locked, {"gone_1": "cut"}) if l == "error"], [])

    def test_a_retired_id_must_not_come_back(self):
        found = id_lock.compare(self.now(SAMPLE), {}, {"s_1": "cut"})
        self.assertTrue(any(level == "error" and "used again" in m for level, m in found))

    def test_new_ids_are_notes(self):
        found = id_lock.compare(self.now(SAMPLE), {}, {})
        self.assertEqual({level for level, _ in found}, {"note"})
        self.assertEqual(len(found), 8)

    def test_a_frozen_line_that_changes_is_an_error(self):
        now = self.now(SAMPLE)
        locked = {"s_2": ("x", now["s_2"][1])}
        changed = self.now(SAMPLE.replace("Nein.", "Doch."))
        found = id_lock.compare(changed, locked, {})
        self.assertTrue(any(level == "error" and "changed" in m for level, m in found))

    def test_a_frozen_line_that_loses_its_tag_is_an_error(self):
        now = self.now(SAMPLE)
        locked = {"s_2": ("x", now["s_2"][1])}
        thawed = self.now(SAMPLE.replace(" [#ok]", ""))
        found = id_lock.compare(thawed, locked, {})
        self.assertTrue(any(level == "error" and "lost its [#ok] tag" in m for level, m in found))

    def test_the_speaker_belongs_to_the_frozen_text(self):
        a = self.now(SAMPLE)["s_2"][1]
        b = self.now(SAMPLE.replace("Mira: [wait", "Antreiber: [wait"))["s_2"][1]
        self.assertNotEqual(a, b)

    def test_update_locks_new_ids_but_never_rewrites_a_frozen_hash(self):
        now = self.now(SAMPLE)
        locked = {"s_2": ("slice/a.dialogue", "oldhash123")}
        locked, _ = id_lock.update(now, locked, {})
        self.assertEqual(locked["s_2"][1], "oldhash123")
        self.assertEqual(locked["s_1"][1], "-")
        self.assertEqual(len(locked), 8)

    def test_update_freezes_a_new_ok_line(self):
        now = self.now(SAMPLE)
        locked, _ = id_lock.update(now, {"s_2": ("slice/a.dialogue", "-")}, {})
        self.assertEqual(locked["s_2"][1], now["s_2"][1])

    def test_the_lock_file_round_trips(self):
        handle, path = tempfile.mkstemp()
        os.close(handle)
        try:
            id_lock.write_lock({"b": ("f", "-"), "a": ("f", "abc")}, {"c": "why"}, path)
            self.assertEqual(id_lock.read_lock(path), ({"a": ("f", "abc"), "b": ("f", "-")}, {"c": "why"}))
        finally:
            os.remove(path)


class ReportTests(unittest.TestCase):
    def test_speaker_statistics(self):
        stats = report.speaker_stats([make_source(SAMPLE)])
        self.assertEqual(stats["Mira"]["lines"], 3)
        self.assertEqual(stats["(Erzählung)"]["lines"], 2)
        self.assertEqual(stats["(Spielerin/Spieler)"]["lines"], 2)

    def test_status_counts(self):
        counts = report.status_stats([make_source(SAMPLE)])
        entry = list(counts.values())[0]
        self.assertEqual((entry["ok"], entry["draft"], entry["ph"], entry["untagged"]), (1, 1, 1, 5))

    def test_cues_nothing_starts_are_found(self):
        source = make_source(SAMPLE.replace("~ later", "~ later\n\n~ orphan\nNichts. [ID:s_9]"))
        source.path = "/x/slice/a.dialogue"
        found = report.unused_cues([source], '"start"')
        self.assertEqual(len(found), 1)
        self.assertIn("orphan", found[0])


class MotifTests(unittest.TestCase):
    DATA = {
        "intro": "Intro.", "register_intro": "Register.",
        "sections": [{"kind": "gag", "title": "Gags", "intro": "Gags."}],
        "motifs": [{"id": "ziege", "kind": "gag", "title": "Die Ziege", "bible": "§33", "payoff": "Rathaus.",
                    "appears": [{"type": "line", "ref": "a_1"}, {"type": "flag", "ref": "valley.goat_met"}]}],
        "register": [{"flag": "valley.goat_met", "axis": "Gag", "meaning": "Begegnung."}],
    }
    SITES = {"valley.goat_met": {"set": ["x.gd"], "read": ["y.gd"]}}

    def check(self, data=None, texts_now=None, sites=None, docs=None):
        folder = tempfile.mkdtemp()
        output = os.path.join(folder, "MOTIVE.md")
        data = data or self.DATA
        sites = self.SITES if sites is None else sites
        with open(output, "w", encoding="utf-8") as f:
            f.write(motifs.render(data, sites))
        for name, text in (docs or {}).items():
            with open(os.path.join(folder, name), "w", encoding="utf-8") as f:
                f.write(text)
        return motifs.problems(data, {"a_1": "Hm."} if texts_now is None else texts_now, sites,
                               folder, {}, output)

    def test_a_consistent_book_has_no_problems(self):
        self.assertEqual(self.check(), [])

    def test_a_vanished_line_id_is_an_error(self):
        found = self.check(texts_now={})
        self.assertEqual([m for level, m in found if level == "error"], ["motif ziege: line ID 'a_1' is gone"])

    def test_a_vanished_flag_is_an_error(self):
        found = self.check(sites={})
        self.assertTrue(any("flag 'valley.goat_met' does not exist" in m for _, m in found))

    def test_a_quote_that_no_longer_matches_is_an_error(self):
        found = self.check(docs={"a.md": "- `a_1` „Doch.“\n"})
        self.assertTrue(any("reads „Hm.“ now" in m for _, m in found), found)
        self.assertEqual(self.check(docs={"a.md": "- `a_1` „Hm.“\n"}), [])

    def test_a_flag_missing_from_the_register_is_a_note(self):
        sites = dict(self.SITES, **{"house.new_thing": {"set": ["z.gd"], "read": []}})
        found = self.check(sites=sites)
        self.assertEqual([level for level, _ in found], ["note"])
        self.assertIn("house.new_thing", found[0][1])

    def test_beats_and_chapters_need_no_register_entry(self):
        sites = dict(self.SITES, **{"beat.fire": {"set": ["z.gd"], "read": []},
                                    "chapter.slice": {"set": ["z.gd"], "read": []}})
        self.assertEqual(self.check(sites=sites), [])

    def test_a_stale_book_is_an_error(self):
        folder = tempfile.mkdtemp()
        output = os.path.join(folder, "MOTIVE.md")
        with open(output, "w", encoding="utf-8") as f:
            f.write("old")
        found = motifs.problems(self.DATA, {"a_1": "Hm."}, self.SITES, folder, {}, output)
        self.assertTrue(any("out of date" in m for _, m in found))


class CalibrationTests(unittest.TestCase):
    def test_the_text_speeds_come_from_the_game(self):
        self.assertEqual(calibrate.text_speeds(), [0.045, 0.025, 0.012, 0.0])

    def test_reading_scales_with_the_seen_share_and_the_speed(self):
        slow = calibrate.reading_seconds(100, 4000, 0.045, seen=0.5, pause=1.0)
        fast = calibrate.reading_seconds(100, 4000, 0.012, seen=0.5, pause=1.0)
        self.assertAlmostEqual(slow, 0.5 * (4000 * 0.045 + 100))
        self.assertGreater(slow, fast)

    def test_a_segment_is_the_way_times_the_factor_plus_the_reading(self):
        minutes = calibrate.estimate(600, 0, 0, 0.025, wander=2.0)
        self.assertAlmostEqual(minutes, 20.0)
        with_text = calibrate.estimate(600, 100, 4000, 0.025, wander=2.0, seen=1.0, pause=1.0)
        self.assertAlmostEqual(with_text, 20.0 + (4000 * 0.025 + 100) / 60.0)

    def test_the_slice_estimate_has_both_worlds_and_slower_text_takes_longer(self):
        slow = calibrate.slice_estimate(0)
        fast = calibrate.slice_estimate(2)
        self.assertAlmostEqual(slow["total"], slow["elysia"] + slow["real"])
        self.assertGreater(slow["total"], fast["total"])
        self.assertTrue(10.0 < calibrate.slice_estimate(1)["total"] < 45.0)

    def test_the_baseline_is_the_autopilot_run(self):
        floor = calibrate.baseline()
        self.assertGreater(floor["real"], floor["elysia"])
        self.assertIn("rift_found", floor["beats"])
        self.assertEqual(floor["elysia"] + floor["real"], 372)

    def test_a_log_is_read_and_fits_the_factor_back(self):
        log = '[1s] INFO  WORLD_STATE: beat {"beat":"elysia_start","minute":0.0,"seconds":0}\n'
        log += '[2s] INFO  WORLD_STATE: beat {"beat":"ending","minute":20.0,"seconds":1200}\n'
        beats = calibrate.parse_log(log)
        self.assertEqual(beats, [("elysia_start", 0), ("ending", 1200)])
        factor = calibrate.fit(beats, 1)
        text = calibrate.story_text()
        reading = sum(calibrate.reading_seconds(text[w][0], text[w][1], 0.025) for w in text)
        walk = calibrate.baseline()["elysia"] + calibrate.baseline()["real"]
        self.assertAlmostEqual(factor * walk + reading, 1200, delta=1)

    def test_a_log_without_beats_is_refused(self):
        with self.assertRaises(ValueError):
            calibrate.fit([], 1)

    def test_per_beat_compares_with_the_autopilot(self):
        rows = calibrate.per_beat([("fire", 900), ("not_a_beat", 5)])
        self.assertEqual([r[0] for r in rows], ["fire"])
        self.assertEqual(rows[0][1:], (900, calibrate.baseline()["beats"]["fire"]))


class ReadableTests(unittest.TestCase):
    def render(self, text):
        handle, path = tempfile.mkstemp(suffix=".dialogue")
        with os.fdopen(handle, "w", encoding="utf-8") as f:
            f.write(text)
        try:
            return "\n".join(readable.render_file(path, "T"))
        finally:
            os.remove(path)

    def test_cues_are_numbered_and_the_file_header_is_dropped(self):
        out = self.render("# Entwicklernotiz\n\n~ start\nEin Hund. [ID:a_1]\n=> END\n\n# Die Szene.\n~ later\nEin Vogel. [ID:a_2]\n")
        self.assertIn("### T1 · `start`", out)
        self.assertIn("### T2 · `later`", out)
        self.assertNotIn("Entwicklernotiz", out)
        self.assertIn("> Die Szene.", out)

    def test_speech_narration_answers_and_ids_are_shown(self):
        out = self.render("~ start\nEin Hund. [ID:a_1]\nMira: Nein. [ID:a_2] [#draft]\n- Gut. [ID:a_r1]\n\tMira: Dann nicht. [ID:a_3]\n")
        self.assertIn("- *Ein Hund.*  <sub>a_1</sub>", out)
        self.assertIn("- **Mira:** Nein. `[#draft]`  <sub>a_2</sub>", out)
        self.assertIn("- ▸ **Gut.**", out)
        self.assertIn("  - **Mira:** Dann nicht.  <sub>a_3</sub>", out)

    def test_conditions_are_shown_and_code_is_not(self):
        out = self.render('~ start\nif WorldState.has_flag("a.b")\n\tMira: Ja. [ID:a_1]\n\tdo WorldState.set_flag("a.c")\nelse\n\tMira: Nein. [ID:a_2]\n=> END\n')
        self.assertIn("*wenn* `a.b`", out)
        self.assertIn("*sonst*", out)
        self.assertNotIn("set_flag", out)
        self.assertNotIn("=> END", out)

    def test_jumps_between_cues_are_shown_and_the_end_is_not(self):
        out = self.render("~ start\nif WorldState.has_flag(\"a.b\")\n\t=> later\n=> END\n\n~ later\nEin Vogel. [ID:a_1]\n")
        self.assertIn("*→ weiter bei* `later`", out)
        self.assertNotIn("END", out)

    def test_inline_conditions_and_answers_with_a_condition(self):
        out = self.render('~ start\n% [if WorldState.has_flag("a.b") /] Mira: Die Steine. [ID:a_1]\n- [if WorldState.has_flag("a.b") /] Doch. [ID:a_r1]\n')
        self.assertIn("*(wenn `a.b`)*", out)
        self.assertEqual(out.count("*(wenn `a.b`)*"), 2)

    def test_values_and_effects_become_placeholders(self):
        out = self.render('~ start\nMira: [wait=0.9]{{WorldState.player_name()}} und {{WorldState.cat_name()}}, {{InputDevice.label_for("sprint")}}. [ID:a_1]\n')
        self.assertIn("‹Name› und ‹Katzenname›, ‹Taste: sprint›.", out)
        self.assertNotIn("wait", out)

    def test_the_slice_is_written_in_playing_order(self):
        names = [os.path.basename(p) for p in readable.story_paths()]
        self.assertEqual(names[:4], ["elysia.dialogue", "tal.dialogue", "antreiber.dialogue", "haus.dialogue"])


class ProjectTests(unittest.TestCase):
    def test_the_story_text_passes_the_lints(self):
        errors = [m for level, m in lint.run() if level == "error"]
        self.assertEqual(errors, [])

    def test_the_story_has_text_to_lint(self):
        self.assertGreater(len(texts.all_texts()), 400)

    def test_the_motif_book_is_true_to_the_game(self):
        found = motifs.problems()
        self.assertEqual([m for level, m in found if level == "error"], [])

    def test_the_register_knows_every_story_flag(self):
        self.assertEqual([m for level, m in motifs.problems() if level == "note"], [])

    def test_the_quotes_on_the_voice_sheets_are_checked(self):
        count = 0
        for name in motifs._markdown(motifs.DOCS):
            with open(os.path.join(motifs.DOCS, name), encoding="utf-8") as f:
                count += len(motifs.QUOTE_RE.findall(f.read()))
        self.assertGreater(count, 70)

    def test_every_locked_id_still_exists(self):
        locked, retired = id_lock.read_lock()
        self.assertGreater(len(locked), 400)
        self.assertEqual([k for k in locked if k not in id_lock.current() and k not in retired], [])


if __name__ == "__main__":
    unittest.main()
