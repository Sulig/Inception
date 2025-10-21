#!/bin/sh
# srcs/requirements/wordpress/tools/configure.sh
set -e

echo "🎯 Configurando WordPress..."

# Esperar a que MariaDB esté realmente listo (más robusto)
echo "⏳ Esperando a MariaDB..."
timeout=60
while ! mysql -h mariadb -u ${WORDPRESS_DB_USER} -p${WORDPRESS_DB_PASSWORD} -e "SELECT 1;" ${WORDPRESS_DB_NAME} 2>/dev/null; do
  sleep 2
  timeout=$((timeout - 2))
  if [ $timeout -le 0 ]; then
    echo "❌ No se puede conectar a MariaDB después de 60 segundos"
    echo "🔍 Verificando variables:"
    echo "DB_HOST: mariadb"
    echo "DB_USER: ${WORDPRESS_DB_USER}"
    echo "DB_NAME: ${WORDPRESS_DB_NAME}"
    exit 1
  fi
  echo "⏰ Esperando conexión a MariaDB... ($timeout segundos restantes)"
done
echo "✅ Conectado a MariaDB"

# Crear wp-config.php si no existe
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

# Configurar permisos
chown -R nobody:nobody /var/www/html
chmod -R 755 /var/www/html

echo "🚀 Iniciando PHP-FPM..."
exec php-fpm81 -F
