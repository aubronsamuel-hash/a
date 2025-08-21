$ErrorActionPreference = "Stop"
param(
    [string]$Image = "ccapi:cli-ci",
    [string]$Output = "reports\trivy.sarif"
)
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Warning "Docker non installe; on skip le scan d image."
    exit 0
}
New-Item -ItemType Directory -Force -Path (Split-Path $Output) | Out-Null
if (-not (Get-Command trivy -ErrorAction SilentlyContinue)) {
    Write-Host "Trivy local non present; utilisation du conteneur aquasec/trivy..." -ForegroundColor Yellow
    docker pull aquasec/trivy:latest > $null
    docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -v "$PWD:/work" -w /work aquasec/trivy:latest image --severity HIGH,CRITICAL --scanners vuln --format sarif -o $Output $Image
    exit $LASTEXITCODE
}
trivy image --severity HIGH,CRITICAL --scanners vuln --format sarif -o $Output $Image
Write-Host "Trivy OK -> $Output" -ForegroundColor Green
