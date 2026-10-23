#!/usr/bin/env python3
"""Report on the story dialogue (standard library only): speakers, status tags, unused cues.

Usage: python3 tools/writing/report.py [--json]
Not part of tools/check.sh. The numbers are what the style book (docs/writing/) is measured
from: lines and words per speaker, how much of each file is draft, frozen or untagged, and which
cues nothing starts any more. Cues that code starts from a variable show up as unused; look
before deleting.
"""
import collections
import json
import os
import re
import sys

import dialogue

CODE_DIRS = ("core", "entities", "world", "ui", "encounters", "content/maps", "tools/autopilot")
CODE_EXTENSIONS = (".gd", ".tscn", ".txt", ".json")


def speaker_stats(sources):
    stats = collections.OrderedDict()
    for source in sources:
        for line in source.lines:
            name = line.speaker or ("(Spielerin/Spieler)" if line.kind == "response" else "(Erzählung)")
            entry = stats.setdefault(name, {"lines": 0, "words": 0, "longest": 0})
            entry["lines"] += 1
            entry["words"] += line.words
            entry["longest"] = max(entry["longest"], line.words)
    total = sum(e["lines"] for e in stats.values()) or 1
    for entry in stats.values():
        entry["mean"] = round(entry["words"] / max(entry["lines"], 1), 1)
        entry["share"] = round(100.0 * entry["lines"] / total, 1)
    return collections.OrderedDict(sorted(stats.items(), key=lambda kv: -kv[1]["lines"]))


def status_stats(sources):
    stats = collections.OrderedDict()
    for source in sources:
        counts = collections.Counter()
        for line in source.lines:
            tags = [t for t in line.tags if t in ("draft", "ok", "ph")]
            counts[tags[0] if tags else "untagged"] += 1
        stats[source.relative] = {"lines": len(source.lines), "cues": len(source.cues), **counts}
    return stats


def code_text():
    chunks = []
    for folder in CODE_DIRS:
        for base, _, files in os.walk(os.path.join(dialogue.ROOT, folder)):
            for name in files:
                if name.endswith(CODE_EXTENSIONS):
                    with open(os.path.join(base, name), encoding="utf-8") as f:
                        chunks.append(f.read())
    return "\n".join(chunks)


def unused_cues(sources, code):
    jumps = set()
    for source in sources:
        jumps |= source.jumps
    found = []
    for source in sources:
        for cue in source.cues:
            quoted = re.search(r"[\"']%s[\"']" % re.escape(cue), code) is not None
            if not quoted and cue not in jumps:
                found.append("%s: ~ %s" % (source.relative, cue))
    return found


def main(argv):
    sources = dialogue.sources(story_only=True)
    speakers = speaker_stats(sources)
    statuses = status_stats(sources)
    unused = unused_cues(sources, code_text())
    if "--json" in argv:
        print(json.dumps({"speakers": speakers, "files": statuses, "unused_cues": unused},
                         ensure_ascii=False, indent=1))
        return 0
    print("%-22s %6s %6s %6s %7s %8s" % ("speaker", "lines", "words", "mean", "longest", "share %"))
    for name, e in speakers.items():
        print("%-22s %6d %6d %6.1f %7d %8.1f" % (name, e["lines"], e["words"], e["mean"], e["longest"], e["share"]))
    total_lines = sum(e["lines"] for e in speakers.values())
    total_words = sum(e["words"] for e in speakers.values())
    print("%-22s %6d %6d %6.1f" % ("all", total_lines, total_words, total_words / max(total_lines, 1)))
    print()
    print("%-28s %6s %5s %6s %5s %4s %9s" % ("file", "lines", "cues", "draft", "ok", "ph", "untagged"))
    for name, e in statuses.items():
        print("%-28s %6d %5d %6d %5d %4d %9d" % (name, e["lines"], e["cues"], e.get("draft", 0),
                                                   e.get("ok", 0), e.get("ph", 0), e.get("untagged", 0)))
    print()
    print("cues nothing starts (%d):" % len(unused))
    for entry in unused:
        print("  " + entry)
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
