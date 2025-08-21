# Force un KO en exigeant une version impossible

powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\ps1\onboarding\check_env.ps1 -MinPython 9.9
if ($LASTEXITCODE -eq 0) { Write-Host "KO: check_env aurait du echouer" -ForegroundColor Red; exit 1 } else { Write-Host "OK: echec attendu check_env" -ForegroundColor Yellow }
