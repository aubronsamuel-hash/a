$env:PYTHONPATH = "backend"
$env:METRICS_ENABLED = "1"
$env:METRICS_PATH = "/metrics"
Start-Process -FilePath python -ArgumentList "-m","uvicorn","backend.app.main:app","--host","127.0.0.1","--port","8001" -NoNewWindow
Start-Sleep -Seconds 3
try {
    $r = Invoke-WebRequest -UseBasicParsing http://127.0.0.1:8001/metrics -TimeoutSec 10
    if ($r.StatusCode -eq 200) { Write-Host "OK: /metrics 200" -ForegroundColor Green } else { exit 2 }
} catch { Write-Host "KO: /metrics" -ForegroundColor Red; exit 2 }
