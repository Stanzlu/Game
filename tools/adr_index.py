#!/usr/bin/env python3
"""Rebuilds the index table at the top of docs/DECISIONS.md from the ADR headings.

Usage: python3 tools/adr_index.py [--check]
--check only reports whether the index is current (exit 1 if not); tools/check.sh runs it.
"""
import re
import sys
from pathlib import Path

PATH = Path(__file__).resolve().parent.parent / "docs" / "DECISIONS.md"
START = "## Index"
END = "\n---\n\n## ADR-001"


def build(text: str) -> str:
    adrs = re.findall(r"^## (ADR-\d+) · (.+)$", text, flags=re.M)
    rows = ["| %s | %s |" % (num, title) for num, title in adrs]
    head = (
        "## Index\n\nZum Nachschlagen: Nur den ADR lesen, der zur Aufgabe passt (die Datei ist groß). "
        "Der Index steht oben, neue ADRs hängen unten an und kommen hier hinein "
        "(`tools/adr_index.py` erzeugt ihn).\n\n| ADR | Titel |\n|---|---|\n"
    )
    return head + "\n".join(rows) + "\n"


def main() -> int:
    text = PATH.read_text(encoding="utf-8")
    start = text.index(START)
    end = text.index(END, start)
    # the block between "## Index" and the "---" before ADR-001
    new_block = build(text) + "\n---\n"
    current = text[start:end] + "\n---\n"
    if "--check" in sys.argv:
        if current.strip() != new_block.strip():
            print("adr index: docs/DECISIONS.md is out of date, run tools/adr_index.py")
            return 1
        print("adr index: ok (%d ADRs)" % len(re.findall(r"^\| ADR-", new_block, flags=re.M)))
        return 0
    text = text[:start] + new_block + text[end + len("\n---\n"):]
    PATH.write_text(text, encoding="utf-8")
    print("adr index: written")
    return 0


if __name__ == "__main__":
    sys.exit(main())
