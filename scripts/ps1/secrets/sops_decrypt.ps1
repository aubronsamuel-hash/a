param(
    [string]$In = "secrets/app.enc.yaml",
    [string]$Out = "secrets/app.dec.yaml"
)
if (-not (Get-Command sops -ErrorAction SilentlyContinue)) { Write-Host "sops introuvable" -ForegroundColor Red; exit 2 }
if (-not $env:SOPS_AGE_KEY_FILE) { Write-Host "SOPS_AGE_KEY_FILE non defini" -ForegroundColor Red; exit 2 }
sops -d $In | Set-Content -Encoding UTF8 $Out
Write-Host "OK: $Out cree (dechiffre)" -ForegroundColor Green
