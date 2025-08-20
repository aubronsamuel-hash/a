$ErrorActionPreference = "Stop"
$Base = "http://localhost:8001"
function Login($U,$P) {
try {
$r = Invoke-RestMethod -Uri "$Base/auth/token" -Method POST -ContentType application/json -Body (@{username=$U;password=$P} | ConvertTo-Json)
return $r.access_token
} catch { return $null }
}
$tok = Login "admin" "admin123"
if (-not $tok) { $tok = Login "admin" "secretXYZ" }
if (-not $tok) { Write-Error "Impossible d obtenir un token admin" ; exit 1 }

# 1er appel

$r1 = Invoke-WebRequest -Uri "$Base/users?page=1&page_size=10&order=username_asc" -Headers @{ Authorization = "Bearer $tok" } -Method GET -TimeoutSec 10
$etag = $r1.Headers["ETag"]
"ETag: $etag"

# 2e appel If-None-Match -> 304

$r2 = Invoke-WebRequest -Uri "$Base/users?page=1&page_size=10&order=username_asc" -Headers @{ Authorization = "Bearer $tok"; "If-None-Match" = $etag } -Method GET -TimeoutSec 10 -ErrorAction SilentlyContinue
if ($r2.StatusCode -ne 304) { Write-Error "304 attendu, recu $($r2.StatusCode)" ; exit 1 }
Write-Host "Front smoke ETag OK" -ForegroundColor Green
