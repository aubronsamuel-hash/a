#!/usr/bin/env bash
set -euo pipefail
ver="${1:-$(cat VERSION)}"; today=$(date +%F)
last=$(git describe --tags --abbrev=0 2>/dev/null || true)
if [ -z "$last" ]; then range=""; else range="$last..HEAD"; fi
log=$(git log $range --pretty=format:"%s|||%h" --no-merges)
declare -A groups; keys=(feat fix perf refactor docs test ci chore)
for k in "${keys[@]}"; do groups[$k]=""; done
while IFS= read -r line; do
  [ -z "$line" ] && continue
  msg=${line%|||*}; sha=${line##*|||}
  key=$(echo "$msg" | sed -E 's/^([a-zA-Z]+).*/\1/' | tr '[:upper:]' '[:lower:]')
  [[ -z "${groups[$key]+_}" ]] && key=chore
  groups[$key]+="- $msg ($sha)\n"
done <<< "$log"
{
  [ -f CHANGELOG.md ] || echo "# Changelog"
  echo
  echo "## [$ver] - $today"
  for k in "${keys[@]}"; do
    val=${groups[$k]}
    [ -n "$val" ] && { echo "### $k"; printf "%b" "$val"; }
  done
} >> CHANGELOG.md
echo "OK: CHANGELOG mis a jour pour $ver"
