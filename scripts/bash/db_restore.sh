#!/usr/bin/env bash
set -euo pipefail
DSN="${DB_DSN:-sqlite:///./cc.db}"
IN="${1:?Usage: $0 <dump_file>}"
OW="${2:-}"
export PYTHONPATH="${PYTHONPATH:-backend}"
args=(restore --dsn "$DSN" --in "$IN")
[ "$OW" = "--overwrite" ] && args+=("--overwrite")
python -m tools.backup_restore "${args[@]}"
