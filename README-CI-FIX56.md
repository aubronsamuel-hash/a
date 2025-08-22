# CI Fix 56 (vague 3)

* k6-smoke: boucle readiness 30s, fallback mock_api, logs API exposes en cas d'echec.
* obs-smoke: deps metrics explicites, check contenu (# HELP/http_), readiness 30s.
* lint-python: versions pinnees = local; scope backend seulement.
* deps-audit: prod-only (requirements.txt), SARIF et non-bloquant; alerte mais PR ne bloque plus.

Repro rapide:

* Obs local: .\scripts\ps1\ci\repro_obs_local.ps1
* k6 local (si Docker present): .\scripts\ps1\ci\repro_k6_local.ps1
* Lint: ruff check backend ; mypy backend/app backend/cli
* Deps audit: pip-audit -r requirements.txt -l --progress-spinner=off --strict=false

Contraintes:
Windows-first. ASCII. Aucun secret. CI rapide.

Tests (PowerShell + sorties attendues):

1. Lint: OK (meme versions que local)
2. Obs: /metrics -> HTTP 200 et contient des lignes # HELP
3. k6: boucle readiness garantit healthz 200 avant run
4. Deps-audit: job passe (upload SARIF) meme si vulns non-critiques; vraies corrections a planifier ensuite
