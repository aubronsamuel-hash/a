#!/usr/bin/env bash
set -euo pipefail
BASE=${BASE:-http://localhost:8001}

# 1) healthz
code=$(curl -s -o /dev/null -w "%{http_code}" "$BASE/healthz" || true)
if [ "$code" != "200" ]; then
  echo "API indisponible ($code). Demarrez l API (ADMIN_AUTOSEED=true) avant le smoke." >&2
  exit 1
fi

# 2) recuperer un token admin - essayer 2 mdp connus (admin123, secretXYZ)
get_token() {
  local user="$1" pass="$2"
  curl -s -X POST -H 'Content-Type: application/json' \
    -d "{\"username\":\"${user}\",\"password\":\"${pass}\"}" \
    "$BASE/auth/token" | jq -r '.access_token // empty'
}

token="$(get_token admin admin123)"
if [ -z "${token:-}" ]; then
  token="$(get_token admin secretXYZ)"
fi
if [ -z "${token:-}" ]; then
  echo "401 Unauthorized: aucun admin present. Relancez l API avec ADMIN_AUTOSEED=true (ou seed manuel) puis reessayez." >&2
  exit 1
fi

# 3) premier appel -> recuperer ETag
etag=$(curl -sD - -o /dev/null -H "Authorization: Bearer $token" \
  "$BASE/users?page=1&page_size=10&order=username_asc" \
  | awk 'BEGIN{IGNORECASE=1}/^ETag:/{gsub("\r","");print $2}')
if [ -z "$etag" ]; then
  echo "Pas d ETag recu sur /users (HTTP OK requis). Abandon." >&2
  exit 1
fi
echo "ETag: $etag"

# 4) second appel avec If-None-Match -> 304 attendu
code=$(curl -s -o /dev/null -w "%{http_code}" \
  -H "Authorization: Bearer $token" \
  -H "If-None-Match: $etag" \
  "$BASE/users?page=1&page_size=10&order=username_asc")
test "$code" = "304" && echo "Front smoke ETag OK"
