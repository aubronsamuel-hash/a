$ErrorActionPreference = "Stop"
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Error "Docker non installe."
    exit 1
}
docker compose -f docker-compose.postgres.yml down -v
Write-Host "Stack Postgres arrete et volumes supprimes." -ForegroundColor Yellow
