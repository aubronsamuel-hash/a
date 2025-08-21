param([int]$Port=8000)
Get-NetTCPConnection -LocalPort $Port -ErrorAction SilentlyContinue | ForEach-Object {
try { Stop-Process -Id $_.OwningProcess -Force -ErrorAction Stop } catch {}
}
Write-Host "OK: backend dev stoppe (port :$Port)" -ForegroundColor Yellow
