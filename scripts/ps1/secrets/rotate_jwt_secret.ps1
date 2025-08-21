param(
    [string]$EnvFile = ".env.dev"
)
if (-not (Test-Path $EnvFile)) { Write-Host "$EnvFile introuvable" -ForegroundColor Red; exit 2 }

# Genere 32 octets aleatoires base64

$bytes = New-Object byte[] 32
[System.Security.Cryptography.RandomNumberGenerator]::Create().GetBytes($bytes)
$val = [Convert]::ToBase64String($bytes)
$lines = Get-Content $EnvFile
$updated = @()
$found = $false
foreach ($l in $lines) {
    if ($l -match '^JWT_SECRET=') { $updated += "JWT_SECRET=$val"; $found = $true }
    else { $updated += $l }
}
if (-not $found) { $updated += "JWT_SECRET=$val" }
$updated | Set-Content -Encoding UTF8 $EnvFile
Write-Host "OK: JWT_SECRET mis a jour dans $EnvFile (rotation)" -ForegroundColor Green
Write-Host "NOTE: Pour staging/prod, mettre a jour le secret dans votre store (GH Secrets) et redeployer." -ForegroundColor Yellow
