param([string]$Dir = ".ci\logs")
if (-not (Test-Path $Dir)) { Write-Host "$Dir introuvable" -ForegroundColor Red; exit 2 }
Get-ChildItem -Recurse -Path $Dir -Filter "*.log" | ForEach-Object {
    $path = $_.FullName
    $out = "$($path).errors.txt"
    Select-String -Path $path -Pattern "ERROR|FAIL|AssertionError|Traceback|E2E FAILED|Exited with code|mypy error|ruff" -AllMatches |
    ForEach-Object { $_.Line } | Set-Content -Encoding UTF8 $out
    if (Test-Path $out) { Write-Host "Erreurs -> $out" -ForegroundColor Yellow }
}
