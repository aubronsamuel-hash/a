$ErrorActionPreference = "Stop"
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Warning "Docker non installe. Fallback: .\PS1\run_bg.ps1"
    exit 0
}
$tag = "ccapi:local"
$container = "ccapi_local"

# stop & rm si existe
docker rm -f $container 2>$null | Out-Null
docker run -d --name $container -p 8001:8001 --env FRONT_DIST_DIR="/app/public" $tag | Out-Null
Write-Host "Container lance: $container (http://localhost:8001)" -ForegroundColor Green
