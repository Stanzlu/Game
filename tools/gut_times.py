#!/usr/bin/env python3
"""Prints the slowest GUT suites from a JUnit XML file (written by `-gjunit_xml_file=`).

Usage: python3 tools/gut_times.py <junit.xml> [count]
tools/check.sh calls it after the unit tests, so growth of the suite stays visible per file.
"""
import sys
import xml.etree.ElementTree as ET


def main() -> int:
    if len(sys.argv) < 2:
        print(__doc__)
        return 2
    count = int(sys.argv[2]) if len(sys.argv) > 2 else 5
    suites = []
    for suite in ET.parse(sys.argv[1]).getroot().iter("testsuite"):
        suites.append((float(suite.get("time", "0")), suite.get("name", "?"), suite.get("tests", "0")))
    suites.sort(reverse=True)
    total = sum(t for t, _, _ in suites)
    print("slowest of %d test files (game time %.0f s):" % (len(suites), total))
    for seconds, name, tests in suites[:count]:
        print("%7.1f s  %s (%s tests)" % (seconds, name, tests))
    return 0


if __name__ == "__main__":
    sys.exit(main())
