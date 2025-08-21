param([string]$Base = "http://localhost:8001")
$ErrorActionPreference = "Stop"
try {
    $r = Invoke-WebRequest -UseBasicParsing -Uri "$Base/features" -TimeoutSec 5
    Write-Host $r.Content
    Write-Host ("X-Features: " + ($r.Headers["X-Features"])) -ForegroundColor Cyan
} catch {
    Write-Error "Echec GET $Base/features ($_)" ; exit 1
}
