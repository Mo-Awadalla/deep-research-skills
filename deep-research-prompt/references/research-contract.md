# Research Contract

Use this branch for reports, investigations, literature reviews, due diligence, comparisons, and decision support.

## Required contract design

### Mission

State:

- the decision or understanding the research supports;
- the intended audience;
- the required deliverable;
- what a successful result enables the audience to do.

Central questions should be answerable. Avoid generic verbs such as “explore” unless discovery itself is the objective.

### Scope

Name inclusions and exclusions, timeframe, geography, population/market/system boundary, and 3–7 terms whose meaning changes the result. Record a research cutoff date for current topics.

An initial hypothesis is optional. If used, label it as a proposition to test and require active search for disconfirming evidence so it does not become an anchor.

### Coverage contract

Define required questions and artifacts, not a universal sequence. Examples:

- compare named alternatives across mandatory dimensions;
- produce at least N candidates with fields A–M;
- identify consensus, disputes, gaps, and decision implications;
- calculate specified metrics with units and formulas;
- include a recommendation only if the evidence supports one.

### Research policy

Choose an effort tier and planning mode. Specify authoritative databases and private corpora when relevant. Allow the agent to change its plan within scope when evidence warrants it.

For broad research, divide independent branches by question, source class, geography, timeframe, or competing hypothesis—not by arbitrary section count. Every branch needs a distinct objective and return contract.

### Stopping rule

Use an observable rule, for example:

> Stop when every core question is answered by the strongest reasonably available evidence; load-bearing claims have independent support or are labeled single-source; contradictions are reconciled or explicitly unresolved; required counts and fields are complete; and another search pass is producing mostly duplicate evidence.

A fixed source count may be a floor, never proof of adequacy.

### Synthesis mode (select one per contract; see SKILL.md §3b)

The contract must encode the mode in the objective, workflow, required outputs, and acceptance checks — not as an appended insights section.

- **S1 contradiction-driven (default):** require the report to, after establishing the evidence base, identify consequential contradictions, unexplained observations, or untested assumptions; check comparability before treating findings as contradictory; generate competing explanations and derive distinguishing predictions; for each candidate record supporting evidence, contrary evidence, added assumptions, the closest existing explanation, and a falsifying observation; select the strongest survivor and state what decision or research direction it changes.
- **S2 cross-domain invention:** for design questions — abstract the bottleneck, search structurally similar problems in other fields, generate materially different designs with the mapping and its limits specified, run a mandatory prior-work check (existing implementation under other terminology = established practice, not invention), and develop the strongest survivor into an implementable spec with baseline, expected advantage, failure conditions, and validation plan. Separate the generation pass from an adversarial review pass that hunts prior work and simpler-baseline wins.
- **S3 experiment-driven:** only when execution with real tools/data is in scope (never brief-only handoff); primary product is a reproducible analysis/prototype/derivation; define baseline, metric, and failure criterion before examining results; never describe an unexecuted test as a result. Without executable tools, the honest deliverable is an executable protocol.

All modes: every derived claim carries the contribution record (Contribution / Prior work / Basis / Consequence / Test / Status). Novelty and usefulness are reported as reader-grading definitions, not agent self-scores: novelty = stated distance from the named closest prior work; usefulness = the concrete decision/action the report changes (the Consequence field). The Prior-work entry names a verifiable source (URL/DOI/evidence ID) for the closest existing idea; claiming "none exists" requires a stated search and is labeled an inference.

### Output architecture

Specify what the reader needs, not a default academic essay. Common components:

- executive answer;
- scope and method;
- findings organized around the decision questions;
- comparison/evidence tables;
- contradictions and uncertainty;
- recommendations or decision options;
- limitations;
- references and optional evidence ledger.

Length follows information density. Do not request “the more the better.”

## Research-type adaptations

### Literature review

Require search databases, query date, inclusion/exclusion criteria, study-quality distinctions, review type, and a study table. Do not treat preprints, observational studies, and controlled trials as equivalent.

### Market or competitive landscape

Define market boundary, customer segment, geography, currency/base year, and comparison dimensions. Separate company-reported numbers from independently measured estimates. Reconcile incompatible market-size definitions.

### Current policy or regulation

Prioritize statutes, regulations, court opinions, regulator guidance, and official notices. Record effective dates and jurisdiction. Distinguish enacted rules from proposals and commentary.

### Historical investigation

Separate contemporary primary records, later scholarship, and retrospective claims. Surface provenance gaps and disputes; do not turn absence of evidence into evidence of absence.

### Technical due diligence

Prioritize official documentation, source code, changelogs, benchmarks with disclosed methodology, and reproducible tests. Record versions and environment. Separate vendor claims from observed performance.

### Source-poor topics

Do not manufacture certainty. Broaden terminology and adjacent literatures, report the search boundary, and explicitly state what could not be established.

### Individualized executable plans

Start with an intake gate: baseline/current practice, constraints, resources, availability, tolerances or risk signals, and the user’s actual objective. Missing consequential inputs require one bundled question or a clearly provisional output; do not manufacture personalization.

Use one canonical prescription as the source of truth. Require every phase map, fallback, summary, budget/volume ledger, and adjustment rule to reconcile to it. Every adjustment rule needs a metric, method, observation window, threshold, action, reassessment window, and noise safeguard.

For consequential domains, reject pseudo-citations, unsupported biological or behavioral precision, categorical safety claims, and inaccessible measurements without practical alternatives. Require a substantive disposition before execution.

## Acceptance-test examples

Write binary checks tied to the request:

- `AT-01`: Every central question has a direct answer or an `Unresolved` label with explanation.
- `AT-02`: At least 12 candidates are present and each contains all eight required fields.
- `AT-03`: Every material quantitative claim includes a nearby citation and unit/timeframe.
- `AT-04`: Each recommendation maps to at least one finding and one cited evidence item.
- `AT-05`: Contradictory estimates are displayed together and reconciled or left explicitly unresolved.
- `AT-06`: A derived contribution is present and falsifiable: reader can name the proposition, the closest prior work, and a refuting observation.
- `AT-07`: Prior-work check recorded: closest existing method/idea named and the actual difference stated, or the check recorded as a limitation.
- `AT-08`: Report contains the synthesis artifact required by the selected mode; a standalone "Original Insights" section does not satisfy it.

For machine checking, include markers in the contract:

```yaml
acceptance:
  min_external_urls: 12
  min_h2_sections: 6
  min_tables: 2
  min_candidates: 0
  forbidden_placeholders: true
  require_references_heading: true
  require_synthesis_artifact: true
  require_contribution_record: true
  require_prior_work_check: true
```
