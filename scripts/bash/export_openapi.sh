#!/usr/bin/env bash
set -euo pipefail
OUT_DIR="${1:-docs}"
OUT_FILE="${2:-openapi.json}"
export EXPORT_OPENAPI_DIR="${OUT_DIR}"
export EXPORT_OPENAPI_FILE="${OUT_FILE}"
export PYTHONPATH="${PYTHONPATH:-backend}"
python -m tools.export_openapi >/dev/null
echo "OpenAPI ecrit dans ${OUT_DIR}/${OUT_FILE}"
