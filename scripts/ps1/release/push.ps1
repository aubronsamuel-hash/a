param([switch]$Tags)
& git push
if ($LASTEXITCODE -ne 0) { Write-Host "Echec push" -ForegroundColor Red; exit 2 }
if ($Tags) { & git push --tags }
