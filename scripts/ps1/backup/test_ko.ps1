# Test KO: port faux -> echec

$env:DB_HOST = "localhost"
$env:DB_PORT = "6543"
$env:DB_NAME = "app_db"
$env:DB_USER = "app_user"
$env:DB_PASSWORD = "pass"

powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\ps1\backup\pg_backup.ps1 -BackupDir "backups/db_test" -RetentionDays 1
if ($LASTEXITCODE -eq 0) { Write-Host "KO: le test devait echouer" -ForegroundColor Red; exit 1 }
Write-Host "OK: echec attendu" -ForegroundColor Yellow
