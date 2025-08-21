#!/usr/bin/env bash
set -euo pipefail
BACKUP_DIR="${BACKUP_DIR:-backups/db}"
RETENTION_DAYS="${BACKUP_RETENTION_DAYS:-7}"
DB_HOST="${DB_HOST:-localhost}"
DB_PORT="${DB_PORT:-5432}"
DB_NAME="${DB_NAME:-app_db}"
DB_USER="${DB_USER:-app_user}"
DB_PASSWORD="${DB_PASSWORD:-}"

if [ -z "$DB_PASSWORD" ]; then echo "DB_PASSWORD manquant"; exit 2; fi
TS=$(date +%Y%m%d_%H%M%S)
DEST="$BACKUP_DIR/$(date +%Y)/$(date +%m-%d)"; mkdir -p "$DEST"
OUT="$DEST/${DB_NAME}_${TS}.sql.gz"

if command -v docker >/dev/null 2>&1; then
  echo "Docker detecte"
  docker run --rm -e PGPASSWORD="$DB_PASSWORD" -v "$(pwd)/$DEST:/dump" postgres:16 \
    bash -lc "pg_dump -h $DB_HOST -p $DB_PORT -U $DB_USER $DB_NAME | gzip -c > /dump/$(basename "$OUT")"
else
  echo "Docker absent; tentative pg_dump local"
  export PGPASSWORD="$DB_PASSWORD"
  pg_dump -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" "$DB_NAME" | gzip -c > "$OUT"
fi
[ -s "$OUT" ] || { echo "Backup vide"; exit 5; }
find "$BACKUP_DIR" -type f -name "*.sql.gz" -mtime +"$RETENTION_DAYS" -delete

echo "OK: $OUT"
