$ErrorActionPreference = "Stop"
if (-not (Test-Path .env)) {
    Write-Host "Avertissement: .env absent. Copie .env.example -> .env" -ForegroundColor Yellow
    Copy-Item .env.example .env
}
docker compose up -d --build
Write-Host "API dispo: http://localhost:8001/healthz" -ForegroundColor Green
