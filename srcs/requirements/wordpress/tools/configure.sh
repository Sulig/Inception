#!/bin/sh
# srcs/requirements/wordpress/tools/configure.sh
set -e

echo "🎯 Configurando WordPress..."

# Esperar un momento para que MariaDB esté listo
echo "⏳ Esperando a MariaDB..."
sleep 15

# Solo crear wp-config.php si no existe
if [ ! -f "/var/www/html/wp-config.php" ]; then
    echo "📝 Creando wp-config.php..."

    cat > /var/www/html/wp-config.php << EOF
<?php
define('DB_NAME', '${WORDPRESS_DB_NAME}');
define('DB_USER', '${WORDPRESS_DB_USER}');
define('DB_PASSWORD', '${WORDPRESS_DB_PASSWORD}');
define('DB_HOST', 'mariadb');
define('DB_CHARSET', 'utf8');
define('DB_COLLATE', '');

define('AUTH_KEY',         'put-your-unique-phrase-here');
define('SECURE_AUTH_KEY',  'put-your-unique-phrase-here');
define('LOGGED_IN_KEY',    'put-your-unique-phrase-here');
define('NONCE_KEY',        'put-your-unique-phrase-here');
define('AUTH_SALT',        'put-your-unique-phrase-here');
define('SECURE_AUTH_SALT', 'put-your-unique-phrase-here');
define('LOGGED_IN_SALT',   'put-your-unique-phrase-here');
define('NONCE_SALT',       'put-your-unique-phrase-here');

\$table_prefix = 'wp_';
define('WP_DEBUG', false);

if ( ! defined('ABSPATH') ) {
    define('ABSPATH', __DIR__ . '/');
}

require_once ABSPATH . 'wp-settings.php';
EOF

    echo "✅ wp-config.php creado"
fi

# Permisos básicos
chown -R nobody:nobody /var/www/html

echo "🚀 Iniciando PHP-FPM..."
exec php-fpm81 -F
