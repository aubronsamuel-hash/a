param(
    [string]$ClientId,
    [string]$ClientSecret,
    [string]$RedirectUri = "http://localhost/auth/google/callback",
    [string]$EnvFile = ".env"
)
if (-not $ClientId -or -not $ClientSecret) { Write-Host "ClientId et ClientSecret requis" -ForegroundColor Red; exit 1 }
$lines = @(
    "GOOGLE_CLIENT_ID=$ClientId",
    "GOOGLE_CLIENT_SECRET=$ClientSecret",
    "GOOGLE_REDIRECT_URI=$RedirectUri"
)
if (-not (Test-Path $EnvFile)) { New-Item -ItemType File -Path $EnvFile | Out-Null }
$map = @{}
Get-Content $EnvFile -ErrorAction SilentlyContinue | ForEach-Object {
    if ($_ -match "^\s*#" -or $_ -match "^\s*$") { return }
    $k,$v = $_.Split("=",2); $map[$k]=$v
}
foreach ($l in $lines) { $k,$v = $l.Split("=",2); $map[$k]=$v }
@($map.Keys | Sort-Object) | ForEach-Object { "$_=$($map[$_])" } | Set-Content $EnvFile -Encoding UTF8
Write-Host "OK: .env mis a jour (Google OAuth)." -ForegroundColor Green
