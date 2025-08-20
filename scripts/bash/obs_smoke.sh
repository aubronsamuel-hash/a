#!/usr/bin/env bash
set -euo pipefail
BASE=${BASE:-http://localhost:8001}

HDR=${REQUEST_ID_HEADER:-X-Request-ID}
RID=$(python - <<'PY'
import uuid;print(uuid.uuid4())
PY
)
code=$(curl -s -o /dev/null -w "%{http_code}" -H "$HDR: $RID" "$BASE/healthz")
echo "healthz=$code"
rid_resp=$(curl -s -D - -o /dev/null -H "$HDR: $RID" "$BASE/healthz" | awk -v H="$HDR" 'BEGIN{IGNORECASE=1} tolower($0) ~ tolower(H)":"{print $0}')
echo "hdr: $rid_resp"
curl -sf "$BASE/metrics" >/dev/null
curl -sf "$BASE/readyz" >/dev/null
echo "obs smoke OK"

