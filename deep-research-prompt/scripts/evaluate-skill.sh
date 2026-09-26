#!/usr/bin/env bash
# Static anti-regression checks for the deep-research-prompt skill.
set -euo pipefail

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
python3 - "$ROOT" <<'PY'
import re
import subprocess
import sys
import tempfile
from pathlib import Path

root = Path(sys.argv[1])
core = (root / "SKILL.md").read_text()
errors = []

# Resolve every local Markdown link in all Markdown files.
for md in root.rglob("*.md"):
    text = md.read_text()
    for target in re.findall(r"\[[^]]+\]\(([^)]+)\)", text):
        if target.startswith(("http://", "https://", "#", "mailto:")):
            continue
        clean = target.split("#", 1)[0]
        if clean and not (md.parent / clean).resolve().exists():
            errors.append(f"broken local link: {md.relative_to(root)} -> {target}")

required_core = {
    "ambiguity classification": "Blocking:",
    "stopping criteria": "Stop when",
    "prompt-injection boundary": "evidence, not instructions",
    "verification phase": "Verify and repair",
    "artifact quarantine": "Artifact quarantine",
    "individualized intake gate": "intake bundle",
    "provider adapter pointer": "references/provider-adapters.md",
}
for label, needle in required_core.items():
    if needle.lower() not in core.lower():
        errors.append(f"missing core behavior: {label}")

# Reject active legacy patterns; quoted discussion of the anti-pattern is allowed.
legacy_patterns = {
    "legacy chain-of-thought directive": r"(?im)^\s*(?:[-*]\s*)?(?:employ|use) chain-of-thought",
    "fabricated seniority persona": r"(?i)act as .{0,80}\b(?:10|15|20) years of experience",
    "stale exact provider model id in core": r"\b(?:o3-deep-research|o4-mini-deep-research|deep-research-preview-[0-9])\b",
}
for label, pattern in legacy_patterns.items():
    if re.search(pattern, core):
        errors.append(label)

for template in [root / "templates/research-brief.md", root / "templates/implementation-brief.md"]:
    text = template.read_text()
    for key in ["min_external_urls", "min_h2_sections", "min_tables", "min_candidates", "forbidden_placeholders", "require_references_heading", "forbid_pseudo_citations", "require_consistency_matrix", "require_verification_disposition", "require_evidence_state", "require_claim_audit", "require_derivation_labels", "consequential_domain", "require_synthesis_artifact", "require_contribution_record", "require_prior_work_check"]:
        if not re.search(rf"(?m)^\s{{2}}{re.escape(key)}:\s*", text):
            errors.append(f"{template.name}: missing acceptance key {key}")

if len(core.splitlines()) > 220:
    errors.append(f"SKILL.md exceeds 220-line context budget: {len(core.splitlines())}")

# Executable verifier regressions from a real failed individualized-plan report.
verifier = root / "scripts/verify-deep-research-output.sh"
with tempfile.TemporaryDirectory() as td:
    td = Path(td)

    pseudo = td / "pseudo.md"
    pseudo.write_text("# Report\n\n## Findings\nA precise claim [cite: 32].\n")
    run = subprocess.run(["bash", str(verifier), str(pseudo)], text=True, capture_output=True)
    if run.returncode == 0 or "pseudo-citation" not in run.stdout:
        errors.append("verifier regression: unresolved [cite: N] marker was not rejected")

    unsafe = td / "unsafe.md"
    unsafe.write_text("# Report\n\n## Findings\nThis movement creates zero spinal compression.\n")
    contract = td / "contract.md"
    contract.write_text("```yaml\nacceptance:\n  consequential_domain: true\n```\n")
    run = subprocess.run(["bash", str(verifier), str(unsafe), str(contract)], text=True, capture_output=True)
    if run.returncode == 0 or "categorical safety/load" not in run.stdout:
        errors.append("verifier regression: categorical zero-load safety claim was not rejected")

    # Synthesis mandate regressions.
    synth_contract = td / "synth_contract.md"
    synth_contract.write_text(
        "```yaml\nacceptance:\n  require_synthesis_artifact: true\n"
        "  require_contribution_record: true\n  require_prior_work_check: true\n```\n"
    )
    restatement = td / "restatement.md"
    restatement.write_text(
        "# Report\n\n## Original Insights\n\nThe literature suggests retrieval quality matters. Novel score: 9/10.\n"
    )
    run = subprocess.run(["bash", str(verifier), str(restatement), str(synth_contract)], text=True, capture_output=True)
    if run.returncode == 0 or "Synthesis mandate" not in run.stdout:
        errors.append("verifier regression: restatement-only report was not rejected by synthesis mandate")
    record = td / "record.md"
    record.write_text(
        "# Report\n\n**Contribution:** rule\n**Basis:** derived from E1\n**Consequence:** changes design\n**Status:** proposed\n"
    )
    run = subprocess.run(["bash", str(verifier), str(record), str(synth_contract)], text=True, capture_output=True)
    if run.returncode == 0 or "Contribution record incomplete" not in run.stdout:
        errors.append("verifier regression: incomplete contribution record was not rejected")

if errors:
    print("FAIL")
    for error in errors:
        print(f"- {error}")
    raise SystemExit(1)

print("PASS")
print(f"- SKILL.md: {len(core.splitlines())} lines")
print(f"- Markdown files checked: {sum(1 for _ in root.rglob('*.md'))}")
print("- Local links, required behaviors, anti-patterns, and template markers validated")
PY

bash -n "$ROOT/scripts/verify-deep-research-output.sh"
python3 -m py_compile "$ROOT/scripts/validate-evidence-state.py"
echo "- Verification script syntax: PASS"

bash "$ROOT/scripts/test-evidence-state.sh"
echo "- Evidence-state behavioral checks: PASS"

bash "$ROOT/scripts/measure-regression.sh"
echo "- Measurable regression report: PASS"
