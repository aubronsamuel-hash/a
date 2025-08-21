$ErrorActionPreference = "Stop"
$Prom = "http://localhost:9090"

# readiness Prometheus

$ready = Invoke-WebRequest -UseBasicParsing -Uri "$Prom/-/ready" -TimeoutSec 5
if ($ready.StatusCode -ne 200) { Write-Error "Prometheus non pret ($($ready.StatusCode))"; exit 1 }

# targets

$targets = Invoke-WebRequest -UseBasicParsing -Uri "$Prom/api/v1/targets" -TimeoutSec 5
if ($targets.Content -notmatch '"job":"ccapi"') { Write-Error "Job ccapi non trouve dans les targets"; exit 1 }
Write-Host "Prometheus OK, job ccapi cible" -ForegroundColor Green
