# CI Fix 55 (checks restants)

* cli-docker: Dockerfile autonome (plus de COPY backend/). Build & run -> OK.
* k6-smoke: fallback mock_api minimal si backend indisponible; boucles d'attente readiness.
* lint-python: restreint a backend/app et backend/cli pour eviter bruit hors scope.
* gitleaks: allowlist PR (workspace) + baseline maintenue pour push.

Repro rapide:

* CLI Docker: .\scripts\ps1\ci\repro_cli_docker.ps1
* k6 local (fallback auto): .\scripts\ps1\ci\repro_k6_local.ps1
* Lint: ruff check backend ; mypy backend/app backend/cli
* Gitleaks PR-like: gitleaks detect --no-git --additional-config .gitleaks.allowlist.toml --config gitleaks.toml

Contraintes:
Windows-first. ASCII. Aucun secret en dur. Jobs rapides.

Tests (PowerShell):

1. Lint: ruff check backend ; mypy backend/app backend/cli -> OK
2. CLI: docker build/run -> imprime "coulisses-cli: OK"
3. k6: repro_k6_local.ps1 -> OK (fallback si besoin)
4. Gitleaks (PR-like): exit 0 si workspace propre avec allowlist
