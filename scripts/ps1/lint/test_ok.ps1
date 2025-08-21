# Lints doivent passer sur l'état courant

powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\ps1\lint\run_ruff.ps1
if ($LASTEXITCODE -ne 0) { Write-Host "KO: Ruff a echoue" -ForegroundColor Red; exit 1 }
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\ps1\lint\run_mypy.ps1
if ($LASTEXITCODE -ne 0) { Write-Host "KO: MyPy a echoue" -ForegroundColor Red; exit 1 }
Write-Host "OK: lints passent" -ForegroundColor Green
