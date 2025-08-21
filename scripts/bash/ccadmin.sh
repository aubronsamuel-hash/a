#!/usr/bin/env bash
set -euo pipefail
cmd="${1:-}"; shift || true
if command -v ccadmin >/dev/null 2>&1; then
    ccadmin "$cmd" "$@"
else
    python -m app.cli "$cmd" "$@"
fi
