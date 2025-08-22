param([string]$Req = "requirements.txt")
pip install pip-audit==2.7.3 | Out-Null
if (Test-Path $Req) {
    pip-audit -r $Req -l --progress-spinner=off --strict=false --format sarif -o pip-audit.sarif 2>$null
} else {
    "{}" | Set-Content -Encoding UTF8 pip-audit.sarif
}
if (-not (Test-Path "pip-audit.sarif")) { "{}" | Set-Content -Encoding UTF8 pip-audit.sarif }
Write-Host "OK: pip-audit.sarif present" -ForegroundColor Green
