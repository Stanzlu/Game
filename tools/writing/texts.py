"""All visible story text in one list (standard library only): dialogue lines and CSV rows."""
import csv
import os

import dialogue

ROOT = dialogue.ROOT
LOCALE_DIR = os.path.join(ROOT, "content", "locale")
# Story text in the translation tables; ui.csv is interface text and has its own rules.
STORY_CSV = ("journal.csv", "items.csv")


class Text:
    """One piece of story text: where it is, its key (line ID or CSV key), kind and tags."""

    def __init__(self, where, key, kind, speaker, text, tags, cue=""):
        self.where = where
        self.key = key
        self.kind = kind
        self.speaker = speaker
        self.text = text
        self.tags = tags
        self.cue = cue

    @property
    def frozen(self):
        return "ok" in self.tags


def dialogue_texts():
    found = []
    for source in dialogue.sources(story_only=True):
        for line in source.lines:
            found.append(Text(line.where, line.id, line.kind, line.speaker, line.text, line.tags, line.cue))
    return found


def csv_texts():
    found = []
    for name in STORY_CSV:
        path = os.path.join(LOCALE_DIR, name)
        with open(path, encoding="utf-8", newline="") as f:
            reader = csv.reader(f)
            next(reader)
            for number, row in enumerate(reader, 2):
                if len(row) >= 2 and row[0]:
                    where = "content/locale/%s:%d" % (name, number)
                    found.append(Text(where, row[0], "csv", "", row[1], []))
    return found


def all_texts():
    return dialogue_texts() + csv_texts()
