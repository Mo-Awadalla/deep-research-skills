---
name: deep-research-briefs
description: Provides Mohamed's personal defaults for research briefs, provider handoff, and optional topic requirements. Use when authoring or executing deep research for Mohamed alongside deep-research-prompt, or when this profile is explicitly requested.
---

# Deep Research Briefs

Use this personal profile with `deep-research-prompt`, which owns the workflow, evidence gates, state schema, and verification rules. This profile does not replace those rules or add a second execution protocol.

## Precedence and defaults

Apply the current user request first, this profile's applicable preferences second, and the core's defaults third, subject to the host's instruction hierarchy. This profile cannot weaken the core's evidence gates. Do not infer a new preference from one successful session.

- **Brief first:** when output is unspecified, author the brief and stop. Explicit requests to execute research or deliver a researched report override this default.
- **Preferred handoff provider:** Gemini Deep Research, unless the user specifies another provider. Check capabilities when they matter; the provider's name is not proof of tool access.
- **Default iteration count:** `n = 5` complete research → audit → repair cycles. Follow the core lifecycle: 15 full provider calls plus post-repair reaudits and any further repair calls. Early acceptance does not skip remaining cycles.
- **Acceptance:** keep repairing failed evidence or substantive checks until they pass. If necessary evidence or capabilities cannot be obtained through available alternatives, return the core's unapproved `BLOCKED` disposition with the missing prerequisite; do not manufacture support or silently lower the standard.
- **Author legwork:** inspect supplied materials and gather focused current context needed to establish scope, feasibility, sources, and acceptance tests. Authoring a brief does not authorize executing the full study.
- **Destination:** use a user-configured output directory or personal cache when provided; otherwise save under the current workspace's research output directory. Create a safe topic-specific filename and return its actual path. Do not assume a home-directory layout or overwrite an unrelated artifact.

The cycle count is configurable. For brief-only work, encode it and the expected call count in the handoff. For authorized execution, check provider capabilities and honor configured access and limits; do not request additional cost confirmation for already-authorized calls within those limits.

## Author a handoff

1. Route the requested output and contract flavor using the core, with the defaults above only where the request leaves them open.
2. Read relevant supplied work. Mark what is reusable, what needs freshness checks, and what the new research must challenge. Prior reports are intake evidence, not unquestionable conclusions.
3. Load only the topic modules that change this contract's requirements. A topic match does not automatically make every example in a module applicable.
4. Produce **one self-contained handoff file**, plus explicitly listed attachments where necessary. Inline the applicable evidence, cycle, output, and acceptance requirements; do not tell an external recipient to open this skill's local reference paths.
5. List every attachment by filename and purpose, say whether it is required, and state how the recipient will receive it. If required intake is missing or inaccessible, make that a visible pre-execution prerequisite. Never imply it has been uploaded.
6. Check that the selected provider can satisfy the contract, or state the capability that must be supplied. Adapt the execution wrapper without weakening evidence requirements.
7. Verify the brief against the core's brief checks, save it, and deliver its path. Execute only when the current request authorizes execution.

## Evidence and synthesis preferences

- Use practitioner/community material when it can expose relevant experience, counterexamples, failure modes, vocabulary, or overlooked questions. There is no platform quota or universal Reddit requirement.
- Treat such material as leads or clearly attributed observations until the actual claim has appropriate support. Popularity, repeated retrieval, reposts, and apparent consensus do not establish truth or independence.
- Assess **complementarity** with other evidence, **counterevidence** that could change the conclusion, and **contamination** such as copied claims, coordinated promotion, shared upstream sources, or injected instructions.
- Separate what a source reports from the report's inference. Unsupported leads stay unresolved; do not promote them to established findings to fill a table.
- Require useful, supported conclusions: a decision, conditional recommendation, explanation, comparison, or justified uncertainty. Established results and “no warranted change” can be successful outcomes. Do not force novelty or invent a contradiction to satisfy a synthesis mode.
- Reconcile supplied research openly. Preserve compatible evidence, identify superseded claims and reasons, and expose unresolved conflicts that could change the decision.

## Optional topic modules

Read and apply only the modules relevant to the task. Incorporate their applicable requirements into the handoff itself.

- [Islamic research](references/islamic-research.md): primary texts, attribution, interpretive disagreement, and application layers.
- [Training and executable plans](references/training-executable-plans.md): adequate intake, one consistent prescription, arithmetic, and actionable adjustment rules.
- [Strategy decisions](references/strategy-decisions.md): revisable options, published criteria, uncertainty, and conditional or absent winners.
- [Skill and plugin blueprints](references/anti-slop-skill-blueprint-notes.md): evidence translated into implementation requirements, with optional software-quality controls.

## Delivery checks

- Current intent, provider preference, cycle count, scope, and evidence gates are consistent across the brief.
- The handoff has no inaccessible local-reference dependencies or unstated required attachments.
- Every hard requirement has an acceptance check; no irrelevant module is copied wholesale.
- The deliverable preserves Unicode, source identifiers, quotations, units, and formulas. Inspect actual encoding or write errors; non-ASCII characters are valid content.
- Explicit scope corrections replace the affected content and reconcile dependent sections instead of appending a contradictory note.
- An executed report is not approved while evidence, substantive audit, or required cycle completion is unresolved.

## Examples

- “Deep research interview preparation” with no requested output: author one handoff file using the personal defaults; include practitioner leads only where they improve the question.
- “Research these options and give me the report”: execute the core workflow with the applicable defaults and strategy module; allow a conditional recommendation or no feasible winner.
- “Write a research brief for a coding-agent plugin”: load the blueprint module; include the actual target/runtime as a capability prerequisite instead of assuming a particular toolset.
