#!/bin/sh

set -e

echo "Starting WordPress configuration..."

# Esperar a que MariaDB esté disponible
echo "Waiting for MariaDB to be ready..."
while ! mysqladmin ping -h"mariadb" -u"${WORDPRESS_DB_USER}" -p"${WORDPRESS_DB_PASSWORD}" --silent; do
    echo "Waiting for database connection..."
    sleep 2
done

echo "Database is ready!"

# Verificar si WordPress ya está instalado
if [ ! -f /var/www/html/wp-config.php ]; then
    echo "WordPress not found. Installing..."

    # Descargar WordPress
    wp core download --path=/var/www/html --locale=en_US --allow-root

    # Crear archivo de configuración
    wp config create \
        --path=/var/www/html \
        --dbname=${WORDPRESS_DB_NAME} \
        --dbuser=${WORDPRESS_DB_USER} \
        --dbpass=${WORDPRESS_DB_PASSWORD} \
        --dbhost=${WORDPRESS_DB_HOST} \
        --dbcharset=utf8 \
        --dbcollate=utf8_general_ci \
        --skip-check \
        --allow-root

    # Instalar WordPress
    wp core install \
        --path=/var/www/html \
        --url=https://${DOMAIN_NAME} \
        --title="Inception Project" \
        --admin_user=${WP_ADMIN_USER} \
        --admin_password=${WP_ADMIN_PASSWORD} \
        --admin_email=${WP_ADMIN_EMAIL} \
        --skip-email \
        --allow-root

    # Configuraciones adicionales de WordPress
    wp option update siteurl "https://${DOMAIN_NAME}" --path=/var/www/html --allow-root
    wp option update home "https://${DOMAIN_NAME}" --path=/var/www/html --allow-root

    # Configurar permisos para uploads
    mkdir -p /var/www/html/wp-content/uploads
    chmod 755 /var/www/html/wp-content/uploads

    echo "WordPress installed successfully!"
else
    echo "WordPress is already installed."
fi

# Configurar permisos
chown -R wordpress:wordpress /var/www/html
find /var/www/html -type d -exec chmod 755 {} \;
find /var/www/html -type f -exec chmod 644 {} \;

echo "Starting PHP-FPM..."
exec php-fpm81 -F
