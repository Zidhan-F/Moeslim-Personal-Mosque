# Stage 1: PHP dependencies (production only)
FROM composer:2.8 AS vendor
WORKDIR /app
COPY composer.json composer.lock ./
RUN composer install \
    --no-dev \
    --no-interaction \
    --prefer-dist \
    --optimize-autoloader \
    --no-scripts

# Stage 2: Frontend assets (Vite for Blade pages)
FROM node:22-alpine AS assets
WORKDIR /app
COPY package.json vite.config.js ./
COPY resources ./resources
RUN npm install --no-audit --no-fund && npm run build

# Stage 3: Production runtime (PHP 8.3 + Apache + PostgreSQL + Redis + OPcache)
FROM php:8.3-apache-bookworm AS production

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        curl \
        libfreetype6-dev \
        libicu-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
        libpq-dev \
        libzip-dev \
        postgresql-client \
        unzip \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j"$(nproc)" \
        bcmath \
        gd \
        intl \
        opcache \
        pdo_pgsql \
        pgsql \
        zip \
    && pecl install redis \
    && docker-php-ext-enable redis \
    && rm -rf /var/lib/apt/lists/* /tmp/pear

RUN a2enmod rewrite headers \
    && sed -ri 's!/var/www/html!/var/www/html/public!g' /etc/apache2/sites-available/*.conf /etc/apache2/apache2.conf \
    && sed -ri 's/AllowOverride None/AllowOverride All/g' /etc/apache2/apache2.conf \
    && sed -ri 's/Listen 80/Listen 8080/g' /etc/apache2/ports.conf \
    && sed -ri 's/<VirtualHost \*:80>/<VirtualHost *:8080>/g' /etc/apache2/sites-available/000-default.conf

RUN { \
    echo 'expose_php = Off'; \
    echo 'display_errors = Off'; \
    echo 'log_errors = On'; \
    echo 'error_log = /dev/stderr'; \
    echo 'memory_limit = 256M'; \
    echo 'upload_max_filesize = 10M'; \
    echo 'post_max_size = 12M'; \
    echo 'max_execution_time = 60'; \
    echo 'opcache.enable = 1'; \
    echo 'opcache.memory_consumption = 128'; \
    echo 'opcache.interned_strings_buffer = 16'; \
    echo 'opcache.max_accelerated_files = 10000'; \
    echo 'opcache.validate_timestamps = 0'; \
    } > /usr/local/etc/php/conf.d/99-moeslim-prod.ini

WORKDIR /var/www/html

COPY --chown=www-data:www-data . .
COPY --from=vendor --chown=www-data:www-data /app/vendor ./vendor
COPY --from=assets --chown=www-data:www-data /app/public/build ./public/build
COPY docker/entrypoint.sh /usr/local/bin/entrypoint.sh

RUN chmod +x /usr/local/bin/entrypoint.sh \
    && mkdir -p storage/app/private storage/app/public storage/framework/cache/data storage/framework/sessions storage/framework/views storage/logs bootstrap/cache \
    && chown -R www-data:www-data storage bootstrap/cache \
    && su -s /bin/sh www-data -c "php artisan package:discover --ansi"

USER www-data

ENV PORT=8080
EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=5s --start-period=20s --retries=3 \
    CMD curl -fsS "http://127.0.0.1:${PORT:-8080}/up" > /dev/null || exit 1

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["apache2-foreground"]
