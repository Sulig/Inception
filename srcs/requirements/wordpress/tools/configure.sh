#!/bin/sh

set -e

echo "Starting WordPress configuration..."

# Espera mejorada para MariaDB
echo "Waiting for MariaDB to be ready..."
for i in $(seq 1 30); do
    if mysql -h"mariadb" -u"${WORDPRESS_DB_USER}" -p"${WORDPRESS_DB_PASSWORD}" -e "SELECT 1" > /dev/null 2>&1; then
        echo "Database is ready!"
        break
    fi
    echo "Waiting for database connection... ($i/30)"
    sleep 2
done

# Verificar conexión final
if ! mysql -h"mariadb" -u"${WORDPRESS_DB_USER}" -p"${WORDPRESS_DB_PASSWORD}" -e "SELECT 1" > /dev/null 2>&1; then
    echo "ERROR: Cannot connect to database after 60 seconds"
    exit 1
fi

# Verificar si WordPress ya está instalado
if [ ! -f /var/www/html/wp-config.php ]; then
    echo "WordPress not found. Installing..."

    # Cambiar temporalmente a root usando sudo (si está disponible) o ejecutar como wordpress
    # Primero intentamos como wordpress, si falla, usamos un enfoque diferente
    cd /var/www/html

    # Descargar WordPress
    wp core download --locale=en_US --allow-root

    # Crear archivo de configuración
    wp config create \
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
        --url=https://${DOMAIN_NAME} \
        --title="Inception Project" \
        --admin_user=${WP_ADMIN_USER} \
        --admin_password=${WP_ADMIN_PASSWORD} \
        --admin_email=${WP_ADMIN_EMAIL} \
        --skip-email \
        --allow-root

    echo "WordPress installed successfully!"
else
    echo "WordPress is already installed."
fi

# Configurar permisos básicos
chown -R wordpress:wordpress /var/www/html
find /var/www/html -type d -exec chmod 755 {} \;
find /var/www/html -type f -exec chmod 644 {} \;

# Crear directorio de uploads con permisos correctos
mkdir -p /var/www/html/wp-content/uploads
chmod 775 /var/www/html/wp-content/uploads

echo "Starting PHP-FPM..."
exec php-fpm81 -F
