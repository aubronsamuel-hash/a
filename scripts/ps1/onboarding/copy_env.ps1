param(
[string]$Src = ".env.dev.example",
[string]$Dst = ".env"
)
if (Test-Path $Dst) { Write-Host "$Dst existe deja, skip" -ForegroundColor Yellow; exit 0 }
if (-not (Test-Path $Src)) { Write-Host "$Src introuvable" -ForegroundColor Red; exit 2 }
Copy-Item $Src $Dst -Force
Write-Host "OK: $Src -> $Dst" -ForegroundColor Green
