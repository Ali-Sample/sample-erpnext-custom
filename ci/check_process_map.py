"""Check docs/models/processes.yaml: ids unique, hand-offs point at real steps, owners are real streams.

Usage: python ci/check_process_map.py [path]    (exit 1 and list every problem if the map is broken)
"""

import sys
from collections import Counter

import yaml

DEFAULT_PATH = "docs/models/processes.yaml"


def load(path=DEFAULT_PATH):
	with open(path, encoding="utf-8") as f:
		return yaml.safe_load(f)


def step_ids(model):
	return {
		f"{s['id']}/{p['id']}/{step}" for s in model["streams"] for p in s["processes"] for step in p["steps"]
	}


def problems(model):
	errors = []
	streams = [s["id"] for s in model["streams"]]
	labels = [p["label"] for s in model["streams"] for p in s["processes"]]
	all_steps = [
		f"{s['id']}/{p['id']}/{step}" for s in model["streams"] for p in s["processes"] for step in p["steps"]
	]
	for kind, values in (("stream id", streams), ("process label", labels), ("step", all_steps)):
		errors += [f"duplicate {kind}: {v}" for v, n in Counter(values).items() if n > 1]
	steps = set(all_steps)
	for h in model.get("handoffs", []):
		for end in ("from", "to"):
			if h.get(end) not in steps:
				errors.append(f"hand-off {h.get('from')} -> {h.get('to')}: '{end}' is not a step in the map")
		if h.get("owner") not in streams:
			errors.append(f"hand-off {h.get('from')} -> {h.get('to')}: owner '{h.get('owner')}' is not a stream")
	return errors


if __name__ == "__main__":
	path = sys.argv[1] if len(sys.argv) > 1 else DEFAULT_PATH
	model = load(path)
	errs = problems(model)
	for e in errs:
		print(f"::error file={path}::{e}")
	print(f"{path}: {len(step_ids(model))} steps, {len(model.get('handoffs', []))} hand-offs, {len(errs)} problems")
	sys.exit(1 if errs else 0)
