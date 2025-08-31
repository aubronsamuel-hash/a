# repro_storybook_ci_lock.ps1
param(
  [string]$FrontendPath = "frontend"
)

$ErrorActionPreference = "Stop"
Write-Host "== Repro Storybook CI lockfile =="

if (-not (Test-Path $FrontendPath)) {
  Write-Error "Path not found: $FrontendPath"
}

$lock = Join-Path $FrontendPath "package-lock.json"
if (-not (Test-Path $lock)) {
  Write-Error "Missing lockfile: $lock"
}

Push-Location $FrontendPath
try {
  node -v
  npm -v
  Write-Host "Running: npm ci --no-audit --no-fund"
  npm ci --no-audit --no-fund
  Write-Host "Running: npm run build:storybook"
  npm run build:storybook
  if (-not (Test-Path "storybook-static")) {
    Write-Error "storybook-static not found after build."
  }
  Write-Host "OK: build storybook done."
}
finally {
  Pop-Location
}
