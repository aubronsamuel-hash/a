param(
[int]$Port = 8000,
[switch]$Reload
)
Write-Host "== Demarrage backend dev ==" -ForegroundColor Cyan
if (Test-Path ".venv/Scripts/Activate.ps1") { . ".venv/Scripts/Activate.ps1" }
$env:PYTHONPATH = "backend"
$cmd = "uvicorn backend.app.main:app --host 0.0.0.0 --port $Port" + ($(if($Reload){" --reload"} else {""}))
Write-Host $cmd -ForegroundColor Gray
Start-Process -FilePath python -ArgumentList "-m", "uvicorn", "backend.app.main:app", "--host", "0.0.0.0", "--port", "$Port" -NoNewWindow
Start-Sleep -Seconds 2
try {
$r = Invoke-WebRequest -UseBasicParsing "http://localhost:$Port/healthz" -TimeoutSec 5
if ($r.StatusCode -eq 200) { Write-Host "OK: healthz 200" -ForegroundColor Green; exit 0 } else { Write-Host "KO: HTTP $($r.StatusCode)" -ForegroundColor Red; exit 3 }
} catch {
Write-Host "KO: backend non joignable" -ForegroundColor Red; exit 3
}
