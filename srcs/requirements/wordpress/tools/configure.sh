#!/bin/sh
# srcs/requirements/wordpress/tools/configure.sh
set -e

echo "🔍 Esperando a que MariaDB esté lista..."

# Esperar hasta que MariaDB esté disponible
until mysql -h mariadb -u ${WORDPRESS_DB_USER} -p${WORDPRESS_DB_PASSWORD} -e "SELECT 1;" ${WORDPRESS_DB_NAME} 2>/dev/null; do
    echo "⏳ MariaDB no está lista aún... esperando"
    sleep 2
done

echo "✅ MariaDB está lista!"

echo "🎯 Verificando configuración de WordPress..."

# Si wp-config.php no existe, crearlo
if [ ! -f "/var/www/html/wp-config.php" ]; then
    echo "📝 Creando wp-config.php..."

    # Crear wp-config.php básico
    cat > /var/www/html/wp-config.php << EOF
<?php
define('DB_NAME', '${WORDPRESS_DB_NAME}');
define('DB_USER', '${WORDPRESS_DB_USER}');
define('DB_PASSWORD', '${WORDPRESS_DB_PASSWORD}');
define('DB_HOST', 'mariadb');
define('DB_CHARSET', 'utf8');
define('DB_COLLATE', '');

define('AUTH_KEY',         '$(openssl rand -base64 48)');
define('SECURE_AUTH_KEY',  '$(openssl rand -base64 48)');
define('LOGGED_IN_KEY',    '$(openssl rand -base64 48)');
define('NONCE_KEY',        '$(openssl rand -base64 48)');
define('AUTH_SALT',        '$(openssl rand -base64 48)');
define('SECURE_AUTH_SALT', '$(openssl rand -base64 48)');
define('LOGGED_IN_SALT',   '$(openssl rand -base64 48)');
define('NONCE_SALT',       '$(openssl rand -base64 48)');

\$table_prefix = 'wp_';
define('WP_DEBUG', false);

if ( ! defined('ABSPATH') ) {
    define('ABSPATH', __DIR__ . '/');
}

require_once ABSPATH . 'wp-settings.php';
EOF

    echo "✅ wp-config.php creado"
else
    echo "✅ wp-config.php ya existe"
fi

# Asegurar permisos
chown -R nobody:nobody /var/www/html
chmod -R 755 /var/www/html
chmod 644 /var/www/html/wp-config.php

echo "🚀 Iniciando PHP-FPM..."
exec php-fpm81 -F

###
