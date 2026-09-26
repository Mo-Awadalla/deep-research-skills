#!/usr/bin/env bash
# Behavioral smoke tests for evidence-state, support, UGC, contradiction, and derivation enforcement.
set -euo pipefail
ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
VERIFIER="$ROOT/scripts/verify-deep-research-output.sh"
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

cat > "$TMP/contract.md" <<'EOF'
```yaml
acceptance:
  min_external_urls: 1
  min_h2_sections: 0
  min_tables: 0
  min_candidates: 0
  forbidden_placeholders: true
  require_references_heading: false
  forbid_pseudo_citations: true
  require_consistency_matrix: false
  require_verification_disposition: true
  require_evidence_state: true
  require_claim_audit: true
  require_derivation_labels: true
  consequential_domain: false
```
EOF

cat > "$TMP/good.md" <<'EOF'
# Research report

Disposition: PASS

research_state:
  claims:
    - id: C01
      type: calculated
      evidence_ids: [E01, E02]
  evidence:
    - id: E01
      url: https://example.com
      independence_group: example-primary
      source_risk: low
      support: supports
    - id: E02
      url: https://example.com
      independence_group: example-secondary
      support: partially_supports
  coverage:
    load_bearing_claims: 1.0
  stopping:
    rationale: no material new evidence

## Findings

C01 is partially supported by E02 and supported by E01. The contradiction/reconciliation record shows no decision impact.

## Contradiction reconciliation

| Claim/question | Source A | Source B | Difference | Resolution | Decision impact |
|---|---|---|---|---|---|
| C01 | E01 | E02 | timeframe | use current source | none |

## Derivation audit

Result type: calculated. Inputs: 2 and 3. Formula: 2 + 3. Units: count. Assumptions: additive. Range: 5 ± 0. Support classification: supports.

[ E01 ](https://example.com)
EOF

if ! bash "$VERIFIER" "$TMP/good.md" "$TMP/contract.md" > "$TMP/good.out" 2>&1; then
  cat "$TMP/good.out"
  echo "FAIL: valid full evidence state rejected"
  exit 1
fi

grep -q 'Evidence state markers present' "$TMP/good.out"
grep -q 'Claim audit support classifications' "$TMP/good.out"
grep -q 'Contradiction/reconciliation record present' "$TMP/good.out"
grep -q 'Derivation/calibration labels' "$TMP/good.out"

cat > "$TMP/bad_state.md" <<'EOF'
# Research report
Disposition: PASS
## Findings
This report has a URL but no evidence registry.
EOF
if bash "$VERIFIER" "$TMP/bad_state.md" "$TMP/contract.md" > "$TMP/bad_state.out" 2>&1; then
  echo "FAIL: incomplete evidence state accepted"
  exit 1
fi
grep -q 'Evidence state incomplete' "$TMP/bad_state.out"

grep -q 'no stable claim/evidence IDs' "$TMP/bad_state.out"

cat > "$TMP/bad_support.md" <<'EOF'
# Research report
Disposition: PASS
research_state:
  claims: [C01]
  evidence: [E01]
  coverage: 1.0
  stopping: done
## Findings
C01 has evidence E01.
## Derivation
Result type: directly stated.
https://example.com
EOF
if bash "$VERIFIER" "$TMP/bad_support.md" "$TMP/contract.md" > "$TMP/bad_support.out" 2>&1; then
  echo "FAIL: missing support/contradiction audit accepted"
  exit 1
fi
grep -q 'citation-support classifications' "$TMP/bad_support.out"

grep -q 'contradiction/reconciliation record' "$TMP/bad_support.out"

cat > "$TMP/bad_ugc.md" <<'EOF'
# Research report
Disposition: PASS
research_state:
  claims: [C01]
  evidence:
    - id: E01
      source_class: community
      user_generated: true
  coverage: 1.0
  stopping: done
## Findings
C01 is supported by E01.
Support classification: supports. Contradiction table: none.
Result type: directly stated. https://example.com
EOF
if bash "$VERIFIER" "$TMP/bad_ugc.md" "$TMP/contract.md" > "$TMP/bad_ugc.out" 2>&1; then
  echo "FAIL: uncorroborated UGC accepted"
  exit 1
fi
grep -q 'independent corroboration' "$TMP/bad_ugc.out"

cat > "$TMP/bad_structural.md" <<'EOF'
# Research report
Disposition: PASS
research_state:
  claims:
    - id: C01
      evidence_ids: [E99]
    - id: C01
      evidence_ids: [E01]
  evidence:
    - id: E01
      url: https://example.com
      independence_group: one
      support: supports
  coverage: {load_bearing_claims: 1.0}
  stopping: {rationale: done}
## Findings
C01 is supported by E01. Support classification: supports. Contradiction reconciliation: none. Result type: directly stated. https://example.com
EOF
if bash "$VERIFIER" "$TMP/bad_structural.md" "$TMP/contract.md" > "$TMP/bad_structural.out" 2>&1; then
  echo "FAIL: malformed/dangling evidence state accepted"
  exit 1
fi
grep -q 'duplicate claim id' "$TMP/bad_structural.out"
grep -q 'unknown evidence' "$TMP/bad_structural.out"

echo "PASS: evidence-state, support, UGC, contradiction, derivation, and structural behavioral checks"
