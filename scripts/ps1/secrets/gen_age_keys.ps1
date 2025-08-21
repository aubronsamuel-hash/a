param(
    [string]$OutDir = "keys/age",
    [string]$KeyFile = "agekey.txt"
)
New-Item -ItemType Directory -Force -Path $OutDir | Out-Null
$full = Join-Path $OutDir $KeyFile
if (-not (Get-Command age-keygen -ErrorAction SilentlyContinue)) {
    Write-Host "age-keygen introuvable. Installez age (https://github.com/FiloSottile/age/releases)" -ForegroundColor Yellow
    exit 2
}
age-keygen -o $full | Out-Null
$pub = (Select-String -Path $full -Pattern "^# public key: (.*)$").Matches[0].Groups[1].Value
Write-Host "Cle privee: $full" -ForegroundColor Green
Write-Host "Cle publique: $pub" -ForegroundColor Cyan
Write-Host "IMPORTANT: Ajoutez la cle publique dans .sops.yaml et gardez la cle privee hors repo." -ForegroundColor Yellow
