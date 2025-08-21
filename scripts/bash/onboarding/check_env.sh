#!/usr/bin/env bash
set -euo pipefail
MIN_PY="${1:-3.11}"
PYV=$(python - <<PY
import sys
print("%d.%d.%d"%sys.version_info[:3])
PY
) || PYV=""
ok=0
if [ -z "$PYV" ]; then echo "Python introuvable"; exit 2; fi
verlte() { [ "$1" = "$2" ] && return 0 || [  "$(printf "%s\n%s\n" "$1" "$2" | sort -V | head -n1)" = "$1" ]; }
if verlte "$MIN_PY" "$PYV"; then echo "Python $PYV OK"; ok=1; else echo "Python $PYV < $MIN_PY"; fi
[ $ok -eq 1 ] || exit 2
