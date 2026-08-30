#!/usr/bin/env bash
# Dump diario do Postgres, mantendo os 7 mais recentes.
# Instalar no crontab da VM (3h da manha):
#   crontab -e
#   0 3 * * * /home/ubuntu/farm-management/deploy/backup.sh >> /home/ubuntu/backup.log 2>&1
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BACKUP_DIR="${BACKUP_DIR:-$HOME/backups}"
KEEP=7

mkdir -p "$BACKUP_DIR"
cd "$PROJECT_DIR"

# shellcheck disable=SC1091
set -a; source .env; set +a

STAMP="$(date +%Y-%m-%d_%H%M)"
OUT="$BACKUP_DIR/farmdb_${STAMP}.sql.gz"

docker compose -f docker-compose.prod.yaml exec -T database \
    pg_dump -U "$POSTGRES_USER" -d "$POSTGRES_DB" | gzip > "$OUT"

echo "[$(date -Is)] backup gerado: $OUT ($(du -h "$OUT" | cut -f1))"

# Remove os mais antigos, mantendo os $KEEP ultimos.
ls -1t "$BACKUP_DIR"/farmdb_*.sql.gz | tail -n "+$((KEEP + 1))" | xargs -r rm -f
