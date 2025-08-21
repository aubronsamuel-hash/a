$ErrorActionPreference = "Stop"
param([string]$Base = "http://localhost:8001")
Write-Host "Check $Base/livez ..." -ForegroundColor Cyan
$live = Invoke-WebRequest -UseBasicParsing -Uri "$Base/livez" -TimeoutSec 3
Write-Host "  livez: $($live.StatusCode)"
Write-Host "Check $Base/readyz ..." -ForegroundColor Cyan
$ready = Invoke-WebRequest -UseBasicParsing -Uri "$Base/readyz" -TimeoutSec 3 -ErrorAction SilentlyContinue
if ($null -eq $ready) {
    Write-Warning "  readyz KO"
    exit 1
}
Write-Host "  readyz: $($ready.StatusCode)"
