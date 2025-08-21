#!/usr/bin/env bash
set -euo pipefail
PART="${1:?Usage: $0 <major|minor|patch> [--tag] [--docker IMAGE]}"
TAG=false
BUILD_DOCKER=false
IMAGE="ccapi"
shift || true
while [ $# -gt 0 ]; do
  case "$1" in
    --tag) TAG=true ;;
    --docker) BUILD_DOCKER=true; IMAGE="${2:?IMAGE}"; shift ;;
    *) echo "Arg inconnu: $1" >&2; exit 2 ;;
  esac
  shift
done

get_version() {
python - <<'PY'
import re,sys
with open("backend/app/version.py","r",encoding="utf-8") as f:
    txt=f.read()
m=re.search(r"version = ['"]([^'"]+)['"]",txt)
assert m, "Version introuvable"
print(m.group(1))
PY
}
set_version_files() {
python - "$1" <<'PY'
import re,sys,pathlib
new=sys.argv[1]
p=pathlib.Path("backend/app/version.py")
p.write_text(re.sub(r"version = ['\"][^'\"]+['\"]", f"version = '{new}'", p.read_text()), encoding="utf-8")
pp=pathlib.Path("backend/pyproject.toml")
pp.write_text(re.sub(r'(^version = ")([^\"]+)(")', r'\1'+new+r'\3', pp.read_text(), flags=re.M), encoding="utf-8")
PY
}
next_version() {
python - "$1" "$2" <<'PY'
import sys,re
v,part=sys.argv[1],sys.argv[2]
if not re.match(r'^\d+\.\d+\.\d+$',v): raise SystemExit("Version non SemVer: "+v)
maj,min,pat=map(int,v.split("."))
if part=="major": print(f"{maj+1}.0.0")
elif part=="minor": print(f"{maj}.{min+1}.0")
elif part=="patch": print(f"{maj}.{min}.{pat+1}")
else: raise SystemExit("part invalide")
PY
}
curr="$(get_version)"
next="$(next_version "$curr" "$PART")"
echo "Version actuelle: $curr -> nouvelle: $next"

set_version_files "$next"

# Update CHANGELOG
today="$(date +%F)"
if ! grep -q "^## \[Unreleased\]$" CHANGELOG.md 2>/dev/null; then
  printf "## [Unreleased]\n\n" | cat - CHANGELOG.md > CHANGELOG.md.new && mv CHANGELOG.md.new CHANGELOG.md
fi
tmp="$(mktemp)"; awk -v ver="$next" -v date="$today" '
BEGIN{done=0}
{ if(!done && $0 ~ /^## \[Unreleased\]$/){ print $0 RS RS "## [" ver "] - " date; done=1; next } }
{ print $0 }
' CHANGELOG.md > "$tmp" && mv "$tmp" CHANGELOG.md

git add backend/app/version.py backend/pyproject.toml CHANGELOG.md
git commit -m "chore(release): bump version to $next"

if $TAG; then
  git tag "v$next"
  echo "Tag cree: v$next"
fi

if $BUILD_DOCKER; then
  docker build -t "${IMAGE}:latest" -t "${IMAGE}:${next}" .
  echo "Images construites: ${IMAGE}:latest et :${next}"
fi
