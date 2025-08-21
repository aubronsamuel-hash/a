#!/usr/bin/env bash
set -euo pipefail
VERSION="${1:-}"
DRYRUN="${DRYRUN:-0}"
if ! [[ "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "Usage: $0 X.Y.Z   (SemVer)" >&2
  exit 1
fi
ver_file="backend/app/version.py"
proj_file="backend/pyproject.toml"
[ -f "$ver_file" ] || { echo "$ver_file manquant"; exit 1; }
[ -f "$proj_file" ] || { echo "$proj_file manquant"; exit 1; }

# maj fichiers
sed -E -i 's/^version\s*=\s*".*"/version = "'$VERSION'"/' "$ver_file"
sed -E -i 's/^version\s*=\s*".*"/version = "'$VERSION'"/' "$proj_file"

# lints/tests
python -m ruff check backend
python -m mypy backend
pytest -q --cov=backend

# commit/tag/push
git add "$ver_file" "$proj_file"
commitMsg="chore(release): v$VERSION"
if [ "$DRYRUN" = "1" ]; then
  echo "[DRYRUN] git commit -m "$commitMsg""
  echo "[DRYRUN] git tag v$VERSION -a -m "release v$VERSION""
  echo "[DRYRUN] git push && git push --tags"
  exit 0
fi
git commit -m "$commitMsg"
git tag "v$VERSION" -a -m "release v$VERSION"
git push
git push --tags
echo "Release v$VERSION creee et poussee."
