# KO attendu: run sans RunId

powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\ps1\ci\fetch_job_logs.ps1 -RunId ""
if ($LASTEXITCODE -eq 0) { Write-Host "KO: devait echouer sans RunId" -ForegroundColor Red; exit 1 }
Write-Host "OK: echec attendu" -ForegroundColor Yellow
