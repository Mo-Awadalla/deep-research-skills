# Substantive Report Audit

Use this after deterministic structure/link checks when a research deliverable includes a plan, protocol, recommendation, forecast, budget, schedule, nutrition target, or other executable prescription.

## Why this exists

A report can satisfy section counts and contain real-looking citations while remaining unusable. Common failure modes include pseudo-citations, unsupported precision, contradictory prescriptions, and a phase map that does not reconcile with the executable tables.

## Audit sequence

### 1. Plain-language extraction

Before judging polish, restate the report as:

- what the reader is being told to do;
- when and how often;
- what inputs or targets apply;
- what triggers an adjustment;
- what the expected outcome is.

If the operational prescription cannot be summarized without guessing, the report is incomplete.

### 2. Citation integrity

Fail the report when it uses unresolved markers such as `[cite: 12]`, orphaned footnote numbers, named studies absent from the references, or bibliography entries that cannot be mapped to claims.

For 3–5 load-bearing claims, verify:

- source identity, date, and venue;
- study population and intervention;
- outcome actually measured;
- whether the source supports the exact claim;
- whether a mechanistic, acute, EMG, or surrogate outcome is being misrepresented as longitudinal evidence.

A valid URL is not proof of claim support.

### 3. Cross-section coherence

Build a small consistency matrix for every major prescription:

| Item | Narrative recommendation | Phase/timeline value | Executable table value | Final summary value | Consistent? |
|---|---|---|---|---|---|

Check especially:

- weekly volume versus session-level totals;
- stated effort/intensity versus programmed RIR or failure;
- maintenance versus deficit/surplus language;
- calendar dates versus week count;
- primary plan versus fallback plan;
- planned deloads versus adjustment rules;
- stated caps versus later peak values.

Any mismatch must be reconciled, not merely mentioned.

### 4. Arithmetic and unit reconciliation

Recompute all decision-driving arithmetic with tools:

- macros to calories;
- percentages and body-weight thresholds;
- weekly set totals, including the stated fractional-set convention;
- date ranges and week counts;
- estimated expenditure versus prescribed intake;
- daily versus weekly redistribution.

Flag values that are mathematically correct but semantically mislabeled—for example, calling an intake “maintenance” when it is below the report’s own expenditure estimate.

### 5. Operational completeness

For each phase, confirm that the executable plan explains exactly how to reach its prescribed values. A table saying volume rises from 10 to 20 sets fails if the daily program remains fixed and no set-addition/removal map exists.

Every adjustment rule needs:

- metric;
- measurement method;
- observation window;
- threshold;
- action;
- reassessment window;
- safeguard against reacting to ordinary noise.

### 6. Precision and feasibility

Challenge exact forecasts, biological targets, and thresholds. Require either direct individualized data or calibrated uncertainty. Reject unsupported promises of precise regional tissue gain, fat loss, risk reduction, or structural change.

Check whether requested measurements are realistically accessible. If a report requires ultrasound, laboratory imaging, proprietary software, or clinician-only testing, it must also provide a practical fallback.

### 7. Domain and safety calibration

Do not let cautious language substitute for evidence. For health, exercise, nutrition, legal, financial, or other consequential advice:

- distinguish general population evidence from evidence for the user’s condition;
- avoid diagnosing from self-report;
- avoid categorical safety claims for an exercise, product, or intervention;
- avoid calling any loaded movement “zero load,” “zero compression,” or inherently safe without support;
- provide symptom- or event-based escalation criteria without fearmongering;
- ensure substitutions solve the stated constraint rather than merely moving it elsewhere.

### 8. Final disposition

Use one of three outcomes:

- **PASS:** citations, arithmetic, internal consistency, and operational mapping hold.
- **PASS WITH REPAIRS:** core recommendation is defensible but named corrections are required before execution.
- **FAIL:** unsupported citations, contradictions, missing operational mapping, unsafe certainty, or fabricated precision undermine the deliverable.

When explaining a failed report to the user, lead with a plain-language summary of what it says, then separate useful core ideas from defects. Do not make the reader parse the report’s jargon to understand the verdict.
