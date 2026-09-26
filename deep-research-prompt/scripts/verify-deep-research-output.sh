#!/usr/bin/env bash
# Deterministic verifier for Markdown deep-research artifacts.
# Usage: verify-deep-research-output.sh REPORT.md [CONTRACT.md]
# Exit: 0 pass, 1 hard failure, 2 usage/configuration error.

set -uo pipefail

REPORT="${1:-}"
CONTRACT="${2:-}"
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
MAX_URLS="${MAX_URLS:-100}"
URL_TIMEOUT="${URL_TIMEOUT:-12}"

if [[ -z "$REPORT" || ! -f "$REPORT" ]]; then
  echo "Usage: $0 REPORT.md [CONTRACT.md]" >&2
  exit 2
fi
if [[ -n "$CONTRACT" && ! -f "$CONTRACT" ]]; then
  echo "Contract not found: $CONTRACT" >&2
  exit 2
fi

count_re() {
  local pattern="$1" file="$2"
  grep -ciE "$pattern" "$file" 2>/dev/null || true
}

contract_int() {
  local key="$1" default="$2"
  if [[ -z "$CONTRACT" ]]; then printf '%s' "$default"; return; fi
  local value
  value=$(grep -E "^[[:space:]]{2}${key}:[[:space:]]*[0-9]+" "$CONTRACT" 2>/dev/null \
    | tail -1 | sed -E 's/.*:[[:space:]]*([0-9]+).*/\1/')
  printf '%s' "${value:-$default}"
}

contract_bool() {
  local key="$1" default="$2"
  if [[ -z "$CONTRACT" ]]; then printf '%s' "$default"; return; fi
  local value
  value=$(grep -E "^[[:space:]]{2}${key}:[[:space:]]*(true|false)" "$CONTRACT" 2>/dev/null \
    | tail -1 | sed -E 's/.*:[[:space:]]*(true|false).*/\1/')
  printf '%s' "${value:-$default}"
}

MIN_URLS=$(contract_int min_external_urls 0)
MIN_H2=$(contract_int min_h2_sections 0)
MIN_TABLES=$(contract_int min_tables 0)
MIN_CANDIDATES=$(contract_int min_candidates 0)
FORBID_PLACEHOLDERS=$(contract_bool forbidden_placeholders true)
REQUIRE_REFERENCES=$(contract_bool require_references_heading false)
FORBID_PSEUDO_CITATIONS=$(contract_bool forbid_pseudo_citations true)
REQUIRE_CONSISTENCY_MATRIX=$(contract_bool require_consistency_matrix false)
REQUIRE_DISPOSITION=$(contract_bool require_verification_disposition false)
REQUIRE_EVIDENCE_STATE=$(contract_bool require_evidence_state false)
REQUIRE_CLAIM_AUDIT=$(contract_bool require_claim_audit false)
REQUIRE_DERIVATION_LABELS=$(contract_bool require_derivation_labels false)
CONSEQUENTIAL_DOMAIN=$(contract_bool consequential_domain false)
REQUIRE_SYNTHESIS_ARTIFACT=$(contract_bool require_synthesis_artifact false)
REQUIRE_CONTRIBUTION_RECORD=$(contract_bool require_contribution_record false)
REQUIRE_PRIOR_WORK_CHECK=$(contract_bool require_prior_work_check false)

FAIL=0
WARN=0
pass() { printf 'PASS  %s\n' "$1"; }
warn() { printf 'WARN  %s\n' "$1"; WARN=$((WARN+1)); }
fail() { printf 'FAIL  %s\n' "$1"; FAIL=$((FAIL+1)); }

echo "=== Deep Research Verification ==="
echo "Report:   $REPORT"
[[ -n "$CONTRACT" ]] && echo "Contract: $CONTRACT"
echo

# Structural integrity
PLACEHOLDERS=$(count_re '\[(specific subject|reader/decision-maker|central question|answerable question|boundaries|status|path|date|insert|todo|tbd)[^]]*\]' "$REPORT")
if [[ "$FORBID_PLACEHOLDERS" == true && "$PLACEHOLDERS" -gt 0 ]]; then
  fail "$PLACEHOLDERS unresolved template placeholders"
else
  pass "No forbidden template placeholders"
fi

H2_COUNT=$(count_re '^##[[:space:]]+' "$REPORT")
if [[ "$H2_COUNT" -lt "$MIN_H2" ]]; then fail "H2 sections $H2_COUNT < required $MIN_H2"; else pass "H2 sections: $H2_COUNT"; fi

# Count Markdown tables by separator rows, not every pipe row.
TABLE_COUNT=$(count_re '^\|[[:space:]]*:?-{3,}.*\|[[:space:]]*$' "$REPORT")
if [[ "$TABLE_COUNT" -lt "$MIN_TABLES" ]]; then fail "Tables $TABLE_COUNT < required $MIN_TABLES"; else pass "Tables: $TABLE_COUNT"; fi

CANDIDATE_COUNT=$(count_re '^#{2,6}[[:space:]]+(Candidate|Option|Alternative)[[:space:]]+([0-9]+|[^:]+:)' "$REPORT")
if [[ "$CANDIDATE_COUNT" -lt "$MIN_CANDIDATES" ]]; then fail "Candidates $CANDIDATE_COUNT < required $MIN_CANDIDATES"; else pass "Candidate sections: $CANDIDATE_COUNT"; fi

if [[ "$REQUIRE_REFERENCES" == true ]]; then
  REF_HEADINGS=$(count_re '^#{1,6}[[:space:]]+(References|Sources|Bibliography)([[:space:]]|$)' "$REPORT")
  if [[ "$REF_HEADINGS" -eq 0 ]]; then fail "Missing References/Sources/Bibliography heading"; else pass "References heading present"; fi
fi

# Reject citation-shaped placeholders that can masquerade as evidence.
PSEUDO_CITES=$(count_re '\[(cite|citation|source)[[:space:]]*:[^]]*\]|\[(citation needed|source needed|ref needed|unverified source)\]|\b(CITATION_NEEDED|SOURCE_NEEDED|REF_NEEDED)\b' "$REPORT")
if [[ "$FORBID_PSEUDO_CITATIONS" == true && "$PSEUDO_CITES" -gt 0 ]]; then
  fail "$PSEUDO_CITES unresolved pseudo-citation marker(s)"
else
  pass "No forbidden pseudo-citation markers"
fi

if [[ "$REQUIRE_EVIDENCE_STATE" == true ]]; then
  STATE_MARKERS=0
  for marker in 'research_state:' 'claims:' 'evidence:' 'coverage:' 'stopping:' 'independence_group'; do
    if grep -q "$marker" "$REPORT" 2>/dev/null; then STATE_MARKERS=$((STATE_MARKERS+1)); fi
  done
  if [[ "$STATE_MARKERS" -lt 6 ]]; then
    fail "Evidence state incomplete: $STATE_MARKERS/6 required markers present"
  else
    pass "Evidence state markers present"
  fi
fi

# Require explicit claim/evidence identifiers when an evidence state is required.
if [[ "$REQUIRE_EVIDENCE_STATE" == true ]]; then
  CLAIM_IDS=$(grep -oE '\bC[0-9]{2,}\b' "$REPORT" 2>/dev/null | sort -u | wc -l | tr -d ' ')
  EVIDENCE_IDS=$(grep -oE '\bE[0-9]{2,}\b' "$REPORT" 2>/dev/null | sort -u | wc -l | tr -d ' ')
  if [[ "$CLAIM_IDS" -eq 0 || "$EVIDENCE_IDS" -eq 0 ]]; then
    fail "Evidence state has no stable claim/evidence IDs"
  else
    pass "Stable claim IDs: $CLAIM_IDS; evidence IDs: $EVIDENCE_IDS"
    if python3 "$SCRIPT_DIR/validate-evidence-state.py" "$REPORT" > /tmp/deep-research-state-validation.out 2>&1; then
      pass "Structured evidence state is valid"
    else
      fail "Structured evidence state is invalid"
      while IFS= read -r validation_line; do printf '      %s\n' "$validation_line"; done < /tmp/deep-research-state-validation.out
    fi
  fi
fi
if grep -qiE 'user_generated:[[:space:]]*true|source_class:[[:space:]]*(community|practitioner)' "$REPORT" 2>/dev/null; then
  if ! grep -qiE 'independent_corroboration|corroborat(ed|ion)_by|independently supported' "$REPORT" 2>/dev/null; then
    fail "User-generated/community evidence lacks independent corroboration marker"
  else
    pass "User-generated/community evidence has corroboration marker"
  fi
fi
if [[ "$REQUIRE_CLAIM_AUDIT" == true ]]; then
  SUPPORT_MARKERS=$(grep -ciE 'supports|partially_supports|contradicts|irrelevant|inaccessible' "$REPORT" 2>/dev/null || true)
  if [[ "$SUPPORT_MARKERS" -eq 0 ]]; then
    fail "Claim audit has no citation-support classifications"
  else
    pass "Claim audit support classifications: $SUPPORT_MARKERS"
  fi
  if ! grep -qiE 'contradiction|reconciliation|decision impact' "$REPORT" 2>/dev/null; then
    fail "Claim audit has no contradiction/reconciliation record"
  else
    pass "Contradiction/reconciliation record present"
  fi
fi

if [[ "$REQUIRE_DERIVATION_LABELS" == true ]]; then
  DERIVATION_MARKERS=$(grep -ciE 'directly stated|calculated|inferred|forecast|unknown' "$REPORT" 2>/dev/null || true)
  if [[ "$DERIVATION_MARKERS" -eq 0 ]]; then
    fail "No derivation/calibration labels present"
  else
    pass "Derivation/calibration labels: $DERIVATION_MARKERS"
  fi
  if grep -qiE 'calculated|inferred|forecast' "$REPORT" 2>/dev/null && ! grep -qiE 'inputs|formula|units|assumptions|sensitivity|range' "$REPORT" 2>/dev/null; then
    fail "Derived result lacks inputs/formula/units/assumptions/range metadata"
  fi
fi
if [[ "$REQUIRE_CONSISTENCY_MATRIX" == true ]]; then
  CONSISTENCY=$(count_re '^#{1,6}[[:space:]]+.*(Consistency|Reconciliation)([[:space:]]|$)|^\|.*Narrative.*Phase.*(Executable|Session|Canonical).*\|' "$REPORT")
  if [[ "$CONSISTENCY" -eq 0 ]]; then fail "Missing required consistency/reconciliation matrix"; else pass "Consistency/reconciliation matrix present"; fi
fi

# Synthesis mandate checks (mirror SKILL.md §3b).
if [[ "$REQUIRE_SYNTHESIS_ARTIFACT" == true ]]; then
  SYNTH=$(count_re '^(#{1,6}[[:space:]]+|>|\*\*)?.*(synthesis artifact|derived contribution|selected hypothesis|competing explanation|design proposal|reproducible analysis|exec::verify|exec::replicate|exec::baseline|executable protocol)' "$REPORT")
  INSIGHT_ONLY=$(count_re '^#{1,6}[[:space:]]+(Original Insights|Novel Findings|Additional Insights)([[:space:]]|$)' "$REPORT")
  if [[ "$SYNTH" -eq 0 ]]; then
    fail "Synthesis mandate: no synthesis-artifact section or artifact content found"
  else
    pass "Synthesis artifact present"
  fi
  if [[ "$INSIGHT_ONLY" -gt 0 && "$SYNTH" -eq "$INSIGHT_ONLY" ]]; then
    fail "Report has only a tacked-on insights section; designated synthesis artifact missing"
  fi
fi

if [[ "$REQUIRE_CONTRIBUTION_RECORD" == true ]]; then
  FIELDS=0
  for f in 'Contribution:' 'Prior work:' 'Basis:' 'Consequence:' 'Test:' 'Status:'; do
    if grep -qiE "\*\*$f|^\s*$f" "$REPORT" 2>/dev/null; then FIELDS=$((FIELDS+1)); fi
  done
  if [[ "$FIELDS" -lt 6 ]]; then
    fail "Contribution record incomplete: $FIELDS/6 fields found (need Contribution/Prior work/Basis/Consequence/Test/Status)"
  else
    pass "Contribution record present (6/6 fields)"
  fi
  FALSIFIER=$(grep -ciE 'would (refute|falsify|disconfirm|count against)|falsif(y|ication|ies)|refuted by|disconfirmed by' "$REPORT" 2>/dev/null || true)
  if [[ "$FALSIFIER" -eq 0 ]]; then
    fail "No falsification condition stated for derived claims"
  else
    pass "Falsification condition present"
  fi
fi

if [[ "$REQUIRE_PRIOR_WORK_CHECK" == true ]]; then
  PWC=$(grep -ciE 'prior[- ]work check|closest existing (method|idea|approach|work)|most similar (prior|existing)|no directly comparable (method|idea|approach|work)' "$REPORT" 2>/dev/null || true)
  PW_SRC=$(grep -iE 'prior[- ]work check|closest existing (method|idea|approach|work)' "$REPORT" 2>/dev/null | grep -ciE 'https?://|\[E?[0-9]+\]|doi|arxiv' || true)
  if [[ "$PWC" -eq 0 ]]; then
    fail "Prior-work check absent: closest existing idea not named"
  elif [[ "$PW_SRC" -eq 0 ]]; then
    fail "Prior-work check present but has no verifiable source (URL/DOI/evidence ID)"
  else
    pass "Prior-work check present with verifiable source"
  fi
fi

if [[ "$REQUIRE_DISPOSITION" == true ]]; then
  DISPOSITION=$(count_re '^(\*\*)?(Verification[[:space:]]+)?Disposition(\*\*)?:[[:space:]]*(PASS|PASS WITH REPAIRS|FAIL)([[:space:]]|$)' "$REPORT")
  if [[ "$DISPOSITION" -eq 0 ]]; then fail "Missing explicit verification disposition"; else pass "Verification disposition present"; fi
fi

# High-risk certainty phrases are hard failures only when the contract marks a consequential domain.
if [[ "$CONSEQUENTIAL_DOMAIN" == true ]]; then
  UNSAFE_CERTAINTY=$(count_re '\b(zero (spinal |axial )?(compression|load)|inherently safe|inherently dangerous|guaranteed safe|risk[- ]free)\b' "$REPORT")
  if [[ "$UNSAFE_CERTAINTY" -gt 0 ]]; then fail "$UNSAFE_CERTAINTY categorical safety/load claim(s) in consequential report"; else pass "No categorical safety/load phrases"; fi
fi

# Opaque embeds and unsupported certainty
OPAQUE=$(count_re 'data:image/|base64,|!\[[^]]*(formula|equation|math)[^]]*\]\(' "$REPORT")
if [[ "$OPAQUE" -gt 0 ]]; then fail "$OPAQUE opaque/base64 or image-formula embeds"; else pass "No opaque formula embeds"; fi

UNVERIFIED=$(count_re '\[UNVERIFIED\]' "$REPORT")
if [[ "$UNVERIFIED" -gt 0 ]]; then warn "$UNVERIFIED explicitly unverified items remain"; else pass "No [UNVERIFIED] markers"; fi

# Extract both Markdown and bare HTTP URLs, normalize common trailing punctuation.
URL_FILE=$(mktemp)
trap 'rm -f "$URL_FILE"' EXIT
grep -oE 'https?://[^][()<>"[:space:]]+' "$REPORT" 2>/dev/null \
  | sed -E 's/[.,;:!]+$//' | sort -u | head -n "$MAX_URLS" > "$URL_FILE" || true
URL_COUNT=$(wc -l < "$URL_FILE" | tr -d ' ')
if [[ "$URL_COUNT" -lt "$MIN_URLS" ]]; then fail "External URLs $URL_COUNT < required $MIN_URLS"; else pass "External URLs: $URL_COUNT"; fi
if [[ "$URL_COUNT" -eq "$MAX_URLS" ]]; then warn "URL checks capped at MAX_URLS=$MAX_URLS"; fi

# GET is more reliable than HEAD for scholarly and bot-protected sites.
URL_FAILS=0
URL_SOFT=0
while IFS= read -r url; do
  [[ -z "$url" ]] && continue
  code=$(curl -L -sS -o /dev/null -w '%{http_code}' --max-time "$URL_TIMEOUT" \
    -A 'Mozilla/5.0 (research-verifier/2.0)' "$url" 2>/dev/null || printf '000')
  code=${code: -3}
  if [[ "$code" =~ ^(000|5[0-9][0-9])$ ]]; then
    printf '      hard URL failure [%s] %s\n' "$code" "$url"
    URL_FAILS=$((URL_FAILS+1))
  elif [[ "$code" =~ ^(401|403|405|429)$ ]]; then
    printf '      access-limited URL [%s] %s\n' "$code" "$url"
    URL_SOFT=$((URL_SOFT+1))
  elif [[ "$code" =~ ^4[0-9][0-9]$ ]]; then
    printf '      broken URL [%s] %s\n' "$code" "$url"
    URL_FAILS=$((URL_FAILS+1))
  fi
done < "$URL_FILE"

if [[ "$URL_COUNT" -gt 0 ]]; then
  HARD_RATE=$((URL_FAILS * 100 / URL_COUNT))
  if [[ "$HARD_RATE" -gt 20 ]]; then fail "Hard URL failure rate ${HARD_RATE}% > 20%";
  elif [[ "$URL_FAILS" -gt 0 ]]; then warn "$URL_FAILS hard URL failures (${HARD_RATE}%)";
  else pass "All fetchable URLs resolved without hard failure"; fi
  [[ "$URL_SOFT" -gt 0 ]] && warn "$URL_SOFT URLs require authentication or blocked automated access"
fi

# Heuristic: material numeric claims should usually have nearby citation markers.
NUMERIC_PATTERN='(^|[^[:alnum:]])[0-9]+([.,][0-9]+)?%|\$[0-9]|[0-9]+([.,][0-9]+)?[[:space:]]*(kg|lb|lbs|kcal|calories|g/day|g/kg|sets|weeks|hours|million|billion|trillion)'
NUMERIC_LINES=$(count_re "$NUMERIC_PATTERN" "$REPORT")
CITED_NUMERIC_LINES=$(grep -iE "$NUMERIC_PATTERN" "$REPORT" 2>/dev/null \
  | grep -ciE 'https?://|\[[^]]+\]\([^)]+\)|\[[0-9]+\]|\([A-Z][^)]*,[[:space:]]*[12][0-9]{3}' || true)
if [[ "$NUMERIC_LINES" -gt 0 && "$CITED_NUMERIC_LINES" -eq 0 ]]; then
  warn "$NUMERIC_LINES quantitative-claim lines found but none appear cited on-line"
else
  pass "Quantitative citation heuristic: $CITED_NUMERIC_LINES/$NUMERIC_LINES lines"
fi

echo
echo "Manual checks still required:"
echo "  - Spot-check 3–5 load-bearing citations for metadata and claim support."
echo "  - Recompute consequential calculations and inspect source independence."
echo "  - Confirm every natural-language acceptance test, contradiction, and limitation."
echo
echo "=== Summary: $FAIL failure(s), $WARN warning(s) ==="
[[ "$FAIL" -eq 0 ]] || exit 1
exit 0
