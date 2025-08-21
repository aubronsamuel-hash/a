# E2E: check -> env -> setup -> up -> ping -> down

powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\ps1\onboarding\check_env.ps1 -MinPython 3.11
if ($LASTEXITCODE -ne 0) { Write-Host "KO: pre-requis" -ForegroundColor Red; exit 1 }
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\ps1\onboarding\copy_env.ps1 -Src .env.dev.example -Dst .env
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\ps1\onboarding\setup_backend.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\ps1\onboarding\dev_up.ps1 -Port 8000

# Verification via /healthz

try {
$r = Invoke-WebRequest -UseBasicParsing http://localhost:8000/healthz -TimeoutSec 5
if ($r.StatusCode -ne 200) { throw "HTTP $($r.StatusCode)" }
Write-Host "OK: onboarding E2E" -ForegroundColor Green
} catch {
Write-Host "KO: healthz" -ForegroundColor Red; exit 1
} finally {
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\ps1\onboarding\dev_down.ps1 -Port 8000 | Out-Null
}
