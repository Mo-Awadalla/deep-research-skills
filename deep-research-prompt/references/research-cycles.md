# Research–audit–repair cycles

This is authoring guidance. Export its applicable rules inside the handoff; the recipient must not need this file.

## Count cycles, not conversations

Default to `n = 5` complete cycles unless the user chooses another positive integer. Each cycle contains three separate full provider calls: **research → independent audit → repair**. Five cycles therefore schedule **15 baseline calls**, plus independent re-audits after substantive repair and further repair/audit calls if necessary. A planned prompt, failed attempt, partial return, or ordinary proofreading pass is not a completed research call.

Complete all configured cycles even if an early cycle passes. Additional cycles may legitimately find no new evidence and make no change. Never invent a defect, new source, contribution, or edit to justify the run count. High usage is accepted within the user's available access; that does not authorize a purchase, subscription change, external message, or an invented provider capability.

Within each cycle:

1. **Research:** investigate the whole contract, retrieve and inspect evidence, produce a versioned candidate and evidence ledger, and identify uncertainty. Later research calls start from the current candidate but challenge its consequential conclusions.
2. **Audit:** use a fresh reviewer context. Receive the candidate, frozen contract, sources, and required user facts—not the author's private deliberation. Independently retrieve evidence where possible and test claim support, alternatives, methods, internal consistency, and every acceptance test. Report findings without editing the candidate.
3. **Repair:** independently investigate each actionable finding before accepting or rejecting it. Return a complete candidate, evidence delta, and finding-resolution register. A repair call still happens when there are no findings: challenge the candidate against the contract, perform fresh evidence checks when possible, and return `no_change` if warranted.
4. **Re-audit substantive repair:** a fresh reviewer must assess the exact repaired revision and its material changes against the whole contract. A later scheduled independent audit can satisfy this requirement if it reviews that exact revision; otherwise use an additional re-audit. Carry evidenced unresolved findings forward into subsequent configured cycles. After all configured cycles, continue targeted repair and independent review until acceptance passes, or until an evidence/capability blocker makes further authorized work unable to resolve the failure. A completed re-audit cannot be inferred from the author's claim that a correction is safe.

A cycle completes when its three full stages have actually returned their required artifacts. Acceptance need not pass in every cycle; unresolved findings carry forward. Report approval is a separate gate requiring independent acceptance of the latest substantive revision after all configured cycles complete. If repair makes no material change to the report, evidence, or acceptance criteria, preserve that immutable revision and establish the lack of substantive change in the delta; the earlier passing independent audit still applies, including to a final no-change repair. Fixing an audited failure always requires re-audit. Record failed and incomplete attempts separately from completed stages.

## Keep the research broad while varying the challenge

All cycles cover the entire contract. Emphases direct extra investigation; they do not divide the question into unreviewed sections.

| Cycle | Additional emphasis |
|---|---|
| 1 | Coverage: clarify terms, establish the evidence base, and identify missing decision inputs. |
| 2 | Alternatives: challenge the preferred answer, search different terminology and competing explanations, and test omitted options. |
| 3 | Source integrity: inspect exact support, inaccessible citations, dates, source dependence, and relevant practitioner leads. |
| 4 | Methods: recompute quantities, test assumptions, check boundaries, and examine implementation or practical feasibility. |
| 5 | Final challenge: attempt to overturn consequential conclusions, verify resolved findings, and test the whole deliverable. |

For fewer than five cycles, use the early emphases and make the last cycle include the final challenge. For more than five, assign remaining cycles to the highest-impact residual uncertainties and retain a final challenge in the last cycle. An emphasis is never a quota for new findings.

When feasible, begin the second cycle's research in a fresh context with the frozen question, constraints, and necessary user facts but without prior conclusions. Save its independently gathered evidence before revealing the earlier report for comparison. Label any necessary shared sources as shared inputs. If isolation is unavailable, record that limitation; do not describe the run as blind.

## Fresh work and independent evidence

Each call records what it actually retrieved or re-examined, the exact passages or data inspected, what changed, and what remained unresolved. For an offline contract, independently inspect the supplied source packet and name the inspected locators; do not fabricate web retrieval. Existing evidence may be reused with its provenance intact. “No material new evidence” is an acceptable result.

A fresh model context is independent review, not an independent evidence source. Reports that cite one underlying paper, dataset, press release, or repost chain share an evidentiary root. Agreement is not a vote that establishes truth. Resolve conflicts through claim applicability, source independence, methods, and evidence strength.

## Revision and finding discipline

- Give each candidate a stable revision ID and preserve the previous candidate. Record substantive changes and the evidence behind them.
- Keep one finding ID across repair attempts. Record its severity, affected claim or acceptance test, evidence, decision impact, disposition, and verification on the exact revision.
- Permitted resolutions are an evidenced correction, an evidenced rejection of the finding, or an unresolved limitation. A reviewer must recheck consequential corrections and contested dismissals.
- A changed recommendation, source support, quantity, scope, test, or interpretation is substantive. Pure formatting can preserve an audit only if the content and meaning are unchanged and the delta explicitly establishes that.
- Scope or acceptance changes require explicit authorization and a new contract version. Log the reason and rerun affected checks. Never weaken a test to turn a failure into a pass.

## Blockers and completion

An inaccessible source is not proof that its claim is false. Seek an authorized accessible original, independent corroboration, a narrower supported claim, or an explicit unknown. Continue work that does not depend on the missing evidence.

Declare `BLOCKED` when a mandatory unresolved finding cannot be repaired with available evidence/capabilities, a targeted repair has produced no relevant progress, and the remaining route needs unavailable input or access. Record attempts, the exact dependency, the affected decision, and what would unblock it. Stop dependent calls; do not spend the remaining cycles repeating an impossible retrieval or fabricate completion.

The final artifact is approved only when every acceptance test passes on the latest substantive revision, no material finding remains unresolved, and all configured cycles have completed. An early passing cycle is an intermediate result. Reaching `n` without acceptance is not success. A blocked artifact remains **unapproved**, accompanied by its failure report and completed-call count; useful supported findings may be explained without endorsing the blocked recommendation.

## One portable handoff packet

Preserve an immutable copy of the final handoff as the external governing contract for later report verification. A report cannot approve itself against weakened embedded criteria. Checking a handoff against its own contract copy establishes readiness only.

Produce one saved handoff file containing the mission, constraints, full evidence rules, acceptance tests, capability requirements, cycle schedule, stage-specific prompts, attachment mapping, and machine-readable contract. No required instruction may point to a local skill file, an unexplained section number, or an unavailable conversation.

The coordinator reuses that file for every call and supplies the stage's listed inputs. Launch actual separate provider jobs; one pasted prompt is not evidence that all calls occurred. Each dispatch names stage, cycle, unique run and actor/context IDs, contract version, and input revision. The recipient runs only that designated stage; a manual operator saves and supplies its results before the next dependent job. For each required attachment, record its name, purpose, version, access method, and whether the recipient actually opened it. A pathname in an exported document is not proof of access. Optional missing attachments may be omitted with their effect stated; missing mandatory evidence blocks only the dependent conclusion or stage. Never send private material to a provider without the user's authorization.

Record which calls actually ran, failed, or remain pending. A handoff is `NOT_RUN` until execution occurs; do not populate report evidence or passing audits with invented results. The coordinator's merging and deterministic checks are not additional full research calls. If it launches another full provider research/audit/repair call, record that call too.
