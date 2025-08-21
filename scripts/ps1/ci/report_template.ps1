param(
    [string]$Job,
    [string]$RunId,
    [string]$ErrorFile
)
$body = @"

# Rapport CI - $Job

Run: $RunId

Erreurs (extrait):
$(Get-Content $ErrorFile -ErrorAction SilentlyContinue | Select-Object -First 50 -Join "`n")

Repro locale:
.\scripts\ps1\ci\run_local.ps1 -Job $Job

## Hypothese:

## Patch minimal:

## Tests de regression:

"@
$path = ".ci\reports\$($Job)_$($RunId).md"
New-Item -ItemType Directory -Force -Path ".ci\reports" | Out-Null
$body | Set-Content -Encoding UTF8 $path
Write-Host "OK: rapport -> $path" -ForegroundColor Green
