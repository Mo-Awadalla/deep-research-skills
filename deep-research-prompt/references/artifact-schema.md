# Artifact schema, version 1

This is the single schema for both exported packets and completed reports. It is implemented by `scripts/research_validation.py`. Python 3 and PyYAML are required; install PyYAML into the selected Python environment if absent. The tools read UTF-8, perform no network calls, and do not write caches or report files.

## What the commands establish

```bash
python3 scripts/validate-evidence-state.py REPORT.md
bash scripts/verify-deep-research-output.sh REPORT.md CONTRACT.md
bash scripts/evaluate-skill.sh
```

The first command checks **structure only**, printing `structure: VALID` and `approval: NOT_ASSESSED`. The second checks structure plus recorded completion and acceptance. Exit codes are `0` for PASS, `1` for REPAIR_REQUIRED, and `2` for BLOCKED, including invalid configuration. Omitting the governing contract runs structure checks but cannot approve a report: it returns BLOCKED. A packet containing both blocks can be passed as both arguments.

These tools check the consistency of supplied records. They cannot certify that calls occurred, sources are true, a reviewer was independent, a rationale is adequate, or an attachment is accessible. Those are auditable human/agent attestations. `research_complete: true` means the supplied records meet the report completion gate, not that execution or truth was independently observed by this script. Never present structural PASS as substantive proof.

`evaluate-skill.sh` performs direct metadata, local-link, and syntax checks, then validates the populated documentation handoff. It does not run unit tests, generate synthetic fixtures, or produce a research-quality score. `measure-regression.sh` remains a compatibility alias to these direct checks.

## Governing acceptance block

Put exactly one `acceptance` mapping in a fenced `yaml`/`yml` block. Plain YAML files rooted at `acceptance` are also accepted. Indentation follows YAML semantics; duplicate keys, unknown fields, wrong types, unsupported schema versions, and multiple acceptance blocks are errors. No configuration silently falls back after a typo.

```yaml
acceptance:
  schema_version: 1
  artifact_kind: handoff
  required_cycles: 5
  required_criteria: [AT01, AT02]
  consequential: false
  require_synthesis: false
```

`schema_version`, `artifact_kind` (`handoff` or `report`), and the nonempty, unique `required_criteria` list are required. `required_cycles` defaults to **5**; it counts full research → audit → repair cycles, so the baseline is **15 calls**. Additional repairs and re-audits are extra. `consequential` and `require_synthesis` default to false. Define each criterion's binary test in the surrounding contract prose and freeze the contract before execution.

A handoff contract may govern a later report without changing these criteria or the cycle count. A report under a handoff contract receives **all report gates**, never just packet-readiness checks. A report contract cannot be satisfied by returning a handoff.

## Research state block

Put exactly one `research_state` mapping in its own fenced YAML block. Its required fields are:

| Field | Type and meaning |
|---|---|
| `schema_version` | Integer `1`. |
| `artifact_kind` | `handoff` or `report`. |
| `revision` | Nonempty ID of an immutable report + evidence + criteria snapshot. |
| `claims`, `evidence`, `support_edges`, `leads` | Lists of the records below. |
| `coverage`, `findings`, `contributions` | Lists of the records below. |
| `stopping` | `{reason: string, remaining_gaps: [string], blocked_on: [string]}`. |
| `run_manifest` | Execution record defined below. |
| `handoff` | Required only for handoffs; prohibited in reports. |

All defined records reject unknown fields. Strings are nonempty unless explicitly allowed below; all listed fields are required unless marked optional. Empty registries are valid for an unexecuted packet. They do not establish research completion.

- **Claim:** `id` (`C1`, `C2`, …); `text`; `kind` (`fact`, `inference`, `forecast`, `recommendation`); `material` (boolean); `status` (`supported`, `unknown`); optional `single_source_exception` (substantive reason for depending on one uniquely authoritative source). Unknowns need no fake evidence. A material unknown prevents report approval; record genuine prerequisites under `stopping.blocked_on`.
- **Evidence:** `id` (`E1`, `E2`, …); `title`; `source_class` (`primary`, `secondary`, `practitioner`, `vendor`, `other`); `independence_group`; `access` (`retrieved`, `limited`, `unavailable`); `published_at` (ISO date or null when unknown); `accessed_at` (ISO date, interpreted as attempt date when inaccessible); exactly one of `url` (HTTP/S, no credentials) or `attachment_id` (portable supplied-source identifier). YAML dates or quoted `YYYY-MM-DD` strings are accepted. Titles, dates, classes, and source identity still need substantive checking.
- **Support edge:** `claim_id`; `evidence_id`; `relation` (`supports`, `partially_supports`, `contradicts`, `context_only`, `inaccessible`); `locator` (exact passage, section, excerpt, or line; may be empty only for inaccessible evidence); `checked_by`. Support is attached to a **claim-source pair**, not a source globally. Full support requires retrieved evidence.
- **Optional lead:** `id` (`L1`, …); `url`; `description`; `status` (`unverified`, `investigated`). Leads need no corroboration. They cannot be targeted by support edges. Promote an investigated lead to evidence only with the required metadata and checks.
- **Coverage:** `criterion` (governing criterion ID); `status` (`met`, `unresolved`); `claim_ids` (possibly empty where the criterion concerns execution or formatting).
- **Finding:** `id` (`F1`, …); `severity` (`material`, `minor`); `status` (`open`, `resolved`); `description`; `resolution` (may be empty while open); `resolved_revision` (null while open, otherwise an actual recorded revision). Material resolutions require an independent finding-specific audit of that exact revision; the final current audit must also account for every material finding.
- **Contribution:** `id` (`S1`, …); `claim_id`; `proposition`; nonempty `prior_work_evidence_ids`; `difference`; `falsification_test`; `status` (`proposed`, `derived`, `tested`, `replicated`). These are populated records, not a keyword test for “synthesis” or “doi.” Their intellectual quality remains an audit question. If no verifiable prior work can be identified, record the search limitation and resolve any required synthesis criterion honestly; do not invent a citation to satisfy this field.

All typed ID references must resolve. Claim/evidence IDs are also reserved tokens in report prose: a bare `C99` or `E99` must be registered. Fenced code examples are excluded from narrative reference checks. Leading-zero IDs are not used in schema version 1; both CLIs accept the same canonical `C1`/`E1` forms.

Identical normalized URLs cannot be assigned different independence groups. Normalization removes fragments/tracking parameters, normalizes host/default ports, and treats HTTP/HTTPS versions of the same path as one source. Matching attachment identifiers also cannot be relabeled as independent. Shared roots across different URLs still require a substantive provenance audit.

For consequential contracts, a supported material claim needs independent primary/secondary support or a documented uniquely authoritative single-source exception. Practitioner accounts may establish what the account reports; an exception cannot make practitioner-only evidence sufficient for a consequential generalization.

## Execution records

`run_manifest` contains exactly `requested_cycles` (positive integer), `cycles` (list), `additional_repairs` (list), `reaudits` (list), and `attestations` (list). Keep unperformed run lists empty rather than pre-filling completed records.

Every recorded cycle contains `number` (ordered, contiguous from 1), `research`, `audit`, and `repair`. Their record shapes are:

| Record | Required fields |
|---|---|
| Research | `id`, `status`, `revision`, `actor`, `summary`. |
| Audit | Research fields plus `independent` (boolean), `criteria`, `finding_ids`. |
| Repair | Research fields plus `input_revision`, `changed` (boolean), `no_change_reason`. |
| Additional repair | Repair fields plus `cycle` and `after_audit` (existing audit/re-audit ID). |
| Re-audit | Audit fields plus `after_repair` (existing baseline/additional repair ID). |

Run IDs are unique nonempty strings. Run `status` is `completed` or `blocked`; never mark a pending call completed. `summary` identifies what the full call did or what blocked it. `actor` identifies the role-separated execution context. Audit actors must differ from the research/repair context they review. `independent: true` is an attestation, not a tool-certified property.

Audit `criteria` is a list of `{id: criterion-ID, status: passed|failed|blocked}` with exactly the governing criterion IDs. Audit `finding_ids` names reviewed findings. All three baseline calls remain required for each cycle, even after an early PASS.

Research output, its audit revision, and its baseline repair input must match. A repair with `changed: true` must use a new revision ID; it cannot recycle a previously audited version. `no_change_reason` may be empty when changed. With `changed: false`, the input/output revision must match and a substantive reason must attest that the **report, evidence, and criteria are unchanged**. This still records a completed repair call. A previous independent audit of that same immutable snapshot remains usable, allowing 15 baseline calls with no edits.

Every changed repair version requires a completed independent audit. A later scheduled audit of that version can satisfy this check; otherwise record an extra re-audit. Additional repairs form an ordered revision chain within their cycle and identify the audit they follow. Circular repair/re-audit records are rejected. The final artifact revision must equal the final repair output and have all required criteria passed in an independent audit. A failed audit of an unchanged version is not erased by a later blanket PASS; investigate the discrepancy and record a corrected new version.

`attestations` records `{id, kind, method, by, statement, status}`. `kind` is `capability` or `external_handoff`; `method` is `manual`; `status` is `confirmed` or `unavailable`. At least one confirmed capability attestation is needed for report approval. External execution and attachment access must be reported honestly. An unavailable required prerequisite is BLOCKED, never a fabricated completed run.

## Packet readiness and final disposition

A handoff additionally contains `objective`, `questions` (nonempty list), `constraints` (list), `expected_artifacts` (nonempty list), `capabilities` (nonempty list), `acceptance_criteria` (governing criterion IDs), `continuation`, `controller`, `stage_prompts` (`research`, `audit`, `repair` strings), `attachments`, and `future_dependencies` (list of descriptions).

Each initial attachment has `id`, `status` (`supplied`, `embedded`, `missing`), and `description`. Missing initial attachments block readiness. Future stage outputs belong in `future_dependencies`; they are not fabricated initial attachments. Stage prompt/controller fields may point to explicitly named, fully embedded packet sections. The operator must check that those sections exist and contain usable instructions; string presence alone does not prove readiness in substance.

A handoff PASS is scoped to `handoff_packet_readiness`, with `research_complete: false` even if its metadata contains earlier run history. A report PASS is scoped to `recorded_report_acceptance`: every requested cycle is recorded complete, changed/current versions have independent audits, all required criteria pass, and no material findings or material unknowns remain. Incomplete work that can continue is REPAIR_REQUIRED. Unavailable prerequisites or invalid/missing governing configuration are BLOCKED. Residual nonmaterial gaps can remain transparently documented.

Use the populated [documentation handoff](../examples/documentation-handoff.md) to see a portable packet. It contains no invented completed research. The schema's fields are expanded in that packet so recipients do not need access to this repository.
