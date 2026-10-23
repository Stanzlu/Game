"""Reader for the .dialogue sources (standard library only): lines, speakers, IDs, tags, cues.

Just enough of the Dialogue Manager syntax for the writing tools; the compiler stays the
authority on validity (core/content/content_validator.gd). Lines are classified as
    speech     "Speaker: text"
    narration  a text line without a speaker (the slice has no colon in narration)
    response   "- text" (the player's answers)
Everything that is code (if, elif, else, do, set, match, when, while, =>) or a comment is skipped.
"""
import os
import re

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
DIALOGUE_DIR = os.path.join(ROOT, "content", "dialogue")
# Directories of placeholder dialogue: they carry [#ph] on every line and are not story text.
PROTOTYPE_DIRS = ("sandbox", "valley", "elysia", "antreiber")

ID_RE = re.compile(r"\[ID:([A-Za-z0-9_]+)\]")
TAG_RE = re.compile(r"\[#([A-Za-z0-9_]+)\]")
BRACKET_RE = re.compile(r"\[/?[^\[\]]*\]")
REPLACE_RE = re.compile(r"\{\{[^}]*\}\}")
SPEAKER_RE = re.compile(r"^([^\s:\[\-=~#][^:\[\]{}]{0,40}?): +(.*)$")
CODE_RE = re.compile(r"^(if|elif|else|while|match|when|do|do!|set|using|import)\b")
JUMP_RE = re.compile(r"=>[<]?\s*([A-Za-z0-9_]+)")
# "% line" marks one line of a group of which one is picked at random ("%2 " weights it)
RANDOM_RE = re.compile(r"^%\d*\s+")


class Line:
    def __init__(self, path, number, kind, speaker, raw, cue):
        self.path = path
        self.number = number
        self.kind = kind
        self.speaker = speaker
        self.raw = raw
        self.cue = cue
        match = ID_RE.search(raw)
        self.id = match.group(1) if match else ""
        self.tags = TAG_RE.findall(raw)
        text = ID_RE.sub("", raw)
        text = TAG_RE.sub("", text)
        text = REPLACE_RE.sub("", text)
        self.text = BRACKET_RE.sub("", text).strip()

    @property
    def words(self):
        return len(re.findall(r"[\wÄÖÜäöüß'’-]+", self.text))

    @property
    def where(self):
        return "%s:%d" % (os.path.relpath(self.path, ROOT).replace(os.sep, "/"), self.number)


class Source:
    def __init__(self, path):
        self.path = path
        self.lines = []
        self.cues = {}
        self.jumps = set()

    @property
    def relative(self):
        return os.path.relpath(self.path, DIALOGUE_DIR).replace(os.sep, "/")

    @property
    def is_story(self):
        return self.relative.split("/")[0] not in PROTOTYPE_DIRS


def parse(path):
    source = Source(path)
    cue = ""
    with open(path, encoding="utf-8") as f:
        for number, raw in enumerate(f.read().replace("\r", "").split("\n"), 1):
            text = raw.strip()
            if not text or text.startswith("#"):
                continue
            if text.startswith("~ "):
                cue = text[2:].strip()
                source.cues[cue] = number
                continue
            for target in JUMP_RE.findall(text):
                source.jumps.add(target)
            if text.startswith("=>") or CODE_RE.match(text):
                continue
            text = RANDOM_RE.sub("", text)
            if text.startswith("- "):
                source.lines.append(Line(path, number, "response", "", text[2:], cue))
                continue
            match = SPEAKER_RE.match(text)
            if match:
                source.lines.append(Line(path, number, "speech", match.group(1), match.group(2), cue))
            else:
                source.lines.append(Line(path, number, "narration", "", text, cue))
    return source


def sources(story_only=False):
    found = []
    for folder, _, files in os.walk(DIALOGUE_DIR):
        for name in sorted(files):
            if name.endswith(".dialogue"):
                found.append(parse(os.path.join(folder, name)))
    found.sort(key=lambda s: s.path)
    return [s for s in found if s.is_story or not story_only]
