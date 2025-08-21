#!/usr/bin/env bash
set -euo pipefail
STATE="${1:-on}"
[ -f .env ] || cp .env.example .env
if grep -q '^READ_ONLY_MODE=' .env; then
  sed -E -i "s/^READ_ONLY_MODE=.*/READ_ONLY_MODE=$( [ "$STATE" = "on" ] && echo true || echo false)/" .env
else
  echo "READ_ONLY_MODE=$( [ "$STATE" = "on" ] && echo true || echo false)" >> .env
fi
echo "READ_ONLY_MODE -> $STATE"
