# Test OK: backup avec env corrects (utiliser une DB dev)

$env:DB_HOST = "localhost"
$env:DB_PORT = "5432"
$env:DB_NAME = "app_db"
$env:DB_USER = "app_user"
$env:DB_PASSWORD = "pass"

powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\ps1\backup\pg_backup.ps1 -BackupDir "backups/db_test" -RetentionDays 1
if ($LASTEXITCODE -ne 0) { Write-Host "KO: backup a echoue" -ForegroundColor Red; exit 1 }
Write-Host "OK" -ForegroundColor Green
