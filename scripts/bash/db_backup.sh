#!/usr/bin/env bash
set -euo pipefail
DSN="${DB_DSN:-sqlite:///./cc.db}"
OUT="${1:?Usage: $0 <out_file>}"
export PYTHONPATH="${PYTHONPATH:-backend}"
python -m tools.backup_restore backup --dsn "$DSN" --out "$OUT"
