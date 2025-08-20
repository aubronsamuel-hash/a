Param(
    [int]$Port = 8001
)
$ErrorActionPreference = "Stop"
$python = Join-Path $PSScriptRoot "..\.venv\Scripts\python.exe"
if (-not (Test-Path $python)) {
    Write-Error "Environnement non initialise. Lancez PS1\setup.ps1" ; exit 1
}
Write-Host "Lancement API en arriere-plan sur http://localhost:$Port ..." -ForegroundColor Cyan
$Args = @(
    "-m","uvicorn","app.main:app",
    "--app-dir","backend",
    "--host","0.0.0.0",
    "--port",$Port
)
Start-Process -WindowStyle Hidden -FilePath $python -ArgumentList $Args
Start-Sleep -Seconds 3
Write-Host "Backend demarre (bg)."

