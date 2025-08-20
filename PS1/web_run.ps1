$ErrorActionPreference = "Stop"
if (-not (Test-Path .\web\package.json)) { Write-Error "Dossier web introuvable" ; exit 1 }
if (-not $env:VITE_API_BASE_URL) { $env:VITE_API_BASE_URL = "http://localhost:8001" }
Push-Location web
Start-Process -WindowStyle Hidden -FilePath npm -ArgumentList "run","dev"
Start-Sleep -Seconds 3
Write-Host "Frontend sur http://localhost:5173" -ForegroundColor Green
Pop-Location
