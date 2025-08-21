# Necessite sops + age-keygen installes et SOPS_AGE_KEY_FILE pointe vers une cle privee dont la pub est dans .sops.yaml

$plain = "secrets/tmp_plain.yaml"
$enc = "secrets/tmp.enc.yaml"
$dec = "secrets/tmp.dec.yaml"
New-Item -ItemType Directory -Force -Path "secrets" | Out-Null
@("password: 123","token: abc") | Set-Content -Encoding UTF8 $plain

if (-not (Get-Command sops -ErrorAction SilentlyContinue)) { Write-Host "sops introuvable (test skip)" -ForegroundColor Yellow; exit 0 }
if (-not $env:SOPS_AGE_KEY_FILE) { Write-Host "SOPS_AGE_KEY_FILE non defini (test skip)" -ForegroundColor Yellow; exit 0 }

# Tente d extraire la cle publique depuis le fichier de cle privee

$priv = Get-Content $env:SOPS_AGE_KEY_FILE -Raw
$pub = ($priv -split "\n") | Where-Object { $_ -like "# public key:*" } | ForEach-Object { $_.Split(": ")[1].Trim() } | Select-Object -First 1
if (-not $pub) { Write-Host "Impossible de deduire la cle publique (test skip)" -ForegroundColor Yellow; exit 0 }

powershell -NoProfile -ExecutionPolicy Bypass -File scripts/ps1/secrets/sops_encrypt.ps1 -In $plain -Out $enc -AgePub $pub
if ($LASTEXITCODE -ne 0) { Write-Host "Echec encrypt" -ForegroundColor Red; exit 1 }
$env:SOPS_AGE_KEY_FILE = $env:SOPS_AGE_KEY_FILE
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/ps1/secrets/sops_decrypt.ps1 -In $enc -Out $dec
if ($LASTEXITCODE -ne 0) { Write-Host "Echec decrypt" -ForegroundColor Red; exit 1 }

# Compare

$h1 = Get-FileHash $plain -Algorithm SHA256
$h2 = Get-FileHash $dec -Algorithm SHA256
if ($h1.Hash -ne $h2.Hash) { Write-Host "KO: mismatch apres roundtrip" -ForegroundColor Red; exit 1 }
Write-Host "OK: roundtrip sops" -ForegroundColor Green
