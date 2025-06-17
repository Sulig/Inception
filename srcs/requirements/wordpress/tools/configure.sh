#!/bin/bash
set -e

# Si ya existe wp-config.php, salimos
if [ -f wp-config.php ]; then
  exec "$@"
  exit 0
fi

# Variables de entorno
: "${WORDPRESS_DB_HOST:?env var missing}"
: "${WORDPRESS_DB_NAME:?env var missing}"
: "${WORDPRESS_DB_USER:?env var missing}"
# password viene de secreto montado
DB_PW=$(cat /run/secrets/db_password)

# Descargamos WordPress
curl -o latest.tar.gz https://wordpress.org/latest.tar.gz
tar zxvf latest.tar.gz --strip-components=1
rm latest.tar.gz

# Generamos wp-config.php con sustitución de variables
cat > wp-config.php <<-EOF
<?php
define('DB_NAME', '${WORDPRESS_DB_NAME}');
define('DB_USER', '${WORDPRESS_DB_USER}');
define('DB_PASSWORD', '${DB_PW}');
define('DB_HOST', '${WORDPRESS_DB_HOST}');
define('DB_CHARSET', 'utf8mb4');
define('DB_COLLATE', '');

\$table_prefix = 'wp_';

define('AUTH_KEY',         'put your unique phrase here');
define('SECURE_AUTH_KEY',  'put your unique phrase here');
define('LOGGED_IN_KEY',    'put your unique phrase here');
define('NONCE_KEY',        'put your unique phrase here');
define('AUTH_SALT',        'put your unique phrase here');
define('SECURE_AUTH_SALT', 'put your unique phrase here');
define('LOGGED_IN_SALT',   'put your unique phrase here');
define('NONCE_SALT',       'put your unique phrase here');

if ( ! defined('ABSPATH') ) {
    define('ABSPATH', __DIR__ . '/');
}

require_once ABSPATH . 'wp-settings.php';
EOF

# Ajustar permisos
chown -R www-data:www-data .
chmod 640 wp-config.php

# Finalmente, arrancar php-fpm
exec "$@"

