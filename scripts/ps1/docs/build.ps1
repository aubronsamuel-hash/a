if (-not (Get-Command mkdocs -ErrorAction SilentlyContinue)) { Write-Host "mkdocs introuvable" -ForegroundColor Red; exit 2 }
mkdocs build --clean
if ($LASTEXITCODE -ne 0) { Write-Host "Echec build docs" -ForegroundColor Red; exit 1 }
Write-Host "OK: build docs dans ./site" -ForegroundColor Green
