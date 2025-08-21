# Installe deps et build

pip install -q -r requirements-docs.txt
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\ps1\docs\build.ps1
if ($LASTEXITCODE -ne 0) { Write-Host "KO: build a echoue" -ForegroundColor Red; exit 1 }
Write-Host "OK: build docs" -ForegroundColor Green
