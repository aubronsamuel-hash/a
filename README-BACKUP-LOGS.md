# Backups DB et Rotation logs

Backups:

* Env: DB_* , BACKUP_DIR, BACKUP_RETENTION_DAYS
* Windows: .\scripts\ps1\backup\pg_backup.ps1
* Bash: ./scripts/bash/backup/pg_backup.sh
* Sortie: BACKUP_DIR/YYYY/MM-DD/name_TS.sql.gz
* Retention: fichiers plus vieux que N jours supprimes

Logs app:

* Activer fichier: LOG_TO_FILE=1, LOG_FILE_PATH, LOG_FILE_MAX_BYTES, LOG_FILE_BACKUP_COUNT
* Sinon stdout

Logs conteneurs:

* Inclure docker/docker-compose.logging.yml pour limiter la taille des journaux json-file

Contraintes:
Windows-first. ASCII. Pas de secrets en dur. DB creds via env. Retention parametrable. Logs FR dans scripts.

Tests (PowerShell):

# Backups OK/KO

powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\ps1\backup\test_ok.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\ps1\backup\test_ko.ps1

# Rotation app (pytest)

PYTHONPATH=backend pytest -q backend/tests/test_logging_rotation.py

# Attendu: 2 passed
