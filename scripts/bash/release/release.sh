#!/usr/bin/env bash
set -euo pipefail
lvl="${1:-patch}"
"$(dirname "$0")/bump.sh" "$lvl"
ver=$(cat VERSION)
"$(dirname "$0")/changelog.sh" "$ver"
git add VERSION CHANGELOG.md backend/app/__init__.py || true
git commit -m "chore(release): v$ver"
"$(dirname "$0")/tag.sh" "$ver"
[ "${2:-}" = "--push" ] && "$(dirname "$0")/push.sh" --tags
