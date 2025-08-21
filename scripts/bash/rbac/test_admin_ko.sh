#!/usr/bin/env bash
set -euo pipefail
BASE_URL="${1:-http://localhost:8000}"
SECRET="${2:-change_me}"
TOK=$("$(dirname "$0")/make_token.sh" u-user user "$SECRET")
curl -s -D - -o /dev/null -H "Authorization: Bearer ${TOK}" "${BASE_URL}/admin/ping"
