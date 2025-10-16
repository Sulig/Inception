#!/bin/sh

set -e

echo "=== WORDPRESS SETUP ==="

# Esperar por MySQL
echo "Waiting for database..."
while ! mysql -hmariadb -u${WORDPRESS_DB_USER} -p${WORDPRESS_DB_PASSWORD} -e "SELECT 1" 2>/dev/null; do
    sleep 2
    echo "Still waiting..."
done

echo "Database is ready!"

# Instalar WordPress si no existe
if [ ! -f /var/www/html/wp-config.php ]; then
    echo "Installing WordPress..."

    cd /var/www/html

    # Descargar WordPress
    wp core download --locale=en_US --allow-root

    # Crear configuración
    wp config create \
        --dbname=${WORDPRESS_DB_NAME} \
        --dbuser=${WORDPRESS_DB_USER} \
        --dbpass=${WORDPRESS_DB_PASSWORD} \
        --dbhost=${WORDPRESS_DB_HOST} \
        --allow-root

    # Instalar
    wp core install \
        --url=https://${DOMAIN_NAME} \
        --title="Inception" \
        --admin_user=${WP_ADMIN_USER} \
        --admin_password=${WP_ADMIN_PASSWORD} \
        --admin_email=${WP_ADMIN_EMAIL} \
        --allow-root

    echo "WordPress installed!"
fi

# Iniciar PHP-FPM
echo "Starting PHP-FPM..."
exec php-fpm81 -F
