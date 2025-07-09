#!/bin/sh
set -e

# 1) Copy WordPress files if not present
if [ ! -f /var/www/html/wp-load.php ]; then
  echo "Copiando WordPress..."
  curl -fsSL https://wordpress.org/latest.tar.gz -o /tmp/wordpress.tar.gz
  mkdir -p /var/www/html
  tar zxvf /tmp/wordpress.tar.gz -C /var/www/html --strip-components=1
  rm /tmp/wordpress.tar.gz
fi

cd /var/www/html

# 2) Generate wp-config.php if not exists
if [ ! -f wp-config.php ]; then
  echo "Generando wp-config.php..."
  wp config create \
    --dbhost="${WORDPRESS_DB_HOST}:${WORDPRESS_DB_PORT}" \
    --dbname="$WORDPRESS_DB_NAME" \
    --dbuser="$WORDPRESS_DB_USER" \
    --dbpass="$WORDPRESS_DB_PASSWORD" \
    --locale=es_ES \
    --skip-check \
    --allow-root
fi

# 3) Adjust permissions
chown -R www-data:www-data /var/www/html
find /var/www/html -type d -exec chmod 755 {} \;
find /var/www/html -type f -exec chmod 644 {} \;

# 4) Arranca PHP‑FPM en primer plano
#exec php-fpm -F
