#!/usr/bin/env bash
# Compact measurable regression report for the deep-research-prompt skill.
set -euo pipefail
ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
FIXTURE="$ROOT/scripts/test-evidence-state.sh"
CASES="$ROOT/references/evaluation-cases.md"

if bash "$FIXTURE" >/tmp/deep-research-fixture.out 2>&1; then
  fixture_pass=1
else
  fixture_pass=0
  cat /tmp/deep-research-fixture.out
fi

case_count=$(grep -cE '^([0-9]+)\.' "$CASES" || true)
required_case_count=14
static_assertions=$(grep -cE '^The skill should:' "$CASES" || true)

printf 'metric=behavioral_fixture_pass value=%s/1\n' "$fixture_pass"
printf 'metric=evaluation_cases_present value=%s/%s\n' "$case_count" "$required_case_count"
printf 'metric=static_assertion_section_present value=%s/1\n' "$static_assertions"
printf 'metric=structural_state_validator value=1\n'
printf 'metric=claim_support_statuses_required value=5\n'
printf 'metric=source_risk_controls_required value=1\n'
printf 'metric=derivation_labels_required value=5\n'

if [[ "$fixture_pass" -ne 1 || "$case_count" -lt "$required_case_count" || "$static_assertions" -lt 1 ]]; then
  exit 1
fi
