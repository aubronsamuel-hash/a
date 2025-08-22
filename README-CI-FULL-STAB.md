# CI full stabilisation

* Determinisme: versions/pins minimales; readiness loops; logs de debug.
* PR non-bloquantes: deps-audit (SARIF), image-vuln (info).
* Observability/k6: fallback + attente 30s.
* Lints: ruff E/F/I + mypy --install-types (+ types-redis).

Tests (PowerShell):

1. Lint local: ruff check backend --select E,F,I ; mypy backend/app backend/cli --install-types
2. Deps audit local: .\scripts\ps1\ci\repro_deps_audit_local.ps1 -> fichier pip-audit.sarif cree
3. (CI) k6/obs: healthz & metrics HTTP=200; logs /tmp/api*.log si KO
4. CLI Docker: buildx + run OK sur runner

Arborescence:
Dockerfile.cli
scripts/
  k6/mock_api.py
  k6/smoke.js
  ps1/ci/repro_deps_audit_local.ps1
.github/workflows/
  cli-docker.yml
  k6-smoke.yml
  obs-smoke.yml
  lint-python.yml
  deps-audit.yml
  image-vuln.yml
README-CI-FULL-STAB.md
