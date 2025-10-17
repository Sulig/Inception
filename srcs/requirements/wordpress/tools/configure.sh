#!/bin/sh
set -e

echo "Esperando a que MariaDB esté lista..."
while ! mysqladmin ping -h"mariadb" -u"${WORDPRESS_DB_USER}" -p"${WORDPRESS_DB_PASSWORD}" --silent; do
    echo "Esperando a MariaDB..."
    sleep 2
done

echo "MariaDB está lista. Configurando WordPress..."

# Verificar si wp-config.php ya existe
if [ ! -f "/var/www/html/wp-config.php" ]; then
    echo "Creando archivo de configuración de WordPress..."

    # Crear wp-config.php usando las variables de entorno
    cat > /var/www/html/wp-config.php << EOF
<?php
define('DB_NAME', '${WORDPRESS_DB_NAME}');
define('DB_USER', '${WORDPRESS_DB_USER}');
define('DB_PASSWORD', '${WORDPRESS_DB_PASSWORD}');
define('DB_HOST', '${WORDPRESS_DB_HOST}');
define('DB_CHARSET', 'utf8');
define('DB_COLLATE', '');

// Claves de seguridad (puedes generarlas o usar valores fijos para desarrollo)
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

    # Configurar permisos
    chown nobody:nobody /var/www/html/wp-config.php
    chmod 644 /var/www/html/wp-config.php
fi

echo "Iniciando PHP-FPM..."
exec php-fpm81 -F
