$ErrorActionPreference = "Stop"
docker compose up -d --build
Write-Host "API dispo: http://localhost:8001/healthz" -ForegroundColor Green
