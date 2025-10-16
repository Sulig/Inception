#!/bin/sh

set -e

echo "Starting WordPress configuration..."

# Espera mejorada para MariaDB
echo "Waiting for MariaDB to be ready..."
for i in {1..30}; do
    if mysql -h"mariadb" -u"${WORDPRESS_DB_USER}" -p"${WORDPRESS_DB_PASSWORD}" -e "SELECT 1" > /dev/null 2>&1; then
        echo "Database is ready!"
        break
    fi
    echo "Waiting for database connection... ($i/30)"
    sleep 2
done

# Si después de 30 intentos no conecta, salir
if ! mysql -h"mariadb" -u"${WORDPRESS_DB_USER}" -p"${WORDPRESS_DB_PASSWORD}" -e "SELECT 1" > /dev/null 2>&1; then
    echo "ERROR: Cannot connect to database after 60 seconds"
    exit 1
fi

# Verificar si WordPress ya está instalado
if [ ! -f /var/www/html/wp-config.php ]; then
    echo "WordPress not found. Installing..."

    # Cambiar a root temporalmente para instalación
    su-exec root wp core download --path=/var/www/html --locale=en_US
    su-exec root wp config create \
        --path=/var/www/html \
        --dbname=${WORDPRESS_DB_NAME} \
        --dbuser=${WORDPRESS_DB_USER} \
        --dbpass=${WORDPRESS_DB_PASSWORD} \
        --dbhost=${WORDPRESS_DB_HOST} \
        --dbcharset=utf8 \
        --dbcollate=utf8_general_ci \
        --skip-check

    # Instalar WordPress
    su-exec root wp core install \
        --path=/var/www/html \
        --url=https://${DOMAIN_NAME} \
        --title="Inception Project" \
        --admin_user=${WP_ADMIN_USER} \
        --admin_password=${WP_ADMIN_PASSWORD} \
        --admin_email=${WP_ADMIN_EMAIL} \
        --skip-email

    echo "WordPress installed successfully!"
else
    echo "WordPress is already installed."
fi

echo "Starting PHP-FPM..."
exec php-fpm81 -F
