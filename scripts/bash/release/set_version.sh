#!/usr/bin/env bash
set -euo pipefail
ver="$1"
if ! [[ "$ver" =~ ^(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)(-[0-9A-Za-z.-]+)?(\+[0-9A-Za-z.-]+)?$ ]]; then
  echo "Version semver invalide: $ver"; exit 2; fi
echo "$ver" > VERSION
if [ -f backend/app/__init__.py ]; then
python - "$ver" <<'PY'
from pathlib import Path
import sys
ver = sys.argv[1]
p=Path('backend/app/__init__.py')
s=p.read_text(encoding='utf-8')
s=s.replace('version = "0.0.0-dev"', f'version = "{ver}"')
p.write_text(s, encoding='utf-8')
PY
fi

echo "OK: VERSION=$ver"
