# CI Fix 54 (vague 1)

* gitleaks: PR -> `--no-git` (workspace seulement). Push main -> baseline `.gitleaks.baseline.json`.
* k6-smoke: on utilise `grafana/k6-action` (plus de apt-get).
* cli-docker: setup buildx avant build.
* lint-python: aligne avec pyproject.

Repro:

* Gitleaks baseline: `.\scripts\ps1\ci\gitleaks_make_baseline.ps1`
* k6 local: `.\scripts\ps1\ci\repro_k6_local.ps1`
* CLI Docker: `.\scripts\ps1\ci\repro_cli_docker.ps1`

Tests (PowerShell):

1. Gitleaks (PR-like): `gitleaks detect --no-banner --redact --no-git --config gitleaks.toml` -> doit passer si workspace propre
2. k6: `.\scripts\ps1\ci\repro_k6_local.ps1` -> check OK
3. Docker CLI: `.\scripts\ps1\ci\repro_cli_docker.ps1` -> affiche "coulisses-cli: OK"
