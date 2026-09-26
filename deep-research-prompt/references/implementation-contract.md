# Implementation Contract

Use this branch when research must become an executable technical specification for a coding agent.

## Current-system contract

Inspect the repository when accessible and record:

- relevant file paths, modules, function signatures, schemas, APIs, jobs, and data stores;
- runtime, dependency, deployment, and test configuration;
- current behavior and known failure modes;
- constraints that must remain invariant;
- conflicts between user-provided descriptions and observed code.

Do not ask the implementation agent to rediscover supplied context. Do require a short freshness check before editing.

## Target contract

Specify the target with concrete interfaces:

- Pydantic, TypeScript, JSON Schema, SQL DDL, API schemas, or function signatures;
- closed vocabularies/enums when the domain is closed;
- input/output examples and error behavior;
- data migrations and backward-compatibility requirements;
- observability and operational requirements.

If a schema cannot responsibly be fixed before research, define the invariants and the decision gate that will fix it.

## Decisions: default and escape hatch

For each consequential choice, name:

- **Default:** what the implementation should use.
- **Rationale:** evidence and constraints supporting it.
- **Escape hatch:** one alternative triggered by a measurable condition.

Do not request an option dump. Comparison is useful only when it resolves to a default or a decision gate.

Apply this pattern to storage, retrieval, chunking, models, reranking, planner architecture, thresholds, evaluation, deployment, and migration.

## Dependencies and versions

Version rules must be time-aware:

1. Inspect repository lockfiles/manifests first.
2. Verify proposed versions against official registries or release documentation on the research date.
3. Prefer compatibility with the existing stack over arbitrary newest versions.
4. Pin exact versions for reproducible builds when the ecosystem supports it.
5. Record why an upgrade is required and any migration risk.

Never invent a version or write `latest`/`TBD` in the final contract.

## Evaluation-first roadmap

The roadmap begins with the smallest evaluation harness that can distinguish improvement from regression. Each step includes:

- files/components affected;
- prerequisites;
- size (S/M/L) and engineer-day estimate as an estimate;
- implementation action;
- test/eval assertion that proves completion;
- rollback or containment path;
- known risks.

Sequence by dependency, not presentation order. Parallelize only independent work.

## Failure-mode audit

Create a table:

| Failure mode | Trigger | Detection | Mitigation | Verification |
|---|---|---|---|---|

Include data-quality failures, boundary inputs, stale caches/indexes, partial migrations, dependency/API changes, latency/cost regressions, security/privacy, observability blind spots, and rollback failure.

## Performance claims

Separate:

- **Measured:** reproduced in the stated environment.
- **Published:** reported by a cited external source.
- **Expected:** reasoned estimate not yet measured.
- **Target:** acceptance threshold chosen for the project.

Never label an unrun test `PASS`. Provide commands or test names for claims that can be reproduced.

## Required deliverables

A strong implementation contract normally includes:

1. current-system map;
2. target architecture and schemas;
3. decision record with defaults and escape hatches;
4. dependency/version table;
5. sequenced roadmap;
6. eval plan and acceptance thresholds;
7. failure-mode audit;
8. migration, rollout, and rollback plan;
9. unresolved decisions with owners or gates;
10. **synthesis artifact (SKILL.md §3b, S2 applies to most implementation work):** for design/invention elements, a prior-work check (closest existing approach, named with a verifiable source, plus the actual difference from the proposal) and a contribution record per derived design claim — Contribution / Prior work / Basis / Consequence / Test / Status, each with a falsifying observation.

## Acceptance-test examples

- `AT-01`: Every target interface has a concrete schema or a named decision gate.
- `AT-02`: Every architectural decision has one default and one measurable escape condition.
- `AT-03`: Every proposed dependency version was verified against an official source.
- `AT-04`: Every roadmap step has a test/eval assertion and rollback path.
- `AT-05`: No expected or target metric is described as measured.
- `AT-06`: Current-system claims name the observed file/config source or are labeled user-provided.
- `AT-07`: Derived design claims carry the contribution record with a falsification condition.
- `AT-08`: Prior-work check performed: closest existing approach named with a verifiable source and the actual difference stated, or the check recorded as a limitation.

Machine-readable contract markers may include:

```yaml
acceptance:
  min_external_urls: 8
  min_h2_sections: 7
  min_tables: 4
  min_candidates: 0
  forbidden_placeholders: true
  require_references_heading: true
  require_synthesis_artifact: true
  require_contribution_record: true
  require_prior_work_check: true
```
