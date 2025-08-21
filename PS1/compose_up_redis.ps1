$ErrorActionPreference = "Stop"
if (-not (Test-Path "./docker-compose.yml")) {
    Write-Warning "docker-compose.yml introuvable. Hypothese: votre stack compose existe deja. Utiliser le fichier override."
}
docker compose -f docker-compose.yml -f docker-compose.redis.yml up -d --build
Write-Host "Stack Redis up. BACKEND utilise RATE_LIMIT_BACKEND=redis." -ForegroundColor Green

