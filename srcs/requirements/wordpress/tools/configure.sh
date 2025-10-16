#!/bin/sh

set -e

echo "Starting WordPress configuration..."

# Esperar a que MariaDB esté disponible (con timeout)
echo "Waiting for MariaDB to be ready..."
timeout=60
count=0
while ! mysqladmin ping -h"mariadb" -u"${WORDPRESS_DB_USER}" -p"${WORDPRESS_DB_PASSWORD}" --silent; do
    echo "Waiting for database connection... ($count/$timeout)"
    sleep 2
    count=$((count + 2))
    if [ $count -ge $timeout ]; then
        echo "ERROR: Database connection timeout after $timeout seconds"
        break
    fi
done

echo "Database is ready!"

# Verificar si WordPress ya está instalado
if [ ! -f /var/www/html/wp-config.php ]; then
    echo "WordPress not found. Installing..."

    # Cambiar temporalmente a root para la instalación
    su-exec root sh -c "wp core download --path=/var/www/html --locale=en_US"
    su-exec root sh -c "wp config create \
        --path=/var/www/html \
        --dbname=${WORDPRESS_DB_NAME} \
        --dbuser=${WORDPRESS_DB_USER} \
        --dbpass=${WORDPRESS_DB_PASSWORD} \
        --dbhost=${WORDPRESS_DB_HOST} \
        --dbcharset=utf8 \
        --dbcollate=utf8_general_ci \
        --skip-check"

    # Instalar WordPress
    su-exec root sh -c "wp core install \
        --path=/var/www/html \
        --url=https://${DOMAIN_NAME} \
        --title='Inception Project' \
        --admin_user=${WP_ADMIN_USER} \
        --admin_password=${WP_ADMIN_PASSWORD} \
        --admin_email=${WP_ADMIN_EMAIL} \
        --skip-email"

    # Configuraciones adicionales
    su-exec root sh -c "wp option update siteurl 'https://${DOMAIN_NAME}' --path=/var/www/html"
    su-exec root sh -c "wp option update home 'https://${DOMAIN_NAME}' --path=/var/www/html"

    echo "WordPress installed successfully!"
else
    echo "WordPress is already installed."
fi

# Configurar permisos
find /var/www/html -type d -exec chmod 755 {} \;
find /var/www/html -type f -exec chmod 644 {} \;

echo "Starting PHP-FPM..."
exec php-fpm81 -F
