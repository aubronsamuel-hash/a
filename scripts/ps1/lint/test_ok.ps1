# Lints doivent passer sur l'etat courant

powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\ps1\lint\run_ruff.ps1 -Path backend
if ($LASTEXITCODE -ne 0) { Write-Host "KO: Ruff a echoue" -ForegroundColor Red; exit 1 }
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\ps1\lint\run_mypy.ps1 -Path "backend/app backend/cli"
if ($LASTEXITCODE -ne 0) { Write-Host "KO: MyPy a echoue" -ForegroundColor Red; exit 1 }
Write-Host "OK: lints passent (E/F/I + mypy)" -ForegroundColor Green
