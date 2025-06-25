#!/bin/sh
set -e

# 1) Descargar y extraer WordPress si no está instalado
if [ ! -f /var/www/html/wp-load.php ]; then
  echo "Descargando WordPress..."
  curl -o latest.tar.gz https://wordpress.org/latest.tar.gz
  mkdir -p /var/www/html
  tar zxvf latest.tar.gz -C /var/www/html --strip-components=1
  rm latest.tar.gz
fi

# 2) Generar wp-config.php si no existe
if [ ! -f /var/www/html/wp-config.php ]; then
  echo "Generando wp-config.php..."
  wp config create \
    --path=/var/www/html \
    --dbhost="$WORDPRESS_DB_HOST" \
    --dbname="$WORDPRESS_DB_NAME" \
    --dbuser="$WORDPRESS_DB_USER" \
    --dbpass="$(cat $WORDPRESS_DB_PASSWORD_FILE)" \
    --locale=es_ES \
    --skip-check \
    --allow-root
fi

# 3) Ajustar permisos
chown -R www-data:www-data /var/www/html
find /var/www/html -type d -exec chmod 755 {} \;
find /var/www/html -type f -exec chmod 644 {} \;

# 4) Arrancar PHP-FPM
exec php-fpm

