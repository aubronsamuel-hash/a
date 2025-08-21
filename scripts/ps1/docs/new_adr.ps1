param([Parameter(Mandatory=$true)][string]$Title)
$slug = ($Title.ToLower() -replace '[^a-z0-9]+','-').Trim('-')
$dir = "docs/adr"
New-Item -ItemType Directory -Force -Path $dir | Out-Null
$idx = (Get-ChildItem $dir -Filter "*.md").Count
$path = Join-Path $dir ("{0:D4}-$slug.md" -f $idx)
@(
"# ADR: $Title",
"",
"- Date: $(Get-Date -Format yyyy-MM-dd)",
"- Statut: propose",
"- Contexte:",
"- Decision:",
"- Consequences:"
) | Set-Content -Encoding UTF8 $path
Write-Host "OK: $path" -ForegroundColor Green
