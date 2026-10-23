"""Tests of the writing tools (standard library only): python3 -m unittest discover -s tools/writing."""
import os
import tempfile
import unittest

import dialogue
import id_lock
import lint
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
        self.assertEqual(sorted(self.by_id), ["s_1", "s_2", "s_3", "s_4", "s_5", "s_r1"])

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
        self.assertEqual(len(found), 6)

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
        self.assertEqual(len(locked), 6)

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
        self.assertEqual(stats["Mira"]["lines"], 2)
        self.assertEqual(stats["(Erzählung)"]["lines"], 2)
        self.assertEqual(stats["(Spielerin/Spieler)"]["lines"], 1)

    def test_status_counts(self):
        counts = report.status_stats([make_source(SAMPLE)])
        entry = list(counts.values())[0]
        self.assertEqual((entry["ok"], entry["draft"], entry["ph"], entry["untagged"]), (1, 1, 1, 3))

    def test_cues_nothing_starts_are_found(self):
        source = make_source(SAMPLE.replace("~ later", "~ later\n\n~ orphan\nNichts. [ID:s_9]"))
        source.path = "/x/slice/a.dialogue"
        found = report.unused_cues([source], '"start"')
        self.assertEqual(len(found), 1)
        self.assertIn("orphan", found[0])


class ProjectTests(unittest.TestCase):
    def test_the_story_text_passes_the_lints(self):
        errors = [m for level, m in lint.run() if level == "error"]
        self.assertEqual(errors, [])

    def test_the_story_has_text_to_lint(self):
        self.assertGreater(len(texts.all_texts()), 400)

    def test_every_locked_id_still_exists(self):
        locked, retired = id_lock.read_lock()
        self.assertGreater(len(locked), 400)
        self.assertEqual([k for k in locked if k not in id_lock.current() and k not in retired], [])


if __name__ == "__main__":
    unittest.main()
