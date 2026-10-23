#!/usr/bin/env python3
"""Lints of the story text (standard library only): vocabulary, numbers and status tags.

Usage: python3 tools/writing/lint.py
Prints `note:` lines (to work off while writing; the exit code stays 0) and `error:` lines (exit
code 1). A line tagged [#ok] is frozen: for it every note is an error. The ID lock has its own
tool (tools/writing/id_lock.py); this script runs it as well.
"""
import json
import os
import re
import sys

import id_lock
import texts

HERE = os.path.dirname(os.path.abspath(__file__))
VOCABULARY = os.path.join(HERE, "vocabulary.json")
NUMBER_RE = re.compile(r"\d")
STATUS_TAGS = ("draft", "ok", "ph")


def load_vocabulary(path=VOCABULARY):
    with open(path, encoding="utf-8") as f:
        data = json.load(f)
    terms = {name: re.compile(pattern, re.IGNORECASE) for name, pattern in data["terms"].items()}
    excepted = {(e["where"], e["term"]) for e in data.get("exceptions", [])}
    return terms, excepted


def severity(text):
    return "error" if text.frozen else "note"


def vocabulary_problems(items, terms, excepted):
    problems = []
    for item in items:
        for name, pattern in terms.items():
            match = pattern.search(item.text)
            if match and (item.key, name) not in excepted:
                problems.append((severity(item), "%s: '%s' is %s language (%s); rephrase or list it "
                                 "under exceptions in vocabulary.json" % (item.where, match.group(0), name, item.key)))
    return problems


def number_problems(items, excepted):
    """Digits in story text: numbers are spelled out, signs and the like are listed as exceptions."""
    problems = []
    for item in items:
        if NUMBER_RE.search(item.text) and (item.key, "number") not in excepted:
            problems.append((severity(item), "%s: digits in story text (%s), spell the number out or list "
                             "it under exceptions with term 'number'" % (item.where, item.key)))
    return problems


def tag_problems(items):
    """Status tags: at most one of [#draft], [#ok], [#ph] on a line; placeholders are never frozen."""
    problems = []
    for item in items:
        tags = [t for t in item.tags if t in STATUS_TAGS]
        if len(tags) > 1:
            problems.append(("error", "%s: more than one status tag (%s)" % (item.where, ", ".join(tags))))
    return problems


def run():
    items = texts.all_texts()
    terms, excepted = load_vocabulary()
    found = vocabulary_problems(items, terms, excepted)
    found += number_problems(items, excepted)
    found += tag_problems([i for i in items if i.kind != "csv"])
    found += id_lock.problems()
    return found


def main():
    found = run()
    for level, message in found:
        print("%s: %s" % (level, message))
    errors = sum(1 for level, _ in found if level == "error")
    notes = len(found) - errors
    print("writing lint: %d errors, %d notes" % (errors, notes))
    return 1 if errors else 0


if __name__ == "__main__":
    sys.exit(main())
