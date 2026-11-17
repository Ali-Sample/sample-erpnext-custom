"""Check an issue's "Process step" line against the process map (RHOS change C4).

Reads the issue body from the ISSUE_BODY environment variable (never from the command line).
Writes result=skip|valid|invalid and step=<value> to $GITHUB_OUTPUT when set.
"""

import os
import re
import sys

from check_process_map import load, step_ids

SECTION = re.compile(r"^###\s*Process step\s*$\n+^(.*?)$", re.MULTILINE)


def check(body, steps):
	m = SECTION.search(body or "")
	if not m:
		return "skip", ""
	step = m.group(1).strip()
	return ("valid" if step in steps else "invalid"), step


def demo():
	steps = {"o2c/quote/create"}
	assert check("### Process step\n\no2c/quote/create\n\n### The need\n\nx", steps) == ("valid", "o2c/quote/create")
	assert check("### Process step\n\no2c/nope\n", steps) == ("invalid", "o2c/nope")
	assert check("plain issue, no form", steps) == ("skip", "")
	print("check_handoff demo: ok")


if __name__ == "__main__":
	if sys.argv[1:] == ["--demo"]:
		demo()
		sys.exit(0)
	result, step = check(os.environ.get("ISSUE_BODY", ""), step_ids(load()))
	print(f"result={result} step={step!r}")
	out = os.environ.get("GITHUB_OUTPUT")
	if out:
		with open(out, "a", encoding="utf-8") as f:
			f.write(f"result={result}\nstep={step.replace(chr(10), ' ')}\n")
