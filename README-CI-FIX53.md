# CI Fix Suite (ETAPE 53)

Jobs vises:

* cli-docker: build & run Dockerfile.cli -> prints OK
* lint-python: ruff/mypy config stabilisee
* k6-smoke: demarre API puis lance scripts/k6/smoke.js (seuils souples)
* obs-smoke: demarre API avec METRICS_ENABLED=1 puis verifie /metrics 200
* scan-secrets: gitleaks avec allowlist + excludes (docs/backups/venv, placeholders)
* deps-audit: pip-audit non-strict, exceptions via pip-audit.toml
* image-vuln: Trivy, fail uniquement CRITICAL, ignore-unfixed

Repro locale:

* PS: .\scripts\ps1\ci\repro_cli.ps1, repro_k6.ps1, repro_metrics.ps1, repro_gitleaks.ps1, repro_deps_audit.ps1, repro_image_vuln.ps1
* Bash: ./scripts/bash/ci/repro_cli.sh, repro_k6.sh

Sorties attendues:

* CLI: "coulisses-cli: OK..."
* /healthz 200, /metrics 200
* k6 OK; trivy: exit 0 si pas de CRITICAL

Contraintes:
Windows-first. ASCII. Aucun secret. Thresholds realistes pour smoke. CI rapide (<2min/job).

Tests (PowerShell + sorties attendues):

1. CLI Docker:
   .\scripts\ps1\ci\repro_cli.ps1

   # Attendu: "coulisses-cli: OK"
2. k6 smoke:
   .\scripts\ps1\ci\repro_k6.ps1

   # Attendu: checks passes
3. Metrics:
   .\scripts\ps1\ci\repro_metrics.ps1

   # Attendu: HTTP 200
4. Gitleaks:
   .\scripts\ps1\ci\repro_gitleaks.ps1

   # Attendu: exit 0 (sans fuite)
5. Deps audit:
   .\scripts\ps1\ci\repro_deps_audit.ps1

   # Attendu: exit 0
6. Image vuln:
   .\scripts\ps1\ci\repro_image_vuln.ps1

   # Attendu: exit 0 (aucune CRITICAL)
