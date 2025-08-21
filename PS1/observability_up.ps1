$ErrorActionPreference = "Stop"
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) { Write-Error "Docker non installe."; exit 1 }
docker compose -f docker-compose.observability.yml up -d --build
Write-Host "Observabilite up: http://localhost:9090 (Prometheus), http://localhost:3000 (Grafana: admin/admin)" -ForegroundColor Green
