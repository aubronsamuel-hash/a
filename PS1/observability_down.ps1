$ErrorActionPreference = "Stop"
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) { Write-Error "Docker non installe."; exit 1 }
docker compose -f docker-compose.observability.yml down -v
Write-Host "Observabilite down (volumes supprimes)" -ForegroundColor Yellow
