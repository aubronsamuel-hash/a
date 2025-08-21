#!/usr/bin/env bash
set -euo pipefail
PATH_ARG="${1:-audit.jsonl}"
[ -f "$PATH_ARG" ] || touch "$PATH_ARG"
echo "Suivi du journal: $PATH_ARG (CTRL+C pour stopper)"
tail -n 100 -f "$PATH_ARG"
