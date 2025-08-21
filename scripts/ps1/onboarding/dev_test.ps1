Write-Host "== Tests rapides backend ==" -ForegroundColor Cyan
if (Test-Path ".venv/Scripts/Activate.ps1") { . ".venv/Scripts/Activate.ps1" }
$env:PYTHONPATH = "backend"
pytest -q
if ($LASTEXITCODE -ne 0) { Write-Host "KO: tests echoues" -ForegroundColor Red; exit 1 }
Write-Host "OK: tests passes" -ForegroundColor Green
