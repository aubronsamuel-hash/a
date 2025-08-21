#!/usr/bin/env bash
set -euo pipefail
lvl="${1:-patch}"
cur=$(cat VERSION)
maj=${cur%%.*}; rest=${cur#*.}; min=${rest%%.*}; pat=${rest#*.}
case "$lvl" in
patch) pat=$((pat+1));;
minor) min=$((min+1)); pat=0;;
major) maj=$((maj+1)); min=0; pat=0;;
*) echo "niveau invalide"; exit 2;; esac
new="$maj.$min.$pat"
"$(dirname "$0")/set_version.sh" "$new"
