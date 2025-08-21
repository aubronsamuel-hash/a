param([int]$Port=8000)

# Reload gracieux via HUP si PID connu; fallback: stop/start
$procs = Get-Process | Where-Object { $_.ProcessName -match "gunicorn" }
if ($procs) {
    foreach ($p in $procs) {
        try { (Get-Process -Id $p.Id).CloseMainWindow() | Out-Null } catch {}
    }
    Write-Host "Reload demande (HUP non garanti sur Windows)." -ForegroundColor Cyan
} else {
    Write-Host "Aucun gunicorn detecte, relance." -ForegroundColor Yellow
}
