#!/usr/bin/env bash
set -euo pipefail
URL="${1:-http://localhost/app.js}"
echo "Test headers for $URL"
curl --compressed -s -D - -o /dev/null "$URL" | grep -Ei "Cache-Control|ETag|Content-Encoding"
