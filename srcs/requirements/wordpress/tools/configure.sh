#!/bin/sh
set -e

# Copy WordPress files if directory empty
if [ -z "$(ls -A /var/www/html)" ]; then
    cp -a /usr/src/wordpress/. /var/www/html/
fi

# Get password from Docker secret
DB_PASSWORD=$(cat /run/secrets/db_password)

# Create wp-config.php
wp config create \
    --dbhost="$WORDPRESS_DB_HOST" \
    --dbname="$WORDPRESS_DB_NAME" \
    --dbuser="$WORDPRESS_DB_USER" \
    --dbpass="$DB_PASSWORD" \
    --locale=es_ES \
    --skip-check \
    --allow-root

# Adjust permissions
chown -R www-data:www-data /var/www/html
find /var/www/html -type d -exec chmod 755 {} \;
find /var/www/html -type f -exec chmod 644 {} \;
