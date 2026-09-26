#!/usr/bin/env bash
# Offline structural and recorded-completion gate. No source truth certification.
# Usage: verify-deep-research-output.sh REPORT.md [CONTRACT.md]
# Exit: 0 PASS, 1 REPAIR_REQUIRED, 2 BLOCKED (including invalid configuration).
set -euo pipefail
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
exec env PYTHONDONTWRITEBYTECODE=1 python3 "$SCRIPT_DIR/verify-output.py" "$@"
