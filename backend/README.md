# Coulisses Crew API (ETAPE 1)

Windows-first. Voir dossiers PS1/ pour scripts.

## Local (sans Docker)

* PS1/setup.ps1 : cree venv, installe deps
* PS1/run.ps1 : lance l API
* PS1/test.ps1 : tests unitaires + HTTP
* PS1/lint.ps1 : ruff + mypy

## Docker

* PS1/compose_up.ps1 / compose_down.ps1

## Endpoints

* GET /healthz
* POST /echo
