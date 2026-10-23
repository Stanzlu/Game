#!/usr/bin/env python3
"""ID lock for the story dialogue (standard library only): no line ID disappears silently.

Usage: python3 tools/writing/id_lock.py [--check]       report (exit 1 on errors)
       python3 tools/writing/id_lock.py --update        lock new IDs, freeze new [#ok] lines
       python3 tools/writing/id_lock.py --refreeze ID.. accept a deliberate change of frozen lines
       python3 tools/writing/id_lock.py --retire ID reason   give up an ID on purpose
The lock (content/dialogue/ids.lock, one line per ID: id, file, hash) records every line ID of the
story dialogue. The hash stands for the text of a frozen ([#ok]) line and is "-" for drafts.
Errors: a locked ID is gone (renamed or deleted: retire it with a reason), a frozen line changed
or lost its tag, a retired ID is used again. Notes: IDs not locked yet, frozen lines not hashed.
"""
import hashlib
import os
import sys

import dialogue

LOCK = os.path.join(dialogue.DIALOGUE_DIR, "ids.lock")
HEADER = (
    "# Locked line IDs of the story dialogue: id <TAB> file <TAB> hash of the frozen text ('-' = draft).\n"
    "# tools/writing/id_lock.py checks and updates it; do not edit by hand.\n"
)


def text_hash(line):
    data = "%s|%s|%s" % (line.kind, line.speaker, line.text)
    return hashlib.sha1(data.encode("utf-8")).hexdigest()[:10]


def current(story_sources=None):
    """id -> (relative file, hash or '-', line) of the story dialogue as it is now."""
    found = {}
    for source in story_sources if story_sources is not None else dialogue.sources(story_only=True):
        for line in source.lines:
            if line.id:
                frozen = "ok" in line.tags
                found[line.id] = (source.relative, text_hash(line) if frozen else "-", line)
    return found


def read_lock(path=LOCK):
    locked, retired = {}, {}
    if not os.path.exists(path):
        return locked, retired
    with open(path, encoding="utf-8") as f:
        for raw in f.read().split("\n"):
            if not raw or raw.startswith("#"):
                continue
            parts = raw.split("\t")
            if parts[0] == "retired" and len(parts) >= 3:
                retired[parts[1]] = parts[2]
            elif len(parts) == 3:
                locked[parts[0]] = (parts[1], parts[2])
    return locked, retired


def write_lock(locked, retired, path=LOCK):
    out = [HEADER]
    for key in sorted(locked):
        out.append("%s\t%s\t%s\n" % (key, locked[key][0], locked[key][1]))
    for key in sorted(retired):
        out.append("retired\t%s\t%s\n" % (key, retired[key]))
    with open(path, "w", encoding="utf-8", newline="\n") as f:
        f.write("".join(out))


def compare(now, locked, retired):
    """(level, message) list for the lock against the dialogue as it is now."""
    found = []
    for key, (file_name, frozen_hash) in sorted(locked.items()):
        if key not in now:
            if key not in retired:
                found.append(("error", "line ID '%s' (%s) is gone; renamed or deleted? Restore it or "
                              "run id_lock.py --retire %s <reason>" % (key, file_name, key)))
            continue
        now_file, now_hash, line = now[key]
        if frozen_hash != "-" and now_hash != frozen_hash:
            what = "changed" if now_hash != "-" else "lost its [#ok] tag"
            found.append(("error", "%s: frozen line '%s' %s since it was frozen; review it and run "
                          "id_lock.py --refreeze %s" % (line.where, key, what, key)))
        if now_file != file_name:
            found.append(("note", "%s: line ID '%s' moved from %s (id_lock.py --update records it)"
                          % (line.where, key, file_name)))
        if frozen_hash == "-" and now_hash != "-":
            found.append(("note", "%s: line '%s' is tagged [#ok] but not frozen yet (id_lock.py --update)"
                          % (line.where, key)))
    for key, (_, _, line) in sorted(now.items()):
        if key in retired:
            found.append(("error", "%s: retired line ID '%s' is used again" % (line.where, key)))
        elif key not in locked:
            found.append(("note", "%s: line ID '%s' is not locked yet (id_lock.py --update)" % (line.where, key)))
    return found


def problems():
    locked, retired = read_lock()
    return compare(current(), locked, retired)


def update(now, locked, retired):
    """Locks new IDs and hashes new [#ok] lines; never touches an existing frozen hash."""
    for key, (file_name, frozen_hash, _) in now.items():
        if key not in locked:
            locked[key] = (file_name, frozen_hash)
        else:
            old_file, old_hash = locked[key]
            locked[key] = (file_name, frozen_hash if old_hash == "-" else old_hash)
    return locked, retired


def main(argv):
    now = current()
    locked, retired = read_lock()
    if "--update" in argv:
        write_lock(*update(now, locked, retired))
        print("id lock: %d IDs locked" % len(read_lock()[0]))
        return 0
    if "--refreeze" in argv:
        for key in argv[argv.index("--refreeze") + 1:]:
            if key not in now or now[key][1] == "-":
                print("id lock: '%s' is not a frozen line" % key)
                return 1
            locked[key] = (now[key][0], now[key][1])
        write_lock(locked, retired)
        return 0
    if "--retire" in argv:
        at = argv.index("--retire")
        if len(argv) < at + 3:
            print("usage: id_lock.py --retire <id> <reason>")
            return 2
        key, reason = argv[at + 1], " ".join(argv[at + 2:])
        retired[key] = reason
        locked.pop(key, None)
        write_lock(locked, retired)
        return 0
    found = compare(now, locked, retired)
    for level, message in found:
        print("%s: %s" % (level, message))
    return 1 if any(level == "error" for level, _ in found) else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
