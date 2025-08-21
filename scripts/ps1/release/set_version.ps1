param([Parameter(Mandatory=$true)][string]$Version)
if ($Version -notmatch '^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)(?:-[0-9A-Za-z.-]+)?(?:\+[0-9A-Za-z.-]+)?$') {
    Write-Host "Version semver invalide: $Version" -ForegroundColor Red; exit 2
}
Set-Content -Path VERSION -Value $Version -Encoding UTF8

# MAJ version dans backend/app/__init__.py si present

$init = "backend/app/__init__.py"
if (Test-Path $init) {
    (Get-Content $init) -replace 'version = ".*"', ('version = "' + $Version + '"') | Set-Content $init -Encoding UTF8
}
Write-Host "OK: VERSION=$Version" -ForegroundColor Green
