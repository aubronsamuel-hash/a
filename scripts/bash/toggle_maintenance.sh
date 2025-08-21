#!/usr/bin/env bash
set -euo pipefail
STATE="${1:-on}"
[ -f .env ] || cp .env.example .env
if grep -q '^MAINTENANCE_MODE=' .env; then
  sed -E -i "s/^MAINTENANCE_MODE=.*/MAINTENANCE_MODE=$( [ "$STATE" = "on" ] && echo true || echo false)/" .env
else
  echo "MAINTENANCE_MODE=$( [ "$STATE" = "on" ] && echo true || echo false)" >> .env
fi
echo "MAINTENANCE_MODE -> $STATE"
