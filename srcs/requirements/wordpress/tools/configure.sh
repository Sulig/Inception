#!/bin/sh
set -e

# Copiar WordPress si está vacío
if [ ! -f /var/www/html/wp-config.php ]; then
    cp -a /usr/src/wordpress/. /var/www/html/
fi

# Configurar wp-config.php
if [ ! -f /var/www/html/wp-config.php ]; then
    wp config create \
        --dbhost="$WORDPRESS_DB_HOST" \
        --dbname="$WORDPRESS_DB_NAME" \
        --dbuser="$WORDPRESS_DB_USER" \
        --dbpass="$(cat $WORDPRESS_DB_PASSWORD_FILE)" \
        --locale=es_ES \
        --skip-check \
        --allow-root
fi

# Configurar permisos
chown -R www-data:www-data /var/www/html
find /var/www/html -type d -exec chmod 755 {} \;
find /var/www/html -type f -exec chmod 644 {} \;

exec "$@"
