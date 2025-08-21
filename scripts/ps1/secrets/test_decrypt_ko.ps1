# Decrypt avec mauvaise cle -> doit echouer

param(
    [string]$Enc = "secrets/tmp.enc.yaml",
    [string]$FakeKey = "keys/age/fake_agekey.txt"
)
if (-not (Get-Command sops -ErrorAction SilentlyContinue)) { Write-Host "sops introuvable (test skip)" -ForegroundColor Yellow; exit 0 }
if (-not (Test-Path $Enc)) { Write-Host "Fichier chiffre introuvable (skip)" -ForegroundColor Yellow; exit 0 }
$old = $env:SOPS_AGE_KEY_FILE
$env:SOPS_AGE_KEY_FILE = $FakeKey
try {
    sops -d $Enc | Out-Null
    Write-Host "KO: decrypt a reussi avec mauvaise cle" -ForegroundColor Red; exit 1
} catch {
    Write-Host "OK: decrypt a echoue avec mauvaise cle" -ForegroundColor Green; exit 0
} finally {
    $env:SOPS_AGE_KEY_FILE = $old
}
