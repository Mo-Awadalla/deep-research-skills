# Deep Research Skills

Two complementary agent skills for producing self-contained research handoffs and optionally executing them. The core is portable; the companion supplies Mohamed's defaults and optional topic rules.

- [`deep-research-prompt/SKILL.md`](deep-research-prompt/SKILL.md): contract authoring, evidence standards, research cycles, handoff templates, and verification.
- [`deep-research-briefs/SKILL.md`](deep-research-briefs/SKILL.md): brief-first and Gemini preferences, optional practitioner leads, output preferences, and topic modules.

## Default workflow

Author a handoff unless the current request explicitly asks for research execution or a finished report. Inspect supplied context and do a focused feasibility scan, then produce one self-contained Markdown packet with stage prompts and explicit attachments. Initial materials and future-generated reports/audits are distinguished.

The default `n = 5` means **five complete research → audit → repair cycles**, not five calls. There are **15 scheduled full research calls**, plus necessary independent re-audits and additional targeted repairs. Complete all cycles even if an earlier version passes. User-specified cycle counts override the default.

Each cycle revisits the whole contract, with emphasis on coverage, alternatives, source integrity, methods/feasibility, then final challenge. Auditors use separate contexts and perform actual evidence checks. Keep versioned reports, evidence deltas, findings, resolutions, and truthful call records. Prepared prompts and failed calls do not count as completed research.

Substantive repairs need independent review at the resulting revision; a later scheduled audit can do this if it checks that exact revision. A justified no-change repair can retain an independent audit of the unchanged report, evidence, and criteria. After the schedule, continue repair until acceptance passes. If required evidence or capabilities prevent progress, keep the artifact unapproved and report the blocker.

## Evidence and outcomes

Useful supported conclusions are the objective. There is no forced novelty, Reddit branch, winner, or arbitrary source count. Relevant practitioner anecdotes remain leads until the actual claim has appropriate support. Credible counterevidence must not be dismissed as contamination merely because it disagrees. Multiple reports citing one source remain one evidentiary root.

- `PASS`: the report satisfies its contract, all requested cycles are complete, and the current revision has independent review.
- `REPAIR_REQUIRED`: defects remain and meaningful repair is possible; the artifact is unapproved.
- `BLOCKED`: necessary input, evidence, access, or capability is unavailable; the artifact is unapproved and names the resumption condition.

A ready handoff and a structurally valid record are distinct from an approved research report. Automated checks assess the consistency of recorded attestations; they cannot certify source truth, context independence, or execution of a remote provider call.

## Files and use

Start with the core skill and apply the companion when its personal defaults are relevant. Both entry points are under 100 lines. Load additional references only as needed; expand applicable requirements into the exported handoff.

- [Research handoff template](deep-research-prompt/templates/research-brief.md)
- [Implementation authoring overlay](deep-research-prompt/templates/implementation-brief.md), merged into the full handoff before export
- [Cycle protocol](deep-research-prompt/references/research-cycles.md)
- [Canonical artifact schema](deep-research-prompt/references/artifact-schema.md)
- [Complete offline handoff example](deep-research-prompt/examples/documentation-handoff.md)
- [Verification report template](deep-research-prompt/templates/verification-report.md)

The companion directly links optional Islamic research, training/executable-plan, strategy, and skill/plugin-blueprint modules. Current user instructions override personal defaults. Provider/tool capabilities are detected, not assumed. `config/mcporter.json` is an optional provider configuration example; the core does not load or require it.

Save outputs as UTF-8 in the user-selected location, a configured profile location, or the current workspace's `research/` directory. Preserve source-language quotations and mathematical symbols.

## Validation

Requirements: Python 3 with PyYAML and a shell for the wrapper commands. Run from `deep-research-prompt/` or use absolute script paths.

```sh
python3 scripts/validate-evidence-state.py REPORT.md
bash scripts/verify-deep-research-output.sh ARTIFACT.md CONTRACT.md
bash scripts/evaluate-skill.sh
```

The first command checks evidence structure only. The second checks the artifact against a separate governing acceptance contract; without that contract it cannot establish approval. Use the schema's versioned fields rather than the older two-space marker format. Indentation is parsed as YAML, missing/malformed configuration does not silently disable checks, and IDs such as C1/E1 are consistent across tools.

The evaluation script checks skill metadata, local links, script syntax, and the shipped handoff example directly. It does not run a unit-test suite. The [agent evaluation scenarios](deep-research-prompt/references/evaluation-cases.md) are optional behavioral reviews requiring real recorded runs. Do not present scenario counts or declared requirements as measured research quality. These checks do not perform the fifteen provider research calls.
