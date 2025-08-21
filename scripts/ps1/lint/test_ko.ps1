# Provoque un echec Ruff (unused import) puis nettoie

$tp = "tmp_lint_fail.py"
"import os, sys`n" + "x=1`n" | Set-Content -Encoding UTF8 $tp
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\ps1\lint\run_ruff.ps1 -Path $tp
if ($LASTEXITCODE -eq 0) { Write-Host "KO: Ruff aurait du echouer" -ForegroundColor Red; Remove-Item $tp -Force; exit 1 }
Write-Host "OK: echec attendu Ruff" -ForegroundColor Yellow
Remove-Item $tp -Force
