#!/usr/bin/env bash
set -euo pipefail
ver="${1:-$(cat VERSION)}"; tag="v$ver"
if ! git diff-index --quiet HEAD --; then echo "Arbre Git sale"; exit 3; fi
if git rev-parse -q --verify "refs/tags/$tag" >/dev/null; then echo "Tag existe deja"; exit 0; fi
git tag -a "$tag" -m "Release $tag"
echo "OK: tag $tag"
