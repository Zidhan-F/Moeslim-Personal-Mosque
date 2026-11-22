#!/bin/sh
set -eu

# Backup harian PostgreSQL untuk Moeslim Mosque VPS.
# Simpan 14 hari terakhir di folder lokal; aktifkan rclone di bawah untuk salinan off-site (Cloudflare R2 / S3).

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
BACKEND_DIR="$(dirname "$SCRIPT_DIR")"
BACKUP_DIR="${BACKUP_DIR:-$BACKEND_DIR/backups}"
ENV_FILE="${ENV_FILE:-$BACKEND_DIR/.env.production}"
STAMP="$(date -u +%Y%m%d-%H%M%S)"
OUT_FILE="$BACKUP_DIR/moeslim-db-$STAMP.sql.gz"

mkdir -p "$BACKUP_DIR"

if [ -f "$ENV_FILE" ]; then
    # shellcheck disable=SC1090
    set -a
    . "$ENV_FILE"
    set +a
fi

cd "$BACKEND_DIR"

docker compose -f docker-compose.prod.yml --env-file "$ENV_FILE" exec -T db \
    pg_dump -U "${DB_USERNAME:-moeslim}" -d "${DB_DATABASE:-moeslim}" --no-owner --no-privileges \
    | gzip -9 > "$OUT_FILE"

echo "Backup selesai: $OUT_FILE"

# Hapus backup lokal lebih dari 14 hari.
find "$BACKUP_DIR" -type f -name 'moeslim-db-*.sql.gz' -mtime +14 -delete

# Opsional: kirim salinan ke Cloudflare R2 / S3 (pasang rclone & konfigurasi remote 'r2').
# if command -v rclone >/dev/null 2>&1; then
#     rclone copy "$OUT_FILE" "r2:moeslim-backups/db/"
# fi
