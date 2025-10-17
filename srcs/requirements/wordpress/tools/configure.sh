#!/bin/sh
# srcs/requirements/wordpress/tools/configure.sh
set -e

echo "🔍 Verificando conectividad con MariaDB..."

# Intentar conexión con MariaDB
while true; do
    if mysql -h mariadb -u ${WORDPRESS_DB_USER} -p${WORDPRESS_DB_PASSWORD} -e "SELECT 1;" ${WORDPRESS_DB_NAME} 2>/dev/null; then
        echo "✅ Conectado a MariaDB"
        break
    else
        echo "⏳ Esperando a MariaDB... (mysql -h mariadb -u ${WORDPRESS_DB_USER} -p[password] ${WORDPRESS_DB_NAME})"
        sleep 2
    fi
done

echo "🎯 Configurando WordPress..."

# Verificar si wp-config.php ya existe
if [ ! -f "/var/www/html/wp-config.php" ]; then
    echo "📝 Creando archivo de configuración de WordPress..."

    # Crear wp-config.php
    cat > /var/www/html/wp-config.php << EOF
<?php
define('DB_NAME', '${WORDPRESS_DB_NAME}');
define('DB_USER', '${WORDPRESS_DB_USER}');
define('DB_PASSWORD', '${WORDPRESS_DB_PASSWORD}');
define('DB_HOST', 'mariadb');
define('DB_CHARSET', 'utf8');
define('DB_COLLATE', '');

$(curl -s https://api.wordpress.org/secret-key/1.1/salt/)

\$table_prefix = 'wp_';
define('WP_DEBUG', false);

if ( ! defined('ABSPATH') ) {
    define('ABSPATH', __DIR__ . '/');
}

require_once ABSPATH . 'wp-settings.php';
EOF

    chown nobody:nobody /var/www/html/wp-config.php
    chmod 644 /var/www/html/wp-config.php
    echo "✅ wp-config.php creado"
else
    echo "✅ wp-config.php ya existe"
fi

echo "🚀 Iniciando PHP-FPM..."
exec php-fpm81 -F
