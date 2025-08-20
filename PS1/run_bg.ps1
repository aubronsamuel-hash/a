$ErrorActionPreference = "Stop"
if (-not (Test-Path ..venv\Scripts\python.exe)) {
    Write-Error "Environnement non initialise. Lancez PS1\setup.ps1" ; exit 1
}
Start-Process "..venv\Scripts\python.exe" -ArgumentList "-m uvicorn app.main:app --app-dir backend --host 0.0.0.0 --port 8001" `
    -NoNewWindow
Start-Sleep -Seconds 2
Write-Host "API demarree en arriere-plan sur http://localhost:8001" -ForegroundColor Green
