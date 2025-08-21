param(
    [string]$Image = "example/app",
    [string]$FromTag = "staging",
    [string]$ToTag = "prod",
    [switch]$Push,
    [switch]$DryRun
)
$src = "$Image:$FromTag"
$dst = "$Image:$ToTag"
Write-Host "Promote $src -> $dst" -ForegroundColor Cyan
if ($DryRun) { Write-Host "Dry-run: docker tag $src $dst && docker push $dst (si -Push)" -ForegroundColor Yellow; exit 0 }
& docker tag $src $dst
if ($LASTEXITCODE -ne 0) { Write-Host "Echec docker tag" -ForegroundColor Red; exit 3 }
if ($Push) { & docker push $dst; if ($LASTEXITCODE -ne 0) { Write-Host "Echec docker push" -ForegroundColor Red; exit 4 } }
Write-Host "OK" -ForegroundColor Green
