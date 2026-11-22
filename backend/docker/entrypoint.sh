#!/bin/sh
set -eu

mkdir -p \
    storage/app/private \
    storage/app/public \
    storage/framework/cache/data \
    storage/framework/sessions \
    storage/framework/views \
    storage/logs \
    bootstrap/cache

# Pastikan symlink public/storage tersedia bila belum dibuat.
if [ ! -e public/storage ]; then
    php artisan storage:link --no-interaction || true
fi

# Tunggu PostgreSQL siap dan jalankan migrasi hanya pada kontainer utama (RUN_MIGRATIONS=true).
if [ "${RUN_MIGRATIONS:-false}" = "true" ]; then
    if [ "${DB_CONNECTION:-pgsql}" = "pgsql" ] && [ -n "${DB_HOST:-}" ]; then
        echo "Menunggu PostgreSQL di ${DB_HOST}:${DB_PORT:-5432}..."
        tries=0
        until pg_isready -h "${DB_HOST}" -p "${DB_PORT:-5432}" -U "${DB_USERNAME:-moeslim}" -d "${DB_DATABASE:-moeslim}" >/dev/null 2>&1; do
            tries=$((tries + 1))
            if [ "$tries" -ge 30 ]; then
                echo "PostgreSQL tidak merespons setelah 30 detik." >&2
                exit 1
            fi
            sleep 1
        done
    fi

    echo "Menjalankan migrasi database..."
    php artisan migrate --force --no-interaction
fi

# Cache konfigurasi & rute untuk performa produksi.
if [ "${APP_ENV:-production}" = "production" ]; then
    php artisan config:cache --no-interaction
    php artisan route:cache --no-interaction
    php artisan view:cache --no-interaction
fi

exec "$@"
