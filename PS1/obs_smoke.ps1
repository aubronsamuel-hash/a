$ErrorActionPreference = "Stop"
$Base = "http://localhost:8001"
$Hdr = $env:REQUEST_ID_HEADER; if (-not $Hdr) { $Hdr = "X-Request-ID" }
$MyID = [guid]::NewGuid().ToString()
Write-Host "== /healthz avec $Hdr ==" -ForegroundColor Cyan
$h = Invoke-WebRequest -Method GET -Uri "$Base/healthz" -Headers @{$Hdr=$MyID} -TimeoutSec 10
"Code: $($h.StatusCode) RID_recu: $($h.Headers[$Hdr])"
if ($h.Headers[$Hdr] -ne $MyID) { Write-Error "Propagation $Hdr KO" ; exit 1 }
Write-Host "== /metrics ==" -ForegroundColor Cyan
$m = Invoke-WebRequest -Method GET -Uri "$Base/metrics" -TimeoutSec 10
"Metrics length: $($m.Content.Length)"
Write-Host "== /readyz ==" -ForegroundColor Cyan
$r = Invoke-WebRequest -Method GET -Uri "$Base/readyz" -TimeoutSec 10
"Ready: $($r.StatusCode)"
