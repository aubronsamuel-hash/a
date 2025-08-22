param(
    [string]$Tag = "cli:test"
)
Write-Host "Build image $Tag" -ForegroundColor Cyan
docker build --pull -t $Tag -f Dockerfile.cli .
if ($LASTEXITCODE -ne 0) { Write-Host "Echec build" -ForegroundColor Red; exit 2 }
Write-Host "Run image $Tag" -ForegroundColor Cyan
$out = docker run --rm $Tag
$out
if ($out -notmatch "coulisses-cli: OK") { Write-Host "Sortie inattendue" -ForegroundColor Red; exit 3 }
Write-Host "OK: CLI Docker" -ForegroundColor Green
