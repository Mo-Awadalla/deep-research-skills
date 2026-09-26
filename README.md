# Deep Research Skills

Two [Hermes Agent](https://hermes-agent.nousresearch.com/docs) skills for running disciplined, evidence-gated deep research:

- **`deep-research-prompt/`** — the core protocol: authoring a research contract, evidence rules (claim → source → quote), provider adapters, output verification scripts, and evaluation harnesses.
- **`deep-research-briefs/`** — conventions for a brief-only deliverable handed to an external deep-research provider (e.g. Gemini Deep Research): niche/practitioner-source branching, file caching convention, intake reconciliation. Use together with `deep-research-prompt`.

## Structure

Each skill is a directory with a `SKILL.md` (frontmatter: `name`, `description`) plus `references/`, `templates/`, `scripts/`, and `config/` as needed. Drop them into your agent's skills directory.

## Verification scripts

`deep-research-prompt/scripts/` includes standalone checkers used to validate research output:

```sh
scripts/verify-deep-research-output.sh <report.md>
scripts/validate-evidence-state.py <state-file>
scripts/evaluate-skill.sh   # full evaluation harness
```
