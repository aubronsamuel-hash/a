# Smoke: verifie presence gh et generation fichiers locaux

if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    Write-Host "gh absent - test_ok se limitera aux fichiers locaux" -ForegroundColor Yellow
}
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\ps1\ci\repro_matrix.ps1
if (-not (Test-Path ".ci\repro_matrix.csv")) { Write-Host "KO: repro_matrix manquante" -ForegroundColor Red; exit 1 }
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\ps1\ci\run_local.ps1 -Job backend-tests
Write-Host "OK: test_ok passe (backend-tests lance)" -ForegroundColor Green
