#!/usr/bin/env python3
"""Validate the structured research_state embedded in a Markdown report."""
from __future__ import annotations
import re
import sys
from pathlib import Path

try:
    import yaml
except Exception as exc:  # pragma: no cover
    print(f"validator unavailable: {exc}")
    raise SystemExit(2)

if len(sys.argv) != 2:
    print("usage: validate-evidence-state.py REPORT.md", file=sys.stderr)
    raise SystemExit(2)

text = Path(sys.argv[1]).read_text(encoding="utf-8")
match = re.search(r"research_state:[ \t]*\n(.*?)(?=\n```|\n## |\Z)", text, re.S)
if not match:
    print("missing research_state block")
    raise SystemExit(1)

raw = "research_state:\n" + match.group(1)
try:
    doc = yaml.safe_load(raw)
except Exception as exc:
    print(f"invalid research_state YAML: {exc}")
    raise SystemExit(1)

state = doc.get("research_state") if isinstance(doc, dict) else None
errors: list[str] = []
if not isinstance(state, dict):
    errors.append("research_state is not a mapping")
else:
    for key in ("claims", "evidence", "coverage", "stopping"):
        if key not in state:
            errors.append(f"missing required field: {key}")
    claims = state.get("claims")
    evidence = state.get("evidence")
    if not isinstance(claims, list) or not claims:
        errors.append("claims must be a non-empty list")
        claims = []
    if not isinstance(evidence, list) or not evidence:
        errors.append("evidence must be a non-empty list")
        evidence = []

    claim_ids: set[str] = set()
    evidence_ids: set[str] = set()
    for item in claims:
        if not isinstance(item, dict):
            errors.append("each claim must be a mapping")
            continue
        cid = item.get("id")
        if not isinstance(cid, str) or not re.fullmatch(r"C\d+", cid):
            errors.append(f"invalid claim id: {cid!r}")
        elif cid in claim_ids:
            errors.append(f"duplicate claim id: {cid}")
        else:
            claim_ids.add(cid)

    for item in evidence:
        if not isinstance(item, dict):
            errors.append("each evidence item must be a mapping")
            continue
        eid = item.get("id")
        if not isinstance(eid, str) or not re.fullmatch(r"E\d+", eid):
            errors.append(f"invalid evidence id: {eid!r}")
        elif eid in evidence_ids:
            errors.append(f"duplicate evidence id: {eid}")
        else:
            evidence_ids.add(eid)
        if not isinstance(item.get("url"), str) or not item["url"].startswith(("http://", "https://")):
            errors.append(f"evidence {eid!r} missing valid URL")
        if not isinstance(item.get("independence_group"), str) or not item["independence_group"]:
            errors.append(f"evidence {eid!r} missing independence_group")
        if item.get("user_generated") is True:
            corr = item.get("corroborated_by")
            if not isinstance(corr, list) or not corr:
                errors.append(f"user-generated evidence {eid!r} missing corroborated_by IDs")

    evidence_by_id = {item.get("id"): item for item in evidence if isinstance(item, dict)}
    for item in claims:
        if not isinstance(item, dict):
            continue
        cid = item.get("id")
        links = item.get("evidence_ids", [])
        if not isinstance(links, list) or not links:
            errors.append(f"claim {cid!r} has no evidence_ids")
            continue
        linked = [evidence_by_id.get(eid) for eid in links]
        if not any(isinstance(ev, dict) and isinstance(ev.get("support"), str) for ev in linked):
            errors.append(f"claim {cid!r} has no linked support classification")
        for eid in links:
            if eid not in evidence_ids:
                errors.append(f"claim {cid!r} references unknown evidence {eid!r}")

    for ev in evidence:
        if not isinstance(ev, dict) or ev.get("user_generated") is not True:
            continue
        corr = ev.get("corroborated_by", [])
        for eid in corr if isinstance(corr, list) else []:
            other = evidence_by_id.get(eid)
            if not isinstance(other, dict):
                errors.append(f"user-generated evidence {ev.get('id')!r} references unknown corroboration {eid!r}")
            elif other.get("independence_group") == ev.get("independence_group"):
                errors.append(f"UGC evidence {ev.get('id')!r} corroborated only by same independence group")


if errors:
    print("invalid evidence state")
    for error in errors:
        print(f"- {error}")
    raise SystemExit(1)

print("valid evidence state")
raise SystemExit(0)
