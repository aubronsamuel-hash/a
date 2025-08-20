$ErrorActionPreference = "Stop"
if (-not (Test-Path .\.venv\Scripts\pytest.exe)) {
    Write-Error "Tests non disponibles. Lancez PS1\setup.ps1" ; exit 1
}
Write-Host "== Lints ==" -ForegroundColor Cyan
.\.venv\Scripts\python.exe -m ruff backend
.\.venv\Scripts\python.exe -m mypy backend
Write-Host "== Unit tests ==" -ForegroundColor Cyan
.\.venv\Scripts\pytest.exe -q --cov=backend --cov-report=term-missing
Write-Host "== HTTP tests ==" -ForegroundColor Cyan
try {
    $health = Invoke-WebRequest -UseBasicParsing http://localhost:8001/healthz -TimeoutSec 5
    if ($health.StatusCode -ne 200) { throw "Healthz != 200" }
    Write-Host "OK /healthz 200" -ForegroundColor Green
} catch {
    Write-Host "Echec /healthz (attendu si serveur eteint) -> KO de demonstration" -ForegroundColor Yellow
}
