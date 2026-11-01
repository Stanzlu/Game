#!/usr/bin/env python3
"""Reading version of dialogue files (standard library only): the text as a script, for a human reader.

Usage: python3 tools/writing/readable.py TITLE OUT.md [FILE.dialogue[#cue,cue] ...]
Without files all story dialogue is written. A file with "#cue,cue" gives only those cues (the delta
of a segment in a file that older segments wrote); the numbers stay those of the whole file and a cue
that is not in the file stops the run. The reading version is for the owner, who is the only
reader (ADR-049): per cue a number (E3, T12) to answer with "OK", "ändern" or "raus", then the
lines in the order the game plays them, with the conditions that pick them and the answers as
branches. It shows no code except the conditions; what a line sets (flags, items, XP) is left out
and lives in the consequence register (docs/writing/MOTIVE.md).
"""
import os
import re
import sys

import dialogue

CONDITION = re.compile(r"^(if|elif)\s+(.*)$")
INLINE_CONDITION = re.compile(r"^(%\d*\s+)?\[(if|elif)\s+(.*?)\s*/\]\s*(.*)$")
RESPONSE_CONDITION = re.compile(r"\s*\[if\s+(.*?)\s*/\]")
TOKEN = re.compile(r"\{\{(.*?)\}\}")
EFFECT = re.compile(r"\[/?(?:wave|rainbow|shake|wait|speed|next|pause|tremble)[^\]]*\]")
PREFIX = {
    "elysia": "E",
    "tal": "T",
    "haus": "H",
    "antreiber": "A",
    "ankunft": "AN",
    "bachlauf": "BL",
    "aufbruch": "W1-",  # Act III: one prefix per segment ("W1-1")
    "waldweg": "W2-",
    "huette": "W3-",
    "flutlichtung": "W4-",
    "nachtwald": "W5-",
    "heimkehr": "W6-",
}
# The order in which the slice plays its places; other files follow by name.
ORDER = ["elysia", "tal", "antreiber", "haus"]


def person(expression):
    """A value in the text ({{ }}) as a placeholder a reader understands."""
    if "player_name" in expression:
        return "‹Name›"
    if "cat_name" in expression:
        return "‹Katzenname›"
    match = re.search(r'label_for\("(\w+)"\)', expression)
    if match:
        return "‹Taste: %s›" % match.group(1)
    return "‹…›"


def clean(text):
    """The words of a line: no ID, status tag, effects or condition, values as placeholders."""
    text = dialogue.ID_RE.sub("", text)
    text = dialogue.TAG_RE.sub("", text)
    text = TOKEN.sub(lambda m: person(m.group(1)), text)
    text = EFFECT.sub("", text)
    return re.sub(r"\s+", " ", text).strip()


def condition_text(expression):
    """A condition shortened to what a reader needs: the flag or memory it asks for."""
    # "a or b" stays an "or" (a reader who reads "and" for it learns a condition that needs both)
    terms = []
    for part in re.split(r"\bor\b", expression):
        names = re.findall(r'"([a-z0-9_.]+)"', part)
        if names:
            negated = " nicht" if re.search(r"\bnot\b|!=", part) else ""
            terms.append("%s%s" % (" und ".join(names), negated))
    if terms:
        return " oder ".join(terms)
    return expression.replace("WorldState.", "")


def render_file(path, prefix, only=None):
    out = []
    pending = []
    cue_number = 0
    skipping = False  # inside a cue that `only` leaves out
    found = set()
    stack = []  # (indent, label) of the open conditions
    opened = False  # the comment above the first cue is the file's header: no reader's business
    with open(path, encoding="utf-8") as f:
        raw_lines = f.read().replace("\r", "").split("\n")
    for raw in raw_lines:
        stripped = raw.strip()
        indent = len(raw) - len(raw.lstrip("\t"))
        if not stripped:
            continue
        if stripped.startswith("#"):
            pending.append(stripped.lstrip("# ").strip())
            continue
        if stripped.startswith("~ "):
            cue_number += 1
            if not opened:
                pending = []
                opened = True
            name = stripped[2:].strip()
            found.add(name)
            skipping = only is not None and name not in only
            if skipping:
                pending = []
                continue
            out += ["", "### %s%d · `%s`" % (prefix, cue_number, name), ""]
            out += ["> " + note for note in pending]
            if pending:
                out.append("")
            pending = []
            stack = []
            continue
        pending = []
        if skipping:
            continue
        while stack and stack[-1][0] >= indent:
            stack.pop()
        pad = "  " * max(indent - 0, 0)
        match = CONDITION.match(stripped)
        if match:
            label = condition_text(match.group(2))
            word = "wenn" if match.group(1) == "if" else "sonst wenn"
            out.append("%s*%s* `%s`" % (pad, word, label))
            stack.append((indent, label))
            continue
        if stripped == "else":
            out.append("%s*sonst*" % pad)
            stack.append((indent, "else"))
            continue
        jump = re.match(r"^=>(<?)\s*([A-Za-z0-9_]+)", stripped)
        if jump:
            if jump.group(2) != "END":
                what = "dazwischen" if jump.group(1) else "weiter bei"
                out.append("%s- *→ %s* `%s`" % (pad, what, jump.group(2)))
            elif indent > 0:
                # an end inside a condition skips what follows for this branch: the reader must see it
                out.append("%s- *→ Ende des Szenenstücks*" % pad)
            continue
        if stripped.startswith(("do ", "do! ", "set ", "=>", "match", "when", "while", "using", "import")):
            continue
        inline = INLINE_CONDITION.match(stripped)
        note = ""
        if inline:
            note = " *(wenn `%s`)*" % condition_text(inline.group(3))
            stripped = inline.group(4)
        else:
            stripped = re.sub(r"^%\d*\s+", "", stripped)
        if stripped.startswith("- "):
            body = stripped[2:]
            answer_condition = RESPONSE_CONDITION.search(body)
            if answer_condition:
                note = " *(wenn `%s`)*" % condition_text(answer_condition.group(1))
                body = RESPONSE_CONDITION.sub("", body)
            out.append("%s- ▸ **%s**%s" % (pad, clean(body), note))
            continue
        status = dialogue.TAG_RE.findall(stripped)
        marker = " `[#%s]`" % status[0] if status else ""
        identifier = dialogue.ID_RE.search(stripped)
        tail = "  <sub>%s</sub>" % identifier.group(1) if identifier else ""
        match = dialogue.SPEAKER_RE.match(stripped)
        if match:
            out.append("%s- **%s:** %s%s%s%s" % (pad, match.group(1), clean(match.group(2)), note, marker, tail))
        else:
            out.append("%s- *%s*%s%s%s" % (pad, clean(stripped), note, marker, tail))
    missing = sorted(set(only or ()) - found)
    if missing:
        raise SystemExit("readable: no cue %s in %s" % (", ".join(missing), os.path.basename(path)))
    return out


def render(title, paths):
    out = ["# " + title, "",
           "<!-- Erzeugt mit `python3 tools/writing/readable.py`. Nicht von Hand ändern: Änderungen gehören in die .dialogue-Dateien. -->",
           "",
           "Lesefassung: der Text in der Reihenfolge, in der das Spiel ihn zeigt. *Kursiv* ist Erzählung, "
           "**fett** sprechen die Figuren, ▸ sind deine Antworten. Eingerückt steht, was nur unter einer "
           "Bedingung oder nach einer Antwort kommt. Hinter jeder Zeile die ID in klein.", "",
           "**So antwortest du:** je Szene (E3, T12 …) „OK“, „ändern: …“ oder „raus“. Was du nicht nennst, "
           "gilt als OK.", ""]
    for entry in paths:
        path, only = entry if isinstance(entry, tuple) else (entry, None)
        name = os.path.splitext(os.path.basename(path))[0].replace(".dialogue", "")
        prefix = PREFIX.get(name, name[:1].upper())
        out += ["", "## " + os.path.basename(path).replace(".dialogue", ""), ""]
        out += render_file(path, prefix, only)
    out.append("")
    return "\n".join(out)


def with_cues(argument):
    """"file.dialogue#cue,cue" becomes (absolute path, {cues}); a plain path stays a path."""
    path, _, cues = argument.partition("#")
    if not cues:
        return os.path.abspath(path)
    return (os.path.abspath(path), set(cues.split(",")))


def story_paths():
    paths = [source.path for source in dialogue.sources(story_only=True)]
    return sorted(paths, key=order_key)


def order_key(path):
    name = os.path.splitext(os.path.basename(path))[0]
    return (ORDER.index(name) if name in ORDER else len(ORDER), path)


def main(argv):
    if len(argv) < 2:
        print(__doc__)
        return 2
    title, target = argv[0], argv[1]
    paths = [with_cues(arg) for arg in argv[2:]] or story_paths()
    with open(target, "w", encoding="utf-8", newline="\n") as f:
        f.write(render(title, paths))
    print("readable: wrote %s (%d files)" % (os.path.relpath(target, dialogue.ROOT), len(paths)))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
