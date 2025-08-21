#!/usr/bin/env bash
set -euo pipefail
OUT="${1:-reports/pip-audit.sarif}"
mkdir -p "$(dirname "$OUT")"
python -m pip install --upgrade pip >/dev/null
python -m pip install pip-audit cyclonedx-bom >/dev/null
python -m pip install -e backend[dev] >/dev/null
if [ -f backend/requirements.txt ]; then
    pip-audit -r backend/requirements.txt >/dev/null || true
fi
pip-audit -f sarif -o "$OUT"
echo "pip-audit OK -> $OUT"
