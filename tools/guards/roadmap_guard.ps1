# ASCII-only. PowerShell 7+
# Purpose: ensure the PR or last commit includes 'Ref: docs/roadmap/step-XX.md'.
# Usage:
#   pwsh -File tools/guards/roadmap_guard.ps1
#   pwsh -File tools/guards/roadmap_guard.ps1 --strict
# Reads PR body from: --PrBody, env:PR_BODY, GITHUB_EVENT_PATH, or git log -1.

param(
    [switch]$Strict,
    [string]$PrBody
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version 3

function Fail([string]$Message) {
    Write-Error $Message
    exit 1
}

# 1) Param or env
if (-not $PrBody -and $env:PR_BODY) { $PrBody = $env:PR_BODY }

# 2) GitHub event payload (PRs or pushes)
if (-not $PrBody -and $env:GITHUB_EVENT_PATH -and (Test-Path -LiteralPath $env:GITHUB_EVENT_PATH)) {
    try {
        $evt = Get-Content -LiteralPath $env:GITHUB_EVENT_PATH -Raw | ConvertFrom-Json
        if ($evt.pull_request -and $evt.pull_request.body) {
            $PrBody = [string]$evt.pull_request.body
        } elseif ($evt.head_commit -and $evt.head_commit.message) {
            # For push events
            if (-not $PrBody) { $PrBody = [string]$evt.head_commit.message }
        }
    } catch {
        Write-Warning ("roadmap_guard: could not parse GITHUB_EVENT_PATH: {0}" -f $_.Exception.Message)
    }
}

# 3) Last commit message fallback
$lastCommit = ""
try { $lastCommit = (git log -1 --pretty=%B) 2>$null } catch { }

$refPattern = 'Ref:\s*docs/roadmap/step-\d+\.md'
$hasRef = $false

if ($PrBody -and ($PrBody -match $refPattern)) {
    $hasRef = $true
} elseif ($lastCommit -and ($lastCommit -match $refPattern)) {
    $hasRef = $true
}

Write-Host "roadmap_guard: strict=$($Strict.IsPresent), hasRef=$hasRef"

if ($Strict) {
    if (-not $hasRef) {
        Write-Host "Debug PR_BODY snippet:"
        if ($PrBody) { $PrBody.Substring(0, [Math]::Min(200, $PrBody.Length)) | Write-Host } else { Write-Host "<empty>" }
        Write-Host "Debug last commit message snippet:"
        if ($lastCommit) { $lastCommit.Substring(0, [Math]::Min(200, $lastCommit.Length)) | Write-Host } else { Write-Host "<empty>" }
        Fail "Missing 'Ref: docs/roadmap/step-XX.md' in PR or last commit."
    }
} else {
    if (-not $hasRef) {
        Write-Warning "No 'Ref: docs/roadmap/step-XX.md' found (non-strict)."
    }
}

Write-Host "roadmap_guard OK"
