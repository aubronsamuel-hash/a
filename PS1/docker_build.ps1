$ErrorActionPreference = "Stop"
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Warning "Docker non installe. Fallback: .\PS1\run_bg.ps1"
    exit 0
}
$tag = "ccapi:local"
docker build -t $tag .
Write-Host "Image construite: $tag" -ForegroundColor Green
