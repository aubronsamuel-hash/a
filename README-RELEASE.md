# Release management

* Source de verite de la version: VERSION
* Exposee par backend/app/__init__.py (version)
* Changelog genere depuis les commits depuis le dernier tag
* Tags: vX.Y.Z

Flux Windows (exemples):

* Bump patch + changelog + tag (sans push):
  .\scripts\ps1\release\release.ps1 -Level patch
* Meme chose avec push tags:
  .\scripts\ps1\release\release.ps1 -Level minor -PushTags
* Changelog seul:
  .\scripts\ps1\release\changelog.ps1 -Version 0.2.0
* Tag seulement:
  .\scripts\ps1\release\tag.ps1 -Version 0.2.0

Flux Bash:

* ./scripts/bash/release/release.sh patch --push

CI:

* La release GitHub est creee a chaque push d un tag vX.Y.Z. Le corps prend CHANGELOG.md complet.
