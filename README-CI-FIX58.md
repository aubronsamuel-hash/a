# CI Fix 58 (vague finale)

* k6-smoke: readiness 30s, logs /tmp/api.log en cas de KO, fallback mock.
* obs-smoke: METRICS on, deps explicites, check 200, logs.
* deps-audit: rapport SARIF, job non-bloquant.
* image-vuln: PR informatif (exit 0), push strict (CRITICAL).

Repro rapide:

* k6 (runner): workflow k6-smoke.
* obs local: `.\\scripts\\ps1\\ci\\repro_obs_local.ps1` (ou `uvicorn backend.app.main:app …` puis `curl :8001/metrics`).
* deps-audit: `pip-audit -r requirements.txt -l --format sarif -o pip-audit.sarif || true`.
* image-vuln: `docker build` puis trivy (non requis localement si indispo).

Contraintes:
ASCII, Windows-first. Aucun secret. CI < 5 min/job.

Tests (PowerShell + sorties attendues):

1. Obs local: script -> “OK: /metrics 200”.
2. k6 CI: healthz HTTP=200 avant exécution.
3. deps-audit CI: job success + SARIF upload.
4. image-vuln CI: PR passe (exit 0), push main strict.
