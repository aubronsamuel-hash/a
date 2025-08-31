# Repro locale Windows du pipeline Storybook avec cache npm (~/.npm)
param(
  [string]$FrontendPath = "frontend"
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

Write-Host "== Repro Storybook CI (cache npm) =="

if (-not (Test-Path $FrontendPath)) {
  Write-Error "Dossier introuvable: $FrontendPath"
}

$lock = Join-Path $FrontendPath "package-lock.json"
if (-not (Test-Path $lock)) {
  Write-Error "Lockfile manquant: $lock"
}

$npmCache = Join-Path $HOME ".npm"
if (-not (Test-Path $npmCache)) {
  New-Item -ItemType Directory -Path $npmCache | Out-Null
}

Push-Location $FrontendPath
try {
  node -v
  npm -v
  $env:NPM_CONFIG_CACHE = $npmCache
  Write-Host "npm ci..."
  npm ci --no-audit --no-fund
  Write-Host "build storybook..."
  npm run build:storybook
  if (-not (Test-Path "storybook-static")) {
    Write-Error "storybook-static manquant apres build."
  }
  Write-Host "OK"
} finally {
  Pop-Location
}

