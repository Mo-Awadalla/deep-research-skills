#!/usr/bin/env bash
# Compatibility alias for direct checks; no unit tests or research-quality metrics.
set -euo pipefail
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
exec bash "$SCRIPT_DIR/evaluate-skill.sh" "$@"
