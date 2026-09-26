# Implementation overlay — authoring only

Do not export this file alone. Populate the research handoff template, merge the applicable material below into its mission, evidence rules, questions, artifacts, and acceptance criteria, then remove authoring instructions. The single exported file must contain the complete stage prompts, cycle controller, attachment map, and populated machine-readable contract. It must not refer the recipient back to this overlay or a local skill file.

## Mission and current-system inputs

Produce an executable specification for **[specific change]** so **[coding agent/team]** can achieve **[measurable outcome]** while preserving **[invariants]**.

Include observed source/configuration paths, relevant interfaces, data models, dependencies, runtime/deployment constraints, current behavior, and known failures. Label facts observed or user-provided and investigate discrepancies. Record the inspected revision or snapshot. A downstream implementation agent must check freshness before editing.

Package repository excerpts or accessible repository links as named initial attachments. A local path is a locator, not proof that the external recipient can access it. Keep sensitive context within authorized boundaries. If relevant code cannot be supplied, distinguish an evidence-backed recommendation from a repository-verified specification and identify missing decision inputs.

## Required questions

1. What observed behavior or constraint makes the change necessary, and what must remain invariant?
2. Which established alternatives meet the requirements, which is the justified default, and under what observable condition should it change?
3. What interfaces, data/error behavior, and compatibility rules must implementation satisfy?
4. What is the smallest meaningful evaluation that distinguishes improvement from regression?
5. What sequence, safeguards, rollout, and rollback make the change executable?

Add task-specific questions. Do not require invention, cross-domain transfer, or a fixed winner when the evidence supports a conventional design, conditional choice, or missing-input gate.

## Required artifacts

- Current-system map with provenance and inspected snapshot.
- Concrete schemas, signatures, and input/output/error examples where known; otherwise named decision gates with invariants, owners, and required evidence.
- Decision table: choice, justified default or unresolved gate, evidence, and measurable escape condition where an alternative is useful.
- Dependency compatibility table based on existing manifests/lockfiles; verify proposed changes against accessible official sources. Do not invent versions or equate newest with appropriate.
- Evaluation plan: baseline, fixtures/data, metric, acceptance threshold, reproducible command or test name, and failure interpretation. Separate measured, published, expected, and target performance.
- Dependency-ordered steps with affected components, prerequisites, action, completion assertion, risks, and rollback/containment where relevant. Include estimates only when useful and label them estimates.
- Failure-mode and operations review covering actual data, boundary, migration, dependency, latency/cost, privacy/security, observability, and rollback risks.
- Applicable rollout/migration plan and unresolved decisions with their effect on executability.

Do not force meaningless migration plans, alternate architectures, table counts, or public URL quotas. Every mandatory artifact needs a concrete acceptance test.

## Evidence and practical checks

Inspect code/configuration when available. For published performance, record environment and methodology; do not present it as a measurement of this system. Reproduce decision-driving computations when tools permit and preserve inputs, units, and commands. If tools/data are unavailable, supply the test protocol and label it unexecuted.

Audit decisive source/configuration claims, version compatibility, interface consistency, and whether proposed completion assertions test the desired behavior. Independently review substantive design changes on the exact revised specification.

## Acceptance criteria to merge

- **AT-01 — Coverage:** all implementation questions and applicable artifacts are answered; unavailable facts or unresolved gates prevent unsupported claims of executability.
- **AT-02 — Evidence:** current-system claims name observed or user-provided sources, proposed dependency changes have compatibility evidence, and performance labels distinguish measurements from expectations.
- **AT-03 — Coherence:** interfaces, schemas, examples, roadmap, tests, migration, and rollback agree; every step has a meaningful completion assertion.
- **AT-04 — Decision usefulness:** every consequential choice has a justified default or a named evidence-dependent gate, and the coding agent receives an executable dependency-ordered path.
- **AT-05 — Independent review:** all material findings are independently resolved on the latest substantive revision. Check cycle completion separately in the run manifest.

Carry these criterion IDs and definitions into the handoff prose and machine-readable acceptance fields. Set consequential-domain controls to the actual task; do not activate them solely because it is technical.
