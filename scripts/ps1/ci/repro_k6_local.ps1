$env:PYTHONPATH = "backend;."

# tente backend d'abord, sinon mock

try {
Start-Process -FilePath python -ArgumentList "-m","uvicorn","backend.app.main:app","--host","127.0.0.1","--port","8000" -NoNewWindow -ErrorAction Stop
} catch {
Start-Process -FilePath python -ArgumentList "-m","uvicorn","scripts.k6.mock_api:app","--host","127.0.0.1","--port","8000" -NoNewWindow
}
Start-Sleep -Seconds 2
docker run --rm -e BASE_URL="http://127.0.0.1:8000" -v ${PWD}:/work -w /work grafana/k6 run scripts/k6/smoke.js
