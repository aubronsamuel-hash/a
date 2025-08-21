# Matrice de repro standard (a ajuster selon workflows)
@"

job,local_cmd
backend-tests,"PYTHONPATH=backend pytest -q"
lint-python,"ruff check . && mypy --install-types --non-interactive backend"
docs-build,"pip install -r requirements-docs.txt && mkdocs build --clean"
release-dryrun,"powershell -File .\\scripts\\ps1\\release\\changelog.ps1"
scan-secrets,"gitleaks detect --no-banner --redact --config gitleaks.toml"
observability-tests,"PYTHONPATH=backend pytest -q backend/tests/test_metrics.py"
"@ | Set-Content -Encoding UTF8 .ci\repro_matrix.csv
Write-Host "OK: .ci\repro_matrix.csv" -ForegroundColor Green
