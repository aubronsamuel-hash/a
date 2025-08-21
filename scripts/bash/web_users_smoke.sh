#!/usr/bin/env bash
set -euo pipefail
BASE=${BASE:-http://localhost:8001}

etag=$(curl -sD - -o /dev/null -H "Authorization: Bearer $(curl -s -X POST -H 'Content-Type: application/json' -d '{"username":"admin","password":"admin123"}' $BASE/auth/token | jq -r .access_token)" "$BASE/users?page=1&page_size=10&order=username_asc" | awk 'BEGIN{IGNORECASE=1}/^ETag:/{gsub("\r","");print $2}')
test -n "$etag"
code=$(curl -s -o /dev/null -w "%{http_code}" -H "Authorization: Bearer $(curl -s -X POST -H 'Content-Type: application/json' -d '{"username":"admin","password":"admin123"}' $BASE/auth/token | jq -r .access_token)" -H "If-None-Match: $etag" "$BASE/users?page=1&page_size=10&order=username_asc")
test "$code" = "304" && echo "Front smoke ETag OK"
