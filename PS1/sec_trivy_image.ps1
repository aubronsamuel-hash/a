$ErrorActionPreference = "Stop"
param(
    [string]$Image = "ccapi:cli-ci",
    [string]$Output = "reports\trivy.sarif"
)
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Warning "Docker non installe; skip du scan d image."
    exit 0
}
Write-Host "Scan image Docker ($Image) avec Trivy..." -ForegroundColor Cyan

# Installe trivy portable via script shell dans un conteneur si absent

if (-not (Get-Command trivy -ErrorAction SilentlyContinue)) {
    Write-Host "Trivy non present; tentative d execution via conteneur..." -ForegroundColor Yellow
    docker pull aquasec/trivy:latest > $null
    New-Item -ItemType Directory -Force -Path (Split-Path $Output) | Out-Null
    docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -v "$PWD:/work" -w /work aquasec/trivy:latest image --severity HIGH,CRITICAL --scanners vuln --format sarif -o $Output $Image
    exit $LASTEXITCODE
}
trivy image --severity HIGH,CRITICAL --scanners vuln --format sarif -o $Output $Image
