$ErrorActionPreference = "Stop"
$Base = "http://localhost:8001"

# Login admin (tente mdp actuel puis fallback secretXYZ)

function Get-Token {
param([string]$U,[string]$P)
try {
$r = Invoke-RestMethod -Uri "$Base/auth/token" -Method POST -ContentType application/json -Body (@{username=$U;password=$P} | ConvertTo-Json)
return $r.access_token
} catch { return $null }
}
$tok = Get-Token -U "admin" -P "admin123"
if (-not $tok) { $tok = Get-Token -U "admin" -P "secretXYZ" }
if (-not $tok) { Write-Error "Impossible d obtenir un token admin" ; exit 1 }

$headers = @{ Authorization = "Bearer $tok" }
$r1 = Invoke-WebRequest -Uri "$Base/users?order=username_asc" -Headers $headers -TimeoutSec 10 -Method GET
$etag = $r1.Headers["ETag"]
"ETag recu: $etag"
$r2 = Invoke-WebRequest -Uri "$Base/users?order=username_asc" -Headers (@{ Authorization = "Bearer $tok"; "If-None-Match" = $etag }) -TimeoutSec 10 -Method GET -ErrorAction SilentlyContinue
if ($r2.StatusCode -ne 304) { Write-Error "304 attendu, recu $($r2.StatusCode)" ; exit 1 }
Write-Host "Cache 304 OK" -ForegroundColor Green
