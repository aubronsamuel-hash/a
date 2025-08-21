$ErrorActionPreference = "Stop"
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Error "Docker non installe."
    exit 1
}
docker compose -f docker-compose.postgres.yml up -d --build
Write-Host "Postgres + backend demarres (http://localhost:8001)" -ForegroundColor Green
