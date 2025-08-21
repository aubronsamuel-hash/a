param(
    [string]$In = "secrets/plain.yaml",
    [string]$Out = "secrets/app.enc.yaml",
    [string]$AgePub = ""
)
if (-not (Get-Command sops -ErrorAction SilentlyContinue)) { Write-Host "sops introuvable" -ForegroundColor Red; exit 2 }
if ($AgePub -eq "") { Write-Host "Age public key requis (-AgePub)" -ForegroundColor Red; exit 2 }

sops -e --age $AgePub $In | Set-Content -Encoding UTF8 $Out
Write-Host "OK: $Out cree (chiffre)" -ForegroundColor Green
