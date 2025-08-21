$env:PYTHONPATH = "backend"
$env:METRICS_ENABLED = "1"
$env:METRICS_PATH = "/metrics"
Start-Process -FilePath python -ArgumentList "-m","uvicorn","backend.app.main:app","--host","127.0.0.1","--port","8001" -NoNewWindow
Start-Sleep -Seconds 2
Invoke-WebRequest -UseBasicParsing http://127.0.0.1:8001/metrics
