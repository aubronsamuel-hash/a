#!/usr/bin/env bash
set -euo pipefail
git push
[ "${1:-}" = "--tags" ] && git push --tags
