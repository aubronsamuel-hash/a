$ErrorActionPreference = "Stop"
if (-not (Test-Path ..venv\Scripts\pytest.exe)) {
    Write-Error "Tests non disponibles. Lancez PS1\setup.ps1" ; exit 1
}
Write-Host "== Lints ==" -ForegroundColor Cyan
..venv\Scripts\python.exe -m ruff check backend
..venv\Scripts\python.exe -m mypy backend
Write-Host "== Unit tests ==" -ForegroundColor Cyan
..venv\Scripts\pytest.exe -q --cov=backend --cov-report=term-missing
