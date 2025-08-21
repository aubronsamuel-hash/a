#!/usr/bin/env bash
set -euo pipefail
OUT_DIR="${1:-keys/age}"; KEY_FILE="${2:-agekey.txt}"
mkdir -p "$OUT_DIR"
age-keygen -o "$OUT_DIR/$KEY_FILE" >/dev/null
PUB=$(grep "^# public key:" "$OUT_DIR/$KEY_FILE" | sed 's/^# public key: //')
echo "Private: $OUT_DIR/$KEY_FILE"
echo "Public:  $PUB"
