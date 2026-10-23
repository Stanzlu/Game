#!/usr/bin/env python3
"""Motif book and consequence register (standard library only): keeps docs/writing/ true to the game.

Usage: python3 tools/writing/motifs.py [--check]    report (exit 1 on errors)
       python3 tools/writing/motifs.py --write      regenerate docs/writing/MOTIVE.md from motive.json
       python3 tools/writing/motifs.py --flags      list the story flags found in the game (to fill the register)
docs/writing/motive.json is the source: foreshadowing (Bible 46), running gags (33), the child's images
(15), and the register of consequences (Plan 5.7, flag -> ending axis). The checker reports
    error  a line ID named in the book or quoted in docs/writing/*.md is gone, or its text changed
    error  a flag named in the book does not exist in the game
    error  MOTIVE.md differs from what motive.json generates
    note   a story flag set in the game is not in the register yet
"""
import json
import os
import re
import sys

import dialogue
import id_lock

ROOT = dialogue.ROOT
DOCS = os.path.join(ROOT, "docs", "writing")
SOURCE = os.path.join(DOCS, "motive.json")
OUTPUT = os.path.join(DOCS, "MOTIVE.md")
CODE_DIRS = ("core", "entities", "world", "ui", "encounters", "content/maps", "content/dialogue")
CODE_EXTENSIONS = (".gd", ".txt", ".dialogue")
# Flags that carry no story meaning of their own.
SKIPPED_PREFIXES = ("beat.", "chapter.")
FLAG_RE = re.compile(r'"([a-z]+\.[a-z0-9_]+)"')
SET_CONTEXT = re.compile(r'set_flag\(|"flag"\s*:|"start_flag"\s*:|Beat\.mark|clear_flag\(')
READ_CONTEXT = re.compile(r'has_flag\(|"if"\s*:|"unless"\s*:|sprite_when|flags\.get\(')
QUOTE_RE = re.compile(r"`([a-z][a-z0-9_]*)`\s+„([^“]+)“")


def load(path=SOURCE):
    with open(path, encoding="utf-8") as f:
        return json.load(f)


def code_files():
    for folder in CODE_DIRS:
        for base, _, files in os.walk(os.path.join(ROOT, folder)):
            for name in sorted(files):
                if name.endswith(CODE_EXTENSIONS):
                    yield os.path.join(base, name)


def flag_sites(files=None):
    """flag -> {"set": [files], "read": [files]} from the lines that mention it."""
    sites = {}
    for path in files if files is not None else code_files():
        relative = os.path.relpath(path, ROOT).replace(os.sep, "/")
        with open(path, encoding="utf-8") as f:
            for line in f:
                if line.lstrip().startswith("const "):
                    continue
                for flag in FLAG_RE.findall(line):
                    entry = sites.setdefault(flag, {"set": [], "read": []})
                    for kind, context in (("set", SET_CONTEXT), ("read", READ_CONTEXT)):
                        if context.search(line) and relative not in entry[kind]:
                            entry[kind].append(relative)
    return sites


def story_flags(sites):
    """Flags the game sets that mean something for the story (no beats, chapters, settings keys)."""
    found = []
    for flag, entry in sorted(sites.items()):
        if entry["set"] and not flag.startswith(SKIPPED_PREFIXES) and flag.split(".")[0] in (
            "elysia", "valley", "house", "forest", "encounter", "slice"
        ):
            found.append(flag)
    return found


def line_texts():
    """line ID -> visible text of the story dialogue as it is now."""
    return {line.id: line.text for source in dialogue.sources(story_only=True) for line in source.lines if line.id}


def refs(data):
    """Every ('line'|'flag', value, where) the book names."""
    found = []
    for motif in data["motifs"]:
        for ref in motif.get("appears", []):
            if ref["type"] in ("line", "flag"):
                found.append((ref["type"], ref["ref"], "motif " + motif["id"]))
        for flag in motif.get("flags", []):
            found.append(("flag", flag, "motif " + motif["id"]))
        for line in motif.get("payoff_lines", []):
            found.append(("line", line, "motif " + motif["id"]))
    for entry in data["register"]:
        found.append(("flag", entry["flag"], "register"))
    return found


def problems(data=None, texts_now=None, sites=None, doc_dir=DOCS, retired=None, output=OUTPUT):
    data = data if data is not None else load()
    texts_now = texts_now if texts_now is not None else line_texts()
    sites = sites if sites is not None else flag_sites()
    if retired is None:
        retired = id_lock.read_lock()[1]
    found = []
    for kind, ref, where in refs(data):
        if kind == "line" and ref not in texts_now:
            found.append(("error", "%s: line ID '%s' is gone%s" % (
                where, ref, " (retired: %s)" % retired[ref] if ref in retired else "")))
        if kind == "flag" and ref not in sites:
            found.append(("error", "%s: flag '%s' does not exist in the game" % (where, ref)))
    for path in sorted(os.path.join(doc_dir, n) for n in _markdown(doc_dir)):
        with open(path, encoding="utf-8") as f:
            text = f.read()
        relative = os.path.relpath(path, ROOT).replace(os.sep, "/")
        for line_id, quoted in QUOTE_RE.findall(text):
            if line_id not in texts_now:
                if re.fullmatch(r"[a-z]+_[a-z0-9_]+", line_id) and _looks_like_line_id(line_id):
                    found.append(("error", "%s: quotes line ID '%s', which is gone" % (relative, line_id)))
            elif _normal(texts_now[line_id]) != _normal(quoted):
                found.append(("error", "%s: '%s' reads „%s“ now, the page quotes „%s“"
                              % (relative, line_id, texts_now[line_id], quoted)))
    registered = {entry["flag"] for entry in data["register"]}
    for flag in story_flags(sites):
        if flag not in registered:
            found.append(("note", "flag '%s' is set in %s but not in the register of consequences "
                          "(docs/writing/motive.json)" % (flag, sites[flag]["set"][0])))
    expected = render(data, sites)
    current = ""
    if os.path.exists(output):
        with open(output, encoding="utf-8") as f:
            current = f.read()
    if current != expected:
        found.append(("error", "docs/writing/MOTIVE.md is out of date; run tools/writing/motifs.py --write"))
    return found


def _markdown(doc_dir):
    for base, _, files in os.walk(doc_dir):
        for name in files:
            if name.endswith(".md"):
                yield os.path.relpath(os.path.join(base, name), doc_dir)


def _looks_like_line_id(candidate):
    """A quoted `identifier` is a line ID when its prefix is one the dialogue uses."""
    prefixes = {i.split("_")[0] for i in line_texts()}
    return candidate.split("_")[0] in prefixes and candidate.count("_") >= 1


def _normal(text):
    return re.sub(r"\s+", " ", text).strip()


def render(data, sites):
    out = ["# Motivbuch", "",
           "<!-- Erzeugt aus docs/writing/motive.json mit `python3 tools/writing/motifs.py --write`. Nicht von Hand ändern. -->",
           "", data["intro"], ""]
    texts_now = line_texts()
    for section in data["sections"]:
        out += ["## " + section["title"], "", section["intro"], ""]
        out += ["| Motiv | Bible | Im Slice | Auflösung |", "|---|---|---|---|"]
        for motif in data["motifs"]:
            if motif["kind"] != section["kind"]:
                continue
            out.append("| **%s** | %s | %s | %s |" % (
                motif["title"], motif["bible"], _appearances(motif, texts_now), motif["payoff"]))
        out.append("")
    out += ["## Konsequenzen-Register", "", data["register_intro"], "",
            "| Flag | Achse | Gesetzt in | Gelesen in | Bedeutung |", "|---|---|---|---|---|"]
    for entry in data["register"]:
        site = sites.get(entry["flag"], {"set": [], "read": []})
        out.append("| `%s` | %s | %s | %s | %s |" % (
            entry["flag"], entry["axis"], _files(site["set"]), _files(site["read"]), entry["meaning"]))
    out.append("")
    return "\n".join(out)


def _appearances(motif, texts_now):
    parts = []
    for ref in motif.get("appears", []):
        if ref["type"] == "line":
            parts.append("`%s`" % ref["ref"])
        elif ref["type"] == "flag":
            parts.append("`%s`" % ref["ref"])
        else:
            parts.append(ref["ref"])
    return ", ".join(parts) if parts else "noch nicht"


def _files(paths):
    if not paths:
        return "–"
    return ", ".join("`%s`" % p.split("/")[-1] for p in paths)


def main(argv):
    if "--flags" in argv:
        for flag in story_flags(flag_sites()):
            print(flag)
        return 0
    data = load()
    if "--write" in argv:
        with open(OUTPUT, "w", encoding="utf-8", newline="\n") as f:
            f.write(render(data, flag_sites()))
        print("motifs: wrote %s" % os.path.relpath(OUTPUT, ROOT))
        return 0
    found = problems(data)
    for level, message in found:
        print("%s: %s" % (level, message))
    errors = sum(1 for level, _ in found if level == "error")
    print("motifs: %d errors, %d notes" % (errors, len(found) - errors))
    return 1 if errors else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
