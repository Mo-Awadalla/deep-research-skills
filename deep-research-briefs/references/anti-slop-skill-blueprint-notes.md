# Skill and Plugin Blueprints

Use when the research will inform an agent skill or plugin. Apply the software-quality extension below only when the proposed skill actually diagnoses or changes code.

## Translate research into an implementation contract

Establish the target task, users, runtime, permitted actions, typical inputs and outputs, and evidence of the current failure. Inspect available artifacts and capabilities instead of assuming a specific host, model, tool, or permission system.

Require a proposed design that identifies:

- trigger and non-trigger cases, intended outcomes, and explicit scope boundaries;
- the smallest useful workflow and the decisions that should remain with the user;
- required capabilities, access prerequisites, and honest fallbacks when they are absent;
- concise main instructions with directly linked optional references;
- deterministic operations that merit reusable scripts, rather than scripts for instruction-following alone;
- artifact and state contracts, failure/recovery behavior, and verification appropriate to the task;
- representative evaluation cases, including negative cases, against a current or simpler baseline.

Separate evidence-backed requirements, design judgments, and unresolved hypotheses. Reusing established approaches can be the best result; novelty is not an acceptance gate. Evaluate cost, user burden, and whether added instructions improve outcomes.

**Example:** a research skill may need citation-support checks and explicit inaccessible-source handling. It does not automatically need refactoring modes, rollback manifests, or a code-quality score.

## Optional software-quality extension

Use this section for skills that diagnose, refactor, or repair software. Treat “slop” as a provisional description of avoidable comprehension, modification, testing, reliability, security, review, or future-change cost. AI authorship or disliked style is not proof of harm.

Consider separate modes only when they clarify authorization and behavior:

- **Diagnose:** read-only evidence gathering and ranked findings.
- **Refactor:** bounded changes that preserve the relevant behavior and contracts.
- **Repair:** explicitly scoped remediation, which may change behavior when that is the authorized objective.

Require an appropriate run record for mutations: baseline, scope, commands, changed files, verification outcomes, recoverable checkpoints where useful, and unresolved risks. A valid outcome may be diagnosis only or no edit. Do not demand an elaborate manifest when a smaller record provides equivalent auditability.

Distinguish style preference, maintainability risk, and behavior/security/contract risk. Rank findings by concrete impact and supporting evidence rather than a universal quality score.

## Controls to evaluate for code-changing skills

- Establish the baseline; distinguish existing failures from regressions.
- Use checks that can detect the relevant failure. Consider characterization, property, mutation, or contract testing when ordinary tests lack an adequate oracle.
- Keep changes coherent and reviewable; verify at meaningful boundaries. Avoid mixing unrelated formatting, dependencies, configuration, and behavior changes.
- Treat complexity, duplication, churn, and history as investigation signals, not verdicts. Preserve domain-justified repetition, abstraction, and comments.
- Require measured evidence for performance claims or changes that trade readability for speed.
- Treat generated tests as unproven until there is evidence they detect the intended failure independently of the implementation.
- Respect existing authorization. Escalate only when scope, permissions, unresolved behavior, or consequential risk requires a user decision; do not create blanket approval gates for routine authorized work.
- Include false positives, review burden, metric gaming, and justified no-change outcomes in evaluation.

## Evidence and acceptance

Practitioner reports can reveal oversized diffs, context mismatch, invented dependencies, weakened tests, swallowed errors, or maintenance pain. Test these claims against independent relevant evidence; they do not establish prevalence or causality by repetition.

Assess study methodology and limits, including task selection, sample, comparison baseline, vendor involvement, and external validity. Preserve conflicts among simplicity, reuse, abstraction, and domain requirements; resolve them conditionally.

Accept the blueprint when its requirements can be implemented and evaluated in the named runtime, its safeguards address demonstrated risks, and its complexity earns its cost against the baseline. Missing essential capability or evidence is a visible prerequisite, not an invented implementation detail.
