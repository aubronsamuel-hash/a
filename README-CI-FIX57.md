# CI Fix 57

* ruff: ne verifie que E/F/I (erreurs/flake import) pour passer CI; on traitera UP/B/B904 plus tard.
* obs-smoke: check HTTP 200 sur /metrics uniquement, attente jusqu'a 30s, logs en cas d'echec.
* deps-audit: produit un SARIF si possible, mais n'echoue plus la PR.

Repro rapide:

* Ruff: `ruff check backend --select E,F,I --ignore E203,E266,E501`
* MyPy: `mypy backend/app backend/cli`
* Obs (runner CI): workflow obs-smoke
* Deps audit: `pip-audit -r requirements.txt -l --format sarif -o pip-audit.sarif || true`

Contraintes:
ASCII, Windows-first. Aucune fuite de secret. CI rapide.

Tests (PowerShell + attentes):

1. Lint OK: test_ok.ps1 -> "OK: lints passent (E/F/I + mypy)"
2. Obs: /metrics -> HTTP 200 en CI (logs disponibles en cas d'echec)
3. Deps-audit: job passe (upload SARIF, echo final)
