param()
$path = Join-Path (Get-Location) "VERSION"
if (-not (Test-Path $path)) { Write-Host "VERSION introuvable" -ForegroundColor Red; exit 2 }
(Get-Content $path -Raw).Trim()
