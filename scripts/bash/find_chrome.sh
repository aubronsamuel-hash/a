#!/usr/bin/env bash
set -euo pipefail

# Echo le chemin d'un Chrome/Chromium si present, sinon rien.

for c in "google-chrome" "google-chrome-stable" "chromium-browser" "chromium" "chrome"; do
  if command -v "$c" >/dev/null 2>&1; then
    command -v "$c"
    exit 0
  fi
done

# Chemins communs
for p in "/usr/bin/chromium" "/usr/bin/chromium-browser" "/usr/bin/google-chrome" "/snap/bin/chromium"; do
  [ -x "$p" ] && echo "$p" && exit 0
done

exit 1
