# Documentation (MkDocs)

## Local

* Installer deps: `pip install -r requirements-docs.txt`
* Servir: `.\\scripts\\ps1\\docs\\serve.ps1` ou `./scripts/bash/docs/serve.sh`

## Build

* `.\\scripts\\ps1\\docs\\build.ps1`

## Deploiement

* CI `docs.yml` publie sur `gh-pages` a chaque push sur `main`.
* Manuel: `.\\scripts\\ps1\\docs\\gh_pages.ps1`

## ADRs

* Nouveau: `.\\scripts\\ps1\\docs\\new_adr.ps1 -Title "Choix Base de Donnees"`
