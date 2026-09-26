<!-- AUTHOR ONLY: Fill from actual checks and remove this comment. Ready handoff does not mean completed research. -->
# Verification report

**Artifact / revision:** [exact artifact name/path and revision].

**Contract / version:** [contract name and version].

**Verified by / on:** [actual reviewer or checker and time].

**Artifact kind:** [handoff | report].

**Disposition:** [PASS | REPAIR_REQUIRED | BLOCKED].

**Meaning:** [Handoff PASS means structurally ready, research not run. Report PASS means all acceptance tests pass on the latest independently reviewed substantive revision and all configured cycles completed. REPAIR_REQUIRED means repairable acceptance defects remain. BLOCKED means unavailable evidence/input/capability prevents further repair and the artifact remains unapproved.]

## Acceptance and evidence

| Criterion | Actual check and inspected evidence | Result | Decision impact / action |
|---|---|---|---|
| [stable ID and requirement] | [method, source/locator or command, result] | [passed/failed/blocked] | [consequence or none] |

Separate deterministic structure checks from source support, consistency, and practical checks. A valid URL, complete table, or passing schema does not establish truth.

## Exact-revision independent review

| Revision | Author/repair actor | Independent reviewer/run | Material changes checked | Acceptance result |
|---|---|---|---|---|
| [revision] | [actor] | [actual actor/run or not performed] | [verified delta] | [actual result] |

Do not carry approval across a substantive edit. A no-change repair preserves the report, evidence, and criteria under the same immutable revision and records a substantive reason. The final substantive revision must have independent review.

## Cycle and call accounting

**Requested cycles:** [n]. **Completed cycles:** [actual]. **Completed full provider calls:** [actual]. **Failed/incomplete attempts:** [actual]. **Independent re-audits:** [actual].

| Cycle | Research | Independent audit | Repair | Additional repair/re-audit calls | Latest accepted revision | Complete? |
|---|---|---|---|---|---|---|
| [number] | [ID/status] | [ID/status] | [ID/status] | [actual IDs/statuses or none] | [revision or none] | [yes/no] |

For an unexecuted handoff, state zero completed cycles/calls and omit invented rows. Readiness never substitutes for execution. A scheduled call is not completed work.

## Findings and resolutions

| Finding | Severity / affected claim or test | Evidence and impact | Correction or evidenced rejection | Independently verified revision | Status |
|---|---|---|---|---|---|
| [ID] | [material/minor; claim/test] | [source/locator and consequence] | [actual action or unresolved] | [revision or not verified] | [open/resolved] |

Report no findings when none exist. Do not invent a defect or perform cosmetic repair to satisfy a quota.

## Limitations and next action

Separate uncertainty from acceptance defects. For each blocked finding, name the missing dependency, attempted authorized alternatives, why targeted repair made no relevant progress, what would unblock it, and which conclusion remains unapproved. Explain supported findings without endorsing an unsupported recommendation.

State the next action required by the disposition. Reaching the cycle count cannot turn an unresolved failure into a pass.
