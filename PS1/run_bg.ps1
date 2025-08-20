Param([int]$Port = 8001)
$ErrorActionPreference = "Stop"

if (-not (Test-Path .\.venv\Scripts\python.exe)) {
    Write-Error "Environnement non initialise. Lancez PS1\setup.ps1" ; exit 1
}
if (-not (Test-Path .\backend\app\main.py)) {
    Write-Error "Fichier backend\app\main.py introuvable. Lancez depuis la racine du repo." ; exit 1
}
if (-not (Test-Path .env)) {
    Write-Host "Avertissement: .env absent. Copie .env.example -> .env" -ForegroundColor Yellow
    if (Test-Path .env.example) { Copy-Item .env.example .env }
}

Write-Host "Lancement API en arriere-plan sur http://localhost:$Port ..." -ForegroundColor Cyan
$Args = @("-m","uvicorn","app.main:app","--app-dir","backend","--host","0.0.0.0","--port",$Port)
Start-Process -WindowStyle Hidden -FilePath .\.venv\Scripts\python.exe -ArgumentList $Args -PassThru | Out-Null
Start-Sleep -Seconds 5
try {
    $code = (Invoke-WebRequest -Uri "http://localhost:$Port/healthz" -UseBasicParsing -TimeoutSec 10).StatusCode
    if ($code -eq 200) {
        Write-Host "Backend demarre (bg), /healthz 200." -ForegroundColor Green
    } else {
        Write-Error "Backend lance mais /healthz = $code" ; exit 1
    }
} catch {
    Write-Error "Echec ping /healthz: $($_.Exception.Message)" ; exit 1
}

