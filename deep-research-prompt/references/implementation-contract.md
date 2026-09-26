# Authoring an implementation research contract

Use when research must produce an actionable technical specification. Merge the implementation overlay into the full research handoff. Research execution does not authorize implementation, deployment, purchases, or external communications.

## Establish the current system

Inspect accessible code, manifests, lockfiles, schemas, runtime and test configuration. Record relevant paths, observed behavior, invariants, constraints, and failures. Separate user-provided descriptions from observations; surface conflicts. Package sufficient snapshots or excerpts for an external researcher, minimizing private information.

## Define required decisions

For material choices, require a supported recommendation, rationale, alternatives, and conditions that would change it. Ties, insufficient evidence, and “none feasible” are valid evidence reporting; they block a criterion demanding an implementation-ready choice until resolved or explicitly changed by the user.

Existing techniques and straightforward adoption are acceptable. Do not require invention or cross-domain analogies. New proposals need comparison with a real baseline, actual differences and assumptions, and a disconfirming test.

## Make interfaces concrete

Specify applicable input/output schemas, error behavior, compatibility, observability, and migration invariants. Include representative examples. When research must decide a schema, state the decision gate rather than inventing the interface in advance.

Inspect pinned dependencies first and verify proposed changes against authoritative source or release information. Distinguish installed and proposed versions. Record compatibility and migration constraints. Avoid stale model identifiers and unverified API parameters.

## Define reproducible evaluation

Before experiments, state workload/data, baseline, metric, failure criterion, and environment. Separate published, observed, calculated, expected, and target values. Provide commands only when their interfaces have been checked. Unrun tests are proposed tests; missing execution capability means a blocked experiment or explicitly requested protocol, never a fabricated result.

Sequence implementation recommendations by dependency. Each step names components, prerequisites, completion assertions, failure detection, and rollback or containment. Estimates remain labeled estimates. Include relevant boundaries, partial failures, migrations, dependency changes, resource use, privacy, and observability; avoid unrelated technology checklists.

## Apply the shared research cycles

Use the same configurable five complete cycles. Emphases can be current-system coverage, alternatives, dependency/source verification, benchmark and rollout feasibility, and final adversarial review. Each includes full research, independent audit, and evidence-backed repair. All scheduled cycles must complete, and the final independently reviewed revision must pass every acceptance requirement before recommending the specification for implementation. Earlier findings can carry forward into later cycles.

Subagents can investigate independent branches inside a phase. They do not count as additional completed provider phases, and summaries do not replace checking code, sources, or outputs. Missing repository access, unpublished measurements, or incompatible capabilities keep affected requirements blocked.

## Select deliverables

Choose artifacts needed for the change: current-system map, target interfaces, decision record, compatibility table, evaluation plan, failure analysis, roadmap, migration/rollback plan, and unresolved gates. Map requirements to acceptance IDs and audit evidence. Never enable machine checks the prose does not request.

For example, a routine library migration needs observed usages, compatibility evidence, a change sequence, meaningful regression checks, and rollback. It does not automatically need eight URLs, a novel architecture, or contribution records.
