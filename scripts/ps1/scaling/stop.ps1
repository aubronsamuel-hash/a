param([int]$Port=8000)
Get-NetTCPConnection -LocalPort $Port -ErrorAction SilentlyContinue | ForEach-Object {
    try { Stop-Process -Id $_.OwningProcess -Force -ErrorAction Stop } catch {}
}
Write-Host "Gunicorn sur :$Port stoppe si present." -ForegroundColor Yellow
