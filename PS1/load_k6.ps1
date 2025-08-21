$ErrorActionPreference = "Stop"
param(
    [int]$VUs = 10,
    [int]$Seconds = 20
)
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Warning "Docker non installe; test k6 skippe."; exit 0
}
Write-Host "Build image backend..." -ForegroundColor Cyan
docker build -t ccapi:k6 .
Write-Host "Compose up backend..." -ForegroundColor Cyan
docker compose -f docker-compose.k6.yml up -d --build

# Attente sante

for ($i=0; $i -lt 90; $i++) {
    try {
        $code = (Invoke-WebRequest -UseBasicParsing -Uri "http://localhost:8001/healthz" -TimeoutSec 2).StatusCode
        if ($code -eq 200) { break }
    } catch {}
    Start-Sleep -Seconds 2
}

# Exec k6 via conteneur officiel; montee du script

$env:BASE = "http://backend:8001"
$summary = "load\k6\summary.json"
New-Item -ItemType Directory -Force -Path "load\k6" | Out-Null
docker run --rm --network cc-k6_default -v "$PWD/load/k6:/scripts" -e BASE=$env:BASE grafana/k6:latest run --vus $VUs --duration ${Seconds}s --summary-export /scripts/summary.json /scripts/smoke.js
$rc = $LASTEXITCODE
Write-Host "Compose down..." -ForegroundColor Yellow
docker compose -f docker-compose.k6.yml down -v
exit $rc
