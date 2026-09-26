# Anti-Slop Skill Blueprint Notes

Use this reference when authoring a research brief that will become a coding-agent skill/plugin.

## Working synthesis to test

Coding slop is not a synonym for AI-authored code or ugly style. A useful provisional definition is code or workflow output that satisfies a narrow immediate requirement while imposing avoidable comprehension, modification, testing, reliability, security, review, or future-change cost. Treat it as a multi-dimensional risk profile, not a single score.

The strongest practitioner distinction is understood and verified work versus context-free, unverified, and unaccountable output. Common practitioner signals include oversized diffs, excessive indirection, architecture/context mismatch, invented APIs or dependencies, duplicate helpers, weakened or tautological tests, swallowed errors, and authors who cannot explain the change. These are practitioner observations, not prevalence or causal proof.

## Required translation into a plugin contract

Ask the research report to evaluate three modes:

- `diagnose`: read-only inventory and ranked findings;
- `refactor`: bounded, behavior-preserving work on an approved target;
- `repair-slop`: staged remediation of an existing area, allowed to stop when safety evidence is insufficient.

Require a machine-readable run manifest with baseline status, scope, commands, changed files, verification results, checkpoints/rollback, unresolved risks, and explicit `no edit` outcomes.

The report must separate:

1. style preference: normally non-blocking;
2. maintainability risk: requires concrete evidence and prioritization;
3. behavior/security/contract risk: hard gate with targeted verification and human escalation.

## Design rules worth testing

- Establish the baseline before editing; distinguish pre-existing failures from regressions.
- Use characterization, approval/golden-master, property, mutation, or contract tests when ordinary tests do not provide an adequate oracle.
- Make one coherent behavior-preserving transformation at a time and verify immediately.
- Keep diffs bounded; separate formatting, dependency, configuration, and behavior changes.
- Use static metrics, duplication, churn, hotspots, and history as signals, never verdicts.
- Require measured evidence before readability-reducing optimization or speculative abstraction.
- Treat generated tests as untrusted until they demonstrate independent failure detection.
- Stop and escalate on ambiguous behavior, public contracts, security, concurrency, migrations, permissions, secrets, billing, data deletion, or untestable changes.
- A successful result may be diagnosis only or no edit; do not force a cleanup to satisfy a metric.

## Evidence cautions

- Code smells are warning signs, not proof of defects.
- Duplication can be intentional; complexity can be essential; comments can preserve domain intent.
- AI quality studies often use limited tasks, open-source samples, vendor taxonomies, or preprints. Audit methodology and label evidence strength.
- Forum, Reddit, Hacker News, X, and maintainer discussions are valuable for vocabulary and failure discovery, but are not sufficient alone for causal, prevalence, safety, or quantitative claims.
- Preserve conflicts among YAGNI, DRY, abstraction, design patterns, and simple-design advice; resolve conditionally by domain, change likelihood, and verification cost.
